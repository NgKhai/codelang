// src/routes/alc.js
// Active Lingo Coach routes

const express = require('express');
const router = express.Router();
const alcController = require('../controllers/alcController');

// POST /api/alc/analyze - Analyze text and provide improvement suggestions
// No authentication required - open to all users
router.post('/analyze', alcController.analyze);

module.exports = router;
