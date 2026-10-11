// One explicit artifact, result and verification scenario for every specification item.
const rows = (text) => text.trim().split("\n").map((line) => {
  const [file, result, verification] = line.split("|");
  if (!file || !result || !verification) throw new Error(`Incomplete task blueprint: ${line}`);
  return { file, result, verification };
});

export const blueprints = {
  P0: rows(`product-scope.md|Утверждённые функции первой поставки и границы расширений|Сопоставить Mac, iPhone, GigaChat и Git с обязательными сценариями.
domain-glossary.md|Единые определения сущностей и их владельцев|Проверить отсутствие смешения профиля, сессии и попытки.
chat-to-run.md|Правила перехода разговора в рабочее задание|Пройти разговор без задания и явный запуск работы.
roles-and-gates.md|Роли, ответственность и независимые проверки|Проверить, кто исполняет, кто ревьюит и кто принимает итог.
permission-policy.md|Обязательные запросы разрешения и защищённые refs|Разобрать commit, push, повторный scope и запрет main.
supported-projects.md|Поддерживаемые репозитории и контрольные проекты|Проверить наличие воспроизводимой задачи и дефекта для каждого типа проекта.
platform-matrix.md|Минимальные OS, архитектуры Mac и физические устройства|Сверить требования с доступными Mac и iPhone.
tool-boundaries.md|Разрешённые инструменты и пределы управления Mac|Разобрать чтение, patch, shell, сеть и Xcode runner.
data-lifecycle.md|Правила хранения, retention, backup и удаления|Проверить полный жизненный цикл проекта и его артефактов.
acceptance-matrix.md|Связь каждого требования с экраном, API и приёмкой|Проверить отсутствие требований без проверяемого результата.`),
  D1: rows(`inventory.md|Инвентарь существующих frames и компонентов agent.pen|Открыть каждый frame и отметить переиспользуемые элементы.
components.md|Компоненты агентов, задач, сообщений и approvals|Проверить варианты статусов и длинный текст.
graph-semantics.md|Легенда узлов и связей с источниками событий|Проверить различие назначения, сообщения, зависимости и ревью.
team-workspace.md|Desktop-композиция команды, работы и активности|Пройти выбор агента и смену задачи в узком окне.
organization-graph.md|Макет иерархии команды|Проверить сворачивание отделов и выбор сотрудника.
communication-graph.md|Макет общения и активной работы|Открыть сообщение по линии между агентами.
task-dag.md|Макет зависимостей и блокировок задач|Проследить зависимость до её причины.
agent-card.md|Карточка сотрудника с ролью, работой и историей|Проверить активную, ожидающую и архивную сессию.
task-card.md|План и карточка задачи с попытками и критериями|Пройти планирование, ревью и повторную попытку.
channels.md|Общий, ролевой и рабочий каналы|Проверить вопросы, ответы и @mentions.
activity.md|Журнал с переходом к реальному источнику|Открыть задачу, сообщение и разрешение из timeline.
review.md|Ревью, findings и возврат исполнителю|Пройти замечание и исправление нового snapshot.
approval.md|Разрешение с scope, аргументами и последствиями|Сравнить одноразовый grant и ограниченное повторное правило.
failure-states.md|Макеты blocked, error, paused и recovery|Проверить понятность причины и доступного следующего действия.
onboarding.md|Первый запуск и подключение личного GigaChat|Пройти неверный ключ, недоступный сервис и успешный запуск.
pairing.md|QR, доверие устройству и подтверждение на Mac|Пройти подтверждение, отказ и истёкший challenge.
mobile-chat.md|Мобильная навигация и чат|Проверить клавиатуру, черновик и длинные сообщения.
mobile-team.md|Мобильные команда, граф и задачи|Пройти touch-выбор узла и переход к карточке.
mobile-review.md|Мобильные approvals, ревью и diff|Проверить чтение длинного refspec перед подтверждением.
mobile-connection.md|Offline, reconnect и состояние транспорта|Показать stale snapshot и сохранённый черновик.
accessibility.md|Проверенные темы, контраст и доступность макетов|Пройти VoiceOver, Reduce Motion и увеличенный текст.
prototype-flows.md|Связанные desktop и mobile прототипы|Пройти запрос → план → сообщение → ревью → разрешение.
handoff.md|Спецификация компонентов и переходов для SwiftUI|Сверить каждую кнопку с действием и всеми состояниями.`),
  A2: rows(`repo-policy.md|Git-репозиторий и правила защищённой ветки|Проверить чистый checkout и отсутствие секретов.
apple-targets.md|Собираемые macOS и iOS targets|Собрать оба targets из командной строки.
swift-packages.md|Общие Domain, API, Design и Graph packages|Проверить отсутствие SwiftUI в Domain и platform leakage.
java-modules.md|Gradle-модули с явными зависимостями|Собрать core без infrastructure и сетевого SDK.
composition-root.md|Явная композиция сервисов через интерфейсы|Подменить provider и repository тестовыми adapters.
toolchain.md|Зафиксированные Java, Swift и зависимости|Повторить сборку на чистой машине с указанными версиями.
formatting.md|Единое форматирование и проверки границ|Запустить проверки на нарушении импорта между модулями.
build-commands.md|Документированные команды сборки и запуска|Воспроизвести инструкции с нового checkout.
ci.md|CI для Java, Mac и iOS|Проверить отказ pipeline при реальной ошибке сборки.
fixtures.md|Контрольные данные домена и транспорта|Декодировать одни fixtures двумя платформами.
contracts.md|OpenAPI и schema событий|Проверить version conflict и неизвестное событие.
logging.md|Структурированные логи с редактированием секретов|Убедиться, что ключ и токен отсутствуют в выводе.`),
  J3: rows(`project/ProjectRun.java|Сущности проекта, запуска и версии требований|Проверить новую спецификацию без потери предыдущего запуска.
task/TaskAttempt.java|Задачи с зависимостями и историей попыток|Вернуть задачу с ревью и сохранить старый артефакт.
agent/AgentSession.java|Раздельные профиль и рабочая сессия|Создать две сессии одного профиля в разных запусках.
task/TaskStateMachine.java|Проверяемые переходы состояния|Отклонить accepted без независимого ревью.
storage/DatabaseMigrator.java|SQLite schema и последовательные миграции|Обновить старую базу без потери внешних связей.
storage/JdbcTaskRepository.java|Repository interfaces и JDBC adapters|Проверить транзакционный rollback и повторное чтение.
storage/EntityVersion.java|Optimistic locking объектов|Отклонить запись с устаревшей expectedVersion.
events/TransactionalOutbox.java|Согласованные изменения и outbox|Прервать транзакцию и проверить отсутствие лишнего события.
events/EventJournal.java|Упорядоченный журнал seq и eventId|Проверить уникальность ID и порядок публикации.
events/SseEndpoint.java|Аутентифицированная live-подписка|Отказать неизвестному устройству и закрыть отозванную подписку.
events/SnapshotService.java|Snapshot с watermark|Изменить проект во время snapshot и проверить непрерывность событий.
events/EventReplayService.java|Replay, dedup и пагинация|Восстановиться после gap без двойных сообщений.
storage/BackupService.java|Согласованный backup и restore|Восстановить активную WAL-базу и проверить связи.
storage/StorageHealth.java|Понятная остановка при ошибке диска|Заполнить диск и убедиться, что новые изменения не теряются скрыто.
storage/RetentionService.java|Архивация с сохранением ссылок|Архивировать запуск и открыть его ревью и сообщения.`),
  J4: rows(`ProviderGateway.java|Независимый интерфейс провайдера модели|Выполнить runtime с тестовым provider без SDK-зависимости.
GigaChatAdapter.java|Рабочий адаптер GigaChat|Получить реальный ответ личного API-доступа.
SdkCompatibility.java|Зафиксированная совместимость Java SDK|Проверить авторизацию, streaming и functions выбранной версии.
GigaChatStreamAdapter.java|Закрытые пробелы SDK в stream и tool calls|Проверить частичный function call и корректное завершение потока.
GigaChatCredentials.java|Личный ключ из Keychain|Проверить отсутствие ключа в args, файлах и iOS.
SecretBridge.java|Защищённая передача секрета Java|Отклонить подключение постороннего локального процесса.
AccessTokenManager.java|Обновляемый access token|Дождаться истечения и успешно обновить токен.
TokenRefreshCoordinator.java|Один refresh для параллельных запросов|Инициировать несколько запросов с истёкшим токеном.
ModelCatalog.java|Каталог разрешённых моделей|Отклонить недоступную модель и сохранить доступную настройку.
ResponseStream.java|Streaming ответа модели|Проверить отмену после нескольких chunks.
FunctionCatalog.java|Схемы функций в запросе модели|Получить вызов разрешённой функции реальным API.
FunctionCallValidator.java|Проверка имён и аргументов|Отклонить неизвестную функцию и повреждённый JSON.
FunctionResult.java|Результаты tools с корректными ID|Проверить два tool calls без смешения результатов.
GenerationCheckpoint.java|Состояние незавершённой генерации|Прервать поток и показать partial result с причиной.
ProviderErrorClassifier.java|Раздельные auth, network и API errors|Проверить 401, throttling и потерю сети.
GenerationQueue.java|Справедливая очередь одного активного вызова|Запустить несколько агентов и проверить отсутствие параллельной генерации.
GenerationCancellation.java|Отмена и timeout очереди|Отменить ожидающий и выполняющийся запрос.
UsageTracker.java|Фактический usage отдельно от оценки|Сравнить ответ API с записанным расходом.
ProviderFixtures.java|Воспроизводимые повреждённые ответы|Проверить обрыв JSON, неверный call ID и отказ refresh.
ProviderEvaluation.java|Контрольные результаты реального GigaChat|Пройти задачу с tool call и сохранить evidence.`),
  J5: rows(`Capability.java|Каталог разрешённых инструментальных действий|Проверить, что неизвестный инструмент не получает default allow.
PermissionScope.java|Scope роли, проекта и пути|Отклонить действие в другом проекте.
PolicyService.java|Серверная проверка каждого инструмента|Вызвать запрещённый tool напрямую через API.
ProtectedRefPolicy.java|Безусловная защита main и default branch|Проверить обе ветки при разных именах default ref.
RefspecValidator.java|Проверка полного refspec и косвенных refs|Отклонить push с обходом защиты через crafted target.
ApprovalRequest.java|Одноразовый запрос конкретного действия|Повторить approve и проверить одно исполнение.
RecurringGrant.java|Явно разрешённый повторный scope|Отклонить похожее действие вне разрешённого пути.
GrantLimits.java|Срок, счётчик и конкретный hash grant|Превысить число применений и проверить отказ.
GrantRevocation.java|Отзыв пользователем действующего правила|Отозвать grant перед следующей операцией.
PreparedActionValidator.java|Инвалидация изменённого действия|Изменить diff после approve и запросить новое решение.
ApprovalActorPolicy.java|Запрет self-approval агентом|Отправить поддельное решение от имени агента.
PermissionAudit.java|Аудит инициатора, scope и результата|Проследить решение до конкретного устройства и операции.
ExecutionAuthorization.java|Проверка непосредственно перед побочным эффектом|Отозвать разрешение между подготовкой и исполнением.
ApprovalDecisionCoordinator.java|Атомарные решения двух клиентов|Одновременно подтвердить на Mac и iPhone.
DeniedAction.java|Остановка после отказа пользователя|Проверить отсутствие скрытого продолжения через другой tool.
GrantExpiration.java|Отказ истёкшему grant|Выполнить операцию после expiry.
TransportPolicy.java|Одинаковая policy для Wi-Fi, BLE и loopback|Сравнить отказ одной команды на трёх путях.
GitBypassCases.java|Проверенные обходы git и shell|Проверить git -C, detached HEAD, aliases и crafted refs.`),
  J6: rows(`RepositoryConnector.java|Подключение существующего репозитория|Добавить repo с незакоммиченными пользовательскими файлами.
DirtyTreeSnapshot.java|Сохранённое исходное dirty-состояние|Проверить, что пользовательский diff остаётся после работы агента.
BaseRevision.java|Base SHA подготовленной операции|Изменить HEAD и отклонить устаревший patch.
WorktreeManager.java|Отдельные рабочие области исполнителей|Изменять один файл двумя агентами без перезаписи.
IntegrationWorkspace.java|Владелец интеграционной ветки|Отклонить прямую запись исполнителя в integration workspace.
FileSearchTool.java|Чтение и поиск в разрешённом проекте|Проверить отсутствующий файл, большой repo и запрещённый путь.
PatchTool.java|Подготовка и применение patch|Проверить mismatch base SHA и частично неприменимый patch.
DiffTool.java|Diff и список изменённых файлов|Проверить rename, binary file и большой текстовый diff.
CommandRunner.java|Контролируемый интерфейс запуска процессов|Запустить успешную и ошибочную команду с exit code.
RunnerIsolation.java|Доказанная изоляция включая Xcode runner|Проверить доступ за пределы workspace до допуска native builds.
ProcessTimeout.java|Timeout и отмена процесса|Остановить зависшую команду и её дочерние процессы.
ProcessLimits.java|Лимиты ресурсов и вывода|Запустить бесконечный вывод и проверить ограничение памяти.
EnvironmentFilter.java|Фильтрация env и секретов|Проверить отсутствие credentials у дочернего процесса.
ToolNetworkPolicy.java|Контроль сетевых действий runner|Отклонить запрос к неразрешённому endpoint.
CanonicalPathPolicy.java|Защита symlink и traversal|Попытаться читать внешний файл через symlink и ../.
ToolArtifactRecorder.java|Сохраняемые результаты инструментов|Связать command, exit code и output с попыткой.
GitMetadataGuard.java|Ограничение shared Git metadata|Попытаться изменить refs и hooks из worktree.
OperationReconciler.java|Сверка interrupted и unknown операций|Перезапустить Java после побочного эффекта до записи ответа.`),
  J7: rows(`RoleConfiguration.java|Роли через конфигурацию и композицию|Добавить роль без наследования AgentSession.
AgentRegistry.java|Registry профилей и доступных tools|Отклонить профиль с неизвестным инструментом.
SessionFactory.java|Новая сессия конкретного назначения|Создать двух специалистов одного профиля.
AgentLoop.java|Цикл генерации и инструмента с событиями|Пройти model → tool → continuation до результата.
ContextAssembler.java|Индивидуальный контекст назначения|Проверить отсутствие чужих task instructions.
MemoryContext.java|Релевантная память с источниками|Подать факты проекта и исключить чужой проект.
AgentInbox.java|Доставка входящих сообщений|Разблокировать агента ответом коллеги.
SessionControl.java|Управляемые pause, resume и stop|При паузе не начинать новые операции.
SessionArchive.java|Архив с сохранённой историей|Открыть сообщения и артефакты завершённой сессии.
AuthorizedSpawn.java|Контролируемое создание специалиста|Отклонить spawn вне разрешённой роли.
SubtaskAssignment.java|Отдельное назначение подзадачи|Проследить результат дочерней задачи до родителя.
SessionLimits.java|Лимиты контекста и модели|Превысить context budget без потери ограничений.
CapabilityCeiling.java|Запрет повышения полномочий|Попробовать выдать себе tool через модельный ответ.
SessionResult.java|Структурированный результат родителю|Проверить task ID, artifact hash и причины отказа.
SessionCompletion.java|Раздельные completion и archive|Завершить задачу и сохранить сотрудника для следующей.
SessionWatchdog.java|Обнаружение зависших сессий|Оборвать heartbeat без повторного побочного эффекта.`),
  J8: rows(`ProjectIntake.java|Зафиксированная цель пользователя|Создать запуск из запроса с выбранным проектом.
ClarificationService.java|Уточнение существенных требований|Проверить запрос без критериев и ответ пользователя.
SpecificationRevision.java|Версионированные требования|Изменить цель во время запуска и сохранить обе версии.
PlanBuilder.java|План с результатами и проверками|Проверить, что у каждой задачи есть критерий принятия.
PlanValidator.java|Проверка полноты плана|Отклонить план без обязательного независимого ревью.
TaskDag.java|План без циклов зависимостей|Отклонить цикл и неизвестный task ID.
AssignmentService.java|Назначение по роли, правам и загрузке|Не назначать backend-задачу сотруднику без нужного scope.
ReviewerAssignment.java|Независимый reviewer|Отклонить автора как обязательного проверяющего.
ReadyTaskScheduler.java|Запуск только готовых узлов|Не начинать задачу до принятия зависимости.
WaitReason.java|Явная причина ожидания|Различить permission, message, dependency и resource.
ResourceScheduler.java|План с лимитами модели и runner|Проверить очередь при занятых ресурсах.
BlockRelease.java|Продолжение после нужного события|Ответ на вопрос снимает только соответствующую блокировку.
PriorityService.java|Приоритеты и переназначения|Поднять ready-задачу без потери истории прежнего назначения.
UserSteering.java|Новое сообщение в активной работе|Изменить требование до завершения текущей попытки.
ReplanningService.java|Новая версия плана с историей|Сохранить выполненные задачи при перепланировании.
ResultConflictResolver.java|Разрешение конфликтующих результатов|Согласовать два изменения одного API-контракта.
ProgressProjection.java|Фактический прогресс и статус|Не считать ожидание генерации завершённой работой.
RunCompletionGate.java|Завершение после всех обязательных проверок|Отклонить completed при непройденном QA gate.`),
  J9: rows(`Channel.java|Общий, ролевой и рабочий каналы|Изолировать сообщения разных проектов.
DirectMessage.java|Прямые сообщения и @mentions|Доставить вопрос выбранному сотруднику.
MessageKind.java|Различимые текст, вопрос, назначение и результат|Не исполнить текстовое обсуждение как команду.
MessageReference.java|Связь сообщения с task и artifact|Открыть исходный артефакт по ссылке.
MessageRepository.java|История авторов и получателей|Прочитать переписку после перезапуска.
InboxNotification.java|Сигнал нужной сессии|Разбудить ожидающего адресата один раз.
MessageCommandBoundary.java|Раздельные разговор и управляющее событие|Проверить назначение задачи только через явный use case.
MessagePermissionBoundary.java|Переписка не выдаёт полномочия|Отклонить просьбу коллеги сделать запрещённый push.
MessageRateLimit.java|Ограниченный объём внутреннего чата|Остановить лавину сообщений без роста памяти.
ConversationLoopDetector.java|Обнаружение бесконечной переписки|Смоделировать взаимные повторные вопросы.
CommunicationProjection.java|Рёбра графа из реальных сообщений|Сопоставить каждое ребро с message ID.
MessageSearch.java|Поиск и переход к исходнику|Найти старый ответ по тексту и task ID.
ContractConversation.java|Обмен Backend и Native Frontend о контракте|Вопрос → ответ → применение API снимает блокировку.`),
  J10: rows(`ProjectMemory.java|Память проекта|Сохранить решение архитектуры и прочитать новой сессией.
TaskMemory.java|Память отдельной задачи|Не подать частное решение в нерелевантную задачу.
AgentMemory.java|Память сотрудника в рамках проекта|Проверить доступ профиля к чужому проекту.
MemoryEvidence.java|Источник каждого факта|Открыть сообщение или артефакт, подтверждающий запись.
FactConfidence.java|Факты отдельно от предположений|Не отобразить непроверенное предположение как подтверждённое.
MemoryRevision.java|Версия записи и автор изменения|Сохранить историю исправления факта.
MemorySearch.java|Выбор релевантных записей|Проверить поиск по task, источнику и ограничению.
MemoryBudget.java|Ограниченный объём памяти в контексте|Подать длинную историю без превышения лимита.
ConstraintPreservingSummary.java|Ограничения сохраняются при компрессии|Проверить сохранение запрета main после сжатия.
MemoryFreshness.java|Устаревшие факты требуют пересмотра|Изменить контракт и пометить старую запись stale.
MemoryProjectScope.java|Изоляция памяти проектов|Исключить секреты и факты другого repo.
MemoryEditor.java|Пользовательское редактирование и экспорт|Изменить факт и сверить экспорт с текущей версией.
MemoryDeletion.java|Удаление записи и связанных индексов|Убедиться, что удалённый факт больше не возвращается поиском.`),
  J11: rows(`ReviewRequest.java|Ревью конкретного snapshot|Зафиксировать artifact hash до назначения reviewer.
IndependentReviewerPolicy.java|Проверяющий не является автором|Отклонить self-review обязательного gate.
ReviewContext.java|Требования и evidence для reviewer|Проверить доступ к критериям и прошлым findings.
ReviewDecision.java|Решение по неизменяемой версии|Изменить файл и не переносить старое accepted.
ReviewFinding.java|Замечание с severity и условием исправления|Создать finding с местом и воспроизводимой проверкой.
ReviewEvidence.java|Команды, exit codes и доказательства|Сопоставить доказательство с проверяемым snapshot.
ChangesRequested.java|Возврат автору с конкретными замечаниями|Не разрешить интеграцию результата с открытым блокером.
ReviewAttempt.java|Новая попытка исправления|Сохранить diff первой и второй попыток.
ReviewRecheck.java|Повторная проверка нового hash|Не принять исправление без актуального recheck.
ReviewCapabilities.java|Отдельные права reviewer и integrator|Запретить reviewer скрытую запись в рабочую ветку.
ReviewEscalation.java|Эскалация спорного решения|Передать конфликт Tech Lead с полной историей.
IntegrationSnapshot.java|Снимок совместного принятого результата|Зафиксировать исходные hashes всех включённых patches.
IntegrationConflict.java|Разрешение конфликта без потери артефактов|Свести два принятых изменения одного файла.
IntegrationChecks.java|Проверки собранного результата|Запустить реальные тесты после объединения patches.
FinalQualityGate.java|Security и QA перед завершением|Блокировать итог при непройденном security check.
ReviewInvalidation.java|Старое ревью инвалидируется после изменения|Поменять artifact hash после accepted.
TestIntegrityPolicy.java|Проверка честности исправления тестов|Не принять удаление падающего теста как исправление бага.
FinalReport.java|Итоговый отчёт с evidence и ограничениями|Сверить каждый заявленный результат с сохранённым артефактом.`),
  J12: rows(`ArtifactRegistry.java|Registry артефактов и источников|Найти результат по task, автору и инструменту.
ArtifactSnapshot.java|Hash и base SHA результата|Изменить содержимое и проверить новый hash.
UnifiedDiff.java|Читаемый unified diff|Проверить добавление, удаление, rename и окончания строк.
ChangedFileList.java|Список изменённых файлов и причин|Связать каждый файл с назначением задачи.
PreparedCommit.java|Подготовленный commit с точными аргументами|Сверить staged diff, branch и base SHA.
CommitApproval.java|Разрешение на конкретный commit|Отклонить исполнение без решения пользователя.
CommitExecutor.java|Commit только по актуальному grant|Изменить staged diff после approve и отказать.
CommitJournal.java|Созданный SHA в журнале операции|Повторить commandId и получить прежний SHA.
PreparedPush.java|Подготовленный remote и refspec|Показать все target refs до запроса разрешения.
PushApproval.java|Отдельное разрешение push|Не использовать commit grant для отправки изменений.
PushRefPolicy.java|Повторная проверка remote и ветки|Отклонить push в main и default branch.
PushFailure.java|Remote refusal и неизвестный исход|Потерять сеть после возможного принятия remote.
GitStateReconcile.java|Сверка Git перед повтором|Прочитать remote ref до повторного push.
PullRequestAdapter.java|Отдельный контракт расширения PR|Проверить отсутствие создания PR без отдельной capability.
DeliveryArtifact.java|Пакет diff, проверок и итогового отчёта|Открыть переданный пакет без активной сессии.`),
  J13: rows(`Budget.java|Лимиты проекта, запуска и сессии|Проверить достижение каждого уровня лимита.
ActualUsage.java|Фактический usage провайдера|Сверить сохранённые токены с ответом API.
UsageEstimate.java|Оценка отдельно от фактической стоимости|Показать unknown cost без выдуманного факта.
BudgetReservation.java|Резерв перед модельным вызовом|Не допустить гонку двух запросов на остаток бюджета.
BudgetExhaustion.java|Остановка новых генераций|Проверить, что ожидающий запрос не стартует после исчерпания.
BudgetIncrease.java|Понятное увеличение лимита|Продолжить очередь после разрешённого изменения бюджета.
Heartbeat.java|Обнаружение зависшего агента|Отключить heartbeat и показать причину ожидания.
ExecutionCheckpoint.java|Сохраняемый checkpoint|Восстановить план, inbox и cursor после сбоя.
SessionRecovery.java|Возобновление незавершённых сессий|Перезапустить Java во время активной работы.
UnknownOperationRecovery.java|Сверка операций с неизвестным исходом|Не повторить commit до проверки Git.
RetryPolicy.java|Повтор только безопасных действий|Различить transient request и побочный эффект.
CommandDeduplication.java|Защита побочного эффекта от дублей|Отправить одну команду через два транспорта.
PartialOutput.java|Частичный вывод и причина сбоя|Прервать процесс и сохранить полученный output.
LogRotation.java|Ограниченный объём логов|Превысить лимит и сохранить актуальную диагностику.
DiagnosticExport.java|Редактированный пакет диагностики|Просканировать экспорт на ключи, токены и pairing credentials.`),
  S14: rows(`CommandModels.swift|Типизированные команды и события|Декодировать shared fixtures без потери версий и ID.
BackendClient.swift|Отправка команд Java-бэкэнду|Обработать успех, доменную ошибку и timeout.
EventStreamClient.swift|Получение SSE и event envelope|Собрать событие из нескольких сетевых chunks.
EventReconnect.swift|Переподключение с курсором|Догрузить события после обрыва.
ProjectReducer.swift|Предсказуемое состояние проекта|Применить snapshot и последовательность событий.
EventDeduplicator.swift|Однократное применение событий|Повторить eventId и command acknowledgement.
BackendTransport.swift|Transport отдельно от store|Подменить Wi-Fi и BLE без изменения экранов.
ProjectStore.swift|Обновление UI-состояния на MainActor|Проверить события из фонового сетевого потока.
ConnectionState.swift|Loading, error и offline|Показать stale snapshot после потери связи.
CommandReceipt.swift|Acknowledgement отдельно от completion|Не отметить задачу выполненной после HTTP 200.
VersionConflict.swift|Обработка expectedVersion conflict|Перечитать состояние перед новым действием.
CompatibilityCheck.swift|Согласование schema и версии API|Отклонить несовместимый Java-сервис.
PreviewFixtures.swift|Previews основных экранных состояний|Открыть loading, denied, offline и long-text previews.`),
  M15: rows(`App/KilnMacApp.swift|Главное окно и Settings scene|Открыть несколько окон и сохранить нужный проект.
Design/KilnTheme.swift|Токены и компоненты из agent.pen|Сверить светлую и тёмную темы с макетом.
Views/Sidebar/ProjectSidebar.swift|Проекты и команда в sidebar|Выбрать проект и сохранить выделение после обновления.
Views/Projects/AddRepositoryView.swift|Выбор и проверка репозитория|Отклонить не-repo и сохранить dirty tree.
Views/Tasks/NewTaskView.swift|Форма нового задания|Отправить цель с контекстом выбранного проекта.
Views/Chat/ChatView.swift|Общий чат и отправка сообщений|Пройти обычный разговор и рабочий запуск.
Views/Chat/ToolResultView.swift|Streaming и результаты инструментов|Отобразить обрыв потока и ошибочный exit code.
Views/Team/TeamWorkspaceView.swift|Основная среда виртуальной команды|Выбрать специалиста, его задачу и канал.
Views/Team/AgentGraphView.swift|Общий граф в desktop-контексте|Переключить три режима без потери выбранного узла.
Views/Team/AgentDetailView.swift|Карточка роли и рабочей сессии|Показать причину ожидания и историю попыток.
Views/Tasks/ProjectPlanView.swift|План и список задач|Открыть blocked-задачу и её зависимость.
Views/Channels/ChannelView.swift|Каналы и поиск сообщений|Найти ответ коллеги и перейти к задаче.
Views/Activity/ActivityView.swift|Журнал событий с источниками|Открыть artifact и approval из timeline.
Views/Approvals/ApprovalQueueView.swift|Ожидающие пользовательские решения|Показать pending, denied и expired без ложной отправки.
Views/Review/ReviewView.swift|Findings и версия результата|Сверить reviewer и hash текущего diff.
Views/Review/DiffView.swift|Diff и изменённые файлы|Прочитать большой файл, rename и binary change.
Views/Terminal/ToolOutputView.swift|Вывод runner без скрытого исполнения|Показать truncated output и exit code.
Views/Controls/RunControlView.swift|Pause, resume и stop|Остановить новые операции и сохранить checkpoint.
Views/Settings/ModelSettingsView.swift|Модель, доступ и бюджет|Обработать недоступную модель и исчерпанный лимит.
Views/Settings/PermissionSettingsView.swift|Права и доверенные устройства|Отозвать grant и доступ iPhone.
Views/Settings/EnvironmentSettingsView.swift|Окружение и диагностика|Показать отсутствие Xcode runner и ошибку Java.
Views/Extensions/ExtensionsView.swift|Hiring, skills и schedules|Включить skill без расширения прав.
Views/Commands/CommandPalette.swift|Палитра основных действий|Найти команду и перейти к нужному экрану.
Commands/KilnCommands.swift|Горячие клавиши|Пройти новые задачу, поиск и остановку с клавиатуры.
Stores/SelectionStore.swift|Единое выделение задачи и агента|Выбор в графе обновляет карточку и чат.
Views/Layout/WorkspaceLayout.swift|Сворачиваемые панели маленького окна|Уменьшить окно без обрезанных действий.
Accessibility/WorkspaceAccessibility.swift|VoiceOver, клавиатура и Reduce Motion|Пройти основные действия без мыши.
design-comparison.md|Сопоставление готовых экранов с agent.pen|Зафиксировать расхождения для обеих тем.`),
  R16: rows(`RemoteAccessSettings.swift|Явное включение удалённого доступа|Проверить отключённую функцию после новой установки.
RemoteEndpointLifecycle.swift|LAN endpoint только при включённом доступе|Отключить функцию и проверить прекращение новых соединений.
BonjourService.swift|Обнаружение Mac в общей LAN|Найти сервис на физическом iPhone.
ManualEndpoint.swift|Подключение по ручному адресу|Проверить сеть с заблокированным Bonjour.
InstallationIdentity.swift|Identity установки и TLS certificate|Проверить fingerprint при повторном подключении.
PairingChallenge.swift|Одноразовый QR challenge|Отклонить повтор и истёкший QR.
DeviceApprovalView.swift|Подтверждение нового iPhone на Mac|Пройти approve и reject нового устройства.
MacTrustVerifier.swift|Проверка идентичности компьютера|Отклонить другой Mac с тем же именем.
DeviceCredentialStore.swift|Credentials в Keychain|Проверить отсутствие credentials в обычном preferences-файле.
AuthenticatedTransport.swift|Аутентификация каждой команды и подписки|Отклонить неизвестное устройство.
DeviceProjectScope.swift|Доступ только к разрешённым проектам|Запросить snapshot чужого проекта.
RemoteSnapshotClient.swift|Initial snapshot и replay|Догрузить события между snapshot и подключением потока.
RemoteCommandRetry.swift|Повтор с прежним commandId|Оборвать ответ сервера после принятой команды.
EndpointRediscovery.swift|Смена IP без потери доверия|Переподключить Mac к сети с новым адресом.
DeviceRevocation.swift|Отзыв доверия устройства|Прекратить команды и SSE действующего телефона.
RemoteConnectionError.swift|Denied, timeout и compatibility errors|Показать понятное действие после ошибки соединения.
RemoteClientRegistry.swift|Несколько доверенных клиентов|Получить одинаковые события на двух устройствах.
ApprovalSync.swift|Атомарный approve двух клиентов|Одновременно подтвердить один запрос на Mac и iPhone.
RemotePayloadPolicy.swift|Модельный ключ отсутствует на телефоне|Просканировать snapshot и event payload на credentials.
lan-device-checks.md|Проверенные LAN permissions и сети|Пройти denied local network и отсутствие общего Wi-Fi.`),
  B17: rows(`ble-spike.md|Измеренный BLE-прототип Mac ↔ iPhone|Обменяться командами на физических устройствах.
GattProfile.swift|Services и characteristics протокола|Проверить чтение, запись и notify выбранных UUID.
MacPeripheralService.swift|Публикация BLE-сервиса Mac|Найти Mac после повторного включения Bluetooth.
PhoneCentralService.swift|Discovery и connect на iPhone|Проверить timeout и несколько найденных устройств.
BlePairing.swift|Единое доверие для BLE|Отклонить телефон без принятого pairing.
BleProtocolVersion.swift|Версия защищённого протокола|Отклонить несовместимую версию и чужую identity.
BleFragmenter.swift|Сообщения разбиты под доступный payload|Передать сообщение больше одного GATT frame.
BleFrame.swift|Message ID, sequence и длина|Проверить переставленные и повреждённые фрагменты.
BleAcknowledgement.swift|ACK и контроль целостности|Потерять фрагмент и не применить неполное сообщение.
BleRetry.swift|Timeout и повтор фрагмента|Отправить duplicate ACK и проверить отсутствие дубля команды.
BleBackpressure.swift|Ограниченная очередь и память|Передавать большой diff при медленном получателе.
BleCommandCodec.swift|Чат и команды поверх BLE|Отправить задание и проверить Java commandId.
BleEventCodec.swift|Компактные live-события|Сверить состояние задачи с Wi-Fi snapshot.
BleArtifactTransfer.swift|Порционная передача diff и логов|Догрузить большой артефакт после разрыва.
BleGraphThrottle.swift|Ограниченная частота обновления графа|Проверить поток событий без перегрузки UI.
BleReplay.swift|Replay после последнего seq|Восстановить пропущенные события после reconnect.
TransportHandoff.swift|Wi-Fi/BLE без второго логического запуска|Переключить транспорт во время отправки команды.
BleConnectionState.swift|Permission и background errors|Показать denied Bluetooth и unavailable Mac.
BleLifecycle.swift|Проверенные background/resume и radio loss|Заблокировать iPhone и вернуться после потери сигнала.
ble-performance.md|Throughput и документированные ограничения|Измерить размеры, задержку и допустимый объём diff.`),
  I18: rows(`Navigation/AppTab.swift|Навигация Чат, Команда, Задачи, Активность|Проверить переходы и сохранение выбранного проекта.
Design/MobileTheme.swift|Общая дизайн-система на iPhone|Сверить компоненты и две темы.
Views/Connection/ComputerListView.swift|Список доверенных Mac|Открыть ранее связанный и удалённый компьютер.
Views/Connection/DiscoveryView.swift|Поиск компьютера|Проверить пустой результат и повторный discovery.
Views/Connection/PairingView.swift|QR scanner и ручной адрес|Пройти отказ камеры и истёкший QR.
Views/Connection/ConnectionStatusView.swift|Тип и состояние соединения|Сравнить Wi-Fi, BLE, offline и reconnect.
Views/Projects/ProjectListView.swift|Проекты выбранного Mac|Выбрать проект без доступа и обработать отказ.
Views/Chat/MobileChatView.swift|Обычный мобильный разговор|Прочитать поток ответа и сохранить черновик.
Views/Chat/NewRunView.swift|Рабочее задание с iPhone|Проверить созданную задачу и файл на Mac.
Views/Chat/AgentMentionView.swift|@mention специалиста|Доставить вопрос выбранной сессии.
Views/Team/MobileTeamView.swift|Состав команды и текущая работа|Сопоставить статус сотрудников с Mac.
Views/Team/MobileAgentView.swift|Карточка сотрудника|Показать waiting reason и активную задачу.
Views/Team/MobileGraphView.swift|Touch-граф и доступный список|Пройти pan, zoom и выбор узла.
Views/Tasks/MobileTaskView.swift|Задачи, зависимости и попытки|Открыть результат предыдущей попытки.
Views/Channels/MobileChannelView.swift|Внутренние каналы|Найти сообщение Backend и открыть source task.
Views/Activity/MobileActivityView.swift|Live-активность и фильтры|Перейти из события к разрешению.
Views/Approvals/MobileApprovalView.swift|Точные разрешения с телефона|Подтвердить актуальное и отклонить stale действие.
Views/Review/MobileReviewView.swift|Reviewer, findings и evidence|Сверить hash с текущей версией результата.
Views/Review/MobileDiffView.swift|Diff с порционной загрузкой|Прочитать большой файл через BLE.
Views/Controls/MobileRunControl.swift|Удалённые pause, resume и stop|Проверить реальное состояние Mac после команды.
Services/HistoryCache.swift|Snapshot и неотправленные черновики|Перезапустить приложение offline без потери текста.
Stores/CommandReceiptStore.swift|Sending, acknowledged и completion|Не показать HTTP acknowledgement как готовую работу.
Services/AppLifecycleCoordinator.swift|Catch-up после фона|Завершить работу на Mac и вернуться в приложение.
Services/CommandRecovery.swift|Потеря связи во время отправки|Повторить commandId и не создать второй запуск.
Accessibility/MobileAccessibility.swift|Dynamic Type, VoiceOver и длинный текст|Пройти основной сценарий при крупном шрифте.
ios-design-comparison.md|Сопоставление UI с mobile frames agent.pen|Сверить переходы и состояния обеих тем.
ios-device-acceptance.md|Полный сценарий физического iPhone|Пройти pairing, чат, граф, review и approve.`),
  G19: rows(`GraphNode.swift|Типизированные узлы и связи|Декодировать агента, задачу, сообщение и review edge.
GraphProjection.swift|Граф из событий домена|Проверить source ID каждого ребра.
OrganizationLayout.swift|Организационный layout|Разложить сотрудников по отделам без пересечений.
DependencyLayout.swift|Layout DAG задач|Показать несколько уровней и blocked dependency.
StableGraphLayout.swift|Положение узлов устойчиво при live updates|Добавить событие без скачка выбранного узла.
GraphGrouping.swift|Сворачивание отделов и подграфов|Сохранить внешние связи скрытой группы.
GraphFilter.swift|Фильтры агента, задачи, роли и состояния|Не показать посторонние edges после фильтрации.
GraphGestures.swift|Pan и zoom мышью и touch|Пройти одинаковый сценарий на Mac и iPhone.
GraphSelection.swift|Выделение связано с карточкой и чатом|Выбрать task node и проверить общий selection state.
GraphEdgeSource.swift|Открытие источника связи|Перейти к сообщению, назначению или review record.
GraphTransferState.swift|Активность по реальному событию|Не анимировать передачу без существующего события.
GraphMotionPolicy.swift|Reduce Motion без потери смысла|Проверить статическую индикацию активности.
GraphAccessibleList.swift|Доступная альтернатива графу|Открыть узел и связь через VoiceOver.
GraphPerformanceFixtures.swift|Большие команды и история|Измерить layout и частоту обновления на целевом устройстве.
GraphParityTests.swift|Одинаковый смысл графа двух платформ|Сравнить projection одного snapshot на Mac и iPhone.`),
  H20: rows(`SpecialistCatalog.java|Каталог доступных профилей|Проверить роли, модели и ограничения каждого профиля.
CandidateSelector.java|Кандидаты под конкретную задачу|Исключить профиль без нужной capability.
CandidateReason.java|Причины выбора роли и модели|Показать источник каждой причины рекомендации.
HiringDecision.java|Выбор пользователя или оркестратора|Принять кандидата и сохранить инициатора решения.
PerformanceRecord.java|Статистика сессии и попытки|Связать метрики с task и версией инструкции.
WorkDuration.java|Время работы отдельно от ожидания|Не учитывать очередь модели как активное выполнение.
PerformanceUsage.java|Фактические токены и стоимость|Проверить неизвестную цену без выдуманной метрики.
QualityComparison.java|Сопоставимое качество результатов|Сравнить задачи одной категории и complexity.
SampleSize.java|Размер и достаточность выборки|Показать недостаток данных для одного запуска.
AssignmentHistory.java|История назначения специалиста|Проследить смену исполнителя и её причину.
ReassignmentReason.java|Объяснение переназначения и отказа|Проверить отсутствие скрытой смены роли.
EvaluationFixtureVersion.java|Версии evaluation-набора|Сравнить результаты только совместимых fixtures.
ProfileInstructionRevision.java|История инструкции профиля|Сохранить старую версию после обновления skill.
ModelChangeHistory.java|Смена модели с сохранением истории|Не смешать usage двух моделей в одном факте.`),
  E21: rows(`SkillDefinition.java|Версионированный формат skill|Отклонить несовместимую схему инструкции.
SkillApplicability.java|Роль и условия применения|Не подать backend skill нерелевантной сессии.
ActiveInstructionView.swift|Видимые действующие инструкции|Открыть текущую версию и источник skill.
SkillPermissionBoundary.java|Skill не расширяет инструменты|Отклонить инструкцию, требующую push без grant.
SkillSettingsView.swift|Включение и отключение skills|Изменить настройку и проверить следующий context assembly.
LocalScheduler.java|Локальный запуск по расписанию|Создать запуск на работающем Mac.
ScheduleTimeZone.java|Timezone и календарные переходы|Проверить переход дня и смену timezone.
ScheduledRunDedup.java|Защита расписания от дублей|Обработать два одновременных wake events.
MissedRunPolicy.java|Явная обработка sleep и missed run|Разбудить Mac после пропущенного времени.
AutomationBudget.java|Отдельный лимит автоматизации|Остановить генерации по исчерпанному бюджету.
ScheduleAvailabilityView.swift|Требование доступного Mac|Показать unavailable host вместо ложного выполненного запуска.
ExternalAdapter.java|Интерфейсы внешних расширений|Подменить adapter без изменения domain core.
GitHubCiAdapter.java|Контракт GitHub и CI расширения|Проверить mock provider без внешней публикации.
ExternalActionApproval.java|Отдельные grants внешних действий|Не отправить сообщение или PR по локальному Git grant.`),
  Q22: rows(`domain-state-tests.md|Проверены доменные инварианты|Отклонить forbidden transitions и self-review.
permission-policy-tests.md|Проверены policy и защищённые refs|Проверить main, default branch и crafted refspec.
shared-contract-tests.md|Совпадают Java и Swift контракты|Декодировать общий набор ошибок, команд и событий.
crash-recovery-tests.md|Проверены recovery и идемпотентность|Прервать Java до и после побочного эффекта.
control-repository.md|Контрольный repo с известным дефектом|Воспроизвести баг и падающую проверку на исходном SHA.
gigachat-evaluation.md|Работает реальный личный GigaChat|Пройти stream и tool call без тестового provider.
platform-ui-tests.md|Работают экраны Mac и iPhone|Пройти чат → команда → граф → ревью → approval.
physical-connectivity-tests.md|Проверены Wi-Fi и BLE на устройствах|Переключить транспорт во время отправки команды.
security-audit.md|Проверены секреты, pairing и обходы|Отклонить неизвестное устройство и symlink escape.
accessibility-audit.md|Проверены темы и доступность|Пройти VoiceOver, клавиатуру, Dynamic Type и Reduce Motion.
performance-baseline.md|Измерены стабильность и производительность|Проверить длинную историю и live-граф по согласованным бюджетам.
acceptance-protocol.md|Заполненный протокол всех финальных gates|Сверить каждое утверждение с evidence конкретной сборки.`),
  L23: rows(`bundled-runtime.md|Минимальная Java runtime внутри bundle|Запустить приложение на Mac без системной Java.
JavaProcessSupervisor.swift|Управляемый локальный Java-процесс|Проверить запуск, stop и отсутствие orphan process.
BackendReadiness.swift|Readiness и compatibility перед работой|Не открыть рабочие команды до готовности сервиса.
BackendRestartPolicy.swift|Ограниченные automatic restarts|Повторить сбой и показать восстановимое состояние ошибки.
BackendInstanceLock.swift|Один процесс на установку|Открыть два окна без второго сервера.
ApplicationSupportPaths.swift|Данные отдельно от app bundle|Переустановить приложение без потери истории.
ShutdownCheckpoint.swift|Checkpoint перед завершением|Завершить Mac-приложение в активном запуске.
WindowLifecycle.swift|Раздельные close window и quit|Закрыть окно и проверить принятую lifecycle policy.
ChildProcessShutdown.swift|Корректная остановка runner-процессов|Завершить приложение при работающем дочернем tool.
macos-signing.md|Подпись и entitlements Mac|Проверить hardened runtime и запрошенные permissions.
macos-notarization.md|Notarization и доверие Gatekeeper|Установить скачанную сборку на чистый Mac.
ios-beta.md|Подписанная мобильная beta|Установить на физический iPhone и пройти pairing.
release-compatibility.md|Матрица версий клиентов и Java|Проверить старый iOS-клиент с новым backend schema.
release-migration.md|Обновление существующих данных|Мигрировать историю проекта из предыдущей beta.
release-diagnostics.md|Безопасный diagnostic export|Проверить отсутствие ключей и credentials.
installation-guide.md|Инструкции сборки, установки и pairing|Воспроизвести установку по документу без автора рядом.
clean-install-check.md|Проверенная чистая установка|Пройти полный сценарий на новом Mac и iPhone.
handoff-protocol.md|Переданные сборки, исходники и evidence|Сверить версии, комплект и финальный список дефектов.`),
};
