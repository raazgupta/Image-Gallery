---
name: library-books-renewal
description: Use when Raj Gupta wants Codex to review the latest library due-date email, log into the library website with the Chrome extension, rely on credentials already saved in Chrome when login is needed, renew all eligible books, and optionally check related Reminders or Calendar entries for the updated due date.
---

# Library Books Renewal

Use this skill for Raj Gupta's recurring library-renewal workflow.

## Core Rules

- Start with Gmail when the request mentions the latest library email, due dates, or reminders from the library.
- Prefer the Chrome extension workflow for the library website.
- Treat Chrome as the source of truth for the saved library username and password.
- When the user says the library credentials are already stored in Chrome, do not ask for the username or password unless Chrome fails to autofill and there is no logged-in session to claim.
- Renew every eligible item in one pass unless the user asks for a subset.
- If the user asks to check reminders or calendar entries, inspect the local `Reminders` and `Calendar` apps after the renewal work.
- Use Computer Use sparingly. Prefer Gmail, Chrome-extension navigation, and direct browser interactions first.

## Default Workflow

1. Search Gmail for the newest library-related due-date message.
2. Read the newest relevant thread and extract the due date plus the listed items.
3. Open the Kawasaki library site with the Chrome extension.
4. Reuse an already logged-in library tab if one exists.
5. If no logged-in tab exists, open the login page and rely on Chrome-saved credentials to sign in.
6. Open `利用者メニュー`, then `貸出状況照会`.
7. Select every renewable item and use the bulk-renewal flow.
8. Confirm the renewal and capture the updated due date from the result page.
9. If asked, check `Reminders` and `Calendar` for matching library-related entries and confirm whether the updated return reminder already exists.

## Gmail Search Rules

- Search for the newest message first, not an older remembered thread.
- Check for forwarded personal mail as well as direct messages from the library.
- Useful search patterns include the library subject line and sender fragments such as `library.city.kawasaki.jp`.
- Treat the newest matching message as the working source unless a more recent related thread clearly supersedes it.

## Chrome Workflow

- Name the browser session clearly for the library task.
- Before opening a new tab, inspect existing Chrome tabs and claim a library tab if it is already logged in.
- If the current tab is only at the login page, let Chrome autofill saved credentials when possible.
- If Chrome does not autofill and there is no logged-in session, pause and ask Raj to log in or provide credentials.
- Keep the final renewal-result tab open when the user may want to review it.

## Kawasaki Library Site Path

Use this path unless the site structure changes:

1. Open `https://www.library.city.kawasaki.jp/`
2. Go to `ログイン` if needed.
3. Open `利用者メニュー`
4. Open `貸出状況照会`
5. Select all renewable items
6. Click `選択した資料を延長`
7. Confirm on `一括貸出延長確認`

## Renewal Heuristics

- The loan page may show one checkbox and one `延長する` control per item, plus a bulk-renew button at the bottom.
- Prefer the bulk-renew path when all visible items are eligible.
- If the confirmation page lists `延長後期限`, treat that as the expected new due date before final submission.
- The success page text `以下の資料は貸出延長が完了しました。` confirms completion.
- If some items are missing checkboxes, infer that they are not eligible for renewal and report that clearly.

## Reminders And Calendar Checks

When Raj asks to check reminders or calendars after renewing:

- Search `Reminders` for `library`.
- Search `Calendar` for `library`.
- Confirm whether a dated return reminder already exists for the new due date.
- Report the specific reminder names and dates, not just a vague yes or no.

## Output Style During A Run

- Give short progress updates while moving between Gmail, Chrome, and app checks.
- When blocked on login, say exactly whether the issue is missing credentials, missing Chrome autofill, or the need for the user to log in once manually.
- After renewal, report the number of books renewed and the exact new due date.
- If reminder or calendar entries are checked, list the relevant matching entries and highlight the one tied to the return date.
