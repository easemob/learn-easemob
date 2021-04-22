package controllers

/**
	登录管理
**/
import (
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	"emlearn/model"
	"emlearn/service"

	"github.com/autumnzw/hiweb"
	"github.com/doug-martin/goqu/v9"
	"gitlab.bjictc.com/go/logsd"
	"gitlab.bjictc.com/go/sqlham"
)

// Token controller
type Token struct {
	hiweb.Controller
}

// UserCredentials input
type UserCredentials struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

//@httpPost
func (t *Token) GenToken(userIn UserCredentials) {
	userJson, _ := json.Marshal(userIn)
	user := model.DefAuthUser{}
	find := sqlham.NewGoqu()
	find = find.Select(model.KeyDefAuthUser, model.UserNameDefAuthUser).Where(
		goqu.And(
			goqu.I(model.UserNameDefAuthUser).Eq(userIn.Username),
			goqu.I(model.UserPwdDefAuthUser).Eq(userIn.Password),
		),
	)
	err := sqlham.Get(find, &user)
	if err != nil {
		if err == sqlham.ErrNotFound {
			t.ServeJSON(http.StatusNotFound, "用户名密码错误")
			logsd.Error("user not found:%s", userJson)
			return
		} else {
			t.ServeJSON(http.StatusOK, service.ErrorCode(service.DATABASE_EXECUTE_ERROR))
			logsd.Error("err:%s", err)
			return
		}

	}
	expiresAt := time.Now().Add(time.Hour * time.Duration(1)).Unix()
	authTime := time.Now().Unix()
	tokenParam := map[string]interface{}{
		"key":  user.Key,
		"name": user.UserName,
		"exp":  expiresAt,
		"iat":  authTime,
	}
	tokenString, err := hiweb.JwtToken(tokenParam)
	if err != nil {
		t.Forbidden()
		return
	}
	logsd.Info("login success:%s", userJson)
	userKey := strconv.Itoa(user.Key)
	t.ServeJSON(http.StatusOK, service.SuccessData(struct {
		Token     string `json:"token"`
		TokenType string `json:"tokenType"`
		Profile   struct {
			Key       string `json:"key"`
			Name      string `json:"name"`
			AuthTime  int64  `json:"authTime"`
			ExpiresAt int64  `json:"expiresAt"`
		} `json:"profile"`
	}{
		TokenType: "Bearer",
		Token:     tokenString,
		Profile: struct {
			Key       string `json:"key"`
			Name      string `json:"name"`
			AuthTime  int64  `json:"authTime"`
			ExpiresAt int64  `json:"expiresAt"`
		}{
			Key:       userKey,
			Name:      user.UserName,
			ExpiresAt: expiresAt,
			AuthTime:  authTime,
		},
	}))
}
