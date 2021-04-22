package utils

import (
	"encoding/base64"
	"strings"
)

// Base64Decode ...
func Base64Decode(s string) ([]byte, error) {
	s1 := strings.Replace(s, " ", "+", -1)
	return base64.StdEncoding.DecodeString(s1)
}

// Base64Encode ...
func Base64Encode(s []byte) string {
	return base64.StdEncoding.EncodeToString(s)
}
