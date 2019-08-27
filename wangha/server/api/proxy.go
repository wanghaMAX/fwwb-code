package api

import (
	"context"
	"net"

	"golang.org/x/net/proxy"
)

func (rt *Router) newProxyDialer() func(context.Context, string) (net.Conn, error) {
	return func(ctx context.Context, addr string) (conn net.Conn, err error) {
		dialer, err := proxy.SOCKS5("tcp", rt.cfg.vision_socks5_proxy, nil, proxy.Direct)
		if err != nil {
			rt.infof("can't connect to the proxy: %v\n", err)
			return nil, err
		}

		conn, err = dialer.Dial("tcp", addr)
		return
	}
}
