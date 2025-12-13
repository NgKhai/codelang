// src/routes/exercises.js
// Exercise routes (public)

const express = require('express');
const router = express.Router();

const exerciseController = require('../controllers/exerciseController');

/**
 * @route   GET /api/exercises/reorder
 * @desc    Get all reorder exercises
 * @access  Public
 */
router.get('/reorder', exerciseController.getReorderExercises);

/**
 * @route   GET /api/exercises/multiple-choice
 * @desc    Get all multiple choice exercises
 * @access  Public
 */
router.get('/multiple-choice', exerciseController.getMultipleChoiceExercises);

/**
 * @route   GET /api/exercises/multiple-choice/:type
 * @desc    Get multiple choice exercises by practice type
 * @access  Public
 */
router.get('/multiple-choice/:type', exerciseController.getMultipleChoiceByType);

/**
 * @route   GET /api/exercises/fill-blank
 * @desc    Get all fill blank exercises
 * @access  Public
 */
router.get('/fill-blank', exerciseController.getFillBlankExercises);

/**
 * @route   GET /api/exercises/sets
 * @desc    Get all exercise sets
 * @access  Public
 */
router.get('/sets', exerciseController.getExerciseSets);

/**
 * @route   GET /api/exercises/sets/:setId
 * @desc    Get exercise set by ID with exercises
 * @access  Public
 */
router.get('/sets/:setId', exerciseController.getExerciseSetById);

/**
 * @route   GET /api/exercises/courses
 * @desc    Get all courses with exercises
 * @access  Public
 */
router.get('/courses', exerciseController.getAllCourses);

/**
 * @route   GET /api/exercises/random
 * @desc    Get random exercises (query: count)
 * @access  Public
 */
router.get('/random', exerciseController.getRandomExercises);

module.exports = router;
