import { blueprints } from "./task-blueprints.mjs";

const profiles = {
  P0: { type: "architecture", kind: "document", due: "2026-10-14", stream: "scope", root: "docs", screens: ["Первый запуск", "Чат", "Проект", "Приёмка"], dependencies: [] },
  D1: { type: "design", kind: "design", due: "2026-10-23", stream: "design", root: "docs/design", screens: ["agent.pen", "macOS", "iOS"], dependencies: ["P0.1"] },
  A2: { type: "architecture", kind: "document", due: "2026-10-19", stream: "foundation", root: "docs/architecture", screens: ["Сборка", "Первый запуск", "Контракт API"], dependencies: ["P0.1"] },
  J3: { type: "backend", kind: "java", due: "2026-10-30", stream: "backend", root: "backend/infrastructure/src/main/java/dev/kiln", screens: ["Проекты", "Задачи", "Live-активность"], dependencies: ["A2.4"] },
  J4: { type: "agents", kind: "java", due: "2026-10-30", stream: "model", root: "backend/infrastructure/src/main/java/dev/kiln/provider", screens: ["Настройки GigaChat", "Чат", "Результат инструмента"], dependencies: ["A2.4"] },
  J5: { type: "security", kind: "java", due: "2026-11-06", stream: "security", root: "backend/application/src/main/java/dev/kiln/permissions", screens: ["Approval", "Permission Rules", "Git"], dependencies: ["A2.4", "P0.5"] },
  J6: { type: "security", kind: "java", due: "2026-11-06", stream: "security", root: "backend/infrastructure/src/main/java/dev/kiln/tools", screens: ["Workspace", "Diff", "Terminal"], dependencies: ["A2.4", "J5.1"] },
  J7: { type: "agents", kind: "java", due: "2026-11-06", stream: "team", root: "backend/application/src/main/java/dev/kiln/agent", screens: ["Команда", "Сессия", "Карточка агента"], dependencies: ["A2.4", "J4.1"] },
  J8: { type: "agents", kind: "java", due: "2026-11-13", stream: "team", root: "backend/application/src/main/java/dev/kiln/orchestration", screens: ["Чат руководителя", "План", "Зависимости задач"], dependencies: ["J7.3"] },
  J9: { type: "backend", kind: "java", due: "2026-11-06", stream: "team", root: "backend/application/src/main/java/dev/kiln/messaging", screens: ["Каналы", "Сообщения", "Граф общения"], dependencies: ["J3.9"] },
  J10: { type: "backend", kind: "java", due: "2026-11-13", stream: "team", root: "backend/application/src/main/java/dev/kiln/memory", screens: ["Память проекта", "Контекст задачи", "Источники"], dependencies: ["J3.1"] },
  J11: { type: "backend", kind: "java", due: "2026-11-20", stream: "graph-review", root: "backend/application/src/main/java/dev/kiln/review", screens: ["Ревью", "Findings", "Интеграция"], dependencies: ["J12.2"] },
  J12: { type: "backend", kind: "java", due: "2026-11-23", stream: "graph-review", root: "backend/application/src/main/java/dev/kiln/artifacts", screens: ["Артефакты", "Changed Files", "Commit", "Push"], dependencies: ["J3.1"] },
  J13: { type: "agents", kind: "java", due: "2026-11-20", stream: "extensions", root: "backend/application/src/main/java/dev/kiln/resilience", screens: ["Бюджет", "Восстановление", "Диагностика"], dependencies: ["J7.3"] },
  S14: { type: "architecture", kind: "swift", due: "2026-10-30", stream: "backend", root: "packages/KilnAPI/Sources/KilnAPI", screens: ["Общий Swift store", "Команды", "Поток событий"], dependencies: ["A2.11"] },
  M15: { type: "macos", kind: "swift", due: "2026-11-23", stream: "desktop", root: "apps/macos/KilnMac", screens: ["Рабочая среда macOS", "Настройки"], dependencies: ["S14.2"] },
  R16: { type: "connectivity", kind: "swift", due: "2026-11-09", stream: "wifi", root: "packages/KilnAPI/Sources/KilnAPI/Connectivity", screens: ["Устройства", "QR", "Соединение Wi-Fi"], dependencies: ["A2.11"] },
  B17: { type: "connectivity", kind: "swift", due: "2026-11-23", stream: "bluetooth", root: "packages/KilnAPI/Sources/KilnAPI/Bluetooth", screens: ["Bluetooth", "Статус соединения", "Мобильный чат"], dependencies: ["P0.1"] },
  I18: { type: "ios", kind: "swift", due: "2026-11-20", stream: "wifi", root: "apps/ios/KilnIOS", screens: ["Рабочая среда iPhone", "Выбранный Mac"], dependencies: ["D1.17", "R16.9", "S14.2"] },
  G19: { type: "macos", kind: "swift", due: "2026-11-20", stream: "graph-review", root: "packages/KilnGraph/Sources/KilnGraph", screens: ["Организация", "Общение", "DAG", "Список узлов"], dependencies: ["S14.1"] },
  H20: { type: "agents", kind: "java", due: "2026-11-27", stream: "extensions", root: "backend/application/src/main/java/dev/kiln/hiring", screens: ["Hiring", "Performance", "Профиль специалиста"], dependencies: ["J7.3"] },
  E21: { type: "agents", kind: "java", due: "2026-11-27", stream: "extensions", root: "backend/application/src/main/java/dev/kiln/extensions", screens: ["Skills", "Автоматизации", "Настройки расширений"], dependencies: ["A2.4"] },
  Q22: { type: "qa", kind: "verification", due: "2026-12-08", stream: "audit", root: "docs/qa", screens: ["macOS", "iOS", "Контрольный репозиторий", "Протокол проверки"], dependencies: ["J3.4", "J5.3", "S14.1"] },
  L23: { type: "release", kind: "release", due: "2026-11-23", stream: "beta", root: "apps/macos/KilnMac/Services", screens: ["Установка", "Запуск", "Обновление", "Передача проекта"], dependencies: ["A2.4"] },
};

