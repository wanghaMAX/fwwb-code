package api

import "unsafe"

type strAnyMap = map[string]interface{}
type strStrMap = map[string]string

// convert string into byte slice effectively
func str_bytes(s string) []byte {
	return *(*[]byte)(unsafe.Pointer(&s))
}

func strstrmap(m strAnyMap) strStrMap {
	r := strStrMap{}

	for k, v := range m {
		if vs, ok := v.(string); ok {
			r[k] = vs
		}
	}

	return r
}

func min(x, y int) int {
	if x < y {
		return x
	} else {
		return y
	}
}
