const completedIds = new Set(["P0.1", "P0.2", "P0.3", "P0.4", "P0.5", "P0.6", "P0.8", "P0.9", "P0.10"]);

const definitions = [
  ["P0.1", "product-scope.md", "Границы продукта", "Сопоставлены платформы, локальное исполнение и 18 требований."],
  ["P0.2", "domain-glossary.md", "Терминология и инварианты", "Разделены профиль/сессия, задача/попытка и receipt/completion."],
  ["P0.3", "chat-to-run.md", "Чат и рабочий запуск", "Разобраны разговор, явная работа, уточнение, повтор и остановка."],
  ["P0.4", "roles-and-gates.md", "Роли и принятие результата", "Определены автор, независимый reviewer, QA и пользовательские gates."],
  ["P0.5", "permission-policy.md", "Политика разрешений", "Проверены protected refs, scope, инвалидация и отдельные commit/push grants."],
  ["P0.6", "supported-projects.md", "Поддерживаемые проекты", "Выбраны Java/Swift control projects и проверяемые дефекты с до/после."],
  ["P0.7", "platform-matrix.md", "Матрица платформ", "Документ готов. Требуется подтверждение устройств и минимальных OS."],
  ["P0.8", "tool-boundaries.md", "Границы инструментов", "Определены read, patch, process, Git, сеть и допуск native runner."],
  ["P0.9", "data-lifecycle.md", "Жизненный цикл данных", "Прослежены storage, archive, export, restore и удаление данных Kiln."],
  ["P0.10", "acceptance-matrix.md", "Матрица приёмки", "18 требований и 24 блока связаны с экранами, API, задачами и evidence."],
  ["A2.1", "architecture/repo-policy.md", "Репозиторий и Git", "Документ готов. Остались Git-инициализация и clean checkout checks."],
  ["A2.2", "architecture/apple-targets.md", "Targets macOS и iOS", "Документ готов. Остались Xcode targets и native сборки."],
  ["A2.3", "architecture/swift-packages.md", "Общие Swift packages", "Документ готов. Остались manifests, исходники и проверки границ."],
  ["A2.4", "architecture/java-modules.md", "Java-модули", "Документ готов. Остались Gradle wrapper, модули и сборка core."],
  ["A2.5", "architecture/composition-root.md", "Composition root", "Документ готов. Остались DI implementation и test adapters."],
  ["A2.6", "architecture/toolchain.md", "Toolchain и версии", "Документ готов. Остались точные версии, checksums и clean product build."],
  ["A2.7", "architecture/formatting.md", "Форматирование и границы", "Документ готов. Остались configs и executable boundary checks."],
  ["A2.8", "architecture/build-commands.md", "Команды сборки", "Документ готов. Остались build-all.sh и воспроизводимый product build."],
  ["A2.9", "architecture/ci.md", "CI", "Документ готов. Остались workflow и реальные pipeline runs."],
  ["A2.10", "architecture/fixtures.md", "Общие fixtures", "Документ готов. Остались JSON-файлы и decoder tests Java/Swift."],
  ["A2.11", "architecture/contracts.md", "Контракты Swift ↔ Java", "Документ готов. Остались OpenAPI, schema и compatibility tests."],
  ["A2.12", "architecture/logging.md", "Логи и redaction", "Документ готов. Остались LogRedactor и проверки export/output."],
];

function document(id, relativePath, title, summary, taskId = id) {
  return Object.freeze({ id, taskId, path: `docs/${relativePath}`, title, summary, href: `/workspace/documents/${id}`, downloadUrl: `/project-docs/${relativePath}`, completed: completedIds.has(taskId) });
}

export const architectureDocuments = Object.freeze(definitions.map((entry) => document(...entry)));
export const documentationReview = document("documentation-review", "documentation-review.md", "Протокол проверки документов", "Сценарная и структурная проверка документальных результатов.", null);
export const documentationIndex = document("architecture-overview", "README.md", "Архитектура Kiln", "Общий индекс решений, границ и открытых работ.", null);
export const documents = Object.freeze([...architectureDocuments, documentationIndex, documentationReview]);

export function getDocument(id) { return documents.find((item) => item.id === id); }

export function applyDocumentationProgress(tasks) {
  return tasks.map((task) => {
    const artifact = architectureDocuments.find((item) => item.taskId === task.id);
    if (!artifact) return { ...task, status: "planned" };
    return {
      ...task, status: artifact.completed ? "completed" : "planned", deliverables: [artifact],
      documentationSummary: artifact.summary,
      ...(artifact.completed ? { completedAt: "2026-10-11", completionChecks: [artifact.summary, "Проверены полнота документа и сценарии; ссылки и примеры проверяются при сборке."], completionEvidence: documentationReview } : {}),
    };
  });
}
