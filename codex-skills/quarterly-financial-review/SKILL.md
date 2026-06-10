---
name: monthly-financial-review
description: Use when Raj Gupta wants to review bank or card statements against the Finances Google Sheet, extract monthly values from statements, update the live sheet for the target month, use Chrome or Google Sheets tooling first, use Computer Use only sparingly, and export OpenOffice .ods snapshots for manual review when requested.
---

# Monthly Financial Review

Use this skill for Raj Gupta's recurring finance worksheet process. The primary system of record is the live `Finances` Google Sheet, not a local OpenOffice workbook.

## Core Rules

- Update the live Google Sheet first.
- Prefer the Google Sheets connector or Chrome extension workflow.
- Use Computer Use only sparingly, only when Chrome or the Sheets connector cannot complete the step.
- Do not use Python or direct file rewrites to modify the spreadsheet.
- Only use OpenOffice as a manual review destination after exporting a snapshot.
- When asked to download the sheet, export it as `.ods`, not `.xlsx`, unless Raj explicitly asks for Excel.
- Before writing ambiguous values, summarize the candidate transactions and ask Raj to confirm the mapping.
- For Trust Club review, exclude `さとふる` / `Satofuru` / Furusato nozei charges from the Trust Club payment amount written into `Monthly Savings`, and explicitly tell Raj when you made that exclusion and by how much.
- When a monthly payslip PDF such as `payslipYYYYMM.pdf` is present in the month folder, use it to populate or verify the rows from `Raj Salary` through `Tax %` on `Monthly Savings`.
- Do not update the `Analysis` sheet or `Accounts` sheet unless Raj explicitly asks for it.

## Default Workflow

1. Identify the target month and statement sources.
2. In the target month folder, look for a bank-statement CSV file matching `ACCT_*` before attempting any PDF parsing.
3. If an `ACCT_*` CSV is present, use it as the primary source because it is easier to parse accurately.
4. Only open and parse the corresponding bank-statement PDF if no usable `ACCT_*` CSV is available in the folder.
5. Open or locate the `Finances` Google Sheet.
6. If a payslip for the target month is available, review it before finalizing the top section of `Monthly Savings`.
7. Work in the relevant month column on `Monthly Savings` and any supporting sheets such as `Credit Saison`.
8. Match statement transactions to worksheet rows by row label first, not only by remembered cell coordinates.
9. Write confirmed values into the live Google Sheet.
10. After category entries are done, copy the prior month's formulas into the current month for formula-driven rows such as `Raj Salary`, `Total Social Insurance & Tax`, `Variable Expenses`, `Savings`, and `Savings %` when those formulas already exist in the previous month.
11. If Raj asks for a local copy, export the current Google Sheet to `.ods` in the requested folder so he can open it manually in OpenOffice.

## Tool Preference

1. Google Sheets connector for precise reads and writes.
2. Chrome extension for actions that depend on the live tab, existing session, or formatting operations.
3. Computer Use only for narrow fallback actions that cannot be done reliably through the first two paths.

## Statement Review Heuristics

- Prefer the `ACCT_*` CSV as the source of truth when it is present in the month folder; fall back to the statement PDF only if the CSV is missing or unusable.
- Keep track of credits versus debits when a worksheet line represents a net figure.
- Decode Japanese bank CSV files as `cp932` / Shift-JIS when needed; do not assume UTF-8.
- For Japanese bank descriptions, translate into plain English when useful, but preserve the original text when it helps auditability.
- Flag mismatches between the sheet and the statement instead of silently forcing a value.
- If the month appears complete except for tiny interest or immaterial items, say so explicitly.
- When a Trust Club payment is being reconciled, check the prior month's Trust Club online-statement export in the folder, because the bank debit in the current month corresponds to the previous month's Trust Club statement cycle. If that online statement contains `さとふる` items, subtract those from the amount entered in the finance sheet because Raj treats them as tax-advantaged prepayments rather than ordinary spending.
- When a payslip is available, treat the payslip as the source of truth for the rows above `Net Income in Bank Account`, except for rows that are intentionally formula-driven in the sheet.
- When using a bank or portfolio statement for the `Accounts` sheet, determine whether each row should hold:
  - the raw foreign-currency balance
  - the JPY equivalent
  - a formula copied from the prior column
  before writing anything.

## Known Sheet Patterns

Use headers and row labels as the main guide. In the current `Finances` sheet, these patterns have been stable and should be checked first:

- `Monthly Savings`
  - If the target month does not exist yet, create it as the next column and preserve the prior month's formatting.
  - `Raj Salary` row: prefer copying the prior month's formula into the target month instead of hard-coding the total, when the prior month already computes it from other rows.
  - `Benefits Allowance`, `DC Allowance`, `Transportation Payment`, `Dividend / Tax Refund / Interest Earned`, and deduction rows should come from the payslip when available.
  - `Rent` row: if the payslip does not state rent, copy the prior month's rent unless Raj says otherwise.
  - `Total Social Insurance & Tax` row: prefer copying the prior month's formula into the target month instead of typing the total manually, when the prior month already sums the deduction rows.
  - `Tax %` row: prefer copying the prior month's formula into the target month instead of typing a literal percentage.
  - `Net Income in Bank Account` row: use the payslip net pay when reconciling compensation, then compare it against the bank remittance and flag mismatches.
  - `ATM Withdrawal` row: primary ATM row should be filled; the second ATM row is usually ignored.
  - `Trust Club` payment row: enter the current month's bank debit amount after subtracting any `さとふる` / Furusato nozei charges found in the prior month's Trust Club online statement.
  - `Local bank transfer` row: sum local outgoing transfers for the month.
  - `Tax payment` row: sum actual tax debits only.
  - `Overseas transfer` row: use actual outbound transfer costs only, not inbound remittances.
  - `Global Pass` row: net all `Global Pass` shopping items by adding charges and subtracting credits.
  - `Variable Expenses`: copy the prior month's formula into the target month after inputs are complete.
  - `Savings`: copy the latest prior month's row 32 formula into the target month after inputs are complete, and treat that live sheet formula as the source of truth. Do not assume `Tax payment` belongs in savings; follow whatever the latest row 32 formula includes or excludes.
  - `Savings %`: copy the prior month's formula into the target month after inputs are complete.
