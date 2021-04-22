package controllers

/**
	会议管理
**/
import (
	"encoding/json"
	"net/http"
	"strings"

	"emlearn/model"
	"emlearn/service"

	"github.com/autumnzw/hiweb"
	"github.com/doug-martin/goqu/v9"
	"gitlab.bjictc.com/go/logsd"
	"gitlab.bjictc.com/go/sqlham"
)

const (
	secondFormat = "2006-01-02 15:04:05"
)

type Conference struct {
	hiweb.Controller
}

// @Description get Conference
// @Param key Conference id
// @auth
func (c *Conference) Get(key int) {
	conf := model.Conference{}
	err := sqlham.GetByKey(key, &conf)
	if err != nil {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
		logsd.Error("err:%s", err)
		return

	}
	c.ServeJSON(http.StatusOK, service.SuccessData(conf))

}

// @Description get Conference detail
// @Param key Conference id
// @HttpGet
// @auth
func (c *Conference) GetConfDetail(key int) {
	conf := model.Conference{}
	err := sqlham.GetByKey(key, &conf)
	if err != nil {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
		logsd.Error("err:%s", err)
		return
	}
	_, err = service.Token()
	if err != nil {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
		logsd.Error("err:%s", err)
		return
	}
	tconf, err := service.GetConference(conf.EasemobKey)
	if err != nil {
		conf.SetState(-1)
		err = sqlham.Update(&conf)
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		}
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
		logsd.Error("err:%s", err)
		return
	}

	c.ServeJSON(http.StatusOK, service.SuccessData(tconf))

}

