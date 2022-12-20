import { useContext, useMemo } from "react";
import { Sample } from "./proxyservice";
import { createEmptyContext } from "./utils";

export class Client {
  evtSource = new EventSource("http://localhost:8084/events?stream=samples");
  subscribeFns = new Set<(sample: Sample) => void>();

  constructor() {
    this.evtSource.onmessage = (event) => {
      const message = JSON.parse(event.data);
      const sample = Sample.fromJSON(message);
      for (let fn of this.subscribeFns) {
        fn(sample);
      }
    };
  }
  addSubscriber(fn: (sample: Sample) => void) {
    this.subscribeFns.add(fn);
  }
  removeSubscriber(fn: (sample: Sample) => void) {
    this.subscribeFns.delete(fn);
  }

  static context = createEmptyContext<Client>();
  static use(): Client {
    return useContext(Client.context);
  }
  static Provider(props: { children: React.ReactNode }) {
    const value = useMemo(() => new Client(), []);
    return (
      <Client.context.Provider value={value}>
        {props.children}
      </Client.context.Provider>
    );
  }
}