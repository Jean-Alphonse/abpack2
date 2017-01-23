Alphabirth = RegisterMod("Alphabirth Pack 2", 1)

---------------------------------------
-- Config
---------------------------------------

---------------------------------------
-- Initialize the RNG
---------------------------------------
math.randomseed(Random())
math.random();math.random();math.random();

---------------------------------------
-- Costume Declaration
---------------------------------------

---------------------------------------
-- Entity Flag Declaration
---------------------------------------
-- use FLAG_YOUR_FLAG = 1 << FlagID

---------------------------------------
-- Curse Declaration
---------------------------------------
-- use CURSE_YOUR_CURSE = 1 << CurseID

---------------------------------------
-- Active Declaration
---------------------------------------
-- use ACTIVE_YOUR_ITEM = ItemID
ACTIVE_CAULDRON = Isaac.GetItemIdByName("Cauldron")

---------------------------------------
-- Passive Declaration
---------------------------------------
-- use PASSIVE_YOUR_ITEM = ItemID

---------------------------------------
-- Trinket Declaration
---------------------------------------
-- use TRINKET_YOUR_ITEM = TrinketID

---------------------------------------
-- Variables that need to be loaded early
---------------------------------------

-------------------------------------------------------------------------------
---- ACTIVE ITEM LOGIC
-------------------------------------------------------------------------------
---------------------------------------
-- Cauldron Logic
---------------------------------------
local cauldron_points = 0
function Alphabirth:triggerCauldron()
    local player = Isaac.GetPlayer(0)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP then
            if entity.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
                if entity.Variant == PickupVariant.PICKUP_TRINKET then
                    cauldron_points = cauldron_points + 5
                else
                    cauldron_points = cauldron_points + 1
                end
                
                pickup_entity = entity:ToPickup()
                pickup_entity.Timeout = 1
            end
        end
    end
            
    while cauldron_points >= 30 do
        free_position = Isaac.GetFreeNearPosition(Game():GetRoom():GetCenterPos(),1)
        Isaac.Spawn(EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_COLLECTIBLE,
            0,
            player.Position,
            Vector(0,0),
            player)
        cauldron_points = cauldron_points - 30
    end
    
    return true
end

-------------------------------------------------------------------------------
---- PASSIVE ITEM LOGIC
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
---- TRINKET LOGIC
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
---- ENTITY LOGIC (Familiars, Enemies, Bosses)
-------------------------------------------------------------------------------

---------------------------------------
-- Post-Update Callback
---------------------------------------
function Alphabirth:modUpdate()
    return true
end

---------------------------------------
-- Callbacks
---------------------------------------
function Alphabirth:reset()
    cauldron_points = 0
end

-------------------
-- Active Handling
-------------------
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerCauldron, ACTIVE_CAULDRON)

-------------------
-- Passive Handling
-------------------

-------------------
-- Player Effects
-------------------

-------------------
-- Take Damage Updates
-------------------

-------------------
-- Entity Handling
-------------------

-------------------
-- Mod Updates
-------------------
Alphabirth:AddCallback(ModCallbacks.MC_POST_UPDATE, Alphabirth.modUpdate)
Alphabirth:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Alphabirth.reset)
