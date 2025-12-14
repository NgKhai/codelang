// --- 1. System Instruction (Defining the Role) ---
// This instructs the model to act as a senior technical lead reviewing communication.
const systemInstruction = `
You are an expert Technical Communication Coach (Active Lingo Coach) for software engineers. Your goal is to help non-native English speakers transform casual, vague, or unprofessional language into precise, polite, and industry-standard technical English.

Your task is to analyze the user's input (which may be in Vietnamese,
"broken" English, or casual English) and generate a coaching report.

You must evaluate the input based on:
1.  **Clarity:** Is the technical intent clear? (e.g.,
"It's broken" vs "It returns a 500 error").
2.  **Tone:** Is it professional and respectful? (e.g.,
"Fix it" vs "Please investigate").
3.  **Lingo:** Does it use standard industry terminology? (e.g.,
"Refactor",
"Deprecate",
"Latency").

You MUST return the result as a strictly formatted JSON object matching the provided schema.
`;

// --- 2. User Query (The Input Data) ---
// This is the raw text the user pastes into the ALC input box.
const userQuery = `
Analyze and improve this text: "Cái API login cho user cũ nó bị lỗi 500 đó, fix đi."
`;

// --- 3. Generation Configuration (The JSON Schema) ---
// This ensures the app receives structured data to display the score, feedback, and suggestion.
const generationConfig = {
    responseMimeType: "application/json",
    responseSchema: {
        type: "OBJECT",
        properties: {
            "originalIntent": {
                "type": "STRING",
                "description": "A brief summary of what the user was trying to say (in English)."
            },
            "professionalScore": {
                "type": "INTEGER",
                "description": "A score from 0 to 100 based on professionalism and clarity."
            },
            "critique": {
                "type": "STRING",
                "description": "Constructive feedback explaining why the original input was unprofessional (in Vietnamese, for better understanding)."
            },
            "suggestion": {
                "type": "STRING",
                "description": "The rewritten, highly professional version of the text in English."
            },
            "keyTermHighlight": {
                "type": "ARRAY",
                "items": {
                    "type": "STRING"
                },
                "description": "List of 2-3 key professional terms used in the suggestion (e.g., 'Legacy accounts', 'Internal Server Error')."
            }
        },
        "required": [
            "originalIntent",
            "professionalScore",
            "critique",
            "suggestion",
            "keyTermHighlight"
        ]
    }
};