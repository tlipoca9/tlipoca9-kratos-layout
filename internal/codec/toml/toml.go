package toml

import (
	"github.com/BurntSushi/toml"
	"github.com/go-kratos/kratos/v2/encoding"
)

const Name = "toml"

func init() {
	encoding.RegisterCodec(codec{})
}

type codec struct{}

func (codec) Marshal(v any) ([]byte, error) {
	return toml.Marshal(v)
}

func (codec) Unmarshal(data []byte, v any) error {
	return toml.Unmarshal(data, v)
}

func (codec) Name() string {
	return Name
}
