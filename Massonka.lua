script_author("MrKapon") -- автор скрипта

require 'lib.moonloader' -- подключение библиотеки
require 'lib.sampfuncs'
local dlstatus = require('moonloader').download_status
local sampev = require 'lib.samp.events'
local vkeys = require('vkeys')
local inicfg = require 'inicfg'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

update_state = false

local script_vers = 1
local script_vers_text = "1.00"

local update_url = "https://raw.githubusercontent.com/MrKapon/massonka/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "https://raw.githubusercontent.com/MrKapon/massonka/main/Massonka.lua" -- тут свою ссылку
local script_path = thisScript().path

local directIni = "massonka.ini"
local cfg = inicfg.load(nil, directIni)

local second = false
local sos = false
local sopr = false
local coords = 
{
{137.2251,1931.3904,19.1907, 'КПП'}, --координата и название
{137.7825,1834.8387,17.6036, 'Ангар №1'},
{343.0120,1798.5864,18.2653, 'С-КПП'},
{345.2440,1926.4535,17.6283, 'Главный Склад'},
{280.2822,1990.3723,17.6071, 'Ангар №3'}
}
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end -- проверка загрузки сампа и сампфункса
    while not isSampAvailable() do wait(100) end -- проверка активности сампа
	sampAddChatMessage("Автор скрипта {ADD8E6}MrKapon", 0x00339933)
	sampAddChatMessage("По всем вопросам обращаться в дискорд: {ADD8E6}mrkapon", 0x00339933)
	sampAddChatMessage("Вступайте в группу нашей семьи {ADD8E6}https://vk.com/massonka_family", 0x00339933)
	
	sampRegisterChatCommand("r",cmd_r)	
	sampRegisterChatCommand(cfg.commands.mmask,cmd_mmask)

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED) -- определить свой ид
	nick = sampGetPlayerNickname(id) -- определить свой ник по иду
	
	downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("Есть обновление! Версия: " .. updateIni.info.vers_text, -1)
                update_state = true
            end
           os.remove(update_path)
        end
    end)
	
	while true do
	wait(0)
	
		if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Скрипт успешно обновлен!", -1)
                    thisScript():reload()
                end
            end)
            break
        end

if isKeyJustPressed(vkeys[cfg.key.lock]) and not sampIsChatInputActive() then 
	sampSendChat("/lock") 
end

if isKeyJustPressed(vkeys[cfg.key.no]) and not sampIsChatInputActive() then
	sampSendChat('/r '..cfg.config.tag..' 10-6. Ожидайте!')
end
if isKeyJustPressed(vkeys[cfg.key.yes]) and not sampIsChatInputActive() then
if sopr == true then
sampSendChat('/r '..cfg.config.tag..' Принято. Выезжайте.')
sopr = false
elseif sos == true then
sampSendChat('/r '..cfg.config.tag..' Принято. Ожидайте помощи!')
sos = false
end
end
if isKeyJustPressed(vkeys[cfg.key.megafon]) and not sampIsChatInputActive() then
if not second then
sampSendChat("/m Вы находитесь на закрытой территории военной базы! У вас есть 15 секунд, чтобы покинуть ее")
second = true
else
sampSendChat("/m За последующее пересечение территории будет открыт огонь без предупреждений!")
second = false
end
end
if isKeyJustPressed(vkeys[cfg.key.sos]) and not sampIsChatInputActive() then
		local name, dist = GetNearestCoord(coords)
		if isCharInArea2d(PLAYER_PED,412.9650,2168.4063,-41.8824,1699.8453) then
			sampSendChat('/r '..cfg.config.tag..' SOS! Совершено нападение на военнослужающего. Сектор:  '..name)
		else
			sampSendChat('/r '..cfg.config.tag..' SOS! Требуется поддержка в квадрат '..kvadrat())
		end
end
local result, target = getCharPlayerIsTargeting(playerHandle) 
 	if result then result, playerid = sampGetPlayerIdByCharHandle(target) end -- Если зажата пкм на игроке, то получаем ID.
      		if result and isKeyJustPressed(vkeys[cfg.key.tie]) then -- Если нажата пкм и кнопка 1 на игроке, то...
        sampSendChat("/tie "..playerid.."") -- Результат
	end
		end
end

function cmd_r(arg)
	if arg ~= '' then
	sampSendChat('/r '..cfg.config.tag..' '..arg)
	end
