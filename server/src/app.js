// src/app.js
// Express application setup with security middleware

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const exerciseRoutes = require('./routes/exercises');
const flashcardRoutes = require('./routes/flashcards');
const progressRoutes = require('./routes/progress');

// Import error handler
const errorHandler = require('./middleware/errorHandler');

const app = express();

// Security middleware
app.use(helmet()); // Security headers
app.use(cors({
    origin: '*', // Allow all origins for mobile app
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Performance middleware
app.use(compression()); // Compress responses
app.use(express.json({ limit: '10mb' })); // Parse JSON bodies
app.use(express.urlencoded({ extended: true }));

// Logging (skip in test environment)
if (process.env.NODE_ENV !== 'test') {
    app.use(morgan('dev'));
}

// Global rate limiting
const globalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 1000, // 1000 requests per 15 minutes
    message: { error: 'Too many requests, please try again later' },
});
app.use(globalLimiter);

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
    });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/exercises', exerciseRoutes);
app.use('/api/flashcards', flashcardRoutes);
app.use('/api/progress', progressRoutes);

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Route not found' });
});

// Error handler
app.use(errorHandler);

module.exports = app;
