import React, { createContext, useContext, useEffect, useState } from "react";

export function createEmptyContext<T>(): React.Context<T> {
  return (createContext as any)();
}

export class Atom<T> {
  subscribeFns = new Set<() => void>();
  constructor(private value: T) {}

  get(): T {
    return this.value;
  }

  set(value: T) {
    this.value = value;
    for (let fn of this.subscribeFns) {
      fn();
    }
  }

  use(): T {
    const [, forceUpdate] = useState({});
    useEffect(() => {
      const callbackFn = () => {
        forceUpdate({});
      };
      this.subscribeFns.add(callbackFn);
      return () => {
        this.subscribeFns.delete(callbackFn);
      };
    }, []);
    return this.value;
  }
}

export interface Dep<T> {
  context: React.Context<T>;
  use: () => T;
  Provider: (props: {children: React.ReactNode}) => JSX.Element;
}

export function makeDep<T>(factory: () => T) {
  const context = createEmptyContext<T>();
  return {
    context,
    use(): T {
      return useContext(context);
    },
    Provider(props: { children: React.ReactNode }) {
      const value = factory();
      return (
        <context.Provider value={value}>{props.children}</context.Provider>
      );
    },
  };
}

export function useHighlightOnChange(deps: [any]): string {
  const [t, setT] = useState<number | null>(null);
  useEffect(() => {
    if (t != null) {
      window.clearTimeout(t);
    }
    setT(
      window.setTimeout(() => {
        setT(null);
        if (t != null) {
          window.clearTimeout(t);
        }
      }, 500)
    );
  }, deps);
  return t != null ? "highlight"  : "";
}