// @Description entry
// @Param name 会议名称
// @Param username 用户名称
// @Param password 密码
// @Param role 角色
// @Param confrType 会议类型
// @httppost
func (c *Conference) Entry(name, username, password, role, confrType string) {
	accessToken, err := service.Token()
	if err != nil {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
		logsd.Error("token err:%s", err)
		return
	}
	confs := make([]model.Conference, 0)
	findConf := sqlham.NewGoqu().
		Where(
			goqu.I(model.NameConference).Eq(name),
			goqu.I(model.ConferenceTypeConference).Eq(confrType),
			goqu.I(model.StateConference).Eq(0)).Order(goqu.I("create_time").Desc())
	err = sqlham.List(findConf, &confs)
	if err != nil && err != sqlham.ErrNotFound {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
		logsd.Error("err:%s", err)
		return
	}
	isCreateConf := false
	isCreateChat := false
	if len(confs) == 0 {
		isCreateConf = true
		isCreateChat = true
	} else {
		tconf, err := service.GetConference(confs[0].EasemobKey)
		if err != nil || tconf == nil {
			confs[0].SetState(-1)
			err = sqlham.Update(&confs[0])
			if err != nil {
				c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
				logsd.Error("err get conf:%s", err)
				return
			}
			isCreateConf = true
		}
		roomId, err := service.GetChatroom(confs[0].ChatRoomId)
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err get chat room:%s", err)
			return
		}
		if roomId == "" {
			isCreateChat = true
		}
	}
	//判断多个老师
	if !isCreateConf {
		tusers := make([]model.DefAuthUser, 0)
		findUser := sqlham.NewGoqu().Where(
			goqu.I(model.ConferenceKeyDefAuthUser).Eq(confs[0].EasemobKey),
			goqu.I(model.IsLoginDefAuthUser).Eq(1),
		)
		err = sqlham.List(findUser, &tusers)
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		}
		hasTeacher := false
		hasStudent := false
		for _, tuser := range tusers {
			if tuser.UserRole == "teacher" {
				hasTeacher = true
			}
			if tuser.UserRole == "student" {
				hasStudent = true
			}
		}
		if hasTeacher && role == "teacher" {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.MULTIPLE_TEACHER))
			logsd.Error("tow teacher in")
			return
		}
		if confrType == "one" && hasStudent && role == "student" {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.MULTIPLE_STUDENT))
			logsd.Error("tow student in")
			return
		}
	}
	/*创建用户*/
	teacherId := ""
	teacherName := ""
	selfUserId := ""
	selfUserName := ""
	isUserExist := true
	isTeacherExist := true
	if isCreateConf {
		if role == "student" {
			isUserExist, selfUserId, selfUserName, err = service.EntryStudent(username, "")
			if err != nil {
				c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
				logsd.Error("create student err")
				return
			}
			isTeacherExist, teacherId, teacherName, err = service.EntryTeacher(username, "")
		} else if role == "teacher" {
			isUserExist, selfUserId, teacherName, err = service.EntryTeacher(username, "")
			selfUserName = teacherName
		}
	} else {
		isUserExist, selfUserId, selfUserName, err = service.EntryUser(role, username, confs[0].EasemobKey)
	}
	if err != nil {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
		logsd.Error("create conf:%v create:%s u:%s err:%s", isCreateConf, role, username, err)
		return
	}
	/*创建聊天室*/
	var chatRoomId = ""
	if isCreateChat {
		chatRoomId, err = service.CreateChatroom(name, teacherName)
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("create chat err:%s", err)
			return
		}
	} else {
		chatRoomId = confs[0].ChatRoomId
	}
	/*创建会议*/
	var confrId = ""
	if isCreateConf {
		conf := model.Conference{}
		conf.SetName(name)
		conf.SetUserName(username)

		conf.SetChatRoomId(chatRoomId)
		conf.SetConferenceType(confrType)
		econf, err := service.CreateConferences(teacherName, password)
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("create conf err:%s", err)
			return
		}
		conf.SetPassword(password)
		conf.SetEasemobKey(econf.Id)
		conf.SetEasemobPwd(econf.Password)
		conf.SetEasemobOwnerKey(teacherName)
		_, err = sqlham.InsertReturn(&conf)
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		}
		confrId = econf.Id
		logsd.Info("create conf n:%s un:%s p:%s r:%s ct:%s id:%s", name, username, password, role, confrType, confrId)
	} else {
		confrId = confs[0].EasemobKey
		logsd.Info("use conf id:%s", confrId)
	}
	if !isUserExist {
		duser := model.DefAuthUser{}
		duser.SetEmUserKey(selfUserId)
		duser.SetEmUserName(selfUserName)
		duser.SetNickName(username)
		duser.SetConferenceKey(confrId)
		duser.SetUserRole(role)
		duser.SetIsLogin(1)
		err = sqlham.Insert(&duser)
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		}
	}
	if !isTeacherExist {
		duser := model.DefAuthUser{}
		duser.SetEmUserKey(teacherId)
		duser.SetEmUserName(teacherName)
		duser.SetNickName(username)
		duser.SetConferenceKey(confrId)
		duser.SetUserRole("teacher")
		duser.SetIsLogin(0)
		err = sqlham.Insert(&duser)
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		}
	}
	tokenParam := map[string]interface{}{
		"key":      selfUserName,
		"nickname": username,
	}
	tokenString, err := hiweb.JwtToken(tokenParam)
	if err != nil {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
		logsd.Error("err:%s", err)
		return
	}
	c.ServeJSON(http.StatusOK, service.SuccessData(struct {
		EmToken   string
		EmUserId  string
		EmName    string
		EmconfrId string
		EmChatId  string
		SysToken  string
	}{
		EmToken:   accessToken,
		EmUserId:  selfUserId,
		EmName:    selfUserName,
		EmconfrId: confrId,
		EmChatId:  chatRoomId,
		SysToken:  tokenString,
	}))

}

type ConfrUserOper struct {
	NickName  string
	Name      string
	IsWhite   bool
	IsMessage bool
	Role      int
}

