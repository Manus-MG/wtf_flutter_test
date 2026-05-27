import express from 'express';
import dotenv from 'dotenv';
import { generateManagementToken, generateAppToken } from './hms_token.js';
import { createRoom } from './hms_management.js';

dotenv.config();

const app = express();
app.use(express.json());

const port = Number(process.env.PORT || 3001);
const ACCESS_KEY = process.env.HMS_ACCESS_KEY;
const SECRET = process.env.HMS_SECRET;
const TEMPLATE_ID = process.env.HMS_TEMPLATE_ID;

// GET /token?userId=&role=&roomId= — real 100ms JWT
app.get('/token', (req, res) => {
  const { userId, role, roomId } = req.query;
  if (!userId || !role || !roomId) {
    return res.status(400).json({ error: 'userId, role, and roomId are required' });
  }
  try {
    const token = generateAppToken(ACCESS_KEY, SECRET, roomId, userId, role);
    console.log(`[token-server] [AUTH] token minted for userId=${userId} role=${role} roomId=${roomId}`);
    return res.json({ token, userId, role, roomId });
  } catch (e) {
    console.error('[token-server] token generation failed:', e.message);
    return res.status(500).json({ error: e.message });
  }
});

// POST /room — create a 100ms room, returns { roomId, roomName }
app.post('/room', async (req, res) => {
  const { name } = req.body;
  const roomName = name || `wtf-call-${Date.now()}`;
  try {
    const mgmtToken = generateManagementToken(ACCESS_KEY, SECRET);
    const room = await createRoom(roomName, TEMPLATE_ID, mgmtToken);
    console.log(`[token-server] [RTC] room created id=${room.id} name=${room.name}`);
    return res.json({ roomId: room.id, roomName: room.name });
  } catch (e) {
    console.error('[token-server] room creation failed:', e.message);
    return res.status(500).json({ error: e.message });
  }
});

// GET /health
app.get('/health', (_req, res) => res.json({ ok: true }));

app.listen(port, '0.0.0.0', () => {
  console.log(`[token-server] listening on 0.0.0.0:${port}`);
  console.log(`[token-server] LAN: http://192.168.29.189:${port}`);
  console.log(`[token-server] endpoints: GET /token  POST /room  GET /health`);
});
