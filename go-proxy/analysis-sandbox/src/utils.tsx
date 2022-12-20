import { createContext, useEffect, useState } from "react";

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