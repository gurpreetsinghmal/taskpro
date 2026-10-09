# TaskPro architecture

The app remains Flutter + GetX. This refactor retains the existing layouts,
colors, text, animations, API endpoints, validation rules, and navigation
destinations. It changes ownership of state and propagates committed local
updates to mounted screens.

## Responsibilities

| Layer | Responsibility |
| --- | --- |
| Screens and feature widgets | Render observable state, show dialogs, manage animation and picker presentation. |
| Controllers | Form state, filtering, validation, user actions, navigation and feedback. Dispose subscriptions and text controllers with the route. |
| [LocalDataService](../lib/services/local_data_service.dart) | Shared observable work orders, statuses, profile and cached dashboard statistics. Hydrate before app startup; reload when the app resumes. |
| [SecureStorageService](../lib/services/secure_storage_service.dart) | Encrypted persistence, serialized read/modify/write operations, committed-change notifications. No navigation or widget layouts. |
| [WorkerDataService](../lib/services/worker_data_service.dart) | Dashboard API reads, cache writes, and the existing check-in synchronization operation. |
| [ApiService](../lib/network/api_service.dart) | Shared HTTP execution, options, progress callbacks and exception mapping. Injectable Dio for tests. |
| [SessionService](../lib/services/session_service.dart) | Stop tracking and clear persisted session data. The session controller owns logout feedback/navigation. |
| [Route bindings](../lib/modules/app_routes/app_pages.dart) | Create controllers for their routes. Screens resolve controllers instead of registering them during build. |

## Data flow

```text
API response or controller action
  -> SecureStorageService write/editWorkOrder
  -> successful encrypted write
  -> committed StorageChange event
  -> LocalDataService observable data
  -> controllers derive state
  -> Obx rebuilds mounted screens on the next Flutter frame
```

No polling, forced navigation, or network request is needed for a local refresh.
The dashboard reads cached data before checking connectivity. Profile saves
update the same profile observed by the dashboard and drawer. Tasks, check-in
sessions, open task details, and completion checklists observe the shared cache.
An actively edited profile form keeps its draft until editing is canceled.

Use `editWorkOrder(id, (current) => current.copyWith(...))` for field changes.
The callback receives the latest persisted order, preventing a checklist edit
from replacing newer sessions or schedule changes. Saves are serialized and
failed writes do not publish new cached values or block subsequent operations.
Downloads preserve pending check-ins and edits made while the request was in
flight. Ordinary unchanged records still receive server updates.

The event stream is scoped to the foreground Dart isolate. The existing
background location worker reads storage and posts location; it does not write
work orders. App resume reloads storage to reconcile external changes. A future
background writer will need an isolate message to trigger a foreground reload
while the app remains visible.

## Module review and extraction

- Authentication/onboarding/splash: preserved flows and timing; standardized route
  bindings, awaited password requests and corrected controller disposal.
- Dashboard/profile: share cached profile and work orders; profile persistence
  happens after a successful update. Dashboard statistics remain server-defined
  and are now cached; no new assumptions about status-to-count mappings.
- Tasks: search/filter and schedule validation belong to the controller. Cards
  and open details observe local changes. Schedule display is scoped to an order.
- Check-in: session state follows stored orders, and cross-order eligibility is
  checked in the controller. The existing details layout lives in its own
  [feature widget](../lib/modules/worker/checkin/widgets/work_order_details_sheet.dart).
- Completion: photo preview and success layouts are in the screen; the controller
  owns photo selection, validation, upload state and checklist edits.
- Signature: encoding and save state live in the signature controller. The
  [shared signature card](../lib/common/widgets/signature_card.dart) preserves
  the customer and technician variants' original padding, title and icon.
- Services: HTTP execution is shared; loading layout and map launching are
  separated from orchestration/screens respectively.

The existing placeholder background upload/download methods, completion payload
fields, example map address, wallet data and server count meanings are retained.
This refactor does not introduce a new offline upload queue or alter those
business rules. Offline profile reads no longer erase the persisted photo.

## Verification

Run `flutter test --no-pub` and `flutter analyze --no-pub`.
Regression tests cover immediate rebuilds (including the actual tasks screen),
cache hydration/deletion, failed writes, simultaneous edits, overlapping reloads,
downloads, shared controller state, profile drafts and HTTP request/error parity.

Device checks still require the normal backend/account and platform permissions:
login, dashboard refresh, accept/reject, propose schedule, check-in/out with
signature and location, completion photos, profile edit and logout. Automated
tests do not claim to verify live backend or native background-service behavior.
