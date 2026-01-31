# Habit Tracker

An AI-powered habit tracking application with offline support, built with Flutter and Go.

## Features

- **Habit Management**: Create, update, and track daily/weekly habits
- **Streak Tracking**: Monitor your consistency with streak counters
- **Categories**: Organize habits by Health, Learning, Productivity, Personal
- **Learning Habits**: Special tracking for educational goals
- **AI Reports**: Monthly AI-generated performance analysis using Google Gemini
- **Revision Suggestions**: AI-powered habit optimization recommendations
- **Calendar View**: Visual habit completion history
- **Offline Support**: Full functionality without internet, syncs when online
- **Push Notifications**: Customizable reminders for habits
- **Minimalist Design**: Clean black/grey/white interface

## Architecture

```
habittracker/
├── app/                    # Flutter mobile application
│   ├── lib/
│   │   ├── core/          # App configuration, theme, routing
│   │   ├── data/          # Models, repositories, API clients
│   │   └── presentation/  # Screens, widgets, providers
│   └── pubspec.yaml
├── backend/               # Go backend API
│   ├── cmd/server/        # Application entry point
│   └── internal/
│       ├── config/        # Configuration management
│       ├── database/      # PostgreSQL, Redis connections
│       ├── handlers/      # HTTP request handlers
│       ├── middleware/    # Auth, CORS, rate limiting
│       ├── models/        # Data models and DTOs
│       ├── repository/    # Database operations
│       ├── routes/        # API routing
│       └── services/      # Business logic
├── nginx/                 # Reverse proxy configuration
├── docker-compose.yml     # Container orchestration
└── .github/workflows/     # CI/CD pipeline
```

## Tech Stack

### Mobile App (Flutter)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: Dio with interceptors
- **Local Storage**: SQLite (sqflite)
- **Authentication**: Firebase Auth
- **Notifications**: Firebase Cloud Messaging + flutter_local_notifications

### Backend (Go)
- **Framework**: Gin
- **Database**: PostgreSQL with pgx
- **Cache**: Redis
- **Authentication**: Firebase Admin SDK + JWT
- **AI**: Google Gemini API

### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **Reverse Proxy**: Nginx
- **CI/CD**: GitHub Actions

## Getting Started

### Prerequisites

- Go 1.21+
- Flutter 3.16+
- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7+
- Firebase project
- Google Gemini API key (optional)

### Backend Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/habittracker.git
cd habittracker
```

2. Copy environment file:
```bash
cp .env.example .env
```

3. Configure environment variables in `.env`

4. Start with Docker Compose:
```bash
docker-compose up -d
```

Or run locally:
```bash
cd backend
go mod download
go run cmd/server/main.go
```

The API will be available at `http://localhost:8080`

### Flutter App Setup

1. Navigate to app directory:
```bash
cd app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Add `google-services.json` (Android) to `android/app/`
   - Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`

4. Update API base URL in `lib/core/constants/api_endpoints.dart`

5. Run the app:
```bash
flutter run
```

### Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication with Email/Password, Google, and Apple providers
3. Enable Cloud Messaging
4. Download service account key for backend
5. Download platform-specific config files for mobile app

### Gemini API Setup (Optional)

1. Get an API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Add to `.env` as `GEMINI_API_KEY`

## API Documentation

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login with Firebase token
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - Logout user

### Habits
- `GET /api/v1/habits` - List all habits
- `POST /api/v1/habits` - Create habit
- `GET /api/v1/habits/:id` - Get habit details
- `PUT /api/v1/habits/:id` - Update habit
- `DELETE /api/v1/habits/:id` - Delete habit
- `POST /api/v1/habits/:id/complete` - Mark complete for today

### Daily Logs
- `GET /api/v1/logs` - Get logs with date range
- `POST /api/v1/logs` - Create/update log entry
- `GET /api/v1/logs/calendar` - Get calendar view data

### Reports
- `GET /api/v1/reports` - List all reports
- `GET /api/v1/reports/:id` - Get report details
- `POST /api/v1/reports/generate` - Generate report manually

### Revisions
- `GET /api/v1/revisions` - Get revision suggestions
- `POST /api/v1/revisions/:id/accept` - Accept suggestion
- `POST /api/v1/revisions/:id/reject` - Reject suggestion

### Sync
- `POST /api/v1/sync/push` - Push offline changes
- `GET /api/v1/sync/pull` - Pull server changes
- `GET /api/v1/sync/status` - Get sync status

## Development

### Running Tests

Backend:
```bash
cd backend
go test -v ./...
```

Flutter:
```bash
cd app
flutter test
```

### Code Style

Backend uses `golangci-lint`:
```bash
golangci-lint run
```

Flutter uses built-in analyzer:
```bash
flutter analyze
```

## Deployment

### Production with Docker Compose

```bash
docker-compose --profile production up -d
```

### Manual Deployment

1. Build backend:
```bash
cd backend
CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/server
```

2. Build Flutter app:
```bash
cd app
flutter build apk --release
flutter build ios --release
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `APP_ENV` | Environment (development/production) | Yes |
| `DB_HOST` | PostgreSQL host | Yes |
| `DB_PORT` | PostgreSQL port | Yes |
| `DB_USER` | Database username | Yes |
| `DB_PASSWORD` | Database password | Yes |
| `DB_NAME` | Database name | Yes |
| `REDIS_HOST` | Redis host | Yes |
| `REDIS_PORT` | Redis port | Yes |
| `JWT_SECRET` | JWT signing secret | Yes |
| `FIREBASE_PROJECT_ID` | Firebase project ID | Yes |
| `GEMINI_API_KEY` | Google Gemini API key | No |
| `FCM_SERVER_KEY` | FCM server key | No |

## License

MIT License - see LICENSE file for details.
