// src/controllers/progressController.js
// User flashcard progress management (SM-2 algorithm support)

const { getCollection, Collections } = require('../config/database');

/**
 * Get all progress records for a user in a specific deck
 */
async function getUserDeckProgress(req, res, next) {
    try {
        const { userId } = req.user;
        const { deckId } = req.params;

        const collection = getCollection(Collections.USER_FLASHCARD_PROGRESS);
        const progress = await collection
            .find({ odUserId: userId, deckId })
            .toArray();

        res.json(progress);

    } catch (error) {
        next(error);
    }
}

/**
 * Get progress for a single card
 */
async function getCardProgress(req, res, next) {
    try {
        const { userId } = req.user;
        const { flashCardId } = req.params;

        const collection = getCollection(Collections.USER_FLASHCARD_PROGRESS);
        const progress = await collection.findOne({
            odUserId: userId,
            flashCardId
        });

        if (!progress) {
            // Return initial state if no progress exists
            return res.json({
                odUserId: userId,
                flashCardId,
                status: 'newCard',
                repetitions: 0,
                easeFactor: 2.5,
                intervalDays: 0,
                nextReviewDate: new Date().toISOString(),
                lastReviewDate: new Date().toISOString(),
            });
        }

        res.json(progress);

    } catch (error) {
        next(error);
    }
}

/**
 * Update card progress (upsert)
 */
async function updateCardProgress(req, res, next) {
    try {
        const { userId } = req.user;
        const { flashCardId } = req.params;
        const progressData = req.body;

        if (!progressData.deckId) {
            return res.status(400).json({ error: 'deckId is required' });
        }

        const collection = getCollection(Collections.USER_FLASHCARD_PROGRESS);

        // Check if progress exists
        const existing = await collection.findOne({
            odUserId: userId,
            flashCardId
        });

        const updateData = {
            status: progressData.status,
            repetitions: progressData.repetitions,
            easeFactor: progressData.easeFactor,
            intervalDays: progressData.intervalDays,
            nextReviewDate: progressData.nextReviewDate,
            lastReviewDate: progressData.lastReviewDate,
        };

        if (existing) {
            // Update existing
            await collection.updateOne(
                { _id: existing._id },
                { $set: updateData }
            );
        } else {
            // Insert new
            await collection.insertOne({
                odUserId: userId,
                deckId: progressData.deckId,
                flashCardId,
                ...updateData,
            });
        }

        // Get updated record
        const updated = await collection.findOne({
            odUserId: userId,
            flashCardId
        });

        res.json(updated);

    } catch (error) {
        next(error);
    }
}

/**
 * Get deck progress statistics
 */
async function getDeckStats(req, res, next) {
    try {
        const { userId } = req.user;
        const { deckId } = req.params;
        const totalCards = parseInt(req.query.totalCards) || 0;

        const collection = getCollection(Collections.USER_FLASHCARD_PROGRESS);
        const progressList = await collection
            .find({ odUserId: userId, deckId })
            .toArray();

        let newCount = 0;
        let learningCount = 0;
        let reviewingCount = 0;
        let masteredCount = 0;
        let dueCount = 0;
        const now = new Date();

        for (const progress of progressList) {
            const status = progress.status || 'newCard';

            switch (status) {
                case 'newCard':
                    newCount++;
                    break;
                case 'learning':
                    learningCount++;
                    break;
                case 'reviewing':
                    reviewingCount++;
                    break;
                case 'mastered':
                    masteredCount++;
                    break;
            }

            // Check if due for review
            if (progress.nextReviewDate) {
                const nextReview = new Date(progress.nextReviewDate);
                if (now > nextReview) {
                    dueCount++;
                }
            }
        }

        // Cards with no progress record are 'new'
        const trackedCards = progressList.length;
        const untrackedNewCards = totalCards - trackedCards;
        newCount += untrackedNewCards;

        res.json({
            newCount,
            learningCount,
            reviewingCount,
            masteredCount,
            dueForReviewCount: dueCount,
        });

    } catch (error) {
        next(error);
    }
}

/**
 * Batch update progress for multiple cards
 */
async function batchUpdateProgress(req, res, next) {
    try {
        const { userId } = req.user;
        const { progressUpdates } = req.body;

        if (!progressUpdates || !Array.isArray(progressUpdates)) {
            return res.status(400).json({ error: 'progressUpdates array is required' });
        }

        const collection = getCollection(Collections.USER_FLASHCARD_PROGRESS);
        const results = [];

        for (const update of progressUpdates) {
            const { flashCardId, deckId, ...progressData } = update;

            if (!flashCardId || !deckId) continue;

            const existing = await collection.findOne({
                odUserId: userId,
                flashCardId
            });

            if (existing) {
                await collection.updateOne(
                    { _id: existing._id },
                    { $set: progressData }
                );
            } else {
                await collection.insertOne({
                    odUserId: userId,
                    deckId,
                    flashCardId,
                    ...progressData,
                });
            }

            results.push({ flashCardId, success: true });
        }

        res.json({ updated: results.length, results });

    } catch (error) {
        next(error);
    }
}

module.exports = {
    getUserDeckProgress,
    getCardProgress,
    updateCardProgress,
    getDeckStats,
    batchUpdateProgress,
};
