local _, addon = ...

local L = addon.locale.translations

if GetLocale() ~= "ruRU" then return end

-- Core
L["Welcome to RestedXP Guides\nRight click to pick a guide"] = "Добро пожаловать в RestedXP Гайды\nПКМ — выбрать гайд"
L["Settings"] = "Настройки"
L["Select Guide"] = "Выбрать гайд"
L["Close"] = "Закрыть"
L["Step %d"] = "Шаг %d"

-- Errors
L["Error parsing guide"] = "Ошибка парсинга гайда"
L["Guide has no name"] = "У гайда нет названия"
L["Guide has no contents"] = "Гайд пуст"
L["Invalid guide group"] = "Неверная группа гайда"
L["Invalid function call"] = "Неверный вызов функции"

-- Import
L["Import guide"] = "Импорт гайда"
L["Incomplete or invalid encoded string"] = "Неполная или неверная строка импорта"
L["Incompatible guide, for %d version vs %d"] = "Несовместимый гайд: версия %d против %d"
L["Loading Guides"] = "Загрузка гайдов"
L["Guides Loaded Successfully"] = "Гайды успешно загружены"
L["Failed to ReadCacheData"] = "Не удалось прочитать кэш"
L["Account mismatch, import string does not apply to current account"] = "Несоответствие аккаунта: строка импорта не подходит для текущего аккаунта"
L["Unable to decode cached guide (%s), removed"] = "Не удалось декодировать кэшированный гайд (%s), удалён"

-- Commands
L["RXP Targeting commands:"] = "Команды таргетинга RXP:"
L["Add target"] = "Добавить цель"
L["Clear queue"] = "Очистить очередь"
L["Show queue"] = "Показать очередь"
L["Scan quest log"] = "Сканировать журнал квестов"

-- Misc
L["Development"] = "Разработка"
L["Classic"] = "Классика"
L["Overwriting (%s) v%d"] = "Перезапись (%s) v%d"
L["Newer guide for (%s) already exists (%s) >= checkGuide (%d)"] = "Более новый гайд для (%s) уже существует (%s) >= (%d)"
L["Loading new version for (%s) v%d"] = "Загрузка новой версии для (%s) v%d"
L["Error trying to load a guide already parsed: "] = "Ошибка: попытка загрузить уже распарсенный гайд: "
L["Total guides loaded: %d/%s"] = "Всего загружено гайдов: %d/%s"
L["Failed integrity check"] = "Проверка целостности не пройдена"

-- Quest automation
L["Quest accepted"] = "Квест принят"
L["Quest completed"] = "Квест выполнен"
L["Quest turned in"] = "Квест сдан"

-- Targeting
L["Target queue cleared"] = "Очередь целей очищена"
L["Target queue:"] = "Очередь целей:"
L["Added target"] = "Добавлена цель"
L["Scanned quest log for targets"] = "Журнал квестов просканирован на цели"

-- Step logic
L["RestedXP Speedrun Guide (A)"] = "RestedXP Гайд спидрана (А)"
L["RestedXP Speedrun Guide (H)"] = "RestedXP Гайд спидрана (О)"
L["RXP Speedrun Guide"] = "RXP Гайд спидрана"
L["RXP TBC Survival Guide"] = "RXP Гайд выживания TBC"
L["TBC Speedrun Guide"] = "Гайд спидрана TBC"
L["TBC Survival Guide"] = "Гайд выживания TBC"

-- Communications
L["Party member %s %s quest %d"] = "Член группы %s %s квест %d"
L["%s is on step %d of %s"] = "%s на шаге %d гайда %s"
L["%s found %s at %d, %.1f, %.1f"] = "%s нашёл %s в %d, %.1f, %.1f"

-- UI
L["Hide guide window"] = "Скрыть окно гайда"
L["Show guide window"] = "Показать окно гайда"
L["Reset frame positions"] = "Сбросить позиции фреймов"
L["Import guide string"] = "Импортировать строку гайда"
L["Frame positions reset"] = "Позиции фреймов сброшены"

-- Settings categories
L["Window"] = "Окно"
L["Fonts"] = "Шрифты"
L["Features"] = "Функции"
L["Display"] = "Отображение"
L["Advanced"] = "Расширенные"
L["Game specific"] = "Игровые"
L["Dungeons"] = "Подземелья"

-- Settings options
L["Show guide window"] = "Показывать окно гайда"
L["Hide guide window"] = "Скрыть окно гайда"
L["Lock frames"] = "Заблокировать фреймы"
L["Window scale"] = "Масштаб окна"
L["Frame height"] = "Высота фрейма"
L["Anchor"] = "Якорь"
L["Guide font size"] = "Размер шрифта гайда"
L["Arrow text size"] = "Размер текста стрелки"
L["Enable quest automation"] = "Включить автоматизацию квестов"
L["Enable quest reward automation"] = "Включить автовыбор наград"
L["Enable trainer automation"] = "Включить автоматизацию тренера"
L["Enable flight path automation"] = "Включить автоматизацию полётов"
L["Enable target automation"] = "Включить автотаргет"
L["Enable item upgrades"] = "Включить апгрейд предметов"
L["Enable tips"] = "Включить подсказки"
L["Enable tracker"] = "Включить трекер"
L["Show arrow"] = "Показывать стрелку"
L["Arrow scale"] = "Масштаб стрелки"
L["Active items scale"] = "Масштаб активных предметов"
L["Hide in raid"] = "Скрывать в рейде"
L["Show step list"] = "Показывать список шагов"
L["Update frequency"] = "Частота обновления"
L["Debug mode"] = "Режим отладки"
L["Pre-load data"] = "Предзагрузка данных"
L["Load all guides"] = "Загрузить все гайды"
L["Phase"] = "Фаза"
L["Season"] = "Сезон"
L["XP rate"] = "Множитель опыта"
L["Enable group quests"] = "Включить групповые квесты"
L["Enable XP step skipping"] = "Включить пропуск шагов по уровню"
L["Northrend Loremaster"] = "Хранитель мудрости Нордскола"
L["Loremaster mode"] = "Режим Хранителя мудрости"
L["Solo Self Found"] = "Solo Self Found"
