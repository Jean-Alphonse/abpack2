local Alphabirth = RegisterMod("Alphabirth Pack 2", 1)

---------------------------------------
-- Config
---------------------------------------
local starting_room_enabled = true

---------------------------------------
-- Initialize the RNG
---------------------------------------
math.randomseed(Random())
math.random();math.random();math.random();

---------------------------------------
-- Costume Declaration
---------------------------------------
local CRACKED_ROCK_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_costume_crackedrock.anm2")
local GLOOM_SKULL_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_costume_gloomskull.anm2")
local AIMBOT_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_costume_aimbot.anm2")
local CYBORG_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_transformation_cyborg.anm2")
local HEMOPHILIA_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_costume_hemophilia.anm2")

---------------------------------------
-- Entity Flag Declaration
---------------------------------------
-- use FLAG_YOUR_FLAG = 1 << FlagID

EntityFlag.FLAG_BLOODERFLY_TARGET = 1 << 37

---------------------------------------
-- Curse Declaration
---------------------------------------
-- use CURSE_YOUR_CURSE = 1 << CurseID
local CURSE_OF_THE_LONELY = 1 << (Isaac.GetCurseIdByName("Curse of the Lonely") - 1)

local function evalCurses(curse_flags)
    if curse_flags then
        local curse_roll = math.random(1, 7)
        if curse_roll == 7 then
            return CURSE_OF_THE_LONELY
        else
            --return curse_flags
        end
    end
end

local function triggerCurses(player)
    local game = Game()
    local level = game:GetLevel()
    if level:GetCurses() & CURSE_OF_THE_LONELY == CURSE_OF_THE_LONELY then
        for _,ent in ipairs(Isaac.GetRoomEntities()) do
            if ent.Type == EntityType.ENTITY_PICKUP and ent.Variant ~= 100 and player.Position:Distance(ent.Position) <= 35 then
                ent.Velocity = Vector((ent.Position.X - player.Position.X)/4, (ent.Position.Y - player.Position.Y)/4)
            end
        end
    end
end

Alphabirth:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, evalCurses)

---------------------------------------
-- Functions
---------------------------------------
local function findClosestEnemy(entity)
    local entities = Isaac.GetRoomEntities()
    local maxDistance = 999999
    local closestEntity
    for _, e in ipairs(entities) do
        if (entity.Position - e.Position):Length() <= maxDistance and e:IsVulnerableEnemy() and e ~= entity then
            closestEntity = e
            maxDistance = (entity.Position - e.Position):Length()
        end
    end
    return closestEntity
end

local function contains(table, value)
    for _, current_item in ipairs(table) do
       if current_item == value then
          return true
       end
    end

    return false
end

---------------------------------------
-- Active Declaration
---------------------------------------
-- use local ACTIVE_YOUR_ITEM = ItemID
local ACTIVE_MIRROR = Isaac.GetItemIdByName("Mirror")
local ACTIVE_CAULDRON = Isaac.GetItemIdByName("Cauldron")
local ACTIVE_SURGEON_SIMULATOR = Isaac.GetItemIdByName("Surgeon Simulator")
local ACTIVE_BIONIC_ARM = Isaac.GetItemIdByName("Bionic Arm")

---------------------------------------
-- Passive Declaration
---------------------------------------
-- use PASSIVE_YOUR_ITEM = ItemID
local PASSIVE_CRACKED_ROCK = Isaac.GetItemIdByName("Cracked Rock")
local PASSIVE_HEMOPHILIA = Isaac.GetItemIdByName("Hemophilia")
local PASSIVE_GLOOM_SKULL = Isaac.GetItemIdByName("Gloom Skull")
local PASSIVE_AIMBOT = Isaac.GetItemIdByName("Aimbot")
local PASSIVE_BLOODERFLY = Isaac.GetItemIdByName("Blooderfly")

---------------------------------------
-- Entity Variant Declaration
---------------------------------------

local ENTITY_VARIANT_BLOODERFLY = Isaac.GetEntityVariantByName("Blooderfly")
---------------------------------------
-- Trinket Declaration
---------------------------------------
-- use TRINKET_YOUR_ITEM = TrinketID

---------------------------------------
-- Variables that need to be loaded early
---------------------------------------

local cyborg_pool = {
    CollectibleType.COLLECTIBLE_TECHNOLOGY,
    CollectibleType.COLLECTIBLE_TECH_X,
    CollectibleType.COLLECTIBLE_TECHNOLOGY_2,
    CollectibleType.COLLECTIBLE_TECH_5,
    PASSIVE_AIMBOT,
    ACTIVE_BIONIC_ARM
}

