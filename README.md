CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Product Information
    sku VARCHAR(100) UNIQUE,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    description TEXT,

    -- Categorization
    category_id UUID NOT NULL,
    brand_id UUID,
    
    -- Ownership
    seller_type VARCHAR(20) NOT NULL CHECK (
        seller_type IN ('STORE', 'RESELLER')
    ),

    seller_id UUID NULL,

    -- Pricing
    price DECIMAL(12,2) NOT NULL,
    original_price DECIMAL(12,2),
    cost DECIMAL(12,2),

    -- Inventory
    quantity INTEGER NOT NULL DEFAULT 1,
    stock_status VARCHAR(20) DEFAULT 'IN_STOCK' CHECK (
        stock_status IN (
            'IN_STOCK',
            'OUT_OF_STOCK',
            'RESERVED',
            'SOLD'
        )
    ),

    -- Product Condition
    condition VARCHAR(30) NOT NULL DEFAULT 'NEW' CHECK (
        condition IN (
            'NEW',
            'LIKE_NEW',
            'EXCELLENT',
            'GOOD',
            'FAIR',
            'POOR',
            'FOR_PARTS'
        )
    ),

    -- Marketplace Payout Tracking
    payout_amount DECIMAL(12,2),
    commission_amount DECIMAL(12,2),
    payout_status VARCHAR(20) DEFAULT 'PENDING' CHECK (
        payout_status IN (
            'PENDING',
            'PROCESSING',
            'PAID',
            'CANCELLED'
        )
    ),
    payout_date TIMESTAMP,

    -- Images
    primary_image_url TEXT,

    -- Product Status
    listing_status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (
        listing_status IN (
            'DRAFT',
            'PENDING_APPROVAL',
            'ACTIVE',
            'SOLD',
            'ARCHIVED',
            'REJECTED'
        )
    ),

    -- Shipping
    weight DECIMAL(10,2),
    length DECIMAL(10,2),
    width DECIMAL(10,2),
    height DECIMAL(10,2),

    -- SEO
    meta_title VARCHAR(255),
    meta_description TEXT,

    -- Auditing
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);
users
categories
brands
product_images
product_attributes
orders
order_items
reviews
wishlists
seller_payouts
addresses
products
product_variants
inventory
product_images
seller_listings
products
    ↓
product_variants
    ↓
seller_listings
    ↓
inventory
users
categories
brands
products
product_images
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,

    role VARCHAR(20) DEFAULT 'CUSTOMER' CHECK (
        role IN ('CUSTOMER','SELLER','ADMIN')
    ),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(100) NOT NULL,
    parent_category_id UUID,

    FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id)
);
Apparel & Shoes
 ├─ Men's Clothing
 ├─ Women's Clothing
 ├─ Shoes

Health & Beauty
 ├─ Makeup
 ├─ Skincare

Home Decor
 ├─ Wall Art
 ├─ Rugs
 CREATE TABLE brands (
    brand_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    logo_url TEXT
);
CREATE TABLE product_images (
    image_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID NOT NULL,

    image_url TEXT NOT NULL,

    display_order INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
);
CREATE TABLE seller_listings (
    listing_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID NOT NULL,

    seller_id UUID NOT NULL,

    asking_price DECIMAL(12,2) NOT NULL,

    quantity INTEGER DEFAULT 1,

    condition VARCHAR(30),

    status VARCHAR(20) DEFAULT 'ACTIVE',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    FOREIGN KEY (seller_id)
        REFERENCES users(user_id)
);
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    customer_id UUID NOT NULL,

    order_total DECIMAL(12,2),

    status VARCHAR(20) DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (customer_id)
        REFERENCES users(user_id)
);
CREATE TABLE order_items (
    order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    order_id UUID NOT NULL,

    product_id UUID NOT NULL,

    seller_id UUID,

    quantity INTEGER,

    unit_price DECIMAL(12,2),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);
Customer Pays $100

Platform Fee = $15

Seller Receives = $85
CREATE TABLE seller_payouts (
    payout_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    seller_id UUID NOT NULL,

    order_id UUID NOT NULL,

    gross_amount DECIMAL(12,2),

    commission_amount DECIMAL(12,2),

    net_amount DECIMAL(12,2),

    payout_status VARCHAR(20) DEFAULT 'PENDING',

    payout_date TIMESTAMP,

    FOREIGN KEY (seller_id)
        REFERENCES users(user_id),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);
users
categories
brands

products
product_variants
product_attributes
product_attribute_values
product_images

seller_listings
inventory

orders
order_items

payments
seller_payouts

reviews
wishlists
shopping_carts
cart_items

