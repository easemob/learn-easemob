package service

import (
	"encoding/json"
	"fmt"
	"strings"
)

func (e *EaseMob) CreateChatroom(name string, owner string) (string, error) {
	paramStr := fmt.Sprintf(
		`{`+
			`"name": "%s","description":"api"`+
			`,"maxusers":20,"owner":"%s","member":["%s"]}`, name, owner, owner)
	ret, err := e.post("chatrooms", paramStr)
	if err != nil {
		return "", err
	}
	response := struct {
		Data struct {
			ID string `json:"id,omitempty"`
		} `json:"data,omitempty"`
		Error            string    `json:"error,omitempty"`
		Exception        string `json:"exception,omitempty"`
		ErrorDescription string `json:"error_description,omitempty"`
	}{}
	err = json.Unmarshal(ret, &response)
	if err != nil {
		return "", err
	}
	if response.Error != "" {
		return "", fmt.Errorf("code:%d mesg:%s", response.Error, response.ErrorDescription)
	}
	return response.Data.ID, nil
}

func (e *EaseMob) GetChatroom(chatId string) (string, error) {
	ret, err := e.get("chatrooms", chatId)
	if err != nil {
		return "", err
	}
	response := struct {
		Data []struct {
			ID      string `json:"id,omitempty"`
			Created int    `json:"created,omitempty"`
			Name    string `json:"name,omitempty"`
		} `json:"data,omitempty"`
		Error        string `json:"error,omitempty"`
		Exception    string `json:"exception,omitempty"`
		ErrorMessage string `json:"error_description,omitempty"`
	}{}
	fmt.Println(string(ret))
	err = json.Unmarshal(ret, &response)
	if err != nil {
		return "", err
	}
	if response.Error == "service_resource_not_found" {
		return "", nil
	}
	if response.Error != "" {
		return "", fmt.Errorf("code:%s mesg:%s", response.Error, response.ErrorMessage)
	}
	if len(response.Data) > 0 {
		return response.Data[0].ID, nil
	} else {
		return "", nil
	}

}

func (e *EaseMob) GetChatroomMute(chatId string) ([]string, error) {
	ret, err := e.get("chatrooms", chatId+"/mute")
	if err != nil {
		return []string{}, err
	}
	response := struct {
		Data []struct {
			Expire string `json:"expire,omitempty"`
			User   string `json:"user,omitempty"`
		} `json:"data,omitempty"`
		Error        string `json:"error,omitempty"`
		Exception    string `json:"exception,omitempty"`
		ErrorMessage string `json:"error_description,omitempty"`
	}{}
	fmt.Println(string(ret))
	err = json.Unmarshal(ret, &response)
	if err != nil {
		return []string{}, err
	}
	if response.Error == "service_resource_not_found" {
		return []string{}, nil
	}
	if response.Error != "" {
		return []string{}, fmt.Errorf("code:%s mesg:%s", response.Error, response.ErrorMessage)
	}
	if len(response.Data) > 0 {
		retUsers := make([]string, 0)
		for _, data := range response.Data {
			retUsers = append(retUsers, data.User)
		}
		return retUsers, nil
	} else {
		return []string{}, nil
	}

}

func (e *EaseMob) AddChatroomMute(chatId string, usersId []string) error {
	var err error
	var ret []byte
	if len(usersId) == 0 {
		ret, err = e.post("chatrooms/"+chatId+"/ban", "")
		if err != nil {
			return err
		}
		response := struct {
			Data struct {
				Mute bool `json:"mute,omitempty"`
			} `json:"data,omitempty"`
			Error        string `json:"error,omitempty"`
			Exception    string `json:"exception,omitempty"`
			ErrorMessage string `json:"error_description,omitempty"`
		}{}
		fmt.Println(string(ret))
		err = json.Unmarshal(ret, &response)
		if err != nil {
			return err
		}
		if response.Error == "service_resource_not_found" {
			return nil
		}
		if response.Error != "" {
			return fmt.Errorf("code:%s mesg:%s", response.Error, response.ErrorMessage)
		}
		if response.Data.Mute {
			return nil
		} else {
			return fmt.Errorf("user mute set err:" + usersId[0])
		}
	} else {
		paramJson := struct {
			Usernames    []string `json:"usernames"`
			Muteduration int      `json:"mute_duration"`
		}{
			Usernames:    usersId,
			Muteduration: -1,
		}
		paramBytes, err := json.Marshal(paramJson)
		if err != nil {
			return err
		}
		ret, err = e.post("chatrooms/"+chatId+"/mute", string(paramBytes))
		if err != nil {
			return err
		}
		response := struct {
			Data []struct {
				Result bool   `json:"result,omitempty"`
				Expire string `json:"expire,omitempty"`
				User   string `json:"user,omitempty"`
			} `json:"data,omitempty"`
			Error        string `json:"error,omitempty"`
			Exception    string `json:"exception,omitempty"`
			ErrorMessage string `json:"error_description,omitempty"`
		}{}
		fmt.Println(string(ret))
		err = json.Unmarshal(ret, &response)
		if err != nil {
			return err
		}
		if response.Error == "service_resource_not_found" {
			return nil
		}
		if response.Error != "" {
			return fmt.Errorf("code:%s mesg:%s", response.Error, response.ErrorMessage)
		}
		if len(response.Data) > 0 {
			if response.Data[0].Result {
				return nil
			} else {
				return fmt.Errorf("user mute set err:" + usersId[0])
			}
		} else {
			return nil
		}
	}

}

func (e *EaseMob) DelChatroomMute(chatId string, usersId []string) error {
	var err error
	var ret []byte
	if len(usersId) == 0 {
		ret, err = e.delete("chatrooms/"+chatId+"/ban", "")
		if err != nil {
			return err
		}
		response := struct {
			Data struct {
				Mute bool `json:"mute,omitempty"`
			} `json:"data,omitempty"`
			Error        string `json:"error,omitempty"`
			Exception    string `json:"exception,omitempty"`
			ErrorMessage string `json:"error_description,omitempty"`
		}{}
		fmt.Println(string(ret))
		err = json.Unmarshal(ret, &response)
		if err != nil {
			return err
		}
		if response.Error == "service_resource_not_found" {
			return nil
		}
		if response.Error != "" {
			return fmt.Errorf("code:%s mesg:%s", response.Error, response.ErrorMessage)
		}
		if response.Data.Mute {
			return nil
		} else {
			return fmt.Errorf("user mute set err:" + usersId[0])
		}
	} else {
		paramStr := strings.Join(usersId, ",")
		ret, err = e.delete("chatrooms/"+chatId+"/mute", paramStr)
		if err != nil {
			return err
		}
		response := struct {
			Data []struct {
				Result bool   `json:"result,omitempty"`
				Expire string `json:"expire,omitempty"`
				User   string `json:"user,omitempty"`
			} `json:"data,omitempty"`
			Error        string `json:"error,omitempty"`
			Exception    string `json:"exception,omitempty"`
			ErrorMessage string `json:"error_description,omitempty"`
		}{}
		fmt.Println(string(ret))
		err = json.Unmarshal(ret, &response)
		if err != nil {
			return err
		}
		if response.Error == "service_resource_not_found" {
			return nil
		}
		if response.Error != "" {
			return fmt.Errorf("code:%s mesg:%s", response.Error, response.ErrorMessage)
		}
		if len(response.Data) > 0 {
			if response.Data[0].Result {
				return nil
			} else {
				return fmt.Errorf("user mute set err:" + usersId[0])
			}
		} else {
			return nil
		}
	}

}
