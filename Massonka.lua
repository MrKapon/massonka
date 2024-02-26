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
--Работа с автообновлением--
local script_vers = 5
local script_vers_text = "1.5"

local update_url = "https://raw.githubusercontent.com/MrKapon/massonka/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "https://raw.githubusercontent.com/MrKapon/massonka/main/Massonka.lua?raw=true" -- тут свою ссылку
local script_path = thisScript().path
--Создание cfg.ini файла--
local cfg = inicfg.load({
    config = 
	{
        knife = 'томагавк Hogue EX-T01',
        tag = '[СОБР]',
        clist = '23',
        resus = '[O(I) | Rh+]',
    },
	key = {
		lock = 'VK_L',
		megafon = 'VK_M',
		sos = 'VK_Z',
		accept = 'VK_F12',
		kv = 'VK_F11',
		tie = 'VK_1',
	},
	commands = 
	{
		mmask = 'mmask',
		monikr = 'rgetm',
		moniks = 'getm',
		fmask = 'fmask',
	},
}, "massonka.ini")
inicfg.save(cfg, "massonka.ini")

local second = false
local sos = false
local sopr = false
local datchik = false
local monikQuant = {}
local monikQuantNum = {}
local fmask = false
local find = false
local models = {19036, 19037, 19038, 18911, 18912, 18913, 18914, 18915, 18916, 18917, 18918, 18919, 18920, 11704, 18920, 11704}

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end -- проверка загрузки сампа и сампфункса
    while not isSampAvailable() do wait(100) end -- проверка активности сампа
	sampAddChatMessage("Автор скрипта {ADD8E6}MrKapon", 0x00339933)
	sampAddChatMessage("По всем вопросам обращаться в дискорд: {ADD8E6}mrkapon", 0x00339933)
	sampAddChatMessage("Вступайте в группу нашей семьи {ADD8E6}https://vk.com/massonka_family", 0x00339933)
	
	sampRegisterChatCommand("r",cmd_r)	
	sampRegisterChatCommand(cfg.commands.mmask,cmd_mmask)
	sampRegisterChatCommand(cfg.commands.monikr, function() rgetm() end)
	sampRegisterChatCommand(cfg.commands.moniks, function() getm() end)
	sampRegisterChatCommand(cfg.commands.fmask, fastMask)

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED) -- определить свой ид
	nick = sampGetPlayerNickname(id) -- определить свой ник по иду
	--Проверка обновления скрипта--
	downloadUrlToFile(update_url, update_path, function(id, status)
		thread = lua_thread.create(function()
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				while not sampIsLocalPlayerSpawned() do wait(0) end
				updateIni = inicfg.load(nil, update_path)
					if tonumber(updateIni.info.vers) > script_vers then
						sampAddChatMessage("Есть обновление! Версия: {ADD8E6}" .. updateIni.info.vers_text, 0x00339933)
						update_state = true
					end
				os.remove(update_path)
			end
		end)
    end)
	
	while true do
	wait(0)
	--Обновление скрипта--
        if update_state then
                downloadUrlToFile(script_url, script_path, function(id, status)
                    if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                        sampAddChatMessage("Скрипт успешно обновлен!", 0x00339933)
                    end
                end)
                break
        end
        
if isKeyJustPressed(vkeys[cfg.key.lock]) and not sampIsChatInputActive() then 
	sampSendChat("/lock") 
end

if isKeyJustPressed(vkeys[cfg.key.yes]) and not sampIsChatInputActive() then
	if sopr == true then
		sampSendChat('/r '..cfg.config.tag..' Принято. Выезжайте.')
		sopr = false
	elseif sos == true then
		sampSendChat('/r '..cfg.config.tag..' Принято. Ожидайте помощи!')
		sos = false
	else
		sampSendChat(sfind)
		datchik = false
	end
end

if isKeyJustPressed(vkeys[cfg.key.megafon]) and not sampIsChatInputActive() then
	if not second and isCharInArea2d(PLAYER_PED,558.6176,2281.1479,-124.5053,1572.4241) then
		sampSendChat("/m Вы находитесь на закрытой территории военной базы! У вас есть 15 секунд, чтобы покинуть ее")
		second = true
	elseif second == false then
		sampSendChat('/m Любая помеха движению конвоя расценивается как нападение')
	else
		sampSendChat("/m За последующее пересечение территории будет открыт огонь без предупреждений!")
		second = false
	end
end

if isKeyJustPressed(vkeys[cfg.key.sos]) and not sampIsChatInputActive() then
	sampSendChat('/r '..cfg.config.tag..' SOS! Требуется поддержка в квадрат '..kvadrats())
