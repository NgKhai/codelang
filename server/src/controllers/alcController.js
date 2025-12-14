// src/controllers/alcController.js
// Active Lingo Coach - Text Analysis with Gemini AI

const { GoogleGenerativeAI } = require('@google/generative-ai');

// Initialize Gemini AI
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// System instruction for the AI
const systemInstruction = `
You are an expert Technical Communication Coach (Active Lingo Coach) for software engineers. Your goal is to help non-native English speakers transform casual, vague, or unprofessional language into precise, polite, and industry-standard technical English.

Your task is to analyze the user's input (which may be in Vietnamese, "broken" English, or casual English) and generate a coaching report.

You must evaluate the input based on:
1. **Clarity:** Is the technical intent clear? (e.g., "It's broken" vs "It returns a 500 error").
2. **Tone:** Is it professional and respectful? (e.g., "Fix it" vs "Please investigate").
3. **Lingo:** Does it use standard industry terminology? (e.g., "Refactor", "Deprecate", "Latency").

EXAMPLES:

Input: "Cái API login cho user cũ nó bị lỗi 500 đó, fix đi."
Output:
{
  "originalIntent": "The user is reporting that the login API returns a 500 Internal Server Error for legacy/existing user accounts and is requesting a fix.",
  "detectedLanguage": "vietnamese",
  "professionalScore": 25,
  "clarityScore": 40,
  "toneScore": 20,
  "critique": "Câu này thiếu chuyên nghiệp vì: (1) Dùng ngôn ngữ quá casual như 'Cái API', 'fix đi'; (2) Không cung cấp đủ context như reproduction steps, error logs, hoặc priority; (3) Giọng điệu có phần ra lệnh thay vì request lịch sự.",
  "suggestion": "Hi team, we've identified an issue where the login endpoint returns a 500 Internal Server Error for legacy user accounts. Could someone please investigate this at your earliest convenience? I'm happy to provide additional logs or reproduction steps if needed.",
  "suggestedCommunicationType": "slack",
  "suggestedSeverity": "high",
  "keyTermHighlight": ["Internal Server Error", "legacy user accounts", "reproduction steps"],
  "alternativeVersions": [
    {
      "type": "formal_email",
      "text": "Subject: [BUG] Login API - 500 Error for Legacy Accounts\\n\\nHi Team,\\n\\nI've discovered an issue with our authentication system. The login endpoint is returning a 500 Internal Server Error when legacy user accounts attempt to authenticate.\\n\\nPriority: High\\n\\nPlease let me know if you need any additional information for debugging.\\n\\nBest regards"
    },
    {
      "type": "quick_slack",
      "text": "🔴 Found a bug: Login API throwing 500 for legacy accounts. Can someone take a look?"
    }
  ]
}

Input: "this code bad, need change"
Output:
{
  "originalIntent": "The user believes there is an issue with the code quality and wants it to be improved or refactored.",
  "detectedLanguage": "broken_english",
  "professionalScore": 15,
  "clarityScore": 20,
  "toneScore": 30,
  "critique": "Phản hồi này quá chung chung và không chuyên nghiệp vì: (1) Không chỉ rõ 'bad' nghĩa là gì - performance issue? bug? code style?; (2) Không đề xuất giải pháp cụ thể; (3) Câu văn không đầy đủ ngữ pháp.",
  "suggestion": "I've reviewed this code and noticed some areas that could be improved. Specifically, [describe the issue]. Would you be open to refactoring this section? I can submit a PR with the proposed changes.",
  "suggestedCommunicationType": "pr_comment",
  "suggestedSeverity": "medium",
  "keyTermHighlight": ["refactoring", "code review", "PR"],
  "alternativeVersions": [
    {
      "type": "formal_email",
      "text": "Subject: Code Review Feedback\\n\\nHi,\\n\\nI've completed my review of the recent changes. I've identified a few areas where we could improve code quality and maintainability. Would you have time to discuss potential refactoring opportunities?\\n\\nBest regards"
    },
    {
      "type": "quick_slack",
      "text": "Hey! Noticed some code that could use some love 🛠️ Mind if I suggest a refactor?"
    }
  ]
}

You MUST return the result as a strictly formatted JSON object.
`;

