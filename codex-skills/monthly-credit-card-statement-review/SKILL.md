---
name: monthly-credit-card-statement-review
description: Use when Codex Claw or another automation needs to review credit card statement emails or attachments, translate Japanese card statement details into English, identify large or suspicious charges, categorize spending, create a pie chart, and email the finished report to raazgupta@gmail.com.
---

# Monthly Credit Card Statement Review

Use this skill when an automation asks for a monthly credit card statement review from Gmail, provided email content, or statement files stored locally in Raj Gupta's finance-analysis project. The expected outcome is an emailed English report to `raazgupta@gmail.com`.

## Statement File Conventions

When the review is being run from the finance-analysis project folder for a given month, look in that month's folder for local statement files before searching Gmail:

- `meisai_*`: 2 Global Pass credit card files, typically current and previous month
- `OnlineStatement_*`: 2 Trust Club credit card files, typically current and previous month

Use the file whose statement period matches the requested review month as the primary source. Keep the adjacent previous/current file available for comparison when checking whether a charge is unusually large, newly recurring, or duplicated across cycles.

## Workflow

1. Determine whether the requested statement is available locally in the target month's project folder. If so, review those files first. If not, load the relevant Gmail/email skill or connector and find the statement email and attachments.
2. If using Gmail/email, find the provided credit card statement email and any attachments. If the automation prompt names a thread, sender, subject, date range, or attachment, use that exactly. If no specific email is provided, search recent mail for likely Japanese credit card statements.
3. Extract transaction text from local files, email bodies, and attachments. For PDFs/images, use the best available local OCR/PDF tooling before falling back to summaries.
4. Translate Japanese merchant names, transaction notes, statement sections, and category labels into clear English. Keep original Japanese text only when useful for auditability.
5. Build a transaction table with at least:
   - Date
   - Merchant or description in English
   - Original Japanese merchant or description, when available
   - Amount
   - Currency
   - Category
   - Suspicion/fraud note
6. Flag large charges. Treat "large" as context-sensitive: prefer the statement's own unusual/high-value signals if present; otherwise flag charges that are materially higher than the rest of the statement, recurring charges that changed sharply, or any single charge that would be noticeable to the user.
7. Think explicitly about possible fraud:
   - Unknown merchant names
   - Duplicate charges
   - Foreign or travel-related charges inconsistent with the rest of the statement
   - Unusual late-night, cash advance, gift-card, or high-ticket purchases
   - Subscriptions the user may have forgotten, while avoiding overclaiming fraud
8. Categorize all spending into these categories only when preparing the pie chart:
   - Restaurants
   - Subscriptions
   - Groceries
   - Utilities
   - Gift
   - Travel
   - Gym
   - Other, only if a transaction does not reasonably fit the required categories
9. Apply these explicit classification overrides whenever they appear:
   - `UBERJP EATS` -> `Restaurants`
   - `Jexer Fitness` -> `Gym`
10. Create a pie chart showing spend by category. If the email tool can attach files, generate a PNG chart and attach it. If attachments are not possible, include a simple Markdown table plus an inline chart image if the medium supports it.
11. Send the finished report by email to `raazgupta@gmail.com`. If the automation has already authorized sending, send directly without asking for confirmation. If direct send is blocked by the connector, create a draft only as a fallback and report that limitation.

## Report Format

Subject:

```text
Monthly Credit Card Statement Review
```

Body structure:

```markdown
Hi Raj,

Here is the monthly credit card statement review.

## Executive Summary
- Total reviewed spend:
- Largest charge:
- Potential fraud concerns:

## Large Charges
| Date | Merchant | Amount | Category | Notes |
|---|---:|---:|---|---|

## Possible Fraud or Follow-Up
| Date | Merchant | Amount | Why it may need review |
|---|---:|---:|---|

## Spending by Category
| Category | Amount | Share |
|---|---:|---:|

## Notes
- Japanese statement details were translated into English.
- Any uncertain translations or category assignments are marked.
```

Keep the report practical and audit-focused. Do not call a charge fraudulent unless there is strong evidence; use "worth reviewing" or "potential concern" for ambiguous items.

## Categorization Hints

- Restaurants: cafes, dining, izakaya, delivery, bars where the merchant is food/drink oriented.
- Subscriptions: software, streaming, memberships, app stores, cloud services, recurring digital services.
- Groceries: supermarkets, convenience-store grocery runs, food markets.
- Utilities: electricity, gas, water, internet, mobile phone, public service bills.
- Gift: gift shops, flowers, presents, gift cards, clearly personal gift purchases.
- Travel: hotels, airlines, trains, taxis, rideshare, parking, rental cars, travel agencies.
- Gym: fitness clubs, sports gyms, wellness memberships, personal training.

Explicit overrides:

- `UBERJP EATS`: Restaurants
- `Jexer Fitness`: Gym

When unsure, categorize conservatively and mark the uncertainty in the notes.
