import express from 'express';
import pg from 'pg';
import productRoutes from './routes/productRoutes.js';

const { Pool } = pg;

const app = express();

app.use(express.json());

// PostgreSQL Connection (Neon)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

// Make pool accessible in routes
app.locals.pool = pool;

// Routes
app.use('/api/products', productRoutes);

// Health Check
app.get('/api/health', async (req, res) => {
  try {
    const dbTest = await pool.query('SELECT NOW()');

    res.json({
      status: 'healthy',
      message: 'Server + Neon DB connected',
      dbTime: dbTest.rows[0].now
    });

  } catch (error) {
    console.error('DB Error:', error);

    res.status(500).json({
      status: 'error',
      message: 'Database connection failed'
    });
  }
});

// Start Server
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
