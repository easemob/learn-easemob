package controllers

/**
	用户管理
**/

import (
	"emlearn/model"
	"emlearn/service"
	"emlearn/utils"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/autumnzw/hiweb"
	"github.com/doug-martin/goqu/v9"
	"gitlab.bjictc.com/go/logsd"
	"gitlab.bjictc.com/go/sqlham"
)

type User struct {
	hiweb.Controller
}

// @Description get nick name
// @Param confrKey 会议key
// @Param userName 用户key
// @Auth
func (u *User) GetNickName(confrKey, userName string) {
	curUserKey := u.GetClaim("key")
	if curUserKey == nil {
		u.ServeJSON(http.StatusOK, service.ErrorCode(service.USERID_GET_ERROR))
		logsd.Error("user key is nil")
		return
	}
	tusers := make([]model.DefAuthUser, 0)
	findUser := sqlham.NewGoqu().
		Where(
			goqu.I(model.ConferenceKeyDefAuthUser).Eq(confrKey),
			goqu.I(model.EmUserNameDefAuthUser).Eq(userName),
		)
	err := sqlham.List(findUser, &tusers)
	if err != nil {
		if err == sqlham.ErrNotFound {

		} else {
			u.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		}

	}
	if len(tusers) > 0 {
		u.ServeJSON(http.StatusOK, service.SuccessData(tusers[0].NickName))
	} else {
		u.ServeJSON(http.StatusOK, service.ErrorCode(service.INPARAM_ERR))
	}

}

// @Description get role
// @Param confrKey 会议key
// @Param userName 用户key
// @Auth
func (u *User) GetUserRole(confrKey, userName string) {
	curUserKey := u.GetClaim("key")
	if curUserKey == nil {
		u.ServeJSON(http.StatusOK, service.ErrorCode(service.USERID_GET_ERROR))
		logsd.Error("user key is nil")
		return
	}
	tusers := make([]model.DefAuthUser, 0)
	findUser := sqlham.NewGoqu().
		Where(
			goqu.I(model.ConferenceKeyDefAuthUser).Eq(confrKey),
			goqu.I(model.EmUserNameDefAuthUser).Eq(userName),
		)
	err := sqlham.List(findUser, &tusers)
	if err != nil {
		if err == sqlham.ErrNotFound {

		} else {
			u.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		}

	}
	if len(tusers) > 0 {
		u.ServeJSON(http.StatusOK, service.SuccessData(tusers[0].UserRole))
	} else {
		u.ServeJSON(http.StatusOK, service.ErrorCode(service.INPARAM_ERR))
	}

}

// @Description get user
// @Auth
func (u *User) GetCur() {
	userName := u.GetClaim("key")
	if userName == nil {
		u.ServeJSON(http.StatusOK, service.ErrorCode(service.USERID_GET_ERROR))
		logsd.Error("user key is nil")
		return
	}
	tusers := make([]model.DefAuthUser, 0)
	findUser := sqlham.NewGoqu().
		Where(
			goqu.I(model.EmUserNameDefAuthUser).Eq(userName),
		)
	err := sqlham.List(findUser, &tusers)
	if err != nil {
		if err == sqlham.ErrNotFound {

		} else {
			u.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		}

	}
	if len(tusers) > 0 {
		u.ServeJSON(http.StatusOK, service.SuccessData(tusers[0]))
	} else {
		u.ServeJSON(http.StatusOK, service.ErrorCode(service.INPARAM_ERR))
	}
}

// @Description get user
// @Param nickName 用户昵称
// @httppost
// @Auth
func (u *User) UpdateNickName(nickName string) {
	if nickName == "" {
		u.ServeJSON(http.StatusNotFound, "昵称不能为空")
		logsd.Error("nick name is blank")
		return
	}
	userKey := u.GetClaim("key")
	if userKey == nil {
		u.ServeJSON(http.StatusOK, service.ErrorCode(service.USERID_GET_ERROR))
		logsd.Error("user key is nil")
		return
	}

	user := model.DefAuthUser{}
	user.SetKey(int(userKey.(float64)))
	user.SetNickName(nickName)
	err := sqlham.Update(&user)
	if err != nil {
		if err == sqlham.ErrNotFound {
			u.ServeJSON(http.StatusNotFound, "资源没找到")
			logsd.Error("user not found:%s", userKey)
			return
		} else {
			u.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		}

	}
	u.ServeJSON(http.StatusOK, service.SuccessData(userKey))

}

// @Description 上传头像
// @httppost
// @Auth
// @upload file 上传文件
func (u *User) UploadAvator() {
	userKey := u.GetClaim("key")
	if userKey == nil {
		u.ServeJSON(http.StatusOK, service.ErrorCode(service.USERID_GET_ERROR))
		logsd.Error("user key is nil")
		return
	}
	file, _, err := u.Ctx.Request.FormFile("file")
	if err != nil {
		u.ServeJSON(http.StatusOK, service.ErrorCode(service.UPLOAD_ERR))
		logsd.Error("err:%s", err)
		return
	}
	dir, _ := hiweb.WebConfig.GetParam("data")
	dirPath := fmt.Sprintf("%s/avator", dir)
	if has, err := utils.PathExists(dirPath); !has || err != nil {
		err = os.MkdirAll(dirPath, os.ModePerm)
		if err != nil {
			u.ServeJSON(http.StatusOK, service.ErrorCode(service.UPLOAD_ERR))
			logsd.Error("err:%s", err)
			return
		}
	}
	filePath := fmt.Sprintf("%s/%d", dirPath, int(userKey.(float64)))
	defer file.Close()
	f, err := os.OpenFile(filePath, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0666)
	if err != nil {
		u.ServeJSON(http.StatusOK, service.ErrorCode(service.UPLOAD_ERR))
		logsd.Error("err:%s", err)
		return
	}
	defer f.Close()
	io.Copy(f, file)

	u.ServeJSON(http.StatusOK, service.SuccessData(userKey))

}

// @Description 获得头像
// @httppost
// @Auth
func (u *User) GetAvator() {
	userKey := u.GetClaim("key")
	if userKey == nil {
		u.ServeJSON(http.StatusOK, service.ErrorCode(service.USERID_GET_ERROR))
		logsd.Error("user key is nil")
		return
	}
	dir, _ := hiweb.WebConfig.GetParam("data")
	filePath := fmt.Sprintf("%s/avator/%d", dir, int(userKey.(float64)))

	if has, err := utils.PathExists(filePath); !has || err != nil {
		err = u.ServeJSON(http.StatusOK, "")
		if err != nil {
			u.ServeJSON(http.StatusOK, service.ErrorCode(service.UPLOAD_ERR))
			logsd.Error("err:%s", err)
			return
		}
	}
	content, err := ioutil.ReadFile(filePath)
	if err != nil {
		u.ServeJSON(http.StatusOK, service.ErrorCode(service.UPLOAD_ERR))
		logsd.Error("err:%s", err)
		return
	}
	u.ServeBody(http.StatusOK, content)

}
