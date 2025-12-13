// src/controllers/authController.js
// Authentication business logic

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { ObjectId } = require('mongodb');
const { getCollection, Collections } = require('../config/database');
const {
    JWT_SECRET,
    JWT_EXPIRES_IN,
    JWT_REFRESH_SECRET,
    JWT_REFRESH_EXPIRES_IN,
    BCRYPT_SALT_ROUNDS,
} = require('../config/auth');

/**
 * Generate access and refresh tokens
 */
function generateTokens(userId, email) {
    const accessToken = jwt.sign(
        { userId, email },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN }
    );

    const refreshToken = jwt.sign(
        { userId, email, type: 'refresh' },
        JWT_REFRESH_SECRET,
        { expiresIn: JWT_REFRESH_EXPIRES_IN }
    );

    return { accessToken, refreshToken };
}

/**
 * Register new user
 */
async function register(req, res, next) {
    try {
        const { email, password, name } = req.body;

        // Validation
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }

        if (password.length < 6) {
            return res.status(400).json({ error: 'Password must be at least 6 characters' });
        }

        const usersCollection = getCollection(Collections.USERS);

        // Check if user exists
        const existingUser = await usersCollection.findOne({
            email: email.toLowerCase()
        });

        if (existingUser) {
            return res.status(409).json({ error: 'User already exists' });
        }

        // Hash password with bcrypt
        const hashedPassword = await bcrypt.hash(password, BCRYPT_SALT_ROUNDS);

        // Create user
        const newUser = {
            _id: new ObjectId(),
            email: email.toLowerCase(),
            password: hashedPassword,
            name: name || email.split('@')[0],
            authProvider: 'email',
            currentStreak: 0,
            completedCourseIds: [],
            learnedWordsCount: 0,
            lastCompletionDate: null,
            createdAt: new Date().toISOString(),
        };

        await usersCollection.insertOne(newUser);

        // Generate tokens
        const userId = newUser._id.toHexString();
        const { accessToken, refreshToken } = generateTokens(userId, newUser.email);

        // Store refresh token
        const refreshTokensCollection = getCollection(Collections.REFRESH_TOKENS);
        await refreshTokensCollection.insertOne({
            userId,
            token: refreshToken,
            createdAt: new Date(),
            expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
        });

        // Return user without password
        const userResponse = {
            _id: userId,
            email: newUser.email,
            name: newUser.name,
            currentStreak: newUser.currentStreak,
            completedCourseIds: newUser.completedCourseIds,
            learnedWordsCount: newUser.learnedWordsCount,
            createdAt: newUser.createdAt,
        };

        console.log(`✅ User registered: ${email}`);

        res.status(201).json({
            user: userResponse,
            accessToken,
            refreshToken,
        });

    } catch (error) {
        next(error);
    }
}

/**
 * Login user
 */
async function login(req, res, next) {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }

        const usersCollection = getCollection(Collections.USERS);

        // Find user
        const user = await usersCollection.findOne({
            email: email.toLowerCase()
        });

        if (!user) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        // Verify password
        const isValidPassword = await bcrypt.compare(password, user.password);

        if (!isValidPassword) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        // Generate tokens
        const userId = user._id.toHexString();
        const { accessToken, refreshToken } = generateTokens(userId, user.email);

        // Store refresh token
        const refreshTokensCollection = getCollection(Collections.REFRESH_TOKENS);
        await refreshTokensCollection.insertOne({
            userId,
            token: refreshToken,
            createdAt: new Date(),
            expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        });

        // Get learned words count
        const progressCollection = getCollection(Collections.USER_FLASHCARD_PROGRESS);
        const learnedCount = await progressCollection.countDocuments({
            odUserId: userId,
            status: { $ne: 'newCard' },
        });

        // Return user without password
        const userResponse = {
            _id: userId,
            email: user.email,
            name: user.name,
            photoUrl: user.photoUrl,
            currentStreak: user.currentStreak || 0,
            completedCourseIds: user.completedCourseIds || [],
            learnedWordsCount: learnedCount,
            lastCompletionDate: user.lastCompletionDate,
            createdAt: user.createdAt,
        };

        console.log(`✅ User logged in: ${email}`);

        res.json({
            user: userResponse,
            accessToken,
            refreshToken,
        });

    } catch (error) {
        next(error);
    }
}

/**
 * Refresh access token
 */
async function refreshToken(req, res, next) {
    try {
        const { refreshToken: token } = req.body;

        if (!token) {
            return res.status(400).json({ error: 'Refresh token required' });
        }

        // Verify refresh token
        let decoded;
        try {
            decoded = jwt.verify(token, JWT_REFRESH_SECRET);
        } catch (error) {
            return res.status(401).json({ error: 'Invalid refresh token' });
        }

        // Check if token exists in database
        const refreshTokensCollection = getCollection(Collections.REFRESH_TOKENS);
        const storedToken = await refreshTokensCollection.findOne({
            token,
            userId: decoded.userId,
        });

        if (!storedToken) {
            return res.status(401).json({ error: 'Refresh token not found or revoked' });
        }

        // Generate new tokens
        const { accessToken, refreshToken: newRefreshToken } = generateTokens(
            decoded.userId,
            decoded.email
        );

        // Replace old refresh token with new one
        await refreshTokensCollection.deleteOne({ token });
        await refreshTokensCollection.insertOne({
            userId: decoded.userId,
            token: newRefreshToken,
            createdAt: new Date(),
            expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        });

        res.json({
            accessToken,
            refreshToken: newRefreshToken,
        });

    } catch (error) {
        next(error);
    }
}

/**
 * Logout - invalidate refresh token
 */
async function logout(req, res, next) {
    try {
        const { refreshToken: token } = req.body;

        if (token) {
            const refreshTokensCollection = getCollection(Collections.REFRESH_TOKENS);
            await refreshTokensCollection.deleteOne({ token });
        }

        res.json({ message: 'Logged out successfully' });

    } catch (error) {
        next(error);
    }
}

module.exports = {
    register,
    login,
    refreshToken,
    logout,
};
