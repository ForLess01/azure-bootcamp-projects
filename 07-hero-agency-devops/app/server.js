/**
 * ==============================================================================
 * PROYECTO 7: CI/CD & DevOps Pipeline - "Hero Agency" (Sesión 11)
 * Autor: Rendo
 * Rol: Senior Cloud Architect
 * Descripción: Servidor Express para la aplicación de votación de superhéroes.
 * ==============================================================================
 */

const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// In-Memory Database for Voting
let heroes = [
  { id: 'ironman', name: 'Iron Man (Tony Stark)', universe: 'Marvel', votes: 142, color: '#e23636' },
  { id: 'batman', name: 'Batman (Bruce Wayne)', universe: 'DC', votes: 128, color: '#2b2d42' },
  { id: 'spiderman', name: 'Spider-Man (Peter Parker)', universe: 'Marvel', votes: 195, color: '#0476d0' },
  { id: 'wonderwoman', name: 'Wonder Woman (Diana Prince)', universe: 'DC', votes: 110, color: '#c99700' }
];

// Health Check Endpoint (Stage 5 Verification)
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'HEALTHY',
    service: 'hero-agency-voting-api',
    version: '1.0.0',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// Get all candidates
app.get('/api/heroes', (req, res) => {
  res.status(200).json({
    success: true,
    data: heroes,
    totalVotes: heroes.reduce((acc, h) => acc + h.votes, 0)
  });
});

// Vote for a candidate
app.post('/api/vote', (req, res) => {
  const { heroId } = req.body;
  if (!heroId) {
    return res.status(400).json({ success: false, error: 'heroId is required' });
  }

  const hero = heroes.find(h => h.id.toLowerCase() === heroId.toLowerCase());
  if (!hero) {
    return res.status(404).json({ success: false, error: `Hero with id '${heroId}' not found` });
  }

  hero.votes += 1;
  return res.status(200).json({
    success: true,
    message: `Vote registered for ${hero.name}!`,
    hero: hero,
    totalVotes: heroes.reduce((acc, h) => acc + h.votes, 0)
  });
});

// Reset for test suites
app.post('/api/reset', (req, res) => {
  heroes = [
    { id: 'ironman', name: 'Iron Man (Tony Stark)', universe: 'Marvel', votes: 0, color: '#e23636' },
    { id: 'batman', name: 'Batman (Bruce Wayne)', universe: 'DC', votes: 0, color: '#2b2d42' },
    { id: 'spiderman', name: 'Spider-Man (Peter Parker)', universe: 'Marvel', votes: 0, color: '#0476d0' },
    { id: 'wonderwoman', name: 'Wonder Woman (Diana Prince)', universe: 'DC', votes: 0, color: '#c99700' }
  ];
  return res.status(200).json({ success: true, message: 'Votes reset successfully' });
});

// Web UI Single-Page Dashboard
app.get('/', (req, res) => {
  const totalVotes = heroes.reduce((acc, h) => acc + h.votes, 0);
  const cardsHtml = heroes.map(h => {
    const pct = totalVotes > 0 ? Math.round((h.votes / totalVotes) * 100) : 0;
    return `
      <div style="background:#1e293b; border-radius:12px; padding:20px; margin:10px; width:220px; box-shadow:0 4px 6px -1px rgba(0,0,0,0.3); border-top: 4px solid ${h.color};">
        <h3 style="margin:0 0 8px 0; color:#f8fafc; font-size:18px;">${h.name}</h3>
        <p style="color:#94a3b8; font-size:13px; margin:0 0 16px 0;">Universo: <strong>${h.universe}</strong></p>
        <div style="font-size:32px; font-weight:800; color:#38bdf8; margin-bottom:8px;">${h.votes}</div>
        <div style="background:#334155; height:8px; border-radius:4px; overflow:hidden;">
          <div style="background:${h.color}; width:${pct}%; height:100%;"></div>
        </div>
        <p style="color:#64748b; font-size:12px; text-align:right; margin:4px 0 12px 0;">${pct}%</p>
        <button onclick="vote('${h.id}')" style="width:100%; background:#2563eb; color:#fff; border:none; padding:10px; border-radius:6px; cursor:pointer; font-weight:600;">Votar</button>
      </div>
    `;
  }).join('');

  res.send(`
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <title>Hero Agency | Voting Platform - Azure DevOps CI/CD</title>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600;800&display=swap" rel="stylesheet">
      <style>
        body { font-family: 'Montserrat', sans-serif; background:#0f172a; color:#f8fafc; margin:0; padding:40px; display:flex; flex-direction:column; align-items:center; }
        .container { max-width: 1000px; width:100%; }
        .badge { background: #0284c7; color:#fff; padding:4px 12px; border-radius:12px; font-size:12px; font-weight:600; text-transform:uppercase; letter-spacing:1px; }
        .header { display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #334155; padding-bottom:20px; margin-bottom:30px; }
        .grid { display:flex; flex-wrap:wrap; justify-content:center; gap:16px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <div>
            <h1 style="margin:0 0 6px 0; font-weight:800; color:#38bdf8;">Hero Agency &bull; Voting Platform</h1>
            <p style="margin:0; color:#94a3b8;">Arquitectura en Contenedores &bull; CI/CD Multi-Stage Azure Pipelines</p>
          </div>
          <div>
            <span class="badge">Production v1.0.0</span>
          </div>
        </div>
        <div class="grid">${cardsHtml}</div>
      </div>
      <script>
        function vote(heroId) {
          fetch('/api/vote', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ heroId })
          }).then(res => res.json()).then(data => {
            if(data.success) {
              window.location.reload();
            } else {
              alert(data.error);
            }
          });
        }
      </script>
    </body>
    </html>
  `);
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`[Hero Agency] Application running on port ${PORT}`);
  });
}

module.exports = app;
