import { useContext, useEffect, useMemo } from "react";
import { EventSourceClient} from "./client";
import { ServerState } from "./proxyservice";
import { Atom, makeDep } from "./utils";

export class ServerStateController {
  state: Atom<ServerState> = new Atom(ServerState.fromPartial({}));
  constructor(readonly client: EventSourceClient<ServerState>) {}

  static dep = makeDep(() => {
      const client = EventSourceClient.serverDep.use();
      const value = useMemo(() => new ServerStateController(client), [client]);
      value.init();
      return value;
  });

  init() {
    useEffect(() => {
      this.client.addSubscriber(this.ingestUpdate);
      return () => {
        this.client.removeSubscriber(this.ingestUpdate);
      };
    }, [this.client]);
  }

  ingestUpdate = (state: ServerState) => {
    this.state.set(state)
  };
}
