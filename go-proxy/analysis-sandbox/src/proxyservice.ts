/* eslint-disable */
import * as Long from "long";
import * as _m0 from "protobufjs/minimal";
import { Timestamp } from "./google/protobuf/timestamp";

export const protobufPackage = "proxyservice";

export enum Mode {
  PROGRESSIVE = 0,
  FOCUS = 1,
  UNRECOGNIZED = -1,
}

export function modeFromJSON(object: any): Mode {
  switch (object) {
    case 0:
    case "PROGRESSIVE":
      return Mode.PROGRESSIVE;
    case 1:
    case "FOCUS":
      return Mode.FOCUS;
    case -1:
    case "UNRECOGNIZED":
    default:
      return Mode.UNRECOGNIZED;
  }
}

export function modeToJSON(object: Mode): string {
  switch (object) {
    case Mode.PROGRESSIVE:
      return "PROGRESSIVE";
    case Mode.FOCUS:
      return "FOCUS";
    case Mode.UNRECOGNIZED:
    default:
      return "UNRECOGNIZED";
  }
}

export interface Preset {
  /**
   * Behavior mode of the preset.
   * TODO: switch to oneof
   */
  mode: Mode;
  /** Base speed in "Focus mode" */
  baseRxSpeedTarget: number;
  /** Break speed. Use Infinity to indicate no speed capping. */
  temporaryRxSpeedTarget: number;
  /**
   * When a break should end.
   * TODO: move to a State message
   */
  temporaryRxSpeedExpiry:
    | Date
    | undefined;
  /** How fast healing should happen. */
  usageHealRate: number;
  /** How long a user should be able to scroll. */
  usageMaxHP: number;
  /** A maximum speed to govern scrolling traffic. */
  usageBaseRxSpeedTarget: number;
  /** ID of the preset */
  id: string;
  trafficRules: TrafficRules | undefined;
}

/** Rules for slowing down */
export interface TrafficRules {
  /** repeated string app_ids = 1; */
  matchAllTraffic: boolean;
}

export interface Overlay {
  preset: Preset | undefined;
  expiry: Date | undefined;
}

export interface Settings {
  /**
   * A version used for migrations of this message.
   * Latest version: 2
   */
  version: number;
  debug: boolean;
  /** Parameters of the active preset. */
  defaultPreset:
    | Preset
    | undefined;
  /** Overlay preset */
  overlay: Overlay | undefined;
  parachutePreset:
    | Preset
    | undefined;
  /** Tracks the last change to the settings. */
  changeMetadata: ChangeMetadata | undefined;
}

export interface ChangeMetadata {
  id: string;
}

export interface Request {
  setSettings?: Settings | undefined;
  getState?: GetStateRequest | undefined;
  heal?: HealRequest | undefined;
}

export interface SetSettingsResponse {
}

export interface GetStateRequest {
}

export interface GetStateResponse {
  usagePoints: number;
}

export interface HealRequest {
}

export interface HealResponse {
  usagePoints: number;
}

export interface ServerState {
  apps: AppState[];
  usagePoints: number;
  ratio: number;
  progressiveRxSpeedTarget: number;
}

export interface AppState {
  txPoints: number;
  name: string;
  rxPoints: number;
  txPointsMax: number;
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
  slowReason: string;
  dnsMatchers: string[];
}

function createBasePreset(): Preset {
  return {
    mode: 0,
    baseRxSpeedTarget: 0,
    temporaryRxSpeedTarget: 0,
    temporaryRxSpeedExpiry: undefined,
    usageHealRate: 0,
    usageMaxHP: 0,
    usageBaseRxSpeedTarget: 0,
    id: "",
    trafficRules: undefined,
  };
}