local cyborg_progress = {}

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
        player:AnimateHappy()
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

                    Isaac.Spawn(
                        EntityType.ENTITY_EFFECT,
                        EffectVariant.POOF01,
                        0,            -- Entity Subtype
                        pickup_entity.Position,
                        Vector(0, 0), -- Velocity
                        player
                    )

                    player:AnimateHappy()
                end
            end
        end
    end
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

----------------------------------------
-- Bionic Arm Logic
----------------------------------------

local bionicDamage = 200
function Alphabirth:triggerBionicArm()
    local ents = Isaac.GetRoomEntities()
    for _, e in ipairs(Isaac.GetRoomEntities()) do
        if e:IsVulnerableEnemy() then
            if e.HitPoints - bionicDamage <= 0 then
                e:Kill()
            else
                e.HitPoints = e.HitPoints - bionicDamage
            end
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
        if entity.Type == EntityType.ENTITY_PICKUP and
                entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and
                entity.SubType == Isaac.GetItemIdByName("The Small Rock") and
                entity.FrameCount == 1 then
            if math.random(1,3) == 1 then
                local pickup_entity = entity:ToPickup()
                pickup_entity:Morph(EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_COLLECTIBLE,
                    PASSIVE_CRACKED_ROCK,
                    false)
            end
        end
    end
end

---------------------------------------
-- Hemophilia Logic
---------------------------------------

local explosionRadius = 4
local numberOfTears = 15
local tears = {}

function Alphabirth:triggerHemophilia(dmg_target, dmg_amount, dmg_source, dmg_flags)
    local player = Isaac.GetPlayer(0)
    if dmg_target:IsActiveEnemy() and dmg_target.HitPoints <= dmg_amount and player:HasCollectible(PASSIVE_HEMOPHILIA) and math.random(1,3) == 1 then
        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.PLAYER_CREEP_RED,0,dmg_target.Position,Vector(0, 0),player)
        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.LARGE_BLOOD_EXPLOSION,0,dmg_target.Position,Vector(0, 0),player)
        for i=1, numberOfTears do
            tears[i] = player:FireTear(dmg_target.Position, Vector(math.random(-explosionRadius, explosionRadius),math.random(-explosionRadius, explosionRadius)), false, false, true)
            tears[i]:ChangeVariant(1)
            tears[i].TearFlags = 0
            tears[i].Scale = 1
            tears[i].Height = -60
            tears[i].FallingSpeed = -4 + math.random()*-4
            tears[i].FallingAcceleration = math.random() + 0.5
        end
        dmg_target:BloodyExplosion()
        tears = {}
    end
end

local function applyHemophiliaCache(pl, fl)
    if pl:HasCollectible(PASSIVE_HEMOPHILIA) and fl == CacheFlag.CACHE_TEARCOLOR then
        pl:AddNullCostume(HEMOPHILIA_COSTUME)
        pl.TearColor = Color(0.6,0,0,1,0,0,0)
    end
end


---------------------------------------
-- Gloom Skull Logic
---------------------------------------

local function applyGloomSkullCache(player, cache_flag)
    if cache_flag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(PASSIVE_GLOOM_SKULL) then
        player.Damage = player.Damage + 1.5
        Game():GetLevel():AddCurse(Isaac.GetCurseIdByName("Curse of Darkness"), false)
        player:AddNullCostume(GLOOM_SKULL_COSTUME)
        maxOutDevilDeal()
    end
end
local didMax = false

local function maxOutDevilDeal()
    didMax = true
end

---------------------------------------
-- Cyborg Logic
---------------------------------------

local hasCyborg = false
function applyCyborgCache(player, flag)
    local charge = player:GetActiveCharge()
    if hasCyborg and flag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + (charge/6)
    elseif hasCyborg and flag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + (charge/4)
    elseif hasCyborg and flag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + (charge/24)
    elseif hasCyborg and flag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + (charge/24)
    end
end

---------------------------------------
-- Aimbot Logic
---------------------------------------

