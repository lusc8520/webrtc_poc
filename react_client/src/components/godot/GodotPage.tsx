import { GodotCanvas } from "./GodotCanvas.tsx";
import { useEffect, useState } from "react";

export function GodotPage({ baseUrl }: { baseUrl: string }) {
  const [sizes, setSizes] = useState<[number, number] | undefined>(undefined);

  useEffect(() => {
    fetchFileSizes(baseUrl).then((fileSizes) => setSizes(fileSizes));
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

function fetchFileSizes(baseUrl: string): Promise<[number, number]> {
  return Promise.all([
    fetchFileSize(baseUrl, "testproject.pck"),
    fetchFileSize(baseUrl, "testproject.wasm"),
  ]);
}

async function fetchFileSize(baseUrl: string, fileName: string) {
  return fetch(`${baseUrl}/api/fileSize/${fileName}`)
    .then((res) => res.text())
    .then((text) => parseInt(text))
    .catch(() => 0);
}