function timing(epicId, number, profile) {
  let due = profile.due;
  let streamId = profile.stream;
  if (epicId === "D1") due = number <= 2 || number === 4 ? "2026-10-19" : number >= 20 ? "2026-10-26" : due;
  if (epicId === "A2") due = [1, 11].includes(number) ? "2026-10-16" : [7, 8, 9, 10, 12].includes(number) ? "2026-10-23" : due;
  if (epicId === "J4" && number <= 8) due = "2026-10-23";
  if (epicId === "J5" && number <= 3) due = "2026-10-30";
  if (epicId === "J6" && number <= 8) due = "2026-10-30";
  if (epicId === "J12") { due = number <= 4 ? "2026-11-13" : number >= 14 ? "2026-11-27" : due; if (number >= 14) streamId = number === 14 ? "extensions" : "beta"; }
  if (epicId === "S14" && number === 1) { due = "2026-10-16"; streamId = "scope"; }
  if (epicId === "M15") {
    due = number <= 3 ? "2026-10-30" : number <= 7 || number === 18 ? "2026-11-06" : [8, 10, 11, 12, 13].includes(number) ? "2026-11-13" : number === 9 ? "2026-11-20" : [19, 20, 21, 22, 26, 27, 28].includes(number) ? "2026-11-27" : due;
    streamId = number <= 7 || number === 18 ? "desktop" : number <= 13 ? "team" : number >= 19 && number <= 22 ? "extensions" : "graph-review";
    if (number === 9) streamId = "graph-review";
    if (number >= 26) streamId = "beta";
  }
  if (epicId === "R16") { due = number <= 11 ? "2026-11-06" : number >= 15 ? "2026-11-27" : due; if (number >= 15) streamId = "bluetooth"; }
  if (epicId === "B17") { due = number <= 3 ? "2026-10-16" : number >= 15 ? "2026-11-27" : due; streamId = number <= 3 ? "ble-spike" : "bluetooth"; }
  if (epicId === "I18") { due = number <= 6 ? "2026-11-09" : number <= 10 ? "2026-11-13" : number <= 16 ? "2026-11-20" : number <= 20 ? "2026-11-23" : "2026-11-27"; streamId = number <= 10 ? "wifi" : number <= 20 ? "graph-review" : "bluetooth"; }
  if (epicId === "Q22") { due = number <= 3 ? "2026-11-09" : number >= 5 && number <= 7 ? "2026-11-23" : number === 8 ? "2026-11-30" : number === 10 ? "2026-12-12" : number === 12 ? "2026-12-14" : due; streamId = number <= 3 ? "team" : number >= 5 && number <= 8 ? "beta" : [10, 12].includes(number) ? "regression" : "audit"; }
  if (epicId === "L23") { due = number >= 2 && number <= 9 ? "2026-10-30" : [12, 14].includes(number) ? "2026-12-01" : [15, 16].includes(number) ? "2026-12-11" : number === 17 ? "2026-12-14" : number === 18 ? "2026-12-15" : due; streamId = number >= 2 && number <= 9 ? "desktop" : [15, 16].includes(number) ? "audit" : number === 17 ? "regression" : number === 18 ? "delivery" : "beta"; }
  return { due, streamId };
}