local aimbotSpeedMod = 3
function handleAimbot ()
    local player = Isaac.GetPlayer(0)
    for _, e in ipairs(Isaac.GetRoomEntities()) do
        if e.Type == 2 and player:HasCollectible(PASSIVE_AIMBOT) then
            local enemy = findClosestEnemy(e)
            if enemy.Position:Distance(e.Position) <= 100 then
                e.Velocity = Vector(-(e.Position.X - enemy.Position.X)/aimbotSpeedMod, -(e.Position.Y - enemy.Position.Y)/aimbotSpeedMod)
                e:ToTear().TearFlags = 1
            end
        end
    end
end

function applyAimbotCache(p, f)
    if f == CacheFlag.CACHE_TEARCOLOR and p:HasCollectible(PASSIVE_AIMBOT) then
        p:AddNullCostume(AIMBOT_COSTUME)
    end
end

-------------------------------------------------------------------------------
---- TRINKET LOGIC
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
---- ENTITY LOGIC (Familiars, Enemies, Bosses)
-------------------------------------------------------------------------------
---------------------------------------
-- Blooderfly Logic
---------------------------------------
function Alphabirth:onBlooderflyInit(_,familiar)
    if familiar == nil then
        Isaac.DebugString("NIL FAMILIAR")
    else
        Isaac.DebugString("Blooderfly Spawned")
    end
end

local blooderfly
local target_entity
local has_target
function Alphabirth:blooderflyUpdate(_,_)
    local player = Isaac.GetPlayer(0)

    if player:HasCollectible(PASSIVE_BLOODERFLY) then
        local entities = Isaac.GetRoomEntities();
        local valid_entities = {}
        local has_target = false

        for _, entity in ipairs(entities) do
            if entity:IsVulnerableEnemy() and entity:IsActiveEnemy(false) then
                if entity:HasEntityFlags(EntityFlag.FLAG_BLOODERFLY_TARGET) then
                    has_target = true
                end

                local enemy = entity:ToNPC()
                if enemy then
                    valid_entities[#valid_entities + 1] = entity
                end
            end
        end

        if #valid_entities > 0 and has_target == false then
            local target_entity_index = 1
            if #valid_entities > 1 then
                target_entity_index = math.random(#valid_entities)
            end
            target_entity = valid_entities[target_entity_index]
            target_entity:AddEntityFlags(EntityFlag.FLAG_BLOODERFLY_TARGET)
        end

        if Game():GetRoom():IsClear() then
            blooderfly:FollowPosition(player.Position)
        else
            blooderfly:FollowPosition(target_entity.Position)
        end
    end
end

function Alphabirth:triggerBlooderfly(entity, damage_amount, damage_source, damage_flags)
    local player = Isaac.GetPlayer(0)
    if entity:IsActiveEnemy() and entity.HitPoints <= damage_amount * 1.2 and entity:HasEntityFlags(EntityFlag.FLAG_BLOODERFLY_TARGET) then
        for i=1, 3 do
            local tear = player:FireTear(entity.Position, Vector(math.random(-4, 4),math.random(-4, 4)), false, false, true)
            tear:ChangeVariant(1)
            tear.TearFlags = 0
            tear.Scale = 1
            tear.Height = -60
            tear.FallingSpeed = -4 + math.random()*-4
            tear.FallingAcceleration = math.random() + 0.5
        end
        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.PLAYER_CREEP_RED,0,entity.Position,Vector(0, 0),player)
    end
    if entity:IsActiveEnemy() and entity:HasEntityFlags(EntityFlag.FLAG_BLOODERFLY_TARGET) then
        entity.HitPoints = entity.HitPoints - damage_amount * 0.2
    end
end

local function applyBlooderflyCache(player, cache_flag)
    if cache_flag == CacheFlag.CACHE_FAMILIARS and player:HasCollectible(PASSIVE_BLOODERFLY) then
        blooderfly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, ENTITY_VARIANT_BLOODERFLY, 0, player.Position, Vector(0,0), player):ToFamiliar()
    end
end

---------------------------------------
-- Post-Update Callback
---------------------------------------
local currentRoom = Game():GetRoom()
local activeCharge
local canDrop = false

