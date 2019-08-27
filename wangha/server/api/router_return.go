package api

var (
	RetSuccess         = []byte(`{"success": "200", "error": ""}`)
	RetAlreadyLogined  = []byte(`{"success": "100", "error": "already logined"}`)
	RetNoSuchUser      = []byte(`{"success": "100", "error": "no such user"}`)
	RetNoSuchImage     = []byte(`{"success": "100", "error": "no such image"}`)
	RetUserExisted     = []byte(`{"success": "100", "error": "email, phone, or username existed"}`)
	RetNeedPerm        = []byte(`{"success": "100", "error": "need permission"}`)
	RetIncorrectPasswd = []byte(`{"success": "100", "error": "password incorrect"}`)
	RetFailLogin       = []byte(`{"success": "100", "error": "fail to login"}`)
	RetInvalid         = []byte(`{"success": "400", "error": "invalid parameters"}`)
	RetInvalidUsername = []byte(`{"success": "400", "error": "name should match the pattern, and not too short"}`)
	RetInvalidCate     = []byte(`{"success": "400", "error": "invalid  category"}`)
	Ret404             = []byte(`{"success": "404", "error": "404 not found"}`)
	RetNotAvailable    = []byte(`{"success": "503", "error": "busy"}`)
)