function dependencies(epicId, number, profile) {
  const anchor = `${epicId}.1`;
  let ids = number === 1 ? profile.dependencies : [anchor];
  if (["P0", "D1", "A2"].includes(epicId) && number === 1) ids = profile.dependencies;
  if (epicId === "P0" && number === 10) ids = Array.from({ length: 9 }, (_, index) => `P0.${index + 1}`);
  if (epicId === "S14" && number >= 2) ids = ["S14.1"];
  if (epicId === "R16" && number >= 6) ids = ["R16.5"];
  if (epicId === "B17") ids = number <= 3 ? ["P0.1"] : number === 4 ? ["B17.2", "R16.9"] : ["B17.4"];
  if (epicId === "M15") ids = number === 1 ? ["S14.2"] : ["M15.1"];
  if (epicId === "I18" && number === 13) ids = ["I18.1", "G19.2"];
  if (epicId === "J3" && number === 8) ids = ["J3.5", "J3.6"];
  if (epicId === "J3" && number >= 10 && number <= 12) ids = ["J3.9"];
  if (epicId === "J11" && [12, 13, 14, 15, 18].includes(number)) ids = ["J11.4", "J11.6"];
  if (epicId === "J12" && number >= 5) ids = ["J12.2", "J5.6"];
  if (epicId === "J13" && number === 2) ids = ["J4.18"];
  if (epicId === "Q22" && number === 12) ids = ["Q22.4", "Q22.8", "Q22.9", "Q22.10", "Q22.11", "L23.17"];
  if (epicId === "L23") ids = number >= 2 && number <= 9 ? ["A2.4"] : number >= 10 && number <= 14 ? ["L23.1"] : number === 17 ? ["L23.16", "Q22.8"] : number === 18 ? ["Q22.12"] : profile.dependencies;
  return ids;
}

