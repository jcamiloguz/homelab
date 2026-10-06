# 06 · Hermes Agent (idea)

**Goal:** run [Hermes Agent](https://github.com/NousResearch/hermes-agent) (Nous Research) on the Pi, using my **ChatGPT subscription** as the model provider instead of a paid API key.

## Plan
1. Install following the official README (verify the current install method at setup time).
2. Pick the OpenAI Codex / ChatGPT-login provider and complete the device-login flow.
3. Auth tokens stay in the agent's home dir — **never commit them**.
4. Connect messaging gateway (Telegram/Discord?) to talk to it from the phone.
5. Later: give it tools/MCP access to the [super app](07-super-app.md).

## Open questions
- Run in Docker or directly on host (needs access to tools/files)?
- Sandbox limits: what can the agent execute on the Pi?
- Local fallback model via Ollama on the 8 GB Pi (1–3B models)?
- ChatGPT plan usage limits when used via agent.
