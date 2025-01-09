import { useEffect } from "react";
import { routes, useRoute } from "./routes.ts";
import { Button, Flex, HStack, Stack, Image } from "@chakra-ui/react";
import { HomeIcon } from "./components/icons/icons.tsx";
import car from "./assets/images/car.png";
import { HomePage } from "./components/HomePage.tsx";
import { CarPage } from "./components/car/CarPage.tsx";
import "./assets/css/main.css";
import { GodotPage } from "./components/godot/GodotPage.tsx";

export function App() {
  const route = useRoute();

  return (
    <Stack
      gap={0}
      overflow="hidden"
      bgColor="background"
      width="100vw"
      height="100vh"
    >
      <HStack gap="15px" padding="10px" bgColor="backgroundLight">
        <Button
          height="50px"
          _hover={{ bgColor: "mainLight", color: "white" }}
          borderRadius="2em"
          color={route.name === "home" ? "white" : "whiteAlpha.700"}
          bgColor={route.name === "home" ? "main" : "transparent"}
          variant="ghost"
          onClick={() => routes.home().push()}
        >
          <Flex fontSize="35px" gap="5px">
            <HomeIcon color="inherit" width="40px" height="40px" />
            Home
          </Flex>
        </Button>
        <Button
          height="50px"
          _hover={{ bgColor: "mainLight", color: "white" }}
          borderRadius="2em"
          color={route.name === "cars" ? "white" : "whiteAlpha.700"}
          bgColor={route.name === "cars" ? "main" : "transparent"}
          variant="ghost"
          onClick={() => routes.cars().push()}
        >
          <Flex fontSize="35px" align="center" gap="5px">
            <Image height="40px" width="auto" align="center" src={car} />
            Cars
          </Flex>
        </Button>
      </HStack>
      <>
        {route.name === "home" && <HomePage />}
        {route.name === "game" && <GodotPage />}
        {route.name === "cars" && <CarPage />}
        {route.name === false && <FallbackPage />}
      </>
    </Stack>
  );
}

function FallbackPage() {
  useEffect(() => {
    routes.home().replace();
  }, []);

  return null;
}

export default App;