addresses
shipments
shipment_items
CREATE TABLE cart_items (
    cart_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,
    product_id UUID NOT NULL,

    quantity INTEGER NOT NULL DEFAULT 1,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    status VARCHAR(20) DEFAULT 'PENDING',
    total_amount DECIMAL(12,2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE order_items (
    order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    order_id UUID NOT NULL,
    product_id UUID NOT NULL,

    seller_id UUID,

    quantity INTEGER NOT NULL,
    price_at_purchase DECIMAL(12,2),

    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    order_id UUID NOT NULL,

    amount DECIMAL(12,2) NOT NULL,
    provider VARCHAR(50), -- Stripe, PayPal, etc.

    status VARCHAR(20) DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    first_name VARCHAR(100),
    last_name VARCHAR(100),

    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,

    role VARCHAR(20) DEFAULT 'CUSTOMER'
        CHECK (role IN ('CUSTOMER', 'SELLER', 'ADMIN')),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    title VARCHAR(255) NOT NULL,
    description TEXT,

    price DECIMAL(12,2) NOT NULL,

    condition VARCHAR(30) DEFAULT 'NEW'
        CHECK (condition IN ('NEW','LIKE_NEW','GOOD','FAIR','POOR')),

    seller_id UUID, -- NULL = store item, NOT NULL = resale item

    stock_quantity INTEGER DEFAULT 1,

    listing_status VARCHAR(20) DEFAULT 'ACTIVE'
        CHECK (listing_status IN ('ACTIVE','INACTIVE','SOLD')),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (seller_id) REFERENCES users(user_id)
);
CREATE TABLE cart_items (
    cart_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,
    product_id UUID NOT NULL,

    quantity INTEGER NOT NULL DEFAULT 1,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    status VARCHAR(20) DEFAULT 'PENDING'
        CHECK (status IN ('PENDING','PAID','SHIPPED','COMPLETED','CANCELLED')),

    total_amount DECIMAL(12,2) DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    order_id UUID NOT NULL,

    amount DECIMAL(12,2) NOT NULL,

    provider VARCHAR(50), -- Stripe, PayPal, etc.

    status VARCHAR(20) DEFAULT 'PENDING'
        CHECK (status IN ('PENDING','SUCCEEDED','FAILED','REFUNDED')),

    transaction_id TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
backend/
├── server.js
├── routes/
│   ├── cartRoutes.js
│   ├── orderRoutes.js
│   └── paymentRoutes.js
├── controllers/
│   ├── cartController.js
│   ├── orderController.js
│   └── paymentController.js
├── db/
│   └── db.js
└── package.json
npm install express pg dotenv cors
const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT
});

module.exports = pool;
const pool = require('../db/db');

exports.addToCart = async (req, res) => {
  try {
    const { user_id, product_id, quantity } = req.body;

    const result = await pool.query(
      `
      INSERT INTO cart_items
      (user_id, product_id, quantity)
      VALUES ($1, $2, $3)
      RETURNING *
      `,
      [user_id, product_id, quantity]
    );

    res.status(201).json(result.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error adding item to cart' });
  }
};

const express = require('express');
const router = express.Router();

const {
  addToCart
} = require('../controllers/cartController');

router.post('/add', addToCart);

module.exports = router;
const pool = require('../db/db');

exports.createOrder = async (req, res) => {
  try {

    const {
      user_id,
      total_amount
    } = req.body;

    const result = await pool.query(
      `
      INSERT INTO orders
      (user_id, total_amount)
      VALUES ($1, $2)
      RETURNING *
      `,
      [user_id, total_amount]
    );

    res.status(201).json(result.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: 'Error creating order'
    });
  }
};
const express = require('express');
const router = express.Router();

const {
  createOrder
} = require('../controllers/orderController');

router.post('/', createOrder);

module.exports = router;
exports.checkout = async (req, res) => {

  const client = await pool.connect();

  try {

    await client.query('BEGIN');

    const { user_id } = req.body;

    const cart = await client.query(
      `
      SELECT c.*, p.price, p.seller_id
      FROM cart_items c
      JOIN products p
      ON c.product_id = p.product_id
      WHERE c.user_id = $1
      `,
      [user_id]
    );

    let total = 0;

    cart.rows.forEach(item => {
      total += item.price * item.quantity;
    });

    const orderResult = await client.query(
      `
      INSERT INTO orders
      (user_id, total_amount)
      VALUES ($1, $2)
      RETURNING *
      `,
      [user_id, total]
    );

    const order = orderResult.rows[0];

    for (const item of cart.rows) {

      await client.query(
        `
        INSERT INTO order_items
        (
          order_id,
          product_id,
          seller_id,
          quantity,
          price_at_purchase
        )
        VALUES ($1,$2,$3,$4,$5)
        `,
        [
          order.order_id,
          item.product_id,
          item.seller_id,
          item.quantity,
          item.price
        ]
      );
    }

    await client.query(
      `
      DELETE FROM cart_items
      WHERE user_id = $1
      `,
      [user_id]
    );

    await client.query('COMMIT');

    res.status(201).json(order);

  } catch (err) {

    await client.query('ROLLBACK');

    console.error(err);

    res.status(500).json({
      message: 'Checkout failed'
    });

  } finally {
    client.release();
  }
};
router.post('/checkout', checkout);
const pool = require('../db/db');

exports.createPayment = async (req, res) => {

  try {

    const {
      order_id,
      amount,
      provider,
      transaction_id
    } = req.body;

    const result = await pool.query(
      `
      INSERT INTO payments
      (
        order_id,
        amount,
        provider,
        transaction_id,
        status
      )
      VALUES ($1,$2,$3,$4,'SUCCEEDED')
      RETURNING *
      `,
      [
        order_id,
        amount,
        provider,
        transaction_id
      ]
    );

    await pool.query(
      `
      UPDATE orders
      SET status='PAID'
      WHERE order_id=$1
      `,
      [order_id]
    );

    res.status(201).json(result.rows[0]);

  } catch (err) {

    console.error(err);

    res.status(500).json({
      message: 'Payment failed'
    });
  }
};
const express = require('express');
const router = express.Router();

const {
  createPayment
} = require('../controllers/paymentController');

router.post('/', createPayment);
});module.exports = router;
const express = require('express');
const cors = require('cors');

