script_author("MrKapon") -- ����� �������

require 'lib.moonloader' -- ����������� ����������
require 'lib.sampfuncs'
local dlstatus = require('moonloader').download_status
local sampev = require 'lib.samp.events'
local vkeys = require('vkeys')
local inicfg = require 'inicfg'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

update_state = false
--������ � ���������������--
local script_vers = 3
local script_vers_text = "1.3"

local update_url = "https://raw.githubusercontent.com/MrKapon/massonka/main/update.ini" -- ��� ���� ���� ������
local update_path = getWorkingDirectory() .. "/update.ini" -- � ��� ���� ������

local script_url = "https://raw.githubusercontent.com/MrKapon/massonka/main/Massonka.lua?raw=true" -- ��� ���� ������
local script_path = thisScript().path
--�������� cfg.ini �����--
local cfg = inicfg.load({
    config = 
	{
        knife = '�������� Hogue EX-T01',
        tag = '[����]',
        clist = '23',
        resus = '[O(I) | Rh+]',
    },
	key = {
		lock = 'VK_L',
		megafon = 'VK_M',
		sos = 'VK_Z',
		yes = 'VK_F12',
		no = 'VK_F11',
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
local monikQuant = {}
local monikQuantNum = {}
local fmask = false
local find = false
local coords = 
{
{137.2251,1931.3904,19.1907, '���'},
{137.7825,1834.8387,17.6036, '����� �1'},
{343.0120,1798.5864,18.2653, '�-���'},
{345.2440,1926.4535,17.6283, '������� �����'},
{280.2822,1990.3723,17.6071, '����� �3'}
}
local models = {19036, 19037, 19038, 18911, 18912, 18913, 18914, 18915, 18916, 18917, 18918, 18919, 18920, 11704, 18920, 11704}
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end -- �������� �������� ����� � ����������
    while not isSampAvailable() do wait(100) end -- �������� ���������� �����
	sampAddChatMessage("����� ������� {ADD8E6}MrKapon", 0x00339933)
	sampAddChatMessage("�� ���� �������� ���������� � �������: {ADD8E6}mrkapon", 0x00339933)
	sampAddChatMessage("��������� � ������ ����� ����� {ADD8E6}https://vk.com/massonka_family", 0x00339933)
	
	sampRegisterChatCommand("r",cmd_r)	
	sampRegisterChatCommand(cfg.commands.mmask,cmd_mmask)
	sampRegisterChatCommand(cfg.commands.monikr, function() rgetm() end)
	sampRegisterChatCommand(cfg.commands.moniks, function() getm() end)
	sampRegisterChatCommand(cfg.commands.fmask, fastMask)

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED) -- ���������� ���� ��
	nick = sampGetPlayerNickname(id) -- ���������� ���� ��� �� ���
	--�������� ���������� �������--
	downloadUrlToFile(update_url, update_path, function(id, status)
		thread = lua_thread.create(function()
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				while not sampIsLocalPlayerSpawned() do wait(0) end
				updateIni = inicfg.load(nil, update_path)
					if tonumber(updateIni.info.vers) > script_vers then
						sampAddChatMessage("���� ����������! ������: {ADD8E6}" .. updateIni.info.vers_text, 0x00339933)
						update_state = true
					end
				os.remove(update_path)
			end
		end)
    end)
	
	while true do
	wait(0)
	--���������� �������--
	if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("������ ������� ��������!", 0x00339933)
				end
			end)
			break
	end
	
if isKeyJustPressed(vkeys[cfg.key.lock]) and not sampIsChatInputActive() then 
	sampSendChat("/lock") 
end

if isKeyJustPressed(vkeys[cfg.key.no]) and not sampIsChatInputActive() then
    sampSendChat('/r ' .. cfg.config.tag .. ' 10-6. ��������!')
end
if isKeyJustPressed(vkeys[cfg.key.yes]) and not sampIsChatInputActive() then
    if sopr == true then
        sampSendChat('/r '..cfg.config.tag..' �������. ���������.')
        sopr = false
    elseif sos == true then
        sampSendChat('/r '..cfg.config.tag..' �������. �������� ������!')
        sos = false
    end
end

if isKeyJustPressed(vkeys[cfg.key.megafon]) and not sampIsChatInputActive() then
	if not second and isCharInArea2d(PLAYER_PED, 412.9650, 2168.4063, -41.8824, 1699.8453) then
		sampSendChat("/m �� ���������� �� �������� ���������� ������� ����! � ��� ���� 15 ������, ����� �������� ��")
		second = true
	elseif second == false then
		sampSendChat('/m ����� ������ �������� ������ ������������� ��� ���������')
	else
		sampSendChat("/m �� ����������� ����������� ���������� ����� ������ ����� ��� ��������������!")
		second = false
	end
end

if isKeyJustPressed(vkeys[cfg.key.sos]) and not sampIsChatInputActive() then
	local name, dist = GetNearestCoord(coords)
		if isCharInArea2d(PLAYER_PED,412.9650,2168.4063,-41.8824,1699.8453) then
			sampSendChat('/r '..cfg.config.tag..' SOS! ��������� ��������� �� ����������������. ������: '..name)
		else
			sampSendChat('/r '..cfg.config.tag..' SOS! ��������� ��������� � ������� '..kvadrat())
		end
end

local result, target = getCharPlayerIsTargeting(playerHandle) 
 	if result then 
		result, playerid = sampGetPlayerIdByCharHandle(target) 
	end
    if result and isKeyJustPressed(vkeys[cfg.key.tie]) then
		sampSendChat('/tie ' ..playerid)
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
        sampSendChat('/do ' .. nick .. ' ���� � ������� ����� Crye Precision G3 Combat � ��������� Multicam')
        wait(1100)
        sampSendChat('/do ���� ������ ����������� ����������� ������������ AVS ������ ������ III-A � �������� ' .. cfg.config.resus)
        wait(1100)
        sampSendChat('/do �� ��������� ' .. cfg.config.knife .. ' � ���������� � ����� Kagwerks, ��������������� ����� �����������')
        wait(1100)
        sampSendChat('/do ���� ������ ����������, �� ������ ���� FAST 3.0 � �������� GPNVG-18 � ��������� ���������� EARMOR M32X')
    end)
