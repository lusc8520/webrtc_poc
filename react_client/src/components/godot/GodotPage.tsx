import { GodotCanvas } from "./GodotCanvas.tsx";
import { useEffect, useState } from "react";
import { baseUrl } from "../../routes.ts";

export function GodotPage() {
  const [sizes, setSizes] = useState<[number, number] | undefined>(undefined);

  useEffect(() => {
    fetchFileSizes().then((fileSizes) => setSizes(fileSizes));
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

function fetchFileSizes(): Promise<[number, number]> {
  return Promise.all([
    fetchFileSize("testproject.pck"),
    fetchFileSize("testproject.wasm"),
  ]);
}

async function fetchFileSize(s: string) {
  return fetch(`${baseUrl}/api/fileSize/${s}`)
    .then((res) => res.text())
    .then((text) => parseInt(text))
    .catch(() => 0);
}
