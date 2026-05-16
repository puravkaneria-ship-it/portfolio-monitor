# Sample Files — How to Use

These files simulate real documents a PE firm would produce. Drop any of them into the dashboard's **Data Lab tab → Upload** area to auto-populate a portfolio company.

---

## Files and What They Simulate

| File | Format | Simulates |
|---|---|---|
| `q1_earnings_release.txt` | Structured text | Quarterly earnings report from a portco |
| `ceo_speaker_notes.txt` | Narrative prose | CEO board meeting speaker notes |
| `board_deck_extract.txt` | Section headers + tables | Extracted board deck pages |
| `deal_memo_summary.txt` | Deal memo format | Investment committee memo at acquisition |
| `management_discussion.txt` | MD&A narrative | Annual management discussion & analysis |
| `portco_kpi_sheet.csv` | CSV spreadsheet | All 5 portcos at once, structured import |

---

## How to Generate Your Own in Claude.ai

Open [claude.ai](https://claude.ai) and paste one of these prompts:

### Q1 Earnings Release
```
Create a Q1 2025 earnings release for [Company Name], a [sector] company acquired in [date] for $[X]M equity. TTM revenue is $[X]M, TTM EBITDA is $[X]M, gross margin is [X]%, net debt is $[X]M. Format it like the sample file at: [paste q1_earnings_release.txt contents]
```

### CEO Speaker Notes
```
Write CEO board presentation speaker notes for [Company Name], a portfolio company of North Castle Partners. The company is in [sector]. Current TTM revenue is $[X]M, EBITDA $[X]M. Key highlights: [bullet 1], [bullet 2], [bullet 3]. Use the same format as: [paste ceo_speaker_notes.txt]
```

### Board Deck Extract
```
Generate a board deck extract for [Company Name]. Entry metrics: revenue $[X]M, EBITDA $[X]M, acquired [date] for $[X]M. Current: revenue $[X]M, EBITDA $[X]M, [X] employees. Format like: [paste board_deck_extract.txt]
```

### Deal Memo
```
Write an investment memorandum executive summary for [Company Name] in [sector]. Enterprise value $[X]M, equity check $[X]M, LTM revenue $[X]M, EBITDA $[X]M, [X]% gross margin, [X] employees. Investment thesis: [1-3 bullets]. Format like: [paste deal_memo_summary.txt]
```

---

## Fields the Parser Will Extract

The dashboard's PDF/text parser will pull these fields from any of the formats above:

| Field | Extracted From |
|---|---|
| Company name | Title / "Company:" label |
| Sector | "Sector:" label or industry keywords in text |
| Acquisition date | "Acquired:", "Acquisition Date:", "Close Date:" |
| Entry equity | "Entry Equity:", "Equity Check:", "Equity:" |
| TTM Revenue | "TTM Revenue", "LTM Revenue", "Revenue:" near current context |
| TTM EBITDA | "TTM EBITDA", "EBITDA:" |
| Gross margin | "Gross Margin:" or calculated from gross profit / revenue |
| Net debt | "Net Debt:", "Net Debt at" |
| Headcount | "Headcount:", "Employees:", "employee" count |
| Entry revenue/EBITDA | "Entry Revenue", "at acquisition", "at close" sections |
| EV multiple | "EV/EBITDA", "entry multiple" |
| NRR | "NRR", "Net Revenue Retention", "Net Dollar Retention" |
| CAC Payback | "CAC Payback", "payback period" |
| Notes | The `notes` field is populated from key highlights |

---

## Tips

- **Freeform is fine.** The parser handles narrative text ("Revenue grew to $45M") as well as tables.
- **Mix of old and current is fine.** Put entry metrics and current metrics in the same doc — the parser knows which is which from context labels like "at acquisition" vs "as of Q3".
- **The CSV is the most reliable.** If you want 100% accuracy, use `portco_kpi_sheet.csv` as a template and fill in your numbers. Every column header is recognized.
- **After upload**, review the portco modal and fill in any missing fields manually. The parser is best-effort on PDFs; structured text/CSV is always more accurate.
