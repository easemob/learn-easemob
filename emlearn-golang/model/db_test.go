package model

import (
	"testing"

	"github.com/doug-martin/goqu/v9"
	"gitlab.bjictc.com/go/logsd"
	"gitlab.bjictc.com/go/sqlham"
)

func TestDelete(t *testing.T) {
	sqlham.InitMysqlDb("newictc:NewIctc2018@tcp(39.97.247.253:33306)/emlearn?parseTime=true&loc=Local&charset=utf8mb4,utf8",
		logsd.GetLoggerSd())
	findUser := sqlham.NewGoqu().
		Where(
			goqu.I(ConferenceKeyDefAuthUser).Eq(""),
			goqu.I(EmUserNameDefAuthUser).Eq(""),
		)
	findUser = findUser.From("def_auth_user")
	err := sqlham.Delete(findUser)
	if err != nil {
		logsd.Error("err:%s", err)
		return
	}
}
