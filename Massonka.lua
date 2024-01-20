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

local script_vers = 1
local script_vers_text = "1.00"

local update_url = "https://raw.githubusercontent.com/MrKapon/massonka/main/update.ini" -- ��� ���� ���� ������
local update_path = getWorkingDirectory() .. "/update.ini" -- � ��� ���� ������

local script_url = "https://raw.githubusercontent.com/MrKapon/massonka/main/Massonka.lua" -- ��� ���� ������
local script_path = thisScript().path

local directIni = "massonka.ini"
local cfg = inicfg.load(nil, directIni)

local second = false
local sos = false
local sopr = false
local coords = 
{
{137.2251,1931.3904,19.1907, '���'}, --���������� � ��������
{137.7825,1834.8387,17.6036, '����� �1'},
{343.0120,1798.5864,18.2653, '�-���'},
{345.2440,1926.4535,17.6283, '������� �����'},
{280.2822,1990.3723,17.6071, '����� �3'}
}
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end -- �������� �������� ����� � ����������
    while not isSampAvailable() do wait(100) end -- �������� ���������� �����
	sampAddChatMessage("����� ������� {ADD8E6}MrKapon", 0x00339933)
	sampAddChatMessage("�� ���� �������� ���������� � �������: {ADD8E6}mrkapon", 0x00339933)
	sampAddChatMessage("��������� � ������ ����� ����� {ADD8E6}https://vk.com/massonka_family", 0x00339933)
	
	sampRegisterChatCommand("r",cmd_r)	
	sampRegisterChatCommand(cfg.commands.mmask,cmd_mmask)

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED) -- ���������� ���� ��
	nick = sampGetPlayerNickname(id) -- ���������� ���� ��� �� ���
	
	downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("���� ����������! ������: " .. updateIni.info.vers_text, -1)
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
                    sampAddChatMessage("������ ������� ��������!", -1)
                    thisScript():reload()
                end
            end)
            break
        end

if isKeyJustPressed(vkeys[cfg.key.lock]) and not sampIsChatInputActive() then 
	sampSendChat("/lock") 
end

if isKeyJustPressed(vkeys[cfg.key.no]) and not sampIsChatInputActive() then
	sampSendChat('/r '..cfg.config.tag..' 10-6. ��������!')
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
if not second then
sampSendChat("/m �� ���������� �� �������� ���������� ������� ����! � ��� ���� 15 ������, ����� �������� ��")
second = true
else
sampSendChat("/m �� ����������� ����������� ���������� ����� ������ ����� ��� ��������������!")
second = false
end
end
if isKeyJustPressed(vkeys[cfg.key.sos]) and not sampIsChatInputActive() then
		local name, dist = GetNearestCoord(coords)
		if isCharInArea2d(PLAYER_PED,412.9650,2168.4063,-41.8824,1699.8453) then
			sampSendChat('/r '..cfg.config.tag..' SOS! ��������� ��������� �� ����������������. ������:  '..name)
		else
			sampSendChat('/r '..cfg.config.tag..' SOS! ��������� ��������� � ������� '..kvadrat())
		end
end
local result, target = getCharPlayerIsTargeting(playerHandle) 
 	if result then result, playerid = sampGetPlayerIdByCharHandle(target) end -- ���� ������ ��� �� ������, �� �������� ID.
      		if result and isKeyJustPressed(vkeys[cfg.key.tie]) then -- ���� ������ ��� � ������ 1 �� ������, ��...
        sampSendChat("/tie "..playerid.."") -- ���������
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
	sampSendChat('/do '..nick..' ���� � ������� ����� Crye Precision G3 Combat � ��������� Multicam')
	wait(1100)
	sampSendChat('/do ���� ������ ����������� ����������� ������������ AVS ������ ������ III-A � �������� [O(I) | Rh+]')
	wait(1100)
	sampSendChat('/do �� ��������� '..cfg.config.knife..' � ���������� � ����� Kagwerks, ��������������� ����� �����������')
	wait(1100)
	sampSendChat('/do ���� ������ ����������, �� ������ ���� FAST 3.0 � �������� GPNVG-18 � ��������� ���������� EARMOR M32X')
	end)
end
function sampev.onServerMessage(color, text)
	lua_thread.create(function()
		print(color,text)
		local myskin = getCharModel(PLAYER_PED)
		if text:find('������� ���� �����') and color == 1687547391 then
		wait(1500)
		sampSendChat('/clist '..cfg.config.clist)
		sampAddChatMessage("�� ������ "..cfg.config.clist.." �����", 0x00FFFFFF)	
		end
		if text:find('�� ����� � ���� �����') and color == -1263159297 then
		wait(1500)
		sampSendChat('/clist '..cfg.config.clist)
		sampAddChatMessage("�� ������ "..cfg.config.clist.." �����", 0x00FFFFFF)	
		end
		if text:find('SOS') or text:find('���') or text:find('���������� ���������') or text:find('���������� �������������') or text:find('���������� ������ � ������') or text:find('������ ���� ��������� ������')  or text:find('�������� ��� �������� ����� ����������') then 
		if color == -1920073984 then
		wait(200)
		sampAddChatMessage('{FF0000}����� ������ ���������! {FFFF33}"F12"{FFFFFF} �������!',0xFF0000)
		sos = true
		end
		end 
		if text:find('������������� �� ���') or text:find('������ ��������') or text:find('������ �������������') or text:find('������������� � ���') then
		if color == -1920073984 then
		wait(200)
		sampAddChatMessage('{FF0000}����������� ���� ���������! {FFFF33}"F12"{FFFFFF} ����������� ����� | {FFFF33}"F11"{FFFFFF} ��������',0xFF0000)
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
		sampAddChatMessage("�� ������ "..cfg.config.clist.." �����", 0x00FFFFFF)	
		else
		wait(5000)
		sampSendChat("/clist 7")
		sampAddChatMessage("�� ������ 7 �����", 0x00FFFFFF)
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