function filesFor(epicId, number, blueprint, profile) {
  let path = `${profile.root}/${blueprint.file}`;
  if (blueprint.file.endsWith(".md") && ["swift", "release"].includes(profile.kind)) path = `docs/${epicId === "L23" ? "release" : "verification"}/${blueprint.file}`;
  if (epicId === "J3" && number <= 4) path = `backend/core/src/main/java/dev/kiln/${blueprint.file}`;
  if (epicId === "J4" && number === 1) path = `backend/application/src/main/java/dev/kiln/provider/${blueprint.file}`;
  if (epicId === "S14" && number === 1) path = `packages/KilnDomain/Sources/KilnDomain/${blueprint.file}`;
  if (epicId === "B17" && number === 3) path = `apps/macos/KilnMac/Services/Bluetooth/${blueprint.file}`;
  if (epicId === "B17" && number === 4) path = `apps/ios/KilnIOS/Services/Bluetooth/${blueprint.file}`;
  if (epicId === "R16" && [1, 2, 3, 5, 6, 7, 17].includes(number)) path = `apps/macos/KilnMac/Services/Connectivity/${blueprint.file}`;
  if (epicId === "R16" && number === 7) path = `apps/macos/KilnMac/Views/Settings/${blueprint.file}`;
  if (epicId === "E21" && blueprint.file.endsWith(".swift")) path = `apps/macos/KilnMac/Views/Extensions/${blueprint.file}`;
  if (epicId === "J4" && number >= 19) path = `backend/infrastructure/src/test/java/dev/kiln/provider/${blueprint.file}`;
  if (epicId === "J5" && number === 18) path = `backend/infrastructure/src/test/java/dev/kiln/permissions/${blueprint.file}`;
  if (epicId === "J9" && number === 13) path = `backend/application/src/test/java/dev/kiln/messaging/${blueprint.file}`;
  if (epicId === "G19" && number >= 14) path = `packages/KilnGraph/Tests/KilnGraphTests/${blueprint.file}`;
  if (epicId === "S14" && number === 13) path = `packages/KilnAPI/Tests/KilnAPITests/${blueprint.file}`;
  const files = [{ path, purpose: blueprint.result }];
  if (epicId === "D1") files.unshift({ path: "agent.pen", purpose: `Frames и компоненты: ${blueprint.result.toLocaleLowerCase("ru")}.` });
  if (epicId === "A2") {
    const artifacts = { 1: [".gitignore"], 2: ["apps/macos/KilnMac.xcodeproj/project.pbxproj", "apps/ios/KilnIOS.xcodeproj/project.pbxproj"], 3: ["packages/KilnDomain/Package.swift", "packages/KilnAPI/Package.swift", "packages/KilnDesign/Package.swift", "packages/KilnGraph/Package.swift"], 4: ["backend/settings.gradle.kts", "backend/build.gradle.kts"], 5: ["backend/api/src/main/java/dev/kiln/CompositionRoot.java"], 6: ["backend/gradle/libs.versions.toml"], 7: [".swift-format"], 8: ["scripts/build-all.sh"], 9: [".github/workflows/ci.yml"], 10: ["fixtures/contracts/project-event.json"], 11: ["contracts/openapi.yaml", "contracts/project-event.schema.json"], 12: ["backend/infrastructure/src/main/java/dev/kiln/logging/LogRedactor.java"] };
    files.push(...artifacts[number].map((path) => ({ path, purpose: blueprint.result })));
  }
  return files;
}

function stepsFor(source, blueprint, profile, files) {
  const first = `${source.title} Результат: ${blueprint.result.toLocaleLowerCase("ru")}.`;
  const fileStep = `Создать или обновить ${files.map((file) => file.path).join(", ")}; ответственность: ${blueprint.result.toLocaleLowerCase("ru")}.`;
  const integration = { document: "Закрепить решение в требованиях и контрактах; проверить связь с зависимыми блоками реализации.", design: "Добавить переходы, empty/loading/error и применимые blocked/offline состояния; сохранить общую дизайн-систему Mac и iPhone.", java: "Встроить компонент через явные интерфейсы и composition root; сохранять доменные события и проверять права на сервере там, где действие их требует.", swift: "Подключить компонент к типизированному состоянию и командам Java; UI не исполняет серверные решения самостоятельно.", verification: "Подготовить воспроизводимый сценарий, исходное состояние и evidence; выполнить проверку на требуемых платформах.", release: "Воспроизвести сборку или lifecycle-сценарий по инструкции; зафиксировать версии и приложить результат проверки." };
  return [first, fileStep, integration[profile.kind], blueprint.verification];
}

