---
name: kawasaki-garbage-battery-days
description: Find official Kawasaki City garbage collection PDFs and determine used battery disposal dates for a specified town or ward. Use when Codex needs to answer questions about Kawasaki garbage disposal schedules, especially dry-cell batteries, rechargeable batteries, Tsukagoshi, Saiwai Ward, or month-specific collection days.
---

# Kawasaki Garbage Battery Days

## Workflow

1. Confirm the target town, ward, item type, and month. If omitted, infer from the user context, but state the assumption.
2. Search the web for the official Kawasaki City collection day page, preferably `site:city.kawasaki.jp 収集日一覧 <ward or town>`.
3. Open the official page and use the linked ward PDF when available. For Tsukagoshi, use the Saiwai Ward page/PDF.
4. Find the row for the town name in Japanese. Tsukagoshi is `塚越`.
5. Map the table columns carefully:
   - `普通ごみ`: regular garbage.
   - `空き缶 ペットボトル 空きびん 使用済み乾電池`: cans, PET bottles, bottles, and used dry-cell batteries.
   - `ミックスペーパー`: mixed paper.
   - `プラスチック資源`: plastic resources.
   - `粗大ごみ 小物金属`: oversized garbage and small metal items.
6. For used dry-cell batteries, use the `使用済み乾電池` column, not the small-metal column.
7. Convert weekday or occurrence rules into exact dates for the requested month. Use the current date only to decide which dates remain.
8. Cite the official Kawasaki page/PDF URL in the response.

## Known Tsukagoshi Rule

As of the official Kawasaki page updated April 1, 2026, the Saiwai Ward row for `塚越` is:

`塚越 火曜・金曜 月曜 土曜 木曜 第2・4回目 火曜`

This means:

- Regular garbage: Tuesday and Friday.
- Used dry-cell batteries with cans/PET bottles/bottles: Monday.
- Mixed paper: Saturday.
- Plastic resources: Thursday.
- Oversized garbage and small metal items: 2nd and 4th Tuesday.

## Battery Distinction

Be precise about battery type:

- Dry-cell batteries and lithium coin batteries (`CR`, `BR`) usually follow the `使用済み乾電池` collection day.
- Rechargeable batteries, lithium-ion batteries, mobile batteries, and devices whose rechargeable batteries cannot be removed may follow Kawasaki's small-metal-items collection rule from November 2025 onward. Verify on the current official Kawasaki page before advising.

## Date Calculation

Use local calendar commands or a small date calculation to list dates:

```bash
cal <month-number> <year>
```

For a weekday rule such as Monday, list every matching date in the month. If the user asks what they can still throw this month, filter out dates earlier than today's local date.
