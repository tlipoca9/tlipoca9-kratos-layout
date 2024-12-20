// Code generated by Wire. DO NOT EDIT.

//go:generate go run -mod=mod github.com/google/wire/cmd/wire
//go:build !wireinject
// +build !wireinject

package main

import (
	"github.com/go-kratos/kratos/v2"
	"github.com/go-kratos/kratos/v2/log"
	"github.com/tlipoca9/tlipoca9-kratos-layout/internal/biz"
	"github.com/tlipoca9/tlipoca9-kratos-layout/internal/conf"
	"github.com/tlipoca9/tlipoca9-kratos-layout/internal/data"
	"github.com/tlipoca9/tlipoca9-kratos-layout/internal/server"
	"github.com/tlipoca9/tlipoca9-kratos-layout/internal/service"
)

import (
	_ "github.com/KimMachineGun/automemlimit"
	_ "github.com/tlipoca9/tlipoca9-kratos-layout/internal/codec/toml"
	_ "go.uber.org/automaxprocs"
)

// Injectors from wire.go:

// wireApp init kratos application.
func wireApp(confServer *conf.Server, confData *conf.Data, logger log.Logger) (*kratos.App, func(), error) {
	dataData, cleanup, err := data.NewData(confData, logger)
	if err != nil {
		return nil, nil, err
	}
	greeterRepo := data.NewGreeterRepo(dataData, logger)
	greeterUsecase := biz.NewGreeterUsecase(greeterRepo, logger)
	greeterService := service.NewGreeterService(greeterUsecase)
	grpcServer := server.NewGRPCServer(confServer, greeterService, logger)
	httpServer := server.NewHTTPServer(confServer, greeterService, logger)
	profileServer := server.NewProfileServer(confServer, logger)
	app := newApp(logger, grpcServer, httpServer, profileServer)
	return app, func() {
		cleanup()
	}, nil
}
