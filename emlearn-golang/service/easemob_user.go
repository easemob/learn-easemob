package service

import (
	"encoding/json"
	"fmt"
)

func (e *EaseMob) RegisterUser(username string, password string, nickname string) (Entities, error) {
	paramStr := fmt.Sprintf(`[{"username": "%s", "password": "%s", "nickname":"%s"}]`, username, password, nickname)
	ret, err := e.post("users", paramStr)
	if err != nil {
		return Entities{}, err
	}
	response := struct {
		Action           string     `json:"action"`
		Error            string     `json:"error"`
		Exception        string     `json:"exception"`
		ErrorDescription string     `json:"error_description"`
		Users            []Entities `json:"entities,omitempty"`
	}{}
	err = json.Unmarshal(ret, &response)
	if err != nil {
		return Entities{}, err
	}
	if len(response.Error) > 0 {
		return Entities{}, fmt.Errorf("code:%s mesg:%s", response.Error, response.ErrorDescription)
	}
	return response.Users[0], nil
}

type Entities struct {
	Uuid      string `json:"uuid,omitempty"`
	UserName  string `json:"username,omitempty"`
	NickName  string `json:"nickname,omitempty"`
	Activated bool   `json:"activated,omitempty"`
}

func (e *EaseMob) GetUser(username string) ([]Entities, error) {
	ret, err := e.get("users", username)
	if err != nil {
		return []Entities{}, err
	}
	response := struct {
		Action           string     `json:"action"`
		Error            string     `json:"error,omitempty"`
		Exception        string     `json:"exception,omitempty"`
		ErrorDescription string     `json:"error_description,omitempty"`
		Users            []Entities `json:"entities,omitempty"`
	}{}
	err = json.Unmarshal(ret, &response)
	if err != nil {
		return response.Users, err
	}
	if len(response.Error) > 0 {
		if response.Error == "service_resource_not_found" {
			return response.Users, nil
		} else {
			return response.Users, fmt.Errorf("code:%s mesg:%s", response.Error, response.ErrorDescription)
		}
	}
	return response.Users, nil
}

func (e *EaseMob) DelUser(username string) error {
	ret, err := e.delete("users/"+username, "")
	if err != nil {
		return err
	}
	response := struct {
		Action           string `json:"action"`
		Error            string `json:"error"`
		Exception        string `json:"exception"`
		ErrorDescription string `json:"error_description"`
	}{}
	fmt.Println(string(ret))
	err = json.Unmarshal(ret, &response)
	if err != nil {
		return err
	}
	if len(response.Error) > 0 {
		return fmt.Errorf("code:%s mesg:%s", response.Error, response.ErrorDescription)
	}
	return nil
}

func (e *EaseMob) Login(confId string, password string, userName string) (int, string, error) {
	route := fmt.Sprintf("easemob/rtc/req/ticket?CONFRID=%s", confId)
	paramStr := fmt.Sprintf(
		`{`+
			`"confrId": "%s", "password": "%s","token": "%s",`+
			`"uid":"%s#%s_%s"}`, confId, password, e.GetAccessToken(), e.OrgName, e.AppName, userName)
	fmt.Println(string(paramStr))
	ret, err := e.postInner(route, paramStr)
	if err != nil {
		return 0, "", err
	}
	fmt.Println(string(ret))
	response := struct {
		RoleToken        string `json:"roleToken"`
		Role             int    `json:"role"`
		Error            int    `json:"error,omitempty"`
		Exception        string `json:"exception,omitempty"`
		ErrorDescription string `json:"error_description,omitempty"`
	}{}
	err = json.Unmarshal(ret, &response)
	if err != nil {
		return 0, "", err
	}
	if response.Error < 0 {
		return 0, "", fmt.Errorf("code:%d mesg:%s", response.Error, response.ErrorDescription)
	}

	return response.Role, response.RoleToken, nil
}

func (e *EaseMob) NickName(userName string, changeUserName string) (Entities, error) {
	paramStr := fmt.Sprintf(`{"nickName": "%s"}`, changeUserName)
	fmt.Println(string(paramStr))
	ret, err := e.put("users/"+userName, paramStr)
	if err != nil {
		return Entities{}, err
	}
	fmt.Println(string(ret))
	response := struct {
		Action           string     `json:"action"`
		Error            string     `json:"error,omitempty"`
		Exception        string     `json:"exception,omitempty"`
		ErrorDescription string     `json:"error_description,omitempty"`
		Users            []Entities `json:"entities,omitempty"`
	}{}
	err = json.Unmarshal(ret, &response)
	if err != nil {
		return Entities{}, err
	}
	if len(response.Error) > 0 {
		return Entities{}, fmt.Errorf("code:%s mesg:%s", response.Error, response.ErrorDescription)
	}
	return response.Users[0], nil
}
