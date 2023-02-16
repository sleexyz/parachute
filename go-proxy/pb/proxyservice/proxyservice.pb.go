// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.28.1
// 	protoc        v3.20.3
// source: proxyservice.proto

package proxyservice

import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	timestamppb "google.golang.org/protobuf/types/known/timestamppb"
	reflect "reflect"
	sync "sync"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

type Mode int32

const (
	Mode_PROGRESSIVE Mode = 0
	Mode_FOCUS       Mode = 1
)

// Enum value maps for Mode.
var (
	Mode_name = map[int32]string{
		0: "PROGRESSIVE",
		1: "FOCUS",
	}
	Mode_value = map[string]int32{
		"PROGRESSIVE": 0,
		"FOCUS":       1,
	}
)

func (x Mode) Enum() *Mode {
	p := new(Mode)
	*p = x
	return p
}

func (x Mode) String() string {
	return protoimpl.X.EnumStringOf(x.Descriptor(), protoreflect.EnumNumber(x))
}

func (Mode) Descriptor() protoreflect.EnumDescriptor {
	return file_proxyservice_proto_enumTypes[0].Descriptor()
}

func (Mode) Type() protoreflect.EnumType {
	return &file_proxyservice_proto_enumTypes[0]
}

func (x Mode) Number() protoreflect.EnumNumber {
	return protoreflect.EnumNumber(x)
}

// Deprecated: Use Mode.Descriptor instead.
func (Mode) EnumDescriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{0}
}

type Settings struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	// latest version: 1
	Version                int32                  `protobuf:"varint,4,opt,name=version,proto3" json:"version,omitempty"`
	BaseRxSpeedTarget      float64                `protobuf:"fixed64,1,opt,name=baseRxSpeedTarget,proto3" json:"baseRxSpeedTarget,omitempty"`
	TemporaryRxSpeedTarget float64                `protobuf:"fixed64,2,opt,name=temporaryRxSpeedTarget,proto3" json:"temporaryRxSpeedTarget,omitempty"`
	TemporaryRxSpeedExpiry *timestamppb.Timestamp `protobuf:"bytes,3,opt,name=temporaryRxSpeedExpiry,proto3" json:"temporaryRxSpeedExpiry,omitempty"`
	UsageHealRate          float64                `protobuf:"fixed64,5,opt,name=usageHealRate,proto3" json:"usageHealRate,omitempty"` // HP per second
	UsageMaxHP             float64                `protobuf:"fixed64,6,opt,name=usageMaxHP,proto3" json:"usageMaxHP,omitempty"`
	UsageBaseRxSpeedTarget float64                `protobuf:"fixed64,9,opt,name=usageBaseRxSpeedTarget,proto3" json:"usageBaseRxSpeedTarget,omitempty"`
	Debug                  bool                   `protobuf:"varint,7,opt,name=debug,proto3" json:"debug,omitempty"`
	Mode                   Mode                   `protobuf:"varint,8,opt,name=mode,proto3,enum=proxyservice.Mode" json:"mode,omitempty"`
	PauseExpiry            *timestamppb.Timestamp `protobuf:"bytes,10,opt,name=pauseExpiry,proto3" json:"pauseExpiry,omitempty"`
}

func (x *Settings) Reset() {
	*x = Settings{}
	if protoimpl.UnsafeEnabled {
		mi := &file_proxyservice_proto_msgTypes[0]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Settings) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Settings) ProtoMessage() {}

func (x *Settings) ProtoReflect() protoreflect.Message {
	mi := &file_proxyservice_proto_msgTypes[0]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Settings.ProtoReflect.Descriptor instead.
func (*Settings) Descriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{0}
}

func (x *Settings) GetVersion() int32 {
	if x != nil {
		return x.Version
	}
	return 0
}

func (x *Settings) GetBaseRxSpeedTarget() float64 {
	if x != nil {
		return x.BaseRxSpeedTarget
	}
	return 0
}

func (x *Settings) GetTemporaryRxSpeedTarget() float64 {
	if x != nil {
		return x.TemporaryRxSpeedTarget
	}
	return 0
}

func (x *Settings) GetTemporaryRxSpeedExpiry() *timestamppb.Timestamp {
	if x != nil {
		return x.TemporaryRxSpeedExpiry
	}
	return nil
}

func (x *Settings) GetUsageHealRate() float64 {
	if x != nil {
		return x.UsageHealRate
	}
	return 0
}

func (x *Settings) GetUsageMaxHP() float64 {
	if x != nil {
		return x.UsageMaxHP
	}
	return 0
}

func (x *Settings) GetUsageBaseRxSpeedTarget() float64 {
	if x != nil {
		return x.UsageBaseRxSpeedTarget
	}
	return 0
}

func (x *Settings) GetDebug() bool {
	if x != nil {
		return x.Debug
	}
	return false
}

func (x *Settings) GetMode() Mode {
	if x != nil {
		return x.Mode
	}
	return Mode_PROGRESSIVE
}

