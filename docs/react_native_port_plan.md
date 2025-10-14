# SM AI Support React Native Port – Implementation Blueprint

## 1. Goal
Port the Flutter `sm_ai_support` package to React Native with feature and UX parity. Deliver an installable RN package plus an example app that demonstrates integration, keeping networking, security, and real-time chat behaviour identical to the Flutter reference.

## 2. Reference Flutter Package Snapshot
- **Entry point**: `lib/main.dart` → bootstraps `SMSupport` widget, injects DI singletons, wires locale/theme.
- **UI flow**: `SMSupportViewHandler` opens `SMSupportCategoriesBs` bottom sheet, which dispatches to:
  - Category list (dynamic, from API) → starts chat (`ChatPage`) for anonymous or authenticated user.
  - “My Chats” → `MySessions` list + `ChatPage` per session.
  - Auth sheet (`NeedAuthBS`) & login via phone OTP (`features/auth`).
- **State management**: Cubits (`SMSupportCubit`, `SingleSessionCubit`, `AuthCubit`) + GetIt DI.
- **Data layer**: `SupportRepo` & `AuthRepo` wrap `NetworkServices` (Dio) for HTTP requests. Interceptors inject tenant headers, API key, auth token, and HMAC signature.
- **Real-time**: `WebSocketService` using Socket.IO with heartbeat & polling fallback; dispatches unread-count streams and live chat messages.
- **Security & storage**: API key + secret stored through `SecureStorageHelper`; anonymous session IDs via shared preferences; OTP tokens via auth manager.
- **Utilities**: Localization (`SMText`, `LocalizationsData`), theming (`ColorsPallets`, `TextStyles`), media upload/download flows.

These concepts must all exist in the React Native port even if implementation details change.

## 3. Target React Native Deliverables
- **Package**: Published TypeScript React Native library exposing `<SMSupport />` component and hooks/utilities mirroring Flutter API (`SMSupportData`, locale enum, etc.).
- **Example app**: Bare React Native (CLI) showcase to exercise the package (category picker → chat → login session → rating).
- **Documentation**: Usage guide, configuration instructions, integration checklist, and API reference.

### Suggested Tech Stack
- React Native CLI + TypeScript, React 18.
- Navigation via `@react-navigation/native`.
- State layer: Zustand or Redux Toolkit Query (for cache + async flows) alongside React Query for server state.
- Networking: Axios with custom interceptors for tenant headers, HMAC, API key, auth.
- Real-time: `socket.io-client` (mirrors Flutter’s Socket.IO server contract) with optional polling fallback.
- Secure storage: `react-native-keychain` or `expo-secure-store` (fallback to AsyncStorage for non-sensitive data).
- Internationalization: `react-i18next` + JSON resource bundles.
- Bottom sheet/UI: `react-native-reanimated`, `react-native-gesture-handler`, `@gorhom/bottom-sheet` for modal sheet; styling through Tamagui or styled-components (or plain StyleSheet).
- Media: `react-native-document-picker`, `react-native-audio-recorder-player`, `react-native-video`, `react-native-image-viewing`.

## 4. Implementation Roadmap
1. **Discovery & scaffolding**
   - Confirm API contracts (REST + WebSocket endpoints, request/response formats, HMAC requirements).
   - Spin up RN workspace: `packages/sm-ai-support-react-native` + `apps/example`.
   - Establish TypeScript config, linting (ESLint + React Native), formatting (Prettier), Husky hooks.
2. **Core platform foundation**
   - Implement config module (`SMSupportData`, locale enum).
   - Add secure storage helpers for API key/secret + AsyncStorage wrapper for anonymous sessions.
   - Build Axios client with interceptors (tenant header, locale header, API key, HMAC signature, auth token, retry/backoff).
   - Implement Auth manager (OTP send/verify, token persistence, logout).
