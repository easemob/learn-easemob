// GENERATED BY THE COMMAND ABOVE; DO NOT EDIT
// This file was generated by swaggo/swag

package controllers

import (
	"bytes"
	"encoding/json"
	"github.com/autumnzw/hiweb"
	"net/http"

	"github.com/alecthomas/template"
)

func init() {
	http.HandleFunc("/swag/", hiweb.Handler(
		hiweb.URL("./swagger.json", "emlearn"), //The url pointing to API definition"
	))
}

var doc = `{
    "openapi": "3.0.1",
    "info": {
        "title": "emlearn",
        "version": "v1"
    },
    "paths": {
        "/Conference/Entry": {
            "post": {
                "tags": [
                    "Conference"
                ],
                "summary": "entry",
                "parameters": [
                    {
                        "name": "name",
                        "in": "query",
                        "description": "会议名称",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    },
                    {
                        "name": "username",
                        "in": "query",
                        "description": "用户名称",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    },
                    {
                        "name": "password",
                        "in": "query",
                        "description": "密码",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    },
                    {
                        "name": "role",
                        "in": "query",
                        "description": "角色",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    },
                    {
                        "name": "confrType",
                        "in": "query",
                        "description": "会议类型",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                }
            }
        },
        "/Conference/Get/{key}": {
            "get": {
                "tags": [
                    "Conference"
                ],
                "summary": "get Conference",
                "parameters": [
                    {
                        "name": "key",
                        "in": "path",
                        "description": "Conference id",
                        "required": false,
                        "schema": {
                            "type": "integer",
                            "items": {},
                            "format": "int32"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                },
                "security": [
                    {
                        "oauth2": []
                    }
                ]
            }
        },
        "/Conference/GetConfDetail/{key}": {
            "get": {
                "tags": [
                    "Conference"
                ],
                "summary": "get Conference detail",
                "parameters": [
                    {
                        "name": "key",
                        "in": "path",
                        "description": "Conference id",
                        "required": false,
                        "schema": {
                            "type": "integer",
                            "items": {},
                            "format": "int32"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                },
                "security": [
                    {
                        "oauth2": []
                    }
                ]
            }
        },
        "/Conference/GetConfrOper": {
            "get": {
                "tags": [
                    "Conference"
                ],
                "summary": "get Conference detail",
                "parameters": [
                    {
                        "name": "confrId",
                        "in": "query",
                        "description": "",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                },
                "security": [
                    {
                        "oauth2": []
                    }
                ]
            }
        },
        "/Conference/Leave": {
            "post": {
                "tags": [
                    "Conference"
                ],
                "summary": "退出会议",
                "parameters": [
                    {
                        "name": "confrId",
                        "in": "query",
                        "description": "会议id",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    },
                    {
                        "name": "userName",
                        "in": "query",
                        "description": "",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                }
            }
        },
        "/Conference/Role": {
            "post": {
                "tags": [
                    "Conference"
                ],
                "summary": "role",
                "parameters": [
                    {
                        "name": "confrId",
                        "in": "query",
                        "description": "会议id",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    },
                    {
                        "name": "role",
                        "in": "query",
                        "description": "角色 7为管理员",
                        "required": false,
                        "schema": {
                            "type": "integer",
                            "items": {},
                            "format": "int32"
                        }
                    },
                    {
                        "name": "userName",
                        "in": "query",
                        "description": "用户名称",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                },
                "security": [
                    {
                        "oauth2": []
                    }
                ]
            }
        },
        "/Conference/SetChatroomMute": {
            "post": {
                "tags": [
                    "Conference"
                ],
                "summary": "设置聊天室静音",
                "requestBody": {
                    "content": {
                        "application/*+json": {
                            "schema": {
                                "$ref": "#/components/schemas/ChatroomMute"
                            }
                        },
                        "application/json": {
                            "schema": {
                                "$ref": "#/components/schemas/ChatroomMute"
                            }
                        },
                        "application/json-patch+json": {
                            "schema": {
                                "$ref": "#/components/schemas/ChatroomMute"
                            }
                        },
                        "text/json": {
                            "schema": {
                                "$ref": "#/components/schemas/ChatroomMute"
                            }
                        }
                    }
                },
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                },
                "security": [
                    {
                        "oauth2": []
                    }
                ]
            }
        },
        "/Conference/SetWhiteStatus": {
            "post": {
                "tags": [
                    "Conference"
                ],
                "summary": "设置聊天室静音",
                "requestBody": {
                    "content": {
                        "application/*+json": {
                            "schema": {
                                "$ref": "#/components/schemas/WhiteStatus"
                            }
                        },
                        "application/json": {
                            "schema": {
                                "$ref": "#/components/schemas/WhiteStatus"
                            }
                        },
                        "application/json-patch+json": {
                            "schema": {
                                "$ref": "#/components/schemas/WhiteStatus"
                            }
                        },
                        "text/json": {
                            "schema": {
                                "$ref": "#/components/schemas/WhiteStatus"
                            }
                        }
                    }
                },
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                },
                "security": [
                    {
                        "oauth2": []
                    }
                ]
            }
        },
        "/Token/GenToken": {
            "post": {
                "tags": [
                    "Token"
                ],
                "summary": "",
                "requestBody": {
                    "content": {
                        "application/*+json": {
                            "schema": {
                                "$ref": "#/components/schemas/UserCredentials"
                            }
                        },
                        "application/json": {
                            "schema": {
                                "$ref": "#/components/schemas/UserCredentials"
                            }
                        },
                        "application/json-patch+json": {
                            "schema": {
                                "$ref": "#/components/schemas/UserCredentials"
                            }
                        },
                        "text/json": {
                            "schema": {
                                "$ref": "#/components/schemas/UserCredentials"
                            }
                        }
                    }
                },
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                }
            }
        },
        "/User/GetAvator": {
            "post": {
                "tags": [
                    "User"
                ],
                "summary": "获得头像",
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                },
                "security": [
                    {
                        "oauth2": []
                    }
                ]
            }
        },
        "/User/GetCur": {
            "get": {
                "tags": [
                    "User"
                ],
                "summary": "get user",
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                },
                "security": [
                    {
                        "oauth2": []
                    }
                ]
            }
        },
        "/User/GetNickName": {
            "get": {
                "tags": [
                    "User"
                ],
                "summary": "get nick name",
                "parameters": [
                    {
                        "name": "confrKey",
                        "in": "query",
                        "description": "会议key",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    },
                    {
                        "name": "userName",
                        "in": "query",
                        "description": "用户key",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                },
                "security": [
                    {
                        "oauth2": []
                    }
                ]
            }
        },
        "/User/GetUserRole": {
            "get": {
                "tags": [
                    "User"
                ],
                "summary": "get role",
                "parameters": [
                    {
                        "name": "confrKey",
                        "in": "query",
                        "description": "会议key",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    },
                    {
                        "name": "userName",
                        "in": "query",
                        "description": "用户key",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                },
                "security": [
                    {
                        "oauth2": []
                    }
                ]
            }
        },
        "/User/UpdateNickName": {
            "post": {
                "tags": [
                    "User"
                ],
                "summary": "get user",
                "parameters": [
                    {
                        "name": "nickName",
                        "in": "query",
                        "description": "用户昵称",
                        "required": false,
                        "schema": {
                            "type": "string",
                            "items": {}
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                },
                "security": [
                    {
                        "oauth2": []
                    }
                ]
            }
        },
        "/User/UploadAvator": {
            "post": {
                "tags": [
                    "User"
                ],
                "summary": "上传头像",
                "requestBody": {
                    "content": {
                        "multipart/form-data": {
                            "schema": {
                                "type": "object",
                                "properties": {
                                    "file": {
                                        "type": "string",
                                        "items": {},
                                        "format": "binary"
                                    }
                                }
                            }
                        }
                    }
                },
                "responses": {
                    "200": {
                        "description": "Success"
                    },
                    "401": {
                        "description": "Unauthorized"
                    },
                    "403": {
                        "description": "Forbidden"
                    }
                },
                "security": [
                    {
                        "oauth2": []
                    }
                ]
            }
        }
    },
    "components": {
        "schemas": {
            "ChatroomMute": {
                "type": "object",
                "properties": {
                    "UserNames": {
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    },
                    "confrId": {
                        "type": "string",
                        "items": {}
                    },
                    "isOpen": {
                        "type": "integer",
                        "items": {},
                        "format": "int32"
                    }
                },
                "additionalProperties": false
            },
            "UserCredentials": {
                "type": "object",
                "properties": {
                    "password": {
                        "type": "string",
                        "items": {}
                    },
                    "username": {
                        "type": "string",
                        "items": {}
                    }
                },
                "additionalProperties": false
            },
            "WhiteStatus": {
                "type": "object",
                "properties": {
                    "UserNames": {
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    },
                    "confrId": {
                        "type": "string",
                        "items": {}
                    },
                    "isOpen": {
                        "type": "integer",
                        "items": {},
                        "format": "int32"
                    }
                },
                "additionalProperties": false
            }
        },
        "securitySchemes": {
            "oauth2": {
                "type": "apiKey",
                "description": "JWT授权(数据将在请求头中进行传输) 直接在下框中输入Bearer {token}（注意两者之间是一个空格）\"",
                "name": "Authorization",
                "in": "header"
            }
        }
    }
}
`

