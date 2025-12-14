// src/tests/alc_test_cases.js
// Test cases for Active Lingo Coach API

/**
 * Test cases for the ALC /api/alc/analyze endpoint
 * 
 * Run these manually with curl or use with a test framework
 */

const testCases = [
    // ============================================================
    // VIETNAMESE INPUT TESTS
    // ============================================================
    {
        name: "Vietnamese - Bug Report (Casual)",
        input: {
            text: "Cái API login cho user cũ nó bị lỗi 500 đó, fix đi."
        },
        expectedFields: ["originalIntent", "detectedLanguage", "professionalScore", "suggestion"],
        expectedLanguage: "vietnamese",
        expectedScoreRange: { min: 10, max: 40 }
    },
    {
        name: "Vietnamese - Feature Request",
        input: {
            text: "Em muốn thêm chức năng dark mode cho app"
        },
        expectedFields: ["originalIntent", "detectedLanguage", "professionalScore", "suggestion"],
        expectedLanguage: "vietnamese"
    },
    {
        name: "Vietnamese - Code Review",
        input: {
            text: "Code này viết dở quá, cần sửa lại"
        },
        expectedFields: ["originalIntent", "professionalScore", "critique"],
        expectedLanguage: "vietnamese"
    },

    // ============================================================
    // BROKEN ENGLISH TESTS
    // ============================================================
    {
        name: "Broken English - Simple",
        input: {
            text: "this code bad, need change"
        },
        expectedLanguage: "broken_english",
        expectedScoreRange: { min: 10, max: 30 }
    },
    {
        name: "Broken English - Bug Report",
        input: {
            text: "button click not work, page crash always"
        },
        expectedLanguage: "broken_english"
    },
    {
        name: "Broken English - Asking for Help",
        input: {
            text: "how to make this work? i try many thing but fail"
        },
        expectedLanguage: "broken_english"
    },

    // ============================================================
    // CASUAL ENGLISH TESTS
    // ============================================================
    {
        name: "Casual English - Demanding Tone",
        input: {
            text: "Fix this ASAP, it's blocking everything!"
        },
        expectedLanguage: "casual_english",
        expectedScoreRange: { min: 30, max: 50 }
    },
    {
        name: "Casual English - Vague Feedback",
        input: {
            text: "I don't like how this looks, make it better"
        },
        expectedLanguage: "casual_english"
    },
    {
        name: "Casual English - Slang",
        input: {
            text: "yo this feature is lowkey broken lol"
        },
        expectedLanguage: "casual_english"
    },

    // ============================================================
    // COMMUNICATION TYPE CONTEXT TESTS
    // ============================================================
    {
        name: "With Communication Type - Email",
        input: {
            text: "meeting tomorrow?",
            communicationType: "email"
        },
        expectedFields: ["suggestion", "alternativeVersions"]
    },
    {
        name: "With Communication Type - Slack",
        input: {
            text: "can someone help with this issue",
            communicationType: "slack"
        },
        expectedFields: ["suggestedCommunicationType"]
    },
    {
        name: "With Communication Type - PR Comment",
        input: {
            text: "this is wrong",
            communicationType: "pr_comment"
        },
        expectedFields: ["suggestedCommunicationType", "suggestion"]
    },

    // ============================================================
    // EDGE CASES
    // ============================================================
    {
        name: "Edge Case - Very Short Input",
        input: {
            text: "help"
        },
        shouldSucceed: true
    },
    {
        name: "Edge Case - Mixed Languages",
        input: {
            text: "API này return null, không biết sao fix"
        },
        expectedLanguage: "vietnamese"
    },
    {
        name: "Edge Case - Already Professional",
        input: {
            text: "I've noticed a potential memory leak in the authentication module. Would you mind reviewing my analysis in the attached document?"
        },
        expectedScoreRange: { min: 70, max: 100 }
    },

    // ============================================================
    // ERROR CASES
    // ============================================================
    {
        name: "Error - Empty String",
        input: {
            text: ""
        },
        shouldFail: true,
        expectedError: "Text cannot be empty"
    },
    {
        name: "Error - Missing Text",
        input: {},
        shouldFail: true,
        expectedError: "Text is required"
    },
    {
        name: "Error - Text Too Long",
        input: {
            text: "a".repeat(5001)
        },
        shouldFail: true,
        expectedError: "5000 characters or less"
    }
];

/**
 * Run a single test case
 */
async function runTest(testCase, baseUrl = 'http://localhost:3000') {
    console.log(`\n🧪 Testing: ${testCase.name}`);
    console.log(`   Input: "${JSON.stringify(testCase.input).substring(0, 80)}..."`);

    try {
        const response = await fetch(`${baseUrl}/api/alc/analyze`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(testCase.input)
        });

        const data = await response.json();

        if (testCase.shouldFail) {
            if (!response.ok && data.error) {
                console.log(`   ✅ Expected error received: ${data.error}`);
                return { passed: true };
            } else {
                console.log(`   ❌ Expected error but request succeeded`);
                return { passed: false };
            }
        }

        if (!response.ok) {
            console.log(`   ❌ Request failed: ${data.error}`);
            return { passed: false };
        }

        // Validate expected fields
        if (testCase.expectedFields) {
            for (const field of testCase.expectedFields) {
                if (!(field in data)) {
                    console.log(`   ❌ Missing expected field: ${field}`);
                    return { passed: false };
                }
            }
        }

        // Validate expected language
        if (testCase.expectedLanguage && data.detectedLanguage !== testCase.expectedLanguage) {
            console.log(`   ⚠️ Language mismatch: expected ${testCase.expectedLanguage}, got ${data.detectedLanguage}`);
        }

        // Validate score range
        if (testCase.expectedScoreRange) {
            const score = data.professionalScore;
            if (score < testCase.expectedScoreRange.min || score > testCase.expectedScoreRange.max) {
                console.log(`   ⚠️ Score ${score} outside expected range [${testCase.expectedScoreRange.min}-${testCase.expectedScoreRange.max}]`);
            }
        }

        console.log(`   ✅ Passed - Score: ${data.professionalScore}, Language: ${data.detectedLanguage}`);
        console.log(`   📝 Suggestion: "${data.suggestion?.substring(0, 100)}..."`);

        return { passed: true, data };

    } catch (error) {
        console.log(`   ❌ Error: ${error.message}`);
        return { passed: false, error };
    }
}

/**
 * Run all test cases
 */
async function runAllTests(baseUrl = 'http://localhost:3000') {
    console.log('═══════════════════════════════════════════════════════');
    console.log('       ACTIVE LINGO COACH - API TEST SUITE');
    console.log('═══════════════════════════════════════════════════════');

    let passed = 0;
    let failed = 0;

    for (const testCase of testCases) {
        const result = await runTest(testCase, baseUrl);
        if (result.passed) {
            passed++;
        } else {
            failed++;
        }
    }

    console.log('\n═══════════════════════════════════════════════════════');
    console.log(`       RESULTS: ${passed} passed, ${failed} failed`);
    console.log('═══════════════════════════════════════════════════════\n');

    return { passed, failed };
}

// Export for use in other files or run directly
module.exports = { testCases, runTest, runAllTests };

// Run tests if executed directly
if (require.main === module) {
    runAllTests().then(({ passed, failed }) => {
        process.exit(failed > 0 ? 1 : 0);
    });
}
