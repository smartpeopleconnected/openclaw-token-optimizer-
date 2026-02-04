# Token Optimizer

> Reduce OpenClaw AI costs by 97% - From $1,500+/month to under $50/month

## Quick Start

```bash
# Analyze current setup
python src/analyzer.py

# Apply all optimizations
python src/optimizer.py --mode full

# Verify setup
python src/verify.py
```

## What It Does

| Optimization | Savings |
|--------------|---------|
| Model routing (Haiku default) | 92% |
| Heartbeat to Ollama | 100% (free) |
| Session management | 80% |
| Prompt caching | 90% |
| **Combined** | **97%** |

## Features

### Free Tier (This Download)
- ✅ Configuration analyzer
- ✅ Basic optimization templates
- ✅ SOUL.md / USER.md templates
- ✅ System prompt rules

### Premium ($29.99)
- ✅ Everything in Free
- ✅ Full optimizer with all modes
- ✅ Ollama heartbeat setup
- ✅ Verification tools
- ✅ Windows + Unix installers
- ✅ Email support
- ✅ 1 year updates

**[Get Premium →](https://YOUR_GUMROAD_LINK)**

## Cost Comparison

| Period | Before | After |
|--------|--------|-------|
| Daily | $2-3 | $0.10 |
| Monthly | $70-90 | $3-5 |
| Yearly | $800+ | $40-60 |

## Installation

### Via ClawHub
```bash
clawdhub install token-optimizer
```

### Manual
```bash
git clone https://github.com/smartpeopleconnected/openclaw-token-optimizer
cd token-optimizer
python src/optimizer.py --mode full
```

## Configuration Generated

```json
{
  "agents": {
    "defaults": {
      "model": { "primary": "anthropic/claude-haiku-4-5" },
      "cache": { "enabled": true, "ttl": "5m" }
    }
  },
  "heartbeat": {
    "model": "ollama/llama3.2:3b"
  },
  "budgets": {
    "daily": 5.00,
    "monthly": 200.00
  }
}
```

## Support

- **Docs:** See README.md
- **Issues:** GitHub Issues
- **Email:** smartpeopleconnected@gmail.com (Premium users)

## Author

**Smart People Connected**
- GitHub: [@smartpeopleconnected](https://github.com/smartpeopleconnected)
- Email: smartpeopleconnected@gmail.com

## License

MIT License - Free to use, modify, and distribute.

---

*Stop burning tokens. Start building things.*
