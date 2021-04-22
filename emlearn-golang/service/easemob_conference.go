package service

import (
	"encoding/json"
	"fmt"

	"gitlab.bjictc.com/go/logsd"
)

type Conference struct {
	Id       string
	Type     int
	Password string
	Mems     []Member
}

func (e *EaseMob) CreateConferences(creator string, password string) (*Conference, error) {
	paramStr := fmt.Sprintf(
		`{`+
			`"confrType": 10, "password": "%s","confrDelayMillis": 1200000,`+
			`"memDefaultRole":3,"allowAudienceTalk": false,"confrId": "",`+
			`"creator":"%s","rec":false,"recMerge":false,"supportWechatMiniProgram": true,`+
			`"useVCodes": ["H264","VP8"]}`, password, creator)
	ret, err := e.post("conferences", paramStr)
	if err != nil {
		return nil, err
	}
	response := struct {
		Id               string `json:"id"`
		Type             int    `json:"type"`
		Password         string `json:"password"`
		Error            int    `json:"error"`
		Exception        string `json:"exception"`
		ErrorDescription string `json:"error_description"`
	}{}
	err = json.Unmarshal(ret, &response)
	if err != nil {
		return nil, err
	}
	if response.Error != 0 {
		return nil, fmt.Errorf("code:%d mesg:%s", response.Error, response.ErrorDescription)
	}
	return &Conference{Id: response.Id, Type: response.Type, Password: response.Password}, nil
}

type Member struct {
	MemberId   string `json:"memberId"`
	MemberName string `json:"memName"`
	Role       int    `json:"role"`
}

func (e *EaseMob) GetConference(confId string) (*Conference, error) {
	ret, err := e.get("conferences", confId)
	if err != nil {
		return nil, err
	}
	response := struct {
		Id           string   `json:"id,omitempty"`
		Type         int      `json:"type,omitempty"`
		Password     string   `json:"password,omitempty"`
		Members      []Member `json:"mems,omitempty"`
		Error        int      `json:"error"`
		Exception    string   `json:"exception,omitempty"`
		ErrorMessage string   `json:"errorMessage"`
	}{}
	fmt.Println(string(ret))
	err = json.Unmarshal(ret, &response)
	if err != nil {
		return nil, err
	}
	if response.Error != 0 {
		return nil, fmt.Errorf("code:%d mesg:%s", response.Error, response.ErrorMessage)
	}
	return &Conference{Id: response.Id, Type: response.Type, Password: response.Password, Mems: response.Members}, nil
}

func (e *EaseMob) RoleConference(roleToken, confId string, role string, user string) error {
	route := fmt.Sprintf("easemob/rtc/chanage/roles?CONFRID=%s", confId)
	paramStr := fmt.Sprintf(
		`{`+
			`"confrId": "%s", "role": "%s","roleToken": "%s",`+
			`"uids":["%s#%s_%s"]}`, confId, role, roleToken, e.OrgName, e.AppName, user)
	logsd.Info("role:%s", paramStr)
	ret, err := e.postInner(route, paramStr)
	if err != nil {
		return err
	}
	response := struct {
		Error        int    `json:"error"`
		Exception    string `json:"exception,omitempty"`
		ErrorMessage string `json:"errorMessage,omitempty"`
	}{}
	logsd.Info("role ret:%s", ret)
	err = json.Unmarshal(ret, &response)
	if err != nil {
		return err
	}
	if response.Error != 0 {
		return fmt.Errorf("code:%d mesg:%s", response.Error, response.ErrorMessage)
	}
	return nil
}
