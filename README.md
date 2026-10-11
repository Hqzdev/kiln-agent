# Kiln

Приложение для Mac и iPhone, сайт и план разработки. Код приложений, сервера и библиотек пишет пользователь. Подготовлены папки, документы и настройки без заглушек реализации.

## Приложения

Откройте apps/Kiln.xcodeproj и выберите KilnMac или KilnIOS. Один проект содержит две цели. Минимум — macOS 26 и iOS 26. Сохранены исходный пользовательский ContentView и ресурсы.

- apps/macos/KilnMac — приложение Mac, папки Features, Models и Services.
- apps/ios/KilnIOS — приложение iOS, папки Features, Models и Services.
- apps/shared — пользовательский общий экран и ресурсы.
- packages — Package.swift и папки Sources/Tests четырёх пакетов, без реализации.
- backend — настройки четырёх модулей Gradle, Wrapper и папки Java; сервера пока нет.
- contracts — OpenAPI и JSON Schema.
- fixtures/contracts — общие примеры данных.

## Сайт и документы

```bash
cd landing
npm ci
npm run dev
```

План находится на /workspace. npm run build обновляет скачиваемые документы, проверяет ссылки и собирает сайт. Документы P0 завершены. A2 и S14 остаются открытыми до реализации и проверок; завершённые задачи получают тег «Выполнено».

Начните с [списка документов](docs/README.md). Команды инструментов описаны в docs/architecture/build-commands.md. Собственные скрипты и реализации помощника удалены; конфигурации сохранены.
