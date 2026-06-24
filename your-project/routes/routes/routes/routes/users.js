const express = require("express");
const router = express.Router();
const db = require("../db");

// CREATE user (Signup)
router.post("/", async (req, res) => {
    const { name, email, password_hash } = req.body;
    try {
        const result = await db.query(
            `INSERT INTO users (name, email, password_hash, role) VALUES ($1, $2, $3, 'customer') RETURNING id, name, email`,
            [name, email, password_hash]
        );
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
