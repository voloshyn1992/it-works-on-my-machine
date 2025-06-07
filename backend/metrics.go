package main

import (
	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func metricsHandler(ctx *gin.Context) {
	prometheusHandler := promhttp.Handler()
	prometheusHandler.ServeHTTP(ctx.Writer, ctx.Request)
}
