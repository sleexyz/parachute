import { AppState } from "./proxyservice";
import { ServerStateController } from "./serverstate";
import { useHighlightOnChange } from "./utils";

export function ServerStateView() {
  const ssc = ServerStateController.dep.use();
  const serverState = ssc.state.use();
  return <div>{serverState.apps.map(app => <AppView key={app.name} value={app} />)}</div>
}

function AppView(props: {value: AppState}) {
//   const shouldHighlight = useHighlightOnChange([props.value > 1]);
  const className = `debug-pre ${props.value.points > 1 ? "highlight" : ""}`;
    return <pre className={className}>{JSON.stringify(props.value, null, 2)}</pre>
}