// @Description get Conference detail
// @Param key Conference id
// @HttpGet
// @auth
func (c *Conference) GetConfrOper(confrId string) {
	confs := make([]model.Conference, 0)
	findConf := sqlham.NewGoqu().
		Where(goqu.I(model.EasemobKeyConference).Eq(confrId))
	err := sqlham.List(findConf, &confs)
	if err != nil && err != sqlham.ErrNotFound {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
		logsd.Error("err:%s", err)
		return
	}
	if len(confs) == 0 {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
		logsd.Error("key:%s not found", confrId)
		return
	}
	conf := confs[0]
	tconf, err := service.GetConference(conf.EasemobKey)
	if err != nil || tconf == nil {
		confs[0].SetState(-1)
		err = sqlham.Update(&confs[0])
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err get conf:%s", err)
			return
		}
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.CONFER_CLOSE))
		logsd.Error("not found conf:%s", conf.EasemobKey)
		return
	}
	muteUsers, err := service.GetChatroomMute(conf.ChatRoomId)
	if err != nil {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
		logsd.Error("err get room mute:%s", err)
		return
	}
	muteMap := make(map[string]int)
	for _, muteUser := range muteUsers {
		muteMap[muteUser] = 1
	}
	whiteCloses := make([]string, 0)
	if len(conf.WhiteClose) > 0 {
		err := json.Unmarshal(conf.WhiteClose, &whiteCloses)
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
			logsd.Error("paser white:%s", err)
			return
		}
	}
	whiteMap := make(map[string]int)
	for _, whiteClose := range whiteCloses {
		whiteMap[whiteClose] = 1
	}
	logsd.Info("mems:%+v mutes:%+v whitec:%+v", tconf.Mems, muteUsers, whiteCloses)
	userOpers := make([]ConfrUserOper, 0)
	for _, mem := range tconf.Mems {
		userNames := strings.Split(mem.MemberName, "_")
		userName := ""
		if len(userNames) > 1 {
			userName = userNames[1]
		} else {
			userName = userNames[0]
		}
		tusers := make([]model.DefAuthUser, 0)
		logsd.Info("find username:%s", userName)
		findUser := sqlham.NewGoqu().
			Where(
				goqu.I(model.ConferenceKeyDefAuthUser).Eq(confrId),
				goqu.I(model.EmUserNameDefAuthUser).Eq(userName),
			)
		err := sqlham.List(findUser, &tusers)
		if err != nil {
			if err == sqlham.ErrNotFound {
				c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
				logsd.Error("not found user err:%s", err)
				return
			} else {
				c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
				logsd.Error("err:%s", err)
				return
			}

		}
		if len(tusers) == 0 {
			continue
		}
		userOper := ConfrUserOper{
			Name:     userName,
			NickName: tusers[0].NickName,
		}
		if _, has := muteMap[mem.MemberName]; has {
			userOper.IsMessage = false
		} else {
			userOper.IsMessage = true
		}
		if _, has := whiteMap[mem.MemberName]; has {
			userOper.IsWhite = false
		} else {
			userOper.IsWhite = true
		}
		userOper.Role = mem.Role
		userOpers = append(userOpers, userOper)
	}

	c.ServeJSON(http.StatusOK, service.SuccessData(userOpers))

}

type ChatroomMute struct {
	ConfrId   string   `json:"confrId"`
	UserNames []string `json:"UserNames"`
	IsOpen    int      `json:"isOpen"`
}

// @Description 设置聊天室静音
// @Param IsMute 1 取消禁言 -1 添加禁言
// @HttpPost
// @auth
func (c *Conference) SetChatroomMute(chatMute ChatroomMute) {
	userKey := c.GetClaim("key")
	if userKey == nil {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.USERID_GET_ERROR))
		logsd.Error("user key is nil")
		return
	}
	var err error
	if chatMute.IsOpen == 1 {
		err = service.DelChatroomMute(chatMute.ConfrId, chatMute.UserNames)
		logsd.Info("del mute:%+v", chatMute)
	} else if chatMute.IsOpen == -1 {
		err = service.AddChatroomMute(chatMute.ConfrId, chatMute.UserNames)
		logsd.Info("add mute:%+v", chatMute)
	} else {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
		logsd.Error("not supoort:%d", chatMute.IsOpen)
		return
	}

	if err != nil {
		c.ServeJSON(http.StatusOK, service.SuccessData(struct {
			IsOpen  int
			ConfrId string
		}{
			IsOpen:  chatMute.IsOpen,
			ConfrId: chatMute.ConfrId,
		}))
	} else {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.SET_ERROR))
	}
}

type WhiteStatus struct {
	ConfrId   string   `json:"confrId"`
	UserNames []string `json:"UserNames"`
	IsOpen    int      `json:"isOpen"`
}

