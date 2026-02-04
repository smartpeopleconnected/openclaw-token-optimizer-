# Product Hunt Launch

---

## Tagline (60 chars max)
```
Reduce OpenClaw AI costs by 97% in 5 minutes
```

## Description
```
Token Optimizer automatically configures your OpenClaw/Clawdbot setup for maximum cost efficiency.

**The Problem:**
OpenClaw defaults prioritize capability over cost. Users report $200+/month bills for basic usage.

**The Solution:**
One command that applies 4 proven optimizations:

🎯 **Model Routing** - Haiku for simple tasks (92% cheaper than Sonnet)
💚 **Free Heartbeats** - Route status checks to local Ollama
📦 **Lean Context** - Load 2KB instead of 50KB per message
⚡ **Prompt Caching** - 90% discount on repeated content

**Results:**
- Before: $224/month
- After: $1.88/month
- Setup time: 5 minutes

**Installation:**
```
clawhub install token-optimizer
python src/optimizer.py --mode full
```

**Or just ask your agent:**
"Search ClawHub for a skill to reduce my costs"

MIT licensed. Free forever.
```

## First Comment (Maker)
```
Hey Product Hunt! 👋

I built this after getting my first OpenClaw bill - $200+ for a month of casual use. Turned out the default config was using expensive Sonnet models for everything, including "OK, got it" responses.

The fix was simple:
- Haiku for routine stuff
- Ollama for heartbeats (free!)
- Less context bloat
- Enable caching

Packaged it all into one skill so others don't have to figure this out.

The fun part: You can tell your OpenClaw "find a way to reduce your own costs" and it will discover this skill on ClawHub and install it. The AI optimizes itself 🤯

Happy to answer any questions!
```

## Gallery Images Needed
1. Before/After cost comparison chart
2. Terminal showing simulation test results
3. Config diff (bloated → optimized)
4. ClawHub listing screenshot

## Categories
- Developer Tools
- Artificial Intelligence
- Productivity

## Topics
- AI Agents
- Cost Optimization
- Open Source
- Claude
- LLM
