package api

import (
	"context"
	"regexp"
)

type RouterOption func(*Router) error

func WithImagePath(path string) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.image_path = path
		return
	}
}

func WithSearchPath(path string) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.search_path = path
		return
	}
}

func WithUsernamePattern(pattern *regexp.Regexp) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.username_pattern = pattern
		return
	}
}

func WithUsernameMinlen(l int) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.username_minlen = l
		return
	}
}

func WithLoginDefaultMaxage(l int) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.login_defage = l
		return
	}
}

func WithSessidTimeout(l int) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.sessid_timeout = l
		return
	}
}

func WithUserDefaultPrivacy(l userinfo_usertype) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.default_privacy = l
		return
	}
}

func WithDgraph(db string) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.dgraph = db
		return
	}
}

func WithVisionProxy(proxy string) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.vision_socks5_proxy = proxy
		return
	}
}

func WithServerMaxerr(l int) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.server_maxerr = l
		return
	}
}

func WithContext(ctx context.Context) RouterOption {
	return func(rt *Router) (err error) {
		rt.ctx = ctx
		return
	}
}

func WithContentMaxlen(l int) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.content_maxlen = l
		return
	}
}

func WithCoverMaxlen(l int) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.cover_maxlen = l
		return
	}
}

func WithTitleMaxlen(l int) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.title_maxlen = l
		return
	}
}

func WithTagMaxlen(l int) RouterOption {
	return func(rt *Router) (err error) {
		rt.cfg.tag_maxlen = l
		return
	}
}
