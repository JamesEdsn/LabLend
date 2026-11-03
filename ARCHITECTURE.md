# LabLend Architecture

LabLend adalah aplikasi peminjaman inventaris laboratorium berbasis Flutter dengan backend REST API. Aplikasi menggunakan Riverpod untuk state management, Node.js, Express, dan TypeScript untuk backend, serta Prisma ORM dan MySQL untuk penyimpanan data.

Dokumen ini menjelaskan arsitektur, tanggung jawab setiap komponen, alur data, state management, autentikasi, dan pengujian yang tersedia pada implementasi saat ini.

## Tech Stack

- **Frontend:** Flutter + Dart
- **State Management:** Riverpod
- **HTTP Client:** package `http`
- **Backend:** Node.js + Express + TypeScript
- **Authentication:** bcryptjs + JSON Web Token (JWT)
- **ORM:** Prisma
- **Database:** MySQL
- **Database Adapter:** Prisma MariaDB Adapter
- **Testing:** Flutter Widget/Unit Tests dan Node.js Test Runner

## Folder Structure

```text
LabLend/
├── lib/
│   ├── main.dart
│   └── features/
│       └── peminjaman/
│           ├── models/
│           │   └── peminjaman_model.dart
│           ├── providers/
│           │   ├── peminjaman_notifier.dart
│           │   └── riwayat_peminjaman_notifier.dart
│           ├── repositories/
│           │   └── peminjaman_repository.dart
│           ├── screens/
│           │   ├── form_peminjaman_screen.dart
│           │   ├── riwayat_peminjaman_screen.dart
│           │   └── edit_peminjaman_dialog.dart
│           └── services/
│               ├── api_service.dart
│               └── local_storage_service.dart
│
├── test/
│   └── features/
│       └── peminjaman/
│
├── backend/
│   ├── prisma/
│   │   ├── migrations/
│   │   └── schema.prisma
│   ├── src/
│   │   ├── middleware/
│   │   │   └── auth.middleware.ts
│   │   ├── models/
│   │   │   ├── peminjaman.model.ts
│   │   │   └── user.model.ts
│   │   ├── repositories/
│   │   │   ├── peminjaman.repository.ts
│   │   │   └── user.repository.ts
│   │   ├── routes/
│   │   │   ├── auth.routes.ts
│   │   │   └── peminjaman.routes.ts
│   │   ├── app.ts
│   │   ├── database.ts
│   │   └── server.ts
│   ├── tests/
│   ├── .env.example
│   └── package.json
│
├── screenshots/
├── ARCHITECTURE.md
├── README.md
├── HowToRun.md
└── checklist_mvp.md
```

*Catatan: Struktur di atas merupakan gambaran direktori utama repository.*

## Architecture Overview

LabLend menggunakan pemisahan tanggung jawab antara frontend, backend, dan database.

```text
┌──────────────────────────────────────┐
│             FLUTTER APP              │
│                                      │
│  Form Peminjaman                     │
│  Riwayat Peminjaman                  │
│  Riverpod State Management           │
│  API Service                         │
└──────────────────┬───────────────────┘
                   │
                   │ HTTP / REST API
                   │ JSON
                   ▼
┌──────────────────────────────────────┐
│             BACKEND API              │
│                                      │
│  Node.js + Express + TypeScript      │
│                                      │
│  Authentication Routes               │
│  Peminjaman Routes                   │
│  Authentication Middleware           │
│  Validation                          │
│  Repository Layer                    │
└──────────────────┬───────────────────┘
                   │
                   │ Prisma Client
                   ▼
┌──────────────────────────────────────┐
│               DATABASE               │
│                                      │
│                MySQL                 │
│                                      │
│           User / Peminjaman          │
└──────────────────────────────────────┘
```

## Architecture Flow

### 1. Borrowing Data Flow

```text
User
 │
 ▼
Flutter Screen
 │
 │ User interaction
 ▼
Riverpod Notifier
 │
 │ Manages application state
 ▼
PeminjamanRepository
 │
 │ Calls API service
 ▼
ApiService (HTTP + JSON)
 │
 │ REST API request
 ▼
Express + TypeScript API
 │
 │ Validates request
 ▼
Authentication Middleware
 │
 │ Verifies JWT
 ▼
Peminjaman Repository
 │
 │ Database operations
 ▼
Prisma Client
 │
 ▼
MySQL Database
```