3. **State management layer**
   - Model responses (`Tenant`, `Category`, `Session`, `Message`, etc.) using TypeScript interfaces mirroring Flutter models.
   - Create Zustand/Redux stores: `supportStore`, `sessionStore`, `authStore`.
   - Port repository functions (`SupportRepo`, `AuthRepo`) calling Axios client.
4. **Real-time services**
   - Implement `WebSocketService` using `socket.io-client` with reconnection strategy, heartbeat, unread count & stats channels, message stream, rating events, polling fallback.
5. **UI parity**
   - Theme provider retrieving tenant colors & fonts; dynamic primary color updates.
   - Components:
     - Categories Bottom Sheet (`SupportCategoriesSheet`): dynamic list, My Chats card, login prompt.
     - Chat screen: header with tenant info, messages list (virtualized), grouped date headers, bubble styling, status icons, attachments preview, rating prompt, message input with upload & voice note actions.
     - My Sessions list: status chips, unread badges, reopen flow.
     - Auth modal: phone input, country picker, OTP entry, verification steps.
     - Media preview modals (image/video).
   - Utility components: loading indicator, snackbar/toast, bottom sheet wrappers.
6. **Feature completion**
   - Session lifecycle: start anonymous session, upgrade to authenticated, assign sessions.
   - Message flows: send text/media, handle replies, mark as read, handle rating requests.
   - Storage upload/download orchestration (presigned URLs + file uploads via `fetch` or `axios`).
   - Localization toggle EN/AR (RTL support, dynamic copy from `SMText` equivalent).
7. **Testing & QA**
   - Unit tests for stores and services (Jest).
   - Component tests (React Native Testing Library) for categories sheet, chat UI.
   - Integration tests for networking (msw) and socket events (mocked server).
   - Detox e2e for example app flows.
8. **Documentation & release**
   - README with installation, linking instructions, secure key setup, env requirements.
   - API docs (Typedoc or manually written).
   - Versioning strategy (semver) and release scripts (`changesets` or npm publish workflow).
   - Example CI matrix (Android/iOS build smoke, lint, test).

## 5. Module Mapping (Flutter → React Native)
| Flutter Module / File | Responsibility | React Native Counterpart |
| --- | --- | --- |
| `SMSupport` widget (`lib/main.dart`) | bootstrap DI, theme, locale | `<SMSupportProvider>` component configuring stores, context providers |
| `SMSupportData` model | package configuration | TypeScript interface `SMSupportConfig` |
| `SMSupportCubit`, `SingleSessionCubit` | support state management | Zustand/Redux slices (`useSupportStore`, `useSessionStore`) with async actions |
| `SupportRepo`, `AuthRepo` | network calls | `supportApi.ts`, `authApi.ts` modules (Axios) |
| `NetworkServices` + interceptors | HTTP client & headers | `http/client.ts` (Axios instance) with interceptors for tenant, auth, API key, HMAC |
| `HmacSignatureHelper`, `SecureStorageHelper` | secure key storage & signing | `security/hmac.ts`, `storage/secure.ts` using Keychain |
| `WebSocketService` | Socket.IO messaging | `realtime/websocket.ts` wrapper on `socket.io-client` |
| `SMSupportCategoriesBs`, `ChatPage`, `MySessions` | UI screens | React components under `src/components` & `src/screens` |
| `AuthCubit` & views | OTP auth flow | `auth/store.ts`, components `PhoneLoginModal`, `OtpVerifyModal` |
| `SMText`, localization setup | copy & translations | `i18n/strings/en.json`, `i18n/strings/ar.json`, `i18n/index.ts` |
| `ColorsPallets`, `TextStyles` | theming | `theme/colors.ts`, `theme/typography.ts` with tenant overrides |

## 6. Detailed Build Notes
- **Configuration & initialization**
  - `initializeSupport(config: SMSupportConfig)` stores config, writes keys to secure storage, primes stores with locale, triggers tenant load.
  - Provide React Context for navigator refs if embedding requires modals outside host tree.
