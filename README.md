# Vehicle Management System (VMS) - Frontend

**Service:** `vms-frontend`  
**Technology Stack:** Flutter Web (Dart 3.2+)  
**Architecture:** Feature-First Clean Architecture  

---

## 🏗️ Workspace Layout

```
vms-frontend/
├── pubspec.yaml                          # Flutter package definitions & dependencies
├── analysis_options.yaml                 # Strict Dart static analysis & linter rules
├── .env.example                          # Environment variable configuration template
├── .editorconfig                         # Code formatting specifications
├── .gitignore                            # Production Flutter/Web ignore patterns
├── web/
│   ├── index.html                       # HTML5 entrypoint with responsive viewport
│   └── manifest.json                    # Web app manifest (PWA)
├── lib/
│   ├── main.dart                        # Application bootstrap & baseline shell
│   ├── core/
│   │   ├── constants/                   # API routes, asset paths, global keys
│   │   ├── network/                     # Dio HTTP client & stateless interceptors
│   │   ├── theme/                       # Material 3 styling & design tokens
│   │   └── router/                      # Declarative GoRouter configuration
│   └── features/                        # Bounded domain feature modules (Vehicles, etc.)
└── test/                                # Widget and unit test suites
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK 3.19.0+** with Web support enabled (`flutter config --enable-web`)
- **Google Chrome** or Chromium-based browser for debugging

### Run Locally (Web)
```bash
# Get dependencies
flutter pub get

# Run on local web port (targeting 127.0.0.1)
flutter run -d chrome --web-port=3000 --web-hostname=127.0.0.1
```

---

## 🔒 Security & Decoupling Boundaries
- **Strict Decoupling:** Fully independent codebase. Zero direct code coupling with `vms-backend`.
- **API Boundary:** All communication with the backend is strictly over RESTful JSON endpoints (`http://127.0.0.1:8080/api/v1`).
- **No Shared State:** Operates as a stateless client passing JWT Bearer tokens in HTTP Authorization headers (RFC 7519 / RFC 9110).