export const Preset = {
  encode(message: Preset, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.mode !== 0) {
      writer.uint32(16).int32(message.mode);
    }
    if (message.baseRxSpeedTarget !== 0) {
      writer.uint32(25).double(message.baseRxSpeedTarget);
    }
    if (message.temporaryRxSpeedTarget !== 0) {
      writer.uint32(33).double(message.temporaryRxSpeedTarget);
    }
    if (message.temporaryRxSpeedExpiry !== undefined) {
      Timestamp.encode(toTimestamp(message.temporaryRxSpeedExpiry), writer.uint32(42).fork()).ldelim();
    }
    if (message.usageHealRate !== 0) {
      writer.uint32(49).double(message.usageHealRate);
    }
    if (message.usageMaxHP !== 0) {
      writer.uint32(57).double(message.usageMaxHP);
    }
    if (message.usageBaseRxSpeedTarget !== 0) {
      writer.uint32(65).double(message.usageBaseRxSpeedTarget);
    }
    if (message.id !== "") {
      writer.uint32(82).string(message.id);
    }
    if (message.trafficRules !== undefined) {
      TrafficRules.encode(message.trafficRules, writer.uint32(90).fork()).ldelim();
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): Preset {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBasePreset();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 2:
          message.mode = reader.int32() as any;
          break;
        case 3:
          message.baseRxSpeedTarget = reader.double();
          break;
        case 4:
          message.temporaryRxSpeedTarget = reader.double();
          break;
        case 5:
          message.temporaryRxSpeedExpiry = fromTimestamp(Timestamp.decode(reader, reader.uint32()));
          break;
        case 6:
          message.usageHealRate = reader.double();
          break;
        case 7:
          message.usageMaxHP = reader.double();
          break;
        case 8:
          message.usageBaseRxSpeedTarget = reader.double();
          break;
        case 10:
          message.id = reader.string();
          break;
        case 11:
          message.trafficRules = TrafficRules.decode(reader, reader.uint32());
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): Preset {
    return {
      mode: isSet(object.mode) ? modeFromJSON(object.mode) : 0,
      baseRxSpeedTarget: isSet(object.baseRxSpeedTarget) ? Number(object.baseRxSpeedTarget) : 0,
      temporaryRxSpeedTarget: isSet(object.temporaryRxSpeedTarget) ? Number(object.temporaryRxSpeedTarget) : 0,
      temporaryRxSpeedExpiry: isSet(object.temporaryRxSpeedExpiry)
        ? fromJsonTimestamp(object.temporaryRxSpeedExpiry)
        : undefined,
      usageHealRate: isSet(object.usageHealRate) ? Number(object.usageHealRate) : 0,
      usageMaxHP: isSet(object.usageMaxHP) ? Number(object.usageMaxHP) : 0,
      usageBaseRxSpeedTarget: isSet(object.usageBaseRxSpeedTarget) ? Number(object.usageBaseRxSpeedTarget) : 0,
      id: isSet(object.id) ? String(object.id) : "",
      trafficRules: isSet(object.trafficRules) ? TrafficRules.fromJSON(object.trafficRules) : undefined,
    };
  },

  toJSON(message: Preset): unknown {
    const obj: any = {};
    message.mode !== undefined && (obj.mode = modeToJSON(message.mode));
    message.baseRxSpeedTarget !== undefined && (obj.baseRxSpeedTarget = message.baseRxSpeedTarget);
    message.temporaryRxSpeedTarget !== undefined && (obj.temporaryRxSpeedTarget = message.temporaryRxSpeedTarget);
    message.temporaryRxSpeedExpiry !== undefined &&
      (obj.temporaryRxSpeedExpiry = message.temporaryRxSpeedExpiry.toISOString());
    message.usageHealRate !== undefined && (obj.usageHealRate = message.usageHealRate);
    message.usageMaxHP !== undefined && (obj.usageMaxHP = message.usageMaxHP);
    message.usageBaseRxSpeedTarget !== undefined && (obj.usageBaseRxSpeedTarget = message.usageBaseRxSpeedTarget);
    message.id !== undefined && (obj.id = message.id);
    message.trafficRules !== undefined &&
      (obj.trafficRules = message.trafficRules ? TrafficRules.toJSON(message.trafficRules) : undefined);
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<Preset>, I>>(object: I): Preset {
    const message = createBasePreset();
    message.mode = object.mode ?? 0;
    message.baseRxSpeedTarget = object.baseRxSpeedTarget ?? 0;
    message.temporaryRxSpeedTarget = object.temporaryRxSpeedTarget ?? 0;
    message.temporaryRxSpeedExpiry = object.temporaryRxSpeedExpiry ?? undefined;
    message.usageHealRate = object.usageHealRate ?? 0;
    message.usageMaxHP = object.usageMaxHP ?? 0;
    message.usageBaseRxSpeedTarget = object.usageBaseRxSpeedTarget ?? 0;
    message.id = object.id ?? "";
    message.trafficRules = (object.trafficRules !== undefined && object.trafficRules !== null)
      ? TrafficRules.fromPartial(object.trafficRules)
      : undefined;
    return message;
  },
};

function createBaseTrafficRules(): TrafficRules {
  return { matchAllTraffic: false };
}

export const TrafficRules = {
  encode(message: TrafficRules, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.matchAllTraffic === true) {
      writer.uint32(8).bool(message.matchAllTraffic);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): TrafficRules {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseTrafficRules();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.matchAllTraffic = reader.bool();
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): TrafficRules {
    return { matchAllTraffic: isSet(object.matchAllTraffic) ? Boolean(object.matchAllTraffic) : false };
  },

  toJSON(message: TrafficRules): unknown {
    const obj: any = {};
    message.matchAllTraffic !== undefined && (obj.matchAllTraffic = message.matchAllTraffic);
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<TrafficRules>, I>>(object: I): TrafficRules {
    const message = createBaseTrafficRules();
    message.matchAllTraffic = object.matchAllTraffic ?? false;
    return message;
  },
};

function createBaseOverlay(): Overlay {
  return { preset: undefined, expiry: undefined };
}

export const Overlay = {
  encode(message: Overlay, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.preset !== undefined) {
      Preset.encode(message.preset, writer.uint32(10).fork()).ldelim();
    }
    if (message.expiry !== undefined) {
      Timestamp.encode(toTimestamp(message.expiry), writer.uint32(18).fork()).ldelim();
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): Overlay {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseOverlay();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.preset = Preset.decode(reader, reader.uint32());
          break;
        case 2:
          message.expiry = fromTimestamp(Timestamp.decode(reader, reader.uint32()));
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): Overlay {
    return {
      preset: isSet(object.preset) ? Preset.fromJSON(object.preset) : undefined,
      expiry: isSet(object.expiry) ? fromJsonTimestamp(object.expiry) : undefined,
    };
  },

  toJSON(message: Overlay): unknown {
    const obj: any = {};
    message.preset !== undefined && (obj.preset = message.preset ? Preset.toJSON(message.preset) : undefined);
    message.expiry !== undefined && (obj.expiry = message.expiry.toISOString());
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<Overlay>, I>>(object: I): Overlay {
    const message = createBaseOverlay();
    message.preset = (object.preset !== undefined && object.preset !== null)
      ? Preset.fromPartial(object.preset)
      : undefined;
    message.expiry = object.expiry ?? undefined;
    return message;
  },
};

function createBaseSettings(): Settings {
  return {
    version: 0,
    debug: false,
    defaultPreset: undefined,
    overlay: undefined,
    parachutePreset: undefined,
    changeMetadata: undefined,
  };
}

export const Settings = {
  encode(message: Settings, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.version !== 0) {
      writer.uint32(32).int32(message.version);
    }
    if (message.debug === true) {
      writer.uint32(56).bool(message.debug);
    }
    if (message.defaultPreset !== undefined) {
      Preset.encode(message.defaultPreset, writer.uint32(90).fork()).ldelim();
    }
    if (message.overlay !== undefined) {
      Overlay.encode(message.overlay, writer.uint32(98).fork()).ldelim();
    }
    if (message.parachutePreset !== undefined) {
      Preset.encode(message.parachutePreset, writer.uint32(114).fork()).ldelim();
    }
    if (message.changeMetadata !== undefined) {
      ChangeMetadata.encode(message.changeMetadata, writer.uint32(122).fork()).ldelim();
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
        case 4:
          message.version = reader.int32();
          break;
        case 7:
          message.debug = reader.bool();
          break;
        case 11:
          message.defaultPreset = Preset.decode(reader, reader.uint32());
          break;
        case 12:
          message.overlay = Overlay.decode(reader, reader.uint32());
          break;
        case 14:
          message.parachutePreset = Preset.decode(reader, reader.uint32());
          break;
        case 15:
          message.changeMetadata = ChangeMetadata.decode(reader, reader.uint32());
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
      version: isSet(object.version) ? Number(object.version) : 0,
      debug: isSet(object.debug) ? Boolean(object.debug) : false,
      defaultPreset: isSet(object.defaultPreset) ? Preset.fromJSON(object.defaultPreset) : undefined,
      overlay: isSet(object.overlay) ? Overlay.fromJSON(object.overlay) : undefined,
      parachutePreset: isSet(object.parachutePreset) ? Preset.fromJSON(object.parachutePreset) : undefined,
      changeMetadata: isSet(object.changeMetadata) ? ChangeMetadata.fromJSON(object.changeMetadata) : undefined,
    };
  },

  toJSON(message: Settings): unknown {
    const obj: any = {};
    message.version !== undefined && (obj.version = Math.round(message.version));
    message.debug !== undefined && (obj.debug = message.debug);
    message.defaultPreset !== undefined &&
      (obj.defaultPreset = message.defaultPreset ? Preset.toJSON(message.defaultPreset) : undefined);
    message.overlay !== undefined && (obj.overlay = message.overlay ? Overlay.toJSON(message.overlay) : undefined);
    message.parachutePreset !== undefined &&
      (obj.parachutePreset = message.parachutePreset ? Preset.toJSON(message.parachutePreset) : undefined);
    message.changeMetadata !== undefined &&
      (obj.changeMetadata = message.changeMetadata ? ChangeMetadata.toJSON(message.changeMetadata) : undefined);
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<Settings>, I>>(object: I): Settings {
    const message = createBaseSettings();
    message.version = object.version ?? 0;
    message.debug = object.debug ?? false;
    message.defaultPreset = (object.defaultPreset !== undefined && object.defaultPreset !== null)
      ? Preset.fromPartial(object.defaultPreset)
      : undefined;
    message.overlay = (object.overlay !== undefined && object.overlay !== null)
      ? Overlay.fromPartial(object.overlay)
      : undefined;
    message.parachutePreset = (object.parachutePreset !== undefined && object.parachutePreset !== null)
      ? Preset.fromPartial(object.parachutePreset)
      : undefined;
    message.changeMetadata = (object.changeMetadata !== undefined && object.changeMetadata !== null)
      ? ChangeMetadata.fromPartial(object.changeMetadata)
      : undefined;
    return message;
  },
};

function createBaseChangeMetadata(): ChangeMetadata {
  return { id: "" };
}

export const ChangeMetadata = {
  encode(message: ChangeMetadata, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.id !== "") {
      writer.uint32(10).string(message.id);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): ChangeMetadata {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseChangeMetadata();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.id = reader.string();
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): ChangeMetadata {
    return { id: isSet(object.id) ? String(object.id) : "" };
  },

  toJSON(message: ChangeMetadata): unknown {
    const obj: any = {};
    message.id !== undefined && (obj.id = message.id);
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<ChangeMetadata>, I>>(object: I): ChangeMetadata {
    const message = createBaseChangeMetadata();
    message.id = object.id ?? "";
    return message;
  },
};

function createBaseRequest(): Request {
  return { setSettings: undefined, getState: undefined, heal: undefined };
}

export const Request = {
  encode(message: Request, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.setSettings !== undefined) {
      Settings.encode(message.setSettings, writer.uint32(10).fork()).ldelim();
    }
    if (message.getState !== undefined) {
      GetStateRequest.encode(message.getState, writer.uint32(18).fork()).ldelim();
    }
    if (message.heal !== undefined) {
      HealRequest.encode(message.heal, writer.uint32(26).fork()).ldelim();
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
          message.getState = GetStateRequest.decode(reader, reader.uint32());
          break;
        case 3:
          message.heal = HealRequest.decode(reader, reader.uint32());
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
      getState: isSet(object.getState) ? GetStateRequest.fromJSON(object.getState) : undefined,
      heal: isSet(object.heal) ? HealRequest.fromJSON(object.heal) : undefined,
    };
  },

  toJSON(message: Request): unknown {
    const obj: any = {};
    message.setSettings !== undefined &&
      (obj.setSettings = message.setSettings ? Settings.toJSON(message.setSettings) : undefined);
    message.getState !== undefined &&
      (obj.getState = message.getState ? GetStateRequest.toJSON(message.getState) : undefined);
    message.heal !== undefined && (obj.heal = message.heal ? HealRequest.toJSON(message.heal) : undefined);
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<Request>, I>>(object: I): Request {
    const message = createBaseRequest();
    message.setSettings = (object.setSettings !== undefined && object.setSettings !== null)
      ? Settings.fromPartial(object.setSettings)
      : undefined;
    message.getState = (object.getState !== undefined && object.getState !== null)
      ? GetStateRequest.fromPartial(object.getState)
      : undefined;
    message.heal = (object.heal !== undefined && object.heal !== null)
      ? HealRequest.fromPartial(object.heal)
      : undefined;
    return message;
  },
};

function createBaseSetSettingsResponse(): SetSettingsResponse {
  return {};
}

export const SetSettingsResponse = {
  encode(_: SetSettingsResponse, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): SetSettingsResponse {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseSetSettingsResponse();
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

  fromJSON(_: any): SetSettingsResponse {
    return {};
  },

  toJSON(_: SetSettingsResponse): unknown {
    const obj: any = {};
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<SetSettingsResponse>, I>>(_: I): SetSettingsResponse {
    const message = createBaseSetSettingsResponse();
    return message;
  },
};

function createBaseGetStateRequest(): GetStateRequest {
  return {};
}

export const GetStateRequest = {
  encode(_: GetStateRequest, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): GetStateRequest {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseGetStateRequest();
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

  fromJSON(_: any): GetStateRequest {
    return {};
  },

  toJSON(_: GetStateRequest): unknown {
    const obj: any = {};
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<GetStateRequest>, I>>(_: I): GetStateRequest {
    const message = createBaseGetStateRequest();
    return message;
  },
};

function createBaseGetStateResponse(): GetStateResponse {
  return { usagePoints: 0 };
}

export const GetStateResponse = {
  encode(message: GetStateResponse, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.usagePoints !== 0) {
      writer.uint32(9).double(message.usagePoints);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): GetStateResponse {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseGetStateResponse();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.usagePoints = reader.double();
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): GetStateResponse {
    return { usagePoints: isSet(object.usagePoints) ? Number(object.usagePoints) : 0 };
  },

  toJSON(message: GetStateResponse): unknown {
    const obj: any = {};
    message.usagePoints !== undefined && (obj.usagePoints = message.usagePoints);
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<GetStateResponse>, I>>(object: I): GetStateResponse {
    const message = createBaseGetStateResponse();
    message.usagePoints = object.usagePoints ?? 0;
    return message;
  },
};

function createBaseHealRequest(): HealRequest {
  return {};
}

export const HealRequest = {
  encode(_: HealRequest, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): HealRequest {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseHealRequest();
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

  fromJSON(_: any): HealRequest {
    return {};
  },

  toJSON(_: HealRequest): unknown {
    const obj: any = {};
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<HealRequest>, I>>(_: I): HealRequest {
    const message = createBaseHealRequest();
    return message;
  },
};

function createBaseHealResponse(): HealResponse {
  return { usagePoints: 0 };
}

export const HealResponse = {
  encode(message: HealResponse, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.usagePoints !== 0) {
      writer.uint32(9).double(message.usagePoints);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): HealResponse {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseHealResponse();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.usagePoints = reader.double();
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): HealResponse {
    return { usagePoints: isSet(object.usagePoints) ? Number(object.usagePoints) : 0 };
  },

  toJSON(message: HealResponse): unknown {
    const obj: any = {};
    message.usagePoints !== undefined && (obj.usagePoints = message.usagePoints);
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<HealResponse>, I>>(object: I): HealResponse {
    const message = createBaseHealResponse();
    message.usagePoints = object.usagePoints ?? 0;
    return message;
  },
};

function createBaseServerState(): ServerState {
  return { apps: [], usagePoints: 0, ratio: 0, progressiveRxSpeedTarget: 0 };
}

export const ServerState = {
  encode(message: ServerState, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    for (const v of message.apps) {
      AppState.encode(v!, writer.uint32(10).fork()).ldelim();
    }
    if (message.usagePoints !== 0) {
      writer.uint32(17).double(message.usagePoints);
    }
    if (message.ratio !== 0) {
      writer.uint32(25).double(message.ratio);
    }
    if (message.progressiveRxSpeedTarget !== 0) {
      writer.uint32(33).double(message.progressiveRxSpeedTarget);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): ServerState {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseServerState();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.apps.push(AppState.decode(reader, reader.uint32()));
          break;
        case 2:
          message.usagePoints = reader.double();
          break;
        case 3:
          message.ratio = reader.double();
          break;
        case 4:
          message.progressiveRxSpeedTarget = reader.double();
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): ServerState {
    return {
      apps: Array.isArray(object?.apps) ? object.apps.map((e: any) => AppState.fromJSON(e)) : [],
      usagePoints: isSet(object.usagePoints) ? Number(object.usagePoints) : 0,
      ratio: isSet(object.ratio) ? Number(object.ratio) : 0,
      progressiveRxSpeedTarget: isSet(object.progressiveRxSpeedTarget) ? Number(object.progressiveRxSpeedTarget) : 0,
    };
  },

  toJSON(message: ServerState): unknown {
    const obj: any = {};
    if (message.apps) {
      obj.apps = message.apps.map((e) => e ? AppState.toJSON(e) : undefined);
    } else {
      obj.apps = [];
    }
    message.usagePoints !== undefined && (obj.usagePoints = message.usagePoints);
    message.ratio !== undefined && (obj.ratio = message.ratio);
    message.progressiveRxSpeedTarget !== undefined && (obj.progressiveRxSpeedTarget = message.progressiveRxSpeedTarget);
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<ServerState>, I>>(object: I): ServerState {
    const message = createBaseServerState();
    message.apps = object.apps?.map((e) => AppState.fromPartial(e)) || [];
    message.usagePoints = object.usagePoints ?? 0;
    message.ratio = object.ratio ?? 0;
    message.progressiveRxSpeedTarget = object.progressiveRxSpeedTarget ?? 0;
    return message;
  },
};

function createBaseAppState(): AppState {
  return { txPoints: 0, name: "", rxPoints: 0, txPointsMax: 0 };
}

export const AppState = {
  encode(message: AppState, writer: _m0.Writer = _m0.Writer.create()): _m0.Writer {
    if (message.txPoints !== 0) {
      writer.uint32(9).double(message.txPoints);
    }
    if (message.name !== "") {
      writer.uint32(18).string(message.name);
    }
    if (message.rxPoints !== 0) {
      writer.uint32(25).double(message.rxPoints);
    }
    if (message.txPointsMax !== 0) {
      writer.uint32(33).double(message.txPointsMax);
    }
    return writer;
  },

  decode(input: _m0.Reader | Uint8Array, length?: number): AppState {
    const reader = input instanceof _m0.Reader ? input : new _m0.Reader(input);
    let end = length === undefined ? reader.len : reader.pos + length;
    const message = createBaseAppState();
    while (reader.pos < end) {
      const tag = reader.uint32();
      switch (tag >>> 3) {
        case 1:
          message.txPoints = reader.double();
          break;
        case 2:
          message.name = reader.string();
          break;
        case 3:
          message.rxPoints = reader.double();
          break;
        case 4:
          message.txPointsMax = reader.double();
          break;
        default:
          reader.skipType(tag & 7);
          break;
      }
    }
    return message;
  },

  fromJSON(object: any): AppState {
    return {
      txPoints: isSet(object.txPoints) ? Number(object.txPoints) : 0,
      name: isSet(object.name) ? String(object.name) : "",
      rxPoints: isSet(object.rxPoints) ? Number(object.rxPoints) : 0,
      txPointsMax: isSet(object.txPointsMax) ? Number(object.txPointsMax) : 0,
    };
  },

  toJSON(message: AppState): unknown {
    const obj: any = {};
    message.txPoints !== undefined && (obj.txPoints = message.txPoints);
    message.name !== undefined && (obj.name = message.name);
    message.rxPoints !== undefined && (obj.rxPoints = message.rxPoints);
    message.txPointsMax !== undefined && (obj.txPointsMax = message.txPointsMax);
    return obj;
  },

  fromPartial<I extends Exact<DeepPartial<AppState>, I>>(object: I): AppState {
    const message = createBaseAppState();
    message.txPoints = object.txPoints ?? 0;
    message.name = object.name ?? "";
    message.rxPoints = object.rxPoints ?? 0;
    message.txPointsMax = object.txPointsMax ?? 0;
    return message;
  },
};

function createBaseSample(): Sample {
  return {
    ip: "",
    rxBytes: 0,
    startTime: undefined,
    duration: 0,
    rxSpeed: 0,
    rxSpeedTarget: 0,
    appMatch: "",
    slowReason: "",
    dnsMatchers: [],
  };
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
    if (message.slowReason !== "") {
      writer.uint32(66).string(message.slowReason);
    }
    for (const v of message.dnsMatchers) {
      writer.uint32(74).string(v!);
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
        case 8:
          message.slowReason = reader.string();
          break;
        case 9:
          message.dnsMatchers.push(reader.string());
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
      slowReason: isSet(object.slowReason) ? String(object.slowReason) : "",
      dnsMatchers: Array.isArray(object?.dnsMatchers) ? object.dnsMatchers.map((e: any) => String(e)) : [],
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
    message.slowReason !== undefined && (obj.slowReason = message.slowReason);
    if (message.dnsMatchers) {
      obj.dnsMatchers = message.dnsMatchers.map((e) => e);
    } else {
      obj.dnsMatchers = [];
    }
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
    message.slowReason = object.slowReason ?? "";
    message.dnsMatchers = object.dnsMatchers?.map((e) => e) || [];
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
