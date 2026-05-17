# Session Quick-Start — North Castle / PE Dashboard Projects

Read this + CLAUDE.md before doing anything. This file has the live state; CLAUDE.md has the architecture.

---

## How to Start a New Session

```bash
cd "/Users/puravkaneria/Documents/Claude/Projects/playing around with claude code/claude-code-handoff"
claude
```

Claude Code auto-reads CLAUDE.md. Paste this file's contents into the first message if you want the live URLs and IDs loaded too.

---

## Live Deployments

| Project | URL | Render Service ID | GitHub Repo |
|---|---|---|---|
| NCP Dashboard (main) | https://north-castle-monitor.onrender.com | `srv-d82cn19j2pic739nfbi0` | `puravkaneria-ship-it/portfolio-monitor` |
| Generic PE Demo | https://pe-portfolio-demo.onrender.com | `srv-d84bce8js32c739o6tvg` | `puravkaneria-ship-it/portfolio-monitor-demo` |
| Palm Peak Heatmap | https://palm-peak-heatmap.onrender.com | `srv-d84boobrjlhs73d4c0t0` | `puravkaneria-ship-it/palm-peak-heatmap` |

---

## Credentials & Keys

| Secret | Where it lives | Notes |
|---|---|---|
| Render API key | Ask Purav / Render dashboard | `rnd_ssEbT54J...` — used in deploy API calls |
| GitHub token | Ask Purav | `ghp_KgPe0w86...` — needed for `git push` |
| NCP password | Hardcoded in public/index.html | `northcastle2024` |
| Demo password | Hardcoded in demo/index.html | `portfolio2024` |
| Palm Peak password | Hardcoded in palm-peak-heatmap/index.html | `palmpeak2024` |
| Anthropic API key | User pastes in Settings tab → 8.2 | Never stored in code |
| Firebase config | Inline in public/index.html | Project: `north-castle-monitor` |

---

## How to Deploy After Edits

Every time you push to GitHub, manually trigger a Render deploy:

```python
# NCP dashboard
python3 -c "
import urllib.request, json
req = urllib.request.Request(
  'https://api.render.com/v1/services/srv-d82cn19j2pic739nfbi0/deploys',
  data=json.dumps({'clearCache':'do_not_clear'}).encode(),
  headers={'Authorization':'Bearer RENDER_API_KEY','Content-Type':'application/json'}
)
print(json.loads(urllib.request.urlopen(req).read())['id'])
"
```

Replace `srv-d82cn19j2pic739nfbi0` with the other service IDs from the table above for the other two sites.

---

## File Map

```
claude-code-handoff/
├── CLAUDE.md                  ← Full architecture brief (auto-read by Claude Code)
├── SESSION_START.md           ← This file — live state snapshot
├── public/
│   └── index.html             ← NCP dashboard (THE main file, ~3000 lines)
├── demo/
│   └── index.html             ← Generic PE demo (same code, no branding)
├── palm-peak-heatmap/
│   └── index.html             ← Palm Peak Capital sector heatmap
├── samples/
│   ├── HOW_TO_USE.md          ← How to generate test files in Claude.ai
│   ├── portco_kpi_sheet.csv   ← Most reliable import format
│   ├── q1_earnings_release.txt
│   ├── ceo_speaker_notes.txt
│   ├── board_deck_extract.txt
│   ├── deal_memo_summary.txt
│   └── management_discussion.txt
├── sample_data.xlsx           ← 12-portco test dataset
├── portco_template.csv        ← Empty CSV template
└── render.yaml                ← Render static site config
```

---

## Current Status (as of May 2025)

**Done:**
- [x] Password-protected login → cursive welcome → dashboard
- [x] Baby blue + white streaks background, Space Grotesk / Inter fonts
- [x] Frosted glass header with typing animation
- [x] Scroll navigation + side dot nav (no tab clicking)
- [x] Newton-Raphson IRR, TVPI, DPI, RVPI, PME, Net MOIC
- [x] Enhanced PDF/text parser (tables, narrative prose, sector detection)
- [x] Firebase real-time sync with live/local toggle
- [x] Present mode (full-screen for conference room)
- [x] All 3 sites deployed on Render
- [x] Sample input files + Claude.ai generation prompts

**Stubbed (not built yet):**
- [ ] Microsoft 365 / SharePoint sync (button exists, shows toast)
- [ ] Multi-user backend (currently localStorage + Firebase; no auth/Postgres)
- [ ] AI insights in CSV/JSON export (aiNotes saved to state, not exported)
- [ ] Custom fields hint chip on company cards

---

## Useful Prompts to Resume With

- "Add a customer concentration chart to Tab 5 if any portco has a `Customer concentration %` custom field."
- "Wire up the SharePoint sync button — it currently just shows a toast."
- "Add a side-by-side portco comparison view."
- "Build a Vercel + Postgres version so the dashboard is truly multi-user."
- "Update Palm Peak heatmap with new scoring data."
