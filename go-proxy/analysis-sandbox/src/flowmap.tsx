import { useContext, useEffect, useMemo } from "react";
import { Client } from "./client";
import { pointsToFdate, updateFdate } from "./frecency";
import { Sample } from "./proxyservice";
import { Atom, createEmptyContext } from "./utils";

export interface Flow extends Sample{
}

export class FlowMap {
  map: Atom<Record<string, Flow>> = new Atom({});
  constructor(readonly client: Client) {}

  static context = createEmptyContext<FlowMap>();
  static Provider(props: { children: React.ReactNode }) {
    const client = Client.use();
    const flowMap = useMemo(() => new FlowMap(client), [client]);
    return (
      <FlowMap.context.Provider value={flowMap}>
        {props.children}
      </FlowMap.context.Provider>
    );
  }

  static use(): FlowMap {
    return useContext(FlowMap.context);
  }

  clear() {
    this.map.set({});
  }

  installFlowMapHandlers() {
    useEffect(() => {
      this.client.addSubscriber(this.ingestSample);
      return () => {
        this.client.removeSubscriber(this.ingestSample);
      };
    });
  }

  ingestSample = (sample: Sample) => {
    let flow = this.map.get()[sample.ip];
    let pointsToAdd = sample.rxBytes / 10000;
    if (flow == undefined) {
      this.map.set({
        ...this.map.get(),
        [sample.ip]: { ...sample },
      });
    } else {
      this.map.set({
        ...this.map.get(),
        [sample.ip]: { ...flow, ...sample, rxBytes: flow.rxBytes + sample.rxBytes },
      });
    }
  };
}