- `Credit Saison`
  - Add card debits or remittance credits that belong on this sheet instead of `Monthly Savings`.
  - Enter the transaction date and amount in the correct debit or credit column so the net auto-updates.
- `Analysis`
  - Only update this sheet when Raj explicitly asks.
  - Add missing years by inserting a new row in year order and mirroring the adjacent year's format.
  - `Monthly Average Variable Expenses` should follow the existing pattern:
    `=SUM(<12 month cells in row 30>)/12`
  - `Monthly Saving Rate (Excluding Bonus)` should follow the existing pattern:
    `=AVERAGE(<12 month cells in row 33>)`
- `Accounts`
  - Only update this sheet when Raj explicitly asks.
  - Match the month header carefully before writing; do not assume the newest month is the rightmost column.
  - `EURJPY` is an FX-rate row and Raj may keep it as an intentionally rounded whole-number display.
  - `EUR Currency` is the raw EUR balance amount, not the JPY equivalent.
  - `Total (EUR)` should be a formula consistent with the previous column pattern unless Raj explicitly asks for a direct typed value.
  - Confirm whether `USD Currency` and similar rows should include fixed deposits or savings-only balances before writing.

## Remittance Rules

When reviewing remittances from BFA or related labels:

- A salary-sized remittance around the usual monthly salary amount should match `Monthly Savings` net income in row `19`.
- If that salary-sized remittance does not match the sheet, or if the row `19` cell is blank, flag it to Raj before changing anything.
- A smaller non-salary BFA remittance can belong on `Credit Saison` as a credit.
- A yearly bonus remittance is distinct from the normal salary remittance and should not be assumed to be the same category.

## Example Mappings Proven In This Workflow

- ATM withdrawals were summed from multiple statement entries and placed in the target month ATM row.
- `Trust Club` payment was copied from the statement into the target month payment row.
- `Trust Club` needs a special exception: if the matching Trust Club online statement includes `さとふる` donations, subtract them before writing the payment row and call out the adjustment in the summary.
- Example: a bank debit of `62,619` mapped to prior Trust Club statement `OnlineStatement_202603...`, which included a `40,000` `さとふる` donation, so the `Monthly Savings` Trust Club row needed `22,619`.
- `Global Pass` required netting charges and credits before entry.
- Example: `Global Pass` on the bank CSV should be entered as shopping debits minus `GLOBAL PASS CASHBACK`.
- A `UC CARD` debit belonged on `Credit Saison`, not `Monthly Savings`.
- Example: a smaller `BOFA SECURITIES JAPAN CO., LTD.` remittance belonged on `Credit Saison` as a credit, while the main salary-sized remittance belonged in `Net Income in Bank Account`.
- A local transfer to `Alps Housing Service` or `Alps Management` belonged in `Local bank transfer`.
- Inbound remittances were not treated as overseas-transfer costs.

## Formula Handling

When a target month summary cell is blank but the prior month has the correct formula:

- Copy the formula from the prior month into the target month.
- Preserve relative references so the formula shifts to the new month naturally.
- Re-read the resulting cell values after the update.
- Apply this same approach to monthly top-section formula rows such as `Raj Salary`, `Total Social Insurance & Tax`, and `Savings %` when the prior month already has a stable formula.
- Be careful not to overwrite a formula-driven row with a literal payslip total just because the payslip provides a total.

## Payslip Mapping

When reviewing `payslipYYYYMM.pdf` for a month, check these lines first and map them into `Monthly Savings`:

- `BASE PAY`
- `BENEFIT ALLOWANCE`
- `DC ALLOWANCE`
- `COMMUTATION ALLOWANCE`
- `DIVIDEND EQUIVALENT-AP`
- `Health Insurance`
- `Nursing insurance`
- `Employee pension`
- `Unemployment Ins.`
- `Income Tax`
- `Residence Tax`
- `Net Pay`

Notes:

- The `DIVIDEND EQUIVALENT-AP` line belongs in `Dividend / Tax Refund / Interest Earned`.
- The bank-side `Net Income in Bank Account` should usually match payslip `Net Pay`; if it does not, flag the difference and explain the likely reason.
- If the sheet's `Raj Salary` formula intentionally includes rent or other support rows, do not overwrite that formula with the payslip total gross number.
- `DIVIDEND EQUIVALENT-AP` can appear only in certain months; do not assume it is present every month.

## Output Style During A Run

- Keep Raj updated with short progress notes.
- Before filling uncertain categories, show the candidate transactions and the proposed totals.
- After each meaningful update, confirm the cells or rows changed and the resulting values.
- At the end, summarize whether the month appears complete and note any still-uncategorized items.
- If you excluded any `さとふる` / Furusato nozei amount from a Trust Club total, include a short explicit line such as `Adjusted Trust Club by excluding Satofuru charges: original X, excluded Y, net Z`.