- **Localization**
  - Mirror `SMText` constants, support runtime toggle based on `config.locale`.
  - Ensure RTL layout via `I18nManager.forceRTL`.
- **Theming**
  - Tenants supply primary color/logo. Cache responses; use fallback theme until fetched. Provide theme hook for host apps to override tokens.
- **Networking**
  - Axios request interceptor order: API key → HMAC signature → auth bearer → Accept-Language/tenant header.
  - HMAC: reuse secret from secure storage; convert request body to canonical JSON string before hashing (align with server expectations).
  - Include retry/backoff for Android similar to DioFactory (exponential backoff on timeout).
- **Authentication**
  - Implement OTP send/verify with same endpoints.
  - Persist tokens securely, auto-attach via Axios interceptors.
  - On verify success, call assign anonymous sessions endpoint and clear stored IDs.
- **Session & Message Flow**
  - Start anonymous session when user sends first message under category.
  - Maintain message list grouping by day/time, mark read when user views chat.
  - Handle rating bottom sheet triggered by WebSocket flag or server response.
- **Media upload/download**
  - Request presigned URLs, upload via multipart `FormData`.
  - Store temporary file metadata to map upload responses to messages.
  - Display thumbnails using download URLs (cache).
- **Real-time considerations**
  - Mirror Socket.IO namespace/path (`/customer/room`, channel naming `message_{tenantId}{sessionId}{customerId|anonymous}`).
  - Heartbeat ping and reconnect attempts, fallback to polling (`setInterval` hitting message history endpoint).
  - Provide unsubscribe/cleanup on component unmount to avoid leaks.
- **Storage helpers**
  - `secureStorage.ts`: keychain wrappers for API key & secret.
  - `preferences.ts`: AsyncStorage for anonymous session IDs, locale, etc.
- **Utilities**
  - Formatters (dates, relative timestamps), error parsing, toast notifications (e.g., `react-native-toast-message`).
  - Device metrics helpers analogous to `size_extension.dart`.

## 7. Testing Strategy
- **Unit**: Validate stores reducers/actions, HMAC generation, network helpers (mock Axios).
- **Integration**: Simulate support flows with msw for API + mocked Socket.IO server.
- **UI**: Snapshot + interaction tests for bottom sheet, chat bubbles, message input.
- **E2E**: Detox scripts covering: open support, start session, send message, authenticate, view sessions, rate chat.
- **Automation**: GitHub Actions/Bitrise workflow running lint, tests, E2E (Android emulator), packaging dry-run.

## 8. Packaging & Distribution
- Prepare `package.json` with proper peer dependencies (React, React Native, React Navigation).
- Use `tsup` or `bob` to build TypeScript → JS + type declarations.
- Include podspec for iOS native dependencies (Keychain, video, document picker).
- Provide installation scripts for autolinking (react-native config).
- Semantic versioning with changelog (Changesets or conventional commits).
- Validate release with example app publish (Android APK/iOS build) before publishing to npm.

## 9. Documentation & Developer Experience
- Main README: Quick start, configuration, environment variables, secure key management, API requirement checklist.
- Guides:
  - Hosting multiple tenants.
  - Customizing themes.
  - Extending translations.
  - Handling authentication integration with host app.
- API reference generated via Typedoc or manual tables.
- Troubleshooting section (Socket IO connectivity, HMAC failures, upload issues).

## 10. Open Questions / Items to Clarify
1. Confirm REST and WebSocket base URLs & path differences between sandbox and production.
2. Determine whether API key/secret provisioning differs on mobile vs web (any rotation requirements).
3. Define minimum Android/iOS versions; check if expo compatibility is required.
4. Clarify media size limits and supported MIME types for upload.
5. Decide on preferred state library (Redux Toolkit vs Zustand vs Recoil) before implementation.
6. Confirm analytics/telemetry needs (if any) for support interactions.

With the above blueprint, an AI agent or developer can execute the port by following sections 4–9 sequentially, ensuring feature parity with the Flutter reference while respecting React Native ecosystem conventions.
