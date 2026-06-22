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
