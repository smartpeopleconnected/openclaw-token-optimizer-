# Discord Posts

---

## OpenClaw Official Discord

### #general or #tips-tricks

```
💡 **Cost Optimization Tip**

Went from $200/month → $5/month on my OpenClaw setup. Here's how:

**The Problem:**
- Sonnet running for simple tasks (expensive!)
- Heartbeats using paid API
- 50KB context loaded every message
- No caching enabled

**The Fix:**
```
clawhub install token-optimizer
python src/optimizer.py --mode full
```

**What it does:**
✅ Haiku for routine tasks (92% cheaper)
✅ Ollama for heartbeats (free)
✅ Lean context (2KB instead of 50KB)
✅ Prompt caching enabled
✅ Budget controls added

**Or just ask your agent:**
> "Search ClawHub for token optimization"

It'll find and install it for you 🤯

GitHub: <https://github.com/smartpeopleconnected/openclaw-token-optimizer>
```

---

### #showcase

```
🦞 **Skill Release: Token Optimizer**

Just published my first ClawHub skill!

**What:** Reduces OpenClaw API costs by 97%
**How:** Model routing + free Ollama heartbeats + caching + budget controls
**Install:** `clawhub install token-optimizer`

Before: $7.46/day
After: $0.06/day

Includes a simulation test so you can see the savings before applying:
```
python test/simulation_test.py
```

Feedback welcome! 🙏

ClawHub: <https://clawhub.ai/skills/smartpeopleconnected/token-optimizer>
GitHub: <https://github.com/smartpeopleconnected/openclaw-token-optimizer>
```

---

### #help (when someone asks about costs)

```
Hey! I had the same problem.

Try this:
```
clawhub install token-optimizer
python src/optimizer.py --mode full
```

It switches to Haiku by default, moves heartbeats to Ollama (free), and enables caching. Dropped my costs from $200/month to under $5.

Or just tell your agent: "Find a skill to reduce my costs on ClawHub" - it'll discover it automatically.
```

---

## Ollama Discord

### #showcase or #projects

```
🔗 **OpenClaw + Ollama Integration**

Made a skill that routes OpenClaw heartbeats to local Ollama instead of paid Claude API.

**Result:** $15/month saved on heartbeats alone

Config it generates:
```json
{
  "heartbeat": {
    "model": "ollama/llama3.2:3b"
  }
}
```

Full skill also optimizes model routing, caching, etc. 97% total cost reduction.

```
clawhub install token-optimizer
```

GitHub: <https://github.com/smartpeopleconnected/openclaw-token-optimizer>
```

---

## AI/LLM Community Discords

### General post

```
💰 **Reduced my AI costs by 97%**

Was spending $200+/month on OpenClaw (Claude-based assistant). Now it's under $5.

**Key optimizations:**
1. Haiku instead of Sonnet for simple tasks
2. Local Ollama for heartbeats (free)
3. Context: 2KB instead of 50KB
4. Prompt caching enabled

Packaged it as a ClawHub skill:
```
clawhub install token-optimizer
```

The cool part: You can tell your OpenClaw "find a skill to reduce my costs" and it discovers + installs it automatically.

Code: <https://github.com/smartpeopleconnected/openclaw-token-optimizer>
```