end

local result, target = getCharPlayerIsTargeting(playerHandle) 
	if result then 
		result, playerid = sampGetPlayerIdByCharHandle(target) 
	end
	if result and isKeyJustPressed(vkeys[cfg.key.tie]) then
		sampSendChat('/tie ' ..playerid)
	end

if isKeyJustPressed(vkeys[cfg.key.kv]) and not sampIsChatInputActive() then
	if coordX ~= nil and coordY ~= nil then
		cX, cY, cZ = getCharCoordinates(playerPed)
		cX = math.ceil(cX)
		cY = math.ceil(cY)
		cZ = math.ceil(cZ)
              
              placeWaypoint(coordX, coordY,0)
              --removeBlip(h)
              --h = addSpriteBlipForCoord(coordX, coordY, 0, 56)
      
              sampAddChatMessage('Установлена метка на {ADD8E6}'..kvadY..'-'..kvadX.. '.{FF0000} Дистанция: {ADD8E6}'..math.ceil(getDistanceBetweenCoords2d(coordX, coordY, cX, cY))..' м.', 0x00FF0000)        
              if kvadrat(kvadY) == 11 and tonumber(kvadX) == 15 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Мост по Дэфолт', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 7 and tonumber(kvadX) == 12 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}НЛО', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 8 and tonumber(kvadX) == 12 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Форт Карсон', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 8 and tonumber(kvadX) == 11 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}ФК', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 9 and tonumber(kvadX) == 7 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}мост СФ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 11 and tonumber(kvadX) == 6 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}СФа заправка', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 10 and tonumber(kvadX) == 6 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}СФПД', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 7 and tonumber(kvadX) == 14 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Нефть', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 8 and tonumber(kvadX) == 13 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Клак', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 9 and tonumber(kvadX) == 14 then
                  sampAddChatMessage('[Локация найдена]:{FF0000} Карьер', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 12 and tonumber(kvadX) == 15 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Яма', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 13 and tonumber(kvadX) == 15 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дорога в лспд после ямы', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 13 and tonumber(kvadX) == 16 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дорога в лспд после ямы', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 13 and tonumber(kvadX) == 17 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дорога в лспд после ямы', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 14 and tonumber(kvadX) == 17 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дорога в ЛСПД перед городом', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 14 and tonumber(kvadX) == 18 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дорога в ЛСПД перед городом', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 15 and tonumber(kvadX) == 18 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Вайнвуд', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 19 and tonumber(kvadX) == 14 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}МО ЛС', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 2 and tonumber(kvadX) == 14 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Заброшка ЛВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 2 and tonumber(kvadX) == 13 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Заброшка ЛВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 12 and tonumber(kvadX) == 2 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}АММО СФ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 11 and tonumber(kvadX) == 3 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}ФБР', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 6 and tonumber(kvadX) == 14 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Гора КПП-2', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 7 and tonumber(kvadX) == 15 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}ЧСВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 8 and tonumber(kvadX) == 16 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}ЧСВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 16 and tonumber(kvadX) == 19 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Конец ЛС-ЛВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 15 and tonumber(kvadX) == 17 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Вайнвуд', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 17 and tonumber(kvadX) == 17 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}ЛС ЛСПД', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 19 and tonumber(kvadX) == 19 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}ЛСПД', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 15 and tonumber(kvadX) == 18 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Вайнвуд', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 11 and tonumber(kvadX) == 19 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Мост ЛС-ЛВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 7 and tonumber(kvadX) == 11 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Монголы', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 14 and tonumber(kvadX) == 19 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Мост ЛС-ЛВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 15 and tonumber(kvadX) == 19 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Мост ЛС-ЛВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 18 and tonumber(kvadX) == 19 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Мост ЛС-ЛВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 2 and tonumber(kvadX) == 12 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Пагансы', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 16 and tonumber(kvadX) == 24 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Шоссе вагос', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 18 and tonumber(kvadX) == 18 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Аммо ЛС', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 9 and tonumber(kvadX) == 20 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Перекрёсток ЛВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 2 and tonumber(kvadX) == 7 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Треньки от Кушнаря', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 19 and tonumber(kvadX) == 24 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Нахуя оно тебе надо', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 9 and tonumber(kvadX) == 19 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Около перекрёсток ЛВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 7 and tonumber(kvadX) == 24 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}ЖД ЛВ перехват', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 9 and tonumber(kvadX) == 24 then
                  sampAddChatMessage('[Локация найденаd]: {FF0000}Перехват ЖД', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 20 and tonumber(kvadX) == 19 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Конец ЛС-ЛВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 3 and tonumber(kvadX) == 22 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}ЛВПД', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 12 and tonumber(kvadX) == 16 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Маршрут по дефолту до моста', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 12 and tonumber(kvadX) == 17 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Маршрут по дефолту до моста', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 12 and tonumber(kvadX) == 18 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Маршрут по дефолту до моста', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 12 and tonumber(kvadX) == 19 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Центр ЛВ-ЛС моста', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 12 and tonumber(kvadX) == 24 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Поворот на вагос перехват', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 13 and tonumber(kvadX) == 23 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дорога вагос', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 13 and tonumber(kvadX) == 24 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дорога вагос', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 14 and tonumber(kvadX) == 23 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дорога вагос', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 14 and tonumber(kvadX) == 24 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дорога вагос', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 15 and tonumber(kvadX) == 15 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Монголс', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 6 and tonumber(kvadX) == 15 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Варлоки', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 1 and tonumber(kvadX) == 18 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Яки', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 1 and tonumber(kvadX) == 19 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Яки', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 4 and tonumber(kvadX) == 10 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дамба', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 4 and tonumber(kvadX) == 9 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дамба', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 4 and tonumber(kvadX) == 11 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Возле дамбы', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 4 and tonumber(kvadX) == 13 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}ПВО Дельты', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 4 and tonumber(kvadX) == 14 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Гидры - ПВО ВП', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 5 and tonumber(kvadX) == 13 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Часть', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 5 and tonumber(kvadX) == 14 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}А-2 - ТГС', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 8 and tonumber(kvadX) == 11 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Рельсы ФК', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 5 and tonumber(kvadX) == 15 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Гора ТГС', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 15 and tonumber(kvadX) == 24 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дерево Вагос', 0x00ADD8E6)   
              end
              if kvadrat(kvadY) == 8 and tonumber(kvadX) == 10 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}После моста ФК', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 6 and tonumber(kvadX) == 16 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}РМ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 18 and tonumber(kvadX) == 19 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}АММО ЛС', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 19 and tonumber(kvadX) == 13 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Перекатка фермы', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 11 and tonumber(kvadX) == 12 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Мост фермы', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 12 and tonumber(kvadX) == 12 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}С моста фермы на Дэфолт', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 9 and tonumber(kvadX) == 21 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}АММО ЛВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 7 and tonumber(kvadX) == 13 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Задняя часть нефти', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 21 and tonumber(kvadX) == 19 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Перехват азтек', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 11 and tonumber(kvadX) == 24 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Рельсы вагос', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 3 and tonumber(kvadX) == 13 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Аэро заброшка', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 3 and tonumber(kvadX) == 14 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Аэро заброшка', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 7 and tonumber(kvadX) == 9 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Пусть в СФПД около моста СФ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 22 and tonumber(kvadX) == 23 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Порт ЛС', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 22 and tonumber(kvadX) == 24 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Порт ЛС', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 23 and tonumber(kvadX) == 23 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Порт ЛС', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 23 and tonumber(kvadX) == 24 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Порт ЛС', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 20 and tonumber(kvadX) == 17 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дорога перехват в азтек (где не проехать фуре)', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 20 and tonumber(kvadX) == 16 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дорога перехват в азтек (где не проехать фуре)', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 4 and tonumber(kvadX) == 20 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дорогатек (где не проехать фуре)', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 8 and tonumber(kvadX) == 9 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Начало моста СФ-ЛВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 11 and tonumber(kvadX) == 5 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Конец моста СФ-ЛВ', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 10 and tonumber(kvadX) == 18 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}ЛКН', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 15 and tonumber(kvadX) == 16 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Диллимор', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 12 and tonumber(kvadX) == 11 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Перекресток у фермы [LSPD]', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 12 and tonumber(kvadX) == 13 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}После фермы [LSPD]', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 13 and tonumber(kvadX) == 11 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Ферма/Завод [LSPD]', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 13 and tonumber(kvadX) == 12 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Ферма/Завод [LSPD]', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 13 and tonumber(kvadX) == 13 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Выезд после завода [LSPD]', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 14 and tonumber(kvadX) == 13 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Маршрут [LSPD]', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 14 and tonumber(kvadX) == 14 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Маршрут [LSPD]', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 15 and tonumber(kvadX) == 14 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Диллимор [LSPD]', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 16 and tonumber(kvadX) == 15 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Диллимор [LSPD]', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 16 and tonumber(kvadX) == 16 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Подъем в Диллиморе [LSPD]', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 17 and tonumber(kvadX) == 16 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Въезд в ЛС через Диллимор [LSPD]', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 17 and tonumber(kvadX) == 18 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}Дорога после больки [LSPD]', 0x00ADD8E6)
              end
              if kvadrat(kvadY) == 11 and tonumber(kvadX) == 6 then
                  sampAddChatMessage('[Локация найдена]: {FF0000}СФа', 0x00ADD8E6)
			  end
			end
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
        sampSendChat('/do ' .. nick .. ' одет в военную форму Crye Precision G3 Combat в камуфляже Multicam')
        wait(1100)
        sampSendChat('/do Торс закрыт тактическим облегченным бронежилетом AVS уровня защиты III-A с нашивкой ' .. cfg.config.resus)
        wait(1100)
        sampSendChat('/do На разгрузке ' .. cfg.config.knife .. ' и бодикамера в кейсе Kagwerks, опознавательные знаки отсутствуют')
        wait(1100)
        sampSendChat('/do Лицо скрыто балаклавой, на голове шлем FAST 3.0 с прибором GPNVG-18 и активными наушниками EARMOR M32X')
    end)