end
function cmd_mmask()
	thread = lua_thread.create(function()
	sampSendChat('/do '..nick..' одет в военную форму Crye Precision G3 Combat в камуфляже Multicam')
	wait(1100)
	sampSendChat('/do Торс закрыт тактическим облегченным бронежилетом AVS уровня защиты III-A с нашивкой [O(I) | Rh+]')
	wait(1100)
	sampSendChat('/do На разгрузке '..cfg.config.knife..' и бодикамера в кейсе Kagwerks, опознавательные знаки отсутствуют')
	wait(1100)
	sampSendChat('/do Лицо скрыто балаклавой, на голове шлем FAST 3.0 с прибором GPNVG-18 и активными наушниками EARMOR M32X')
	end)
end
function sampev.onServerMessage(color, text)
	lua_thread.create(function()
		print(color,text)
		local myskin = getCharModel(PLAYER_PED)
		if text:find('Рабочий день начат') and color == 1687547391 then
		wait(1500)
		sampSendChat('/clist '..cfg.config.clist)
		sampAddChatMessage("Вы надели "..cfg.config.clist.." клист", 0x00FFFFFF)	
		end
		if text:find('Вы сняли с себя маску') and color == -1263159297 then
		wait(1500)
		sampSendChat('/clist '..cfg.config.clist)
		sampAddChatMessage("Вы надели "..cfg.config.clist.." клист", 0x00FFFFFF)	
		end
		if text:find('SOS') or text:find('СОС') or text:find('Запрашиваю поддержку') or text:find('Совершенно проникновение') or text:find('запрашиваю помощь в сектор') or text:find('угнана фура снабжения сектор')  or text:find('Нахожусь под активным огнем противника') then 
		if color == -1920073984 then
		wait(200)
		sampAddChatMessage('{FF0000}Подан сигнал поддержки! {FFFF33}"F12"{FFFFFF} Принять!',0xFF0000)
		sos = true
		end
		end 
		if text:find('сопровождение на РФК') or text:find('Ожидаю сопровод') or text:find('Ожидаю сопровождение') or text:find('сопровождение у РФК') then
		if color == -1920073984 then
		wait(200)
		sampAddChatMessage('{FF0000}Загрузилась фура снабжения! {FFFF33}"F12"{FFFFFF} Подтвердить выезд | {FFFF33}"F11"{FFFFFF} Отказать',0xFF0000)
		sopr = true
		end 
		end
	end)
end
function sampev.onSendSpawn()
	lua_thread.create(function()
		local myskin = getCharModel(PLAYER_PED)
		if myskin == 287 or myskin == 191 or myskin == 179 or myskin == 61 or myskin == 255 or myskin == 73 then
		wait(1500)
		sampSendChat('/clist '..cfg.config.clist)
		sampAddChatMessage("Вы надели "..cfg.config.clist.." клист", 0x00FFFFFF)	
		else
		wait(5000)
		sampSendChat("/clist 7")
		sampAddChatMessage("Вы надели 7 клист", 0x00FFFFFF)
		end
	end)
end
function GetNearestCoord(Array)
    local x, y, z = getCharCoordinates(playerPed)
    local distance = {}
    for k, v in pairs(Array) do
        distance[k] = {distance = math.floor(getDistanceBetweenCoords3d(v[1], v[2], v[3], x, y, z)), name = v[4]}
    end
    table.sort(distance, function(a, b) return a.distance < b.distance end)
    for k, v in pairs(distance) do
        CoordName, CoordDist = v.name, v.distance
        break
    end
    return CoordName, CoordDist
end
function kvadrat()
    local KV = {
        [1] = "А",
        [2] = "Б",
        [3] = "В",
        [4] = "Г",
        [5] = "Д",
        [6] = "Ж",
        [7] = "З",
        [8] = "И",
        [9] = "К",
        [10] = "Л",
        [11] = "М",
        [12] = "Н",
        [13] = "О",
        [14] = "П",
        [15] = "Р",
        [16] = "С",
        [17] = "Т",
        [18] = "У",
        [19] = "Ф",
        [20] = "Х",
        [21] = "Ц",
        [22] = "Ч",
        [23] = "Ш",
        [24] = "Я",
    }
    local X, Y, Z = getCharCoordinates(playerPed)
    X = math.ceil((X + 3000) / 250)
    Y = math.ceil((Y * - 1 + 3000) / 250)
    Y = KV[Y]
    local KVX = (Y.."-"..X)
    return KVX
end