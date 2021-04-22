package service

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

type EaseMob struct {
	OrgName      string
	AppName      string
	ClientID     string
	ClientSecret string
	accessToken  string
}

func NewEaseMob(orgName string, appName string, clientId, clientSecret string) *EaseMob {
	return &EaseMob{
		OrgName:      orgName,
		AppName:      appName,
		ClientID:     clientId,
		ClientSecret: clientSecret,
	}
}

func (e *EaseMob) GetAccessToken() string {
	return e.accessToken
}

func (e *EaseMob) postInner(route, paramStr string) ([]byte, error) {
	urlPath := fmt.Sprintf("https://a1.easemob.com/%s", route)
	req, err := http.NewRequest("POST", urlPath, strings.NewReader(string(paramStr)))
	if err != nil {
		return []byte{}, err
	}
	req.Header.Add("Content-Type", "application/json")
	httpResp, err := http.DefaultClient.Do(req)
	if err != nil {
		return []byte{}, err
	}
	defer httpResp.Body.Close()
	if err != nil {
		return []byte{}, err
	}
	return ioutil.ReadAll(httpResp.Body)
}

func (e *EaseMob) post(route, paramStr string) ([]byte, error) {
	urlPath := fmt.Sprintf("https://a1.easemob.com/%s/%s/%s", e.OrgName, e.AppName, route)
	req, err := http.NewRequest("POST", urlPath, strings.NewReader(string(paramStr)))
	if err != nil {
		return []byte{}, err
	}
	req.Header.Add("Content-Type", "application/json")
	if e.accessToken != "" {
		req.Header.Add("Authorization", fmt.Sprintf("Bearer %s", e.accessToken))
	}
	httpResp, err := http.DefaultClient.Do(req)
	if err != nil {
		return []byte{}, err
	}
	defer httpResp.Body.Close()
	if err != nil {
		return []byte{}, err
	}
	return ioutil.ReadAll(httpResp.Body)
}

func (e *EaseMob) put(route, paramStr string) ([]byte, error) {
	urlPath := fmt.Sprintf("https://a1.easemob.com/%s/%s/%s", e.OrgName, e.AppName, route)
	req, err := http.NewRequest("PUT", urlPath, strings.NewReader(string(paramStr)))
	if err != nil {
		return []byte{}, err
	}
	req.Header.Add("Content-Type", "application/json")
	if e.accessToken != "" {
		req.Header.Add("Authorization", fmt.Sprintf("Bearer %s", e.accessToken))
	}
	httpResp, err := http.DefaultClient.Do(req)
	if err != nil {
		return []byte{}, err
	}
	defer httpResp.Body.Close()
	if err != nil {
		return []byte{}, err
	}
	return ioutil.ReadAll(httpResp.Body)
}

func (e *EaseMob) delete(route, paramStr string) ([]byte, error) {
	urlPath := fmt.Sprintf("https://a1.easemob.com/%s/%s/%s", e.OrgName, e.AppName, route)
	req, err := http.NewRequest("DELETE", urlPath, strings.NewReader(string(paramStr)))
	if err != nil {
		return []byte{}, err
	}
	req.Header.Add("Content-Type", "application/json")
	if e.accessToken != "" {
		req.Header.Add("Authorization", fmt.Sprintf("Bearer %s", e.accessToken))
	}
	httpResp, err := http.DefaultClient.Do(req)
	if err != nil {
		return []byte{}, err
	}
	defer httpResp.Body.Close()
	if err != nil {
		return []byte{}, err
	}
	return ioutil.ReadAll(httpResp.Body)
}

func (e *EaseMob) get(route, paramStr string) ([]byte, error) {
	urlPath := fmt.Sprintf("https://a1.easemob.com/%s/%s/%s/%s", e.OrgName, e.AppName, route, paramStr)
	req, err := http.NewRequest("GET", urlPath, nil)
	if err != nil {
		return []byte{}, err
	}
	req.Header.Add("Content-Type", "application/json")
	if e.accessToken != "" {
		req.Header.Add("Authorization", fmt.Sprintf("Bearer %s", e.accessToken))
	}
	httpResp, err := http.DefaultClient.Do(req)
	if err != nil {
		return []byte{}, err
	}
	defer httpResp.Body.Close()
	if err != nil {
		return []byte{}, err
	}
	return ioutil.ReadAll(httpResp.Body)
}

func (e *EaseMob) Token() (string, error) {
	params := struct {
		GrantType    string `json:"grant_type"`
		ClientID     string `json:"client_id"`
		ClientSecret string `json:"client_secret"`
	}{
		GrantType:    "client_credentials",
		ClientID:     e.ClientID,
		ClientSecret: e.ClientSecret,
	}
	paramStr, err := json.Marshal(params)
	if err != nil {
		return "", err
	}
	ret, err := e.post("token", string(paramStr))
	if err != nil {
		return "", err
	}
	response := struct {
		AccessToken      string `json:"access_token"`
		ExpiresIn        int    `json:"expires_in"`
		Error            string `json:"error"`
		ErrorDescription string `json:"error_description"`
	}{}
	err = json.Unmarshal(ret, &response)
	if err != nil {
		return "", err
	}
	if len(response.Error) == 0 {
		e.accessToken = response.AccessToken
		fmt.Println(e.accessToken)
		return e.accessToken, nil
	} else {
		return "", fmt.Errorf(response.ErrorDescription)
	}
}

var easeMob *EaseMob

func InitEaseMob(orgName string, appName string, clientId, clientSecret string) {
	easeMob = &EaseMob{
		OrgName:      orgName,
		AppName:      appName,
		ClientID:     clientId,
		ClientSecret: clientSecret,
	}
}
func Token() (string, error) {
	return easeMob.Token()
}

func RegisterUser(username, password, nickname string) (Entities, error) {
	return easeMob.RegisterUser(username, password, nickname)
}

func GetUser(username string) ([]Entities, error) {
	return easeMob.GetUser(username)
}
func NickName(username string, changeUserName string) (Entities, error) {
	return easeMob.NickName(username, changeUserName)
}
func DelUser(username string) error {
	return easeMob.DelUser(username)
}
func CreateConferences(creator string, password string) (*Conference, error) {
	return easeMob.CreateConferences(creator, password)
}

func CreateChatroom(name string, owner string) (string, error) {
	return easeMob.CreateChatroom(name, owner)
}
func GetChatroom(chatId string) (string, error) {
	return easeMob.GetChatroom(chatId)
}
func GetChatroomMute(chatId string) ([]string, error) {
	return easeMob.GetChatroomMute(chatId)
}

func AddChatroomMute(chatId string, usersId []string) error {
	return easeMob.AddChatroomMute(chatId, usersId)
}
func DelChatroomMute(chatId string, usersId []string) error {
	return easeMob.DelChatroomMute(chatId, usersId)
}

func GetConference(confId string) (*Conference, error) {
	return easeMob.GetConference(confId)
}

func RoleConference(roleToken, confId string, role string, user string) error {
	return easeMob.RoleConference(roleToken, confId, role, user)
}
func Login(confId string, password string, userName string) (int, string, error) {
	return easeMob.Login(confId, password, userName)
}
