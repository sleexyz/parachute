// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.28.1
// 	protoc        v3.20.3
// source: proxyservice.proto

package proxyservice

import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

type Settings struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	BaseRxSpeedTarget float64 `protobuf:"fixed64,1,opt,name=baseRxSpeedTarget,proto3" json:"baseRxSpeedTarget,omitempty"`
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

func (x *Settings) GetBaseRxSpeedTarget() float64 {
	if x != nil {
		return x.BaseRxSpeedTarget
	}
	return 0
}

type Request struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	// Types that are assignable to Message:
	//
	//	*Request_SetSettings
	//	*Request_SetTemporaryRxSpeedTarget
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

func (x *Request) GetSetTemporaryRxSpeedTarget() *SetTemporaryRxSpeedTargetRequest {
	if x, ok := x.GetMessage().(*Request_SetTemporaryRxSpeedTarget); ok {
		return x.SetTemporaryRxSpeedTarget
	}
	return nil
}

type isRequest_Message interface {
	isRequest_Message()
}

type Request_SetSettings struct {
	SetSettings *Settings `protobuf:"bytes,1,opt,name=setSettings,proto3,oneof"`
}

type Request_SetTemporaryRxSpeedTarget struct {
	SetTemporaryRxSpeedTarget *SetTemporaryRxSpeedTargetRequest `protobuf:"bytes,2,opt,name=setTemporaryRxSpeedTarget,proto3,oneof"`
}

func (*Request_SetSettings) isRequest_Message() {}

func (*Request_SetTemporaryRxSpeedTarget) isRequest_Message() {}

type SetTemporaryRxSpeedTargetRequest struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Speed    float64 `protobuf:"fixed64,1,opt,name=speed,proto3" json:"speed,omitempty"`
	Duration int32   `protobuf:"varint,2,opt,name=duration,proto3" json:"duration,omitempty"`
}

func (x *SetTemporaryRxSpeedTargetRequest) Reset() {
	*x = SetTemporaryRxSpeedTargetRequest{}
	if protoimpl.UnsafeEnabled {
		mi := &file_proxyservice_proto_msgTypes[2]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *SetTemporaryRxSpeedTargetRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*SetTemporaryRxSpeedTargetRequest) ProtoMessage() {}

func (x *SetTemporaryRxSpeedTargetRequest) ProtoReflect() protoreflect.Message {
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

// Deprecated: Use SetTemporaryRxSpeedTargetRequest.ProtoReflect.Descriptor instead.
func (*SetTemporaryRxSpeedTargetRequest) Descriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{2}
}

func (x *SetTemporaryRxSpeedTargetRequest) GetSpeed() float64 {
	if x != nil {
		return x.Speed
	}
	return 0
}

func (x *SetTemporaryRxSpeedTargetRequest) GetDuration() int32 {
	if x != nil {
		return x.Duration
	}
	return 0
}

type Sample struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Ip        string `protobuf:"bytes,1,opt,name=ip,proto3" json:"ip,omitempty"`
	RxBytes   int64  `protobuf:"varint,2,opt,name=rxBytes,proto3" json:"rxBytes,omitempty"`
	StartTime int64  `protobuf:"varint,3,opt,name=startTime,proto3" json:"startTime,omitempty"`
	Duration  int32  `protobuf:"varint,4,opt,name=duration,proto3" json:"duration,omitempty"` // how long the sample
}

func (x *Sample) Reset() {
	*x = Sample{}
	if protoimpl.UnsafeEnabled {
		mi := &file_proxyservice_proto_msgTypes[3]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Sample) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Sample) ProtoMessage() {}

