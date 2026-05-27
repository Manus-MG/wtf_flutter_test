import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';

export function generateManagementToken(accessKey, secret) {
  const payload = {
    access_key: accessKey,
    type: 'management',
    version: 2,
    jti: uuidv4(),
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 24 * 3600,
    nbf: Math.floor(Date.now() / 1000),
  };
  return jwt.sign(payload, secret, { algorithm: 'HS256' });
}

export function generateAppToken(accessKey, secret, roomId, userId, role) {
  const payload = {
    access_key: accessKey,
    room_id: roomId,
    user_id: userId,
    role: role,
    type: 'app',
    version: 2,
    jti: uuidv4(),
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 24 * 3600,
    nbf: Math.floor(Date.now() / 1000),
  };
  return jwt.sign(payload, secret, { algorithm: 'HS256' });
}
