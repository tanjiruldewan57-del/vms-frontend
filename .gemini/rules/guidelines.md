# 🛡️ Engineering & Anti-Hallucination Standards

1. Zero-Laziness & No Placeholders:
   - Never write "// TODO", "// Implement here", or leave empty functions. Always deliver complete, working code.
2. Grounded API & Package Integrity:
   - Use only stable, official Flutter SDK (Material 3) APIs. Do NOT invent methods or widgets that do not exist.
   - Do NOT add unnecessary external packages to pubspec.yaml unless explicitly requested.
3. Automated Verification Loop:
   - Always run `flutter analyze` after creating or editing Dart files. If any errors or warnings occur, resolve them immediately before finishing.
4. Clean Architecture & Type Safety:
   - Keep models, screens, widgets, and state management cleanly separated.
   - Strictly follow sound null-safety: no loose `dynamic` types or unhandled null values.