---
name: Ma on YouTube
description: Use this skill when the user wants to take media assets from a Gmail message, assemble a simple video with intro stills, main video, and outro still, prefer terminal-first processing such as ffmpeg over GUI editing when practical, and upload the result to YouTube as unlisted or private.
---

# Ma on YouTube

Use this skill for a repeatable workflow:

1. Find the source email in Gmail.
2. Download all attachments into a target folder.
3. Identify:
   - intro still image or intro still images
   - main video
   - outro still image
4. Prepare the stills so they match the video aspect ratio and do not show black padding or unwanted dark bands.
5. Build the final sequence:
   - intro still
   - cross dissolve
   - optional second intro still
   - cross dissolve
   - main video
   - cross dissolve
   - outro still
6. Set still durations to 5.0 seconds unless the user asks otherwise.
7. Export the finished movie to the working folder.
8. Upload to YouTube Studio with the requested visibility.

## Preferred Tooling

Default to the terminal and browser extension path:

1. Gmail tools for source email discovery and exact instructions.
2. Terminal tools for file verification, image cleanup, and video assembly.
3. `ffmpeg` for stitching stills, transitions, and final export when practical.
4. Chrome extension workflow for YouTube Studio upload.
5. Computer Use only when a required step cannot be completed reliably through the terminal or Chrome extension.

Avoid using Computer Use for routine browser work or for video assembly if a terminal-first path is available.

## Inputs To Confirm

Before starting, gather or infer:

- Gmail search target
  - usually the message subject or a short query
- Working folder
  - where attachments and export should live
- Asset mapping
  - which file is the intro still
  - which file is the optional second intro still
  - which file is the main video
  - which file is the outro still
- Requested YouTube visibility
  - `unlisted`, `private`, or `public`
- Requested YouTube title
  - prefer the exact title written in the Gmail instructions
- Thumbnail preference
  - if the email indicates a thumbnail image, use it as the custom YouTube thumbnail

If filenames follow a predictable prefix rule, use that rule directly.

## Gmail Step

Use Gmail tools to locate the email and download every attachment into the requested folder.

Preferred approach:

1. Search Gmail for the message.
2. Read the matching message body.
3. Download each attachment or inline image.
4. Save all assets into the working folder.

After download, verify the files are present on disk before moving on.

Treat the Gmail message body as the source of truth for:

- exact YouTube title
- whether there are one or two intro stills
- which image should be used as the custom thumbnail
- visibility
- any still cleanup instructions

## Asset Preparation

Inspect the media in the working folder and determine:

- the video file
- the intro still or stills
- the outro still

Create cleaned still-image derivatives when needed.

### Rules For Stills

- Match the video's aspect ratio.
- Do not distort the source image.
- Remove black bars, black padding, or dark empty regions if they are not part of the intended design.
- If the image contains a useful center composition with empty top and bottom bands, crop to the meaningful middle area first.
- Resize the cleaned result to the target video frame size for easier assembly.

### Practical Heuristics

- If the still is surrounded by black and the useful content is centered, crop to the non-black content and scale to a video-sized canvas.
- If top and bottom dark bands are decorative but unwanted, crop them out and preserve the remaining image in the video's aspect ratio.
- Avoid stretching faces, text, or logos.

Name derived files clearly, for example:

- `thumbnail1_clean_3840x2160.jpeg`
- `thumbnail2_clean_3840x2160.jpeg`
- `end_clean_3840x2160.jpeg`

## Assembly

Prefer terminal-first assembly with `ffmpeg`.

Use iMovie only as a fallback when the user explicitly wants iMovie review or when the terminal path is impractical for the requested edit.

### Timeline Structure

Build the final sequence in this order:

1. Intro still
2. `Cross Dissolve`
3. If a second intro still is provided, include it
4. `Cross Dissolve`
5. Main video
6. `Cross Dissolve`
7. Outro still

### Timing

- Set each still duration to `5.0` seconds by default.
- Keep the original main video duration unless the user requests edits.

### Visual Consistency

- Use still assets that already match the video frame or aspect ratio.
- Use `Fit`-style presentation for stills. Do not use Ken Burns or crop-to-fill unless the user asks for it.
- If the source still has black bars or black padding, replace it with the cleaned derivative instead of accepting the bars.
- Prefer solving padding issues in the source asset first, then using the cleaned file in the final sequence.

## ffmpeg Guidance

When using `ffmpeg`, prefer a workflow like this:

1. Normalize stills to the target frame size without distortion.
2. Generate 5-second still clips.
3. Apply cross dissolves between adjacent segments.
4. Concatenate the intro clip or clips, main video, and outro clip.
5. Export a final MP4 into the working folder.

If the user wants a manual review pass before export, iMovie remains a valid fallback, but it should not be the default path.

## Export

Export into the same working folder as the assets unless the user asks for a different destination.

Recommended defaults:

- Format: video and audio
- Resolution: use the source video's delivery resolution unless the user asks otherwise
- Quality: high
- Compression: prefer a practical MP4 output for upload

Wait for export completion and verify the final movie exists with a stable non-zero size before uploading.

## YouTube Upload

Prefer the Chrome extension workflow in the user's existing Chrome session.

Use Computer Use for upload only if the Chrome extension path is unavailable or blocked.

### Upload Steps

1. Open YouTube Studio upload flow.
2. Select the exported movie file.
3. Set the title from the Gmail instructions if one is provided.
4. If the first thumbnail image is intended as the thumbnail, upload it as the custom thumbnail.
5. Leave optional fields alone unless the user asked for more.
6. Advance through:
   - Details
   - Video elements
   - Checks
   - Visibility
7. Set the requested visibility:
   - `unlisted` if the user wants link-only access
   - `private` if only the account owner and invited viewers should see it

If Chrome extension upload fails because local files are blocked, verify Chrome extension file URL access before falling back.

### Required Confirmation

Stop immediately before the final publish or save click in YouTube Studio and ask the user to confirm unless the user has already explicitly authorized completing the upload and save.

Reason:

- This is a third-party transmission and publishing action.

Example confirmation:

`I’m on the final Visibility screen with the video ready as unlisted. If you want me to finish, say "go ahead and save it as unlisted."`

## Suggested Execution Order

When running this workflow, proceed in this order:

1. Create or verify the working folder.
2. Download Gmail attachments into that folder.
3. Inspect filenames and identify intro still or stills, main video, and outro still.
4. Create cleaned still derivatives if black borders or dark bands are present.
5. Prefer `ffmpeg` assembly in the terminal.
6. Use 5.0-second still durations, `Fit`-style still framing, and cross dissolves.
7. Export the movie.
8. Upload to YouTube Studio through the Chrome extension path.
9. Set the Gmail-specified title and thumbnail if provided.
10. Set visibility to the user-requested state.
11. Pause for final confirmation before the last save or publish action unless the user already authorized completion.

## Output Expectations

At the end, report:

- where the downloaded assets were saved
- which cleaned still files were created
- the exported movie path
- the chosen YouTube visibility
- the exact YouTube title used
- whether a custom thumbnail was uploaded
- the YouTube link once the upload is complete
- whether final confirmation is still required before the last publish or save action
