package model

import (
	"gitlab.bjictc.com/go/sqlham"
)

type Conference struct {
	Key int `db:"key" json:"key" desc:""`

	EasemobKey string `db:"easemob_key" json:"easemobKey" desc:""`

	EasemobPwd string `db:"easemob_pwd" json:"easemobPwd" desc:""`

	EasemobOwnerKey string `db:"easemob_owner_key" json:"easemobOwnerKey" desc:""`

	ConferenceType string `db:"conference_type" json:"conferenceType" desc:""`

	Name string `db:"name" json:"name" desc:""`

	State int `db:"state" json:"state" desc:"0:为正常 -1:停止"`

	ChatRoomId string `db:"chat_room_id" json:"chatRoomId" desc:""`

	UserName string `db:"user_name" json:"userName" desc:""`

	Password string `db:"password" json:"password" desc:""`

	UserKey string `db:"user_key" json:"userKey" desc:"创建用户key"`

	WhiteClose []byte `db:"white_close" json:"whiteClose" desc:""`

	StartTime sqlham.CTime `db:"start_time" json:"startTime" desc:""`

	EndTime sqlham.CTime `db:"end_time" json:"endTime" desc:""`

	CreateTime sqlham.CTime `db:"create_time" json:"createTime" desc:""`

	UpdateTime sqlham.CTime `db:"update_time" json:"updateTime" desc:""`

	changedColMap map[string]interface{} `json:"-" db:"-"`
}

func (o *Conference) SetKey(v int) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["key"] = v

	o.Key = v
}

func (o *Conference) SetEasemobKey(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["easemob_key"] = v

	o.EasemobKey = v
}

func (o *Conference) SetEasemobPwd(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["easemob_pwd"] = v

	o.EasemobPwd = v
}

func (o *Conference) SetEasemobOwnerKey(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["easemob_owner_key"] = v

	o.EasemobOwnerKey = v
}

func (o *Conference) SetConferenceType(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["conference_type"] = v

	o.ConferenceType = v
}

func (o *Conference) SetName(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["name"] = v

	o.Name = v
}

func (o *Conference) SetState(v int) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["state"] = v

	o.State = v
}

func (o *Conference) SetChatRoomId(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["chat_room_id"] = v

	o.ChatRoomId = v
}

func (o *Conference) SetUserName(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["user_name"] = v

	o.UserName = v
}

func (o *Conference) SetPassword(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["password"] = v

	o.Password = v
}

func (o *Conference) SetUserKey(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["user_key"] = v

	o.UserKey = v
}

func (o *Conference) SetWhiteClose(v []byte) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["white_close"] = v

	o.WhiteClose = v
}

func (o *Conference) SetStartTime(v sqlham.CTime) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["start_time"] = v

	o.StartTime = v
}

func (o *Conference) SetEndTime(v sqlham.CTime) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["end_time"] = v

	o.EndTime = v
}

func (o *Conference) SetCreateTime(v sqlham.CTime) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["create_time"] = v

	o.CreateTime = v
}

func (o *Conference) SetUpdateTime(v sqlham.CTime) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["update_time"] = v

	o.UpdateTime = v
}

func (o *Conference) GetChangeMap() map[string]interface{} {
	return o.changedColMap
}
func (o *Conference) GetKeyType() string {
	return "int"
}

//set方法
func (o *Conference) SetAllChange() {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["key"] = o.Key

	o.changedColMap["easemob_key"] = o.EasemobKey

	o.changedColMap["easemob_pwd"] = o.EasemobPwd

	o.changedColMap["easemob_owner_key"] = o.EasemobOwnerKey

	o.changedColMap["conference_type"] = o.ConferenceType

	o.changedColMap["name"] = o.Name

	o.changedColMap["state"] = o.State

	o.changedColMap["chat_room_id"] = o.ChatRoomId

	o.changedColMap["user_name"] = o.UserName

	o.changedColMap["password"] = o.Password

	o.changedColMap["user_key"] = o.UserKey

	o.changedColMap["white_close"] = o.WhiteClose

	o.changedColMap["start_time"] = o.StartTime

	o.changedColMap["end_time"] = o.EndTime

	o.changedColMap["create_time"] = o.CreateTime

	o.changedColMap["update_time"] = o.UpdateTime

}

func (o *Conference) GetKey() interface{} {
	return o.Key
}