func (x *Settings) GetPauseExpiry() *timestamppb.Timestamp {
	if x != nil {
		return x.PauseExpiry
	}
	return nil
}

type Request struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	// Types that are assignable to Message:
	//
	//	*Request_SetSettings
	//	*Request_GetState
	//	*Request_Heal
	Message isRequest_Message `protobuf_oneof:"message"`
}

func (x *Request) Reset() {
	*x = Request{}
	if protoimpl.UnsafeEnabled {
		mi := &file_proxyservice_proto_msgTypes[1]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Request) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Request) ProtoMessage() {}

func (x *Request) ProtoReflect() protoreflect.Message {
	mi := &file_proxyservice_proto_msgTypes[1]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Request.ProtoReflect.Descriptor instead.
func (*Request) Descriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{1}
}

func (m *Request) GetMessage() isRequest_Message {
	if m != nil {
		return m.Message
	}
	return nil
}

func (x *Request) GetSetSettings() *Settings {
	if x, ok := x.GetMessage().(*Request_SetSettings); ok {
		return x.SetSettings
	}
	return nil
}

func (x *Request) GetGetState() *GetStateRequest {
	if x, ok := x.GetMessage().(*Request_GetState); ok {
		return x.GetState
	}
	return nil
}

func (x *Request) GetHeal() *HealRequest {
	if x, ok := x.GetMessage().(*Request_Heal); ok {
		return x.Heal
	}
	return nil
}

type isRequest_Message interface {
	isRequest_Message()
}

type Request_SetSettings struct {
	SetSettings *Settings `protobuf:"bytes,1,opt,name=setSettings,proto3,oneof"`
}

type Request_GetState struct {
	GetState *GetStateRequest `protobuf:"bytes,2,opt,name=getState,proto3,oneof"`
}

type Request_Heal struct {
	Heal *HealRequest `protobuf:"bytes,3,opt,name=heal,proto3,oneof"`
}

func (*Request_SetSettings) isRequest_Message() {}

func (*Request_GetState) isRequest_Message() {}

func (*Request_Heal) isRequest_Message() {}

type UncaughtError struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Error string `protobuf:"bytes,1,opt,name=error,proto3" json:"error,omitempty"`
}

func (x *UncaughtError) Reset() {
	*x = UncaughtError{}
	if protoimpl.UnsafeEnabled {
		mi := &file_proxyservice_proto_msgTypes[2]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *UncaughtError) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*UncaughtError) ProtoMessage() {}

func (x *UncaughtError) ProtoReflect() protoreflect.Message {
	mi := &file_proxyservice_proto_msgTypes[2]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use UncaughtError.ProtoReflect.Descriptor instead.
func (*UncaughtError) Descriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{2}
}

func (x *UncaughtError) GetError() string {
	if x != nil {
		return x.Error
	}
	return ""
}

type SetSettingsResponse struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields
}

func (x *SetSettingsResponse) Reset() {
	*x = SetSettingsResponse{}
	if protoimpl.UnsafeEnabled {
		mi := &file_proxyservice_proto_msgTypes[3]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *SetSettingsResponse) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*SetSettingsResponse) ProtoMessage() {}

func (x *SetSettingsResponse) ProtoReflect() protoreflect.Message {
	mi := &file_proxyservice_proto_msgTypes[3]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use SetSettingsResponse.ProtoReflect.Descriptor instead.
func (*SetSettingsResponse) Descriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{3}
}

type GetStateRequest struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields
}

func (x *GetStateRequest) Reset() {
	*x = GetStateRequest{}
	if protoimpl.UnsafeEnabled {
		mi := &file_proxyservice_proto_msgTypes[4]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *GetStateRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*GetStateRequest) ProtoMessage() {}

func (x *GetStateRequest) ProtoReflect() protoreflect.Message {
	mi := &file_proxyservice_proto_msgTypes[4]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use GetStateRequest.ProtoReflect.Descriptor instead.
func (*GetStateRequest) Descriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{4}
}

type GetStateResponse struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	UsagePoints float64 `protobuf:"fixed64,1,opt,name=usagePoints,proto3" json:"usagePoints,omitempty"`
}

func (x *GetStateResponse) Reset() {
	*x = GetStateResponse{}
	if protoimpl.UnsafeEnabled {
		mi := &file_proxyservice_proto_msgTypes[5]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *GetStateResponse) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*GetStateResponse) ProtoMessage() {}

func (x *GetStateResponse) ProtoReflect() protoreflect.Message {
	mi := &file_proxyservice_proto_msgTypes[5]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use GetStateResponse.ProtoReflect.Descriptor instead.
func (*GetStateResponse) Descriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{5}
}

func (x *GetStateResponse) GetUsagePoints() float64 {
	if x != nil {
		return x.UsagePoints
	}
	return 0
}

type HealRequest struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields
}

