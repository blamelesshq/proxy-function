package fetch

import (
	"encoding/base64"
	"fmt"
	"os"

	"github.com/antonmashko/envconf"
	"github.com/aws/aws-sdk-go/service/kms"
)

var isGCP = os.Getenv("IS_GCP")

func init() {
	fmt.Println("starting init config")
	if isGCP == "" {
		fmt.Println("init AWS config")
		// use kms for encrypt aws variables
		InitAWSConfig()
	} else {
		fmt.Println("init GCP config")
		InitGCPConfig()
	}
}

type Config struct {
	PrometheusURL string `env:"PROMETHEUS_URL" required:"true"`
	Login         string `env:"PROMETHEUS_LOGIN" required:"true"`
	Password      string `env:"PROMETHEUS_PASSWORD" required:"true"`
}

var DefaultConfig = Config{}

func decrypt(k *kms.KMS, text string) (string, error) {
	l, err := base64.StdEncoding.DecodeString(text)
	if err != nil {
		return "", fmt.Errorf("cannot decode string: %s", err)
	}
	input := &kms.DecryptInput{
		CiphertextBlob: l,
	}
	response, err := k.Decrypt(input)
	if err != nil {
		return "", fmt.Errorf("cannot decrypt string: %s", err)
	}
	return string(response.Plaintext[:]), nil
}

// InitAWSConfig init credentials for AWS KMS
func InitAWSConfig() {
	if err := envconf.Parse(&DefaultConfig); err != nil {
		panic(fmt.Errorf("cannot read config from env for AWS: %s", err))
	}
	// k := kms.New(session.New())
	// get login
	// fmt.Println("set login field from KMS")
	// l, err := decrypt(k, DefaultConfig.Login)
	// if err != nil {
	// 	panic(err)
	// }
	// DefaultConfig.Login = l
	// // get password
	// fmt.Println("set password field from KMS")
	// p, err := decrypt(k, DefaultConfig.Password)
	// if err != nil {
	// 	panic(err)
	// }
	// DefaultConfig.Password = p
	fmt.Printf("AWS config: %+v", DefaultConfig)
}

// InitGCPConfig init credentials for GCP
func InitGCPConfig() {
	if err := envconf.Parse(&DefaultConfig); err != nil {
		panic(fmt.Errorf("cannot read config from env for GCP: %s", err))
	}
	fmt.Printf("GCP config: %+v\n", DefaultConfig)
}
