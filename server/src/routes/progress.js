// src/routes/progress.js
// User flashcard progress routes (protected)

const express = require('express');
const router = express.Router();

const progressController = require('../controllers/progressController');
const { authenticateToken } = require('../middleware/auth');

// All progress routes require authentication
router.use(authenticateToken);

/**
 * @route   GET /api/progress/:deckId
 * @desc    Get all progress for a deck
 * @access  Private
 */
router.get('/:deckId', progressController.getUserDeckProgress);

/**
 * @route   GET /api/progress/card/:flashCardId
 * @desc    Get progress for a single card
 * @access  Private
 */
router.get('/card/:flashCardId', progressController.getCardProgress);

/**
 * @route   PUT /api/progress/card/:flashCardId
 * @desc    Update progress for a card
 * @access  Private
 */
router.put('/card/:flashCardId', progressController.updateCardProgress);

/**
 * @route   GET /api/progress/stats/:deckId
 * @desc    Get deck statistics (query: totalCards)
 * @access  Private
 */
router.get('/stats/:deckId', progressController.getDeckStats);

/**
 * @route   POST /api/progress/batch
 * @desc    Batch update progress for multiple cards
 * @access  Private
 */
router.post('/batch', progressController.batchUpdateProgress);

module.exports = router;
