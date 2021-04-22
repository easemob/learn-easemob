package utils

import (
	"strconv"
	"strings"
	"time"
)

const (
	secondFormat      = "2006-01-02 15:04:05"
	secondFormatV2    = "2006/01/02 15:04:05"
	minFormat         = "2006-01-02 15:04"
	dayMinFormat      = "15:04"
	dayStdFormat      = "2006-01-02"
	compactFormat     = "20060102150405"
	nanoFormat        = "2006-01-02 15:04:05.999999999"
	compactNanoFormat = "20060102150405.999999999"
	dayFormat         = "20060102"
	hourFormat        = "15"
)

// NowCompactStr 20060102150405
func NowCompactStr() string {
	currentTimeStr := time.Now().Format(compactFormat)
	return currentTimeStr
}

// NowNanoCompactStr 20060102150405999999999
func NowNanoCompactStr() string {
	currentTimeStr := time.Now().Format(compactNanoFormat)
	currentTimeStr = strings.Replace(currentTimeStr, ".", "", -1)
	return currentTimeStr
}
func NowNanoStr() string {
	currentTimeStr := time.Now().Format(nanoFormat)

	return currentTimeStr
}

// NowDayStr 20060102
func NowDayStr() string {
	dayFormatStr := time.Now().Format(dayFormat)
	return dayFormatStr
}

// NowDayStr 20060102
func NowDayInt() int {
	dayFormatStr := time.Now().Format(dayFormat)
	dayFormatInt, _ := strconv.Atoi(dayFormatStr)
	return dayFormatInt
}

// NowHourInt 20060102
func NowHourInt() int {
	hourFormatStr := time.Now().Format(hourFormat)
	hourFormatInt, _ := strconv.Atoi(hourFormatStr)
	return hourFormatInt
}

// FormatCompactDayStr ...
func FormatCompactDayStr(t time.Time) string {
	dayFormatStr := t.Format(dayFormat)
	return dayFormatStr
}

// FormatCompactDayInt ...
func FormatCompactDayInt(t time.Time) int {
	dayFormatStr := t.Format(dayFormat)
	dayFormatInt, _ := strconv.Atoi(dayFormatStr)
	return dayFormatInt
}

// ParseDay ...
func ParseDay(str string) (time.Time, error) {
	t, err := time.ParseInLocation(dayStdFormat, str, time.Local)
	if err != nil {
		return t, err
	}
	return t, nil
}

// ParseCompactDay ...
func ParseCompactDay(str string) (time.Time, error) {
	t, err := time.ParseInLocation(dayFormat, str, time.Local)
	if err != nil {
		return t, err
	}
	return t, nil
}
