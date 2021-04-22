package service

import (
	"fmt"
	"testing"
)

func TestRegisterUser(t *testing.T) {
	InitEaseMob("1108200509113038", "chatapp", "YXA6axGRAPHUSeyk9gN5mLVB8A", "YXA6Z_PjcIkBH2z3a7B7CBXl3y-hU78")
	_, err := Token()
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}
	// err = RegisterUser("zz3", "zz3", "zz2")

	// conf, err := CreateConferences(10, "")
	// if err != nil {
	// 	fmt.Printf("err:%s", err)
	// 	return
	// }
	// fmt.Printf("c:%v\n", conf)

	conf, err := GetConference("LBJ13H05522QKTH0DX5JHD00C144087")
	if err != nil {
		fmt.Printf("err:%s\n", err)
		return
	}
	fmt.Printf("c:%v\n", conf)
}

func TestGetUser(t *testing.T) {
	InitEaseMob("1108200509113038", "chatapp", "YXA6axGRAPHUSeyk9gN5mLVB8A", "YXA6Z_PjcIkBH2z3a7B7CBXl3y-hU78")
	_, err := Token()
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}
	users, err := GetUser("ca")

	// conf, err := CreateConferences(10, "")
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}
	fmt.Printf("u:%v\n", users)

}
func TestDelUser(t *testing.T) {
	InitEaseMob("1108200509113038", "chatapp", "YXA6axGRAPHUSeyk9gN5mLVB8A", "YXA6Z_PjcIkBH2z3a7B7CBXl3y-hU78")
	_, err := Token()
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}
	err = DelUser("9d0f7bba9bff443669b0223beea5f4f7")

	// conf, err := CreateConferences(10, "")
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}

}
func TestCreateChatroom(t *testing.T) {
	InitEaseMob("1108200509113038", "chatapp", "YXA6axGRAPHUSeyk9gN5mLVB8A", "YXA6Z_PjcIkBH2z3a7B7CBXl3y-hU78")
	_, err := Token()
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}
	id, err := CreateChatroom("aa", "5860e28d95e3438860d5d3c8150e3437")
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}
	fmt.Printf("id:%v\n", id)
}

func TestGetChatroom(t *testing.T) {
	InitEaseMob("1108200509113038", "chatapp", "YXA6axGRAPHUSeyk9gN5mLVB8A", "YXA6Z_PjcIkBH2z3a7B7CBXl3y-hU78")
	_, err := Token()
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}
	id, err := GetChatroom("129869194264577")
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}
	fmt.Printf("id:%v\n", id)
}

func TestGetChatroomMute(t *testing.T) {
	InitEaseMob("1108200509113038", "chatapp", "YXA6axGRAPHUSeyk9gN5mLVB8A", "YXA6Z_PjcIkBH2z3a7B7CBXl3y-hU78")
	_, err := Token()
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}
	id, err := GetChatroomMute("130693579472898")
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}
	fmt.Printf("id:%v\n", id)
}

func TestSetChatroomMute(t *testing.T) {
	InitEaseMob("1108200509113038", "chatapp", "YXA6axGRAPHUSeyk9gN5mLVB8A", "YXA6Z_PjcIkBH2z3a7B7CBXl3y-hU78")
	_, err := Token()
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}
	err = AddChatroomMute("130702249099265", []string{})
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}
}

func TestRoleConference(t *testing.T) {
	InitEaseMob("1108200509113038", "chatapp", "YXA6axGRAPHUSeyk9gN5mLVB8A", "YXA6Z_PjcIkBH2z3a7B7CBXl3y-hU78")
	_, err := Token()
	if err != nil {
		fmt.Printf("err:%s", err)
		return
	}
	// err = RoleConference("", "LBJ13H05522QATH0DW164400C149949", "7", []string{"1108200509113038#chatapp_1e6668d2d6c54f5054e2d0836bf84c71"})
	// if err != nil {
	// 	fmt.Printf("err:%s", err)
	// 	return
	// }
}

func TestLogin(t *testing.T) {
	// InitEaseMob("1108200509113038", "chatapp", "YXA6axGRAPHUSeyk9gN5mLVB8A", "YXA6Z_PjcIkBH2z3a7B7CBXl3y-hU78")
	// at, err := Token()
	// if err != nil {
	// 	fmt.Printf("err:%s", err)
	// 	return
	// }
	// auser, err := RegisterUser("admin", "1", "admin")
	// if err != nil {
	// 	fmt.Printf("err:%s\n", err)
	// 	return
	// }
	// fmt.Printf("id:%v\n", auser.Uuid)
	// conf, err := CreateConferences("admin", "aa")
	// if err != nil {
	// 	fmt.Printf("err:%s\n", err)
	// 	return
	// }

	// _, roleToken, err := Login("LBJ13H05522QATH0DW164400C153055", "caonima121", at, "1108200509113038#chatapp_admin")
	// if err != nil {
	// 	fmt.Printf("err:%s", err)
	// 	return
	// }
	// fmt.Printf("id:%v\n", roleToken)
	// err = RoleConference(roleToken, "LBJ13H05522QATH0DW164400C153055", "7", "68d2d6c52f5044e250836bf84c7174cb")
	// if err != nil {
	// 	fmt.Printf("err:%s", err)
	// 	return
	// }
}
