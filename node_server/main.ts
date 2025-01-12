import express from "express";
import cors from "cors";
import path from "path";
import fs from "fs";
import { WebSocketServer } from "ws";
import { Client, Lobby, PacketType, sendMessageToClient } from "./types";

const staticDir = path.join(__dirname, "../react_client/dist");

const app = express();
app.use(cors({ origin: "*" }));
app.use(express.static(staticDir));

app.get("/api/fileSize/:file", async (req, res) => {
  try {
    const fileStats = fs.statSync(path.join(staticDir, req.params.file));
    res.send(fileStats.size);
  } catch {
    res.send(0);
  }
});

app.get("/api/ping", (req, res) => {
  res.send("kek");
});

app.get(/(.*)/, (_, res) => {
  res.sendFile(path.join(staticDir, "index.html"));
});

const server = app.listen(3000, () => {
  console.log("Listening on http://localhost:3000");
});

const webSocketServer = new WebSocketServer({ server: server });

let clientIdCounter = 0;
let lobbyIdCounter = 0;

const connectedClients = new Map<number, Client>();
const openLobbies = new Map<number, Lobby>();

webSocketServer.on("connection", (webSocket) => {
  const clientId = clientIdCounter;
  clientIdCounter++;
  const client: Client = {
    id: clientId,
    webSocket: webSocket,
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
  };
  webSocket.onerror = (e) => webSocket.close();
  webSocket.onclose = (e) => {
    leaveLobby(client);
    connectedClients.delete(clientId);
  };
});

function joinOrCreateLobby(client: Client) {
  const lobby = [...openLobbies.values()].find((l) => l.ids.size < 5);

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
    console.log([...lobby.ids.values()]);
    sendMessageToClient(client, {
      pType: PacketType.JOINED,
      ids: [...lobby.ids.values()],
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
