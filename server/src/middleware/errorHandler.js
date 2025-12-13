// src/middleware/errorHandler.js
// Centralized error handling middleware

function errorHandler(err, req, res, next) {
    console.error('❌ Error:', err.message);

    // Default error status and message
    let statusCode = err.statusCode || 500;
    let message = err.message || 'Internal Server Error';

    // Handle specific error types
    if (err.name === 'ValidationError') {
        statusCode = 400;
        message = err.message;
    }

    if (err.name === 'JsonWebTokenError') {
        statusCode = 401;
        message = 'Invalid token';
    }

    if (err.name === 'TokenExpiredError') {
        statusCode = 401;
        message = 'Token expired';
    }

    if (err.code === 11000) {
        statusCode = 409;
        message = 'Duplicate entry';
    }

    // Don't leak error details in production
    const response = {
        error: message,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    };

    res.status(statusCode).json(response);
}

module.exports = errorHandler;