### 2. Component Responsibilities

**Flutter Screen**

Responsible for:

- Displaying the borrowing form.
- Displaying borrowing history.
- Handling user input.
- Showing loading, empty, success, and error states.
- Providing edit and delete interactions.

**Riverpod Notifier**

Responsible for:

- Managing application state.
- Fetching borrowing data.
- Handling loading and error states.
- Processing borrowing submissions.
- Refreshing borrowing history after data changes.

**PeminjamanRepository**

Responsible for:

- Separating data operations from UI.
- Communicating with the API service.
- Providing borrowing data to the notifier.
- Processing create, read, update, and delete operations.

**ApiService**

Responsible for:

- Sending HTTP requests.
- Handling JSON request and response data.
- Communicating with backend API endpoints.

**Backend Routes**

Responsible for:

- Receiving HTTP requests.
- Handling authentication and borrowing operations.
- Connecting requests to the appropriate repository.
- Returning API responses.

**Backend Repository**

Responsible for:

- Handling database operations.
- Communicating with Prisma Client.
- Applying user-specific data filters for borrowing records.

## State Management

LabLend uses **Riverpod** to manage the state of the borrowing feature.

### PeminjamanState

The borrowing form state contains:

- `status` — represents the current data state.
- `alat` — contains available equipment.
- `errorMessage` — stores an error message when data loading fails.
- `isSubmitting` — indicates whether the borrowing form is currently being submitted.

The `PeminjamanNotifier` is responsible for changing the state based on user actions and repository results.

### Main UI States

The borrowing feature implements the following states:

**1. Loading**

Displayed when the application is retrieving available equipment.

```text
Loading → CircularProgressIndicator
```

**2. Loaded**

Displayed when available equipment has been successfully retrieved.

```text
Loaded → Borrowing Form
```

**3. Empty**

Displayed when there is no available equipment.

```text
Empty → "Stok Alat Sedang Kosong"
```

**4. Error**

Displayed when retrieving equipment fails.

The user can press **Coba Lagi** to trigger the data request again.

```text
Error → Coba Lagi → Loading → Loaded / Error
```

**5. Validation**

The borrowing form validates:

- Equipment selection.
- Quantity.
- Return date.

Invalid input prevents the submission process.

**6. Submit Loading**

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

### Riwayat Peminjaman State

`RiwayatPeminjamanNotifier` uses Riverpod `AsyncNotifier` to manage borrowing history.

Its responsibilities include:

- Loading borrowing history.
- Refreshing the displayed records.
- Updating existing records.
- Deleting records.
- Refreshing data after successful operations.

## Authentication Architecture

The backend implements user registration and login using password hashing and JSON Web Token (JWT).

### Authentication Flow

```text
User
 │
 ▼
POST /api/auth/register
        or
POST /api/auth/login
 │
 ▼
Auth Routes
 │
 ▼
User Repository
 │
 ▼
Prisma Client
 │
 ▼
MySQL User Table
 │
 ▼
Password Verification
 │
 ▼
JWT Generation
 │
 ▼
Authentication Response
```

### Registration

The registration endpoint:

- Receives user information.
- Validates the registration data.
- Hashes the password using bcryptjs.
- Stores the user in the database.

### Login

The login endpoint:

- Receives email and password.
- Retrieves the corresponding user.
- Verifies the password against its stored hash.
- Generates a JWT when authentication succeeds.
- Returns the token and user information.

### JWT Authentication Middleware

The `requireAuth` middleware protects borrowing endpoints.

Its responsibilities include:

- Reading the Bearer token from the Authorization header.
- Verifying the JWT using the configured secret.
- Extracting the authenticated user's ID.
- Attaching authentication information to the request.
- Rejecting requests with missing or invalid tokens.

## User-Specific Borrowing Data

LabLend implements user-specific data access on the backend.

The `Peminjaman` model contains an optional `userId` relation to the `User` model.

