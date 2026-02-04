# Hacker News Posts

---

## Show HN Submission

### Title
```
Show HN: Token Optimizer – Reduced my OpenClaw costs from $200/month to $5
```

### URL
```
https://github.com/smartpeopleconnected/openclaw-token-optimizer
```

### Text (if self-post)
```
I was spending $200+/month on OpenClaw (Claude-based AI assistant). After analyzing the token usage, I found most of it was wasted:

1. Sonnet running for trivial tasks ("OK, done" responses)
2. Heartbeat checks hitting paid API every hour
3. 50KB of conversation history loaded on every message
4. No prompt caching enabled

Built a tool that fixes all of this:

- Routes simple tasks to Haiku (92% cheaper)
- Moves heartbeats to local Ollama (free)
- Reduces context from 50KB to 2KB
- Enables prompt caching (90% discount on repeated prompts)
- Adds budget controls

Result: $224/month → $1.88/month

It's packaged as a ClawHub skill:

    clawhub install token-optimizer

Or you can just tell your OpenClaw agent "find a skill to reduce my costs" and it discovers + installs it automatically.

MIT licensed. Would appreciate feedback on the approach.
```

---

## Comment Templates

### When AI costs are discussed
```
If you're using OpenClaw/Clawdbot, check your model routing. Default configs often use Sonnet for everything.

I built a tool that switches to Haiku for routine tasks + routes heartbeats to local Ollama. Went from $200/month to under $5.

https://github.com/smartpeopleconnected/openclaw-token-optimizer
```

### When someone mentions OpenClaw
```
Pro tip: Install token-optimizer before anything else. The default config is expensive.

    clawhub install token-optimizer

Switches to Haiku by default, free Ollama heartbeats, enables caching. 97% cost reduction.
```

### Technical discussion about LLM costs
```
The key optimizations that work:

1. Model routing - Haiku handles 80% of tasks fine (92% cheaper than Sonnet)
2. Local LLM for non-critical calls (heartbeats, status checks)
3. Prompt caching - huge savings on repeated system prompts
4. Context pruning - don't load 50KB when 2KB suffices

Packaged all of this for OpenClaw: https://github.com/smartpeopleconnected/openclaw-token-optimizer
```

---

## Ask HN Response

### If someone asks about reducing AI costs
```
For OpenClaw specifically:

1. Default model to Haiku, only escalate to Sonnet when needed
2. Route heartbeats to Ollama (free)
3. Trim your context - SOUL.md and USER.md should be under 5KB total
4. Enable prompt caching

I automated this: clawhub install token-optimizer

Before: $224/month, After: $1.88/month
```
