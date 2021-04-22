package main

import (
	"testing"

	"github.com/autumnzw/hiweb/webcmd"
	"gitlab.bjictc.com/go/logsd"

	"gitlab.bjictc.com/go/sqlham"
)

func TestAutoCol(t *testing.T) {
	logsd.SetLogger(logsd.AdapterConsole, "")

	sqlham.InitMysqlDb("newictc:NewIctc2018@tcp(39.97.247.253:33306)/emlearn?parseTime=true&loc=Local&charset=utf8mb4,utf8", logsd.GetLoggerSd())
	tables, err := sqlham.GetTables()
	if err != nil {
		t.Errorf("err:%v", err)
		return
	}
	err = sqlham.AutoColumn(tables, "./model")
	if err != nil {
		t.Errorf("err:%v", err)
		return
	}
}

func TestAutoRoute(t *testing.T) {
	err := webcmd.CreateRoute("./controllers", "emlearn", "", "")
	if err != nil {
		t.Error(err)
	}

}
