# sd-ios — Agents Guide

This repo prioritizes **world-class code quality**, predictable UI behavior, and long-term maintainability.

## Principles
- **Small, composable views**: Prefer extracting subviews over deeply nested `body` trees.
- **Single source of truth**: UI reads from `ObservableObject` / `@State` with clear ownership.
- **Main-thread correctness**: UI state mutations happen on the main actor (`@MainActor` view models).
- **Structured concurrency**: Prefer `async/await` and `Task {}`; avoid callback pyramids.
- **Deterministic UI**: Avoid “hidden” state. Make view behavior explainable from the current state.
- **No regressions**: Existing screens must keep their UX unless explicitly changed.

## Architecture boundaries (expected)
Keep a clear, one-direction flow:

`View` → `ViewModel` → `UseCase` → `Repository` → `Network/Storage`

- **Views** (`Views/**`): Compose UI, bind state, route events to the view model. No business logic.
- **ViewModels** (`ViewModels/**`): Own UI state, validation, orchestration, and error mapping.
- **UseCases**: Contain business rules and coordinate repositories. Test here when possible.
- **Repositories**: Isolate API/storage calls and data mapping.

## SwiftUI best practices
- **Prefer `@StateObject` for screen-level VMs**, `@ObservedObject` for injected VMs.
- **Avoid work in `body`**: expensive computations should be precomputed or moved to helpers.
- **Use `@FocusState`** for keyboard UX; keep focus transitions intentional.
- **Prefer value types** for UI config models; avoid global singletons unless already established.
- **Animation**: Keep subtle and purposeful. Avoid animations that fight user input (especially text fields).

## Validation and errors
- Validation should be **view-model owned** and surfaced via explicit state like `nameError`, `amountError`, etc.
- Step/wizard flows should validate **only the current step** on “Next”, and full validation on “Save”.
- Error dialogs should be driven by a single optional message state and use the shared modifier (`withErrorDialog`).

## Localization
- All user-visible strings must go through localization (`"key".localized()`).
- Avoid embedding English strings in UI unless already used across the app.

## Accessibility & UX quality bar
- Respect Dynamic Type (use existing typography helpers where applicable).
- Ensure tap targets are sufficiently large; prefer `.contentShape(Rectangle())` for transparent hit areas.
- Keep color contrast high enough in both light/dark modes (use existing `Color.app*` helpers).

## Code style
- Prefer **clear naming** over brevity.
- Avoid duplicated logic; when duplicating UI is inevitable, keep it localized and consistent.
- Keep files cohesive: one screen per file, and small private subviews/helpers under it.

## Pull request checklist (before merging)
- **Builds** in Xcode (Debug).
- **Add flow** works end-to-end (including validation and error handling).
- **Edit flow** unchanged unless the PR explicitly modifies it.
- **Navigation** back/close behavior correct.
- **Localization** keys exist for newly introduced strings.
- **No UI regressions**: compare before/after screenshots for touched screens if possible.

## Manual test plan (minimum)
- Add subscription wizard:
  - Step 1: empty name/category blocks Next and shows field errors.
  - Step 2: empty/0 amount blocks Next and shows error.
  - Yearly requires month; error shown when missing.
  - Final Save triggers `onSaved` on success and returns to previous screen.
- Edit subscription:
  - Subscription Details → Edit opens the existing edit UI (no stepper).
  - Update still works.

