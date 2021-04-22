package main

/**
	启动主程序
**/

import (
	_ "emlearn/controllers"
	"emlearn/service"
	"flag"
	"net/http"

	"github.com/autumnzw/hiweb"
	"gitlab.bjictc.com/go/logsd"
	"gitlab.bjictc.com/go/sqlham"
)

func main() {
	ip := flag.String("ip", "127.0.0.1", "ip")
	port := flag.String("port", "8111", "port")
	flag.Parse()
	if *port == "" {
		flag.PrintDefaults()
		return
	}
	logsd.SetLogger(logsd.AdapterConsole)
	logsd.SetLogger(logsd.AdapterMultiFile, `{"filename":"./logs/emlearn.log","separate":["error"]}`)
	sqlham.InitMysqlDb("newictc:NewIctc2018@tcp(39.97.247.253:33306)/emlearn?parseTime=true&loc=Local&charset=utf8mb4,utf8",
		logsd.GetLoggerSd())
	hiweb.WebConfig.SecretKey = "asdfsvasf"
	hiweb.WebConfig.Logger = logsd.GetLoggerSd()
	hiweb.WebConfig.SetParam("datapath", "./data")

	service.InitEaseMob("1108200509113038", "chatapp", "YXA6axGRAPHUSeyk9gN5mLVB8A", "YXA6Z_PjcIkBH2z3a7B7CBXl3y-hU78")
	hiweb.RouteFiles("/", "./dist")
	logsd.Info("start web %s:%s dir:%s", *ip, *port, "./dist")
	e := http.ListenAndServe(*ip+":"+*port, nil)
	if e != nil {
		logsd.Error(e)
	}
}
