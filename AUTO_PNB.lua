local MAG_X = -1 -- set magplant's x (LEAVE AT -1 TO GET IT AUTOMATICALLY FROM YOUR POSITION)
local MAG_Y = -1 -- set magplant's y (LEAVE AT -1 TO GET IT AUTOMATICALLY FROM YOUR POSITION)

local WEBHOOK = "https://discord.com/api/webhooks/1123450665264488628/CukcWC--bKb4Z0dXdFenu8T0mCagF92XXtZRa0GFWIQXkBy94xLIU0ppIu4LcwpOApNo" -- webhook link
if MAG_X == -1 or MAG_Y == -1 then -- Don't touch
	MAG_X = math.floor(GetLocal().tile_x-1) -- Don't touch
	MAG_Y = math.floor(GetLocal().tile_y-1) -- Don't touch
end

local REMOTE_X = MAG_X -- Don't touch
local REMOTE_Y = MAG_Y -- Don't touch
local PNB_X = MAG_X + 1 -- Don't touch
local PNB_Y = MAG_Y + 1 -- Don't touch

local START_PNB_X = PNB_X -- Don't touch
local START_PNB_Y = PNB_Y -- Don't touch

local START_MAG_X = MAG_X -- Don't touch
local START_MAG_Y = MAG_Y -- Don't touch

local USE_ARROZ = false -- Don't touch
local USE_CLOVER = false -- Don't touch
local CHECK_ARROZ = false -- Don't touch
local CHECK_CLOVER = false -- Don't touch

local CURRENT_GEMS = GetLocal().gems -- Don't touch
local LAST_UPDATE = os.time() -- Don't touch
local CHANGE_REMOTE = false -- Don't touch
local BLACK_GEM_COUNT = 0 -- Don't touch
local MAG1_COUNT = 0 -- Don't touch
local MAG2_COUNT = 0 -- Don't touch
local MAG3_COUNT = 0 -- Don't touch
local MAG4_COUNT = 0 -- Don't touch
local MAG5_COUNT = 0 -- Don't touch
local MAG6_COUNT = 0 -- Don't touch

local MAG_1_EMPTY = false
local MAG_2_EMPTY = false
local MAG_3_EMPTY = false
local MAG_4_EMPTY = false
local MAG_5_EMPTY = false
local MAG_6_EMPTY = false

local BLGL = GetItemCount(11550)
local BGL = GetItemCount(7188)
local DL = GetItemCount(1796)
local WL = GetItemCount(242)

local TOTAL_LOCKS = (BLGL*1000000) + (BGL*10000) + (DL*100) + WL

if WORLD == "" then
	WORLD = string.upper(GetLocal().world)
end

for _, item in pairs(GetObjects()) do
	if GetLocal().world == "EXIT" then return end
	if item.id == 13802 then
		BLACK_GEM_COUNT = BLACK_GEM_COUNT + item.count
	end
end

local function GET_TELEPHONE()
	local TILE_X = 0
	local TILE_Y = 0

    for _,tile in pairs(GetTiles()) do
        if tile.fg == 3898 then
            if tile.pos_x < 0 then
				TILE_X = math.floor(tile.pos_x + 256)
			else
				TILE_X = tile.pos_x
			end

			if tile.pos_y < 0 then
				TILE_Y = math.floor(tile.pos_y + 256)
			else
				TILE_Y = tile.pos_y
			end

			return TILE_X, TILE_Y
        end
    end
end

function EARNED_LOCKS(LOCK_COUNT)
	local EARNED_BLGL = 0
	local EARNED_BGL = 0
	local EARNED_DL = 0
	local EARNED_WL = 0

	while LOCK_COUNT >= 1000000 do
		LOCK_COUNT = LOCK_COUNT - 1000000
		EARNED_BLGL = EARNED_BLGL + 1
	end

	while LOCK_COUNT >= 10000 do
		LOCK_COUNT = LOCK_COUNT - 10000
		EARNED_BGL = EARNED_BGL + 1
	end

	while LOCK_COUNT >= 100 do
		LOCK_COUNT = LOCK_COUNT - 100
		EARNED_DL = EARNED_DL + 1
	end

	while LOCK_COUNT >= 1 do
		LOCK_COUNT = LOCK_COUNT - 1
		EARNED_WL = EARNED_WL + 1
	end

	return EARNED_BLGL, EARNED_BGL, EARNED_DL, EARNED_WL
