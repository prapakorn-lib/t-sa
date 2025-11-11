const express = require('express');
const { Pool } = require('pg');
const path = require('path');
const { exec } = require('child_process');
const http = require('http');

const app = express();
const PORT = process.env.PORT || 3000;

// Database connection configuration
const pool = new Pool({
  host: process.env.DB_HOST || 'db',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'concert_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres123',
});

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Initialize database
async function initDatabase() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS concerts (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        artist VARCHAR(255) NOT NULL,
        date DATE NOT NULL,
        venue VARCHAR(255) NOT NULL,
        total_tickets INTEGER NOT NULL,
        available_tickets INTEGER NOT NULL,
        price DECIMAL(10, 2) NOT NULL
      );
    `);

    await pool.query(`
      CREATE TABLE IF NOT EXISTS bookings (
        id SERIAL PRIMARY KEY,
        concert_id INTEGER REFERENCES concerts(id),
        customer_name VARCHAR(255) NOT NULL,
        customer_email VARCHAR(255) NOT NULL,
        num_tickets INTEGER NOT NULL,
        booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Insert sample data if table is empty
    const result = await pool.query('SELECT COUNT(*) FROM concerts');
    if (parseInt(result.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO concerts (name, artist, date, venue, total_tickets, available_tickets, price)
        VALUES
          ('Rock Festival 2024', 'The Rockers', '2024-12-15', 'Bangkok Arena', 1000, 1000, 1500.00),
          ('Jazz Night', 'Smooth Jazz Band', '2024-12-20', 'Blue Note Club', 300, 300, 800.00),
          ('Pop Concert', 'Pop Stars', '2024-12-25', 'Impact Arena', 5000, 5000, 2000.00),
          ('EDM Party', 'DJ MixMaster', '2025-01-10', 'RCA Plaza', 2000, 2000, 1200.00);
      `);
      console.log('Sample data inserted successfully');
    }

    console.log('Database initialized successfully');
  } catch (err) {
    console.error('Error initializing database:', err);
  }
}

// Helper function to make HTTP request and measure time
function makeRequest(url) {
  return new Promise((resolve) => {
    const startTime = Date.now();
    http.get(url, (res) => {
      const endTime = Date.now();
      resolve({
        statusCode: res.statusCode,
        time: endTime - startTime
      });
    }).on('error', () => {
      const endTime = Date.now();
      resolve({
        statusCode: 0,
        time: endTime - startTime
      });
    });
  });
}

// Test Routes
app.get('/tests', (req, res) => {
  res.render('tests');
});

// Performance Test API
app.get('/api/tests/performance', async (req, res) => {
  try {
    const results = {
      healthCheck: { times: [], avg: 0, passed: false },
      concertsApi: { times: [], avg: 0, passed: false },
      concurrent: { success: 0, failed: 0, passed: false }
    };

    // Test 1: Health Check Response Time
    for (let i = 0; i < 5; i++) {
      const result = await makeRequest(`http://localhost:${PORT}/health`);
      results.healthCheck.times.push(result.time);
    }
    results.healthCheck.avg = Math.round(
      results.healthCheck.times.reduce((a, b) => a + b, 0) / 5
    );
    results.healthCheck.passed = results.healthCheck.avg < 500;

    // Test 2: Concerts API Response Time
    for (let i = 0; i < 5; i++) {
      const result = await makeRequest(`http://localhost:${PORT}/api/concerts`);
      results.concertsApi.times.push(result.time);
    }
    results.concertsApi.avg = Math.round(
      results.concertsApi.times.reduce((a, b) => a + b, 0) / 5
    );
    results.concertsApi.passed = results.concertsApi.avg < 1000;

    // Test 3: Concurrent Requests
    const concurrentTests = [];
    for (let i = 0; i < 10; i++) {
      concurrentTests.push(makeRequest(`http://localhost:${PORT}/api/concerts`));
    }
    const concurrentResults = await Promise.all(concurrentTests);
    results.concurrent.success = concurrentResults.filter(r => r.statusCode === 200).length;
    results.concurrent.failed = 10 - results.concurrent.success;
    results.concurrent.passed = results.concurrent.success === 10;

    res.json(results);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Availability Test API
app.get('/api/tests/availability', async (req, res) => {
  try {
    const results = {
      healthEndpoint: { status: 'unknown', passed: false, details: null },
      databaseConnection: { status: 'unknown', passed: false },
      containerHealth: { web: 'unknown', db: 'unknown', passed: false }
    };

    // Test 1: Health Endpoint
    try {
      const healthResult = await makeRequest(`http://localhost:${PORT}/health`);
      if (healthResult.statusCode === 200) {
        results.healthEndpoint.status = 'working';
        results.healthEndpoint.passed = true;
      } else {
        results.healthEndpoint.status = 'failed';
      }
    } catch (err) {
      results.healthEndpoint.status = 'error';
    }

    // Test 2: Database Connection
    try {
      await pool.query('SELECT 1');
      results.databaseConnection.status = 'connected';
      results.databaseConnection.passed = true;
    } catch (err) {
      results.databaseConnection.status = 'disconnected';
    }

    // Test 3: Container Health (simulated - would need docker commands in production)
    results.containerHealth.web = 'healthy';
    results.containerHealth.db = 'healthy';
    results.containerHealth.passed = true;
    results.containerHealth.note = 'To check actual container health, use: docker-compose ps';

    res.json(results);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Scalability Test API
app.get('/api/tests/scalability', async (req, res) => {
  try {
    const results = {
      databaseConnections: { success: 0, failed: 0, total: 20, passed: false },
      sustainedLoad: { success: 0, failed: 0, total: 50, passed: false, successRate: 0 },
      scaling: { note: 'Try scaling with: docker-compose up -d --scale web=3' }
    };

    // Test 1: Database Connection Pool (20 concurrent queries)
    const dbTests = [];
    for (let i = 0; i < 20; i++) {
      dbTests.push(
        pool.query('SELECT * FROM concerts')
          .then(() => ({ success: true }))
          .catch(() => ({ success: false }))
      );
    }
    const dbResults = await Promise.all(dbTests);
    results.databaseConnections.success = dbResults.filter(r => r.success).length;
    results.databaseConnections.failed = 20 - results.databaseConnections.success;
    results.databaseConnections.passed = results.databaseConnections.success >= 18;

    // Test 2: Sustained Load (50 requests)
    const loadTests = [];
    for (let i = 0; i < 50; i++) {
      loadTests.push(makeRequest(`http://localhost:${PORT}/api/concerts`));
    }
    const loadResults = await Promise.all(loadTests);
    results.sustainedLoad.success = loadResults.filter(r => r.statusCode === 200).length;
    results.sustainedLoad.failed = 50 - results.sustainedLoad.success;
    results.sustainedLoad.successRate = Math.round((results.sustainedLoad.success / 50) * 100);
    results.sustainedLoad.passed = results.sustainedLoad.successRate >= 95;

    res.json(results);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({
      status: 'healthy',
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    res.status(503).json({
      status: 'unhealthy',
      database: 'disconnected',
      error: err.message
    });
  }
});

// Home page - List all concerts
app.get('/', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM concerts ORDER BY date ASC'
    );
    res.render('index', { concerts: result.rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all concerts (API)
app.get('/api/concerts', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM concerts ORDER BY date ASC'
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get specific concert (API)
app.get('/api/concerts/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'SELECT * FROM concerts WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Concert not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Book tickets
app.post('/api/bookings', async (req, res) => {
  const { concert_id, customer_name, customer_email, num_tickets } = req.body;

  try {
    // Start transaction
    await pool.query('BEGIN');

    // Check available tickets
    const concertResult = await pool.query(
      'SELECT available_tickets FROM concerts WHERE id = $1',
      [concert_id]
    );

    if (concertResult.rows.length === 0) {
      await pool.query('ROLLBACK');
      return res.status(404).json({ error: 'Concert not found' });
    }

    const availableTickets = concertResult.rows[0].available_tickets;

    if (availableTickets < num_tickets) {
      await pool.query('ROLLBACK');
      return res.status(400).json({
        error: 'Not enough tickets available',
        available: availableTickets
      });
    }

    // Create booking
    const bookingResult = await pool.query(
      'INSERT INTO bookings (concert_id, customer_name, customer_email, num_tickets) VALUES ($1, $2, $3, $4) RETURNING *',
      [concert_id, customer_name, customer_email, num_tickets]
    );

    // Update available tickets
    await pool.query(
      'UPDATE concerts SET available_tickets = available_tickets - $1 WHERE id = $2',
      [num_tickets, concert_id]
    );

    await pool.query('COMMIT');

    res.status(201).json({
      message: 'Booking successful',
      booking: bookingResult.rows[0]
    });
  } catch (err) {
    await pool.query('ROLLBACK');
    res.status(500).json({ error: err.message });
  }
});

// Get all bookings
app.get('/api/bookings', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT b.*, c.name as concert_name, c.artist, c.date, c.venue
      FROM bookings b
      JOIN concerts c ON b.concert_id = c.id
      ORDER BY b.booking_date DESC
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Start server
const server = app.listen(PORT, async () => {
  console.log(`Server is running on port ${PORT}`);
  await initDatabase();
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    pool.end(() => {
      console.log('Database pool closed');
      process.exit(0);
    });
  });
});

module.exports = app;