end

function rgetm()
  local x,y,z = getCharCoordinates(PLAYER_PED)
  local result, text = Search3Dtext(x,y,z, 700, "Склад")
  local temp = split(text, "\n")
  sampAddChatMessage("============= Мониторинг ============", 0xFFFFFF)
  for k, val in pairs(temp) do monikQuant[k] = val end
  if monikQuant[6] ~= nil then
    for i = 1, table.getn(monikQuant) do
      number1, number2, monikQuantNum[i] = string.match(monikQuant[i],"(%d+)[^%d]+(%d+)[^%d]+(%d+)")
      monikQuantNum[i] = monikQuantNum[i]/1000
    end
    sampSendChat("/r Мониторинг: [LSPD - "..monikQuantNum[1].." | SFPD - "..monikQuantNum[2].." | LVPD - "..monikQuantNum[3].." | SFa - "..monikQuantNum[4].." | FBI - "..monikQuantNum[6].."]")
  end
end

function getm()
	local x,y,z = getCharCoordinates(PLAYER_PED)
	local result, text = Search3Dtext(x,y,z, 1000, "FBI")
	local temp = split(text, "\n")
	sampAddChatMessage("=============[Мониторинг]============", 0xFFFFFF)
	for k, val in pairs(temp) do sampAddChatMessage(val, 0xFFFFFF) end
	sampAddChatMessage("=============[Мониторинг]============", 0xFFFFFF)