func (x *HealRequest) Reset() {
	*x = HealRequest{}
	if protoimpl.UnsafeEnabled {
		mi := &file_proxyservice_proto_msgTypes[6]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *HealRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*HealRequest) ProtoMessage() {}

func (x *HealRequest) ProtoReflect() protoreflect.Message {
	mi := &file_proxyservice_proto_msgTypes[6]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use HealRequest.ProtoReflect.Descriptor instead.
func (*HealRequest) Descriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{6}
}

type HealResponse struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	UsagePoints float64 `protobuf:"fixed64,1,opt,name=usagePoints,proto3" json:"usagePoints,omitempty"`
}

func (x *HealResponse) Reset() {
	*x = HealResponse{}
	if protoimpl.UnsafeEnabled {
		mi := &file_proxyservice_proto_msgTypes[7]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *HealResponse) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*HealResponse) ProtoMessage() {}

func (x *HealResponse) ProtoReflect() protoreflect.Message {
	mi := &file_proxyservice_proto_msgTypes[7]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use HealResponse.ProtoReflect.Descriptor instead.
func (*HealResponse) Descriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{7}
}

func (x *HealResponse) GetUsagePoints() float64 {
	if x != nil {
		return x.UsagePoints
	}
	return 0
}

type ServerState struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Apps                     []*AppState `protobuf:"bytes,1,rep,name=apps,proto3" json:"apps,omitempty"`
	UsagePoints              float64     `protobuf:"fixed64,2,opt,name=usagePoints,proto3" json:"usagePoints,omitempty"`
	Ratio                    float64     `protobuf:"fixed64,3,opt,name=ratio,proto3" json:"ratio,omitempty"`
	ProgressiveRxSpeedTarget float64     `protobuf:"fixed64,4,opt,name=progressiveRxSpeedTarget,proto3" json:"progressiveRxSpeedTarget,omitempty"`
}

func (x *ServerState) Reset() {
	*x = ServerState{}
	if protoimpl.UnsafeEnabled {
		mi := &file_proxyservice_proto_msgTypes[8]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *ServerState) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*ServerState) ProtoMessage() {}

func (x *ServerState) ProtoReflect() protoreflect.Message {
	mi := &file_proxyservice_proto_msgTypes[8]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use ServerState.ProtoReflect.Descriptor instead.
func (*ServerState) Descriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{8}
}

func (x *ServerState) GetApps() []*AppState {
	if x != nil {
		return x.Apps
	}
	return nil
}

func (x *ServerState) GetUsagePoints() float64 {
	if x != nil {
		return x.UsagePoints
	}
	return 0
}

func (x *ServerState) GetRatio() float64 {
	if x != nil {
		return x.Ratio
	}
	return 0
}

func (x *ServerState) GetProgressiveRxSpeedTarget() float64 {
	if x != nil {
		return x.ProgressiveRxSpeedTarget
	}
	return 0
}

type AppState struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	TxPoints    float64 `protobuf:"fixed64,1,opt,name=txPoints,proto3" json:"txPoints,omitempty"`
	Name        string  `protobuf:"bytes,2,opt,name=name,proto3" json:"name,omitempty"`
	RxPoints    float64 `protobuf:"fixed64,3,opt,name=rxPoints,proto3" json:"rxPoints,omitempty"`
	TxPointsMax float64 `protobuf:"fixed64,4,opt,name=txPointsMax,proto3" json:"txPointsMax,omitempty"`
}

func (x *AppState) Reset() {
	*x = AppState{}
	if protoimpl.UnsafeEnabled {
		mi := &file_proxyservice_proto_msgTypes[9]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *AppState) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*AppState) ProtoMessage() {}

func (x *AppState) ProtoReflect() protoreflect.Message {
	mi := &file_proxyservice_proto_msgTypes[9]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use AppState.ProtoReflect.Descriptor instead.
func (*AppState) Descriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{9}
}

func (x *AppState) GetTxPoints() float64 {
	if x != nil {
		return x.TxPoints
	}
	return 0
}

func (x *AppState) GetName() string {
	if x != nil {
		return x.Name
	}
	return ""
}

func (x *AppState) GetRxPoints() float64 {
	if x != nil {
		return x.RxPoints
	}
	return 0
}

func (x *AppState) GetTxPointsMax() float64 {
	if x != nil {
		return x.TxPointsMax
	}
	return 0
}

type Sample struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Ip            string                 `protobuf:"bytes,1,opt,name=ip,proto3" json:"ip,omitempty"`
	RxBytes       int64                  `protobuf:"varint,2,opt,name=rxBytes,proto3" json:"rxBytes,omitempty"`
	StartTime     *timestamppb.Timestamp `protobuf:"bytes,3,opt,name=startTime,proto3" json:"startTime,omitempty"`
	Duration      int64                  `protobuf:"varint,4,opt,name=duration,proto3" json:"duration,omitempty"` // how long the sample
	RxSpeed       float64                `protobuf:"fixed64,5,opt,name=rxSpeed,proto3" json:"rxSpeed,omitempty"`
	RxSpeedTarget float64                `protobuf:"fixed64,6,opt,name=rxSpeedTarget,proto3" json:"rxSpeedTarget,omitempty"`
	AppMatch      string                 `protobuf:"bytes,7,opt,name=appMatch,proto3" json:"appMatch,omitempty"`
	SlowReason    string                 `protobuf:"bytes,8,opt,name=slowReason,proto3" json:"slowReason,omitempty"`
	DnsMatchers   []string               `protobuf:"bytes,9,rep,name=dnsMatchers,proto3" json:"dnsMatchers,omitempty"`
}