const cartRoutes = require('./routes/cartRoutes');
const orderRoutes = require('./routes/orderRoutes');
const paymentRoutes = require('./routes/paymentRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/cart', cartRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/payments', paymentRoutes);

app.listen(5000, () => {
  console.log('Server running on port 5000');
});
React Frontend
      ↓
POST /api/cart/add
      ↓
POST /api/orders/checkout
      ↓
Creates Order + Order Items
      ↓
POST /api/payments
      ↓
Marks Order as PAID

npm install bcryptjs jsonwebtoken
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    first_name VARCHAR(100),
    last_name VARCHAR(100),

    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,

    role VARCHAR(20) DEFAULT 'CUSTOMER'
        CHECK (role IN ('CUSTOMER', 'SELLER', 'ADMIN')),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

PORT=5000

DB_HOST=localhost
DB_PORT=5432
DB_NAME=marketplace
DB_USER=postgres
DB_PASSWORD=yourpassword

JWT_SECRET=super_secret_jwt_key
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db/db');

const JWT_SECRET = process.env.JWT_SECRET;
exports.register = async (req, res) => {
  try {

    const {
      first_name,
      last_name,
      email,
      password
    } = req.body;

    const existingUser = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({
        message: 'Email already exists'
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `
      INSERT INTO users
      (
        first_name,
        last_name,
        email,
        password_hash
      )
      VALUES ($1,$2,$3,$4)
      RETURNING user_id,email
      `,
      [
        first_name,
        last_name,
        email,
        hashedPassword
      ]
    );

    res.status(201).json(result.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: 'Registration failed'
    });
  }
};
exports.login = async (req, res) => {

  try {

    const {
      email,
      password
    } = req.body;

    const userResult = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (userResult.rows.length === 0) {
      return res.status(401).json({
        message: 'Invalid credentials'
      });
    }

    const user = userResult.rows[0];

    const validPassword =
      await bcrypt.compare(
        password,
        user.password_hash
      );

    if (!validPassword) {
      return res.status(401).json({
        message: 'Invalid credentials'
      });
    }

    const token = jwt.sign(
      {
        user_id: user.user_id,
        email: user.email,
        role: user.role
      },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      token
    });

  } catch (err) {
    console.error(err);

    res.status(500).json({
      message: 'Login failed'
    });
  }
};

const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {

  const authHeader =
    req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({
      message: 'No token provided'
    });
  }

  const token =
    authHeader.split(' ')[1];

  try {

    const decoded =
      jwt.verify(
        token,
        process.env.JWT_SECRET
      );

    req.user = decoded;

    next();

  } catch {

    return res.status(401).json({
      message: 'Invalid token'
    });
  }
};
const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {

  const authHeader =
    req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({
      message: 'No token provided'
    });
  }

  const token =
    authHeader.split(' ')[1];

  try {

    const decoded =
      jwt.verify(
        token,
        process.env.JWT_SECRET
      );

    req.user = decoded;

    next();

  } catch {

    return res.status(401).json({
      message: 'Invalid token'
    });
  }
};
const express = require('express');
const router = express.Router();

const {
  register,
  login
} = require('../controllers/authController');

router.post('/register', register);
router.post('/login', login);

module.exports = router;
const authRoutes =
require('./routes/authRoutes');

app.use(
  '/api/auth',
  authRoutes
);
const auth = require('../middleware/auth');

router.get(
  '/me',
  auth,
  async (req, res) => {

    res.json({
      user: req.user
    });

  }
);
const response = await fetch(
  '/api/auth/login',
  {
    method: 'POST',
    headers: {
      'Content-Type':
      'application/json'
    },
    body: JSON.stringify({
      email,
      password
    })
  }
);

const data = await response.json();

localStorage.setItem(
  'token',
  data.token
);
const token =
localStorage.getItem('token');

fetch('/api/orders', {
  headers: {
    Authorization:
      `Bearer ${token}`
  }
});
CREATE TABLE categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(100) NOT NULL,

    parent_category_id UUID,

    FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id)
);
Apparel & Shoes
 ├─ Men's Clothing
 ├─ Women's Clothing
 ├─ Shoes

Health & Beauty
 ├─ Skincare
 ├─ Makeup

