// src/controllers/flashcardController.js
// Flashcard management business logic

const { getCollection, Collections } = require('../config/database');

/**
 * Get flashcards with pagination
 */
async function getFlashCards(req, res, next) {
    try {
        const page = parseInt(req.query.page) || 0;
        const limit = parseInt(req.query.limit) || 5;

        const collection = getCollection(Collections.FLASH_CARDS);

        const flashCards = await collection
            .find({})
            .skip(page * limit)
            .limit(limit)
            .toArray();

        res.json(flashCards);

    } catch (error) {
        next(error);
    }
}

/**
 * Get flashcard by ID
 */
async function getFlashCardById(req, res, next) {
    try {
        const { id } = req.params;

        const collection = getCollection(Collections.FLASH_CARDS);
        const flashCard = await collection.findOne({ flashCardId: id });

        if (!flashCard) {
            return res.status(404).json({ error: 'Flashcard not found' });
        }

        res.json(flashCard);

    } catch (error) {
        next(error);
    }
}

/**
 * Get total flashcards count
 */
async function getFlashCardsCount(req, res, next) {
    try {
        const collection = getCollection(Collections.FLASH_CARDS);
        const count = await collection.countDocuments({});
        res.json({ count });
    } catch (error) {
        next(error);
    }
}

/**
 * Get all flashcard decks
 */
async function getFlashCardDecks(req, res, next) {
    try {
        const collection = getCollection(Collections.FLASH_CARD_DECKS);
        const decks = await collection.find({}).toArray();
        res.json(decks);
    } catch (error) {
        next(error);
    }
}

/**
 * Get flashcard deck by ID with cards
 */
async function getFlashCardDeckById(req, res, next) {
    try {
        const { deckId } = req.params;

        const decksCollection = getCollection(Collections.FLASH_CARD_DECKS);
        const deck = await decksCollection.findOne({ deckId });

        if (!deck) {
            return res.status(404).json({ error: 'Deck not found' });
        }

        // Fetch cards for this deck
        const cardsCollection = getCollection(Collections.FLASH_CARDS);
        const cards = await cardsCollection
            .find({ flashCardId: { $in: deck.cardIds } })
            .toArray();

        res.json({
            ...deck,
            cards,
        });

    } catch (error) {
        next(error);
    }
}

/**
 * Get flashcards by list of IDs
 */
async function getFlashCardsByIds(req, res, next) {
    try {
        const { ids } = req.body;

        if (!ids || !Array.isArray(ids)) {
            return res.status(400).json({ error: 'ids array is required' });
        }

        const collection = getCollection(Collections.FLASH_CARDS);
        const flashCards = await collection
            .find({ flashCardId: { $in: ids } })
            .toArray();

        res.json(flashCards);

    } catch (error) {
        next(error);
    }
}

module.exports = {
    getFlashCards,
    getFlashCardById,
    getFlashCardsCount,
    getFlashCardDecks,
    getFlashCardDeckById,
    getFlashCardsByIds,
};
