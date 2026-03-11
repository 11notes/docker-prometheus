package main

import (
	"os"
	"syscall"

	"github.com/11notes/go-eleven"
)

const APP_BIN = "prometheus"
const APP_CONFIG_ENV string = "PROMETHEUS_CONFIG"
const APP_CONFIG string = "/prometheus/etc/default.yml"

func main() {
	// write env to file if set
	eleven.Container.EnvToFile(APP_CONFIG_ENV, APP_CONFIG)

	// start app
	if err := syscall.Exec("/usr/local/bin/" + APP_BIN, []string{APP_BIN, "--config.file", APP_CONFIG, "--web.listen-address=0.0.0.0:9090", "--log.format=json", "--auto-gomaxprocs", "--auto-gomemlimit", "--storage.tsdb.path=/prometheus/var"}, os.Environ()); err != nil {
		os.Exit(1)
	}
}