func (x *Sample) Reset() {
	*x = Sample{}
	if protoimpl.UnsafeEnabled {
		mi := &file_proxyservice_proto_msgTypes[10]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Sample) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Sample) ProtoMessage() {}

func (x *Sample) ProtoReflect() protoreflect.Message {
	mi := &file_proxyservice_proto_msgTypes[10]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Sample.ProtoReflect.Descriptor instead.
func (*Sample) Descriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{10}
}

func (x *Sample) GetIp() string {
	if x != nil {
		return x.Ip
	}
	return ""
}

func (x *Sample) GetRxBytes() int64 {
	if x != nil {
		return x.RxBytes
	}
	return 0
}

func (x *Sample) GetStartTime() *timestamppb.Timestamp {
	if x != nil {
		return x.StartTime
	}
	return nil
}

func (x *Sample) GetDuration() int64 {
	if x != nil {
		return x.Duration
	}
	return 0
}

func (x *Sample) GetRxSpeed() float64 {
	if x != nil {
		return x.RxSpeed
	}
	return 0
}

func (x *Sample) GetRxSpeedTarget() float64 {
	if x != nil {
		return x.RxSpeedTarget
	}
	return 0
}

func (x *Sample) GetAppMatch() string {
	if x != nil {
		return x.AppMatch
	}
	return ""
}

func (x *Sample) GetSlowReason() string {
	if x != nil {
		return x.SlowReason
	}
	return ""
}

func (x *Sample) GetDnsMatchers() []string {
	if x != nil {
		return x.DnsMatchers
	}
	return nil
}

var File_proxyservice_proto protoreflect.FileDescriptor