Home Decor
 ├─ Wall Art
 ├─ Rugs
 CREATE TABLE product_images (
    image_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID NOT NULL,

    image_url TEXT NOT NULL,

    display_order INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
);
router.post(
  '/',
  auth,
  createProduct
);
exports.createProduct = async (req, res) => {

  try {

    const {
      title,
      description,
      price,
      category_id,
      condition
    } = req.body;

    const seller_id = req.user.user_id;

    const result = await pool.query(
      `
      INSERT INTO products
      (
        title,
        description,
        price,
        category_id,
        condition,
        seller_id
      )
      VALUES ($1,$2,$3,$4,$5,$6)
      RETURNING *
      `,
      [
        title,
        description,
        price,
        category_id,
        condition,
        seller_id
      ]
    );

    res.status(201).json(result.rows[0]);

  } catch (err) {

    console.error(err);

    res.status(500).json({
      message: 'Product creation failed'
    });
  }
};
router.get('/search', searchProducts);
exports.searchProducts = async (req, res) => {

  try {

    const keyword = req.query.q || '';

    const result = await pool.query(
      `
      SELECT *
      FROM products
      WHERE title ILIKE $1
      `,
      [`%${keyword}%`]
    );

    res.json(result.rows);

  } catch (err) {

    console.error(err);

    res.status(500).json({
      message: 'Search failed'
    });
  }
};
CREATE TABLE seller_listings (

    listing_id UUID PRIMARY KEY
    DEFAULT gen_random_uuid(),

    seller_id UUID NOT NULL,

    product_id UUID NOT NULL,

    quantity INTEGER DEFAULT 1,

    asking_price DECIMAL(12,2),

    condition VARCHAR(30),

    status VARCHAR(20)
        DEFAULT 'ACTIVE',

    created_at TIMESTAMP
        DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (seller_id)
        REFERENCES users(user_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);
exports.createListing = async (req, res) => {

  try {

    const seller_id = req.user.user_id;

    const {
      product_id,
      quantity,
      asking_price,
      condition
    } = req.body;

    const result = await pool.query(
      `
      INSERT INTO seller_listings
      (
        seller_id,
        product_id,
        quantity,
        asking_price,
        condition
      )
      VALUES ($1,$2,$3,$4,$5)
      RETURNING *
      `,
      [
        seller_id,
        product_id,
        quantity,
        asking_price,
        condition
      ]
    );

    res.status(201).json(result.rows[0]);

  } catch (err) {

    console.error(err);

    res.status(500).json({
      message: 'Listing failed'
    });
  }
};
CREATE TABLE inventory (

    inventory_id UUID PRIMARY KEY
    DEFAULT gen_random_uuid(),

    product_id UUID NOT NULL,

    quantity INTEGER NOT NULL,

    updated_at TIMESTAMP
    DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id)
    REFERENCES products(product_id)
);
await client.query(
`
UPDATE inventory
SET quantity = quantity - $1
WHERE product_id = $2
`,
[
  item.quantity,
  item.product_id
]
);
users
  │
  ├── addresses
  ├── orders
  ├── cart_items
  ├── reviews
  └── seller_listings

products
  │
  ├── categories
  ├── product_images
  ├── inventory
  └── seller_listings

orders
  │
  ├── order_items
  ├── payments
  └── shipments

seller_listings
  │
  └── seller_payouts
  npm install multer
 backend/
├── uploads/
│   └── products/
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    cb(null, 'uploads/products');
  },

  filename: function(req, file, cb) {
    const unique =
      Date.now() +
      '-' +
      Math.round(Math.random() * 1E9);

    cb(
      null,
      unique + path.extname(file.originalname)
    );
  }
});

const upload = multer({
  storage
});

module.exports = upload;
const express = require('express');
const router = express.Router();

const auth = require('../middleware/auth');
const upload = require('../middleware/upload');

router.post(
  '/:productId/images',
  auth,
  upload.single('image'),
  async (req, res) => {

    try {

      const { productId } = req.params;

      const imageUrl =
        `/uploads/products/${req.file.filename}`;

      const result =
      await pool.query(
        `
        INSERT INTO product_images
        (product_id, image_url)
        VALUES ($1,$2)
        RETURNING *
        `,
        [productId, imageUrl]
      );

      res.status(201)
      .json(result.rows[0]);

    } catch (err) {

      console.error(err);

      res.status(500).json({
        message: 'Upload failed'
      });
    }
  }
);

module.exports = router;
app.use(
  '/uploads',
  express.static('uploads')
);
const formData = new FormData();

formData.append(
  'image',
  selectedFile
);

await fetch(
  `/api/products/${productId}/images`,
  {
    method: 'POST',
    headers: {
      Authorization:
        `Bearer ${token}`
    },
    body: formData
  }
);
npm install stripe
STRIPE_SECRET_KEY=sk_test_xxxxxxxxx
const Stripe = require('stripe');

module.exports = new Stripe(
  process.env.STRIPE_SECRET_KEY
);
const stripe =
require('../config/stripe');

exports.createPaymentIntent =
async (req, res) => {

  try {

    const { amount } = req.body;

    const paymentIntent =
    await stripe.paymentIntents.create({
      amount: amount * 100,
      currency: 'usd'
    });

    res.json({
      clientSecret:
      paymentIntent.client_secret
    });

  } catch (err) {

    console.error(err);

    res.status(500).json({
      message:
      'Payment Intent Failed'
    });
  }
};
router.post(
  '/create-payment-intent',
  auth,
  createPaymentIntent
);
User adds items
        ↓
Cart
        ↓
Checkout Page
        ↓
Create Payment Intent
        ↓
Stripe Card Form
        ↓
Payment Success
        ↓
Create Order
        ↓
Reduce Inventory
        ↓
Create Seller Payout
ALTER TABLE products
ADD COLUMN category_id UUID;

ALTER TABLE products
ADD CONSTRAINT fk_product_category
FOREIGN KEY (category_id)
REFERENCES categories(category_id);
src/
├── pages/
│   ├── Login.jsx
│   ├── Register.jsx
│   ├── Products.jsx
│   ├── ProductDetails.jsx
│   ├── Cart.jsx
│   ├── Checkout.jsx
│   ├── SellerDashboard.jsx
│   └── AdminDashboard.jsx
├── components/
│   ├── Navbar.jsx
│   ├── ProductCard.jsx
│   ├── ProtectedRoute.jsx
├── context/
│   └── AuthContext.jsx
├── App.jsx
└── api.js
const API_URL = "http://localhost:5000/api";

export const api = async (url, method = "GET", body, token) => {
  const res = await fetch(`${API_URL}${url}`, {
    method,
    headers: {
      "Content-Type": "application/json",
      Authorization: token ? `Bearer ${token}` : ""
    },
    body: body ? JSON.stringify(body) : null
  });

  return res.json();
};
import { createContext, useState } from "react";

