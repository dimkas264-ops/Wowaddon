print("=== DRAENEI GUIDE FILE LOADED ===")
print("RXPGuides exists:", RXPGuides ~= nil)
if RXPGuides then print("RegisterGuide type:", type(RXPGuides.RegisterGuide)) end

local faction = UnitFactionGroup("player")
print("Faction:", faction)
if faction == "Horde" then 
    print("Horde detected, skipping")
    return 
end

print("About to call RegisterGuide...")

RXPGuides.RegisterGuide([[
#wotlk
#group RestedXP Alliance 1-20
#defaultfor Draenei
#name 1-12 Остров Лазурной Дымки
#next 11-20 Остров Кровавой Дымки (Дренеи)

step
.goto Azuremyst Isle,84.19,43.03
>>Поговорите с Мегелоном
.target Megelon
.accept 9279 >>Принять: Ты выжил!

step  << Shaman
#completewith next
.goto Azuremyst Isle,80.0,47.1
.vendor >> Убейте 2-3 мобов для продажи хлама (на 10м+), затем продайте хлам внутри
step  << Shaman
.goto Azuremyst Isle,79.277,49.123
.trainer >> Выучить: Оружие Камнедробителя

step  << Warrior
#completewith next
.goto Azuremyst Isle,80.0,47.1
.vendor >> Убейте 2-3 мобов для продажи хлама (на 10м+), затем продайте хлам внутри
step  << Warrior
.goto Azuremyst Isle,79.587,49.446
.trainer >> Выучить: Боевой крик

step  << Priest/Mage
#completewith next
.goto Azuremyst Isle,79.3,50.9
.vendor >> Убейте мобов, пока не наберется 48м на хлам. Продайте хлам, затем купите 10 воды у Риоша
.collect 159,10 >> Собрать: Освежающая родниковая вода (x10)

step
.goto Azuremyst Isle,80.419,45.885
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Проэнитусом|r
.target Proenitus
.turnin 9279 >> Сдать: Ты выжил!
.accept 9280 >> Принять: Восполнение кристаллов

step
.goto Azuremyst Isle,79.1,46.5
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Ботаником Тэриксом|r
.target Botanist Taerix
.accept 10302 >> Принять: Нестабильные мутации

step
#sticky
#label mothblood
>> Убивайте и собирайте кровь с |cRXP_ENEMY_Мотыльков долины|r
.complete 9280,1 >> Собрать: Флакон с кровью мотылька (x8)

step
.goto Azuremyst Isle,78.4,44.3
>> Приоритет на квест "Нестабильные мутации". Сначала сдайте его, затем идите к Корневым плеточникам. Кровь мотыльков можно добить по пути обратно.
.complete 10302,1 >> Убить: Нестабильная мутация (x8)

step
.goto Azuremyst Isle,79.1,46.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Ботаником Тэриксом|r
.target Botanist Taerix
.turnin 10302 >> Сдать: Нестабильные мутации
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Учеником Вишаэлем|r
.target Apprentice Vishael
.accept 9799 >> Принять: Ботаническая работа

step
.goto Azuremyst Isle,74.5,48.5
>> Убивайте плеточников и собирайте маленькие цветы на земле
.complete 9799,1 >> Собрать: Оскверненный цветок (x3)
.complete 9293,1 >> Собрать: Образец плеточника (x10)

step
.goto Azuremyst Isle,79.1,46.5
.xp 4-420 >> Фармите, пока до 4-го уровня не останется 420 ед. опыта (980/1400)

step
#requires mothblood
.goto Azuremyst Isle,79.1,46.5
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Ботаником Тэриксом|r
.target Botanist Taerix
.turnin 9293 >> Сдать: Должное
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Учеником Вишаэлем|r
.turnin 9799 >> Сдать: Ботаническая работа

step
.goto Azuremyst Isle,80.4,45.8
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Проэнитусом|r
.target Proenitus
.turnin 9280 >> Сдать: Восполнение кристаллов
.accept 9409 >> Принять: Срочная доставка!

step
#completewith next
.goto Azuremyst Isle,80.0,47.1
.vendor >> Продать хлам и починить экипировку

step  << Mage
#completewith next
.goto Azuremyst Isle,79.582,48.762
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Валаату|r
.target Valaatu
.turnin 9290 >> Сдать: Обучение мага
.trainer >> Выучить новые заклинания

step  << Paladin
#completewith next
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Аурелоном|r
.target Aurelon
.turnin 9287 >> Сдать: Обучение паладина
.goto Azuremyst Isle,79.695,48.236
.trainer >> Выучить новые заклинания

step
.goto Azuremyst Isle,79.9,49.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Залдуном|r
.target Zalduun
.turnin 9409 >> Сдать: Срочная доставка!
.accept 9283 >> Принять: Спасение выживших!

step  << Shaman
.goto Azuremyst Isle,79.277,49.123
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Фирманвааром|r
.target Firmanvaar
.accept 9449 >> Принять: Зов Земли
.turnin 9421 >> Сдать: Обучение шамана
.trainer >> Выучить: Удар Земли

step  << Shaman
.goto Azuremyst Isle,71.315,39.097
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Духом долины|r
.target Spirit of the Vale
.turnin 9449 >> Сдать: Зов Земли
.accept 9450 >> Принять: Зов Земли

step  << Warrior
.goto Azuremyst Isle,79.587,49.446
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Коре|r
.target Kore
.turnin 9289 >> Сдать: Обучение воина
.trainer >> Выучить новые заклинания

step
#sticky
#label survivors
>> Используйте заклинание |cRXP_FRIENDLY_Дар наару|r на одного из раненых выживших снаружи здания. Они разбросаны по всей стартовой зоне.
.complete 9283,1 >> Спасено дренейских выживших

step  << Shaman
.goto Azuremyst Isle,70.1,36.6
.complete 9450,1 >> Убить: Беспокойный дух земли (x4)

step  << Shaman
.goto Azuremyst Isle,71.315,39.097
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Духом долины|r
.target Spirit of the Vale
.turnin 9450 >> Сдать: Зов Земли
.accept 9451 >> Принять: Зов Земли

step  << Shaman
.goto Azuremyst Isle,79.277,49.123
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Фирманвааром|r
.target Firmanvaar
.turnin 9451 >> Сдать: Зов Земли

step  << Hunter
.goto Azuremyst Isle,79.86,49.67
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Килнеем|r
.target Keilnei
.accept 9288 >> Принять: Обучение охотников
.turnin 9288 >> Сдать: Обучение охотников
.train 1978 >> Выучить: Укус змеи

step  << Priest
.goto Azuremyst Isle,79.3,50.9
.vendor >> Купите еще воды у Риоша
.collect 159,10 >> Собрать: Освежающая родниковая вода (x15)

step  << Hunter
#completewith next
.goto Azuremyst Isle,79.3,50.9
.vendor >> Купите 6 стопок стрел у Муры

step
#label spareparts2
.goto Azuremyst Isle,79.4,51.3
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Техником Жанаа|r
.target Technician Zhanaa
.accept 9305 >> Принять: Запасные части

step
.goto Azuremyst Isle,79.5,51.7
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Карающим Алдаром|r
.target Vindicator Aldar
.accept 9303 >> Принять: Прививка

step
.goto Azuremyst Isle,85.3,66.2
.use 22962 >> Используйте |cRXP_FRIENDLY_Кристалл для прививки|r из сумок на |cRXP_ENEMY_Совухов из Гнездной рощи|r.
>> Собирайте Излучатели на земле (выглядят как вращающиеся розовые кристаллы).
.complete 9303,1 >> Привитые совухи (x6)
.complete 9305,1 >> Собрать: Запасная часть излучателя (x4)

step
#sticky
#completewith next
.deathskip >> Агрите много совухов и умрите специально. Можно встать на костер. Возродитесь у духа на Месте крушения.

step
.goto Azuremyst Isle,79.4,51.3
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Техником Жанаа|r
.target Technician Zhanaa
.turnin 9305 >> Сдать: Запасные части

step
.goto Azuremyst Isle,79.5,51.5
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Карающим Алдаром|r
.target Vindicator Aldar
.turnin 9303 >> Сдать: Прививка
.accept 9309 >> Принять: Пропавший разведчик

step
#completewith next
.goto Azuremyst Isle,79.3,50.9
.vendor >> Продать хлам и починиться

step
.goto Azuremyst Isle,77.3,58.7
>> Кликните на большой кристалл внутри озера
.complete 9294,1 >> Собрать: Рассеивание нейтрализующего агента (x1)

step
.goto Azuremyst Isle,71.998,60.856
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Толааном|r
.target Tolaan
.turnin 9309 >> Сдать: Пропавший разведчик
.accept 10303 >> Принять: Эльфы крови

step
.goto Azuremyst Isle,70.1,63.5
.complete 10303,1 >> Убить: Разведчик эльфов крови (x10)

step
.goto Azuremyst Isle,72.0,61.0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Толааном|r
.target Tolaan
.turnin 10303 >> Сдать: Эльфы крови
.accept 9311 >> Принять: Шпионка эльфов крови

step
.goto Azuremyst Isle,69.2,65.5
.complete 9311,1 >> Убить: Геодезист Кандресс (x1)
.use 24414 >> Соберите планы с Геодезиста и кликните по ним в сумке
.accept 9798 >> Принять: Планы эльфов крови

step
#sticky
#completewith next
.xp 6-1485 >> Фармите эльфов, пока до 6-го уровня не останется 1485 ед. опыта (1315/2800). На последнем мобе оставьте себе мало ХП, мы будем делать death skip.

step
.deathskip >> Умрите и поговорите с целителем душ, чтобы возродиться на кладбище
.goto Azuremyst Isle,79.2,46.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Ботаником Тэриксом|r
.target Botanist Taerix
.turnin 9294 >> Сдать: Исцеление озера

step
#label survivors2
#requires survivors
.goto Azuremyst Isle,80.1,49.0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Залдуном|r
.target Zalduun
.turnin 9283 >> Сдать: Спасение выживших!

step
.goto Azuremyst Isle,79.488,51.622
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Карающим Алдаром|r
.target Vindicator Aldar
.turnin 9311 >> Сдать: Шпионка эльфов крови
.turnin 9798 >> Сдать: Планы эльфов крови
.accept 9312 >> Принять: Излучатель

step
.goto Azuremyst Isle,79.422,51.234
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Техником Жанаа|r
.target Technician Zhanaa
.turnin 9312 >> Сдать: Излучатель
.accept 9313 >> Принять: Путь в Лазурную Заставу

step
#requires survivors2
.goto Azuremyst Isle,64.6,54.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Аэуном|r
.target Aeun
.accept 9314 >> Принять: Весть из Лазурной Заставы

step
.goto Azuremyst Isle,61.1,54.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Диктинной|r
.target Diktynna
.accept 9452 >> Принять: Красный луциан – очень вкусно!

step
#completewith end
>> Ищите |cRXP_FRIENDLY_Дренейских детенышей|r. Это редкий моб. Если найдете, используйте на нем |cRXP_FRIENDLY_Дар наару|r (вашу расовую способность), пока он дерется с мобом. Затем примите квест.
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Дренейским детенышем|r
.target Draenei Youngling
.accept 9612 >> Принять: Сердечная благодарность!
.unitscan Draenei Youngling

step
#sticky
#completewith next
.use 23654 >> Бегите на север вдоль реки, используйте рыболовную сеть на косяках рыбы. Когда дойдете до конца реки, идите искать Задохликов. Постарайтесь сделать хотя бы 50% этого квеста, позже будет еще шанс.
.collect 23614,10

step
.goto Azuremyst Isle,53.9,34.4
.use 23678 >> Двигайтесь на запад вдоль побережья, убивая Задохликов-инфекционеров, пока не выпадет Тускло светящийся кристалл.
.collect 23678,1
.accept 9455 >> Принять: Странные находки

step
#sticky
#completewith next
.goto Azuremyst Isle,56.1,39.3
.deathskip >> Умрите специально и возродитесь у Лазурной Заставы
>> Убедитесь, что умираете рядом с прудом у подножия горы

step
#completewith next
.goto Azuremyst Isle,49.0,51.6,150
>> Идите в Лазурную Заставу

step
.goto Azuremyst Isle,48.4,51.6
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Анахоретом Фатимой|r
.target Anchorite Fateema
.accept 9463 >> Принять: Лекарственная цель

step  << Shaman
#sticky
.goto Azuremyst Isle,49.6,53.1,0
>> Купите посох (Walking stick), если есть 5с
.collect 2495,1

step
.isOnQuest 9612
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Экзархом Менелаем|r
.target Exarch Menelaous
.turnin 9612 >> Сдать: Сердечная благодарность!
.turnin 9455 >> Сдать: Странные находки
.accept 9456 >> Принять: Великая охота на лунного оленя (часть 2)

step  << Warrior/Paladin
.goto Azuremyst Isle,49.0,51.1
.trainer >> Выучить горное дело и использовать Поиск минералов. Вы добываете грубые камни для заточек позже.

step
.goto Azuremyst Isle,47.2,50.6
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Экзархом Менелаем|r
.target Exarch Menelaous
.turnin 9455 >> Сдать: Странные находки
.accept 9456 >> Принять: Великая охота на лунного оленя (часть 2)

step  << Shaman
.goto Azuremyst Isle,48.05,50.42
.trainer >> Выучить новые заклинания

step
.goto Azuremyst Isle,48.7,50.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Техником Дивууном|r
.target Technician Dyvuun
.turnin 9313 >> Сдать: Путь в Лазурную Заставу

step
.goto Azuremyst Isle,48.4,49.3
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Попечительницей Челлан|r
.target Caregiver Chellan
.turnin 9314 >> Сдать: Весть из Лазурной Заставы

step
.goto Azuremyst Isle,48.4,49.3
.home >> Установить камень возвращения в Лазурную Заставу

step  << Paladin
.goto Azuremyst Isle,48.4,49.5
.trainer >> Выучить новые заклинания

step  << Priest
.goto Azuremyst Isle,48.603,49.285
.trainer >> Выучить новые заклинания
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Гуваном|r
.target Guvan
.accept 9586 >> Принять: Помощь Таваре

step  << Mage
.goto Azuremyst Isle,49.9,50.0
.trainer >> Выучить новые заклинания

step  << Warrior
.goto Azuremyst Isle,50.023,50.515
.trainer >> Выучить новые заклинания

step  << Hunter
.goto Azuremyst Isle,49.780,51.938
.trainer >> Выучить новые заклинания

step
#sticky
#completewith azuremyst1
>> Убивайте и лутайте Корневых ловчих и Лунных оленей по ходу квестов. Фармите даже после сдачи квеста. Впереди большой шаг на фарм опыта.
.complete 9463,1
.collect 23676,6 >> Собрать: Вырезка лунного оленя (x6)

step  << Priest
.goto Azuremyst Isle,56.1,48.9
.complete 9586,1 >> Исцелить Тавару

step
.goto Azuremyst Isle,47.0,70.1
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Адмиралом Одей|r
.target Admiral Odesyus
.accept 9506 >> Принять: Малое начало

step
.goto Azuremyst Isle,46.687,70.629
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_"Пирожком" Слабосоусом|r
.target "Cookie" McWeaksauce
.accept 9512 >> Принять: Джамбо-гумбо от Пирожка

step
.goto Azuremyst Isle,46.4,71.2
.vendor >> Продать хлам и починиться
.trainer >> Выучить кузнечное дело и купить Кирку у Калипсо. Это позволит делать заточки (+2 к урону), которые очень сильны. Перестаньте их делать на 20 уровне.  << Warrior
.trainer >> Выучить кузнечное дело и купить Кирку у Калипсо. Это позволит делать грузила (+2 к урону). Перестаньте их делать на 20 уровне.  << Paladin

step
.goto Azuremyst Isle,58.5,66.3
>> Фармите по пути
>> Лутайте карту в одной из палаток
.complete 9506,2 >> Собрать: Навигационная карта (x1)

step
.goto Azuremyst Isle,59.5,67.6
>> Лутайте компас в одной из палаток
.complete 9506,1 >> Собрать: Навигационный компас (x1)

step
.goto Azuremyst Isle,48.8,72.7
>> Убивайте крабов на побережье
.complete 9512,1 >> Собрать: Мясо скользящего краба (x6)

step
.goto Azuremyst Isle,46.7,70.5
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_"Пирожком" Слабосоусом|r
.target "Cookie" McWeaksauce
.turnin 9512 >> Сдать: Джамбо-гумбо от Пирожка

step
.goto Azuremyst Isle,47.0,70.3
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Адмиралом Одей|r
.target Admiral Odesyus
.turnin 9506 >> Сдать: Малое начало
.accept 9530 >> Принять: У меня есть растение!
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Жрицей Кайлин Иль'динар|r
.target Priestess Kyleen Il'dinare
.accept 9513 >> Принять: Отвоевание руин

step
.goto Azuremyst Isle,47.2,70.1
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Археологом Адамантом Железным Сердцем|r
.target Archaeologist Adamant Ironheart
.accept 9523 >> Принять: Хрупкие и драгоценные вещи требуют особого обращения

step
#sticky
.goto Azuremyst Isle,48.1,63.2
>> Найдите выдолбленный пень рядом с местом, где крестьяне рубят лес
.complete 9530,1 >> Собрать: Выдолбленное дерево (x1)

step
.goto Azuremyst Isle,46.9,66.1
>> Фармите, ища кучи фиолетовых листьев на окраине Лагеря Одей
.complete 9530,2 >> Собрать: Куча листьев (x5)

step
#label azuremyst1
.goto Azuremyst Isle,47.1,70.1
>> Фармите по пути
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Адмиралом Одей|r
.target Admiral Odesyus
.turnin 9530 >> Сдать: У меня есть растение!
.accept 9531 >> Принять: В компании дерева

step
.goto Azuremyst Isle,39.4,73.9
>> Добейте Корневых ловчих и оленей.
.complete 9463,1 >> Собрать: Лоза корневого ловчего (x8)
.complete 9454,1 >> Собрать: Вырезка лунного оленя (x6)

step
.xp 8-950 >> Фармите, пока до 8-го уровня не останется 950 ед. опыта (3550/4500). Постарайтесь закончить рядом с Лазурной Заставой.

step
.goto Azuremyst Isle,49.780,51.938
>> Умрите и возродитесь в Лазурной Заставе или добегите, если осталось меньше 100 метров.

step
.goto Azuremyst Isle,49.780,51.938
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Актеоном|r
.target Acteon
.accept 9454 >> Принять: Великая охота на лунного оленя
.turnin 9454 >> Сдать: Великая охота на лунного оленя
.accept 10324 >> Принять: Великая охота на лунного оленя (повторная)

step
.goto Azuremyst Isle,48.390,51.770
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Анахоретом Фатимой|r
.target Anchorite Fateema
.turnin 9463 >> Сдать: Лекарственная цель
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Дедалом|r
.target Daedal
.accept 9473 >> Принять: Альтернативная альтернатива

step
.goto Azuremyst Isle,48.9,51.1
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Дулви|r
.target Dulvi
.accept 10428 >> Принять: Пропавший рыбак

step
.goto Azuremyst Isle,49.365,51.086
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Криптографом Арреном|r
.target Cryptographer Aurren
.accept 9538 >> Принять: Изучение языка

step
.goto Azuremyst Isle,49.365,51.086
.use 23818 >> Кликните по "Букварю лесных фурболгов" в сумке
.complete 9538,1 >> Букварь лесных фурболгов прочитан

step
.goto Azuremyst Isle,49.365,51.086
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Тотемом гу|r
.target Totem of Akida
.turnin 9538 >> Сдать: Изучение языка
.accept 9539 >> Принять: Тотем гу

step  << Shaman
.goto Azuremyst Isle,48.05,50.41
.trainer >> Выучить новые заклинания

step  << Hunter
.goto Azuremyst Isle,49.780,51.938
.trainer >> Выучить новые заклинания

step  << Priest
.goto Azuremyst Isle,48.6,49.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Гуваном|r
.target Guvan
.turnin 9586 >> Сдать: Помощь Таваре
.trainer >> Выучить новые заклинания

step  << Paladin
.goto Azuremyst Isle,48.4,49.5
.trainer >> Выучить новые заклинания

step  << Mage
.goto Azuremyst Isle,49.9,50.0
.trainer >> Выучить новые заклинания

step  << Warrior
.goto Azuremyst Isle,50.023,50.515
.trainer >> Выучить новые заклинания

step
#sticky
#completewith azuremyst2
>> Убивайте Задохликов и Лунных оленей-самцов по ходу квестов
.complete 9456,1 >> Убить: Задохлик-инфекционер (x8)
.complete 10324,1

step
>> Фармите по пути
.goto Azuremyst Isle,49.9,45.9,100,0
.goto Azuremyst Isle,55.2,41.6
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Тотемом гу|r
.target Totem of Coo
.turnin 9539 >> Сдать: Тотем гу
.accept 9540 >> Принять: Тотем Тикти

step
>> Спрыгните с обрыва или подождите, пока дух даст вам замедленное падение
.goto Azuremyst Isle,53.0,34.0
>> Лутайте маленькие синие цветы рядом со стволами деревьев
.complete 9473,1 >> Собрать: Луковица лазурного львиного зева (x5)

step
.goto Azuremyst Isle,64.4,39.8
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Тотемом Тикти|r
.target Totem of Tikti
.turnin 9540 >> Сдать: Тотем Тикти
.accept 9541 >> Принять: Тотем Йор
.timer 30,Swim Speed Buff RP
>> После сдачи квеста следуйте за духом фурболга и ждите, пока не получите бафф на скорость плавания, прежде чем заходить в воду

step
.waypoint Azuremyst Isle,61.0,54.2,-29,wptimer,UNIT_AURA
.waypoint Azuremyst Isle,61.0,54.2,-1
.waypoint Azuremyst Isle,63.39,40.37,-1
.goto Azuremyst Isle,61.0,54.2,0
>> Следуйте за духом фурболга и ждите баффа на скорость плавания, затем заходите в воду
.use 23654 >> Используйте рыболовную сеть на косяках рыбы. Если из воды выплывет мурлок, убегайте.
.complete 9452,1 >> Собрать: Красный луциан (x10)
>> Избегайте драк с мобами, иначе бафф скорости спадет

step
.goto Azuremyst Isle,61.0,54.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Диктинной|r
.target Diktynna
.turnin 9452 >> Сдать: Красный луциан – очень вкусно!
.accept 9453 >> Принять: Найти Актеона!

step
.goto Azuremyst Isle,63.2,68.0
>> Кликните на тотем под водой
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Тотемом Йор|r
.target Totem of Yor
.turnin 9541 >> Сдать: Тотем Йор
.accept 9542 >> Принять: Тотем Варк
.timer 71,Totem of Vark ghostsaber RP

step
>> Следуйте за духом фурболга, пока он не превратит вас в призрачного саблезуба
.waypoint Azuremyst Isle,28.1,62.5,-70,wptimer,UNIT_AURA
.goto Azuremyst Isle,28.1,62.5,0
.waypoint Azuremyst Isle,28.1,62.5,-1
.waypoint Azuremyst Isle,60.68,69.21,-1
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Тотемом Варк|r
.target Totem of Vark
.turnin 9542 >> Сдать: Тотем Варк
.accept 9544 >> Принять: Пророчество Акиды

step
#label azuremyst2
.goto Azuremyst Isle,27.3,63.9
>> Снимите с себя бафф призрачного саблезуба.
>> Убивайте фурболгов в этой зоне, с них падают ключи от клеток, которые вам нужны
.complete 9544,1 >> Пленник из Лесной Чащи освобожден (x8)

step
.goto Azuremyst Isle,28.6,70.0,100,0
.goto Azuremyst Isle,30.1,72.7
>> Добейте Задохликов и Лунных оленей-самцов
.complete 9456,1 >> Убить: Задохлик-инфекционер (x8)
.complete 10324,1 >> Собрать: Шкура лунного оленя-самца (x6)

step
#sticky
#completewith treesteptime
>> Фармите по пути
.collect 23759,1,9514 >> Собрать: Покрытая рунами табличка (x1)
.use 23759 >> Кликните по предмету в инвентаре, как только подберете его
.accept 9514 >> Принять: Покрытая рунами табличка

step
.goto Azuremyst Isle,31.4,79.3
>> Убивайте наг и лутайте светящиеся штуки на земле
.complete 9513,1 >> Убить: Мирмидон Чешуи Гнева (x5)
.complete 9513,2 >> Убить: Нага из Чешуи Гнева (x5)
.complete 9513,3 >> Убить: Сирена из Чешуи Гнева (x5)
.complete 9523,1 >> Собрать: Древняя реликвия (x8)

step
#label treesteptime
.goto Azuremyst Isle,18.4,84.1
.use 23792 >> Используйте маскировку под дерево у флага наг
>> После использования маскировки вы не сможете двигаться. Подождите около минуты, чтобы получить выполнение квеста.
.complete 9531,1
.cast 30298
.timer 82,Traitor Uncovered

step
.goto Azuremyst Isle,16.5,94.4
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Коуленом|r
.target Cowlen
.turnin 10428 >> Сдать: Пропавший рыбак
.accept 9527 >> Принять: Все, что осталось

step
.goto Azuremyst Isle,15.0,89.4
>> Убивайте Совухов (Owlbeasts)
.complete 9527,1 >> Собрать: Останки семьи Коулена (x1)

step
.goto Azuremyst Isle,16.5,94.3
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Коуленом|r
.target Cowlen
.turnin 9527 >> Сдать: Все, что осталось

step
#sticky
#completewith next
.deathskip >> Умрите и возродитесь у Лазурной Заставы

step
.goto Azuremyst Isle,47.0,70.3
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Жрицей Кайлин Иль'динар|r
.target Priestess Kyleen Il'dinare
.turnin 9513 >> Сдать: Отвоевание руин
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Археологом Адамантом Железным Сердцем|r
.target Archaeologist Adamant Ironheart
.turnin 9523 >> Сдать: Хрупкие и драгоценные вещи требуют особого обращения
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Адмиралом Одей|r
.target Admiral Odesyus
.turnin 9531 >> Сдать: В компании дерева
.accept 9537 >> Принять: Проявить милосердие
>> Не сдавайте "Покрытую рунами табличку" прямо сейчас, иначе начнется долгая RP-сценка

step
.goto Azuremyst Isle,47.0,70.3
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Жрицей Кайлин Иль'динар|r
.target Priestess Kyleen Il'dinare
.turnin 9514 >> Сдать: Покрытая рунами табличка

step  << Hunter
#sticky
.goto Azuremyst Isle,48.8,72.7
>> Убивайте крабов на побережье
.complete 9512,1 >> Собрать: Мясо скользящего краба (x6)

step
.goto Azuremyst Isle,50.2,70.6,40,0
.goto Azuremyst Isle,45.7,73.2,40,0
.goto Azuremyst Isle,50.2,70.6
>> Поговорите с инженером "Искрой" Пережиг, который патрулирует пляж на юго-востоке. Дождитесь его реплики и убейте его.
.complete 9537,1 >> Собрать: Послание предателя (x1)
.skipgossip 17243
.timer 18,Traitor's Communication RP
.unitscan Engineer "Spark" Overgrind

step  << Hunter
.goto Azuremyst Isle,46.7,70.5
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_"Пирожком" Слабосоусом|r
.target "Cookie" McWeaksauce
.turnin 9512 >> Сдать: Джамбо-гумбо от Пирожка

step
.goto Azuremyst Isle,47.036,70.212
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Адмиралом Одей|r
.target Admiral Odesyus
.turnin 9537 >> Сдать: Проявить милосердие
.accept 9602 >> Принять: Избавь их от зла...

step
.goto Azuremyst Isle,47.127,70.289
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Жрицей Кайлин Иль'динар|r
.target Priestess Kyleen Il'dinare
.accept 9515 >> Принять: Полководец Срисс'тиз
.maxlevel 9

step  << !Hunter
#completewith next
.goto Azuremyst Isle,27.0,76.7,60
>> Путь к Полководцу Срисс'тизу начинается здесь

step  << !Hunter
>> Зайдите в пещеру наг и убейте Полководца Срисс'тиза
.goto Azuremyst Isle,24.5,74.5
.complete 9515,1
.isOnQuest 9515

step
.goto Azuremyst Isle,49.9,51.9
.xp 9+3070 >> Фармите, пока не будет 3070+/6500 ед. опыта

step
#sticky
#completewith next
.deathskip >> Death skip или бегите обратно в Лазурную Заставу

step
.goto Azuremyst Isle,49.9,51.9
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Актеоном|r
.target Acteon
.turnin 9453 >> Сдать: Найти Актеона!
.turnin 10324 >> Сдать: Великая охота на лунного оленя

step
.goto Azuremyst Isle,49.5,51.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Аругу из Лесной Чащи|r
.target Arugoo of the Stillpine
.turnin 9544 >> Сдать: Пророчество Акиды
.accept 9559 >> Принять: Крепость Лесной Чащи

step
.goto Azuremyst Isle,48.5,51.5
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Дедалом|r
.target Daedal
.turnin 9473 >> Сдать: Альтернативная альтернатива

step
.goto Azuremyst Isle,47.2,50.7
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Экзархом Менелаем|r
.target Exarch Menelaous
.turnin 9456 >> Сдать: Великая охота на лунного оленя (часть 2)
.turnin 9602 >> Сдать: Избавь их от зла...
.accept 9623 >> Принять: Совершеннолетие  << Hunter

step
.goto Azuremyst Isle,47.2,50.7
.isOnQuest 9612
.goto Azuremyst Isle,47.2,50.7
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Экзархом Менелаем|r
.target Exarch Menelaous
.turnin 9612 >> Сдать: Сердечная благодарность!

step  << Shaman
.goto Azuremyst Isle,48.05,50.41
.trainer >> Выучить заклинания 10-го уровня

step  << Hunter
.goto Azuremyst Isle,49.780,51.938
.trainer >> Выучить заклинания 10-го уровня

step  << Priest
.goto Azuremyst Isle,48.6,49.4
.trainer >> Выучить заклинания 10-го уровня

step  << Paladin
.goto Azuremyst Isle,48.4,49.5
.trainer >> Выучить заклинания 10-го уровня

step  << Mage
.goto Azuremyst Isle,49.9,50.0
.trainer >> Выучить заклинания 10-го уровня

step  << Warrior
.goto Azuremyst Isle,50.023,50.515
.trainer >> Выучить заклинания 10-го уровня
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Руадой|r
.target Ruada
.accept 9582 >> Принять: Сила одного

step  << Shaman
.goto Azuremyst Isle,48.05,50.41
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Тулууном|r
.target Tuluun
.accept 9464 >> Принять: Зов Огня

step  << Hunter
.goto Azuremyst Isle,49.7,51.9
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Торгасом Гримсоном|r
.target Thorgas Grimson
.accept 9757 >> Принять: Найди охотницу Келлу Ночную Дугу

step  << Hunter
.goto Azuremyst Isle,24.182,54.346
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Охотницей Келлой Ночной Дугой|r
.target Huntress Kella Nightbow
.turnin 9757 >> Сдать: Найди охотницу Келлу Ночную Дугу
.accept 9591 >> Принять: Укрощение зверя

step  << Hunter
.goto Azuremyst Isle,20.7,65.1
.use 23896 >> Используйте жезл на Шипастого ползуна. Они появляются дальше по побережью, не перепутайте их со Скользящими крабами.
.complete 9591,1 >> Приручить: Шипастый ползун
.unitscan Barbed Crawler 

step  << Hunter
#completewith next
.goto Azuremyst Isle,27.0,76.7,60
>> Путь к Полководцу Срисс'тизу начинается здесь

step  << Hunter
>> Зайдите в пещеру наг и убейте Полководца Срисс'тиза
.goto Azuremyst Isle,25.3,73.1,80,0
.goto Azuremyst Isle,25.9,71.2,60,0
.goto Azuremyst Isle,27.5,73.8,60,0
.goto Azuremyst Isle,24.5,74.5
.complete 9515,1
.isOnQuest 9515

step  << Hunter
.goto Azuremyst Isle,24.182,54.346
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Охотницей Келлой Ночной Дугой|r
.target Huntress Kella Nightbow
.turnin 9591 >> Сдать: Укрощение зверя
.accept 9592 >> Принять: Укрощение зверя

step  << Hunter
.goto The Exodar,81.480,51.428
.turnin 9623 >> Сдать: Совершеннолетие
.accept 9625 >> Принять: Элеки — это серьезно

step  << Hunter
.goto Azuremyst Isle,35.4,35.0,80,0
.goto Azuremyst Isle,39.0,31.2
.use 23897 >> Используйте жезл на Большого древотопыра
.complete 9592,1 >> Приручить: Большой древотопыр

step  << Hunter
.goto Azuremyst Isle,24.182,54.346
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Охотницей Келлой Ночной Дугой|r
.target Huntress Kella Nightbow
.turnin 9592 >> Сдать: Укрощение зверя
.accept 9593 >> Принять: Укрощение зверя

step  << Hunter
.goto Azuremyst Isle,35.0,33.9
.use 23898 >> Используйте жезл на Задохлика
.complete 9593,1 >> Приручить: Задохлик

step  << Hunter
.goto Azuremyst Isle,24.182,54.346
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Охотницей Келлой Ночной Дугой|r
.target Huntress Kella Nightbow
.turnin 9593 >> Сдать: Укрощение зверя
.accept 9675 >> Принять: Обучение питомца

step  << Hunter
#completewith next
.goto Azuremyst Isle,24.6,49.0,35
>> Зайдите в Экзодар через черный ход

step  << Hunter
.goto The Exodar,42.0,71.4,60,0
.goto The Exodar,44.6,72.0,60,0
.goto The Exodar,44.1,86.6
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Ганааром|r
.target Ganaar
.turnin 9675 >> Сдать: Обучение питомца
.trainer >> Выучить заклинания питомца

step  << Hunter
#completewith next
.goto The Exodar,47.9,89.
>> Удалите старые стрелы. Обязательно наденьте новые, которые купите.
.vendor >> Купите 6 стопок Острых стрел

step  << Hunter
#sticky
#completewith next
>> Поговорите с мастером оружия наверху
.goto The Exodar,51.1,80.5,40,0
.goto The Exodar,53.3,85.7
.train 202 >> Выучить: Двуручные мечи

step  << Hunter
#completewith murloc1
>> Спрыгните вниз и выходите из Экзодара
.goto The Exodar,57.9,61.5,50,0
.goto The Exodar,53.0,35.0,80,0
.goto The Exodar,64.0,36.5,60,0
.goto Azuremyst Isle,44.7,23.5
.zone Azuremyst Isle >> Спрыгните вниз и выходите из Экзодара
>> В качестве альтернативы вы можете сделать logout skip на любом жаровне или спрыгнув с любого уступа в городе
.link https://www.youtube.com/watch?v=WUWNGyQWJw8 >> Нажмите здесь для примера

step  << Hunter wotlk
#sticky
#label pet1
.cast 1515 >> По пути к следующему квестовому хабу, используйте Приручение зверя на кота 8+ уровня

step
#label murloc1
.goto Azuremyst Isle,44.7,23.5
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Гурфом|r
.target Gurf
.accept 9562 >> Принять: Мурлоки... Почему здесь? Почему сейчас?

step
.goto Azuremyst Isle,44.8,23.8
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Моордо|r
.target Moordo
.accept 9560 >> Принять: Звери Апокалипсиса!

step
.goto Azuremyst Isle,46.6,20.7
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Верховным вождем Лесной Чащи|r
.target High Chief Stillpine
.turnin 9559 >> Сдать: Крепость Лесной Чащи

step  << Shaman
#sticky
#completewith next
>> Убивайте Опустошителей
.complete 9560,1 >> Собрать: Шкура опустошителя (x8)

step  << Shaman
.goto Azuremyst Isle,59.6,18.0
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Темпером|r
.target Temper
.turnin 9464 >> Сдать: Зов Огня
.accept 9465 >> Принять: Зов Огня

step  << Hunter
#sticky
#label pet1
.goto Azuremyst Isle,54.7,18.4
.cast 1515 >> Используйте Приручение зверя на Образце опустошителя, чтобы приручить его

step
.goto Azuremyst Isle,54.7,18.4
>> Убивайте Опустошителей. Лутайте их шкуры
.complete 9560,1 >> Собрать: Шкура опустошителя (x8)

step  << Warrior
.goto Azuremyst Isle,54.1,9.8
>> Кликните на клетку с Опустошителем
.complete 9582,1 >> Убить: Смертоносный опустошитель (x1)

step
#requires pet1  << Hunter
.goto Azuremyst Isle,44.8,23.8
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Моордо|r
.target Moordo
.turnin 9560 >> Сдать: Звери Апокалипсиса!

step
.goto Azuremyst Isle,46.8,21.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Лесной Чащей Младшим|r
.target Stillpine the Younger
.accept 9573 >> Принять: Вождь Умору

step
.goto Azuremyst Isle,46.6,20.6
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Верховным вождем Лесной Чащи|r
.target High Chief Stillpine
.accept 9565 >> Принять: Обыскать крепость Лесной Чащи

step
>> Начните зачистку в глубь пещеры. Держитесь на верхних уровнях.
.goto Azuremyst Isle,47.4,14.0
.complete 9573,1 >> Убить: Вождь Умору (x1)
.complete 9573,2 >> Убить: Безумный дикий совух (x9)

step  << Shaman
.goto Azuremyst Isle,46.1,16.8
>> Продолжайте убивать совухов
.complete 9465,1 >> Собрать: Ритуальный факел (x1)

step
.goto Azuremyst Isle,50.6,11.6
>> Спрыгните вниз и идите в заднюю часть пещеры.
.turnin 9565 >> Сдать: Обыскать крепость Лесной Чащи
.accept 9566 >> Принять: Кровавые кристаллы
>> Когда вы приблизитесь к красному кристаллу, рядом вы можете увидеть двухголового пса по имени "Куркен". НЕ УБИВАЙТЕ ЕГО, этот моб нужен для следующего квеста

step
.goto Azuremyst Isle,46.7,20.8
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Верховным вождем Лесной Чащи|r
.target High Chief Stillpine
.turnin 9566 >> Сдать: Кровавые кристаллы

step
.goto Azuremyst Isle,47.0,22.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Курцем Провидцем|r
.target Kurz the Revelator
.accept 9570 >> Принять: Куркен крадется

step
#completewith next
.goto Azuremyst Isle,46.9,22.0
.vendor >> Продайте хлам, починитесь. Купите 6-слотовые сумки, если нужно.

step
.goto Azuremyst Isle,46.8,21.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Лесной Чащей Младшим|r
.target Stillpine the Younger
.turnin 9573 >> Сдать: Вождь Умору

step
.goto Azuremyst Isle,49.9,12.8
>> Убейте Куркена
.complete 9570,1 >> Собрать: Шкура Куркена (x1)

step
.goto Azuremyst Isle,47.0,22.2
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Курцем Провидцем|r
.target Kurz the Revelator
.turnin 9570 >> Сдать: Куркен крадется
.accept 9571 >> Принять: Шкура Куркена

step  << Shaman
.goto Azuremyst Isle,46.7,20.8
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Верховным вождем Лесной Чащи|r
.target High Chief Stillpine
.accept 9622 >> Принять: Предупреди свой народ

step
#label end
.goto Azuremyst Isle,44.8,23.8
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Моордо|r
.target Moordo
.turnin 9571 >> Сдать: Шкура Куркена

step  << Shaman
.goto Azuremyst Isle,59.6,17.9
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Темпером|r
.target Temper
.turnin 9465 >> Сдать: Зов Огня
.accept 9467 >> Принять: Зов Огня

step  << Shaman
.hs >> Используйте камень возвращения в Лазурную Заставу

step  << Shaman
.goto Azuremyst Isle,47.112,50.604
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Экзархом Менелаем|r
.target Exarch Menelaous
.turnin 9622 >> Сдать: Предупреди свой народ

step  << Shaman
#sticky
#completewith next
>> Кликните по Огнеупорному мешку в ваших сумках
.complete 9467,2 >> Собрать: Ритуальный факел (x1)

step  << Shaman
.goto Azuremyst Isle,11.3,82.3
>> Кликните по плетеному человеку, чтобы призвать Высотера
.complete 9467,1 >> Собрать: Пепел Высотера (x1)

step  << Shaman
.goto Azuremyst Isle,59.5,18.0
.use 24335 >> Используйте сферу в сумке, чтобы телепортироваться обратно в Угодья тлеющих углей
>>|Tinterface/worldmap/chatbubble_64grey.blp:20|tПоговорите с |cRXP_FRIENDLY_Темпером|r
.target Temper
.turnin 9467 >> Сдать: Зов Огня
.accept 9468 >> Принять: Зов Огня

step
#sticky
#label SGrain
.goto Azuremyst Isle,34.1,18.0,0,0
>> Убивайте мурлоков в этой зоне. Лутайте их Зерно
.complete 9562,1 >> Собрать: Зерно Лесной Чащи (x5)

step
.goto Azuremyst Isle,34.0,25.9,70,0
.goto Azuremyst Isle,34.9,12.0,60,0
.goto Azuremyst Isle,34.0,25.9
>> Убейте и лутайте Мургургулу. Он патрулирует побережье. Будьте осторожны, он наносит ОЧЕНЬ много урона
.unitscan Murgurgula
.use 23850 >> Лутните и кликните по "Достоинству Гурфа" в инвентаре
.collect 23850,1,9564 >> Достоинство Гурфа (1)
.accept 9564 >> Принять: Достоинство Гурфа

step
#requires SGrain
.goto Bloodmyst Isle,63.5,88.8
.zone Bloodmyst Isle >> Отправляйтесь на Остров Кровавой Дымки
]])