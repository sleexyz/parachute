import {  useEffect, useMemo } from "react";
import { EventSourceClient, } from "./client";
import { pointsToFdate, updateFdate } from "./frecency";
import { Sample } from "./proxyservice";
import { Atom, makeDep } from "./utils";

export interface Flow extends Sample {
  fdate: Date;
}

export class FlowMap {
  map: Atom<Record<string, Flow>> = new Atom({});
  constructor(readonly client: EventSourceClient<Sample>) {}

  static dep = makeDep(() => {
      const client = EventSourceClient.samplesDep.use();
      return useMemo(() => new FlowMap(client), [client]);
  });

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
    let pointsToAdd = 1;
    if (flow == undefined) {
      this.map.set({
        ...this.map.get(),
        [sample.ip]: { ...sample , fdate: pointsToFdate(pointsToAdd)},
      });
    } else {
      this.map.set({
        ...this.map.get(),
        [sample.ip]: {
          ...flow,
          ...sample,
          fdate: updateFdate(flow.fdate, pointsToAdd),
          rxBytes: flow.rxBytes + sample.rxBytes,
        },
      });
    }
  };
}
