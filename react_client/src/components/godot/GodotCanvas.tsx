import { baseUrl } from "../../routes.ts";
import { useEffect, useRef, useState } from "react";
import { Engine } from "./engine";
import {
  Box,
  Button,
  Center,
  Flex,
  Image,
  Progress,
  Stack,
  Text,
  VStack,
} from "@chakra-ui/react";
import godotSplash from "../../assets/images/godot_splash.png";
import { FullIcon } from "../icons/icons.tsx";

type Props = {
  fileName: string;
  pckSize: number;
  wasmSize: number;
};

export function GodotCanvas({ fileName, pckSize, wasmSize }: Props) {
  const godotConfig = {
    canvasResizePolicy: 0,
    executable: `${baseUrl}/${fileName}`,
    fileSizes: {
      [`${baseUrl}/${fileName}.pck`]: pckSize,
      [`${baseUrl}/${fileName}.wasm`]: wasmSize,
    },
    onProgress: (current: number, total: number) => {
      setProgress(Math.floor((current / total) * 100));
    },
  };

  const [engine] = useState<any>(new Engine());
  const [showOverlay, setShowOverlay] = useState(true);
  const [progress, setProgress] = useState(0);
  const wrapper = useRef<HTMLDivElement>(null);
  const [width, setWidth] = useState(0);
  const [height, setHeight] = useState(0);

  function reloadSize() {
    if (wrapper.current) {
      setHeight(wrapper.current.clientHeight);
      setWidth(wrapper.current.clientWidth);
    }
  }

  useEffect(() => {
    if (!wrapper.current) return;
    const observer = new ResizeObserver(reloadSize);
    observer.observe(wrapper.current);
    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    engine
      .startGame(godotConfig)
      .then(() => setShowOverlay(false))
      .catch((e: Error) => console.error("canvas error", e.message));
    return () => {
      console.warn("clean up engine when unmounting...");
      engine.requestQuit();
      engine.unload();
    };
  }, []);

  return (
    <Stack padding="10px" gap="10px" flexGrow={1}>
      <Box flexGrow={1} position="relative" ref={wrapper}>
        <canvas
          style={{
            display: "block",
            outline: "none",
            position: "absolute",
            top: 0,
            left: 0,
          }}
          id="canvas"
          width={width}
          height={height}
        >
          <Text>
            HTML5 canvas appears to be unsupported in the current browser.
            <br />
            Please try updating or use a different browser.
          </Text>
        </canvas>
        {showOverlay && (
          <Center
            display={showOverlay ? "flex" : "none"}
            height="100%"
            width="100%"
            bgColor="#0c0d14"
            position="absolute"
            top={0}
            left={0}
          >
            <VStack>
              <Box width="500px">
                <Image
                  width="100%"
                  objectFit="contain"
                  align="center"
                  src={godotSplash}
                />
              </Box>
              <Text fontSize="20px">{progress} %</Text>
              <Progress
                borderRadius="10px"
                bgColor="whiteAlpha.900"
                width="300px"
                colorScheme="blue"
                height="20px"
                value={progress}
              />
              <Text fontSize="20px">downloading game . . .</Text>
            </VStack>
          </Center>
        )}
      </Box>
      <Flex justify="center">
        <Button
          _hover={{ bgColor: "mainLight" }}
          borderRadius="1em"
          fontSize="25px"
          color="white"
          bgColor="main"
          onClick={() => wrapper.current?.requestFullscreen()}
        >
          <Flex align="center" gap="8px">
            <Text>Fullscreen</Text>
            <FullIcon />
          </Flex>
        </Button>
      </Flex>
    </Stack>
  );
}
