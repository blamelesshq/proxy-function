package fetch

type FunctionObj struct {
	Route       string
	Url         string
	AccessToken string
	Login       string
	Password    string
	Type        string
}

type RouteConfigObj struct {
	Functions []FunctionObj
}

type Response struct {
	StatusCode int
	Data       *map[string]interface{}
}

type Fetch struct {
	Path        string
	Search      string
	Start       string
	End         string
	Url         string
	AccessToken string
	Login       string
	Password    string
	Type        string
	Params      string
}

type Result struct {
	Bltime  string
	Blvalue string
}

type Sid struct {
	Sid string
}
