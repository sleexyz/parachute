import { useEffect, useRef } from "react";
import { AppState } from "./proxyservice";
import { ServerStateController } from "./serverstate";
import { useHighlightOnChange } from "./utils";

export function ServerStateView() {
  const ssc = ServerStateController.dep.use();
  const serverState = ssc.state.use();
  return <div>{serverState.apps.map(app => <AppView key={app.name} value={app} />)}</div>
}

function AppView(props: {value: AppState}) {
  const lastValue = usePrevious(props.value.txPoints, 0)
//   const shouldHighlight = useHighlightOnChange([props.value > 1]);
  const className = `debug-pre ${props.value.txPoints > lastValue ? "highlight" : ""}`;
    return <pre className={className}>{JSON.stringify(props.value, null, 2)}</pre>
}


function usePrevious<T>(value: T, firstValue: T): T {
  // The ref object is a generic container whose current property is mutable ...
  // ... and can hold any value, similar to an instance property on a class
  const ref = useRef(firstValue);
  // Store current value in ref
  useEffect(() => {
    ref.current = value;
  }, [value]); // Only re-run if value changes
  // Return previous value (happens before update in useEffect above)
  return ref.current;
}