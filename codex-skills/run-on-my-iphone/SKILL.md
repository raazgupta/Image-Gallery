---
name: run-on-my-iphone
description: Use when Raj Gupta asks to run, build, install, relaunch, or deploy the current Xcode iOS app on his connected iPhone instead of using Xcode's Run button. Works best when the iPhone is paired and available on local Wi-Fi or USB. Handles finding the iPhone destination, building with xcodebuild, installing with devicectl, and relaunching the app with terminate-existing.
---

# Run On My iPhone

Use this skill when the user wants the current iOS app built and launched on their iPhone from the terminal.

## Workflow

1. Discover the phone.
   - Run `xcrun devicectl list devices`.
   - Confirm the iPhone is `available (paired)` or `connected`.

2. Find the correct Xcode destination ID.
   - Run `xcodebuild -project "<project>.xcodeproj" -scheme "<scheme>" -showdestinations`.
   - For `xcodebuild`, use the `platform:iOS` destination `id=...` from this output.
   - Do not use the CoreDevice identifier from `devicectl` as the `xcodebuild` destination.

3. Stop stale build state if needed.
   - If a prior `xcodebuild` is stuck, terminate it before retrying.

4. Build for the iPhone.
   - Use a writable derived data path under `/private/tmp`, for example:
     - `xcodebuild -project "<project>.xcodeproj" -scheme "<scheme>" -configuration Debug -destination id=<xcode-destination-id> -derivedDataPath /private/tmp/<derived-data-dir> build`

5. Verify the built app bundle exists.
   - Check for `*.app` under `/private/tmp/<derived-data-dir>/Build/Products/Debug-iphoneos/`.
   - If install fails claiming the bundle is invalid, confirm the build fully completed and that `Info.plist` exists inside the `.app`.

6. Install to the iPhone.
   - Use the CoreDevice identifier from `xcrun devicectl list devices`:
     - `xcrun devicectl device install app --device <coredevice-id> "<app-bundle-path>"`

7. Launch the app on the iPhone.
   - Use:
     - `xcrun devicectl device process launch --device <coredevice-id> --terminate-existing --activate <bundle-id>`
   - This replaces any currently running copy on the phone.

## Notes

- Prefer `Debug` builds unless the user asks otherwise.
- If the user says “run on my iPhone again”, reuse the same flow directly.
- If both USB and Wi-Fi are possible, local Wi-Fi is acceptable as long as the device is paired and available.
- Summarize the actual device name, build result, install result, and launch result in the final response.
