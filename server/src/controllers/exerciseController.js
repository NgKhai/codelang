// src/controllers/exerciseController.js
// Exercise management business logic

const { getCollection, Collections } = require('../config/database');

/**
 * Get all reorder exercises
 */
async function getReorderExercises(req, res, next) {
    try {
        const collection = getCollection(Collections.REORDER_EXERCISES);
        const exercises = await collection.find({}).toArray();
        res.json(exercises);
    } catch (error) {
        next(error);
    }
}

/**
 * Get all multiple choice exercises
 */
async function getMultipleChoiceExercises(req, res, next) {
    try {
        const collection = getCollection(Collections.MULTIPLE_CHOICE_EXERCISES);
        const exercises = await collection.find({}).toArray();
        res.json(exercises);
    } catch (error) {
        next(error);
    }
}

/**
 * Get multiple choice exercises by practice type
 */
async function getMultipleChoiceByType(req, res, next) {
    try {
        const { type } = req.params;
        const collection = getCollection(Collections.MULTIPLE_CHOICE_EXERCISES);
        const exercises = await collection.find({ practiceType: type }).toArray();
        res.json(exercises);
    } catch (error) {
        next(error);
    }
}

/**
 * Get all fill blank exercises
 */
async function getFillBlankExercises(req, res, next) {
    try {
        const collection = getCollection(Collections.FILL_BLANK_EXERCISES);
        const exercises = await collection.find({}).toArray();
        res.json(exercises);
    } catch (error) {
        next(error);
    }
}

/**
 * Get all exercise sets
 */
async function getExerciseSets(req, res, next) {
    try {
        const collection = getCollection(Collections.EXERCISE_SETS);
        const sets = await collection.find({}).toArray();
        res.json(sets);
    } catch (error) {
        next(error);
    }
}

/**
 * Get exercise set by ID with populated exercises
 */
async function getExerciseSetById(req, res, next) {
    try {
        const { setId } = req.params;

        const setsCollection = getCollection(Collections.EXERCISE_SETS);
        const set = await setsCollection.findOne({ setId });

        if (!set) {
            return res.status(404).json({ error: 'Exercise set not found' });
        }

        // Fetch all exercise types
        const reorderCollection = getCollection(Collections.REORDER_EXERCISES);
        const mcCollection = getCollection(Collections.MULTIPLE_CHOICE_EXERCISES);
        const fbCollection = getCollection(Collections.FILL_BLANK_EXERCISES);

        const [reorderData, mcData, fbData] = await Promise.all([
            reorderCollection.find({}).toArray(),
            mcCollection.find({}).toArray(),
            fbCollection.find({}).toArray(),
        ]);

        // Build exercises
        const exercises = [];
        const exerciseRefs = set.exercises || [];

        for (let i = 0; i < exerciseRefs.length; i++) {
            const ref = exerciseRefs[i];
            const type = ref.type;
            const index = ref.index;

            let exercise = null;

            switch (type) {
                case 'reorder':
                    if (index < reorderData.length) {
                        exercise = {
                            id: `${setId}_reorder_${i}`,
                            type: 'reorder',
                            data: reorderData[index],
                        };
                    }
                    break;
                case 'multiple_choice':
                    if (index < mcData.length) {
                        exercise = {
                            id: `${setId}_mc_${i}`,
                            type: 'multiple_choice',
                            data: mcData[index],
                        };
                    }
                    break;
                case 'fill_blank':
                    if (index < fbData.length) {
                        exercise = {
                            id: `${setId}_fb_${i}`,
                            type: 'fill_blank',
                            data: fbData[index],
                        };
                    }
                    break;
            }

            if (exercise) {
                exercises.push(exercise);
            }
        }

        res.json({
            setId: set.setId,
            name: set.name,
            exercises,
        });

    } catch (error) {
        next(error);
    }
}

/**
 * Get all courses with their exercises
 */
async function getAllCourses(req, res, next) {
    try {
        const setsCollection = getCollection(Collections.EXERCISE_SETS);
        const setsData = await setsCollection.find({}).toArray();

        // Fetch all exercise types in parallel
        const reorderCollection = getCollection(Collections.REORDER_EXERCISES);
        const mcCollection = getCollection(Collections.MULTIPLE_CHOICE_EXERCISES);
        const fbCollection = getCollection(Collections.FILL_BLANK_EXERCISES);

        const [reorderData, mcData, fbData] = await Promise.all([
            reorderCollection.find({}).toArray(),
            mcCollection.find({}).toArray(),
            fbCollection.find({}).toArray(),
        ]);

        const courses = [];

        for (const setData of setsData) {
            const exercises = [];
            const exerciseRefs = setData.exercises || [];

            for (let i = 0; i < exerciseRefs.length; i++) {
                const ref = exerciseRefs[i];
                const type = ref.type;
                const index = ref.index;

                let exercise = null;

                switch (type) {
                    case 'reorder':
                        if (index < reorderData.length) {
                            exercise = {
                                id: `${setData.setId}_reorder_${i}`,
                                type: 'reorder',
                                data: reorderData[index],
                            };
                        }
                        break;
                    case 'multiple_choice':
                        if (index < mcData.length) {
                            exercise = {
                                id: `${setData.setId}_mc_${i}`,
                                type: 'multiple_choice',
                                data: mcData[index],
                            };
                        }
                        break;
                    case 'fill_blank':
                        if (index < fbData.length) {
                            exercise = {
                                id: `${setData.setId}_fb_${i}`,
                                type: 'fill_blank',
                                data: fbData[index],
                            };
                        }
                        break;
                }

                if (exercise) {
                    exercises.push(exercise);
                }
            }

            courses.push({
                id: setData.setId,
                name: setData.name,
                exercises,
            });
        }

        res.json(courses);

    } catch (error) {
        next(error);
    }
}

/**
 * Get random exercises
 */
async function getRandomExercises(req, res, next) {
    try {
        const count = parseInt(req.query.count) || 10;

        // Fetch all exercises
        const reorderCollection = getCollection(Collections.REORDER_EXERCISES);
        const mcCollection = getCollection(Collections.MULTIPLE_CHOICE_EXERCISES);
        const fbCollection = getCollection(Collections.FILL_BLANK_EXERCISES);

        const [reorderData, mcData, fbData] = await Promise.all([
            reorderCollection.find({}).toArray(),
            mcCollection.find({}).toArray(),
            fbCollection.find({}).toArray(),
        ]);

        // Combine all exercises
        const allExercises = [
            ...reorderData.map((e, i) => ({
                id: `reorder_${i}`,
                type: 'reorder',
                data: e,
            })),
            ...mcData.map((e, i) => ({
                id: `multiple_choice_${i}`,
                type: 'multiple_choice',
                data: e,
            })),
            ...fbData.map((e, i) => ({
                id: `fill_blank_${i}`,
                type: 'fill_blank',
                data: e,
            })),
        ];

        // Shuffle array
        for (let i = allExercises.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [allExercises[i], allExercises[j]] = [allExercises[j], allExercises[i]];
        }

        // Return requested count
        res.json(allExercises.slice(0, count));

    } catch (error) {
        next(error);
    }
}

module.exports = {
    getReorderExercises,
    getMultipleChoiceExercises,
    getMultipleChoiceByType,
    getFillBlankExercises,
    getExerciseSets,
    getExerciseSetById,
    getAllCourses,
    getRandomExercises,
};
