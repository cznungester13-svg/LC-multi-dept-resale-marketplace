-- 1. Categories Table (Self-referencing for hierarchies)
CREATE TABLE categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    parent_category_id UUID,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- 2. Products Table
CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category_id UUID,
    condition VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 3. Product Images Table
CREATE TABLE product_images (
    image_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    image_url TEXT NOT NULL,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- 4. Inventory Table
CREATE TABLE inventory (
    inventory_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    quantity INTEGER NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);
const pool = require('../config/db'); // Path to your db pool configuration

// Create a new product listing
exports.createProduct = async (req, res) => {
  try {
    const seller_id = req.user.user_id;
    const { title, description, price, category_id, condition } = req.body;

    const result = await pool.query(
      'INSERT INTO products (seller_id, title, description, price, category_id, condition) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [seller_id, title, description, price, category_id, condition]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Product creation failed' });
  }
};

// Search products (Public lookup)
exports.searchProducts = async (req, res) => {
  try {
    const keyword = req.query.q || '';
    
    const result = await pool.query(
      'SELECT * FROM products WHERE title ILIKE $1',
      [`%${keyword}%`]
    );

    res.json(result.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Search failed' });
  }
};

// Get products belonging to the logged-in seller
exports.getSellerProducts = async (req, res) => {
  try {
    const seller_id = req.user.user_id;
    
    const result = await pool.query(
      'SELECT * FROM products WHERE seller_id = $1 ORDER BY created_at DESC',
      [seller_id]
    );
    
    res.json(result.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Update an owned product listing
exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, price, category_id, condition } = req.body;
    const seller_id = req.user.user_id;

    const result = await pool.query(
      'UPDATE products SET title = $1, description = $2, price = $3, category_id = $4, condition = $5 WHERE product_id = $6 AND seller_id = $7 RETURNING *',
      [title, description, price, category_id, condition, id, seller_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Product not found or unauthorized' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Delete an owned product listing
exports.deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const seller_id = req.user.user_id;

    const result = await pool.query(
      'DELETE FROM products WHERE product_id = $1 AND seller_id = $2 RETURNING *',
      [id, seller_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Product not found or unauthorized' });
    }

    res.json({ message: 'Product deleted successfully' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth'); // Path to your JWT authentication middleware
const {
  createProduct,
  searchProducts,
  getSellerProducts,
  updateProduct,
  deleteProduct
} = require('../controllers/productController');

// Public search
router.get('/search', searchProducts);

// Protected merchant operations
router.post('/', auth, createProduct);
router.get('/seller', auth, getSellerProducts);
router.put('/:id', auth, updateProduct);
router.delete('/:id', auth, deleteProduct);

module.exports = router;
export const apiFetch = async (endpoint, options = {}) => {
  const token = localStorage.getItem('token');
  
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const response = await fetch(endpoint, { ...options, headers });
  
  if (!response.ok) {
    throw new Error('API request failed');
  }
  
  return response.json();
};
import { useState, useEffect } from 'react';
import { apiFetch } from '../utils/api';

export const useFetch = (endpoint) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const result = await apiFetch(endpoint);
        setData(result);
      } catch (err) {
        setError(err.message || 'Something went wrong');
      } finally {
        setLoading(false);
      }
    };

    if (endpoint) {
      fetchData();
    }
  }, [endpoint]);

  return { data, loading, error };
};
