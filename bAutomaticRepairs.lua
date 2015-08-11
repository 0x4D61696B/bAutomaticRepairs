-- =============================================================================
--  bAutomaticRepairs
--    by: BurstBiscuit
-- =============================================================================

require "math"
require "string"
require "table"
require "lib/lib_ChatLib"
require "lib/lib_Debug"

Debug.EnableLogging(false)


-- =============================================================================
--  Variables
-- =============================================================================

local c_MaxDurability = 1000
local itemIDs = {}
local repairCost = 0


-- =============================================================================
--  Functions
-- =============================================================================

function Notification(message)
    ChatLib.Notification({text = "[bAutomaticRepairs] " .. tostring(message)})
end

function GetRepairCost(itemInfo)
    local durabilityPercent = 1 - (itemInfo.durability.current / c_MaxDurability)
    
    return Game.GetItemRepairCost(itemInfo.itemTypeId, durabilityPercent)
end


-- =============================================================================
--  Events
-- =============================================================================

function OnRepairResponse(args)
    if (args.success) then
        Notification("All items have been repaired for " .. repairCost .. " Crystite.")
    end
end

function OnTerminalAuthorized(args)
    if (args.terminal_type == "GARAGE") then
        local itemList = Player.GetItemIdList("gear")
        itemIDs = {}
        repairCost = 0
        
        for _, itemGuid in pairs(itemList) do
            local itemInfo = Player.GetItemInfo(itemGuid)
            
            if (itemInfo and itemInfo.durability) then
                if (itemInfo.durability.current < c_MaxDurability) then
                    repairCost = repairCost + GetRepairCost(itemInfo)
                    table.insert(itemIDs, itemInfo.itemId)
                end
            end
        end
        
        if (#itemIDs > 0) then
            Player.RequestRepairItems(itemIDs)
        end
    end
end
