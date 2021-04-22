package service

const (
	/*系统返回值*/
	SUCCESS                = "1"
	EXCEPTION              = "-1"
	UPLOAD_ERR             = "-2"
	UPLOAD_TOO_LARGE       = "-3"
	BASE64_ERR             = "-4"
	INPARAM_ERR            = "-5"
	NODATA_ERR             = "-6"
	JSON_TRANS_ERR         = "-7"
	DATABASE_EXECUTE_ERROR = "-8"
	OPERATE_ERROR          = "-9"
	INVALID_DATA           = "-10"
	USER_PWD_ERROR         = "-11"
	CSV_INVALID_DATA       = "-12"
	USERID_GET_ERROR       = "-13"
	TIME_FORMAT_ERROR      = "-14"
	MULTIPLE_TEACHER       = "-15"
	MULTIPLE_STUDENT       = "-16"
	SET_ERROR              = "-17"
	CONFER_CLOSE = "-18"
)

var RetCode map[string]string = map[string]string{
	/*系统返回值*/
	SUCCESS:                "正常",
	EXCEPTION:              "系统错误",
	UPLOAD_ERR:             "上传文件错误",
	UPLOAD_TOO_LARGE:       "上传文件过大",
	BASE64_ERR:             "base64 错误",
	INPARAM_ERR:            "传入参数错误",
	NODATA_ERR:             "关联数据已被移除或发现变更",
	JSON_TRANS_ERR:         "JSON数据不合法",
	DATABASE_EXECUTE_ERROR: "数据库执行失败,请重试，如需再次复现，请联系管理员！",
	OPERATE_ERROR:          "操作失败，请联系管理员",
	INVALID_DATA:           "数据不合法",
	USER_PWD_ERROR:         "用户名,密码错误",
	CSV_INVALID_DATA:       "CSV数据不合法",
	USERID_GET_ERROR:       "获得userid失败",
	TIME_FORMAT_ERROR:      "时间格式错误",
	MULTIPLE_TEACHER:       "多个老师",
	MULTIPLE_STUDENT:       "多个学生",
	SET_ERROR:              "设置失败",
	CONFER_CLOSE:"会议已关闭",
}

func GetCodeMesg(code string) string {
	mesg, exsits := RetCode[code]
	if !exsits {
		return ""
	} else {
		return mesg
	}
}
