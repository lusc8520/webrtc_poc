import { WebSocket } from "ws";

export type Lobby = {
  id: number;
  ids: Set<number>;
};
export type Message = Joined | Forward;
export type Client = {
  id: number;
  webSocket: WebSocket;
  lobby?: Lobby;
};

export enum PacketType {
  JOINED = 0,
  SDP = 1,
  ICE = 2,
}

type Forward = {
  pType: PacketType.SDP | PacketType.ICE;
} & Record<string, any>;

type Joined = {
  pType: PacketType.JOINED;
  ids: number[];
};

export function sendMessageToClient(
  client: Client | undefined,
  message: Message,
) {
  if (client === undefined) return;
  client.webSocket.send(JSON.stringify(message));
}