var file_proxyservice_proto_rawDesc = []byte{
	0x0a, 0x12, 0x70, 0x72, 0x6f, 0x78, 0x79, 0x73, 0x65, 0x72, 0x76, 0x69, 0x63, 0x65, 0x2e, 0x70,
	0x72, 0x6f, 0x74, 0x6f, 0x12, 0x0c, 0x70, 0x72, 0x6f, 0x78, 0x79, 0x73, 0x65, 0x72, 0x76, 0x69,
	0x63, 0x65, 0x1a, 0x1f, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, 0x2f, 0x70, 0x72, 0x6f, 0x74, 0x6f,
	0x62, 0x75, 0x66, 0x2f, 0x74, 0x69, 0x6d, 0x65, 0x73, 0x74, 0x61, 0x6d, 0x70, 0x2e, 0x70, 0x72,
	0x6f, 0x74, 0x6f, 0x22, 0xd8, 0x03, 0x0a, 0x08, 0x53, 0x65, 0x74, 0x74, 0x69, 0x6e, 0x67, 0x73,
	0x12, 0x18, 0x0a, 0x07, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x18, 0x04, 0x20, 0x01, 0x28,
	0x05, 0x52, 0x07, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x12, 0x2c, 0x0a, 0x11, 0x62, 0x61,
	0x73, 0x65, 0x52, 0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x54, 0x61, 0x72, 0x67, 0x65, 0x74, 0x18,
	0x01, 0x20, 0x01, 0x28, 0x01, 0x52, 0x11, 0x62, 0x61, 0x73, 0x65, 0x52, 0x78, 0x53, 0x70, 0x65,
	0x65, 0x64, 0x54, 0x61, 0x72, 0x67, 0x65, 0x74, 0x12, 0x36, 0x0a, 0x16, 0x74, 0x65, 0x6d, 0x70,
	0x6f, 0x72, 0x61, 0x72, 0x79, 0x52, 0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x54, 0x61, 0x72, 0x67,
	0x65, 0x74, 0x18, 0x02, 0x20, 0x01, 0x28, 0x01, 0x52, 0x16, 0x74, 0x65, 0x6d, 0x70, 0x6f, 0x72,
	0x61, 0x72, 0x79, 0x52, 0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x54, 0x61, 0x72, 0x67, 0x65, 0x74,
	0x12, 0x52, 0x0a, 0x16, 0x74, 0x65, 0x6d, 0x70, 0x6f, 0x72, 0x61, 0x72, 0x79, 0x52, 0x78, 0x53,
	0x70, 0x65, 0x65, 0x64, 0x45, 0x78, 0x70, 0x69, 0x72, 0x79, 0x18, 0x03, 0x20, 0x01, 0x28, 0x0b,
	0x32, 0x1a, 0x2e, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x62,
	0x75, 0x66, 0x2e, 0x54, 0x69, 0x6d, 0x65, 0x73, 0x74, 0x61, 0x6d, 0x70, 0x52, 0x16, 0x74, 0x65,
	0x6d, 0x70, 0x6f, 0x72, 0x61, 0x72, 0x79, 0x52, 0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x45, 0x78,
	0x70, 0x69, 0x72, 0x79, 0x12, 0x24, 0x0a, 0x0d, 0x75, 0x73, 0x61, 0x67, 0x65, 0x48, 0x65, 0x61,
	0x6c, 0x52, 0x61, 0x74, 0x65, 0x18, 0x05, 0x20, 0x01, 0x28, 0x01, 0x52, 0x0d, 0x75, 0x73, 0x61,
	0x67, 0x65, 0x48, 0x65, 0x61, 0x6c, 0x52, 0x61, 0x74, 0x65, 0x12, 0x1e, 0x0a, 0x0a, 0x75, 0x73,
	0x61, 0x67, 0x65, 0x4d, 0x61, 0x78, 0x48, 0x50, 0x18, 0x06, 0x20, 0x01, 0x28, 0x01, 0x52, 0x0a,
	0x75, 0x73, 0x61, 0x67, 0x65, 0x4d, 0x61, 0x78, 0x48, 0x50, 0x12, 0x36, 0x0a, 0x16, 0x75, 0x73,
	0x61, 0x67, 0x65, 0x42, 0x61, 0x73, 0x65, 0x52, 0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x54, 0x61,
	0x72, 0x67, 0x65, 0x74, 0x18, 0x09, 0x20, 0x01, 0x28, 0x01, 0x52, 0x16, 0x75, 0x73, 0x61, 0x67,
	0x65, 0x42, 0x61, 0x73, 0x65, 0x52, 0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x54, 0x61, 0x72, 0x67,
	0x65, 0x74, 0x12, 0x14, 0x0a, 0x05, 0x64, 0x65, 0x62, 0x75, 0x67, 0x18, 0x07, 0x20, 0x01, 0x28,
	0x08, 0x52, 0x05, 0x64, 0x65, 0x62, 0x75, 0x67, 0x12, 0x26, 0x0a, 0x04, 0x6d, 0x6f, 0x64, 0x65,
	0x18, 0x08, 0x20, 0x01, 0x28, 0x0e, 0x32, 0x12, 0x2e, 0x70, 0x72, 0x6f, 0x78, 0x79, 0x73, 0x65,
	0x72, 0x76, 0x69, 0x63, 0x65, 0x2e, 0x4d, 0x6f, 0x64, 0x65, 0x52, 0x04, 0x6d, 0x6f, 0x64, 0x65,
	0x12, 0x3c, 0x0a, 0x0b, 0x70, 0x61, 0x75, 0x73, 0x65, 0x45, 0x78, 0x70, 0x69, 0x72, 0x79, 0x18,
	0x0a, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x1a, 0x2e, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, 0x2e, 0x70,
	0x72, 0x6f, 0x74, 0x6f, 0x62, 0x75, 0x66, 0x2e, 0x54, 0x69, 0x6d, 0x65, 0x73, 0x74, 0x61, 0x6d,
	0x70, 0x52, 0x0b, 0x70, 0x61, 0x75, 0x73, 0x65, 0x45, 0x78, 0x70, 0x69, 0x72, 0x79, 0x22, 0xbe,
	0x01, 0x0a, 0x07, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x12, 0x3a, 0x0a, 0x0b, 0x73, 0x65,
	0x74, 0x53, 0x65, 0x74, 0x74, 0x69, 0x6e, 0x67, 0x73, 0x18, 0x01, 0x20, 0x01, 0x28, 0x0b, 0x32,
	0x16, 0x2e, 0x70, 0x72, 0x6f, 0x78, 0x79, 0x73, 0x65, 0x72, 0x76, 0x69, 0x63, 0x65, 0x2e, 0x53,
	0x65, 0x74, 0x74, 0x69, 0x6e, 0x67, 0x73, 0x48, 0x00, 0x52, 0x0b, 0x73, 0x65, 0x74, 0x53, 0x65,
	0x74, 0x74, 0x69, 0x6e, 0x67, 0x73, 0x12, 0x3b, 0x0a, 0x08, 0x67, 0x65, 0x74, 0x53, 0x74, 0x61,
	0x74, 0x65, 0x18, 0x02, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x1d, 0x2e, 0x70, 0x72, 0x6f, 0x78, 0x79,
	0x73, 0x65, 0x72, 0x76, 0x69, 0x63, 0x65, 0x2e, 0x47, 0x65, 0x74, 0x53, 0x74, 0x61, 0x74, 0x65,
	0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x48, 0x00, 0x52, 0x08, 0x67, 0x65, 0x74, 0x53, 0x74,
	0x61, 0x74, 0x65, 0x12, 0x2f, 0x0a, 0x04, 0x68, 0x65, 0x61, 0x6c, 0x18, 0x03, 0x20, 0x01, 0x28,
	0x0b, 0x32, 0x19, 0x2e, 0x70, 0x72, 0x6f, 0x78, 0x79, 0x73, 0x65, 0x72, 0x76, 0x69, 0x63, 0x65,
	0x2e, 0x48, 0x65, 0x61, 0x6c, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x48, 0x00, 0x52, 0x04,
	0x68, 0x65, 0x61, 0x6c, 0x42, 0x09, 0x0a, 0x07, 0x6d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x22,
	0x25, 0x0a, 0x0d, 0x55, 0x6e, 0x63, 0x61, 0x75, 0x67, 0x68, 0x74, 0x45, 0x72, 0x72, 0x6f, 0x72,
	0x12, 0x14, 0x0a, 0x05, 0x65, 0x72, 0x72, 0x6f, 0x72, 0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52,
	0x05, 0x65, 0x72, 0x72, 0x6f, 0x72, 0x22, 0x15, 0x0a, 0x13, 0x53, 0x65, 0x74, 0x53, 0x65, 0x74,
	0x74, 0x69, 0x6e, 0x67, 0x73, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x22, 0x11, 0x0a,
	0x0f, 0x47, 0x65, 0x74, 0x53, 0x74, 0x61, 0x74, 0x65, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74,
	0x22, 0x34, 0x0a, 0x10, 0x47, 0x65, 0x74, 0x53, 0x74, 0x61, 0x74, 0x65, 0x52, 0x65, 0x73, 0x70,
	0x6f, 0x6e, 0x73, 0x65, 0x12, 0x20, 0x0a, 0x0b, 0x75, 0x73, 0x61, 0x67, 0x65, 0x50, 0x6f, 0x69,
	0x6e, 0x74, 0x73, 0x18, 0x01, 0x20, 0x01, 0x28, 0x01, 0x52, 0x0b, 0x75, 0x73, 0x61, 0x67, 0x65,
	0x50, 0x6f, 0x69, 0x6e, 0x74, 0x73, 0x22, 0x0d, 0x0a, 0x0b, 0x48, 0x65, 0x61, 0x6c, 0x52, 0x65,
	0x71, 0x75, 0x65, 0x73, 0x74, 0x22, 0x30, 0x0a, 0x0c, 0x48, 0x65, 0x61, 0x6c, 0x52, 0x65, 0x73,
	0x70, 0x6f, 0x6e, 0x73, 0x65, 0x12, 0x20, 0x0a, 0x0b, 0x75, 0x73, 0x61, 0x67, 0x65, 0x50, 0x6f,
	0x69, 0x6e, 0x74, 0x73, 0x18, 0x01, 0x20, 0x01, 0x28, 0x01, 0x52, 0x0b, 0x75, 0x73, 0x61, 0x67,
	0x65, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x73, 0x22, 0xad, 0x01, 0x0a, 0x0b, 0x53, 0x65, 0x72, 0x76,
	0x65, 0x72, 0x53, 0x74, 0x61, 0x74, 0x65, 0x12, 0x2a, 0x0a, 0x04, 0x61, 0x70, 0x70, 0x73, 0x18,
	0x01, 0x20, 0x03, 0x28, 0x0b, 0x32, 0x16, 0x2e, 0x70, 0x72, 0x6f, 0x78, 0x79, 0x73, 0x65, 0x72,
	0x76, 0x69, 0x63, 0x65, 0x2e, 0x41, 0x70, 0x70, 0x53, 0x74, 0x61, 0x74, 0x65, 0x52, 0x04, 0x61,
	0x70, 0x70, 0x73, 0x12, 0x20, 0x0a, 0x0b, 0x75, 0x73, 0x61, 0x67, 0x65, 0x50, 0x6f, 0x69, 0x6e,
	0x74, 0x73, 0x18, 0x02, 0x20, 0x01, 0x28, 0x01, 0x52, 0x0b, 0x75, 0x73, 0x61, 0x67, 0x65, 0x50,
	0x6f, 0x69, 0x6e, 0x74, 0x73, 0x12, 0x14, 0x0a, 0x05, 0x72, 0x61, 0x74, 0x69, 0x6f, 0x18, 0x03,
	0x20, 0x01, 0x28, 0x01, 0x52, 0x05, 0x72, 0x61, 0x74, 0x69, 0x6f, 0x12, 0x3a, 0x0a, 0x18, 0x70,
	0x72, 0x6f, 0x67, 0x72, 0x65, 0x73, 0x73, 0x69, 0x76, 0x65, 0x52, 0x78, 0x53, 0x70, 0x65, 0x65,
	0x64, 0x54, 0x61, 0x72, 0x67, 0x65, 0x74, 0x18, 0x04, 0x20, 0x01, 0x28, 0x01, 0x52, 0x18, 0x70,
	0x72, 0x6f, 0x67, 0x72, 0x65, 0x73, 0x73, 0x69, 0x76, 0x65, 0x52, 0x78, 0x53, 0x70, 0x65, 0x65,
	0x64, 0x54, 0x61, 0x72, 0x67, 0x65, 0x74, 0x22, 0x78, 0x0a, 0x08, 0x41, 0x70, 0x70, 0x53, 0x74,
	0x61, 0x74, 0x65, 0x12, 0x1a, 0x0a, 0x08, 0x74, 0x78, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x73, 0x18,
	0x01, 0x20, 0x01, 0x28, 0x01, 0x52, 0x08, 0x74, 0x78, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x73, 0x12,
	0x12, 0x0a, 0x04, 0x6e, 0x61, 0x6d, 0x65, 0x18, 0x02, 0x20, 0x01, 0x28, 0x09, 0x52, 0x04, 0x6e,
	0x61, 0x6d, 0x65, 0x12, 0x1a, 0x0a, 0x08, 0x72, 0x78, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x73, 0x18,
	0x03, 0x20, 0x01, 0x28, 0x01, 0x52, 0x08, 0x72, 0x78, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x73, 0x12,
	0x20, 0x0a, 0x0b, 0x74, 0x78, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x73, 0x4d, 0x61, 0x78, 0x18, 0x04,
	0x20, 0x01, 0x28, 0x01, 0x52, 0x0b, 0x74, 0x78, 0x50, 0x6f, 0x69, 0x6e, 0x74, 0x73, 0x4d, 0x61,
	0x78, 0x22, 0xa6, 0x02, 0x0a, 0x06, 0x53, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x12, 0x0e, 0x0a, 0x02,
	0x69, 0x70, 0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x02, 0x69, 0x70, 0x12, 0x18, 0x0a, 0x07,
	0x72, 0x78, 0x42, 0x79, 0x74, 0x65, 0x73, 0x18, 0x02, 0x20, 0x01, 0x28, 0x03, 0x52, 0x07, 0x72,
	0x78, 0x42, 0x79, 0x74, 0x65, 0x73, 0x12, 0x38, 0x0a, 0x09, 0x73, 0x74, 0x61, 0x72, 0x74, 0x54,
	0x69, 0x6d, 0x65, 0x18, 0x03, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x1a, 0x2e, 0x67, 0x6f, 0x6f, 0x67,
	0x6c, 0x65, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x62, 0x75, 0x66, 0x2e, 0x54, 0x69, 0x6d, 0x65,
	0x73, 0x74, 0x61, 0x6d, 0x70, 0x52, 0x09, 0x73, 0x74, 0x61, 0x72, 0x74, 0x54, 0x69, 0x6d, 0x65,
	0x12, 0x1a, 0x0a, 0x08, 0x64, 0x75, 0x72, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x18, 0x04, 0x20, 0x01,
	0x28, 0x03, 0x52, 0x08, 0x64, 0x75, 0x72, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x12, 0x18, 0x0a, 0x07,
	0x72, 0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x18, 0x05, 0x20, 0x01, 0x28, 0x01, 0x52, 0x07, 0x72,
	0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x12, 0x24, 0x0a, 0x0d, 0x72, 0x78, 0x53, 0x70, 0x65, 0x65,
	0x64, 0x54, 0x61, 0x72, 0x67, 0x65, 0x74, 0x18, 0x06, 0x20, 0x01, 0x28, 0x01, 0x52, 0x0d, 0x72,
	0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x54, 0x61, 0x72, 0x67, 0x65, 0x74, 0x12, 0x1a, 0x0a, 0x08,
	0x61, 0x70, 0x70, 0x4d, 0x61, 0x74, 0x63, 0x68, 0x18, 0x07, 0x20, 0x01, 0x28, 0x09, 0x52, 0x08,
	0x61, 0x70, 0x70, 0x4d, 0x61, 0x74, 0x63, 0x68, 0x12, 0x1e, 0x0a, 0x0a, 0x73, 0x6c, 0x6f, 0x77,
	0x52, 0x65, 0x61, 0x73, 0x6f, 0x6e, 0x18, 0x08, 0x20, 0x01, 0x28, 0x09, 0x52, 0x0a, 0x73, 0x6c,
	0x6f, 0x77, 0x52, 0x65, 0x61, 0x73, 0x6f, 0x6e, 0x12, 0x20, 0x0a, 0x0b, 0x64, 0x6e, 0x73, 0x4d,
	0x61, 0x74, 0x63, 0x68, 0x65, 0x72, 0x73, 0x18, 0x09, 0x20, 0x03, 0x28, 0x09, 0x52, 0x0b, 0x64,
	0x6e, 0x73, 0x4d, 0x61, 0x74, 0x63, 0x68, 0x65, 0x72, 0x73, 0x2a, 0x22, 0x0a, 0x04, 0x4d, 0x6f,
	0x64, 0x65, 0x12, 0x0f, 0x0a, 0x0b, 0x50, 0x52, 0x4f, 0x47, 0x52, 0x45, 0x53, 0x53, 0x49, 0x56,
	0x45, 0x10, 0x00, 0x12, 0x09, 0x0a, 0x05, 0x46, 0x4f, 0x43, 0x55, 0x53, 0x10, 0x01, 0x42, 0x11,
	0x5a, 0x0f, 0x70, 0x62, 0x2f, 0x70, 0x72, 0x6f, 0x78, 0x79, 0x73, 0x65, 0x72, 0x76, 0x69, 0x63,
	0x65, 0x62, 0x06, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x33,
}

