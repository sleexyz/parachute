import React, { useEffect, useMemo, useState } from "react";
import "./App.css";
import { Client } from "./client";
import { Flow, FlowMap } from "./flowmap";
import { fdateToPoints } from "./frecency";



function App() {
  const flowmap = FlowMap.use();
  flowmap.installFlowMapHandlers();
  const map = flowmap.map.use();
  console.log(map);

  return (
    <div className="App">
      <Controls />
      <div className="Card">
        {Object.values(map).sort(sortByFdate).map((flow) => {
          return <FlowDiv key={flow.ip} value={flow} />;
        })}
      </div>
    </div>
  );
}

function Controls() {
  const flowmap = FlowMap.use();

  const clear = React.useCallback(() => {
    flowmap.clear();
  }, [flowmap]);

  return (<div>
    <button onClick={clear}>Clear</button>
    </div>);
}

function sortByFdate(a: Flow, b: Flow): number {
  return b.fdate - a.fdate;
}

function useHighlightOnChange(deps: [any]) {
  const [t, setT] = useState<number|null>(null);
  useEffect(() => {
    if (t != null) {
      window.clearTimeout(t);
    }
    setT(window.setTimeout(() =>{
      setT(null)
      if (t != null) {
        window.clearTimeout(t);
      }
    }, 500));
  }, deps);
  return t != null
}

function FlowDiv(props: { value: Flow }) {
  const shouldHighlight = useHighlightOnChange([props.value])

  const className = `debug-pre ${shouldHighlight ? 'highlight' : ''}`;
  return (
    <pre className={className}>
      <div> ip: {props.value.ip} </div>
      <div> rxBytes: {props.value.rxBytes} </div>
      <div> fdate: {props.value.fdate.toISOString()} </div>
      <div> points: {fdateToPoints(props.value.fdate)} </div>
    </pre>
  );
}

function Providers(props: { children?: React.ReactNode }) {
  return (
    <Client.Provider>
      <FlowMap.Provider>{props.children}</FlowMap.Provider>
    </Client.Provider>
  );
}

export default () => {
  return (
    <Providers>
      <App />
    </Providers>
  );
};