type swaggerInfo struct {
}

// SwaggerInfo holds exported Swagger Info so clients can modify it
var SwaggerInfo = swaggerInfo{}

type s struct{}

func (s *s) ReadDoc() string {
	sInfo := SwaggerInfo

	t, err := template.New("swagger_info").Funcs(template.FuncMap{
		"marshal": func(v interface{}) string {
			a, _ := json.Marshal(v)
			return string(a)
		},
	}).Parse(doc)
	if err != nil {
		return doc
	}

	var tpl bytes.Buffer
	if err := t.Execute(&tpl, sInfo); err != nil {
		return doc
	}

	return tpl.String()
}

func init() {
	hiweb.SwaggerRegister(&s{})

	conference := Conference{}

	hiweb.Route("/Conference/Entry", &conference, "name;username;password;role;confrType", "post:Entry", hiweb.RouteOption{IsAuth: false})

	hiweb.Route("/Conference/Role", &conference, "confrId;role;userName", "post:Role", hiweb.RouteOption{IsAuth: true})

	hiweb.Route("/Conference/Leave", &conference, "confrId;userName", "post:Leave", hiweb.RouteOption{IsAuth: false})

	hiweb.Route("/Conference/SetChatroomMute", &conference, "", "post:SetChatroomMute", hiweb.RouteOption{IsAuth: true})

	hiweb.Route("/Conference/Get/", &conference, "key", "get:Get", hiweb.RouteOption{IsAuth: true})

	hiweb.Route("/Conference/GetConfDetail/", &conference, "key", "get:GetConfDetail", hiweb.RouteOption{IsAuth: true})

	hiweb.Route("/Conference/GetConfrOper", &conference, "confrId", "get:GetConfrOper", hiweb.RouteOption{IsAuth: true})

	hiweb.Route("/Conference/SetWhiteStatus", &conference, "", "post:SetWhiteStatus", hiweb.RouteOption{IsAuth: true})

	token := Token{}

	hiweb.Route("/Token/GenToken", &token, "", "post:GenToken", hiweb.RouteOption{IsAuth: false})

	user := User{}

	hiweb.Route("/User/GetAvator", &user, "", "post:GetAvator", hiweb.RouteOption{IsAuth: true})

	hiweb.Route("/User/GetNickName", &user, "confrKey;userName", "get:GetNickName", hiweb.RouteOption{IsAuth: true})

	hiweb.Route("/User/GetUserRole", &user, "confrKey;userName", "get:GetUserRole", hiweb.RouteOption{IsAuth: true})

	hiweb.Route("/User/UpdateNickName", &user, "nickName", "post:UpdateNickName", hiweb.RouteOption{IsAuth: true})

	hiweb.Route("/User/UploadAvator", &user, "", "post:UploadAvator", hiweb.RouteOption{IsAuth: true})

	hiweb.Route("/User/GetCur", &user, "", "get:GetCur", hiweb.RouteOption{IsAuth: true})

}
