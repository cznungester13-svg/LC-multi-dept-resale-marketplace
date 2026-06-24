const express = require("express");
const router = express.Router();
const db = require("../db");

// GET all products
router.get("/", async (req, res) => {
    try {
        const result = await db.query("SELECT * FROM products ORDER BY created_at DESC");
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// CREATE product
router.post("/", async (req, res) => {
    const { seller_id, category_id, brand_id, title, description, base_price } = req.body;
    try {
        const result = await db.query(
            `INSERT INTO products (seller_id, category_id, brand_id, title, description, base_price) 
             VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
            [seller_id, category_id, brand_id, title, description, base_price]
        );
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
