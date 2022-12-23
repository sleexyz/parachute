import React, { useEffect, useMemo, useState } from "react";
import "./App.css";
import { EventSourceClient } from "./client";
import { Flow, FlowMap } from "./flowmap";
import { fdateToPoints } from "./frecency";
import { ServerStateController } from "./serverstate";
import { ServerStateView } from "./ServerStateView";
import { useHighlightOnChange } from "./utils";

function App() {
  const flowmap = FlowMap.dep.use();
  flowmap.installFlowMapHandlers();
  const map = flowmap.map.use();

  return (
    <div className="App">
      <ServerStateView />
      <Controls />
      <div className="Card">
        {Object.values(map)
          .sort(sortByFdate)
          .map((flow) => {
            return <FlowDiv key={flow.ip} value={flow} />;
          })}
      </div>
    </div>
  );
}

function Controls() {
  const flowmap = FlowMap.dep.use();

  const clear = React.useCallback(() => {
    flowmap.clear();
  }, [flowmap]);

  return (
    <div>
      <button onClick={clear}>Clear</button>
    </div>
  );
}

function sortByStartTime(a: Flow, b: Flow): number {
  return b.startTime - a.startTime;
}

function sortByFdate(a: Flow, b: Flow): number {
  return b.fdate - a.fdate;
}

function FlowDiv(props: { value: Flow }) {
  const shouldHighlight = useHighlightOnChange([props.value.rxSpeedTarget]);
  const className = `debug-pre ${shouldHighlight ? "highlight" : ""}`;
  if (props.value.rxSpeedTarget != Infinity) {
    return null
  }
  return (
    <pre className={className}>
      {JSON.stringify(
        {
          ...props.value,
          ip: undefined,
          fdate: undefined,
          points: fdateToPoints(props.value.fdate),
          rxSpeed: undefined,
          rxSpeedTarget: undefined,
          duration: undefined,
          startTime: undefined,
        },
        null,
        2
      )}
    </pre>
  );
}

const deps = [
  ...[ServerStateController.dep, EventSourceClient.serverDep],
  ...[FlowMap.dep, EventSourceClient.samplesDep],
];

function Providers(props: { children?: React.ReactNode }): JSX.Element {
  let elem = props.children;
  for (let dep of deps) {
    elem = React.createElement(dep.Provider, { children: elem });
  }
  return elem as any;
}

export default () => {
  return (
    <Providers>
      <App />
    </Providers>
  );
};