function Alphabirth:modUpdate()
    local player = Isaac.GetPlayer(0)
    local game = Game()
    local room = game:GetRoom()
    local frame = game:GetFrameCount()

    if not player:HasCollectible(PASSIVE_CRACKED_ROCK) then
        handleCrackedRockSpawnChance()
    end
    triggerCurses(player)

    -- Reset variables each run
    if frame == 1 then
        cauldron_points = 0
        didMax = false
        hasCyborg = false
        cyborg_progress = {}
    end

    -- Max Deal with the Devil chance
    if didMax == true and Game():GetRoom():GetFrameCount() == 1 then
        Isaac.GetPlayer(0):GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_GOAT_HEAD, false)
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
    --Cyborg Transformation Detector
    if Game():GetFrameCount() % 60 == 0 then
        if not hasCyborg then
            for _, item in ipairs(cyborg_pool) do
                if player:HasCollectible(item) and contains(cyborg_progress, item) == false then
                    table.insert(cyborg_progress, item)
                end
            end
            if #cyborg_progress >= 3 then
                hasCyborg = true
                player:AddNullCostume(CYBORG_COSTUME)
                player:AddCacheFlags(CacheFlag.CACHE_ALL)
                player:EvaluateItems()
            end
        end
    end

    --Bionic Arm Extra Logic
    local charge = player:GetActiveCharge()
    if player:HasCollectible(ACTIVE_BIONIC_ARM) and charge ~= activeCharge then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end

    --Cyborg Extra Logic
    if hasCyborg and charge ~= activeCharge then
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end

    activeCharge = charge
    handleAimbot()
    if hasCyborg then
        local room = Game():GetRoom()
        if room:GetFrameCount() == 1 and room:IsFirstVisit() and room:IsAmbushActive() == true then
            canDrop = true
        end
        if canDrop and room:IsFirstVisit() and room:IsAmbushActive() == false then
            canDrop = false
            if math.random(1,10) == 1 then
                Isaac.Spawn(5,90,0,room:GetCenterPos(), Vector(0,0), player)
            end
        end
    end

    -- Spawn items in starting room
    if starting_room_enabled then
        if frame == 1 then
            local new_items = {
                    ACTIVE_CAULDRON, ACTIVE_BIONIC_ARM, ACTIVE_MIRROR, ACTIVE_SURGEON_SIMULATOR,
                    PASSIVE_AIMBOT, PASSIVE_BLOODERFLY, PASSIVE_CRACKED_ROCK, PASSIVE_GLOOM_SKULL,
                    PASSIVE_HEMOPHILIA
            }
            local row = 31
            for i, item in ipairs(new_items) do
                -- Usable grid indexes start at 16 with 16 per "row"
                -- This places them in the second row of the room
                Isaac.DebugString("Spawning: " .. item)
                local position = room:GetGridPosition(i + row)
                if item < 500 then
                    Isaac.Spawn(
                                EntityType.ENTITY_PICKUP,       -- Type
                                PickupVariant.PICKUP_TRINKET,   -- Variant
                                item,                           -- Subtype
                                position,                       -- Position
                                Vector(0, 0),                   -- Velocity
                                player                          -- Spawner
                            )
                else
                    Isaac.Spawn(EntityType.ENTITY_PICKUP,
                                PickupVariant.PICKUP_COLLECTIBLE,
                                item,
                                position,
                                Vector(0, 0),
                                player
                            )
                end

                if i % 11 == 0 then
                    row = row + 19
                end
            end
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
function Alphabirth:evaluateCache(player, cache_flag)
    local player = Isaac.GetPlayer(0)
    applyGloomSkullCache(player, cache_flag)
    applyCrackedRockCache(player, cache_flag)
    applyAimbotCache(player, cache_flag)
    applyBlooderflyCache(player, cache_flag)
    applyHemophiliaCache(player, cache_flag)

    local charge = player:GetActiveCharge()
    if player:HasCollectible(ACTIVE_BIONIC_ARM) and cache_flag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + (charge/6)
    end
    applyCyborgCache(player, cache_flag)
end

-------------------
-- Active Handling
-------------------
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerCauldron, ACTIVE_CAULDRON)
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerSurgeonSimulator, ACTIVE_SURGEON_SIMULATOR)
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerMirror, ACTIVE_MIRROR)
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerBionicArm, ACTIVE_BIONIC_ARM)


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
Alphabirth:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Alphabirth.triggerHemophilia)

-------------------
-- Entity Handling
-------------------
Alphabirth:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Alphabirth.onBlooderflyInit, ENTITY_VARIANT_BLOODERFLY)
Alphabirth:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Alphabirth.blooderflyUpdate, ENTITY_VARIANT_BLOODERFLY)
-------------------
-- Mod Updates
-------------------

Alphabirth:AddCallback(ModCallbacks.MC_POST_UPDATE, Alphabirth.modUpdate)
Alphabirth:AddCallback(ModCallbacks.MC_POST_RENDER, Alphabirth.cauldronUpdate)
Alphabirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Alphabirth.evaluateCache)
