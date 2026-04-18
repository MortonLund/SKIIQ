# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

SkiIQ is an AI-powered ski technique analyzer. Users upload a video or photo; the browser extracts frames; a Netlify serverless function sends those frames to the Claude API with a detailed ski instruction prompt; the structured response is rendered back in the UI.

## Local Development

Requires the [Netlify CLI](https://docs.netlify.com/cli/get-started/):

```bash
netlify dev        # Serves static site + functions at localhost:8888
```

Set `ANTHROPIC_API_KEY` in a `.env` file or in Netlify's environment variable dashboard. The function reads `process.env.ANTHROPIC_API_KEY`.

There is no build step, no test suite, and no linter.

## Architecture

**Two files do all the work:**

- `index.html` — entire frontend (HTML + CSS + JS, no framework, no bundler)
- `netlify/functions/analyze.js` — serverless function that calls the Claude API

**Data flow:**
1. User uploads video or image
2. Browser extracts up to 10 JPEG frames via Canvas API (max 1024×1024, quality 0.75); images are duplicated 5× to simulate frames
3. Deduplicated frames (max 3 unique) are POSTed as Base64 to `/.netlify/functions/analyze` with a `language` field (`da`/`en`/`zh`)
4. The function builds a ~3 000-token system prompt based on the Danish Ski School (Den Danske Skiskole) D15 methodology and calls `claude-opus-4-5` (max 1 200 output tokens)
5. Structured response text is returned and parsed client-side into color-coded sections

**Response sections** (parsed by emoji/arrow headers):
`✓ STRENGTHS` → `→ FOCUS` → `⬅️ EXERCISE` → `↑ DEVELOPMENT CHAIN` → `💬 REMEMBER`

## Key Constraints

- **Stateless** — no database, no sessions, no caching
- **API key is server-side only** — never referenced in `index.html`
- CORS is open (`*`) in the function
- The D15 framework (8 development points: Flade Ski, For Stor Skridtstilling, Stive Skiled, Uhensigtsmæssige Bøjeforhold, Hofterotation, Overkropsrotation, Bagvægt, Indoverlæning) is hardcoded in the system prompt in `analyze.js`
- UI supports three languages (Danish default, English, Chinese); all UI strings are in a `translations` object in `index.html`
