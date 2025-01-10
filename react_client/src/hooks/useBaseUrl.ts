import { useEffect, useState } from "react";

const possibleUrls = ["http://localhost:80", ""];

export function useBaseUrl() {
  const [baseUrl, setBaseUrl] = useState<string | undefined>(undefined);

  useEffect(() => {
    Promise.all([Promise.wait(300), getBaseUrl()]).then(([, url]) =>
      setBaseUrl(url),
    );
  }, []);

  async function getBaseUrl() {
    for (const url of possibleUrls) {
      try {
        const response = await fetch(`${url}/api/ping`);
        const text = await response.text();
        if (text == "kek") {
          console.warn(`base url found: ${url}`);
          return url;
        }
      } catch (e) {
        console.error(e);
      }
    }
    console.warn("no base url found");
    return "";
  }

  return baseUrl;
}
