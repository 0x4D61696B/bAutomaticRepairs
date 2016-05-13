-- =============================================================================
--  bAutoRepair
--    by: BurstBiscuit
-- =============================================================================

require "math"
require "table"
require "unicode"

require "lib/lib_ChatLib"
require "lib/lib_Debug"

Debug.EnableLogging(false)


-- =============================================================================
--  Variables
-- =============================================================================

local c_MaxDurability = 1000

local g_Enabled     = true
local g_RepairCost  = 0
local g_RepairList  = {}


-- =============================================================================
--  Functions
-- =============================================================================

function Notification(message)
    ChatLib.Notification({text = "[bAutoRepair] " .. tostring(message)})
end

function GetRepairCost(itemInfo)
    local durabilityPercent = 1 - (itemInfo.durability.current / c_MaxDurability)

    return Game.GetItemRepairCost(itemInfo.itemTypeId, durabilityPercent)
end


-- =============================================================================
--  Events
-- =============================================================================

function OnRepairResponse(args)
    Debug.Table("OnRepairResponse()", args)

    if (args.success) then
        Notification("All items have been repaired for " .. tostring(g_RepairCost) .. " Crystite.")
        g_RepairList = {}
    end
end

function OnTerminalAuthorized(args)
    Debug.Table("OnTerminalAuthorized()", args)

    if (g_Enabled and args.terminal_type == "GARAGE") then
        local itemIdList = Player.GetItemIdList("gear")
        g_RepairCost = 0
        g_RepairList = {}

        for _, itemGuid in pairs(itemIdList) do
            local itemInfo = Player.GetItemInfo(itemGuid)

            if (itemInfo and itemInfo.durability) then
                if (itemInfo.durability.current < c_MaxDurability) then
                    g_RepairCost = g_RepairCost + GetRepairCost(itemInfo)
                    table.insert(g_RepairList, itemInfo.itemId)
                end
            end
        end

        if (#g_RepairList > 0) then
            pcall(Player.RequestRepairItems, g_RepairList)
        end
    end
end

function OnTrackerUpdate(args)
    Debug.Table("OnTrackerUpdate()", args)

    if (not args.json) then
        return
    end

    local json = jsontotable(args.json)

    if (json.id and json.objectives and json.id == "mission_867") then
        Debug.Log("Repair tutorial mission found, checking objective status")
        g_Enabled = false

        for _, objective in pairs(json.objectives) do
            if (not objective.completed) then
                return
            end
        end

        Debug.Log("All objectives completed, enabling addon again")
        g_Enabled = true
    end
end
