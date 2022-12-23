import { useMemo } from "react";
import { Sample, ServerState } from "./proxyservice";
import { makeDep } from "./utils";

export class EventSourceClient<T> {
  subscribeFns = new Set<(sample: T) => void>();

  constructor(
    readonly evtSource: EventSource,
    deserialize: (data: unknown) => T
  ) {
    this.evtSource.onmessage = (event) => {
      const message = JSON.parse(event.data);
      const sample = deserialize(message);
      for (let fn of this.subscribeFns) {
        fn(sample);
      }
    };
  }

  static samplesDep = makeDep(() => {
    return useMemo(
      () =>
        new EventSourceClient(
          new EventSource("http://localhost:8084/events?stream=samples"),
          Sample.fromJSON
        ),
      []
    );
  });

  static serverDep = makeDep(() => {
    return useMemo(
      () =>
        new EventSourceClient(
          new EventSource("http://localhost:8084/events?stream=server"),
          ServerState.fromJSON
        ),
      []
    );
  });

  addSubscriber(fn: (sample: T) => void) {
    this.subscribeFns.add(fn);
  }
  removeSubscriber(fn: (sample: T) => void) {
    this.subscribeFns.delete(fn);
  }
}
