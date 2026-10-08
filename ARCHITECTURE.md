# LabLend Architecture

## Stack

* **Frontend:** Flutter + Dart
* **State Management:** Riverpod
* **Testing:** Flutter Widget Test
* **Backend:** Node.js (Express) + TypeScript
* **Database:** MySQL
* **ORM:** Prisma
* **Infrastructure:** Docker Compose (untuk database lokal)
* **Architecture Pattern:** Monorepo (npm workspaces)

## Folder Structure

```text
lablend/
├── lib/
│   ├── main.dart
│   │
│   └── features/
│       └── peminjaman/
│           ├── providers/
│           │   └── peminjaman_notifier.dart
│           │
│           ├── repositories/
│           │   └── peminjaman_repository.dart
│           │
│           └── screens/
│               └── form_peminjaman_screen.dart
│
├── test/
│   └── features/
│       └── peminjaman/
│           └── form_peminjaman_test.dart
│
├── screenshots/
│   ├── 01-loading.png
│   ├── 02-loaded.png
│   ├── 03-empty.png
│   ├── 04-error-retry.png
│   ├── 05-validation.png
│   ├── 06-submit-loading.png
│   └── 07-widget-tests.png
│
├── ARCHITECTURE.md
├── README.md
└── pubspec.yaml
```

## Architecture Flow

```text
User
  │
  ▼
FormPeminjamanScreen
  │
  │ User selects equipment
  │ and submits borrowing form
  ▼
PeminjamanNotifier
  │
  │ Manages application state
  │
  ├── Loading
  ├── Loaded
  ├── Empty
  ├── Error
  └── Submitting
  │
  ▼
PeminjamanRepository
  │
  │ Fetch / submit data
  ▼
Simulated Data Source
```

## State Management

LabLend uses **Riverpod** to manage the state of the borrowing feature.

The main state is represented by `PeminjamanState`, which contains:

* `status` → represents the current data state.
* `alat` → contains the available equipment.
* `errorMessage` → stores an error message when data loading fails.
* `isSubmitting` → indicates whether the borrowing form is currently being submitted.

The `PeminjamanNotifier` is responsible for changing the state based on user actions and repository results.

## Main States

The borrowing feature implements the following states:

### 1. Loading

Displayed when the application is retrieving available equipment.

```text
Loading → CircularProgressIndicator
```

### 2. Loaded

Displayed when available equipment has been successfully retrieved.

```text
Loaded → Borrowing Form
```

### 3. Empty

Displayed when there is no available equipment.

```text
Empty → "Stok Alat Sedang Kosong"
```

### 4. Error

Displayed when retrieving equipment fails.

The user can press **Coba Lagi** to trigger the data request again.

```text
Error → Coba Lagi → Loading → Loaded / Error
```

### 5. Validation

The borrowing form validates:

* Equipment selection
* Quantity
* Return date

Invalid input prevents the submission process.

### 6. Submit Loading

When the user submits a valid borrowing request:

```text
Submit
  ↓
isSubmitting = true
  ↓
Button disabled
  ↓
Repository processes request
  ↓
isSubmitting = false
```

The submit button is disabled while the request is processing to prevent duplicate submissions.

## Feature Responsibilities

### `form_peminjaman_screen.dart`

Responsible for:

* Displaying the borrowing form.
* Displaying loading, loaded, empty, and error states.
* Handling user input.
* Performing form validation.
* Displaying submission results.

### `peminjaman_notifier.dart`

Responsible for:

* Managing `PeminjamanState`.
* Fetching available equipment.
* Handling loading and error states.
* Processing borrowing submissions.
* Preventing duplicate submissions.

### `peminjaman_repository.dart`

Responsible for:

* Providing equipment data.
* Processing borrowing requests.
* Simulating asynchronous operations for the current MVP.

The repository is separated from the UI so that the data source can later be replaced with a real backend/API without requiring major changes to the UI.

## Testing

Widget tests are provided for the main required states:

1. Loading state
2. Loaded state
3. Empty state
4. Error state and retry
5. Form validation
6. Submit loading state

Test file:

```text
test/features/peminjaman/form_peminjaman_test.dart
```

Run the tests with:

```bash
flutter test
```

## Future Development

The current implementation uses simulated data for the MVP and assignment demonstration.

In a future version, the repository can be connected to a real backend API:

```text
Flutter App
    ↓
PeminjamanNotifier
    ↓
PeminjamanRepository
    ↓
REST API
    ↓
Backend
    ↓
Database
```

This allows the current state-management implementation to remain while replacing the simulated repository with a real data source.

## Key Decisions

* **Flutter:** Used to build the LabLend mobile application.
* **Riverpod:** Used for centralized and predictable state management.
* **Repository Pattern:** Separates data operations from UI and state-management logic.
* **Feature-based structure:** Keeps files related to the borrowing feature together and makes the project easier to expand.
* **Simulated Repository:** Used for the current MVP so that loading, empty, error, and submission states can be demonstrated without requiring a backend.
* **Widget Testing:** Used to verify that the UI responds correctly to different application states.
