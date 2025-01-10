import { Client, Lobby, PacketType, sendMessageToClient } from "./types.ts";
// @ts-types="npm:@types/express@5.0.0"
import express from "npm:express@5.0.0";
// @ts-types="npm:@types/cors@2.8.5"
import cors from "npm:cors@2.8.5";
import * as path from "https://deno.land/std@0.207.0/path/mod.ts";
// @ts-types="npm:@types/ws@8.5.13"
import { WebSocketServer } from "npm:ws@8.18.0";

let clientIdCounter = 0;
let lobbyIdCounter = 0;

const connectedClients = new Map<number, Client>();
const openLobbies = new Map<number, Lobby>();

const staticDir = path.join(
  path.dirname(path.fromFileUrl(import.meta.url)),
  "../react_client/dist",
);
const app = express();
app.use(cors({ origin: "*" }));
app.use(express.static(staticDir));

function getStatic() {

}

app.get("/api/fileSize/:file", async (req, res) => {
  try {
    const fileInfo = await Deno.stat(path.join(staticDir, req.params.file));
    res.send(fileInfo.size);
  } catch {
    res.send(0);
  }
});

app.get("/api/ping", (req, res) => {
  res.send("kek")
})

app.get(/(.*)/, (_, res) => {
  res.sendFile(path.join(staticDir, "index.html"));
});

const server = app.listen(80, () => {
  console.log("Listening on http://localhost:80");
});

const webSocketServer = new WebSocketServer({ server: server,  });

webSocketServer.on("connection", (webSocket) => {
  const clientId = clientIdCounter;
  clientIdCounter++;
  const client: Client = {
    id: clientId,
    webSocket: webSocket
  };

  connectedClients.set(clientId, client);
  joinOrCreateLobby(client);

  webSocket.onmessage = (event) => {
    try {
      const message = JSON.parse(event.data as string);
      const receiverId = message.receiverId;
      const canSend = client.lobby?.ids.has(receiverId);
      if (!canSend) return;
      sendMessageToClient(connectedClients.get(receiverId), {
        pType: message.packetType,
        senderId: client.id,
        ...message,
      });
    } catch {
      webSocket.close();
    }
    webSocket.onerror = (e) => webSocket.close();
    webSocket.onclose = (e) => {
      leaveLobby(client);
      connectedClients.delete(clientId);
    };
  };
});

function joinOrCreateLobby(client: Client) {
  const lobby = openLobbies.values().find((lobby) => lobby.ids.size < 5);
  if (lobby === undefined) {
    const newLobbyId = lobbyIdCounter;
    const createLobby: Lobby = {
      id: newLobbyId,
      ids: new Set<number>(),
    };
    openLobbies.set(newLobbyId, createLobby);
    client.lobby = createLobby;
    lobbyIdCounter++;
    sendMessageToClient(client, {
      pType: PacketType.JOINED,
      ids: [],
    });
    createLobby.ids.add(client.id);
    return createLobby;
  } else {
    client.lobby = lobby;
    sendMessageToClient(client, {
      pType: PacketType.JOINED,
      ids: lobby.ids.values().toArray(),
    });
    lobby.ids.add(client.id);
    return lobby;
  }
}

function leaveLobby(client: Client) {
  const lobby = client.lobby;
  if (lobby === undefined) return;

  lobby.ids.delete(client.id);

  if (lobby.ids.size === 0) {
    openLobbies.delete(lobby.id);
  }
}