func (x *Sample) ProtoReflect() protoreflect.Message {
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

// Deprecated: Use Sample.ProtoReflect.Descriptor instead.
func (*Sample) Descriptor() ([]byte, []int) {
	return file_proxyservice_proto_rawDescGZIP(), []int{3}
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

func (x *Sample) GetStartTime() int64 {
	if x != nil {
		return x.StartTime
	}
	return 0
}

func (x *Sample) GetDuration() int32 {
	if x != nil {
		return x.Duration
	}
	return 0
}

var File_proxyservice_proto protoreflect.FileDescriptor

var file_proxyservice_proto_rawDesc = []byte{
	0x0a, 0x12, 0x70, 0x72, 0x6f, 0x78, 0x79, 0x73, 0x65, 0x72, 0x76, 0x69, 0x63, 0x65, 0x2e, 0x70,
	0x72, 0x6f, 0x74, 0x6f, 0x12, 0x0c, 0x70, 0x72, 0x6f, 0x78, 0x79, 0x73, 0x65, 0x72, 0x76, 0x69,
	0x63, 0x65, 0x22, 0x38, 0x0a, 0x08, 0x53, 0x65, 0x74, 0x74, 0x69, 0x6e, 0x67, 0x73, 0x12, 0x2c,
	0x0a, 0x11, 0x62, 0x61, 0x73, 0x65, 0x52, 0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x54, 0x61, 0x72,
	0x67, 0x65, 0x74, 0x18, 0x01, 0x20, 0x01, 0x28, 0x01, 0x52, 0x11, 0x62, 0x61, 0x73, 0x65, 0x52,
	0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x54, 0x61, 0x72, 0x67, 0x65, 0x74, 0x22, 0xc0, 0x01, 0x0a,
	0x07, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x12, 0x3a, 0x0a, 0x0b, 0x73, 0x65, 0x74, 0x53,
	0x65, 0x74, 0x74, 0x69, 0x6e, 0x67, 0x73, 0x18, 0x01, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x16, 0x2e,
	0x70, 0x72, 0x6f, 0x78, 0x79, 0x73, 0x65, 0x72, 0x76, 0x69, 0x63, 0x65, 0x2e, 0x53, 0x65, 0x74,
	0x74, 0x69, 0x6e, 0x67, 0x73, 0x48, 0x00, 0x52, 0x0b, 0x73, 0x65, 0x74, 0x53, 0x65, 0x74, 0x74,
	0x69, 0x6e, 0x67, 0x73, 0x12, 0x6e, 0x0a, 0x19, 0x73, 0x65, 0x74, 0x54, 0x65, 0x6d, 0x70, 0x6f,
	0x72, 0x61, 0x72, 0x79, 0x52, 0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x54, 0x61, 0x72, 0x67, 0x65,
	0x74, 0x18, 0x02, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x2e, 0x2e, 0x70, 0x72, 0x6f, 0x78, 0x79, 0x73,
	0x65, 0x72, 0x76, 0x69, 0x63, 0x65, 0x2e, 0x53, 0x65, 0x74, 0x54, 0x65, 0x6d, 0x70, 0x6f, 0x72,
	0x61, 0x72, 0x79, 0x52, 0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x54, 0x61, 0x72, 0x67, 0x65, 0x74,
	0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x48, 0x00, 0x52, 0x19, 0x73, 0x65, 0x74, 0x54, 0x65,
	0x6d, 0x70, 0x6f, 0x72, 0x61, 0x72, 0x79, 0x52, 0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x54, 0x61,
	0x72, 0x67, 0x65, 0x74, 0x42, 0x09, 0x0a, 0x07, 0x6d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x22,
	0x54, 0x0a, 0x20, 0x53, 0x65, 0x74, 0x54, 0x65, 0x6d, 0x70, 0x6f, 0x72, 0x61, 0x72, 0x79, 0x52,
	0x78, 0x53, 0x70, 0x65, 0x65, 0x64, 0x54, 0x61, 0x72, 0x67, 0x65, 0x74, 0x52, 0x65, 0x71, 0x75,
	0x65, 0x73, 0x74, 0x12, 0x14, 0x0a, 0x05, 0x73, 0x70, 0x65, 0x65, 0x64, 0x18, 0x01, 0x20, 0x01,
	0x28, 0x01, 0x52, 0x05, 0x73, 0x70, 0x65, 0x65, 0x64, 0x12, 0x1a, 0x0a, 0x08, 0x64, 0x75, 0x72,
	0x61, 0x74, 0x69, 0x6f, 0x6e, 0x18, 0x02, 0x20, 0x01, 0x28, 0x05, 0x52, 0x08, 0x64, 0x75, 0x72,
	0x61, 0x74, 0x69, 0x6f, 0x6e, 0x22, 0x6c, 0x0a, 0x06, 0x53, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x12,
	0x0e, 0x0a, 0x02, 0x69, 0x70, 0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x02, 0x69, 0x70, 0x12,
	0x18, 0x0a, 0x07, 0x72, 0x78, 0x42, 0x79, 0x74, 0x65, 0x73, 0x18, 0x02, 0x20, 0x01, 0x28, 0x03,
	0x52, 0x07, 0x72, 0x78, 0x42, 0x79, 0x74, 0x65, 0x73, 0x12, 0x1c, 0x0a, 0x09, 0x73, 0x74, 0x61,
	0x72, 0x74, 0x54, 0x69, 0x6d, 0x65, 0x18, 0x03, 0x20, 0x01, 0x28, 0x03, 0x52, 0x09, 0x73, 0x74,
	0x61, 0x72, 0x74, 0x54, 0x69, 0x6d, 0x65, 0x12, 0x1a, 0x0a, 0x08, 0x64, 0x75, 0x72, 0x61, 0x74,
	0x69, 0x6f, 0x6e, 0x18, 0x04, 0x20, 0x01, 0x28, 0x05, 0x52, 0x08, 0x64, 0x75, 0x72, 0x61, 0x74,
	0x69, 0x6f, 0x6e, 0x42, 0x11, 0x5a, 0x0f, 0x70, 0x62, 0x2f, 0x70, 0x72, 0x6f, 0x78, 0x79, 0x73,
	0x65, 0x72, 0x76, 0x69, 0x63, 0x65, 0x62, 0x06, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x33,
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

var file_proxyservice_proto_msgTypes = make([]protoimpl.MessageInfo, 4)
var file_proxyservice_proto_goTypes = []interface{}{
	(*Settings)(nil),                         // 0: proxyservice.Settings
	(*Request)(nil),                          // 1: proxyservice.Request
	(*SetTemporaryRxSpeedTargetRequest)(nil), // 2: proxyservice.SetTemporaryRxSpeedTargetRequest
	(*Sample)(nil),                           // 3: proxyservice.Sample
}
var file_proxyservice_proto_depIdxs = []int32{
	0, // 0: proxyservice.Request.setSettings:type_name -> proxyservice.Settings
	2, // 1: proxyservice.Request.setTemporaryRxSpeedTarget:type_name -> proxyservice.SetTemporaryRxSpeedTargetRequest
	2, // [2:2] is the sub-list for method output_type
	2, // [2:2] is the sub-list for method input_type
	2, // [2:2] is the sub-list for extension type_name
	2, // [2:2] is the sub-list for extension extendee
	0, // [0:2] is the sub-list for field type_name
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
			switch v := v.(*SetTemporaryRxSpeedTargetRequest); i {
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
		(*Request_SetTemporaryRxSpeedTarget)(nil),
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: file_proxyservice_proto_rawDesc,
			NumEnums:      0,
			NumMessages:   4,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_proxyservice_proto_goTypes,
		DependencyIndexes: file_proxyservice_proto_depIdxs,
		MessageInfos:      file_proxyservice_proto_msgTypes,
	}.Build()
	File_proxyservice_proto = out.File
	file_proxyservice_proto_rawDesc = nil
	file_proxyservice_proto_goTypes = nil
	file_proxyservice_proto_depIdxs = nil
}
