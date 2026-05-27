import fetch from 'node-fetch';

const HMS_API = 'https://api.100ms.live/v2';

export async function createRoom(name, templateId, managementToken) {
  const res = await fetch(`${HMS_API}/rooms`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${managementToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ name, description: 'WTF Assessment call', template_id: templateId }),
  });
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`100ms createRoom failed (${res.status}): ${err}`);
  }
  return res.json();
}

export async function getRoom(roomId, managementToken) {
  const res = await fetch(`${HMS_API}/rooms/${roomId}`, {
    headers: { Authorization: `Bearer ${managementToken}` },
  });
  if (!res.ok) throw new Error(`100ms getRoom failed (${res.status})`);
  return res.json();
}