export const AuthContext = createContext();

export default function AuthProvider({ children }) {
  const [token, setToken] = useState(localStorage.getItem("token"));

  const login = (newToken) => {
    localStorage.setItem("token", newToken);
    setToken(newToken);
  };

  const logout = () => {
    localStorage.removeItem("token");
    setToken(null);
  };

  return (
    <AuthContext.Provider value={{ token, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}
import { useState, useContext } from "react";
import { api } from "../api";
import { AuthContext } from "../context/AuthContext";

export default function Login() {
  const { login } = useContext(AuthContext);

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleLogin = async () => {
    const res = await api("/auth/login", "POST", {
      email,
      password
    });

    login(res.token);
  };

  return (
    <div>
      <h2>Login</h2>

      <input
        placeholder="Email"
        onChange={(e) => setEmail(e.target.value)}
      />

      <input
        type="password"
        placeholder="Password"
        onChange={(e) => setPassword(e.target.value)}
      />

      <button onClick={handleLogin}>
        Login
      </button>
    </div>
  );
}
import { useState } from "react";
import { api } from "../api";

export default function Register() {
  const [form, setForm] = useState({});

  const handleChange = (e) => {
    setForm({
      ...form,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async () => {
    await api("/auth/register", "POST", form);
    alert("Account created");
  };

  return (
    <div>
      <h2>Register</h2>

      <input name="first_name" placeholder="First Name" onChange={handleChange} />
      <input name="last_name" placeholder="Last Name" onChange={handleChange} />
      <input name="email" placeholder="Email" onChange={handleChange} />
      <input name="password" type="password" placeholder="Password" onChange={handleChange} />

      <button onClick={handleSubmit}>
        Create Account
      </button>
    </div>
  );
}
import { useEffect, useState } from "react";
import { api } from "../api";
import ProductCard from "../components/ProductCard";

export default function Products() {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    const load = async () => {
      const res = await api("/products/search?q=");
      setProducts(res);
    };

    load();
  }, []);

  return (
    <div>
      <h2>Products</h2>

      {products.map(p => (
        <ProductCard key={p.product_id} product={p} />
      ))}
    </div>
  );
}
import { useNavigate } from "react-router-dom";

export default function ProductCard({ product }) {
  const nav = useNavigate();

  return (
    <div onClick={() => nav(`/product/${product.product_id}`)}>
      <h3>{product.title}</h3>
      <p>${product.price}</p>
    </div>
  );
}
import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { api } from "../api";

export default function ProductDetails() {
  const { id } = useParams();
  const [product, setProduct] = useState(null);

  useEffect(() => {
    const load = async () => {
      const res = await api(`/products/${id}`);
      setProduct(res);
    };

    load();
  }, [id]);

  if (!product) return <div>Loading...</div>;

  return (
    <div>
      <h2>{product.title}</h2>
      <p>{product.description}</p>
      <h3>${product.price}</h3>

      <button>Add to Cart</button>
    </div>
  );
}
import { useEffect, useState, useContext } from "react";
import { api } from "../api";
import { AuthContext } from "../context/AuthContext";

export default function Cart() {
  const { token } = useContext(AuthContext);
  const [items, setItems] = useState([]);

  useEffect(() => {
    const load = async () => {
      const res = await api("/cart", "GET", null, token);
      setItems(res);
    };

    load();
  }, []);

  return (
    <div>
      <h2>Cart</h2>

      {items.map(i => (
        <div key={i.cart_item_id}>
          Product: {i.product_id} | Qty: {i.quantity}
        </div>
      ))}
    </div>
  );
}
import { useContext } from "react";
import { api } from "../api";
import { AuthContext } from "../context/AuthContext";

export default function Checkout() {
  const { token } = useContext(AuthContext);

  const handleCheckout = async () => {
    const res = await api(
      "/orders/checkout",
      "POST",
      {},
      token
    );

    alert("Order created: " + res.order_id);
  };

  return (
    <div>
      <h2>Checkout</h2>
      <button onClick={handleCheckout}>
        Complete Order
      </button>
    </div>
  );
}
import { useEffect, useState, useContext } from "react";
import { api } from "../api";
import { AuthContext } from "../context/AuthContext";

export default function SellerDashboard() {
  const { token } = useContext(AuthContext);
  const [listings, setListings] = useState([]);

  useEffect(() => {
    const load = async () => {
      const res = await api("/seller/listings", "GET", null, token);
      setListings(res);
    };

    load();
  }, []);

  return (
    <div>
      <h2>Seller Dashboard</h2>

      {listings.map(l => (
        <div key={l.listing_id}>
          {l.product_id} - ${l.asking_price}
        </div>
      ))}
    </div>
  );
}
import { useEffect, useState, useContext } from "react";
import { api } from "../api";
import { AuthContext } from "../context/AuthContext";

export default function AdminDashboard() {
  const { token } = useContext(AuthContext);
  const [orders, setOrders] = useState([]);

  useEffect(() => {
    const load = async () => {
      const res = await api("/admin/orders", "GET", null, token);
      setOrders(res);
    };

    load();
  }, []);

  return (
    <div>
      <h2>Admin Dashboard</h2>

      {orders.map(o => (
        <div key={o.order_id}>
          Order: {o.order_id} - ${o.total_amount}
        </div>
      ))}
    </div>
  );
}
import { BrowserRouter, Routes, Route } from "react-router-dom";

import Login from "./pages/Login";
import Register from "./pages/Register";
import Products from "./pages/Products";
import ProductDetails from "./pages/ProductDetails";
import Cart from "./pages/Cart";
import Checkout from "./pages/Checkout";
import SellerDashboard from "./pages/SellerDashboard";
import AdminDashboard from "./pages/AdminDashboard";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>

        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />

        <Route path="/" element={<Products />} />
        <Route path="/product/:id" element={<ProductDetails />} />

        <Route path="/cart" element={<Cart />} />
        <Route path="/checkout" element={<Checkout />} />

        <Route path="/seller" element={<SellerDashboard />} />
        <Route path="/admin" element={<AdminDashboard />} />

      </Routes>
    </BrowserRouter>
  );
}
import { useContext } from "react";
import { Navigate } from "react-router-dom";
import { AuthContext } from "../context/AuthContext";

export default function ProtectedRoute({ children }) {
  const { token } = useContext(AuthContext);

  if (!token) {
    return <Navigate to="/login" />;
  }

  return children;
}
<Route
  path="/cart"
  element={
    <ProtectedRoute>
      <Cart />
    </ProtectedRoute>
  }
/>
const [user, setUser] = useState(
  JSON.parse(localStorage.getItem("user"))
);

const login = (token, userData) => {
  localStorage.setItem("token", token);
  localStorage.setItem("user", JSON.stringify(userData));

  setToken(token);
  setUser(userData);
};
export function RoleRoute({ children, allowedRoles }) {
  const { user } = useContext(AuthContext);

  if (!user) return <Navigate to="/login" />;

  if (!allowedRoles.includes(user.role)) {
    return <Navigate to="/" />;
  }

  return children;
}
<Route
  path="/seller"
  element={
    <RoleRoute allowedRoles={["SELLER"]}>
      <SellerDashboard />
    </RoleRoute>
  }
/>
<Route
  path="/admin"
  element={
    <RoleRoute allowedRoles={["ADMIN"]}>
      <AdminDashboard />
    </RoleRoute>
  }
/>
import { useContext } from "react";
import { api } from "../api";
import { AuthContext } from "../context/AuthContext";

export default function ProductDetails({ product }) {
  const { token } = useContext(AuthContext);

  const addToCart = async () => {
    await api(
      "/cart/add",
      "POST",
      {
        product_id: product.product_id,
        quantity: 1
      },
      token
    );

    alert("Added to cart");
  };

  return (
    <div>
      <h2>{product.title}</h2>
      <p>${product.price}</p>

      <button onClick={addToCart}>
        Add to Cart
      </button>
    </div>
  );
}
import { useState, useContext } from "react";
import { api } from "../api";
import { AuthContext } from "../context/AuthContext";

export default function SellerDashboard() {
  const { token } = useContext(AuthContext);

  const [form, setForm] = useState({
    title: "",
    description: "",
    price: ""
  });

  const handleChange = (e) => {
    setForm({
      ...form,
      [e.target.name]: e.target.value
    });
  };

  const createProduct = async () => {
    await api("/products", "POST", form, token);
    alert("Product created");
  };

  return (
    <div>
      <h2>Seller Dashboard</h2>

      <input
        name="title"
        placeholder="Title"
        onChange={handleChange}
      />

      <input
        name="description"
        placeholder="Description"
        onChange={handleChange}
      />

      <input
        name="price"
        placeholder="Price"
        onChange={handleChange}
      />

      <button onClick={createProduct}>
        Create Product
      </button>
    </div>
  );
}
npm install @stripe/stripe-js @stripe/react-stripe-js
import { loadStripe } from "@stripe/stripe-js";
import { Elements, CardElement, useStripe, useElements } from "@stripe/react-stripe-js";
import { api } from "../api";
import { useContext } from "react";
import { AuthContext } from "../context/AuthContext";

const stripePromise = loadStripe("YOUR_PUBLISHABLE_KEY");

function CheckoutForm() {
  const stripe = useStripe();
  const elements = useElements();
  const { token } = useContext(AuthContext);

  const pay = async () => {

    const { clientSecret } = await api(
      "/payments/create-payment-intent",
      "POST",
      { amount: 100 },
      token
    );

    const result = await stripe.confirmCardPayment(
      clientSecret,
      {
        payment_method: {
          card: elements.getElement(CardElement)
        }
      }
    );

    if (result.error) {
      alert("Payment failed");
    } else {
      alert("Payment successful");
    }
  };

  return (
    <div>
      <CardElement />
      <button onClick={pay}>Pay Now</button>
    </div>
  );
}

export default function Checkout() {
  return (
    <Elements stripe={stripePromise}>
      <CheckoutForm />
    </Elements>
  );
}
router.get("/", auth, getCart);
const pool = require("../db/db");

exports.getCart = async (req, res) => {
  try {
    const user_id = req.user.user_id;

    const result = await pool.query(
      `
      SELECT
        c.cart_item_id,
        c.quantity,
        p.product_id,
        p.title,
        p.price,
        p.seller_id
      FROM cart_items c
      JOIN products p ON p.product_id = c.product_id
      WHERE c.user_id = $1
      `,
      [user_id]
    );

    res.json(result.rows);

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to load cart" });
  }
};
router.delete("/:id", auth, removeFromCart);
exports.removeFromCart = async (req, res) => {
  try {
    const user_id = req.user.user_id;
    const { id } = req.params;

    await pool.query(
      `
      DELETE FROM cart_items
      WHERE cart_item_id = $1
      AND user_id = $2
      `,
      [id, user_id]
    );

    res.json({ message: "Removed from cart" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Delete failed" });
  }
};
await client.query(
  `
  UPDATE inventory
  SET quantity = quantity - $1
  WHERE product_id = $2
  AND quantity >= $1
  `,
  [item.quantity, item.product_id]
);
if (inventory.rows[0]?.quantity < item.quantity) {
  throw new Error("Out of stock");
}
const feeRate = 0.10; // 10%

for (const item of orderItems) {

  const gross = item.price_at_purchase * item.quantity;
  const fee = gross * feeRate;
  const net = gross - fee;

  await pool.query(
    `
    INSERT INTO seller_payouts
    (seller_id, order_id, gross_amount, commission_amount, net_amount, payout_status)
    VALUES ($1,$2,$3,$4,$5,'PENDING')
    `,
    [
      item.seller_id,
      order_id,
      gross,
      fee,
      net
    ]
  );
}
CREATE TABLE seller_payouts (
    payout_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL,
    order_id UUID NOT NULL,
    gross_amount DECIMAL(12,2),
    commission_amount DECIMAL(12,2),
    net_amount DECIMAL(12,2),
    payout_status VARCHAR(20) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
router.get("/my-orders", auth, getMyOrders);
exports.getMyOrders = async (req, res) => {
  try {
    const user_id = req.user.user_id;

    const result = await pool.query(
      `
      SELECT *
      FROM orders
      WHERE user_id = $1
      ORDER BY created_at DESC
      `,
      [user_id]
    );

    res.json(result.rows);

  } catch (err) {
    res.status(500).json({ message: "Failed to fetch orders" });
  }
};
import { useEffect, useState, useContext } from "react";
import { api } from "../api";
import { AuthContext } from "../context/AuthContext";

export default function Orders() {
  const { token } = useContext(AuthContext);
  const [orders, setOrders] = useState([]);

  useEffect(() => {
    const load = async () => {
      const res = await api("/orders/my-orders", "GET", null, token);
      setOrders(res);
    };

    load();
  }, []);

  return (
    <div>
      <h2>My Orders</h2>

      {orders.map(o => (
        <div key={o.order_id}>
          Order: {o.order_id} - ${o.total_amount} - {o.status}
        </div>
      ))}
    </div>
  );
}
ALTER TABLE seller_listings
ADD COLUMN approval_status VARCHAR(20) DEFAULT 'PENDING';
exports.getPendingListings = async (req, res) => {
  const result = await pool.query(
    `
    SELECT *
    FROM seller_listings
    WHERE approval_status = 'PENDING'
    `
  );

  res.json(result.rows);
};
exports.reviewListing = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body; // APPROVED or REJECTED

  await pool.query(
    `
    UPDATE seller_listings
    SET approval_status = $1
    WHERE listing_id = $2
    `,
    [status, id]
  );

  res.json({ message: "Updated" });
};
router.get("/listings", auth, adminOnly, getPendingListings);

router.patch("/listings/:id", auth, adminOnly, reviewListing);
module.exports = (req, res, next) => {
  if (req.user.role !== "ADMIN") {
    return res.status(403).json({ message: "Forbidden" });
  }
  next();
};
npm install express raw-body
app.use(
  "/api/payments/webhook",
  express.raw({ type: "application/json" })
);

app.use(express.json());
router.post("/webhook", handleStripeWebhook);
const stripe = require("../config/stripe");
const pool = require("../db/db");

exports.handleStripeWebhook = async (req, res) => {
  const sig = req.headers["stripe-signature"];

  let event;

  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // PAYMENT SUCCESS
  if (event.type === "payment_intent.succeeded") {
    const paymentIntent = event.data.object;

    const orderId = paymentIntent.metadata.order_id;

    await pool.query(
      `UPDATE orders SET status='PAID' WHERE order_id=$1`,
      [orderId]
    );
  }

  res.json({ received: true });
};
Frontend says "paid"
Stripe says "maybe"

Webhook says "REAL confirmed payment"
CREATE TABLE shipments (
    shipment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    order_id UUID NOT NULL,

    carrier VARCHAR(100),
    tracking_number TEXT,

    status VARCHAR(20) DEFAULT 'PENDING',

    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
exports.createShipment = async (req, res) => {
  const { order_id, carrier, tracking_number } = req.body;

  const result = await pool.query(
    `
    INSERT INTO shipments
    (order_id, carrier, tracking_number, status)
    VALUES ($1,$2,$3,'SHIPPED')
    RETURNING *
    `,
    [order_id, carrier, tracking_number]
  );

  res.json(result.rows[0]);
};
UPDATE orders
SET status='SHIPPED'
WHERE order_id=$1
CREATE TABLE product_variants (
    variant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID NOT NULL,

    size VARCHAR(50),
    color VARCHAR(50),

    sku TEXT UNIQUE,
    price_override DECIMAL(12,2),

    stock_quantity INTEGER DEFAULT 0,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);
exports.searchProducts = async (req, res) => {
  const {
    q,
    category,
    min,
    max
  } = req.query;

  const result = await pool.query(
    `
    SELECT *
    FROM products
    WHERE ($1 = '' OR title ILIKE '%' || $1 || '%')
    AND ($2::uuid IS NULL OR category_id = $2)
    AND price BETWEEN COALESCE($3, 0) AND COALESCE($4, 999999)
    `,
    [q || '', category || null, min, max]
  );

  res.json(result.rows);
};
CREATE TABLE reviews (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID NOT NULL,
    user_id UUID NOT NULL,

    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
exports.addReview = async (req, res) => {
  const user_id = req.user.user_id;
  const { product_id, rating, comment } = req.body;

  const result = await pool.query(
    `
    INSERT INTO reviews
    (product_id, user_id, rating, comment)
    VALUES ($1,$2,$3,$4)
    RETURNING *
    `,
    [product_id, user_id, rating, comment]
  );

  res.json(result.rows[0]);
};
SELECT *
FROM reviews
WHERE product_id = $1;
npm install nodemailer
const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL,
    pass: process.env.EMAIL_PASSWORD
  }
});
exports.sendEmail = async (to, subject, text) => {
  await transporter.sendMail({
    from: process.env.EMAIL,
    to,
    subject,
    text
  });
};
sendEmail(
  user.email,
  "Order Confirmed",
  "Your order has been placed successfully."
);
sendEmail(
  user.email,
  "Your order shipped",
  `Tracking number: ${tracking_number}`
);
Products + Variants
Search + Filters
Reviews
Cart + Checkout
Seller listings
const adminOnly = (req, res, next) => {
  if (req.user.role !== "ADMIN") {
    return res.status(403).json({ message: "Forbidden" });
  }
  next();
};
router.get("/stats", auth, adminOnly, getStats);
router.get("/users", auth, adminOnly, getUsers);
router.get("/orders", auth, adminOnly, getOrders);
router.get("/products/pending", auth, adminOnly, getPendingProducts);
exports.getStats = async (req, res) => {
  const users = await pool.query("SELECT COUNT(*) FROM users");
  const orders = await pool.query("SELECT COUNT(*) FROM orders");
  const revenue = await pool.query(`
    SELECT COALESCE(SUM(total_amount),0) FROM orders WHERE status='PAID'
  `);

  res.json({
    users: users.rows[0].count,
    orders: orders.rows[0].count,
    revenue: revenue.rows[0].coalesce
  });
};
export default function AdminDashboard() {
  const [stats, setStats] = useState({});

  useEffect(() => {
    api("/admin/stats").then(setStats);
  }, []);

  return (
    <div>
      <h2>Admin Dashboard</h2>
      <p>Users: {stats.users}</p>
      <p>Orders: {stats.orders}</p>
      <p>Revenue: ${stats.revenue}</p>
    </div>
  );
}
npm install socket.io
const http = require("http");
const { Server } = require("socket.io");

const server = http.createServer(app);

const io = new Server(server, {
  cors: { origin: "*" }
});

io.on("connection", (socket) => {
  console.log("User connected:", socket.id);
});
const notifyUser = (userId, message) => {
  io.to(userId).emit("notification", message);
};
socket.emit("join", userId);
npm install aws-sdk multer-s3
const AWS = require("aws-sdk");

const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_KEY,
  secretAccessKey: process.env.AWS_SECRET,
  region: "us-east-1"
});
const multer = require("multer");
const multerS3 = require("multer-s3");

const upload = multer({
  storage: multerS3({
    s3,
    bucket: "your-marketplace-bucket",
    key: function (req, file, cb) {
      cb(null, Date.now().toString() + "-" + file.originalname);
    }
  })
});
LOCAL STORAGE ❌ (breaks in production)
S3 STORAGE   ✅ (scalable + global CDN-ready)
exports.refundPayment = async (req, res) => {
  const stripe = require("../config/stripe");

  const { payment_intent } = req.body;

  const refund = await stripe.refunds.create({
    payment_intent
  });

  await pool.query(
    "UPDATE orders SET status='REFUNDED' WHERE payment_intent=$1",
    [payment_intent]
  );

  res.json(refund);
};
router.post("/refund", auth, adminOnly, refundPayment);
if (event.type === "charge.refunded") {
  // mark order refunded
}
const fraudCheck = (order, user) => {

  if (order.total_amount > 5000) {
    return "HIGH_VALUE";
  }

  if (user.risk_score > 80) {
    return "BLOCK";
  }

  return "OK";
};
ALTER TABLE users ADD COLUMN risk_score INTEGER DEFAULT 0;
ALTER TABLE orders ADD COLUMN risk_flag TEXT;
const risk = fraudCheck(order, user);

if (risk === "BLOCK") {
  throw new Error("Transaction blocked");
}
SELECT
  COUNT(*) AS total_orders,
  SUM(total_amount) AS revenue,
  AVG(total_amount) AS avg_order
FROM orders
WHERE status='PAID';
SELECT
  DATE(created_at),
  SUM(total_amount)
FROM orders
GROUP BY DATE(created_at)
ORDER BY DATE(created_at);
export default function Analytics() {
  const [data, setData] = useState([]);

  useEffect(() => {
    api("/admin/analytics").then(setData);
  }, []);

  return (
    <div>
      <h2>Analytics</h2>

      {data.map(d => (
        <div key={d.date}>
          {d.date} - ${d.sum}
        </div>
      ))}
    </div>
  );
}
FRONTEND (React)
  ├── Admin Dashboard
  ├── Seller Dashboard
  ├── Marketplace UI
  └── Checkout (Stripe)

BACKEND (Node)
  ├── Auth (JWT)
  ├── Orders
  ├── Payments (Stripe + Webhooks)
  ├── Inventory
  ├── Fraud Engine
  ├── Analytics
  └── WebSockets

INFRASTRUCTURE
  ├── S3 Image Storage
  ├── Stripe Payments
  ├── PostgreSQL DB
  └── Real-time Events