end

function rgetm()
  local x,y,z = getCharCoordinates(PLAYER_PED)
  local result, text = Search3Dtext(x,y,z, 700, "�����")
  local temp = split(text, "\n")
  sampAddChatMessage("============= ���������� ============", 0xFFFFFF)
  for k, val in pairs(temp) do monikQuant[k] = val end
  if monikQuant[6] ~= nil then
    for i = 1, table.getn(monikQuant) do
      number1, number2, monikQuantNum[i] = string.match(monikQuant[i],"(%d+)[^%d]+(%d+)[^%d]+(%d+)")
      monikQuantNum[i] = monikQuantNum[i]/1000
    end
    sampSendChat("/r ����������: [LSPD - "..monikQuantNum[1].." | SFPD - "..monikQuantNum[2].." | LVPD - "..monikQuantNum[3].." | SFa - "..monikQuantNum[4].." | FBI - "..monikQuantNum[6].."]")
  end
end

function getm()
	local x,y,z = getCharCoordinates(PLAYER_PED)
	local result, text = Search3Dtext(x,y,z, 1000, "FBI")
	local temp = split(text, "\n")
	sampAddChatMessage("=============[����������]============", 0xFFFFFF)
	for k, val in pairs(temp) do sampAddChatMessage(val, 0xFFFFFF) end
	sampAddChatMessage("=============[����������]============", 0xFFFFFF)
end

function fastMask()
	fmask = true
	find = false
	sampSendChat('/items')
end

