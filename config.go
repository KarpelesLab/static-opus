package opus

/*
// standard compilation flags
#cgo CFLAGS: -DHAVE_CONFIG_H -D_FORTIFY_SOURCE=2 -DPIC -fvisibility=hidden -fstack-protector-strong -fno-common
#cgo windows LDFLAGS: -lssp

// add includes needed for opus, including building the actual opus lib
#cgo CFLAGS: -Iopus-1.5.2 -Iopus-1.5.2/include -Iopus-1.5.2/celt -Iopus-1.5.2/silk -Iopus-1.5.2/silk/float
#cgo LDFLAGS: -lm
*/
import "C"
