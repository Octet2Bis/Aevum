# Aevum

[![CI](https://github.com/Octet2Bis/Aevum/actions/workflows/ci.yml/badge.svg)](https://github.com/Octet2Bis/Aevum/actions/workflows/ci.yml)

**An iOS wellness app that turns screen-time overload into a 45-second active break.**
When a locked app crosses its daily threshold, Aevum does not just block it: it offers a short physical protocol (breathing, eye mobility, spinal decompression) and unlocks a grace window once it is done.

> **Status: prototype.** The web simulator runs and is tested. The Swift app is built and unit-tested in CI on a macOS runner; it has not been run on a physical iPhone yet.

## What it does

| Screen | What happens |
|---|---|
| Diagnostic | A 3-step questionnaire estimates a "biological age" gap from screen hours, unconscious unlocks, joint stiffness and afternoon brain fog, then recommends a first protocol. |
| Dashboard | A living agave grows with each micro-action; vitality score, streak calendar, daily challenge. |
| Interception | Screen Time shield → 45-second decompression → grace window. |
| Protocols | 12 longevity protocols with guided players (breathing orb, mobility, cognitive micro-games). |

## How it was built

Four gates, each a file in this repo, before any line of UI:

1. [`BRIEF.md`](BRIEF.md): problem, persona, anti-scope (no social feed, no paywall on the diagnostic, no biometric data on a server).
2. [`PRD.md`](PRD.md): use cases, state machine, data model.
3. [`DESIGN_CONTRACT.md`](DESIGN_CONTRACT.md): "Swiss transit" visual identity, palette, 8 px grid, radii.
4. Build: SwiftUI app + vanilla JS simulator sharing the **same JSON catalogues**. No catalogue is inlined in code.

Research behind the content lives in [`Documentation/`](Documentation/): protocol compendium, Screen Time API notes, and voice-of-customer from r/nosurf (public posts, authors removed).

## Tests & quality

Every claim above is backed by a check you can run.

| Check | What it proves | Command |
|---|---|---|
| Server tests (10) | The simulator's server listens on localhost only, refuses path traversal (plain, encoded, backslash) and null bytes, keeps running after bad requests | `node web_preview/tests/server.test.js` |
| Data parity (9/9) | The iOS app and the web simulator read byte-identical catalogues (SHA-256) | `node scripts/check-parity.mjs` |
| iOS build | The app and its 3 Screen Time extensions compile for the iOS simulator | CI, job `ios` |
| XCTest | Catalogue integrity, biological-age arithmetic, a valid recommendation for every circadian slot (guards a fixed out-of-range bug) | CI, job `ios` |
| Privacy | On-device only, privacy manifest, no secret in code | [`PrivacyInfo.xcprivacy`](AevumApp/Resources/PrivacyInfo.xcprivacy) |

## Run it

```bash
node web_preview/server.js        # simulator on http://127.0.0.1:3000
```

iOS, on a Mac with Xcode 15+: `brew install xcodegen && xcodegen generate`, then open `Aevum.xcodeproj`. Signing, Family Controls and TestFlight steps: [`README_XCODE_MAC.md`](README_XCODE_MAC.md).

## Structure

```
AevumApp/        SwiftUI app: onboarding, dashboard, challenge players, design system, services
Extensions/      Screen Time shield, shield action, device-activity monitor
web_preview/     Interactive simulator (vanilla JS + Web Audio) and its Node server
Documentation/   Research: protocols, Screen Time API, voice of customer
scripts/         Quality checks run in CI
```

Product, design and code by Antoine Lecerf, built with Claude Code.