end

function removeColorAndSymbols(str)
    local cleanedStr = string.gsub(str, "`(%S)", '')
    cleanedStr = string.gsub(cleanedStr, "`{2}|(~{2})", '')
    return cleanedStr
end

local function FormatNumber(num)
    num = math.floor(num + 0.5)

    local formatted = tostring(num)
    local k = 3
    while k < #formatted do
        formatted = formatted:sub(1, #formatted - k) .. "," .. formatted:sub(#formatted - k + 1)
        k = k + 4
    end

    return formatted
end

local function CHECK_BUFFS()
    if GetLocal().world ~= WORLD then return end

    CHECK_ARROZ = true
	CHECK_CLOVER = true
    SendPacket(2, "action|wrench\n|netid|"..GetLocal().netid)
end

local function FindMagplants()
    if (GetTile(PNB_X+2, PNB_Y-1).fg == 5638 and GetTile(PNB_X+3, PNB_Y-1).fg == 5638 and GetTile(PNB_X+4, PNB_Y-1).fg == 5638 and GetTile(PNB_X+2, PNB_Y+1).fg == 5638 and GetTile(PNB_X+3, PNB_Y+1).fg == 5638 and GetTile(PNB_X+4, PNB_Y+1).fg == 5638) then
        return true
    else
        return false
    end
end

local function Place(x, y,id)
    local player = GetLocal()
    local pkt_punch = {
        type = 3,
        int_data = id,
        pos_x = player.pos_x,
        pos_y = player.pos_y,
        int_x = x,
        int_y = y,
    }
    SendPacketRaw(pkt_punch)
end

local function Update()
    if GetLocal().world ~= WORLD or CHANGE_REMOTE then return end

    local payload = [[
    {
        "content": "",
        "embeds": [{
            "color": "1146986",
            "fields": [{
                "name":"Account:",
                "value": ":alien: Name: **%s**\n:earth_asia: Current World: **%s**",
                "inline": false
            },
            {
                "name": "Information:",
                "value": ":gem: Gems: **%s**\n(Earned **%s** from the last **%s seconds**)\n\n:four_leaf_clover: Lucky Clover Stock: **%s**\n:poultry_leg: Arroz Stock: **%s**\n:gem: Black Gems in World: **%s**\n(Earned **%s** from the last **%s seconds**, an average rate of **%s** gems per second)",
                "inline": false
            },
            {
                "name": "Total Locks:",
                "value": "__**Total**__\n<:BLGL:1106329216221462620> Black Gem Locks: **%s**\n<:BGL:1106329217597182063> Blue Gem Locks: **%s**\n<:DL:1106339010038734848> Diamond Locks: **%s**\n<:WL:1111357502978789437> World Locks: **%s**",
                "inline": false
            },
			{
                "name": "In the past %s seconds:",
                "value": "<:BLGL:1106329216221462620> - **%s**\n<:BGL:1106329217597182063> - **%s**\n<:DL:1106339010038734848> - **%s**\n<:WL:1111357502978789437> - **%s**",
                "inline": false
            },
            {
                "name": "MAGPLANT:",
                "value": "Current remote: [**%s**, **%s**]\n\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**",
                "inline": false
            },
            {
                "name": "Status",
                "value": ":green_circle: Breaking",
                "inline": false
            }
            ],
            "thumbnail": {
                "url": "https://cdn.growtopia.tech/items/18.png"
            },
            "footer": {
                "text": "%s"
            }
        }]
    }]]

    local gems_earned = FormatNumber(GetLocal().gems - CURRENT_GEMS)
	local BEFORE_BLACK_GEMS = BLACK_GEM_COUNT

	BLACK_GEM_COUNT = 0

    for _, item in pairs(GetObjects()) do
		if item.id == 13802 then
			BLACK_GEM_COUNT = BLACK_GEM_COUNT + item.count
		end
	end
	
	BLGL = math.floor(GetItemCount(11550))
	BGL = math.floor(GetItemCount(7188))
	DL = math.floor(GetItemCount(1796))
	WL = math.floor(GetItemCount(242))

	OLD_LOCKS = TOTAL_LOCKS
	TOTAL_LOCKS = (BLGL*1000000) + (BGL*10000) + (DL*100) + WL

	EARNED_BLGL, EARNED_BGL, EARNED_DL, EARNED_WL = EARNED_LOCKS(TOTAL_LOCKS - OLD_LOCKS)
	
	local BLACK_GEMS_EARNED = BLACK_GEM_COUNT - BEFORE_BLACK_GEMS
	local BLACK_GEMS_AVERAGE = BLACK_GEMS_EARNED / WEBHOOK_DELAY

    SendWebhook(WEBHOOK, payload:format(removeColorAndSymbols(GetLocal().name), GetLocal().world, FormatNumber(GetLocal().gems), gems_earned, WEBHOOK_DELAY, math.floor(GetItemCount(528)), math.floor(GetItemCount(4604)), math.floor(BLACK_GEM_COUNT), math.floor(BLACK_GEMS_EARNED), WEBHOOK_DELAY, BLACK_GEMS_AVERAGE, BLGL, BGL, DL, WL, WEBHOOK_DELAY, EARNED_BLGL, EARNED_BGL, EARNED_DL, EARNED_WL, REMOTE_X, REMOTE_Y, MAG_X, MAG_Y, FormatNumber(MAG1_COUNT), MAG_X + 1, MAG_Y, FormatNumber(MAG2_COUNT), MAG_X + 2, MAG_Y, FormatNumber(MAG3_COUNT), MAG_X, MAG_Y + 2, FormatNumber(MAG4_COUNT), MAG_X + 1, MAG_Y + 2, FormatNumber(MAG5_COUNT), MAG_X + 2, MAG_Y + 2, FormatNumber(MAG6_COUNT), os.date("!%a, %b/%d/%Y at %I:%M %p", os.time() + 8 * 60 * 60)))

    CURRENT_GEMS = GetLocal().gems
end

local function updateRemote()
    if GetLocal().world ~= WORLD then return end

    local payload = [[
		{
			"content": "",
			"embeds": [{
				"color": "1146986",
				"fields": [{
					"name":"Account:",
					"value": ":alien: Name: **%s**\n:earth_asia: Current World: **%s**",
					"inline": false
				},
				{
					"name": "Information:",
					"value": ":gem: Gems: **%s**\n(Earned **%s** from the last **%s seconds**)\n\n:four_leaf_clover: Lucky Clover Stock: **%s**\n:poultry_leg: Arroz Stock: **%s**\n:gem: Black Gems in World: **%s**\n(Earned **%s** from the last **%s seconds**, an average rate of **%s** gems per second)",
					"inline": false
				},
				{
					"name": "Total Locks:",
					"value": "__**Total**__\n<:BLGL:1106329216221462620> Black Gem Locks: **%s**\n<:BGL:1106329217597182063> Blue Gem Locks: **%s**\n<:DL:1106339010038734848> Diamond Locks: **%s**\n<:WL:1111357502978789437> World Locks: **%s**",
					"inline": false
				},
				{
					"name": "In the past %s seconds:",
					"value": "<:BLGL:1106329216221462620> - **%s**\n<:BGL:1106329217597182063> - **%s**\n<:DL:1106339010038734848> - **%s**\n<:WL:1111357502978789437> - **%s**",
					"inline": false
				},
				{
					"name": "MAGPLANT:",
					"value": "Current remote: [**%s**, **%s**]\n\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**",
					"inline": false
				},
				{
					"name": "Status",
					"value": ":yellow_circle: Changing remote! MAGPLANT 5000 [**%s**, **%s**] is empty.",
					"inline": false
				}
				],
				"thumbnail": {
					"url": "https://cdn.growtopia.tech/items/32.png"
				},
				"footer": {
					"text": "%s"
				}
			}]
		}]]

	local BEFORE_BLACK_GEMS = BLACK_GEM_COUNT

	BLACK_GEM_COUNT = 0

    for _, item in pairs(GetObjects()) do
		if item.id == 13802 then
			BLACK_GEM_COUNT = BLACK_GEM_COUNT + item.count
		end
	end
	
	BLGL = math.floor(GetItemCount(11550))
	BGL = math.floor(GetItemCount(7188))
	DL = math.floor(GetItemCount(1796))
	WL = math.floor(GetItemCount(242))

	OLD_LOCKS = TOTAL_LOCKS
	TOTAL_LOCKS = (BLGL*1000000) + (BGL*10000) + (DL*100) + WL

	EARNED_BLGL, EARNED_BGL, EARNED_DL, EARNED_WL = EARNED_LOCKS(TOTAL_LOCKS - OLD_LOCKS)
	
	local BLACK_GEMS_EARNED = BLACK_GEM_COUNT - BEFORE_BLACK_GEMS
	local BLACK_GEMS_AVERAGE = BLACK_GEMS_EARNED / WEBHOOK_DELAY

    SendWebhook(WEBHOOK, payload:format(removeColorAndSymbols(GetLocal().name), GetLocal().world, FormatNumber(GetLocal().gems), gems_earned, WEBHOOK_DELAY, math.floor(GetItemCount(528)), math.floor(GetItemCount(4604)), math.floor(BLACK_GEM_COUNT), math.floor(BLACK_GEMS_EARNED), WEBHOOK_DELAY, BLACK_GEMS_AVERAGE, BLGL, BGL, DL, WL, WEBHOOK_DELAY, EARNED_BLGL, EARNED_BGL, EARNED_DL, EARNED_WL, REMOTE_X, REMOTE_Y, MAG_X, MAG_Y, FormatNumber(MAG1_COUNT), MAG_X + 1, MAG_Y, FormatNumber(MAG2_COUNT), MAG_X + 2, MAG_Y, FormatNumber(MAG3_COUNT), MAG_X, MAG_Y + 2, FormatNumber(MAG4_COUNT), MAG_X + 1, MAG_Y + 2, FormatNumber(MAG5_COUNT), MAG_X + 2, MAG_Y + 2, FormatNumber(MAG6_COUNT), REMOTE_X, REMOTE_Y, os.date("!%a, %b/%d/%Y at %I:%M %p", os.time() + 8 * 60 * 60)))
end

local function SendReconnect()
    if GetLocal().world ~= WORLD then return end

    local payload = [[
		{
			"content": "",
			"embeds": [{
				"color": "1146986",
				"fields": [{
					"name":"Account:",
					"value": ":alien: Name: **%s**\n:earth_asia: Current World: **%s**",
					"inline": false
				},
				{
					"name": "Information:",
					"value": ":gem: Gems: **%s**\n(Earned **%s** from the last **%s seconds**)\n\n:four_leaf_clover: Lucky Clover Stock: **%s**\n:poultry_leg: Arroz Stock: **%s**\n:gem: Black Gems in World: **%s**\n(Earned **%s** from the last **%s seconds**, an average rate of **%s** gems per second)",
					"inline": false
				},
				{
					"name": "Total Locks:",
					"value": "__**Total**__\n<:BLGL:1106329216221462620> Black Gem Locks: **%s**\n<:BGL:1106329217597182063> Blue Gem Locks: **%s**\n<:DL:1106339010038734848> Diamond Locks: **%s**\n<:WL:1111357502978789437> World Locks: **%s**",
					"inline": false
				},
				{
					"name": "In the past %s seconds:",
					"value": "<:BLGL:1106329216221462620> - **%s**\n<:BGL:1106329217597182063> - **%s**\n<:DL:1106339010038734848> - **%s**\n<:WL:1111357502978789437> - **%s**",
					"inline": false
				},
				{
					"name": "MAGPLANT:",
					"value": "Current remote: [**%s**, **%s**]\n\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**\n[**%s**, **%s**] MAGPLANT 5000: **%s**",
					"inline": false
				},
				{
					"name": "Status",
					"value": ":red_circle: Reconnected! You most likely disconnected recently.",
					"inline": false
				}
				],
				"thumbnail": {
					"url": "https://cdn.growtopia.tech/items/3732.png"
				},
				"footer": {
					"text": "%s"
				}
			}]
		}]]
	
	local BEFORE_BLACK_GEMS = BLACK_GEM_COUNT

	BLACK_GEM_COUNT = 0

    for _, item in pairs(GetObjects()) do
		if item.id == 13802 then
			BLACK_GEM_COUNT = BLACK_GEM_COUNT + item.count
		end
	end
	
	BLGL = math.floor(GetItemCount(11550))
	BGL = math.floor(GetItemCount(7188))
	DL = math.floor(GetItemCount(1796))
	WL = math.floor(GetItemCount(242))

	OLD_LOCKS = TOTAL_LOCKS
	TOTAL_LOCKS = (BLGL*1000000) + (BGL*10000) + (DL*100) + WL

	EARNED_BLGL, EARNED_BGL, EARNED_DL, EARNED_WL = EARNED_LOCKS(TOTAL_LOCKS - OLD_LOCKS)
	
	local BLACK_GEMS_EARNED = BLACK_GEM_COUNT - BEFORE_BLACK_GEMS
	local BLACK_GEMS_AVERAGE = BLACK_GEMS_EARNED / WEBHOOK_DELAY

    SendWebhook(WEBHOOK, payload:format(removeColorAndSymbols(GetLocal().name), GetLocal().world, FormatNumber(GetLocal().gems), gems_earned, WEBHOOK_DELAY, math.floor(GetItemCount(528)), math.floor(GetItemCount(4604)), math.floor(BLACK_GEM_COUNT), math.floor(BLACK_GEMS_EARNED), WEBHOOK_DELAY, BLACK_GEMS_AVERAGE, BLGL, BGL, DL, WL, WEBHOOK_DELAY, EARNED_BLGL, EARNED_BGL, EARNED_DL, EARNED_WL, REMOTE_X, REMOTE_Y, MAG_X, MAG_Y, FormatNumber(MAG1_COUNT), MAG_X + 1, MAG_Y, FormatNumber(MAG2_COUNT), MAG_X + 2, MAG_Y, FormatNumber(MAG3_COUNT), MAG_X, MAG_Y + 2, FormatNumber(MAG4_COUNT), MAG_X + 1, MAG_Y + 2, FormatNumber(MAG5_COUNT), MAG_X + 2, MAG_Y + 2, FormatNumber(MAG6_COUNT), os.date("!%a, %b/%d/%Y at %I:%M %p", os.time() + 8 * 60 * 60)))
end

local function Get_Remote()
	Sleep(500)

    FindPath(PNB_X, PNB_Y)
	Sleep(150)
	Place(GetLocal().tile_x+1, GetLocal().tile_y, 18)
	Sleep(150)
    Place(REMOTE_X, REMOTE_Y,32)
    Sleep(600)
	
    SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|"..REMOTE_X.."|\ny|"..REMOTE_Y.."|\nbuttonClicked|getRemote")
	Sleep(500)
end

local function checkRemote()
    if GetLocal().world ~= WORLD then return end

    if GetItemCount(5640) < 1 then
        SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|0\ncheck_bfg|0\ncheck_gems|"..TAKE_GEMS)
        Sleep(50)
        Get_Remote()
    end

    return GetItemCount(5640) >= 1
end

local function hook(var)
    if var[0]:find("OnTalkBubble") and var[2]:find("The MAGPLANT 5000 is empty") and var[1] == GetLocal().netid then
        CHANGE_REMOTE = true
        return true
    end
    if var[0]:find("OnDialogRequest") and var[1]:find("magplant_edit") then
        local x = var[1]:match('embed_data|x|(%d+)')
        local y = var[1]:match('embed_data|y|(%d+)')
        local amount = var[1]:match("The machine contains (%d+)")
        if amount == nil then amount = 0 end

        if x == ""..MAG_X.."" and y == ""..MAG_Y.."" then
            MAG1_COUNT = amount
        elseif x == ""..(MAG_X+1).."" and y == ""..MAG_Y.."" then
            MAG2_COUNT = amount
        elseif x == ""..(MAG_X+2).."" and y == ""..MAG_Y.."" then
            MAG3_COUNT = amount
        elseif x == ""..(MAG_X).."" and y ~= ""..MAG_Y.."" then
            MAG4_COUNT = amount
        elseif x == ""..(MAG_X+1).."" and y ~= ""..MAG_Y.."" then
            MAG5_COUNT = amount
        elseif x == ""..(MAG_X+2).."" and y ~= ""..MAG_Y.."" then
            MAG6_COUNT = amount
        end
        return true
    end
    if var[0]:find("OnConsoleMessage") then
        if var[0]:find("OnConsoleMessage") and var[1]:find("Cheat Active") then
            return true
        end
        if var[0]:find("OnConsoleMessage") and var[1]:find("Whoa, calm down toggling cheats on/off... Try again in a second!") then
            return true
        end
        if var[0]:find("OnConsoleMessage") and var[1]:find("Applying cheats...") then
            return true
        end
    end
	if var[0]:find("OnDialogRequest") and var[1]:find("add_player_info") then
        if CHECK_CLOVER then
            if var[1]:find("|528|") then
                USE_CLOVER = false
            else
                USE_CLOVER = true
            end

            CHECK_CLOVER = false
		end
		
		if CHECK_ARROZ then
			if var[1]:find("|4604|") then
                USE_ARROZ = false
            else
                USE_ARROZ = true
            end

			CHECK_ARROZ = false
        end
		
		return true
	end

	if var[0]:find("OnDialogRequest") and var[1]:find("telephone") then
		return true
	end
	
end

AddCallback("Hook", "OnVarlist", hook)

RunThread(function()
	while true do
		Sleep(100)

		if EVADE_TAXES then
			if GetLocal().gems >= 10000 then
				SendPacket(2 , "action|buy\nitem|buy_worldlockpack")
				Sleep(200)
			end
		
			if GetItemCount(242) >= 100 then
				local packet = {}
				packet.type = 10
				packet.int_data = 242
				SendPacketRaw(packet)
				Sleep(100)
			end
		
			if GetItemCount(1796) >= 100 then
				TELEPHONE_X, TELEPHONE_Y = GET_TELEPHONE()
				SendPacket(2,"action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..TELEPHONE_X.."|\ny|"..TELEPHONE_Y.."|\nbuttonClicked|bglconvert")
				Sleep(500)
			end

			if GetItemCount(7188) >= 100 then
				SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
				Sleep(100)
			end
		end
	end
end)

while true do
	CHECK_BUFFS()
    Sleep(750)
    if GetLocal().world ~= WORLD then
        SendPacket(2, "action|join_request\nname|" .. WORLD .. "")
        SendPacket(3, "action|join_request\nname|" .. WORLD .. "\ninvitedWorld|0")
        Sleep(7000)
        SendReconnect()
    elseif checkRemote() then
		if USE_CLOVER then
			Place(GetLocal().tile_x, GetLocal().tile_y, 528)
			Sleep(400)
		end
	
		if USE_ARROZ then
			Place(GetLocal().tile_x, GetLocal().tile_y, 4604)
			Sleep(400)
		end	

        if CHANGE_REMOTE then
			local WARN_TEXT = ""
            updateRemote()
            Sleep(150)
            if REMOTE_X == (MAG_X) and REMOTE_Y == MAG_Y and not MAG_1_EMPTY then
                REMOTE_X = MAG_X + 1
				WARN_TEXT = "`4Magplant 1 is empty! Switching to #2!"
				MAG_1_EMPTY = true
                Get_Remote()
            elseif REMOTE_X == (MAG_X + 1) and REMOTE_Y == MAG_Y and not MAG_2_EMPTY then
                REMOTE_X = MAG_X + 2
				WARN_TEXT = "`4Magplant 2 is empty! Switching to #3!"
				MAG_2_EMPTY = true
                Get_Remote()
            elseif REMOTE_X == (MAG_X + 2) and REMOTE_Y == MAG_Y and not MAG_3_EMPTY then
                REMOTE_X = MAG_X
				REMOTE_Y = MAG_Y + 2
				WARN_TEXT = "`4Magplant 3 is empty! Switching to #4!"
				MAG_3_EMPTY = true
                Get_Remote()
            elseif REMOTE_X == (MAG_X) and REMOTE_Y ~= MAG_Y and not MAG_4_EMPTY then
                REMOTE_X = MAG_X + 1
				WARN_TEXT = "`4Magplant 4 is empty! Switching to #5!"
				MAG_4_EMPTY = true
                Get_Remote()
            elseif REMOTE_X == (MAG_X + 1) and REMOTE_Y ~= MAG_Y and not MAG_5_EMPTY then
                REMOTE_X = MAG_X + 2
				WARN_TEXT = "`4Magplant 5 is empty! Switching to #6!"
				MAG_5_EMPTY = true
                Get_Remote()
            elseif REMOTE_X == (MAG_X + 2) and REMOTE_Y ~= MAG_Y and not MAG_6_EMPTY then
                REMOTE_X = MAG_X
				REMOTE_Y = MAG_Y
				WARN_TEXT = "`4Magplant 6 is empty! Switching to #1!"
				MAG_6_EMPTY = true
                Get_Remote()
			elseif MAG_1_EMPTY and MAG_2_EMPTY and MAG_3_EMPTY and MAG_4_EMPTY and MAG_5_EMPTY and MAG_6_EMPTY and FindMagplants() then
				WARN_TEXT = "`4All magplants empty! Moving to the next 6 Magplants!"
				PNB_X = PNB_X + 3
				MAG_X = MAG_X + 3
				REMOTE_X = MAG_X
				REMOTE_Y = MAG_Y
				FindPath(PNB_X, PNB_Y)
				Sleep(1000)
				MAG_1_EMPTY = false
				MAG_2_EMPTY = false
				MAG_3_EMPTY = false
				MAG_4_EMPTY = false
				MAG_5_EMPTY = false
				MAG_6_EMPTY = false
				Get_Remote()
			
			elseif MAG_1_EMPTY and MAG_2_EMPTY and MAG_3_EMPTY and MAG_4_EMPTY and MAG_5_EMPTY and MAG_6_EMPTY and not FindMagplants() then
				WARN_TEXT = "`4All magplants empty! Resetting!"
				PNB_X = START_PNB_X
				PNB_Y = START_PNB_Y

				MAG_X = START_MAG_X
				MAG_Y = START_MAG_Y

				REMOTE_X = MAG_X
				REMOTE_Y = MAG_Y
				FindPath(PNB_X, PNB_Y)
				Sleep(1000)
				MAG_1_EMPTY = false
				MAG_2_EMPTY = false
				MAG_3_EMPTY = false
				MAG_4_EMPTY = false
				MAG_5_EMPTY = false
				MAG_6_EMPTY = false
				Get_Remote()

			end
			local packet = {}
			packet[0] = "OnTextOverlay"
			packet[1] = WARN_TEXT
			packet.netid = -1
			SendVarlist(packet)
            CHANGE_REMOTE = false
            Sleep(150)
        end

        SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|1\ncheck_bfg|1\ncheck_gems|"..TAKE_GEMS)
        Sleep(500)

        if os.time() - LAST_UPDATE >= WEBHOOK_DELAY then
            LAST_UPDATE = os.time()

            Sleep(250)
            Place(MAG_X, MAG_Y, 32)
            Sleep(250)
            Place(MAG_X + 1, MAG_Y, 32)
            Sleep(250)
            Place(MAG_X + 2, MAG_Y, 32)
            Sleep(250)
            Place(MAG_X, MAG_Y + 2, 32)
            Sleep(250)
            Place(MAG_X + 1, MAG_Y + 2, 32)
            Sleep(250)
            Place(MAG_X + 2, MAG_Y + 2, 32)
            Sleep(250)

            Update()
        end
    end
end

