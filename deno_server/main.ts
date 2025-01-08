import { serveDir } from "jsr:@std/http/file-server";
import { Client, Lobby, PacketType, sendMessageToClient } from "./types.ts";

let clientIdCounter = 0;
let lobbyIdCounter = 0;

const connectedClients = new Map<number, Client>();
const openLobbies = new Map<number, Lobby>();

Deno.serve({
  port: 80,
}, (req) => {
  if (req.headers.get("upgrade") === "websocket") {
    const { response, socket } = Deno.upgradeWebSocket(req);
    const clientId = clientIdCounter;
    clientIdCounter++;
    const client: Client = {
      id: clientId,
      webSocket: socket,
    };
    socket.onopen = () => {
      connectedClients.set(clientId, client);
      joinOrCreateLobby(client);
    };
    socket.onmessage = (e) => {
      try {
        const message = JSON.parse(e.data);
        const receiverId = message.receiverId;
        const canSend = client.lobby?.ids.has(receiverId);
        if (!canSend) return;
        sendMessageToClient(connectedClients.get(receiverId), {
          pType: message.packetType,
          senderId: client.id,
          ...message,
        });
      } catch (e) {
        socket.close();
      }
    };
    socket.onclose = () => {
      leaveLobby(client);
      connectedClients.delete(clientId);
    };
    socket.onerror = () => {
      socket.close();
    };
    return response;
  } else {
    return serveDir(req, { fsRoot: "public" });
  }
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
