package service

const (
	// IsIndent Result IsIndent
	IsIndent = false
)

// ServiceResult ...
type ServiceResult struct {
	Code    string      `json:"code"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
}

// IsSuccessful 判断是否成功
func (sr *ServiceResult) IsSuccessful() bool {
	return sr.Code == SUCCESS
}

// SetCode 设定code
func (sr *ServiceResult) SetCode(code string) *ServiceResult {
	sr.Code = code
	sr.Message = RetCode[code]
	if sr.Code != SUCCESS {
		sr.Data = nil
	}
	return sr
}

// SetData 设定Data并修改Code为syscode.SUCCESS
func (sr *ServiceResult) SetData(data interface{}) *ServiceResult {
	sr.Data = data
	if sr.Data != nil {
		sr.Code = SUCCESS
		sr.Message = RetCode[sr.Code]
	}
	return sr
}

// SetError 设定Error
func (sr *ServiceResult) SetError(err error) *ServiceResult {
	sr.SetErrorCode(err, EXCEPTION)
	return sr
}

// SetErrorCode 设定Error,Code
func (sr *ServiceResult) SetErrorCode(err error, code string) *ServiceResult {
	sr.Code = code
	if code != SUCCESS {
		sr.Data = nil
	}
	sr.Message = RetCode[sr.Code]
	return sr
}

func SuccessData(data interface{}) *ServiceResult {
	codeObj := ServiceResult{
		Code: SUCCESS,
		Data: data,
	}
	return &codeObj
}
func ExcptionData(mess string) *ServiceResult {
	codeObj := ServiceResult{
		Code:    EXCEPTION,
		Message: mess,
	}
	return &codeObj
}

// ErrorCode 创建返回值
func ErrorCode(code string) *ServiceResult {
	mess := RetCode[code]
	codeObj := ServiceResult{
		Code:    code,
		Message: mess,
	}
	return &codeObj
}
