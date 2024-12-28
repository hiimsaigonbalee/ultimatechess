const http = require("http");
const { Server } = require("socket.io");

const app = http.createServer();
const io = new Server(app, {
  cors: {
    origin: "*",
  },
});

const PORT = 3000;
const rooms = {};

const WeatherTypes = {
  SUNNY: 'sunny',
  RAINY: 'rainy',
  SNOWY: 'snowy',
  FOGGY: 'foggy',
  FOREST: 'forest',
  STORMY: 'stormy',
  WINDY: 'windy'
};

// Thay thế mảng weather cũ
const weather = Object.values(WeatherTypes);

function initializeBoard() {
  return [
    [
      { type: "rook", isWhite: false }, { type: "knight", isWhite: false },
      { type: "bishop", isWhite: false }, { type: "queen", isWhite: false },
      { type: "king", isWhite: false }, { type: "bishop", isWhite: false },
      { type: "knight", isWhite: false }, { type: "rook", isWhite: false }
    ],
    Array(8).fill({ type: "pawn", isWhite: false }),
    ...Array(4).fill(Array(8).fill(null)),
    Array(8).fill({ type: "pawn", isWhite: true }),
    [
      { type: "rook", isWhite: true }, { type: "knight", isWhite: true },
      { type: "bishop", isWhite: true }, { type: "queen", isWhite: true },
      { type: "king", isWhite: true }, { type: "bishop", isWhite: true },
      { type: "knight", isWhite: true }, { type: "rook", isWhite: true }
    ]
  ];
}

io.on("connection", (socket) => {
  console.log(`Player connected: ${socket.id}`);

  socket.on("create-room", ({ roomId, weather }) => {
  if (!rooms[roomId]) {
    rooms[roomId] = {
      players: [],
      currentTurn: null,
      board: initializeBoard(),
      weather: weather, // Lưu thời tiết được chọn
      lastMoveTime: Date.now(),
    };
  }

  const room = rooms[roomId];
  if (room.players.length >= 2) {
    socket.emit("room-full", "Room is already full!");
    return;
  }

  const playerColor = room.players.length === 0 ? "white" : "black";
  room.players.push({ id: socket.id, color: playerColor });
  socket.join(roomId);

  if (room.players.length === 2) {
    room.currentTurn = room.players.find((p) => p.color === "white").id;
  }

  io.to(roomId).emit("room-status", {
    players: room.players,
    currentTurn: room.currentTurn,
    board: room.board,
    weather: room.weather, // Gửi thời tiết tới tất cả client
  });
});

socket.on("move", ({ roomId, startRow, startCol, endRow, endCol }) => {
  const room = rooms[roomId];
  if (!room) {
    socket.emit("error", "Room not found");
    return;
  }

  if (socket.id !== room.currentTurn) {
    socket.emit("error", "Not your turn");
    return;
  }

  const player = room.players.find((p) => p.id === socket.id);
  const piece = room.board[startRow][startCol];

  if (!piece) {
    socket.emit("error", "No piece at starting position");
    return;
  }

  if ((piece.isWhite && player.color !== "white") ||
      (!piece.isWhite && player.color !== "black")) {
    socket.emit("error", "Cannot move opponent's pieces");
    return;
  }

  room.board[endRow][endCol] = piece;
  room.board[startRow][startCol] = null;
  room.currentTurn = room.players.find((p) => p.id !== socket.id).id;

  const timeSinceLastMove = Date.now() - room.lastMoveTime;
  room.lastMoveTime = Date.now();

  io.to(roomId).emit("game-update", {
    move: { startRow, startCol, endRow, endCol, currentTurn: room.currentTurn },
    board: room.board,
    weather: room.weather, // Gửi thời tiết mới nếu thay đổi
  });
});

  socket.on("join-room", ({ roomId }) => {
    console.log(`${socket.id} joining room: ${roomId}`);

    // Tạo phòng mới nếu chưa tồn tại
    if (!rooms[roomId]) {
      rooms[roomId] = {
        players: [],
        currentTurn: null,
        board: initializeBoard(),
        weather: room.weather,
        lastMoveTime: Date.now(),
      };
    }

    const room = rooms[roomId];

    // Kiểm tra phòng đã đầy chưa
    if (room.players.length >= 2) {
      socket.emit("error", "Room is full!");
      return;
    }

    // Kiểm tra người chơi đã trong phòng chưa
    if (room.players.some(p => p.id === socket.id)) {
      socket.emit("error", "Already in room!");
      return;
    }

    // Thêm người chơi vào phòng
    const playerColor = room.players.length === 0 ? "white" : "black";
    room.players.push({ id: socket.id, color: playerColor });
    socket.join(roomId);

    // Cập nhật lượt chơi nếu đủ người
    if (room.players.length === 2) {
      room.currentTurn = room.players.find(p => p.color === "white").id;
    }

    // Gửi trạng thái phòng

  io.to(roomId).emit("room-status", {
    players: room.players,
    currentTurn: room.currentTurn,
    board: room.board,
    weather: room.weather,
    roomId: roomId
  });

  // Cập nhật danh sách phòng với thông tin thời tiết
  const availableRooms = Object.entries(rooms).map(([id, room]) => ({
    roomId: id,
    players: room.players.length,
    status: room.players.length < 2 ? "Đang chờ" : "Đang chơi",
    weather: room.weather // Thêm thông tin thời tiết
  }));
  io.emit("rooms-list", availableRooms);

    // Log để debug
    console.log(`Room ${roomId} status:`, {
      players: room.players.length,
      currentTurn: room.currentTurn,
    });
  });

  socket.on("disconnect", () => {
    for (const [roomId, room] of Object.entries(rooms)) {
      const playerIndex = room.players.findIndex((p) => p.id === socket.id);
      if (playerIndex !== -1) {
        room.players.splice(playerIndex, 1);
        if (room.players.length === 0) {
          delete rooms[roomId];
        } else {
          room.currentTurn = null;
          io.to(roomId).emit("room-status", {
            players: room.players,
            currentTurn: room.currentTurn,
            board: room.board,
            weather: room.weather,
          });
        }
        break;
      }
    }

    // Gửi danh sách phòng cập nhật
    const availableRooms = Object.entries(rooms).map(([roomId, room]) => ({
      roomId,
      players: room.players.length,
      status: room.players.length < 2 ? "Đang chờ" : "Đang chơi",
    }));
    io.emit("rooms-list", availableRooms);
  }); // Đóng "disconnect"

  socket.on("get-rooms", () => {
    const availableRooms = Object.entries(rooms).map(([roomId, room]) => ({
      roomId,
      players: room.players.length,
      status: room.players.length < 2 ? "Đang chờ" : "Đang chơi",
    }));

    socket.emit("rooms-list", availableRooms);
  }); // Đóng "get-rooms"
}); // Đóng "io.on"

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});