// JSON Schema for structured output
const responseSchema = {
    type: "object",
    properties: {
        originalIntent: {
            type: "string",
            description: "A brief summary of what the user was trying to say (in English)."
        },
        detectedLanguage: {
            type: "string",
            enum: ["vietnamese", "broken_english", "casual_english"],
            description: "The detected language/style of the input."
        },
        professionalScore: {
            type: "integer",
            description: "A score from 0 to 100 based on overall professionalism."
        },
        clarityScore: {
            type: "integer",
            description: "A score from 0 to 100 based on clarity of technical intent."
        },
        toneScore: {
            type: "integer",
            description: "A score from 0 to 100 based on professional tone."
        },
        critique: {
            type: "string",
            description: "Constructive feedback explaining why the original input was unprofessional (in Vietnamese, for better understanding)."
        },
        suggestion: {
            type: "string",
            description: "The rewritten, highly professional version of the text in English."
        },
        suggestedCommunicationType: {
            type: "string",
            enum: ["slack", "email", "pr_comment", "meeting_notes", "documentation"],
            description: "The suggested communication channel for this type of message."
        },
        suggestedSeverity: {
            type: "string",
            enum: ["critical", "high", "medium", "low"],
            description: "The suggested priority/severity level."
        },
        keyTermHighlight: {
            type: "array",
            items: { type: "string" },
            description: "List of 2-4 key professional terms used in the suggestion."
        },
        alternativeVersions: {
            type: "array",
            items: {
                type: "object",
                properties: {
                    type: { type: "string" },
                    text: { type: "string" }
                },
                required: ["type", "text"]
            },
            description: "Alternative versions for different contexts (formal email, quick slack, etc.)."
        }
    },
    required: [
        "originalIntent",
        "detectedLanguage",
        "professionalScore",
        "clarityScore",
        "toneScore",
        "critique",
        "suggestion",
        "suggestedCommunicationType",
        "suggestedSeverity",
        "keyTermHighlight",
        "alternativeVersions"
    ]
};

/**
 * Analyze text and provide professional improvement suggestions
 */
async function analyze(req, res, next) {
    try {
        const { text, communicationType } = req.body;

        // Validation
        if (!text || typeof text !== 'string') {
            return res.status(400).json({
                error: 'Text is required and must be a string'
            });
        }

        if (text.trim().length === 0) {
            return res.status(400).json({
                error: 'Text cannot be empty'
            });
        }

        if (text.length > 5000) {
            return res.status(400).json({
                error: 'Text must be 5000 characters or less'
            });
        }

        // Check for API key
        if (!process.env.GEMINI_API_KEY) {
            return res.status(500).json({
                error: 'Gemini API key not configured'
            });
        }

        // Build the prompt
        let userPrompt = `Analyze and improve this text: "${text}"`;
        if (communicationType) {
            userPrompt += `\n\nThe user intends to use this in a ${communicationType} context.`;
        }

        // Call Gemini API
        const model = genAI.getGenerativeModel({
            model: "gemini-flash-latest",
            systemInstruction: systemInstruction,
            generationConfig: {
                responseMimeType: "application/json",
                responseSchema: responseSchema,
                temperature: 0.7,
                maxOutputTokens: 2048,
            }
        });

        const result = await model.generateContent(userPrompt);
        const response = result.response;
        const responseText = response.text();

        // Parse JSON response
        let analysisResult;
        try {
            analysisResult = JSON.parse(responseText);
        } catch (parseError) {
            console.error('Failed to parse Gemini response:', responseText);
            return res.status(500).json({
                error: 'Failed to parse AI response'
            });
        }

        console.log(`✅ ALC analyzed text: "${text.substring(0, 50)}..."`);

        res.json(analysisResult);

    } catch (error) {
        console.error('❌ ALC analyze error:', error);

        // Handle specific Gemini API errors
        if (error.message?.includes('API_KEY')) {
            return res.status(500).json({
                error: 'Invalid Gemini API key'
            });
        }

        if (error.message?.includes('quota')) {
            return res.status(429).json({
                error: 'API quota exceeded. Please try again later.'
            });
        }

        next(error);
    }
}

module.exports = {
    analyze,
};
