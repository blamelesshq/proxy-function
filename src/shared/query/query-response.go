package query

type QueryResponse struct {
	Data   QueryResponseData `json:"data"`
	Status string            `json:"status"`
}

type QueryResponseData struct {
	Result     []QueryResponseDataResult `json:"result"`
	ResultType string                    `json:"resultType"`
}

type QueryResponseDataResult struct {
	Values []map[string]string `json:"values"`
}
