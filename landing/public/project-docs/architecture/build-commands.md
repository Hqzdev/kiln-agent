# Архитектура: как собирать сайт и продукт

Задача: A2.8. Дата: 11 октября 2026. Документ готов. Цели сборки продукта и build-all.sh ещё нужно создать.

## Команды существующего сайта

```bash
npm run spec:generate
npm run build
npm run dev
```

`spec:generate` готовит техническое задание для скачивания и копии документов для сайта. `build` собирает сайт Next.js для выпуска. `dev` запускает сайт для разработки. Эти команды не собирают KilnMac, KilnIOS или сервер Java.

## Будущие команды продукта

После создания Gradle Wrapper сервер собирается так:

```bash
./backend/gradlew -p backend clean test :api:bootJar
```

После создания общих пакетов Swift их тесты запускаются так:

```bash
swift test --package-path packages/KilnDomain
swift test --package-path packages/KilnAPI
swift test --package-path packages/KilnDesign
swift test --package-path packages/KilnGraph
```

После создания общих схем Xcode можно собрать Mac и посмотреть доступные устройства для iOS:

```bash
xcodebuild -project apps/macos/KilnMac.xcodeproj -scheme KilnMac -destination 'platform=macOS' build
xcodebuild -project apps/ios/KilnIOS.xcodeproj -scheme KilnIOS -showdestinations
```

Из списка iOS выбирается существующий симулятор. Его ID используется для сборки и тестов. Связь устройств проверяется отдельно на настоящем iPhone.

## Что должен делать build-all.sh

Скрипт проверяет наличие нужных инструментов и записывает версии и параметры сборки. Затем запускает проверки Java и Swift и собирает приложения. При первой ошибке он завершает работу с ненулевым кодом. Пропущенный этап не считается успешным.

Вывод сохраняется в папке материалов проверки вместе с командой, версией и кодом завершения.

Архив выпуска, подпись и проверка Apple (notarization) — отдельные этапы L23. Для обычной сборки секреты выпуска не нужны.

## Когда A2.8 можно закрыть

Должны существовать исполняемый build-all.sh и все перечисленные цели сборки. Инструкции нужно повторить из чистой копии репозитория. Сейчас подтверждена сборка сайта; команды продукта описывают будущую структуру.