function fallbackPackage(epicId, number) {
  if (epicId === "P0") return number === 2 ? "ARC-02" : number === 5 ? "SEC-01" : number === 9 ? "ARC-05" : "ARC-01";
  if (epicId === "J4") return number >= 5 && number <= 8 ? "SEC-05" : "AI-01";
  if (epicId === "J13") return number >= 14 ? "SEC-05" : "AI-04";
  const simple = { J6: "SEC-04", J7: "AI-02", J8: "AI-03", J9: "JAVA-03", J10: "JAVA-04", J11: "JAVA-05", S14: "ARC-03", G19: "MAC-04", H20: "AI-05", E21: "AI-05" };
  if (simple[epicId]) return simple[epicId];
  if (epicId === "D1") return number <= 2 || [4, 8, 9, 10, 11].includes(number) ? "DES-01" : [3, 5, 6, 7].includes(number) ? "DES-02" : number >= 12 && number <= 14 ? "DES-04" : number >= 16 && number <= 20 ? "DES-03" : "DES-05";
  if (epicId === "A2") return number === 11 ? "ARC-03" : [7, 8, 9, 10, 12].includes(number) ? "REL-01" : "ARC-04";
  if (epicId === "J3") return number <= 7 ? "JAVA-01" : number <= 12 ? "JAVA-02" : "ARC-05";
  if (epicId === "J5") return number <= 3 ? "SEC-01" : [4, 5, 18].includes(number) ? "SEC-02" : "SEC-03";
  if (epicId === "J12") return number <= 4 ? "JAVA-04" : number <= 13 ? "SEC-02" : number === 14 ? "AI-05" : "MAC-05";
  if (epicId === "M15") return number <= 3 ? "MAC-01" : number <= 7 || number === 18 ? "MAC-02" : number === 9 ? "MAC-04" : number <= 13 ? "MAC-03" : number === 22 ? "AI-05" : "MAC-05";
  if (epicId === "R16") return number >= 5 && number <= 11 || number === 15 ? "NET-01" : number >= 14 ? "NET-05" : "NET-02";
  if (epicId === "B17") return number <= 3 ? "NET-03" : number >= 15 ? "NET-05" : "NET-04";
  if (epicId === "I18") return number <= 6 ? "IOS-01" : number <= 10 ? "IOS-02" : number <= 16 ? "IOS-03" : number <= 20 ? "IOS-04" : "IOS-05";
  if (epicId === "Q22") return number <= 3 ? "QA-01" : number >= 5 && number <= 7 ? "QA-02" : number === 8 ? "QA-03" : [10, 12].includes(number) ? "QA-05" : "QA-04";
  if (epicId === "L23") return number >= 2 && number <= 9 ? "MAC-01" : [12, 13, 14].includes(number) ? "REL-03" : [15, 16].includes(number) ? "REL-04" : number >= 17 ? "REL-05" : "REL-02";
  throw new Error(`Missing work package for ${epicId}.${number}`);
}

export class TaskCatalogBuilder {
  #epics;
  #workPackages;

  constructor({ epics, workPackages }) {
    this.#epics = epics;
    this.#workPackages = workPackages;
  }

  build() {
    return this.#epics.flatMap((epic) => {
      const profile = profiles[epic.id];
      if (!profile || blueprints[epic.id]?.length !== epic.tasks.length) throw new Error(`Incomplete epic: ${epic.id}`);
      return epic.tasks.map((source, index) => {
        const number = index + 1;
        const blueprint = blueprints[epic.id][index];
        const files = filesFor(epic.id, number, blueprint, profile);
        const workPackage = this.#workPackages.find((item) => item.id === fallbackPackage(epic.id, number));
        if (!workPackage) throw new Error(`Unknown work package for ${source.id}`);
        return {
          id: source.id, type: profile.type, title: source.title.replace(/\.$/, ""), priority: ["H20", "E21"].includes(epic.id) ? "P1" : "P0",
          epicId: epic.id, epicTitle: epic.title, ...timing(epic.id, number, profile),
          dependencies: dependencies(epic.id, number, profile), covers: [source.id], workPackageIds: [workPackage.id],
          goal: `Блок «${epic.title}». ${source.title}`, result: blueprint.result,
          screens: [...new Set([...profile.screens, ...workPackage.screens])],
          files, steps: stepsFor(source, blueprint, profile, files),
          acceptance: [`Получен результат: ${blueprint.result.toLocaleLowerCase("ru")}.`, `Проверка пройдена и сохранено доказательство: ${blueprint.verification}`],
          tests: [blueprint.verification],
        };
      });
    });
  }
}
