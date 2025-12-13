// src/server.js
// Server entry point with graceful shutdown handling

require('dotenv').config();

const app = require('./app');
const { connectDB, disconnectDB } = require('./config/database');

const PORT = process.env.PORT || 3000;

let server;

async function startServer() {
    try {
        // Connect to MongoDB
        await connectDB();

        // Start server
        server = app.listen(PORT, () => {
            console.log(`🚀 Server running on port ${PORT}`);
            console.log(`📡 Environment: ${process.env.NODE_ENV || 'development'}`);
            console.log(`🔗 Health check: http://localhost:${PORT}/api/health`);
        });

        // Handle graceful shutdown
        setupGracefulShutdown();

    } catch (error) {
        console.error('❌ Failed to start server:', error);
        process.exit(1);
    }
}

function setupGracefulShutdown() {
    const signals = ['SIGTERM', 'SIGINT'];

    signals.forEach(signal => {
        process.on(signal, async () => {
            console.log(`\n📴 ${signal} received, shutting down gracefully...`);

            // Close HTTP server
            if (server) {
                server.close(() => {
                    console.log('✅ HTTP server closed');
                });
            }

            // Disconnect from database
            await disconnectDB();

            console.log('👋 Goodbye!');
            process.exit(0);
        });
    });

    // Handle uncaught exceptions
    process.on('uncaughtException', (error) => {
        console.error('❌ Uncaught Exception:', error);
        process.exit(1);
    });

    process.on('unhandledRejection', (reason, promise) => {
        console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
        process.exit(1);
    });
}

// Start the server
startServer();