function sampev.onServerMessage(color, text)
    lua_thread.create(function()
        print(color, text)        
        if text:find('������� ���� �����') and color == 1687547391 then
            wait(1500)
            sampSendChat('/clist ' .. cfg.config.clist)
            sampAddChatMessage("�� ������ " .. cfg.config.clist .. " �����", 0x00FFFFFF)
        end        
        if text:find('�� ����� � ���� �����') and color == -1263159297 then
            wait(1500)
            sampSendChat('/clist ' .. cfg.config.clist)
            sampAddChatMessage("�� ������ " .. cfg.config.clist .. " �����", 0x00FFFFFF)
        end
        if text:find('SOS') or text:find('���') or text:find('���������� ���������') or text:find('���������� �������������') or text:find('���������� ������ � ������') or text:find('������ ���� ��������� ������') or text:find('�������� ��� �������� ����� ����������') then
            if color == -1920073984 then
                wait(200)
                sampAddChatMessage('{FF0000}����� ������ ���������! {FFFF33}"' .. cfg.key.yes:gsub("VK_", "") .. '"{FFFFFF} �������!', 0xFF0000)
                sos = true
                sopr = false
            end
        end
        if text:find('������������� �� ���') or text:find('������ ��������') or text:find('������ �������������') or text:find('������������� � ���') then
            if color == -1920073984 then
                wait(200)
                sampAddChatMessage('{FF0000}����������� ���� ���������! {FFFF33}"' .. cfg.key.yes:gsub("VK_", "") .. '"{FFFFFF} ����������� ����� | {FFFF33}"' .. cfg.key.no:gsub("VK_", "") .. '"{FFFFFF} ��������', 0xFF0000)
                sopr = true
                sos = false
            end
        end
		if text:find('^ ������� ����� ������ �����') then
			wait(1200)
			fastMask()
		end
    end)
end

function sampev.onSendSpawn()
    lua_thread.create(function()
        local myskin = getCharModel(PLAYER_PED)        
        if myskin == 287 or myskin == 191 or myskin == 179 or myskin == 61 or myskin == 255 or myskin == 73 then
            wait(1500)
            sampSendChat('/clist ' .. cfg.config.clist)
            sampAddChatMessage("�� ������ " .. cfg.config.clist .. " �����", 0x00FFFFFF)
        else
            wait(5000)
            sampSendChat("/clist 7")
            sampAddChatMessage("�� ������ 7 �����", 0x00FFFFFF)
        end
    end)
end
--������� ���������--
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
--������� ���������--
function kvadrat()
    local KV = {
        [1] = "�",
        [2] = "�",
        [3] = "�",
        [4] = "�",
        [5] = "�",
        [6] = "�",
        [7] = "�",
        [8] = "�",
        [9] = "�",
        [10] = "�",
        [11] = "�",
        [12] = "�",
        [13] = "�",
        [14] = "�",
        [15] = "�",
        [16] = "�",
        [17] = "�",
        [18] = "�",
        [19] = "�",
        [20] = "�",
        [21] = "�",
        [22] = "�",
        [23] = "�",
        [24] = "�",
    }
    local X, Y, Z = getCharCoordinates(playerPed)
    X = math.ceil((X + 3000) / 250)
    Y = math.ceil((Y * - 1 + 3000) / 250)
    Y = KV[Y]
    local KVX = (Y.."-"..X)
    return KVX
end
--������� ��������� � ������������--
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
				sampAddChatMessage(' ������, � ��� ��� �����', 0xFF0000)
				sampSendClickTextdraw(508)
				fmask = false
			end
		end
	end
end
--������� ��������� � ���������--
function sampev.onShowDialog(id, s, t, b1, b2 ,text)
	if id == 24700 and fmask then
		if text:find('������') then
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
--������� ������ 3D ������--
function Search3Dtext(x, y, z, radius, pattern)
    for id = 0, 2048 do
        if sampIs3dTextDefined(id) then
            local text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle = sampGet3dTextInfoById(id)
            local dist = getDistanceBetweenCoords3d(x, y, z, posX, posY, posZ)
            if dist < radius and (pattern == "" or string.match(text, pattern)) then
                return true, text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle
            end
        end
    end
    return false
end
--������� ���������� ����� �� ��������� (��� �����������)--
function split(inputstr, sep)
    -- ������������� ����������� �� ���������, ���� �� �� ������������
    if sep == nil then
        sep = "%s"
    end
    -- ������� ��� �������� ����������� ���������
    local t = {}
    local i = 1
    -- �������� �� ������ � ��������� � �� ���������
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end