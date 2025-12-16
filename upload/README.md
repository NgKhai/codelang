# CodeLang MongoDB Data Upload

This folder contains Python scripts to upload exercise data to MongoDB Atlas.

## Setup

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure MongoDB connection:**
   ```bash
   copy .env.example .env
   ```
   Then edit `.env` and add your MongoDB connection string.

3. **Run the upload script:**
   ```bash
   python upload_data.py
   ```

## Data Collections

The script creates the following collections:

| Collection | Description | Count |
|------------|-------------|-------|
| `reorder_exercises` | Translation reorder exercises | 5 |
| `multiple_choice_exercises` | Vocabulary & grammar questions | 5 |
| `fill_blank_exercises` | Fill in the blank exercises | 5 |
| `flash_cards` | Vocabulary flash cards | 10 |
| `exercise_sets` | Grouped exercise sets | 5 |

## Notes

- Running the script will **clear and replace** all existing data in these collections
- Make sure your MongoDB user has write permissions to the database
