# Portfolio Monitor — North Castle Partners

A single-file HTML dashboard for monitoring a PE fund's portfolio companies. Built in Cowork for **pk** (Yale intern → joining North Castle Partners). This `CLAUDE.md` is the handoff brief: read it before doing anything else and you'll have the full context.

## What this is (in one sentence)

`index.html` is the entire dashboard. Open it in Chrome and it works. No build step, no server, no dependencies beyond three CDN libraries loaded at runtime. Everything else in this folder supports that one file.

## Architecture

- **Single self-contained HTML** — ~128 KB, all CSS/JS inline.
- **Three runtime CDN deps**: Chart.js (charts), PapaParse (CSV), SheetJS (XLSX). PDF.js is also loaded for client-side PDF parsing.
- **State** lives in `localStorage` keyed by `ncp_portfolio_dashboard_v1`. JSON-shaped: `{portcos: [...], settings: {...}, source: "demo"|"manual"|"import"|"pdf"|"empty", lastSaved}`.
- **No backend.** Persistence is per-browser. JSON snapshot export/import is how data moves between machines today.

## The data model

Each portfolio company is an object with these fields (canonical names — the importer accepts many synonyms; see HEADER_MAP in the source):

| Field | Type | Notes |
|---|---|---|
| `id` | string | Stable key; re-importing same id replaces the row |
| `name` | string | Required |
| `sector` | enum | Healthcare Services / Consumer Brands / B2B Software / Industrial Services / Financial Services |
| `status` | enum | Outperforming / On plan / Underperforming / Distressed |
| `vintage` | YYYY-MM-DD | Acquisition close date |
| `invested` | $M | Equity check |
| `entryRev`, `entryEbitda`, `entryGM`, `entryDebt`, `entryMult` | numbers | At close |
| `curRev`, `curEbitda`, `curGM`, `curDebt`, `curMult` | numbers | Current TTM |
| `hcEntry`, `hcCur` | int | Headcount |
| `nrr`, `cacPayback` | number/null | SaaS only |
| `notes` | string | Free-form |
| `custom` | object | Arbitrary key/value pairs — any unmapped CSV/XLSX column lands here per row |
| `aiNotes` | string | Optional — populated by Claude when user clicks "Enrich with Claude" in the modal |
| `revHist`, `ebitdaHist` | number[4] | Historical series (Y-3, Y-2, Y-1, Current) |
| `curValue` | $M | Derived: (curEbitda × curMult) − curDebt; computed by `P()` helper |

The math (MOIC, IRR-approx, EBITDA bridge, marginal benefit vs sector) all lives in the JS — search for `function moic`, `function fundRollup`, `function ebitdaGrowthBridge`, `function marginalBenefit`.

## What the dashboard does (8 tabs)

1. **Overview** — 6 KPI cards (count, invested, FMV, MOIC, IRR, EBITDA), composition donuts, vintage curve, fund EBITDA roll-up
2. **Leaderboard** — sortable table with all portcos, rankable by MOIC/IRR/CAGR/value-created
3. **Companies** — card grid; each card has checkbox (multi-select delete), × button (single delete), click body to open modal
4. **Value Creation** — fund-level bridge (earnings growth × valuation change × debt paydown), per-portco stacked bar, vs-sector chart, detail table
5. **Operational KPIs** — heatmap (margin shift, rev growth, EBITDA growth, headcount), margin compare bar, headcount top-10, SaaS NRR-vs-CAC bubble
6. **Sector Cuts** — sector roll-up table, MOIC by sector, entry-vs-current multiple scatter
7. **Data Lab** — upload CSV/XLSX/JSON/PDF, manual entry form, SharePoint sync stub, JSON snapshot export
8. **Settings** — firm name, fund label, as-of date, sector growth assumptions, Anthropic API key, reset/snapshot

The **modal** (click any company) shows: KPIs, **auto-generated key notes**, P&L chart, value bridge, all 21 editable fields, **custom fields with suggestions** (Top customer / Top 10 suppliers / etc.), and an **"Enrich with Claude" button** that calls Anthropic API directly from the browser if the user pastes their API key in Settings → 8.2.

## Important quirks / design decisions

1. **The importer is forgiving.** `HEADER_MAP` in the JS contains synonyms — `Company` / `Company Name` / `portco` all map to `name`; `Revenue` / `Net Sales` / `TTM Revenue` all map to `curRev`; etc. **Any column NOT in HEADER_MAP becomes a custom field on each row** — this is the "variable template" feature. Don't break it.
2. **No demo re-seeding on empty.** `loadState()` returns `blankState()` only when localStorage is genuinely empty (first run). If the user has deleted all 22 portcos, that empty array sticks. The welcome modal offers "Start blank" vs "Load demo" on first run only.
3. **Cowork preview pane vs Chrome.** Cowork's preview uses an isolated browser session — localStorage doesn't persist across opens. The fix is to tell users to open the file in Chrome directly. Don't try to "fix" this in code; it's not a code bug.
4. **The Claude API call** uses `anthropic-dangerous-direct-browser-access: true` header. Model: `claude-sonnet-4-6`. Stored in `state.settings.anthropicKey`. Cost: ~$0.01-0.02 per portco insight.
5. **Palette is intentional.** Black / white / muted gold. The user (a PE firm) showed this needs to look executive, not colorful. CSS variables in `:root`. If you change the palette, change all of them together — search for `--accent`, `--ink`, `--muted`, and the chart `palette` array.
6. **Number formatting** uses `toLocaleString` for commas. `fmtM` / `fmtMshort` are the centralizers. Don't introduce raw `.toFixed(1) + "M"` anywhere.
7. **Chart axis titles are deliberately formula-free.** No "MOIC^(1/hold)−1", no "(×EBITDA)", no "(higher = better)". Just metric names. Keep it that way — partner-facing.
8. **Status colors:** `out` (green) / `on` (blue/gold accent) / `und` (amber) / `dis` (red). Defined as `.badge` classes and the `palette` is monochrome+gold for series.

