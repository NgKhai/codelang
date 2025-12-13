// src/routes/users.js
// Protected user routes

const express = require('express');
const router = express.Router();

const userController = require('../controllers/userController');
const { authenticateToken } = require('../middleware/auth');

// All user routes require authentication
router.use(authenticateToken);

/**
 * @route   GET /api/users/me
 * @desc    Get current user profile
 * @access  Private
 */
router.get('/me', userController.getCurrentUser);

/**
 * @route   PUT /api/users/name
 * @desc    Update user's name
 * @access  Private
 */
router.put('/name', userController.updateName);

/**
 * @route   POST /api/users/streak
 * @desc    Complete daily streak
 * @access  Private
 */
router.post('/streak', userController.completeStreak);

/**
 * @route   POST /api/users/complete-course
 * @desc    Mark a course as completed
 * @access  Private
 */
router.post('/complete-course', userController.completeCourse);

module.exports = router;
