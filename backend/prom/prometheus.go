package prom

import (
	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus"
	"strconv"
	"time"
)

var (
	httpRequestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"code", "method"},
	)

	httpRequestErrorsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_request_errors_total",
			Help: "Total number of HTTP error responses",
		},
		[]string{"code", "method"},
	)

	httpRequestDurationSeconds = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "Histogram of HTTP request latencies",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"handler", "method"},
	)
)

func init() {
	prometheus.MustRegister(
		httpRequestsTotal,
		httpRequestErrorsTotal,
		httpRequestDurationSeconds,
	)
}
func PrometheusMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		c.Next() // process request

		status := c.Writer.Status()
		elapsed := time.Since(start).Seconds()
		handler := c.FullPath()
		method := c.Request.Method

		httpRequestDurationSeconds.
			WithLabelValues(handler, method).
			Observe(elapsed)

		httpRequestsTotal.
			WithLabelValues(strconv.Itoa(status), method).
			Inc()

		if status >= 400 {
			httpRequestErrorsTotal.
				WithLabelValues(strconv.Itoa(status), method).
				Inc()
		}
	}
}
