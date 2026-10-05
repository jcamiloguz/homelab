# 07 · Super app (idea)

A single self-hosted app for my personal life admin, built by me, AI-native.

## Modules
| Module | MVP features |
|---|---|
| 💰 Finance | accounts, transactions (CSV import), categories, monthly budget, spend charts |
| 🛒 Shopping list | shared lists, quick add, recurring items, "bought" history |
| 📈 Portfolio | holdings, buy/sell transactions, price fetch, allocation & performance |
| ❤️ Health | weight, sleep, workouts, habits, notes; later import from wearables |

## Architecture (proposal)
```
browser / phone (PWA) ──► web app (TypeScript) ──► API ──► Postgres
                                                     ▲
Hermes Agent ──── MCP server ────────────────────────┘
```
- TypeScript monorepo (frontend + API + MCP server), Postgres (or SQLite to start).
- Built as an `arm64` Docker image, deployed via `services/super-app/compose.yml`.
- Auth: single user behind Tailscale first; proper auth later.
- MCP server lets the agent do things like *"add milk to the list"* or *"how much did I spend on food this month?"*.

## Rules
- Only fake seed data in the repo.
- Real data lives in `${DATA_DIR}/super-app` and is backed up.

## Open questions
- Framework (Next.js vs. Hono + React/Vite)?
- Monorepo inside this repo (`apps/super-app`) or separate repo?
- Bank import format(s) available.