end

function fastMask()
	fmask = true
	find = false
	sampSendChat('/items')
end

function sampev.onServerMessage(color, text)
    lua_thread.create(function()      
        if text:find('Рабочий день начат') and color == 1687547391 then
            wait(1500)
            sampSendChat('/clist ' .. cfg.config.clist)
            sampAddChatMessage("Вы надели " .. cfg.config.clist .. " клист", 0x00FFFFFF)
        end        
        if text:find('Вы сняли с себя маску') and color == -1263159297 then
            wait(1500)
            sampSendChat('/clist ' .. cfg.config.clist)
            sampAddChatMessage("Вы надели " .. cfg.config.clist .. " клист", 0x00FFFFFF)
        end
        if text:find('SOS') or text:find('СОС') or text:find('Запрашиваю поддержку') or text:find('Совершенно проникновение') or text:find('запрашиваю помощь в сектор') or text:find('угнана фура снабжения сектор') or text:find('Нахожусь под активным огнем противника') or text:find('Требуется огневая поддержка') then
            if color == -1920073984 then
                wait(200)
                sampAddChatMessage('{FF0000}Подан сигнал поддержки! {FFFF33}"' .. cfg.key.yes:gsub("VK_", "") .. '"{FFFFFF} Принять!', 0xFF0000)
                sos = true
                sopr = false
				datchik = false
            end
        end
        if text:find('сопровождение на РФК') or text:find('Ожидаю сопровод') or text:find('Ожидаю сопровождение') or text:find('сопровождение у РФК') then
            if color == -1920073984 then
                wait(200)
                sampAddChatMessage('{FF0000}Загрузилась фура снабжения! {FFFF33}"' .. cfg.key.yes:gsub("VK_", "") .. '"{FFFFFF} Подтвердить выезд', 0xFF0000)
                sopr = true
                sos = false
				datchik = false
            end
        end
		if text:find('^ Сначала нужно надеть маску') then
			wait(1200)
			fastMask()
		end
        if string.find(text, "(%A)-[0-9][0-9]") or string.find(text, "(%A)-[0-9]") then
            kvadY, kvadX = string.match(text, "(%A)-(%d+)")
            if kvadrat(kvadY) ~= nil and kvadX ~= nil and kvadY ~= nil and tonumber(kvadX) < 25 and tonumber(kvadX) > 0 then
              last = lcs
              coordX = kvadX * 250 - 3125
              coordY = (kvadrat(kvadY) * 250 - 3125) * - 1
            end
        end
		if string.find(text, '/sfind [0-9]') then
		print(color)
			if color == -1137955585 then
				sfind = string.match(text, '/sfind [%d+]')
				wait(200)
				sampAddChatMessage('{FF0000}Сработал датчик движения! {FFFF33}"' .. cfg.key.yes:gsub("VK_", "") .. '"{FFFFFF} Принять!', 0xFF0000)
				datchik = true
				sos = false
				sopr = false
			end
		end
    end)
