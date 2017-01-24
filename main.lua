local Alphabirth = RegisterMod("Alphabirth Pack 2", 1)

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
local CRACKED_ROCK_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_costume_crackedrock.anm2")
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
-- use local ACTIVE_YOUR_ITEM = ItemID
local ACTIVE_MIRROR = Isaac.GetItemIdByName("Mirror")
local ACTIVE_CAULDRON = Isaac.GetItemIdByName("Cauldron")
local ACTIVE_SURGEON_SIMULATOR = Isaac.GetItemIdByName("Surgeon Simulator")

---------------------------------------
-- Passive Declaration
---------------------------------------
-- use PASSIVE_YOUR_ITEM = ItemID
local PASSIVE_CRACKED_ROCK = Isaac.GetItemIdByName("Cracked Rock")

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
    if cauldron_points >= 30 then
        local free_position = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 1, true)
        Isaac.Spawn(EntityType.ENTITY_PICKUP,
            PickupVariant.PICKUP_COLLECTIBLE,
            0,
            free_position,
            Vector(0,0),
            player)
        cauldron_points = cauldron_points - 30
    else
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
    end
    
    player:AnimateHappy()
end

---------------------------------------
-- Surgeon Simulator Logic
---------------------------------------
function Alphabirth:triggerSurgeonSimulator()
    local player = Isaac.GetPlayer(0)
    local spawnPos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 1, true)
    if player:GetHearts() == 2 then
        player:AddHearts(-1)
        Isaac.Spawn(5, 10, 2, spawnPos, Vector(0, 0), player)
    end
    if player:GetHearts() > 2 then
        player:AddHearts(-2)
        Isaac.Spawn(5, 10, 1, spawnPos, Vector(0, 0), player)
    end
    return true
end

----------------------------------------
-- Mirror Logic
----------------------------------------
function Alphabirth:triggerMirror()
	Isaac.DebugString("Mirror:")
    local player = Isaac.GetPlayer(0)

    -- Get room entities.
    local ents = Isaac.GetRoomEntities()

    -- Get number of entities, and generate a random number between 1 and the number of entities.
    local num_ents = #ents

    local rand_key = math.random(num_ents)

    -- Make sure the entity is an enemy, not a fire, and not a portal.
    -- Switch Isaac's position with the entity's position.
    -- Animate the teleportation.
    -- Further randomize the selection.
    for rand_key, entity in pairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy() and entity.Type ~= 306 then
        	local player_pos = player.Position
        	local entity_pos = entity.Position

        	player.Position = entity_pos
        	entity.Position = player_pos

        	player:AnimateTeleport()

        	rand_key = math.random(1, num_ents)
        end
    end
end

-------------------------------------------------------------------------------
---- PASSIVE ITEM LOGIC
-------------------------------------------------------------------------------
---------------------------------------
-- Cracked Rock Logic
---------------------------------------
function Alphabirth:triggerCrackedRockEffect(dmg_target, dmg_amount, dmg_source, dmg_dealer)
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(PASSIVE_CRACKED_ROCK) and dmg_source == 0 and dmg_target:IsActiveEnemy() then
        local upper_limit_luck_modifier = 100 - math.ceil(player.Luck * 1.5)
        if(math.random(1, upper_limit_luck_modifier) <= 10) then
            Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.SHOCKWAVE_RANDOM,
                0,            -- Entity Subtype
                dmg_target.Position,
                Vector(0, 0), -- Velocity
                player
            )
        end
    end
end

local function applyCrackedRockCache(player, cache_flag)
    if player:HasCollectible(PASSIVE_CRACKED_ROCK) and cache_flag == CacheFlag.CACHE_TEARCOLOR then
        player:AddNullCostume(CRACKED_ROCK_COSTUME)
        player.TearColor = Color(
            0.666, 0.666, 0.666,    -- RGB
            1, 		                -- Alpha
            0, 0, 0                 -- RGB Offset
        )
    end
end

local function handleCrackedRockSpawnChance()
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == 5 and entity.Variant == 100 and entity.SubType ==
        Isaac.GetItemIdByName("Small Rock") and entity.FrameCount == 1 then
            if math.random(3) == 1 then
                entity.SubVariant = PASSIVE_CRACKED_ROCK
            end
        end
    end
end

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
    local player = Isaac.GetPlayer(0)
    local game = Game()
    local room = game:GetRoom()
    if not player:HasCollectible(PASSIVE_CRACKED_ROCK) then
        handleCrackedRockSpawnChance()
    end
	for _, entity in ipairs(Isaac.GetRoomEntities()) do
		if entity.Type == EntityType.ENTITY_PICKUP and 
                entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and 
                entity.SubType == ACTIVE_CAULDRON then
			local sprite = entity:GetSprite()
            if cauldron_points <= 15 then
                sprite:ReplaceSpritesheet(1,"gfx/Items/Collectibles/collectible_cauldron1.png")
            elseif cauldron_points < 30 and cauldron_points > 15 then
                sprite:ReplaceSpritesheet(1,"gfx/Items/Collectibles/collectible_cauldron2.png")
            else
                sprite:ReplaceSpritesheet(1,"gfx/Items/Collectibles/collectible_cauldron3.png")
            end
			sprite:LoadGraphics()
		end
	end
end

function Alphabirth:cauldronUpdate()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(ACTIVE_CAULDRON) then
        local sprite = Sprite()
        sprite:Load("gfx/animations/animation_sprite_cauldron.anm2", true)
        if cauldron_points <= 10 then
            sprite:ReplaceSpritesheet(0,"gfx/Items/Collectibles/collectible_cauldron1.png")
        elseif cauldron_points <= 20 and cauldron_points > 10 then
            sprite:ReplaceSpritesheet(0,"gfx/Items/Collectibles/collectible_cauldron2.png")
        elseif cauldron_points < 30 and cauldron_points > 20 then
            sprite:ReplaceSpritesheet(0,"gfx/Items/Collectibles/collectible_cauldron3.png")
        else
            sprite:ReplaceSpritesheet(0,"gfx/Items/Collectibles/collectible_cauldron4.png")
        end
        
        sprite:LoadGraphics()
        sprite:Play("Idle", true)
        sprite.Offset = Vector(16,16)
        sprite:RenderLayer(0, Vector(0, 0))
    end
end

---------------------------------------
-- Callbacks
---------------------------------------
function Alphabirth:reset()
    cauldron_points = 0
end

function Alphabirth:evaluateCache(player, cache_flag)
    local player = Isaac.GetPlayer(0)
    applyCrackedRockCache(player, cache_flag)
end

-------------------
-- Active Handling
-------------------
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerCauldron, ACTIVE_CAULDRON)
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerSurgeonSimulator, ACTIVE_SURGEON_SIMULATOR)
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerMirror, ACTIVE_MIRROR)

-------------------
-- Passive Handling
-------------------

-------------------
-- Player Effects
-------------------

-------------------
-- Take Damage Updates
-------------------
Alphabirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Alphabirth.triggerCrackedRockEffect)

-------------------
-- Entity Handling
-------------------

-------------------
-- Mod Updates
-------------------

Alphabirth:AddCallback(ModCallbacks.MC_POST_UPDATE, Alphabirth.modUpdate)
Alphabirth:AddCallback(ModCallbacks.MC_POST_RENDER, Alphabirth.cauldronUpdate)
Alphabirth:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Alphabirth.reset)
Alphabirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Alphabirth.evaluateCache)
