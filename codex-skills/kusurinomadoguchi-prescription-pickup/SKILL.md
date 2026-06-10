---
name: kusurinomadoguchi-prescription-pickup
description: Use when Raj Gupta wants to book or update a prescription pickup through the exact Kusuri no Madoguchi pharmacy page at https://www.kusurinomadoguchi.com/shoho/prescription?pharmacy_id=1000066617&utm_source=gbp. Prefer the Chrome extension workflow over Computer Use, reuse an already-open Chrome tab when possible, and prepare the booking flow up to the final externally visible confirmation step.
---

# Kusuri no Madoguchi Prescription Pickup

Use this skill for Raj Gupta's recurring prescription-pickup workflow on the Kusuri no Madoguchi page for pharmacy id `1000066617`.

## Primary Target

- Exact page: `https://www.kusurinomadoguchi.com/shoho/prescription?pharmacy_id=1000066617&utm_source=gbp`
- Preferred browser path: Chrome extension skill and browser automation.
- Avoid Computer Use unless the Chrome extension path is unavailable and the user explicitly wants a fallback.
- Computer Use is token-expensive, so treat it as the last resort rather than the default.

## Workflow

1. Look for the prescription image in the user's Gmail instructions first when the request came from email or refers to "the email I sent." Prefer downloading the attached prescription JPG from that Gmail thread instead of asking the user for the file again.
2. If the prescription image is not accessible from Gmail in the current session, ask the user for the local JPG path or ask them to open the relevant Gmail thread or pharmacy tab in Chrome.
3. If the user already has the pharmacy page open in Chrome, claim that tab and continue there.
4. Otherwise, try to open the exact URL in a Chrome-extension-controlled tab.
5. If browser policy blocks direct navigation to the site, stop and ask the user to open the exact pharmacy page in Chrome, then claim that tab.
6. Confirm or infer the booking details:
   - pickup day and time
   - whether this is a new reservation or a change to an existing one
   - any prescription image or code that must be supplied
7. Navigate the Kusuri no Madoguchi reservation flow using Chrome automation and prioritize every step that does not require Computer Use.
8. Fill the booking details and upload any required prescription artifact, preferably the Gmail-sourced JPG when available.
9. If the remaining blocker is a site interaction that cannot be completed reliably through the Chrome extension, stop instead of switching automatically to Computer Use.
10. Summarize which steps were completed without Computer Use, which exact step is blocked, and what the user should take over manually if they want to finish that blocked step themselves.
11. Stop immediately before the final submission or reservation-confirmation click and summarize what is filled in.
12. Only complete the final booking step after explicit user confirmation, because it creates or changes a live pharmacy reservation.

## Defaults And Assumptions

- If the user gives a pickup request such as "Monday at 7pm", use that exact slot.
- If the user does not specify a slot, gather the available times first before asking for a final choice.
- If the user says this is the usual Kashimada pharmacy next to Maruetsu, assume it refers to the exact pharmacy page above unless the user says otherwise.
- If the user says the prescription is in the email they sent, treat Gmail as the first source of truth for the JPG.

## Gmail Notes

- When the request originated from a Gmail instruction thread, check that thread for the prescription image before asking the user for another copy.
- Prefer the attached JPG or inline prescription image from Gmail when the connector or browser session can materialize it as a local file.
- If Gmail only exposes the image as a browser preview and not a downloadable local file, keep the pharmacy tab in handoff state and tell the user exactly what artifact is still needed.

## Chrome Notes

- Prefer the Chrome extension browser workflow, not generic web search.
- Reuse a user-opened tab whenever possible, especially if direct site navigation is blocked by browser policy in the current session.
- Keep the claimed pharmacy tab open as a `handoff` tab if the flow is waiting on user confirmation or additional prescription details.

## Computer Use Policy

- Treat Computer Use as expensive and use it sparingly.
- Default to Chrome extension, Gmail connector, and other lower-token steps first.
- Save the non-Computer-Use steps in this skill so future runs can replay them consistently.
- If a live blocker remains that truly requires Computer Use, pause and hand that step to the user instead of consuming a large token budget automatically.

## Safety Boundary

- Final booking, update, or cancellation is an externally visible action.
- Prepare everything up to the last confirmation step, then pause and ask for approval before submitting.

## Good Trigger Examples

- "Book my medicine pickup at the Kashimada pharmacy for Monday at 7pm."
- "Use the Kusuri no Madoguchi pharmacy page and set up my prescription pickup."
- "Open my regular Kusuri no Madoguchi booking workflow in Chrome."