end

function sampev.onSendSpawn()
    lua_thread.create(function()
        local myskin = getCharModel(PLAYER_PED)        
        if myskin == 287 or myskin == 191 or myskin == 179 or myskin == 61 or myskin == 255 or myskin == 73 then
            wait(1500)
            sampSendChat('/clist ' .. cfg.config.clist)
            sampAddChatMessage("Вы надели " .. cfg.config.clist .. " клист", 0x00FFFFFF)
        else
            wait(5000)
            sampSendChat("/clist 7")
            sampAddChatMessage("Вы надели 7 клист", 0x00FFFFFF)
        end
    end)
end
--Функция координат--
function GetNearestCoord(Array)
    local x, y, z = getCharCoordinates(playerPed)
    local distance = {}
    for k, v in pairs(Array) do
        distance[k] = {distance = math.floor(getDistanceBetweenCoords3d(v[1], v[2], v[3], x, y, z)), name = v[4]}
    end
    table.sort(distance, function(a, b) return a.distance < b.distance end)
    local CoordName, CoordDist = distance[1].name, distance[1].distance
    return CoordName, CoordDist
end
--Функция квадратов--
function kvadrats()
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
function kvadrat(param)
    local KV = {"А","Б","В","Г","Д","Ж","З","И","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Я"}
    return table.getIndexID(KV, param)
end
function table.getIndexID(object, value)
    for k, v in pairs(object) do
       if v == value then
          return k
       end
    end
    return nil
end
--Функция связанная с текстдравами--
function sampev.onShowTextDraw(id, data)
	if fmask then
		for i, v in ipairs(models) do
			if data.modelId == v then
				sampSendClickTextdraw(id)
				find = true
				return true
			end
		end
		if id == 2161 and not find then
			if data.text == '1' then
				sampSendClickTextdraw(2162)
			elseif data.text == '2' then
				sampAddChatMessage(' Ошибка, у вас нет маски', 0xFF0000)
				sampSendClickTextdraw(508)
				fmask = false
			end
		end
	end
end
--Функция связанная с диалогами--
function sampev.onShowDialog(id, s, t, b1, b2 ,text)
	if id == 24700 and fmask then
		if text:find('Надеть') then
			sampSendDialogResponse(id, 1, 1, _)
		else
			sampSendDialogResponse(id, 0, 0, _)
		end
		sampSendClickTextdraw(508)
		fmask = false
		lua_thread.create(function() wait(1200) sampSendChat('/mask') end)
		return false
	end
end
--Функция поиска 3D текста--
function Search3Dtext(x, y, z, radius, patern)
    local text = ""
    local color = 0
    local posX = 0.0
    local posY = 0.0
    local posZ = 0.0
    local distance = 0.0
    local ignoreWalls = false
    local player = -1
    local vehicle = -1
    local result = false

    for id = 0, 2048 do
        if sampIs3dTextDefined(id) then
            local text2, color2, posX2, posY2, posZ2, distance2, ignoreWalls2, player2, vehicle2 = sampGet3dTextInfoById(id)
            if text2:find(patern) then
				text = text2
				color = color2
				posX = posX2
				posY = posY2
				posZ = posZ2
				distance = distance2
				ignoreWalls = ignoreWalls2
				player = player2
				vehicle = vehicle2
				radius = getDistanceBetweenCoords3d(x, y, z, posX, posY, posZ)
            end
        end
    end

		    return result, text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle
	end
--Функция разделения строк на подстроки (для мониторинга)--
function split(inputstr, sep)
    -- Устанавливаем разделитель по умолчанию, если он не предоставлен
    if sep == nil then
        sep = "%s"
    end
    -- Таблица для хранения результатов разбиения
    local t = {}
    local i = 1
    -- Проходим по строке и разделяем её на подстроки
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end