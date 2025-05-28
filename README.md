# The Music Besties

A personalized concierge application that helps users find their music tribe through AI-driven curation and matching.

## Project Overview

This project implements a hybrid conversational-visual user interface with the following features:

- Progressive Web App (PWA) accessible via web browser
- Core chat interface for AI interaction
- Contextual Input Module for collecting user information
- Sideboard Display for visualizations and content
- Collapsible Exchange Units for organizing conversation history

## Tech Stack

### Frontend
- **Nuxt.js 3**: Vue.js framework with SSR capabilities
- **Vue 3**: Component-based UI framework
- **Tailwind CSS**: Utility-first CSS framework (via Nuxt UI)

### Backend
- **FastAPI**: Modern Python web framework
- **CrewAI**: AI agent framework for orchestrating LLM interactions
- **Supabase**: Database and authentication provider

## Project Structure

```
/
├── components/         # Vue components
├── services/           # API services
├── backend/            # FastAPI backend
│   ├── main.py         # Main FastAPI application
│   └── agents.py       # CrewAI agent definitions
└── public/             # Static assets
```

## Setup Instructions

### Frontend Setup

1. Install dependencies:

```bash
npm install
```

2. Create a `.env` file in the root directory with the following variables:

```
VUE_APP_FASTAPI_URL=http://localhost:8000
VUE_APP_SUPABASE_URL=your_supabase_project_url
VUE_APP_SUPABASE_KEY=your_supabase_public_api_key
```

3. Start the development server:

```bash
npm run dev
```

### Backend Setup

1. Navigate to the backend directory:

```bash
cd backend
```

2. Create a virtual environment and activate it:

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:

```bash
pip install -r requirements.txt
```

4. Create a `.env` file in the backend directory with the following variables:

```
SUPABASE_URL=your_supabase_project_url
SUPABASE_KEY=your_supabase_public_api_key
OPENAI_API_KEY=your_openai_api_key
```

5. Start the FastAPI server:

```bash
uvicorn main:app --reload
```

## Deployment

### Frontend Deployment (Vercel)

1. Push your code to a GitHub repository
2. Connect the repository to Vercel
3. Configure environment variables in Vercel project settings

### Backend Deployment (Railway)

1. Push your code to a GitHub repository
2. Connect the repository to Railway
3. Configure environment variables in Railway project settings

## Phase 0 Implementation

The current implementation represents Phase 0 of the project, which includes:

- Basic Progressive Web App setup
- Core chat interface for user-AI interaction
- "Hello World" conversation sequence
- Contextual Input Module for collecting user's name
- Sideboard Display for showing welcome message
- Integration with FastAPI backend

Future phases will expand on this foundation to include music curation, personalization, and social features.
