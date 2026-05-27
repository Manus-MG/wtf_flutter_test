import express from 'express';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const port = Number(process.env.PORT || 3001);

app.get('/token', (req, res) => {
  const { userId = 'demo-user', role = 'member' } = req.query;

  if (!userId || !role) {
    return res.status(400).json({ error: 'userId and role are required' });
  }

  return res.json({
    token: `dev-token-${userId}-${role}`,
    userId,
    role,
  });
});

app.listen(port, () => {
  console.log(`[token-server] listening on http://localhost:${port}`);
});