## Where things live in the source

The dashboard is one HTML file. Search anchors:

- `DEMO = [` — the 22-portco demo dataset
- `function P(` — normalizes a portco object (computes curValue if missing)
- `function fundRollup(` — fund-level aggregates with empty-state guards
- `function ingestRows(` — the forgiving importer
- `HEADER_MAP` — column synonyms
- `function autoKeyNotes(` — generates the 6-bullet auto-summary per portco
- `function generateClaudeNotes(` — Claude API call
- `function renderCompanyGrid(` — card grid + multi-select
- `function renderOpsKPIs(` — SaaS bubble chart lives here
- `:root {` (CSS) — palette

## Known issues / next steps

- **Persistence is single-browser.** A real shared deployment needs a backend (Postgres + auth). The hooks exist (`/api/portcos`, `/api/upload-pdf` are wired up in `vercel-app/public/index.html` already, just no functions deployed).
- **PDF parsing is best-effort.** PDF.js extracts text, regex finds Revenue / EBITDA / Net Debt / Headcount / NRR. Image-only PDFs and complex board-deck layouts will miss fields. For production, route to a server-side Claude-with-PDF call.
- **Microsoft 365 / SharePoint sync** is stubbed. The button in Tab 7.3 just shows a toast. Real sync requires server-side OAuth on the user's North Castle tenant.
- **The custom-fields UI** doesn't surface in the company card preview — only inside the modal. Consider adding a "+N custom" hint chip on cards.
- **AI insights aren't shown in exports.** `aiNotes` saves to the state but doesn't render in the CSV/JSON export. Easy add.

## Working with this in Claude Code

### First-time setup

1. **Install Claude Code:** <https://docs.claude.com/claude-code>
2. **Open this folder:** `cd "this-folder-path" && claude`
3. Claude Code auto-reads this `CLAUDE.md` and you have full context.

### Adding the Render MCP (optional — for deploying)

```bash
# Get your key from https://dashboard.render.com/u/settings#api-keys
claude mcp add --transport http render https://mcp.render.com/mcp \
  --header "Authorization: Bearer YOUR_RENDER_API_KEY"
```

Then in chat: "Deploy this static site to Render under the name `north-castle-monitor`." Claude Code will use the MCP to create the service, push, and confirm the live URL.

### Adding GitHub MCP (also useful)

```bash
claude mcp add --transport http github https://api.github.com/mcp \
  --header "Authorization: Bearer YOUR_GITHUB_PAT"
```

Then "create a private repo `portfolio-monitor` and push everything in this folder."

### Useful prompts to start with in Claude Code

- "Add a chart to Tab 5 showing customer concentration if any portco has a `Customer concentration %` custom field."
- "Build the Vercel deploy with a Postgres database so the dashboard is actually multi-user."
- "Improve the PDF parser — find net-of-revenue patterns more reliably and handle scanned documents using the Anthropic API."
- "Add a 'compare two portcos side-by-side' view."

## Files in this handoff

| File | Purpose |
|---|---|
| `CLAUDE.md` | This brief (you are here) |
| `index.html` | The dashboard. The whole app. Open in Chrome. |
| `public/index.html` | Same file, in the deploy structure Render/Vercel/Netlify expect |
| `sample_data.xlsx` | 12-portco realistic dataset to test imports against |
| `portco_template.csv` | Empty template for portfolio companies to fill out |
| `setup.sh` | One-shot script: clones into Claude Code, initializes git, prints next steps |
| `render.yaml` | Render static-site config (if you want to deploy there) |

## Conventions

- **Editing JS:** the entire script block is inside `<script>` at the bottom of `index.html`. Indent 2 spaces, no semicolons missing.
- **Adding a new chart:** define a canvas in HTML, add a `chart("idName", {...})` call in the right render function, follow the existing color discipline (black / gold / gray).
- **Adding a new tab:** add the `<button data-tab="tN">` in the nav, the `<section id="tN" class="tab">`, and wire `refreshAll()` if needed.
- **Don't reintroduce formulas in chart labels.** The partners said no.
- **Don't reintroduce a colorful palette.** The partners said no.
- **Don't break the import synonym map.** Real CFOs send Excel files with whatever column names they feel like; the dashboard absorbs all of it.

## Original session context (briefly)

This was built across multiple Cowork sessions with `pk`, a Yale intern preparing for a PE internship at North Castle Partners. Yale's IT blocks Microsoft 365 connection from his Yale account, so the SharePoint integration is stubbed but designed to activate cleanly once he's on a North Castle account. The final firm-facing design was driven by partner expectations: "minimal, black/white/gold, no formulas, executive-presentable." That's the bar to clear on every future change.
