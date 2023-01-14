// Objective-C API for talking to strange.industries/go-proxy/pkg/ffi Go package.
//   gobind -lang=objc strange.industries/go-proxy/pkg/ffi
//
// File is generated by gobind. Do not edit.

#ifndef __Ffi_H__
#define __Ffi_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


@class FfiDebugClientProxyBridge;
@class FfiMobileLogger;
@class FfiOnDeviceProxyBridge;
@class FfiOutboundChannel;
@class FfiTunConnAdapter;
@protocol FfiCallbacks;
@class FfiCallbacks;
@protocol FfiProxyBridge;
@class FfiProxyBridge;

@protocol FfiCallbacks <NSObject>
- (void)writeInboundPacket:(NSData* _Nullable)b;
@end

@protocol FfiProxyBridge <NSObject>
- (void)close;
/**
 * Control plane
 */
- (NSData* _Nullable)rpc:(NSData* _Nullable)input error:(NSError* _Nullable* _Nullable)error;
- (void)startDirectProxyConnection:(id<FfiCallbacks> _Nullable)cbs settingsData:(NSData* _Nullable)settingsData;
/**
 * Deprecate
 */
- (void)startUDPServer:(long)port settingsData:(NSData* _Nullable)settingsData;
/**
 * Data plane
 */
- (void)writeOutboundPacket:(NSData* _Nullable)b;
@end

@interface FfiDebugClientProxyBridge : NSObject <goSeqRefInterface, FfiProxyBridge> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) FfiOutboundChannel* _Nullable outboundChannel;
- (void)close;
- (NSData* _Nullable)readOutboundPacket;
- (NSData* _Nullable)rpc:(NSData* _Nullable)input error:(NSError* _Nullable* _Nullable)error;
- (void)startDirectProxyConnection:(id<FfiCallbacks> _Nullable)cbs settingsData:(NSData* _Nullable)settingsData;
/**
 * deprecated.
 */
- (void)startUDPServer:(long)port settingsData:(NSData* _Nullable)settingsData;
- (void)writeOutboundPacket:(NSData* _Nullable)b;
@end

@interface FfiMobileLogger : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
- (BOOL)write:(NSData* _Nullable)p0 n:(long* _Nullable)n error:(NSError* _Nullable* _Nullable)error;
@end

@interface FfiOnDeviceProxyBridge : NSObject <goSeqRefInterface, FfiProxyBridge> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped field OnDeviceProxyBridge.Proxy with unsupported type: *strange.industries/go-proxy/pkg/proxy.Proxy

@property (nonatomic) FfiOutboundChannel* _Nullable outboundChannel;
// skipped method OnDeviceProxyBridge.AppUsed with unsupported parameter or return types

- (void)beforeSettingsChange;
- (void)close;
// skipped method OnDeviceProxyBridge.DebugGetEntries with unsupported parameter or return types

// skipped method OnDeviceProxyBridge.DebugRecordState with unsupported parameter or return types

// skipped method OnDeviceProxyBridge.GetDefiniteAppMatch with unsupported parameter or return types

// skipped method OnDeviceProxyBridge.GetFlow with unsupported parameter or return types

// skipped method OnDeviceProxyBridge.GetFuzzyAppMatch with unsupported parameter or return types

// skipped method OnDeviceProxyBridge.GetState with unsupported parameter or return types

- (void)heal;
// skipped method OnDeviceProxyBridge.OnSettingsChange with unsupported parameter or return types

// skipped method OnDeviceProxyBridge.PublishSample with unsupported parameter or return types

- (NSData* _Nullable)readOutboundPacket;
- (void)recordIp:(NSString* _Nullable)ip;
// skipped method OnDeviceProxyBridge.RecordState with unsupported parameter or return types

- (void)registerDnsEntry:(NSString* _Nullable)ip name:(NSString* _Nullable)name;
- (void)registerIp:(NSString* _Nullable)ip;
- (NSData* _Nullable)rpc:(NSData* _Nullable)input error:(NSError* _Nullable* _Nullable)error;
- (double)rxSpeedTarget;
// skipped method OnDeviceProxyBridge.SetSettings with unsupported parameter or return types

// skipped method OnDeviceProxyBridge.Start with unsupported parameter or return types

- (void)startDirectProxyConnection:(id<FfiCallbacks> _Nullable)cbs settingsData:(NSData* _Nullable)settingsData;
- (void)startUDPServer:(long)port settingsData:(NSData* _Nullable)settingsData;
// skipped method OnDeviceProxyBridge.UpdateUsagePoints with unsupported parameter or return types

- (void)writeOutboundPacket:(NSData* _Nullable)b;
@end

/**
 * Allows outbound packets to
1) be written to by a producer, and
2) be read from by a consumer
 */
@interface FfiOutboundChannel : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
- (NSData* _Nullable)readOutboundPacket;
- (void)writeOutboundPacket:(NSData* _Nullable)b;
@end

/**
 * Provides a TunConn
 */
@interface FfiTunConnAdapter : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
- (void)close;
/**
 * Read outbound packets
 */
- (BOOL)read:(NSData* _Nullable)b ret0_:(long* _Nullable)ret0_ error:(NSError* _Nullable* _Nullable)error;
- (BOOL)write:(NSData* _Nullable)b ret0_:(long* _Nullable)ret0_ error:(NSError* _Nullable* _Nullable)error;
@end

FOUNDATION_EXPORT id<FfiProxyBridge> _Nullable FfiInit(NSString* _Nullable env);

FOUNDATION_EXPORT id<FfiProxyBridge> _Nullable FfiInitDebug(NSString* _Nullable env, NSString* _Nullable dataAddr, NSString* _Nullable controlAddr);

FOUNDATION_EXPORT FfiDebugClientProxyBridge* _Nullable FfiInitDebugClientProxyBridge(NSString* _Nullable dataAddr, NSString* _Nullable controlAddr);

FOUNDATION_EXPORT FfiOutboundChannel* _Nullable FfiInitOutboundChannel(void);

FOUNDATION_EXPORT FfiTunConnAdapter* _Nullable FfiInitTunConnAdapter(id<FfiCallbacks> _Nullable cbs, FfiOutboundChannel* _Nullable oc);

FOUNDATION_EXPORT long FfiMaxProcs(long max);

FOUNDATION_EXPORT long FfiSetGCPercent(long pct);

FOUNDATION_EXPORT int64_t FfiSetMemoryLimit(int64_t limit);

@class FfiCallbacks;

@class FfiProxyBridge;

@interface FfiCallbacks : NSObject <goSeqRefInterface, FfiCallbacks> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (void)writeInboundPacket:(NSData* _Nullable)b;
@end

@interface FfiProxyBridge : NSObject <goSeqRefInterface, FfiProxyBridge> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (void)close;
/**
 * Control plane
 */
- (NSData* _Nullable)rpc:(NSData* _Nullable)input error:(NSError* _Nullable* _Nullable)error;
- (void)startDirectProxyConnection:(id<FfiCallbacks> _Nullable)cbs settingsData:(NSData* _Nullable)settingsData;
/**
 * Deprecate
 */
- (void)startUDPServer:(long)port settingsData:(NSData* _Nullable)settingsData;
/**
 * Data plane
 */
- (void)writeOutboundPacket:(NSData* _Nullable)b;
@end

#endif
