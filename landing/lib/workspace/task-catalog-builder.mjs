import { blueprints } from "./task-blueprints.mjs";
import taskDependencies from "./task-dependencies.json" with { type: "json" };
import writingGuides from "./task-writing-guides.json" with { type: "json" };

const profiles = {
  P0: { type: "architecture", kind: "document", due: "2026-10-14", stream: "scope", root: "docs", screens: ["Первый запуск", "Чат", "Проект", "Приёмка"], dependencies: [] },
  D1: { type: "design", kind: "design", due: "2026-10-23", stream: "design", root: "docs/design", screens: ["agent.pen", "macOS", "iOS"], dependencies: ["P0.1"] },
  A2: { type: "architecture", kind: "document", due: "2026-10-19", stream: "foundation", root: "docs/architecture", screens: ["Сборка", "Первый запуск", "Контракт API"], dependencies: ["P0.1"] },
  J3: { type: "backend", kind: "java", due: "2026-10-30", stream: "backend", root: "backend/infrastructure/src/main/java/dev/blot", screens: ["Проекты", "Задачи", "Live-активность"], dependencies: ["A2.4"] },
  J4: { type: "agents", kind: "java", due: "2026-10-30", stream: "model", root: "backend/infrastructure/src/main/java/dev/blot/provider", screens: ["Настройки GigaChat", "Чат", "Результат инструмента"], dependencies: ["A2.4"] },
  J5: { type: "security", kind: "java", due: "2026-11-06", stream: "security", root: "backend/application/src/main/java/dev/blot/permissions", screens: ["Approval", "Permission Rules", "Git"], dependencies: ["A2.4", "P0.5"] },
  J6: { type: "security", kind: "java", due: "2026-11-06", stream: "security", root: "backend/infrastructure/src/main/java/dev/blot/tools", screens: ["Workspace", "Diff", "Terminal"], dependencies: ["A2.4", "J5.1"] },
  J7: { type: "agents", kind: "java", due: "2026-11-06", stream: "team", root: "backend/application/src/main/java/dev/blot/agent", screens: ["Команда", "Сессия", "Карточка агента"], dependencies: ["A2.4", "J4.1"] },
  J8: { type: "agents", kind: "java", due: "2026-11-13", stream: "team", root: "backend/application/src/main/java/dev/blot/orchestration", screens: ["Чат руководителя", "План", "Зависимости задач"], dependencies: ["J7.3"] },
  J9: { type: "backend", kind: "java", due: "2026-11-06", stream: "team", root: "backend/application/src/main/java/dev/blot/messaging", screens: ["Каналы", "Сообщения", "Граф общения"], dependencies: ["J3.9"] },
  J10: { type: "backend", kind: "java", due: "2026-11-13", stream: "team", root: "backend/application/src/main/java/dev/blot/memory", screens: ["Память проекта", "Контекст задачи", "Источники"], dependencies: ["J3.1"] },
  J11: { type: "backend", kind: "java", due: "2026-11-20", stream: "graph-review", root: "backend/application/src/main/java/dev/blot/review", screens: ["Ревью", "Findings", "Интеграция"], dependencies: ["J12.2"] },
  J12: { type: "backend", kind: "java", due: "2026-11-23", stream: "graph-review", root: "backend/application/src/main/java/dev/blot/artifacts", screens: ["Артефакты", "Changed Files", "Commit", "Push"], dependencies: ["J3.1"] },
  J13: { type: "agents", kind: "java", due: "2026-11-20", stream: "extensions", root: "backend/application/src/main/java/dev/blot/resilience", screens: ["Бюджет", "Восстановление", "Диагностика"], dependencies: ["J7.3"] },
  S14: { type: "architecture", kind: "swift", due: "2026-10-30", stream: "backend", root: "packages/BlotAPI/Sources/BlotAPI", screens: ["Общий Swift store", "Команды", "Поток событий"], dependencies: ["A2.11"] },
  M15: { type: "macos", kind: "swift", due: "2026-11-23", stream: "desktop", root: "apps/macos/BlotMac", screens: ["Рабочая среда macOS", "Настройки"], dependencies: ["S14.2"] },
  R16: { type: "connectivity", kind: "swift", due: "2026-11-09", stream: "wifi", root: "packages/BlotAPI/Sources/BlotAPI/Connectivity", screens: ["Устройства", "QR", "Соединение Wi-Fi"], dependencies: ["A2.11"] },
  B17: { type: "connectivity", kind: "swift", due: "2026-11-23", stream: "bluetooth", root: "packages/BlotAPI/Sources/BlotAPI/Bluetooth", screens: ["Bluetooth", "Статус соединения", "Мобильный чат"], dependencies: ["P0.1"] },
  I18: { type: "ios", kind: "swift", due: "2026-11-20", stream: "wifi", root: "apps/ios/BlotIOS", screens: ["Рабочая среда iPhone", "Выбранный Mac"], dependencies: ["D1.17", "R16.9", "S14.2"] },
  G19: { type: "macos", kind: "swift", due: "2026-11-20", stream: "graph-review", root: "packages/BlotGraph/Sources/BlotGraph", screens: ["Организация", "Общение", "DAG", "Список узлов"], dependencies: ["S14.1"] },
  H20: { type: "agents", kind: "java", due: "2026-11-27", stream: "extensions", root: "backend/application/src/main/java/dev/blot/hiring", screens: ["Hiring", "Performance", "Профиль специалиста"], dependencies: ["J7.3"] },
  E21: { type: "agents", kind: "java", due: "2026-11-27", stream: "extensions", root: "backend/application/src/main/java/dev/blot/extensions", screens: ["Skills", "Автоматизации", "Настройки расширений"], dependencies: ["A2.4"] },
  Q22: { type: "qa", kind: "verification", due: "2026-12-08", stream: "audit", root: "docs/qa", screens: ["macOS", "iOS", "Контрольный репозиторий", "Протокол проверки"], dependencies: ["J3.4", "J5.3", "S14.1"] },
  L23: { type: "release", kind: "release", due: "2026-11-23", stream: "beta", root: "apps/macos/BlotMac/Services", screens: ["Установка", "Запуск", "Обновление", "Передача проекта"], dependencies: ["A2.4"] },
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

function filesFor(epicId, number, blueprint, profile) {
  let path = `${profile.root}/${blueprint.file}`;
  if (blueprint.file.endsWith(".md") && ["swift", "release"].includes(profile.kind)) path = `docs/${epicId === "L23" ? "release" : "verification"}/${blueprint.file}`;
  if (epicId === "J3" && number <= 4) path = `backend/core/src/main/java/dev/blot/${blueprint.file}`;
  if (epicId === "J4" && number === 1) path = `backend/application/src/main/java/dev/blot/provider/${blueprint.file}`;
  if (epicId === "S14" && number === 1) path = `packages/BlotDomain/Sources/BlotDomain/${blueprint.file}`;
  if (epicId === "B17" && number === 3) path = `apps/macos/BlotMac/Services/Bluetooth/${blueprint.file}`;
  if (epicId === "B17" && number === 4) path = `apps/ios/BlotIOS/Services/Bluetooth/${blueprint.file}`;
  if (epicId === "R16" && [1, 2, 3, 5, 6, 7, 17].includes(number)) path = `apps/macos/BlotMac/Services/Connectivity/${blueprint.file}`;
  if (epicId === "R16" && number === 7) path = `apps/macos/BlotMac/Views/Settings/${blueprint.file}`;
  if (epicId === "E21" && blueprint.file.endsWith(".swift")) path = `apps/macos/BlotMac/Views/Extensions/${blueprint.file}`;
  if (epicId === "J4" && number >= 19) path = `backend/infrastructure/src/test/java/dev/blot/provider/${blueprint.file}`;
  if (epicId === "J5" && number === 18) path = `backend/infrastructure/src/test/java/dev/blot/permissions/${blueprint.file}`;
  if (epicId === "J9" && number === 13) path = `backend/application/src/test/java/dev/blot/messaging/${blueprint.file}`;
  if (epicId === "G19" && number >= 14) path = `packages/BlotGraph/Tests/BlotGraphTests/${blueprint.file}`;
  if (epicId === "S14" && number === 13) path = `packages/BlotAPI/Tests/BlotAPITests/${blueprint.file}`;
  const domainFiles = {
    1: ["Project.java", "Run.java", "RunStatus.java", "SpecificationRevision.java"],
    2: ["Task.java", "TaskDependency.java", "TaskAttempt.java"],
    3: ["AgentProfile.java", "AgentSession.java"],
    4: ["RunStateMachine.java", "TaskStateMachine.java", "SessionStateMachine.java"],
  };
  const files = epicId === "J3" && number <= 4
    ? domainFiles[number].map((name) => ({ path: `backend/core/src/main/java/dev/blot/core/${name}`, purpose: blueprint.result }))
    : [{ path, purpose: blueprint.result }];
  if (epicId === "D1") files.unshift({ path: "agent.pen", purpose: `Frames и компоненты: ${blueprint.result.toLocaleLowerCase("ru")}.` });
  if (epicId === "A2") {
    const artifacts = { 1: [".gitignore"], 2: ["apps/Blot.xcodeproj/project.pbxproj"], 3: ["packages/BlotDomain/Package.swift", "packages/BlotAPI/Package.swift", "packages/BlotDesign/Package.swift", "packages/BlotGraph/Package.swift"], 4: ["backend/settings.gradle.kts", "backend/build.gradle.kts"], 5: ["backend/api/src/main/java/dev/blot/CompositionRoot.java"], 6: ["backend/gradle/libs.versions.toml"], 7: [".swift-format"], 8: ["scripts/build-all.sh"], 9: [".github/workflows/ci.yml"], 10: ["fixtures/contracts/project-event.json"], 11: ["contracts/openapi.yaml", "contracts/project-event.schema.json"], 12: ["backend/infrastructure/src/main/java/dev/blot/logging/LogRedactor.java"] };
    files.push(...artifacts[number].map((path) => ({ path, purpose: blueprint.result })));
    if (number === 3) files.push(...[
      "packages/BlotDomain/Sources/BlotDomain/Project.swift",
      "packages/BlotDomain/Sources/BlotDomain/Run.swift",
      "packages/BlotDomain/Sources/BlotDomain/Task.swift",
      "packages/BlotAPI/Sources/BlotAPI/BackendClient.swift",
      "packages/BlotDesign/Sources/BlotDesign/DesignTokens.swift",
      "packages/BlotGraph/Sources/BlotGraph/GraphNode.swift",
      "packages/BlotGraph/Sources/BlotGraph/GraphEdge.swift",
    ].map((path) => ({ path, purpose: "Реальные общие типы и настройки из инструкции задачи; полная реализация функций выполняется в S14 и G19." })));
  }
  return files;
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
        const writingGuide = writingGuides[source.id];
        if (!writingGuide || writingGuide.length < 80) throw new Error(`Missing specific writing guide: ${source.id}`);
        const implementationKind = epic.id === "A2" ? ([5, 12].includes(number) ? "java" : "configuration") : profile.kind;
        const workPackage = this.#workPackages.find((item) => item.id === fallbackPackage(epic.id, number));
        if (!workPackage) throw new Error(`Unknown work package for ${source.id}`);
        return {
          id: source.id, type: profile.type, title: source.title.replace(/\.$/, ""), priority: ["H20", "E21"].includes(epic.id) ? "P1" : "P0",
          epicId: epic.id, epicTitle: epic.title, ...timing(epic.id, number, profile),
          dependencies: taskDependencies[source.id], covers: [source.id], workPackageIds: [workPackage.id],
          goal: `Блок «${epic.title}». ${source.title}`, result: blueprint.result,
          screens: [...new Set([...profile.screens, ...workPackage.screens])],
          files, writingGuide, implementationKind,
          steps: [writingGuide, `Проверка результата: ${blueprint.verification}`],
          acceptance: [`Получен результат: ${blueprint.result.toLocaleLowerCase("ru")}.`, `Проверка пройдена и сохранено доказательство: ${blueprint.verification}`],
          tests: [blueprint.verification],
        };
      });
    });
  }
}
