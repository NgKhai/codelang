// src/config/database.js
// MongoDB connection with connection pooling for efficient concurrent handling

const { MongoClient } = require('mongodb');

let client = null;
let db = null;

// Connection pool settings for high concurrency
const options = {
    maxPoolSize: 100,      // Maximum connections in pool
    minPoolSize: 5,        // Minimum connections maintained
    maxIdleTimeMS: 60000,  // Close idle connections after 60s
    waitQueueTimeoutMS: 30000, // Timeout for waiting connections
    serverSelectionTimeoutMS: 10000,
    socketTimeoutMS: 45000,
    retryWrites: true,
    retryReads: true,
};

/**
 * Connect to MongoDB with connection pooling
 */
async function connectDB() {
    if (db) {
        return db;
    }

    try {
        const mongoUrl = process.env.MONGO_URL;
        if (!mongoUrl) {
            throw new Error('MONGO_URL not found in environment variables');
        }

        // Database name - defaults to 'codelang'
        const dbName = process.env.DB_NAME || 'codelang';

        console.log('🔄 Connecting to MongoDB...');
        client = new MongoClient(mongoUrl, options);

        await client.connect();

        // Explicitly specify the database name
        db = client.db(dbName);

        // Verify connection
        await db.command({ ping: 1 });
        console.log('✅ MongoDB connected successfully');
        console.log(`📊 Database: ${dbName}`);
        console.log(`📊 Connection pool: min=${options.minPoolSize}, max=${options.maxPoolSize}`);

        return db;
    } catch (error) {
        console.error('❌ MongoDB connection error:', error.message);
        throw error;
    }
}

/**
 * Get the database instance
 */
function getDB() {
    if (!db) {
        throw new Error('Database not connected. Call connectDB() first.');
    }
    return db;
}

/**
 * Get a specific collection
 */
function getCollection(name) {
    return getDB().collection(name);
}

/**
 * Gracefully disconnect from MongoDB
 */
async function disconnectDB() {
    if (client) {
        console.log('🔄 Disconnecting from MongoDB...');
        await client.close();
        client = null;
        db = null;
        console.log('✅ MongoDB disconnected');
    }
}

/**
 * Collection names used in the application
 */
const Collections = {
    USERS: 'users',
    REORDER_EXERCISES: 'reorder_exercises',
    MULTIPLE_CHOICE_EXERCISES: 'multiple_choice_exercises',
    FILL_BLANK_EXERCISES: 'fill_blank_exercises',
    FLASH_CARDS: 'flash_cards',
    EXERCISE_SETS: 'exercise_sets',
    FLASH_CARD_DECKS: 'flash_card_decks',
    USER_FLASHCARD_PROGRESS: 'user_flashcard_progress',
    REFRESH_TOKENS: 'refresh_tokens',
};

module.exports = {
    connectDB,
    getDB,
    getCollection,
    disconnectDB,
    Collections,
};
