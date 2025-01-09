import { GodotCanvas } from "./GodotCanvas.tsx";
import { useEffect, useState } from "react";
import { basePath } from "../../routes.ts";

export function GodotPage() {
  const [sizes, setSizes] = useState<[number, number] | undefined>(undefined);

  useEffect(() => {
    Promise.all([
      fetchFileSize(`testproject.pck`),
      fetchFileSize(`testproject.wasm`),
    ]).then((ns) => setSizes(ns));
  }, []);

  if (sizes === undefined) return null;

  return (
    <GodotCanvas
      fileName={"testproject"}
      pckSize={sizes[0]}
      wasmSize={sizes[1]}
    />
  );
}

function fetchFileSize(s: string) {
  return fetch(`${basePath}/${s}`, { method: "HEAD" })
    .then((res) => res.headers.get("content-length"))
    .then((s) => parseInt(s ?? "0"))
    .catch(() => 0);
}
