// src/routes/flashcards.js
// Flashcard routes (public)

const express = require('express');
const router = express.Router();

const flashcardController = require('../controllers/flashcardController');

/**
 * @route   GET /api/flashcards
 * @desc    Get flashcards with pagination (query: page, limit)
 * @access  Public
 */
router.get('/', flashcardController.getFlashCards);

/**
 * @route   GET /api/flashcards/count
 * @desc    Get total flashcards count
 * @access  Public
 */
router.get('/count', flashcardController.getFlashCardsCount);

/**
 * @route   GET /api/flashcards/decks
 * @desc    Get all flashcard decks
 * @access  Public
 */
router.get('/decks', flashcardController.getFlashCardDecks);

/**
 * @route   GET /api/flashcards/decks/:deckId
 * @desc    Get flashcard deck by ID with cards
 * @access  Public
 */
router.get('/decks/:deckId', flashcardController.getFlashCardDeckById);

/**
 * @route   POST /api/flashcards/by-ids
 * @desc    Get flashcards by list of IDs
 * @access  Public
 */
router.post('/by-ids', flashcardController.getFlashCardsByIds);

/**
 * @route   GET /api/flashcards/:id
 * @desc    Get flashcard by ID
 * @access  Public
 */
router.get('/:id', flashcardController.getFlashCardById);

module.exports = router;
