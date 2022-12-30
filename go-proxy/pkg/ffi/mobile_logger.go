package ffi

/*
#cgo CFLAGS: -x objective-c
#cgo LDFLAGS: -framework Foundation
#import <Foundation/Foundation.h>
#import <os/log.h>


os_log_t logger;

void Log(const char *text) {
  if (logger == NULL) {
	logger = os_log_create("industries.strange.slowdown.tunnel.go-proxy", "go-proxy");
  }
  NSString *nss = [NSString stringWithUTF8String:text];
  // NSLog(@"%@", nss);
  os_log_debug(logger, "%{public}@", nss);


}
*/
import "C"
import "unsafe"

type MobileLogger struct {
}

func (nsl MobileLogger) Write(p []byte) (n int, err error) {
	p = append(p, 0)
	cstr := (*C.char)(unsafe.Pointer(&p[0]))
	C.Log(cstr)
	return len(p), nil
}
