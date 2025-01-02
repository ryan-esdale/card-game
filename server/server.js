const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

let players = [];
let currentTurn = 0;

// Broadcast a message to all connected players
function broadcast(message) {
    wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify(message));
        }
    });
}

// Server event handlers
wss.on('connection', (ws) => {
    console.log('Player connected.');

    ws.on('message', (message) => {
        const data = JSON.parse(message);
        console.log('Received:', data);

        if (data.type === 'join') {
            const player = { id: players.length + 1, ws };
            console.log("Connecting new player as player #", player.id)
            players.push(player);
            broadcast({ type: 'player_joined', playerId: player.id });
            ws.send(JSON.stringify({ type: 'welcome', playerId: player.id }));
        } else if (data.type === 'play_card') {
            if (players[currentTurn].ws === ws) {
                broadcast({ type: 'action', playerId: data.playerId, action: data.action });
                currentTurn = (currentTurn + 1) % players.length;
                broadcast({ type: 'turn', playerId: players[currentTurn].id });
            } else {
                ws.send(JSON.stringify({ type: 'error', message: 'Not your turn!' }));
            }
        }
    });

    ws.on('close', () => {
        players = players.filter((player) => player.ws !== ws);
        broadcast({ type: 'player_disconnected', message: 'A player has disconnected.' });
    });
});
