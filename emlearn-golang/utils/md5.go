package utils

import (
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
)

// Md5String ...
func Md5String(s string) string {
	h := md5.New()
	h.Write([]byte(s)) // 需要加密的字符串
	return hex.EncodeToString(h.Sum(nil))
}

// Md5Json md5 struct use json string
func Md5Json(obj interface{}) (string, error) {
	s, err := json.Marshal(obj)
	if err != nil {
		return "", err
	}
	return Md5String(string(s)), nil
}
