// src/controllers/userController.js
// User management business logic

const { ObjectId } = require('mongodb');
const { getCollection, Collections } = require('../config/database');

/**
 * Get current user profile
 */
async function getCurrentUser(req, res, next) {
    try {
        const { userId } = req.user;

        const usersCollection = getCollection(Collections.USERS);
        const user = await usersCollection.findOne({
            _id: new ObjectId(userId)
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Get learned words count
        const progressCollection = getCollection(Collections.USER_FLASHCARD_PROGRESS);
        const learnedCount = await progressCollection.countDocuments({
            odUserId: userId,
            status: { $ne: 'newCard' },
        });

        const userResponse = {
            _id: user._id.toHexString(),
            email: user.email,
            name: user.name,
            photoUrl: user.photoUrl,
            currentStreak: user.currentStreak || 0,
            completedCourseIds: user.completedCourseIds || [],
            learnedWordsCount: learnedCount,
            lastCompletionDate: user.lastCompletionDate,
            createdAt: user.createdAt,
        };

        res.json(userResponse);

    } catch (error) {
        next(error);
    }
}

/**
 * Update user's name
 */
async function updateName(req, res, next) {
    try {
        const { userId } = req.user;
        const { name } = req.body;

        if (!name || name.trim().length === 0) {
            return res.status(400).json({ error: 'Name is required' });
        }

        const usersCollection = getCollection(Collections.USERS);

        await usersCollection.updateOne(
            { _id: new ObjectId(userId) },
            { $set: { name: name.trim() } }
        );

        // Get updated user
        const user = await usersCollection.findOne({ _id: new ObjectId(userId) });

        // Get learned words count
        const progressCollection = getCollection(Collections.USER_FLASHCARD_PROGRESS);
        const learnedCount = await progressCollection.countDocuments({
            odUserId: userId,
            status: { $ne: 'newCard' },
        });

        const userResponse = {
            _id: user._id.toHexString(),
            email: user.email,
            name: user.name,
            photoUrl: user.photoUrl,
            currentStreak: user.currentStreak || 0,
            completedCourseIds: user.completedCourseIds || [],
            learnedWordsCount: learnedCount,
            lastCompletionDate: user.lastCompletionDate,
            createdAt: user.createdAt,
        };

        console.log(`✅ User name updated: ${userId}`);
        res.json(userResponse);

    } catch (error) {
        next(error);
    }
}

/**
 * Complete daily streak
 */
async function completeStreak(req, res, next) {
    try {
        const { userId } = req.user;

        const usersCollection = getCollection(Collections.USERS);
        const user = await usersCollection.findOne({ _id: new ObjectId(userId) });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        const now = new Date();
        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

        // Parse last completion date
        let lastCompletionDate = null;
        if (user.lastCompletionDate) {
            lastCompletionDate = new Date(user.lastCompletionDate);
        }

        const lastCompletionDay = lastCompletionDate
            ? new Date(lastCompletionDate.getFullYear(), lastCompletionDate.getMonth(), lastCompletionDate.getDate())
            : null;

        // Check if already completed today
        if (lastCompletionDay && lastCompletionDay.getTime() === today.getTime()) {
            console.log(`🔥 Streak already completed today for user: ${userId}`);
            return res.json(await getFormattedUser(userId));
        }

        // Calculate new streak
        let currentStreak = user.currentStreak || 0;
        let newStreak;

        if (lastCompletionDay) {
            const yesterday = new Date(today);
            yesterday.setDate(yesterday.getDate() - 1);

            if (lastCompletionDay.getTime() === yesterday.getTime()) {
                newStreak = currentStreak + 1;
                console.log(`🔥 Streak incremented: ${currentStreak} -> ${newStreak}`);
            } else {
                newStreak = 1;
                console.log(`🔥 Streak reset to 1 (was ${currentStreak})`);
            }
        } else {
            newStreak = 1;
            console.log('🔥 First streak!');
        }

        // Update database
        await usersCollection.updateOne(
            { _id: new ObjectId(userId) },
            {
                $set: {
                    currentStreak: newStreak,
                    lastCompletionDate: now.toISOString(),
                }
            }
        );

        res.json(await getFormattedUser(userId));

    } catch (error) {
        next(error);
    }
}

/**
 * Complete a course
 */
async function completeCourse(req, res, next) {
    try {
        const { userId } = req.user;
        const { courseId } = req.body;

        if (!courseId) {
            return res.status(400).json({ error: 'courseId is required' });
        }

        const usersCollection = getCollection(Collections.USERS);
        const user = await usersCollection.findOne({ _id: new ObjectId(userId) });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        const completedCourses = user.completedCourseIds || [];

        // Check if already completed
        if (completedCourses.includes(courseId)) {
            console.log(`📚 Course ${courseId} already completed`);
            return res.json(await getFormattedUser(userId));
        }

        // Add to completed list
        await usersCollection.updateOne(
            { _id: new ObjectId(userId) },
            { $push: { completedCourseIds: courseId } }
        );

        console.log(`📚 Course ${courseId} marked as completed`);
        res.json(await getFormattedUser(userId));

    } catch (error) {
        next(error);
    }
}

/**
 * Helper to get formatted user response
 */
async function getFormattedUser(userId) {
    const usersCollection = getCollection(Collections.USERS);
    const user = await usersCollection.findOne({ _id: new ObjectId(userId) });

    const progressCollection = getCollection(Collections.USER_FLASHCARD_PROGRESS);
    const learnedCount = await progressCollection.countDocuments({
        odUserId: userId,
        status: { $ne: 'newCard' },
    });

    return {
        _id: user._id.toHexString(),
        email: user.email,
        name: user.name,
        photoUrl: user.photoUrl,
        currentStreak: user.currentStreak || 0,
        completedCourseIds: user.completedCourseIds || [],
        learnedWordsCount: learnedCount,
        lastCompletionDate: user.lastCompletionDate,
        createdAt: user.createdAt,
    };
}

module.exports = {
    getCurrentUser,
    updateName,
    completeStreak,
    completeCourse,
};
