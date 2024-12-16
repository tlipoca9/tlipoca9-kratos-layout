package codec

import "github.com/BurntSushi/toml"

type TOML struct{}

func (TOML) Marshal(v any) ([]byte, error) {
	return toml.Marshal(v)
}

func (TOML) Unmarshal(data []byte, v any) error {
	return toml.Unmarshal(data, v)
}

func (TOML) Name() string {
	return "toml"
}
