/**
 * ==============================================================================
 * PROYECTO 7: Unit Tests con Jest y Supertest (Stage 2: Test)
 * ==============================================================================
 */

const request = require('supertest');
const app = require('../server');

describe('Hero Agency Voting Platform - Automated Test Suite', () => {

  beforeEach(async () => {
    // Reset votes before each test
    await request(app).post('/api/reset');
  });

  test('GET /health debe retornar estado HEALTHY y código 200 (Health Check)', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toEqual(200);
    expect(res.body.status).toEqual('HEALTHY');
    expect(res.body.service).toEqual('hero-agency-voting-api');
    expect(res.body.version).toEqual('1.0.0');
  });

  test('GET /api/heroes debe listar los superhéroes candidatos con total de votos', async () => {
    const res = await request(app).get('/api/heroes');
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toBeGreaterThanOrEqual(4);
    expect(res.body.totalVotes).toBe(0);
  });

  test('POST /api/vote debe incrementar votos para un héroe válido', async () => {
    const res = await request(app)
      .post('/api/vote')
      .send({ heroId: 'spiderman' });

    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.hero.votes).toEqual(1);
    expect(res.body.totalVotes).toEqual(1);
  });

  test('POST /api/vote debe fallar con 400 si falta el heroId', async () => {
    const res = await request(app)
      .post('/api/vote')
      .send({});

    expect(res.statusCode).toEqual(400);
    expect(res.body.success).toBe(false);
    expect(res.body.error).toContain('required');
  });

  test('POST /api/vote debe fallar con 404 si el heroId no existe', async () => {
    const res = await request(app)
      .post('/api/vote')
      .send({ heroId: 'aquaman_fake' });

    expect(res.statusCode).toEqual(404);
    expect(res.body.success).toBe(false);
  });

  test('GET / debe responder con la interfaz HTML y código 200', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.headers['content-type']).toContain('text/html');
    expect(res.text).toContain('Hero Agency');
  });
});
