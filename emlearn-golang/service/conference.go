package service

import (
	"emlearn/model"
	"emlearn/utils"
	"fmt"

	"gitlab.bjictc.com/go/logsd"

	"github.com/doug-martin/goqu/v9"

	"gitlab.bjictc.com/go/sqlham"
)

func GetConfrById(confrId string) (model.Conference, error) {
	confs := make([]model.Conference, 0)
	findConf := sqlham.NewGoqu().
		Where(goqu.I(model.EasemobKeyConference).Eq(confrId))
	err := sqlham.List(findConf, &confs)
	if err != nil && err != sqlham.ErrNotFound {
		return model.Conference{}, err
	}
	if len(confs) == 0 {
		return model.Conference{}, fmt.Errorf("key:%s not found", confrId)
	}
	return confs[0], nil
}

func EntryStudent(username string, confrId string) (bool, string, string, error) {
	return EntryUser("student", username, confrId)
}
func EntryTeacher(username string, confrId string) (bool, string, string, error) {
	return EntryUser("teacher", username, confrId)
}

func EntryUser(role string, username string, confrId string) (bool, string, string, error) {
	if confrId != "" && role == "teacher" {
		tusers := make([]model.DefAuthUser, 0)
		findUser := sqlham.NewGoqu().Where(
			goqu.I(model.ConferenceKeyDefAuthUser).Eq(confrId),
			goqu.I(model.UserRoleDefAuthUser).Eq(role),
		)
		err := sqlham.List(findUser, &tusers)
		if err != nil && err != sqlham.ErrNotFound {
			return false, "", "", err
		}
		_, err = NickName(tusers[0].EmUserName, username)
		if err != nil {
			return false, "", "", err
		}
		ouser := model.DefAuthUser{}
		ouser.SetKey(tusers[0].Key)
		ouser.SetNickName(username)
		ouser.SetIsLogin(1)
		err = sqlham.Update(&ouser)
		if err != nil {
			return false, "", "", err
		}
		if len(tusers) > 0 {
			return true, tusers[0].EmUserKey, tusers[0].EmUserName, nil
		}
	}
	nUserName := utils.UUID32()
	if role == "teacher" {
		nUserName = nUserName + ".tea"
	}
	users, err := GetUser(nUserName)
	if err != nil {
		return false, "", "", err
	}
	if len(users) > 0 {
		err = DelUser(nUserName)
		if err != nil {
			return false, "", "", err
		}
		logsd.Info("entry delete userName:%s", nUserName)
	}
	ruser, err := RegisterUser(nUserName, "1", username)
	if err != nil {
		return false, "", "", err
	}

	return false, ruser.Uuid, nUserName, nil
}
