# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

SkiIQ is an AI-powered ski technique analyzer based on the PSIA Alpine Technical Manual. Users upload a video or photo; the browser extracts up to 9 frames; a Netlify serverless function sends those frames to the Claude API; the response includes the best frame with a coaching overlay drawn on canvas.

## Deploying

Claude can commit and push directly — no terminal needed:

```bash
git add . && git commit -m "message" && git push
```

Netlify auto-deploys from the `main` branch on GitHub. Site: `nimble-dieffenbachia-8e087b.netlify.app`.

To add a Netlify API token (for build status checking), run:
```bash
claude mcp add netlify -e NETLIFY_TOKEN=<your-token> -- npx -y @netlify/mcp
```
Get the token from: Netlify dashboard → User settings → Applications → Personal access tokens.

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
2. Browser extracts up to 9 JPEG frames at 0.25s intervals via Canvas API (max 1024×1024, quality 0.75)
3. Brightness-based skier centering crops each frame around the darkest region
4. Frames + frameLabels POSTed as Base64 to `/.netlify/functions/analyze` with `language` field (`da`/`en`/`zh`)
5. Function uses PSIA Alpine Technical Manual knowledge base, calls `claude-opus-4-5` (max 1500 tokens)
6. Response JSON: `{ text, bestFrameIndex, bestFrameImage, overlayInstructions }`
7. Client draws `bestFrameImage` on canvas with LINE/ARROW/CIRCLE overlays; parses text into sections

**Response sections** (parsed by emoji/arrow headers):
`✓ WHAT I SEE` → `→ SKILL FOCUS` → `⬤ TRY THIS` → `💬 FEEL THIS`

## Key Constraints

- **Stateless** — no database, no sessions, no caching
- **API key is server-side only** — never referenced in `index.html`
- CORS is open (`*`) in the function
- Analysis methodology: PSIA Alpine Technical Manual (4 skills: Rotational Control, Edge Control, Pressure Control, Balance)
- Overlay coordinates are relative to 400×600 — scaled to actual canvas size in client
- UI supports three languages (Danish default, English, Chinese); all UI strings are in a `UI_TEXT` object in `index.html`
