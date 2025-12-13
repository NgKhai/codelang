// src/config/auth.js
// JWT and authentication configuration

module.exports = {
    // JWT Access Token
    JWT_SECRET: process.env.JWT_SECRET || 'fallback-secret-change-in-production',
    JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '15m',

    // JWT Refresh Token
    JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET || 'fallback-refresh-secret-change-in-production',
    JWT_REFRESH_EXPIRES_IN: process.env.JWT_REFRESH_EXPIRES_IN || '7d',

    // Bcrypt salt rounds (12 is a good balance of security and performance)
    BCRYPT_SALT_ROUNDS: 12,

    // Rate limiting for auth endpoints
    AUTH_RATE_LIMIT: {
        windowMs: 15 * 60 * 1000, // 15 minutes
        max: 100, // 100 requests per window
        message: { error: 'Too many requests, please try again later' },
    },
};
