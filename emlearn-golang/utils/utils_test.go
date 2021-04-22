package utils

import (
	"fmt"
	"testing"
)

func TestTime(t *testing.T) {
	fmt.Printf("%s\n", NowNanoCompactStr())
}
