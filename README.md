**Warning**
- *Chinotto is currently in active development (alpha build, not feature-complete).*
- *Chinotto currently does not run in an App Sandbox.*
- *Built for Xcode 15, may not work as expected for older Xcode versions*
- *Use at your own risk =)*

**Notes**
- *Most of the functionality is currently in `CoreSimulator/Devices`, where you can inspect individual devices.*

# Chinotto
A sweet little tool for managing the bitter taste of Xcode using up your Mac's storage space.

<img width="240" alt="Screenshot 2023-11-13 at 5 13 08 PM" src="https://github.com/boscojwho/Chinotto/assets/2549615/b770ddd9-46e9-46cc-a240-0a8bd089b088">

## Instructions
1. Checkout latest commit on `/main` branch.
2. Go to the project's `Chinotto.xcconfig` (DEBUG configuration) file, and replace placeholder values with your own Team ID and bundle id prefix for code-signing.
3. Build and run via Xcode 15 on macOS 14.0 (or higher).
4. Click the "Calculate" button on "All Directories" or on an individual directory.
5. That's it!
6. You can use Spotlight and search for "Chinotto" for subsequent launches, if you wish to bypass Xcode.

## Screenshots
### Main Window

<img width="480" alt="Screenshot 2023-11-28 at 6 53 43 PM" src="https://github.com/boscojwho/Chinotto/assets/2549615/8da3f865-b528-442d-8b9f-e8568c7ef7d2">

### Menu Bar extra app

<img width="360" alt="Screenshot 2023-11-28 at 6 53 46 PM" src="https://github.com/boscojwho/Chinotto/assets/2549615/b0f250e2-e0a3-46f0-9f88-7002fba2ec24">

### Settings/Preferences

<img width="360" alt="Screenshot 2023-11-28 at 6 53 51 PM" src="https://github.com/boscojwho/Chinotto/assets/2549615/2d388ca8-0d7d-4af8-976a-d53a1c7fcb00">

## Contribute!
Feel free to suggest new features, file bug reports, or provide feedback in the issues tracker 😀
- Remember: Go to the project's `Chinotto.xcconfig` (DEBUG configuration) file, and replace placeholder values with your own Team ID and bundle id prefix for code-signing.

## Why?
One of the pain points of using macOS is seeing half of your Mac's storage consumed by some unknown force called "System Data". Apple does provide some tools in System Settings to help manage this issue, but it could be much better, especially for Xcode users.

<img width="720" alt="Screenshot 2023-11-13 at 4 57 07 PM" src="https://github.com/boscojwho/Chinotto/assets/2549615/4882db49-05ef-45c6-a6ae-dbf2144d5032">

This is where Chinotto can help.

## See it in action

System Settings (System Preferences) does not accurately report Xcode's actual disk space usage. For example, on my MacBook Air M1 (256 GB/8 GB) running Sonoma, Storage reports `Developer` uses 23.7 GB of disk space, but if we run Chinotto, we find that the actual usage is at 97.45 GB, which is more than 4x the system's reported value.

System Settings:

<img width="470" alt="Screenshot 2023-11-13 at 4 49 50 PM" src="https://github.com/boscojwho/Chinotto/assets/2549615/6115cc94-8137-4029-9ab5-150640b1b77b">

Chinotto:

<img width="720" alt="Screenshot 2023-11-13 at 4 51 25 PM" src="https://github.com/boscojwho/Chinotto/assets/2549615/55bf5093-89e5-4cce-aec8-811f4d5a98cb">

Finder:
- Finder reports the same values as Chinotto.
<img width="720" alt="Screenshot 2023-11-13 at 5 24 03 PM" src="https://github.com/boscojwho/Chinotto/assets/2549615/a131fdd6-bd18-4684-b04d-15c4a253a1fd">

## I made this because
So who cares, as long as you still have storage left at the end of the day? Well, if you are using a base model Apple Silicon Mac with 256 GB storage and 8 GB RAM, your applications will most likely be heavily relying on memory swap. This is quite fine, until your Mac only has about 10-20% of its full storage capacity left, then for whatever reason, Apple Silicon starts to drain your Mac's battery faster than an Intel Mac. This is not great, and to be honest, unacceptable, given Apple's claims that base model Macs are "efficient" [see claim here] (https://www.macrumors.com/2023/11/08/8gb-ram-m3-macbook-pro-like-16-gb-pc/).

## Prior Art
Here’s some prior art (non-exhaustive list), check them out if Chinotto doesn’t meet your needs! 🥹
- Xcode Trash Remover https://github.com/FrankKair/xcode-trash-remover
- Xcode Dev Cleaner https://github.com/vashpan/xcode-dev-cleaner
- Cleaner for Xcode https://github.com/waylybaye/XcodeCleaner-SwiftUI