// @Description 设置聊天室静音
// @Param IsMute 1 取消禁言 -1 添加禁言
// @HttpPost
// @auth
func (c *Conference) SetWhiteStatus(whiteStatus WhiteStatus) {
	userKey := c.GetClaim("key")
	if userKey == nil {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.USERID_GET_ERROR))
		logsd.Error("user key is nil")
		return
	}
	conf, err := service.GetConfrById(whiteStatus.ConfrId)
	if err != nil {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
		logsd.Error("get confr id:%s err:%s", whiteStatus.ConfrId, err)
		return
	}
	whiteCloses := make([]string, 0)
	if len(conf.WhiteClose) > 0 {
		err := json.Unmarshal(conf.WhiteClose, &whiteCloses)
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
			logsd.Error("paser white:%s", err)
			return
		}
	}
	whiteMap := make(map[string]int)
	for _, whiteClose := range whiteCloses {
		whiteMap[whiteClose] = 1
	}

	for _, whiteClose := range whiteStatus.UserNames {
		if whiteStatus.IsOpen == 1 {
			if _, has := whiteMap[whiteClose]; has {
				delete(whiteMap, whiteClose)
			}
		} else if whiteStatus.IsOpen == -1 {
			if _, has := whiteMap[whiteClose]; !has {
				whiteMap[whiteClose] = 1
			}
		}

	}
	whiteCloses = make([]string, 0)
	for whiteClose, _ := range whiteMap {
		whiteCloses = append(whiteCloses, whiteClose)
	}
	whiteClosesByte, err := json.Marshal(whiteCloses)
	if err != nil {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
		logsd.Error("paser in db white:%s", err)
		return
	}
	conf.SetWhiteClose(whiteClosesByte)
	err = sqlham.Update(&conf)
	if err != nil {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
		logsd.Error("err set conf:%s", err)
		return
	}
	c.ServeJSON(http.StatusOK, service.SuccessData(struct {
		IsOpen  int
		ConfrId string
	}{
		IsOpen:  whiteStatus.IsOpen,
		ConfrId: whiteStatus.ConfrId,
	}))
}

// @Description role
// @Param confrId 会议id
// @Param role 角色 7为管理员
// @Param userName 用户名称
// @httppost
// @Auth
func (c *Conference) Role(confrId string, role int, userName string) {
	tusers := make([]model.DefAuthUser, 0)
	findUser := sqlham.NewGoqu().
		Where(
			goqu.I(model.EmUserNameDefAuthUser).Eq(userName),
		)
	err := sqlham.List(findUser, &tusers)
	if err != nil {
		if err == sqlham.ErrNotFound {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		} else {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		}

	}
	user := tusers[0]
	c.ServeJSON(http.StatusOK, service.SuccessData(user.EmUserName))
	//confs := make([]model.Conference, 0)
	//findConf := sqlham.NewGoqu().
	//	Where(goqu.I(model.EasemobKeyConference).Eq(confrId))
	//err = sqlham.List(findConf, &confs)
	//if err != nil && err != sqlham.ErrNotFound {
	//	c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
	//	logsd.Error("err:%s", err)
	//	return
	//}
	//_, roleToken, err := service.Login(confrId, confs[0].EasemobPwd, adminName)
	//if err != nil {
	//	logsd.Error("login err:%s", err)
	//	c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
	//	return
	//}
	//roleStr := strconv.Itoa(role)
	//err = service.RoleConference(roleToken, confrId, roleStr, user.EmUserName)
	//if err != nil {
	//	c.ServeJSON(http.StatusOK, service.ErrorCode(service.SET_ERROR))
	//	logsd.Error("err:%s", err)
	//	return
	//}
	//logsd.Info("role:%s", roleStr)
	//c.ServeJSON(http.StatusOK, service.SuccessData(user.EmUserName))

}

// @Description 退出会议
// @Param confrId 会议id
// @Param username 用户名称
// @httppost
func (c *Conference) Leave(confrId string, userName string) {
	tusers := make([]model.DefAuthUser, 0)
	findUser := sqlham.NewGoqu().
		Where(
			goqu.I(model.ConferenceKeyDefAuthUser).Eq(confrId),
			goqu.I(model.EmUserNameDefAuthUser).Eq(userName),
		)
	err := sqlham.List(findUser, &tusers)
	if err != nil {
		if err == sqlham.ErrNotFound {

		} else {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		}

	}
	if len(tusers) > 0 {
		tuser := tusers[0]
		tuser.SetKey(tuser.Key)
		tuser.SetIsLogin(0)
		err = sqlham.Update(&tuser)
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		}
		err = service.DelUser(userName)
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
			logsd.Error("easemob call del user err:%s", err)
			return
		}
		logsd.Info("leave delete userName:%s", userName)
	} else {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
		logsd.Error("user not found confrId:%s username:%s", confrId, userName)
		return
	}

	conf, err := service.GetConfrById(confrId)
	if err != nil {
		c.ServeJSON(http.StatusOK, service.ErrorCode(service.EXCEPTION))
		logsd.Error("err get confr id:%s", err)
		return
	}
	tconf, err := service.GetConference(confrId)
	if err != nil || tconf == nil {
		conf.SetState(-1)
		err = sqlham.Update(&conf)
		if err != nil {
			c.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err get conf:%s", err)
			return
		}
	}
	c.ServeJSON(http.StatusOK, service.SuccessData(userName))
}