var (
	file_proxyservice_proto_rawDescOnce sync.Once
	file_proxyservice_proto_rawDescData = file_proxyservice_proto_rawDesc
)

func file_proxyservice_proto_rawDescGZIP() []byte {
	file_proxyservice_proto_rawDescOnce.Do(func() {
		file_proxyservice_proto_rawDescData = protoimpl.X.CompressGZIP(file_proxyservice_proto_rawDescData)
	})
	return file_proxyservice_proto_rawDescData
}

var file_proxyservice_proto_enumTypes = make([]protoimpl.EnumInfo, 1)
var file_proxyservice_proto_msgTypes = make([]protoimpl.MessageInfo, 11)
var file_proxyservice_proto_goTypes = []interface{}{
	(Mode)(0),                     // 0: proxyservice.Mode
	(*Settings)(nil),              // 1: proxyservice.Settings
	(*Request)(nil),               // 2: proxyservice.Request
	(*UncaughtError)(nil),         // 3: proxyservice.UncaughtError
	(*SetSettingsResponse)(nil),   // 4: proxyservice.SetSettingsResponse
	(*GetStateRequest)(nil),       // 5: proxyservice.GetStateRequest
	(*GetStateResponse)(nil),      // 6: proxyservice.GetStateResponse
	(*HealRequest)(nil),           // 7: proxyservice.HealRequest
	(*HealResponse)(nil),          // 8: proxyservice.HealResponse
	(*ServerState)(nil),           // 9: proxyservice.ServerState
	(*AppState)(nil),              // 10: proxyservice.AppState
	(*Sample)(nil),                // 11: proxyservice.Sample
	(*timestamppb.Timestamp)(nil), // 12: google.protobuf.Timestamp
}
var file_proxyservice_proto_depIdxs = []int32{
	12, // 0: proxyservice.Settings.temporaryRxSpeedExpiry:type_name -> google.protobuf.Timestamp
	0,  // 1: proxyservice.Settings.mode:type_name -> proxyservice.Mode
	12, // 2: proxyservice.Settings.pauseExpiry:type_name -> google.protobuf.Timestamp
	1,  // 3: proxyservice.Request.setSettings:type_name -> proxyservice.Settings
	5,  // 4: proxyservice.Request.getState:type_name -> proxyservice.GetStateRequest
	7,  // 5: proxyservice.Request.heal:type_name -> proxyservice.HealRequest
	10, // 6: proxyservice.ServerState.apps:type_name -> proxyservice.AppState
	12, // 7: proxyservice.Sample.startTime:type_name -> google.protobuf.Timestamp
	8,  // [8:8] is the sub-list for method output_type
	8,  // [8:8] is the sub-list for method input_type
	8,  // [8:8] is the sub-list for extension type_name
	8,  // [8:8] is the sub-list for extension extendee
	0,  // [0:8] is the sub-list for field type_name
}

