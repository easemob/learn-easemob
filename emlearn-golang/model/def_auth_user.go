package model

import (
	"gitlab.bjictc.com/go/sqlham"
)

type DefAuthUser struct {
	Key int `db:"key" json:"key" desc:""`

	EmUserKey string `db:"em_user_key" json:"emUserKey" desc:""`

	EmUserName string `db:"em_user_name" json:"emUserName" desc:""`

	UserRole string `db:"user_role" json:"userRole" desc:""`

	ConferenceKey string `db:"conference_key" json:"conferenceKey" desc:""`

	UserName string `db:"user_name" json:"userName" desc:""`

	UserPwd string `db:"user_pwd" json:"userPwd" desc:""`

	NickName string `db:"nick_name" json:"nickName" desc:""`

	IsLogin int `db:"is_login" json:"isLogin" desc:""`

	CreateTime sqlham.CTime `db:"create_time" json:"createTime" desc:""`

	UpdateTime sqlham.CTime `db:"update_time" json:"updateTime" desc:""`

	changedColMap map[string]interface{} `json:"-" db:"-"`
}

func (o *DefAuthUser) SetKey(v int) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["key"] = v

	o.Key = v
}

func (o *DefAuthUser) SetEmUserKey(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["em_user_key"] = v

	o.EmUserKey = v
}

func (o *DefAuthUser) SetEmUserName(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["em_user_name"] = v

	o.EmUserName = v
}

func (o *DefAuthUser) SetUserRole(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["user_role"] = v

	o.UserRole = v
}

func (o *DefAuthUser) SetConferenceKey(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["conference_key"] = v

	o.ConferenceKey = v
}

func (o *DefAuthUser) SetUserName(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["user_name"] = v

	o.UserName = v
}

func (o *DefAuthUser) SetUserPwd(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["user_pwd"] = v

	o.UserPwd = v
}

func (o *DefAuthUser) SetNickName(v string) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["nick_name"] = v

	o.NickName = v
}

func (o *DefAuthUser) SetIsLogin(v int) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["is_login"] = v

	o.IsLogin = v
}

func (o *DefAuthUser) SetCreateTime(v sqlham.CTime) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["create_time"] = v

	o.CreateTime = v
}

func (o *DefAuthUser) SetUpdateTime(v sqlham.CTime) {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["update_time"] = v

	o.UpdateTime = v
}

func (o *DefAuthUser) GetChangeMap() map[string]interface{} {
	return o.changedColMap
}
func (o *DefAuthUser) GetKeyType() string {
	return "int"
}

//set方法
func (o *DefAuthUser) SetAllChange() {
	if o.changedColMap == nil {
		o.changedColMap = make(map[string]interface{})
	}

	o.changedColMap["key"] = o.Key

	o.changedColMap["em_user_key"] = o.EmUserKey

	o.changedColMap["em_user_name"] = o.EmUserName

	o.changedColMap["user_role"] = o.UserRole

	o.changedColMap["conference_key"] = o.ConferenceKey

	o.changedColMap["user_name"] = o.UserName

	o.changedColMap["user_pwd"] = o.UserPwd

	o.changedColMap["nick_name"] = o.NickName

	o.changedColMap["is_login"] = o.IsLogin

	o.changedColMap["create_time"] = o.CreateTime

	o.changedColMap["update_time"] = o.UpdateTime

}

func (o *DefAuthUser) GetKey() interface{} {
	return o.Key
}