When a user creates a borrowing record, the backend associates that record with the authenticated user's ID.

For read, update, and delete operations, the repository applies a user ID filter to ensure that users can only access their own borrowing records.

```text
User A
  │
  ▼
JWT: userId A
  │
  ▼
Authentication Middleware
  │
  ▼
Peminjaman Repository
  │
  ▼
Filter: userId = A
  │
  ▼
User A Borrowing Records
```

The same process applies independently to User B.

Existing borrowing records created before user authentication may have a `userId` value of `null`. These records are not automatically assigned to a newly registered user.

> Authentication and user-specific data access have been implemented and tested on the backend. Full login and session integration in the Flutter UI remains part of future development.

## REST API

The backend provides the following API endpoints.

### Authentication

| Method | Endpoint | Function |
|---|---|---|
| POST | `/api/auth/register` | Register a new user |
| POST | `/api/auth/login` | Authenticate an existing user |

### Peminjaman

All borrowing endpoints require a valid Bearer JWT.

| Method | Endpoint | Function |
|---|---|---|
| GET | `/api/peminjaman` | Retrieve authenticated user's records |
| GET | `/api/peminjaman/:id` | Retrieve one user's record |
| POST | `/api/peminjaman` | Create a borrowing record |
| PUT | `/api/peminjaman/:id` | Update a borrowing record |
| DELETE | `/api/peminjaman/:id` | Delete a borrowing record |

### API Validation

The backend validates borrowing data before database operations.

Validation includes:

- Equipment name must be valid.
- Quantity must be a positive integer.
- Return date must use the valid `YYYY-MM-DD` format.
- Malformed JSON requests are handled with an HTTP 400 response.
- Internal errors are handled with an HTTP 500 response.

## Database Architecture

Prisma ORM is used to communicate with MySQL.

The main database models include:

**User**

Stores registered user information, including identity, email, hashed password, and role.

**Peminjaman**

Stores borrowing records, including equipment information, quantity, return date, and the associated user ID.

The relationship between the two models allows borrowing records to be associated with their respective users.

Database schema changes are maintained through Prisma migrations.

## Testing

### Flutter Testing

Flutter tests are located in:

```text
test/features/peminjaman/
```

The tests cover:

1. Loading state.
2. Loaded state.
3. Empty state.
4. Error state and retry.
5. Form validation.
6. Submit loading state.
7. Borrowing model and API service behavior.
8. Borrowing history behavior.

Run the following commands from the project root:

```bash
flutter analyze
flutter test
```

### Backend Testing

Backend tests are located in:

```text
backend/tests/
```

The backend uses Node.js tests and an in-memory repository for API testing without requiring a live MySQL connection for each test.

The test coverage includes:

- Valid and invalid borrowing models.
- API success responses.
- Empty data responses.
- HTTP failure responses.
- Malformed JSON handling.
- Authentication behavior.
- User-specific borrowing data access.
- Repository failure handling.

Run the following commands from the `backend` directory:

```bash
npm test
npm run build
```

## Current Limitations and Future Development

The current implementation provides borrowing CRUD operations, backend authentication, and user-specific data access.

The following areas still require further development:

- Flutter login and registration screens.
- Frontend JWT storage and session management.
- Role-based access control for students and laboratory assistants.
- Dynamic inventory catalog and inventory CRUD.
- Borrowing approval and rejection workflow.
- Borrowing and return status management.
- Automatic inventory stock updates.
- Return notifications.
- QR Code or barcode equipment identification.

These features can be developed incrementally based on the final MVP requirements.

## Key Architectural Decisions

- **Flutter:** Used to build the LabLend application.
- **Riverpod:** Used for centralized and predictable state management.
- **Repository Pattern:** Separates data operations from UI and state-management logic.
- **Feature-Based Structure:** Keeps files related to the borrowing feature organized.
- **REST API:** Separates frontend operations from backend business logic.
- **Prisma ORM:** Provides structured database access.
- **JWT Authentication:** Protects backend endpoints and identifies authenticated users.
- **User-Specific Data Filtering:** Ensures borrowing records are accessed according to the authenticated user.
- **Automated Testing:** Helps verify frontend behavior and backend API functionality.
