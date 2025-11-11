const express = require('express');
const { Pool } = require('pg');
const path = require('path');
const { exec } = require('child_process');
const http = require('http');

const app = express();
const PORT = process.env.PORT || 8347;

// Database connection configuration
const pool = new Pool({
  host: process.env.DB_HOST || 'db',
  port: process.env.DB_PORT || 54321,
  database: process.env.DB_NAME || 'concert_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres123',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
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

// Helper to add artificial delay (for testing purposes - simulate slow response)
function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Test Routes
app.get('/tests', (req, res) => {
  res.render('tests');
});

// Performance Test API
app.get('/api/tests/performance', async (req, res) => {
  try {
    const results = {
      healthCheck: { times: [], avg: 0, standard: 500 },
      concertsApi: { times: [], avg: 0, standard: 1000 },
      concurrent: { success: 0, failed: 0, total: 10 }
    };

    // Test 1: Health Check Response Time (ผ่าน - รวดเร็ว)
    for (let i = 0; i < 5; i++) {
      const result = await makeRequest(`http://localhost:${PORT}/health`);
      results.healthCheck.times.push(result.time);
    }
    results.healthCheck.avg = Math.round(
      results.healthCheck.times.reduce((a, b) => a + b, 0) / 5
    );

    // Test 2: Concerts API Response Time (ไม่ผ่าน - ช้าเกินไป)
    // เพิ่ม delay เพื่อให้ช้ากว่ามาตรฐาน
    for (let i = 0; i < 5; i++) {
      const startTime = Date.now();
      await delay(800); // Artificial delay
      await makeRequest(`http://localhost:${PORT}/api/concerts`);
      const responseTime = Date.now() - startTime;
      results.concertsApi.times.push(responseTime);
    }
    results.concertsApi.avg = Math.round(
      results.concertsApi.times.reduce((a, b) => a + b, 0) / 5
    );

    // Test 3: Concurrent Requests (ไม่ผ่าน - บางอันล้มเหลว)
    // Simulate some failures
    const concurrentTests = [];
    for (let i = 0; i < 10; i++) {
      if (i === 3 || i === 7) {
        // Simulate 2 failed requests
        concurrentTests.push(Promise.resolve({ statusCode: 500 }));
      } else {
        concurrentTests.push(makeRequest(`http://localhost:${PORT}/api/concerts`));
      }
    }
    const concurrentResults = await Promise.all(concurrentTests);
    results.concurrent.success = concurrentResults.filter(r => r.statusCode === 200).length;
    results.concurrent.failed = 10 - results.concurrent.success;

    res.json(results);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Availability Test API
app.get('/api/tests/availability', async (req, res) => {
  try {
    const results = {
      healthEndpoint: { status: 'unknown', responseCode: null },
      databaseConnection: { status: 'unknown', responseTime: null },
      containerHealth: { web: 'unknown', db: 'unknown', note: '' }
    };

    // Test 1: Health Endpoint (ผ่าน)
    try {
      const healthResult = await makeRequest(`http://localhost:${PORT}/health`);
      results.healthEndpoint.responseCode = healthResult.statusCode;
      if (healthResult.statusCode === 200) {
        results.healthEndpoint.status = 'responding';
      } else {
        results.healthEndpoint.status = 'error';
      }
    } catch (err) {
      results.healthEndpoint.status = 'unreachable';
    }

    // Test 2: Database Connection (ผ่าน)
    try {
      const startTime = Date.now();
      await pool.query('SELECT 1');
      const responseTime = Date.now() - startTime;
      results.databaseConnection.status = 'connected';
      results.databaseConnection.responseTime = responseTime;
    } catch (err) {
      results.databaseConnection.status = 'disconnected';
    }

    // Test 3: Container Health (ต้องเช็คด้วย CLI)
    results.containerHealth.web = 'running';
    results.containerHealth.db = 'running';
    results.containerHealth.note = 'Use docker-compose ps to verify health status';

    res.json(results);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Scalability Test API
app.get('/api/tests/scalability', async (req, res) => {
  try {
    const results = {
      databaseConnections: { success: 0, failed: 0, total: 20 },
      sustainedLoad: { success: 0, failed: 0, total: 50, successRate: 0 },
      resourceUsage: { note: 'Monitor with docker stats' },
      scaling: { note: 'Try scaling with: docker-compose up -d --scale web=3' }
    };

    // Test 1: Database Connection Pool (ไม่ผ่าน - มีบางอันล้มเหลว)
    const dbTests = [];
    for (let i = 0; i < 20; i++) {
      if (i === 5 || i === 12 || i === 18) {
        // Simulate 3 failed connections
        dbTests.push(Promise.resolve({ success: false }));
      } else {
        dbTests.push(
          pool.query('SELECT * FROM concerts')
            .then(() => ({ success: true }))
            .catch(() => ({ success: false }))
        );
      }
    }
    const dbResults = await Promise.all(dbTests);
    results.databaseConnections.success = dbResults.filter(r => r.success).length;
    results.databaseConnections.failed = 20 - results.databaseConnections.success;

    // Test 2: Sustained Load (ไม่ผ่าน - success rate ต่ำกว่า 95%)
    const loadTests = [];
    for (let i = 0; i < 50; i++) {
      if (i % 10 === 9) {
        // Simulate 5 failed requests (every 10th request fails)
        loadTests.push(Promise.resolve({ statusCode: 500 }));
      } else {
        loadTests.push(makeRequest(`http://localhost:${PORT}/api/concerts`));
      }
    }
    const loadResults = await Promise.all(loadTests);
    results.sustainedLoad.success = loadResults.filter(r => r.statusCode === 200).length;
    results.sustainedLoad.failed = 50 - results.sustainedLoad.success;
    results.sustainedLoad.successRate = Math.round((results.sustainedLoad.success / 50) * 100);

    res.json(results);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// System Info endpoint (for inspection - students must run to get values)
app.get('/api/system/info', async (req, res) => {
  try {
    const dbResult = await pool.query('SELECT version() as db_version, current_database() as db_name, inet_server_port() as db_port');
    res.json({
      application: {
        buildId: process.env.BUILD_ID || 'unknown',
        version: process.env.APP_VERSION || 'unknown',
        deployEnv: process.env.DEPLOY_ENV || 'unknown',
        port: PORT,
        nodeVersion: process.version,
        uptime: Math.floor(process.uptime()),
      },
      database: {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        name: dbResult.rows[0].db_name,
        instanceId: process.env.DB_INSTANCE_ID || 'unknown',
        cluster: process.env.DB_CLUSTER || 'unknown',
        serverPort: dbResult.rows[0].db_port,
        poolMax: pool.options.max,
        poolIdleTimeout: pool.options.idleTimeoutMillis,
      },
      network: {
        hostname: require('os').hostname(),
        platform: process.platform,
        arch: process.arch,
      }
    });
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
