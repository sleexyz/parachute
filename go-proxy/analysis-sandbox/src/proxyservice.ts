/* eslint-disable */
import * as Long from "long";
import * as _m0 from "protobufjs/minimal";
import { Timestamp } from "./google/protobuf/timestamp";

export const protobufPackage = "proxyservice";

export interface Settings {
  baseRxSpeedTarget: number;
  useExponentialDecay: boolean;
}

export interface Request {
  setSettings?: Settings | undefined;
  setTemporaryRxSpeedTarget?: SetTemporaryRxSpeedTargetRequest | undefined;
  resetPoints?: ResetPointsRequest | undefined;
}

export interface ResetPointsRequest {
}

export interface SetTemporaryRxSpeedTargetRequest {
  speed: number;
  duration: number;
}

export interface Sample {
  ip: string;
  rxBytes: number;
  startTime:
    | Date
    | undefined;
  /** how long the sample */
  duration: number;
  rxSpeed: number;
  rxSpeedTarget: number;
  appMatch: string;
}

function createBaseSettings(): Settings {
  return { baseRxSpeedTarget: 0, useExponentialDecay: false };
}

export const Settings = {
  encode(message: Settings, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.baseRxSpeedTarget !== 0) {
      writer.uint32(9).double(message.baseRxSpeedTarget);
    }
    if (message.useExponentialDecay === true) {
      writer.uint32(16).bool(message.useExponentialDecay);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): Settings {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseSettings();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.baseRxSpeedTarget = reader.double();
          break;
        case 2:
          message.useExponentialDecay = reader.bool();
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): Settings {
    return {
      baseRxSpeedTarget: isSet(object.baseRxSpeedTarget) ? Number(object.baseRxSpeedTarget) : 0,
      useExponentialDecay: isSet(object.useExponentialDecay) ? Boolean(object.useExponentialDecay) : false,
    };
  },

  toJSON(message: Settings): unknown {
    const obj: any = {};
    message.baseRxSpeedTarget !== undefined && (obj.baseRxSpeedTarget = message.baseRxSpeedTarget);
    message.useExponentialDecay !== undefined && (obj.useExponentialDecay = message.useExponentialDecay);
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<Settings>, I>>(object: I): Settings {
    const message = createBaseSettings();
    message.baseRxSpeedTarget = object.baseRxSpeedTarget ?? 0;
    message.useExponentialDecay = object.useExponentialDecay ?? false;
    return message;
  },
};

function createBaseRequest(): Request {
  return { setSettings: undefined, setTemporaryRxSpeedTarget: undefined, resetPoints: undefined };
}

export const Request = {
  encode(message: Request, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.setSettings !== undefined) {
      Settings.encode(message.setSettings, writer.uint32(10).fork()).ldelim();
    }
    if (message.setTemporaryRxSpeedTarget !== undefined) {
      SetTemporaryRxSpeedTargetRequest.encode(message.setTemporaryRxSpeedTarget, writer.uint32(18).fork()).ldelim();
    }
    if (message.resetPoints !== undefined) {
      ResetPointsRequest.encode(message.resetPoints, writer.uint32(26).fork()).ldelim();
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): Request {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseRequest();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.setSettings = Settings.decode(reader, reader.uint32());
          break;
        case 2:
          message.setTemporaryRxSpeedTarget = SetTemporaryRxSpeedTargetRequest.decode(reader, reader.uint32());
          break;
        case 3:
          message.resetPoints = ResetPointsRequest.decode(reader, reader.uint32());
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): Request {
    return {
      setSettings: isSet(object.setSettings) ? Settings.fromJSON(object.setSettings) : undefined,
      setTemporaryRxSpeedTarget: isSet(object.setTemporaryRxSpeedTarget)
        ? SetTemporaryRxSpeedTargetRequest.fromJSON(object.setTemporaryRxSpeedTarget)
        : undefined,
      resetPoints: isSet(object.resetPoints) ? ResetPointsRequest.fromJSON(object.resetPoints) : undefined,
    };
  },

  toJSON(message: Request): unknown {
    const obj: any = {};
    message.setSettings !== undefined &&
      (obj.setSettings = message.setSettings ? Settings.toJSON(message.setSettings) : undefined);
    message.setTemporaryRxSpeedTarget !== undefined &&
      (obj.setTemporaryRxSpeedTarget = message.setTemporaryRxSpeedTarget
        ? SetTemporaryRxSpeedTargetRequest.toJSON(message.setTemporaryRxSpeedTarget)
        : undefined);
    message.resetPoints !== undefined &&
      (obj.resetPoints = message.resetPoints ? ResetPointsRequest.toJSON(message.resetPoints) : undefined);
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<Request>, I>>(object: I): Request {
    const message = createBaseRequest();
    message.setSettings = (object.setSettings !== undefined && object.setSettings !== null)
      ? Settings.fromPartial(object.setSettings)
      : undefined;
    message.setTemporaryRxSpeedTarget =
      (object.setTemporaryRxSpeedTarget !== undefined && object.setTemporaryRxSpeedTarget !== null)
        ? SetTemporaryRxSpeedTargetRequest.fromPartial(object.setTemporaryRxSpeedTarget)
        : undefined;
    message.resetPoints = (object.resetPoints !== undefined && object.resetPoints !== null)
      ? ResetPointsRequest.fromPartial(object.resetPoints)
      : undefined;
    return message;
  },
};

function createBaseResetPointsRequest(): ResetPointsRequest {
  return {};
}

export const ResetPointsRequest = {
  encode(_: ResetPointsRequest, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): ResetPointsRequest {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseResetPointsRequest();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(_: any): ResetPointsRequest {
    return {};
  },

  toJSON(_: ResetPointsRequest): unknown {
    const obj: any = {};
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<ResetPointsRequest>, I>>(_: I): ResetPointsRequest {
    const message = createBaseResetPointsRequest();
    return message;
  },
};

function createBaseSetTemporaryRxSpeedTargetRequest(): SetTemporaryRxSpeedTargetRequest {
  return { speed: 0, duration: 0 };
}

export const SetTemporaryRxSpeedTargetRequest = {
  encode(message: SetTemporaryRxSpeedTargetRequest, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.speed !== 0) {
      writer.uint32(9).double(message.speed);
    }
    if (message.duration !== 0) {
      writer.uint32(16).int32(message.duration);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): SetTemporaryRxSpeedTargetRequest {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseSetTemporaryRxSpeedTargetRequest();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.speed = reader.double();
          break;
        case 2:
          message.duration = reader.int32();
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): SetTemporaryRxSpeedTargetRequest {
    return {
      speed: isSet(object.speed) ? Number(object.speed) : 0,
      duration: isSet(object.duration) ? Number(object.duration) : 0,
    };
  },

  toJSON(message: SetTemporaryRxSpeedTargetRequest): unknown {
    const obj: any = {};
    message.speed !== undefined && (obj.speed = message.speed);
    message.duration !== undefined && (obj.duration = Math.round(message.duration));
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<SetTemporaryRxSpeedTargetRequest>, I>>(
    object: I,
  ): SetTemporaryRxSpeedTargetRequest {
    const message = createBaseSetTemporaryRxSpeedTargetRequest();
    message.speed = object.speed ?? 0;
    message.duration = object.duration ?? 0;
    return message;
  },
};

function createBaseSample(): Sample {
  return { ip: "", rxBytes: 0, startTime: undefined, duration: 0, rxSpeed: 0, rxSpeedTarget: 0, appMatch: "" };
}

export const Sample = {
  encode(message: Sample, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.ip !== "") {
      writer.uint32(10).string(message.ip);
    }
    if (message.rxBytes !== 0) {
      writer.uint32(16).int64(message.rxBytes);
    }
    if (message.startTime !== undefined) {
      Timestamp.encode(toTimestamp(message.startTime), writer.uint32(26).fork()).ldelim();
    }
    if (message.duration !== 0) {
      writer.uint32(32).int64(message.duration);
    }
    if (message.rxSpeed !== 0) {
      writer.uint32(41).double(message.rxSpeed);
    }
    if (message.rxSpeedTarget !== 0) {
      writer.uint32(49).double(message.rxSpeedTarget);
    }
    if (message.appMatch !== "") {
      writer.uint32(58).string(message.appMatch);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): Sample {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseSample();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.ip = reader.string();
          break;
        case 2:
          message.rxBytes = longToNumber(reader.int64() as Long);
          break;
        case 3:
          message.startTime = fromTimestamp(Timestamp.decode(reader, reader.uint32()));
          break;
        case 4:
          message.duration = longToNumber(reader.int64() as Long);
          break;
        case 5:
          message.rxSpeed = reader.double();
          break;
        case 6:
          message.rxSpeedTarget = reader.double();
          break;
        case 7:
          message.appMatch = reader.string();
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): Sample {
    return {
      ip: isSet(object.ip) ? String(object.ip) : "",
      rxBytes: isSet(object.rxBytes) ? Number(object.rxBytes) : 0,
      startTime: isSet(object.startTime) ? fromJsonTimestamp(object.startTime) : undefined,
      duration: isSet(object.duration) ? Number(object.duration) : 0,
      rxSpeed: isSet(object.rxSpeed) ? Number(object.rxSpeed) : 0,
      rxSpeedTarget: isSet(object.rxSpeedTarget) ? Number(object.rxSpeedTarget) : 0,
      appMatch: isSet(object.appMatch) ? String(object.appMatch) : "",
    };
  },

  toJSON(message: Sample): unknown {
    const obj: any = {};
    message.ip !== undefined && (obj.ip = message.ip);
    message.rxBytes !== undefined && (obj.rxBytes = Math.round(message.rxBytes));
    message.startTime !== undefined && (obj.startTime = message.startTime.toISOString());
    message.duration !== undefined && (obj.duration = Math.round(message.duration));
    message.rxSpeed !== undefined && (obj.rxSpeed = message.rxSpeed);
    message.rxSpeedTarget !== undefined && (obj.rxSpeedTarget = message.rxSpeedTarget);
    message.appMatch !== undefined && (obj.appMatch = message.appMatch);
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<Sample>, I>>(object: I): Sample {
    const message = createBaseSample();
    message.ip = object.ip ?? "";
    message.rxBytes = object.rxBytes ?? 0;
    message.startTime = object.startTime ?? undefined;
    message.duration = object.duration ?? 0;
    message.rxSpeed = object.rxSpeed ?? 0;
    message.rxSpeedTarget = object.rxSpeedTarget ?? 0;
    message.appMatch = object.appMatch ?? "";
    return message;
  },
};

declare var self: any | undefined;
declare var window: any | undefined;
declare var global: any | undefined;
var tsProtoGlobalThis: any = (() => {
  if (typeof globalThis !== "undefined") {
    return globalThis;
  }
  if (typeof self !== "undefined") {
    return self;
  }
  if (typeof window !== "undefined") {
    return window;
  }
  if (typeof global !== "undefined") {
    return global;
  }
  throw "Unable to locate global object";
})();

type Builtin = Date | Function | Uint8Array | string | number | boolean | undefined;

export type DeepPartial<T> = T extends Builtin ? T
  : T extends Array<infer U> ? Array<DeepPartial<U>> : T extends ReadonlyArray<infer U> ? ReadonlyArray<DeepPartial<U>>
  : T extends {} ? { [K in keyof T]?: DeepPartial<T[K]> }
  : Partial<T>;

type KeysOfUnion<T> = T extends T ? keyof T : never;
export type Exact<P, I extends P> = P extends Builtin ? P
  : P & { [K in keyof P]: Exact<P[K], I[K]> } & { [K in Exclude<keyof I, KeysOfUnion<P>>]: never };

function toTimestamp(date: Date): Timestamp {
  const seconds = date.getTime() / 1_000;
  const nanos = (date.getTime() % 1_000) * 1_000_000;
  return { seconds, nanos };
}

function fromTimestamp(t: Timestamp): Date {
  let millis = t.seconds * 1_000;
  millis += t.nanos / 1_000_000;
  return new Date(millis);
}

function fromJsonTimestamp(o: any): Date {
  if (o instanceof Date) {
    return o;
  } else if (typeof o === "string") {
    return new Date(o);
  } else {
    return fromTimestamp(Timestamp.fromJSON(o));
  }
}

function longToNumber(long: Long): number {
  if (long.gt(Number.MAX_SAFE_INTEGER)) {
    throw new tsProtoGlobalThis.Error("Value is larger than Number.MAX_SAFE_INTEGER");
  }
  return long.toNumber();
}

// If you get a compile-error about 'Constructor<Long> and ... have no overlap',
// add '--ts_proto_opt=esModuleInterop=true' as a flag when calling 'protoc'.
if (_m0.util.Long !== Long) {
  _m0.util.Long = Long as any;
  _m0.configure();
}

function isSet(value: any): boolean {
  return value !== null && value !== undefined;
}