func init() { file_proxyservice_proto_init() }
func file_proxyservice_proto_init() {
	if File_proxyservice_proto != nil {
		return
	}
	if !protoimpl.UnsafeEnabled {
		file_proxyservice_proto_msgTypes[0].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Settings); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_proxyservice_proto_msgTypes[1].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Request); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_proxyservice_proto_msgTypes[2].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*UncaughtError); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_proxyservice_proto_msgTypes[3].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*SetSettingsResponse); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_proxyservice_proto_msgTypes[4].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*GetStateRequest); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_proxyservice_proto_msgTypes[5].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*GetStateResponse); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_proxyservice_proto_msgTypes[6].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*HealRequest); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_proxyservice_proto_msgTypes[7].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*HealResponse); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_proxyservice_proto_msgTypes[8].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*ServerState); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_proxyservice_proto_msgTypes[9].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*AppState); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_proxyservice_proto_msgTypes[10].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Sample); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
	}
	file_proxyservice_proto_msgTypes[1].OneofWrappers = []interface{}{
		(*Request_SetSettings)(nil),
		(*Request_GetState)(nil),
		(*Request_Heal)(nil),
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: file_proxyservice_proto_rawDesc,
			NumEnums:      1,
			NumMessages:   11,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_proxyservice_proto_goTypes,
		DependencyIndexes: file_proxyservice_proto_depIdxs,
		EnumInfos:         file_proxyservice_proto_enumTypes,
		MessageInfos:      file_proxyservice_proto_msgTypes,
	}.Build()
	File_proxyservice_proto = out.File
	file_proxyservice_proto_rawDesc = nil
	file_proxyservice_proto_goTypes = nil
	file_proxyservice_proto_depIdxs = nil
}
