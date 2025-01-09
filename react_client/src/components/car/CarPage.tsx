import {
  Box,
  Button,
  Center,
  CircularProgress,
  Flex,
  Image,
  Stack,
  Text,
} from "@chakra-ui/react";
import {CarPicture, getCarSrc, useRandomCar} from "./randomCar.ts";
import { useEffect, useState } from "react";
import { LinkIcon, ReloadIcon } from "../icons/icons.tsx";

export function CarPage() {
  const { result, fetchCar } = useRandomCar();

  const [car, setCar] = useState<CarPicture | undefined>();

  useEffect(() => {
    fetchCar();
  }, []);

  return (
    <Flex direction={["column", "column", "row"]} flexGrow={1}>
      <Center flexDir="column" padding={3} flexGrow={1}>
        <Stack width={["300px", "450px"]} gap={0}>
          <Flex height="25px" justify="end">
            <Flex
              onClick={() => {
                if (car === undefined) return;
                window.open(getCarSrc(car));
              }}
              transition="color 0.15s"
              _hover={{ color: "lightgrey" }}
              paddingRight={1}
              gap={1}
              cursor="pointer"
              align="center"
              color={car === undefined ? "grey" : "darkgrey"}
            >
              <Text color="inherit">View Original</Text>
              <LinkIcon />
            </Flex>
          </Flex>
          <Stack borderRadius="20px" bgColor="mainDark" padding={5} gap={5}>
            <Box
              alignSelf="stretch"
              aspectRatio="1/1"
              overflow="hidden"
              position="relative"
            >
              <CircularProgress
                capIsRound={true}
                color="mainLight"
                display={car ? "none" : "block"}
                isIndeterminate
                trackColor="white"
                position="absolute"
                top="50%"
                transform="translate(-50%, -50%)"
                left="50%"
                size={50}
              />
              {(() => {
                if (
                  result === undefined ||
                  result === "fetching" ||
                  !result.ok
                ) {
                  return null;
                }
                if (result.ok) {
                  return (
                    <Image
                      onLoad={() => {
                        console.warn(`car loaded. id: ${result.value.id}`);
                        setCar({ id: result.value.id });
                      }}
                      onError={() => {
                        console.error("image error :( refetching car...");
                        setCar(undefined);
                        fetchCar();
                      }}
                      height="100%"
                      width="100%"
                      loading="eager"
                      ignoreFallback={true}
                      objectFit="contain"
                      src={`https://cdn2.thecatapi.com/images/${result.value.id}.jpg`}
                    />
                  );
                }
              })()}
            </Box>
            <Flex gap={2}>
              <Button
                border="1px black solid"
                bgColor="#005188"
                _hover={{ bgColor: "#0070a1" }}
                height="40px"
                borderRadius="20px"
                flexGrow={1}
                disabled={!car}
                onClick={() => {
                  setCar(undefined);
                  fetchCar();
                }}
                alignItems="center"
                justifyContent="center"
                gap="10px"
              >
                <Text fontSize={["20px", "25px"]}>Fetch Car</Text>
                <ReloadIcon
                  display={["none", "block"]}
                  color="white"
                  fontSize="25px"
                />
              </Button>
            </Flex>
          </Stack>
        </Stack>
      </Center>
    </Flex>
  );
}
