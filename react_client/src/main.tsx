import { createRoot } from "react-dom/client";
import App from "./App.tsx";
import { RouteProvider } from "./routes.ts";
import { ChakraProvider } from "@chakra-ui/react";
import { theme } from "./theme/theme.ts";

createRoot(document.getElementById("root")!).render(
  <RouteProvider>
    <ChakraProvider theme={theme}>
      <App />
    </ChakraProvider>
  </RouteProvider>,
);
