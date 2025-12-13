// src/middleware/auth.js
// JWT authentication middleware

const jwt = require('jsonwebtoken');
const { JWT_SECRET } = require('../config/auth');

/**
 * Verify JWT token middleware
 * Adds user info to req.user if valid
 */
function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
        return res.status(401).json({ error: 'Access token required' });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = {
            userId: decoded.userId,
            email: decoded.email,
        };
        next();
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({ error: 'Token expired', code: 'TOKEN_EXPIRED' });
        }
        return res.status(403).json({ error: 'Invalid token' });
    }
}

/**
 * Optional authentication - doesn't fail if no token
 * Useful for routes that work with or without auth
 */
function optionalAuth(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return next();
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = {
            userId: decoded.userId,
            email: decoded.email,
        };
    } catch (error) {
        // Invalid token, but continue without user info
    }

    next();
}

module.exports = {
    authenticateToken,
    optionalAuth,
};
