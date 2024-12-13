package server

import (
	"net/http/pprof"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/go-kratos/kratos/v2/middleware/recovery"
	"github.com/go-kratos/kratos/v2/transport/http"

	"github.com/tlipoca9/tlipoca9-kratos-layout/internal/conf"
)

type ProfileServer struct {
	*http.Server
}

// NewProfileServer new a pprof server.
func NewProfileServer(c *conf.Server, logger log.Logger) *ProfileServer {
	if !c.Profile.Enabled {
		return nil
	}

	var opts = []http.ServerOption{
		http.Middleware(
			recovery.Recovery(),
		),
	}
	if c.Profile.Network != "" {
		opts = append(opts, http.Network(c.Profile.Network))
	}
	if c.Profile.Addr != "" {
		opts = append(opts, http.Address(c.Profile.Addr))
	}
	if c.Profile.Timeout != nil {
		opts = append(opts, http.Timeout(c.Profile.Timeout.AsDuration()))
	}

	srv := http.NewServer(opts...)
	srv.HandleFunc("/debug/pprof/", pprof.Index)
	srv.HandleFunc("/debug/pprof/cmdline", pprof.Cmdline)
	srv.HandleFunc("/debug/pprof/profile", pprof.Profile)
	srv.HandleFunc("/debug/pprof/symbol", pprof.Symbol)
	srv.HandleFunc("/debug/pprof/trace", pprof.Trace)
	return &ProfileServer{Server: srv}
}
