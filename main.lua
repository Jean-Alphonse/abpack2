local Alphabirth = {}
Alphabirth_mod = RegisterMod("Alphabirth Pack 2", 1)

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
local ABYSS_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_costume_abyss.anm2")
local BIRTH_CONTROL_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_costume_birthcontrol.anm2")
local JUDAS_FEZ_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_costume_judasfez.anm2")
local HOT_COALS_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_costume_hotcoals.anm2")
local TECH_ALPHA_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_costume_techalpha.anm2")
local QUILL_FEATHER_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_costume_quillfeather.anm2")
local DAMNED_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_transformation_damned.anm2")
local HOARDER_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_costume_hoarder.anm2")

local ENDOR_BODY_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/players/animation_character_endorbody.anm2")
local ENDOR_HEAD_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/players/animation_character_endorhead.anm2")
---------------------------------------
-- Entity Flag Declaration
---------------------------------------
-- use FLAG_YOUR_FLAG = 1 << FlagID
local FLAG_VOID = 1 << 37

local FLAG_SPIRIT_EYE_SHOT = 1 << 38
local FLAG_HEMOPHILIA_SHOT = 1 << 39
local FLAG_ABYSS_SHOT = 1 << 42
local FLAG_QUILL_FEATHER_SHOT = 1 << 43

local FLAG_HEMOPHILIA_APPLIED = 1 << 40
local FLAG_QUILL_FEATHER_APLLIED = 1 << 41

local FLAG_MORPH_TRIED = 1 << 44 --For entities with a nil FrameCount value

---------------------------------------
-- Tear Flag Easy Access
---------------------------------------
local TEAR_FLAGS = {
    FLAG_PIERCING = 1 << 1,
    FLAG_HOMING = 1 << 2,
    FLAG_IPECAC = 1 << 12
}

---------------------------------------
-- Curse Declaration
---------------------------------------
-- use CURSE_YOUR_CURSE = 1 << CurseID
local CURSE_OF_THE_LONELY = 1 << (Isaac.GetCurseIdByName("Curse of the Lonely") - 1)

local function evalCurses(curse_flags)
    if curse_flags then
        local curse_roll = math.random(1, 16)
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

Alphabirth_mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, evalCurses)

---------------------------------------
-- Functions
---------------------------------------

local function radToDeg (rad)
	return ((rad * 180) / math.pi)
end

local function degToRad (deg)
	return ((deg * math.pi) / 180)
end
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

local function chooseRandomTarget()
    local entities = Isaac.GetRoomEntities()
    local valid_entities = {}

    for _, entity in ipairs(entities) do
        if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and entity.Type ~= 306 then
            if entity:ToNPC() then
                valid_entities[#valid_entities + 1] = entity
            end
        end
    end

    if #valid_entities > 0 then
        local index = 1
        if #valid_entities > 1 then
            index = math.random(#valid_entities)
        end
        return valid_entities[index]
    end
    return nil
end

local function playSound(sfx, vol, delay, loop, pitch) --SFX: SoundEffect.SOUND_SPIDER_COUGH vol: float delay: integer loop:boolean pitch: float
    local player = Isaac.GetPlayer(0)
    local sound_entity = Isaac.Spawn(EntityType.ENTITY_FLY, 0, 0, player.Position, Vector(0,0), nil):ToNPC()
    sound_entity:PlaySound(sfx, vol, delay, loop, pitch)
    sound_entity:Remove()
end

local function colorRawData(color)
    return color.R, color.G, color.B, color.A, color.RO, color.GO, color.BO
end

local function directionToDegree(direction)
    if direction >= 0 then
        if direction == Direction.LEFT then
            direction = 4
        end
        direction = direction - 1
        return direction*90
    end
    return 0
end

local function degreeToDirection(angle)
    while angle / 360 > 1 do
        angle = angle - 360
    end
    if angle > 269 then
        return angle/90 - 3
    end
    return angle/90 + 1
end

local function directionToRad(direction)
    return directionToDegree(direction) * math.pi / 180
end

local function radToDirection(angle)
    while angle > math.pi * 2 do
        angle = angle - math.pi * 2
    end
    if angle > (math.pi * 3) / 2 then
        return angle/(math.pi / 2) - 3
    end
    return angle/(math.pi / 2) + 1
end

local function atan2(a,b)
    return degToRad(Vector(a, b):GetAngleDegrees())
end

local function fireProjectiles(numProjectiles, projectileSpreadDegrees, shotSpeed, shotVariant, posFired, posTarget, parentEntity)
    local base_direction = (posTarget - posFired):Normalized()
    local base_degrees = base_direction:GetAngleDegrees()
    local projectiles = {}
    if numProjectiles % 2 ~= 0 then
        local current_degree_offset = base_degrees + ((numProjectiles / 2) - 1) * projectileSpreadDegrees
        for i = 1, numProjectiles do
            local shot_motion = Vector.FromAngle(current_degree_offset) * shotSpeed
            projectiles[i] = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,
                shotVariant,
                0,
                posFired,
                shot_motion,
                parentEntity)
            current_degree_offset = current_degree_offset - projectileSpreadDegrees
        end
    else
        local clockwise_degree_offset = base_degrees - projectileSpreadDegrees
        local counterclockwise_degree_offset = base_degrees + projectileSpreadDegrees
        for i =1, numProjectiles do
            local shot_motion
            if i % 2 == 0 then
                shot_motion = Vector.FromAngle(clockwise_degree_offset) * shotSpeed
                clockwise_degree_offset = clockwise_degree_offset - projectileSpreadDegrees
            else
                shot_motion = Vector.FromAngle(counterclockwise_degree_offset) * shotSpeed
                counterclockwise_degree_offset = counterclockwise_degree_offset + projectileSpreadDegrees
            end

            projectiles[i] = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,
                shotVariant,
                0,
                posFired,
                shot_motion,
                parentEntity)
        end
    end

    return projectiles
end

function hasbit(x, p)
    return (x & p)
end

function setbit(x, p)
    return x | p
end

---------------------------------------
-- Active Declaration
---------------------------------------
-- use local ACTIVE_YOUR_ITEM = ItemID
local ACTIVE_MIRROR = Isaac.GetItemIdByName("Mirror")
local ACTIVE_CAULDRON = Isaac.GetItemIdByName("Cauldron")
local ACTIVE_SURGEON_SIMULATOR = Isaac.GetItemIdByName("Surgeon Simulator")
local ACTIVE_BIONIC_ARM = Isaac.GetItemIdByName("Bionic Arm")
local ACTIVE_ALASTORS_CANDLE = Isaac.GetItemIdByName("Alastor's Candle")
local ACTIVE_BLOOD_DRIVE = Isaac.GetItemIdByName("Blood Drive")
local ACTIVE_CHALICE_OF_BLOOD = Isaac.GetItemIdByName("Chalice of Blood")
local ACTIVE_BLACKLIGHT = Isaac.GetItemIdByName("Blacklight")

---------------------------------------
-- Passive Declaration
---------------------------------------
-- use PASSIVE_YOUR_ITEM = ItemID
local PASSIVE_CRACKED_ROCK = Isaac.GetItemIdByName("Cracked Rock")
local PASSIVE_HEMOPHILIA = Isaac.GetItemIdByName("Hemophilia")
local PASSIVE_GLOOM_SKULL = Isaac.GetItemIdByName("Gloom Skull")
local PASSIVE_AIMBOT = Isaac.GetItemIdByName("Aimbot")
local PASSIVE_BLOODERFLY = Isaac.GetItemIdByName("Blooderfly")
local PASSIVE_TECH_ALPHA = Isaac.GetItemIdByName("Tech Alpha")
local PASSIVE_BRUNCH = Isaac.GetItemIdByName("Brunch")
local PASSIVE_BIRTH_CONTROL = Isaac.GetItemIdByName("Birth Control")
local PASSIVE_SPIRIT_EYE = Isaac.GetItemIdByName("Spirit Eye")
local PASSIVE_ABYSS = Isaac.GetItemIdByName("Abyss")
local PASSIVE_INFESTED_BABY = Isaac.GetItemIdByName("Infested Baby")
local PASSIVE_JUDAS_FEZ = Isaac.GetItemIdByName("Judas' Fez")
local PASSIVE_HOT_COALS = Isaac.GetItemIdByName("Hot Coals")
local PASSIVE_QUILL_FEATHER = Isaac.GetItemIdByName("Quill Feather")
local PASSIVE_HOARDER = Isaac.GetItemIdByName("Hoarder")

---------------------------------------
-- Entity Variant Declaration
---------------------------------------
-- Familiars
local ENTITY_VARIANT_BLOODERFLY = Isaac.GetEntityVariantByName("Blooderfly")
local ENTITY_VARIANT_SPIRIT_EYE = Isaac.GetEntityVariantByName("Spirit Eye")
local ENTITY_VARIANT_ABYSS_TEAR = Isaac.GetEntityVariantByName("Abyss Tear")
local ENTITY_VARIANT_INFESTED_BABY = Isaac.GetEntityVariantByName("Infested Baby")

-- Enemies
local ENTITY_VARIANT_BRIMSTONE_HOST = Isaac.GetEntityVariantByName("Brimstone Host")

local ENTITY_TYPE_ZYGOTE = Isaac.GetEntityTypeByName("Zygote")
local ENTITY_VARIANT_ZYGOTE = Isaac.GetEntityVariantByName("Zygote")

local ENTITY_TYPE_LOBOTOMY = Isaac.GetEntityTypeByName("Lobotomy")
local ENTITY_VARIANT_LOBOTOMY = Isaac.GetEntityVariantByName("Lobotomy")

local ENTITY_TYPE_HEADLESS_ROUND_WORM = Isaac.GetEntityVariantByName("Headless Round Worm")
local ENTITY_VARIANT_HEADLESS_ROUND_WORM = Isaac.GetEntityVariantByName("Headless Round Worm")

local ENTITY_TYPE_ROUND_TRIO = Isaac.GetEntityTypeByName("Round Worm Trio")
local ENTITY_VARIANT_ROUND_TRIO = Isaac.GetEntityVariantByName("Round Worm Trio")

local ENTITY_TYPE_FOUR_EYE = Isaac.GetEntityTypeByName("4 Eyed Crawler")
local ENTITY_VARIANT_FOUR_EYE = Isaac.GetEntityVariantByName("4 Eyed Crawler")

local ENTITY_TYPE_DIP_ULCER = Isaac.GetEntityTypeByName("Dip Ulcer")
local ENTITY_VARIANT_DIP_ULCER = Isaac.GetEntityVariantByName("Dip Ulcer")

local ENTITY_TYPE_LEECH_CREEP = Isaac.GetEntityTypeByName("Leech Creep")
local ENTITY_VARIANT_LEECH_CREEP = Isaac.GetEntityVariantByName("Leech Creep")

local ENTITY_TYPE_KAMIKAZE_FLY = Isaac.GetEntityTypeByName("Kamikaze Fly")
local ENTITY_VARIANT_KAMIKAZE_FLY = Isaac.GetEntityVariantByName("Kamikaze Fly")

-- Effects
local ENTITY_VARIANT_ALASTORS_FLAME = Isaac.GetEntityVariantByName("Alastor's Flame")
local ENTITY_VARIANT_CHALICE_OF_BLOOD = Isaac.GetEntityVariantByName("Chalice of Blood")
---------------------------------------
-- Trinket Declaration
---------------------------------------
-- use TRINKET_YOUR_ITEM = TrinketID

---------------------------------------
-- Pocket Items Declaration
---------------------------------------
-- use POCKETITEM_YOUR_NAME = PocketItemID

local POCKETITEM_NAUDIZ = Isaac.GetCardIdByName("Naudiz")

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

local damned_pool = {
    PASSIVE_GLOOM_SKULL,
    ACTIVE_CHALICE_OF_BLOOD,
    CollectibleType.COLLECTIBLE_PENTAGRAM,
    CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW,
    CollectibleType.COLLECTIBLE_PACT,
    CollectibleType.COLLECTIBLE_MARK
}

local damned_progress = {}

local birthControl_pool = {
    PASSIVE_INFESTED_BABY,
    PASSIVE_BLOODERFLY,
    PASSIVE_SPIRIT_EYE,
    CollectibleType.COLLECTIBLE_BROTHER_BOBBY,
    CollectibleType.COLLECTIBLE_SISTER_MAGGY,
    CollectibleType.COLLECTIBLE_LITTLE_CHUBBY,
    CollectibleType.COLLECTIBLE_ROBO_BABY,
    CollectibleType.COLLECTIBLE_LITTLE_CHAD,
    CollectibleType.COLLECTIBLE_LITTLE_STEVEN,
    CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL,
    CollectibleType.COLLECTIBLE_DEMON_BABY,
    CollectibleType.COLLECTIBLE_DEAD_BIRD,
    CollectibleType.COLLECTIBLE_BUM_FRIEND,
    CollectibleType.COLLECTIBLE_GHOST_BABY,
    CollectibleType.COLLECTIBLE_HARLEQUIN_BABY,
    CollectibleType.COLLECTIBLE_RAINBOW_BABY,
    CollectibleType.COLLECTIBLE_ABEL,
    CollectibleType.COLLECTIBLE_DRY_BABY,
    CollectibleType.COLLECTIBLE_ROBO_BABY_2,
    CollectibleType.COLLECTIBLE_ROTTEN_BABY,
    CollectibleType.COLLECTIBLE_HEADLESS_BABY,
    CollectibleType.COLLECTIBLE_LIL_BRIMSTONE,
    CollectibleType.COLLECTIBLE_LIL_HAUNT,
    CollectibleType.COLLECTIBLE_DARK_BUM,
    CollectibleType.COLLECTIBLE_PUNCHING_BAG,
    CollectibleType.COLLECTIBLE_MONGO_BABY,
    CollectibleType.COLLECTIBLE_INCUBUS,
    CollectibleType.COLLECTIBLE_SWORN_PROTECTOR,
    CollectibleType.COLLECTIBLE_FATES_REWARD,
    CollectibleType.COLLECTIBLE_CHARGED_BABY,
    CollectibleType.COLLECTIBLE_BUMBO,
    CollectibleType.COLLECTIBLE_LIL_GURDY,
    CollectibleType.COLLECTIBLE_KEY_BUM,
    CollectibleType.COLLECTIBLE_SERAPHIM,
    CollectibleType.COLLECTIBLE_FARTING_BABY,
    CollectibleType.COLLECTIBLE_SUCCUBUS,
    CollectibleType.COLLECTIBLE_LIL_LOKI,
    CollectibleType.COLLECTIBLE_HUSHY,
    CollectibleType.COLLECTIBLE_LIL_MONSTRO,
    CollectibleType.COLLECTIBLE_KING_BABY,
    CollectibleType.COLLECTIBLE_BIG_CHUBBY,
    CollectibleType.COLLECTIBLE_ACID_BABY
}

local isEndor = false

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
                if entity.Variant ~= PickupVariant.PICKUP_COLLECTIBLE and
                        entity.Variant ~= PickupVariant.PICKUP_BIGCHEST and
                        entity.Variant ~= PickupVariant.PICKUP_BED and
                        entity.Variant ~= PickupVariant.PICKUP_TROPHY then
                    if entity.Variant == PickupVariant.PICKUP_TRINKET then
                        cauldron_points = cauldron_points + 5
                    elseif entity.Variant == PickupVariant.PICKUP_COIN then
                        if entity.SubType == CoinSubType.COIN_DIME then
                            cauldron_points = cauldron_points + 10
                        elseif entity.SubType == CoinSubType.COIN_DOUBLEPACK then
                            cauldron_points = cauldron_points + 2
                        elseif entity.SubType == CoinSubType.COIN_NICKEL or
                                entity.SubType == CoinSubType.COIN_STICKYNICKEL then
                            cauldron_points = cauldron_points + 5
                        else
                            cauldron_points = cauldron_points + 1
                        end
                    elseif entity.Variant == PickupVariant.PICKUP_BOMB then
                        if entity.SubType == BombSubType.BOMB_DOUBLEPACK then
                            cauldron_points = cauldron_points + 2
                        elseif entity.SubType == BombSubType.BOMB_GOLDEN then
                            cauldron_points = cauldron_points + 3
                        else
                            cauldron_points = cauldron_points + 1
                        end
                    elseif entity.Variant == PickupVariant.PICKUP_KEY then
                        if entity.SubType == KeySubType.KEY_DOUBLEPACK then
                            cauldron_points = cauldron_points + 2
                        elseif entity.SubType == KeySubType.KEY_GOLDEN then
                            cauldron_points = cauldron_points + 3
                        else
                            cauldron_points = cauldron_points + 1
                        end
                    elseif entity.Variant == PickupVariant.PICKUP_ETERNALCHEST or
                            entity.Variant == PickupVariant.PICKUP_LOCKEDCHEST or
                            entity.Variant == PickupVariant.PICKUP_BOMBCHEST then
                        cauldron_points = cauldron_points + 3
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
        if entity:IsActiveEnemy() and
                entity.Type ~= 306 and -- Portals
                entity.Type ~= 304 and -- The Thing
                entity.Type ~= EntityType.ENTITY_RAGE_CREEP and
                entity.Type ~= EntityType.ENTITY_BLIND_CREEP and
                entity.Type ~= EntityType.ENTITY_WALL_CREEP then
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

----------------------------------------
-- Alastor's Candle Logic
----------------------------------------
local flames = {}
local number_of_fires = 2
local flames_exist = false
function Alphabirth:triggerAlastorsCandle()
    local player = Isaac.GetPlayer(0)
    --Remove previous flames (if any)
    if flames_exist then
        for i=1, number_of_fires do
            flames[i]:Die()
            Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.POOF01,
                0,            -- Entity Subtype
                flames[i].Position,
                Vector(0, 0), -- Velocity
                nil
            )
        end
    end
    --Spawn two flames
    for i=1, number_of_fires do
        flames[i] = Isaac.Spawn(
            3,
            239,
            0,
            player.Position,
            Vector(0,0),
            player
        )
    end
    flames_exist = true
    return true
end

local distance = 100
local modifier
local function handleAlastorsCandleFlames()
    local player = Isaac.GetPlayer(0)
    --Spin the flames
    if distance == 100 then
        modifier = 1
    end
    if distance == 30 then
        modifier = -1
    end

    for i=1, number_of_fires do
        if(i % 2 == 0) then
            local x_velocity = math.cos((Game():GetFrameCount()/10)+math.pi)*distance
            local y_velocity = math.sin((Game():GetFrameCount()/10)+math.pi)*distance
            flames[i].Position = Vector(player.Position.X + x_velocity, player.Position.Y + y_velocity)
        else
            local x_velocity = math.cos(Game():GetFrameCount()/10)*distance
            local y_velocity = math.sin(Game():GetFrameCount()/10)*distance
            flames[i].Position = Vector(player.Position.X + x_velocity, player.Position.Y + y_velocity)
        end
    end

    distance = distance - modifier
    for i=1, number_of_fires do
        --Add Fear to Close Entitie
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity:IsVulnerableEnemy() and entity.Position:Distance(flames[i].Position) < 55 and math.random(20) == 1 then
                entity:AddFear(EntityRef(flames[i]), 60)
            end
        end
    end
end

---------------------------------------
-- Blood Drive Logic
---------------------------------------

local bloodDriveTimesUsed = 0

local function handleBloodDrive()
    local currentRoom = Game():GetRoom()
    local player = Isaac.GetPlayer(0)
    if bloodDriveTimesUsed > 0 then
        for _,ent in ipairs(Isaac.GetRoomEntities()) do
            if ent:IsVulnerableEnemy() and ent.FrameCount == 1 then
                ent.MaxHitPoints = ent.MaxHitPoints - ent.MaxHitPoints/(12/bloodDriveTimesUsed)
                ent.HitPoints = ent.MaxHitPoints
                for i=1, bloodDriveTimesUsed do
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, ent.Position, Vector(0,0),player)
                end
            end
        end
    end
end

function Alphabirth:triggerBloodDrive()
    local player = Isaac.GetPlayer(0)
    local total_hearts = player:GetMaxHearts()
    if total_hearts > 2 and player:GetPlayerType() ~= PlayerType.PLAYER_XXX then
        bloodDriveTimesUsed = bloodDriveTimesUsed + 1
        player:AddMaxHearts(-2)
        Game():Darken(1, 8)
        player:AnimateSad()
    end
end

---------------------------------------
-- Chalice of Blood Logic
---------------------------------------
local chalice
local chalice_souls = 0
local soul_limit = 15
local CHALICE_STATS = {
    DAMAGE = 1,
    SHOTSPEED = 0
}
local function applyChaliceOfBloodCache(player, cache_flag)
    if player:HasCollectible(ACTIVE_CHALICE_OF_BLOOD) then
        if cache_flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * CHALICE_STATS.DAMAGE
        end
        if cache_flag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + CHALICE_STATS.SHOTSPEED
        end
    end
end

function Alphabirth:triggerChaliceOfBlood()
    local player = Isaac.GetPlayer(0)
    local room = Game():GetRoom()

    if chalice_souls < soul_limit then

        if chalice ~= nil then
           chalice:Remove()
        end

        chalice = Isaac.Spawn(
            3,
            ENTITY_VARIANT_CHALICE_OF_BLOOD,
            0,
            player.Position,
            Vector(0,0),
            player
        )
    else
        CHALICE_STATS.DAMAGE = 2
        CHALICE_STATS.SHOTSPEED = 0.4
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
        player:EvaluateItems()
        chalice_souls = 0
        playSound(SoundEffect.SOUND_GULP, 0.5, 0, false, 1)
    end
    return true
end

local function handleChaliceOfBlood()
    local player = Isaac.GetPlayer(0)
    local room = Game():GetRoom()

    -- Remove Chalice if room is clear
    if room:GetFrameCount() == 1 then
        CHALICE_STATS.DAMAGE = 1
        CHALICE_STATS.SHOTSPEED = 0
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
        player:EvaluateItems()
    end

    if room:IsClear() and chalice ~= nil then
        Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.POOF01,
            0,            -- Entity Subtype
            chalice.Position,
            Vector(0, 0), -- Velocity
            nil
        )
        chalice:Remove()
        chalice = nil
    end

    if chalice ~= nil then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_PLAYER and entity.Position:Distance(chalice.Position) <= 140 then
                Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.PLAYER_CREEP_RED,0,player.Position,Vector(0, 0),player)
            end
            local entity_is_close = entity.Position:Distance(chalice.Position) <= 140
            if entity:IsDead() and entity:ToNPC() and entity_is_close and not entity:IsBoss() then
                playSound(SoundEffect.SOUND_SUMMONSOUND, 0.5, 0, false, 0.8)
                Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    EffectVariant.POOF02,
                    0,            -- Entity Subtype
                    entity.Position,
                    Vector(0, 0), -- Velocity
                    nil
                )
                chalice_souls = chalice_souls + 1
            end
        end
    end

    if chalice_souls >= soul_limit and chalice ~= nil then
        playSound(SoundEffect.SOUND_SUMMONSOUND, 0.5, 0, false, 0.9)
        Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.POOF01,
            0,            -- Entity Subtype
            chalice.Position,
            Vector(0, 0), -- Velocity
            nil
        )
        chalice:Remove()
        chalice = nil
    end
end

function Alphabirth:chaliceOfBloodUpdate()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(ACTIVE_CHALICE_OF_BLOOD) then
        local sprite = Sprite()
        sprite:Load("gfx/animations/animation_sprite_chaliceofblood.anm2", true)
        if chalice_souls <= 5 then
            sprite:ReplaceSpritesheet(0,"gfx/Items/Collectibles/collectible_chaliceofblood.png")
        elseif chalice_souls <= 10 then
            sprite:ReplaceSpritesheet(0,"gfx/Items/Collectibles/collectible_chaliceofblood2.png")
        elseif chalice_souls < 15 then
            sprite:ReplaceSpritesheet(0,"gfx/Items/Collectibles/collectible_chaliceofblood3.png")
        else
            sprite:ReplaceSpritesheet(0,"gfx/Items/Collectibles/collectible_chaliceofblood4.png")
        end

        sprite:LoadGraphics()
        sprite:Play("Idle", true)
        sprite.Offset = Vector(16,16)
        sprite:RenderLayer(0, Vector(0, 0))
    end
end

----------------------------------------
-- Blacklight Logic
----------------------------------------

local blacklightUses = 0
local darkenCooldown = 0
local timesTillMax = 20
function Alphabirth:triggerBlacklight()
    if blacklightUses < timesTillMax then
        blacklightUses = blacklightUses + 1
        darkenCooldown = 0
        for i, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity:IsVulnerableEnemy() then
                if entity.HitPoints - 40 <= 0 then
                    entity:Kill()
                else
                    entity.HitPoints = entity.HitPoints - 40
                end
            end
        end
        return true
    end
end


local function handleBlacklight()
    if blacklightUses > 0 and darkenCooldown == 0 then
        Game():Darken(3 - (blacklightUses/((timesTillMax)/2)), 200)
        darkenCooldown = 195
    end
    if darkenCooldown > 0 then
        darkenCooldown = darkenCooldown - 1
    end
end

-------------------------------------------------------------------------------
---- PASSIVE ITEM LOGIC
-------------------------------------------------------------------------------
---------------------------------------
-- Brunch "Logic"
---------------------------------------
local has_brunch_health = false
local function applyBrunchCache(player, cache_flag)
    if cache_flag == CacheFlag.CACHE_TEARCOLOR and player:HasCollectible(PASSIVE_BRUNCH) then
        player.Color = Color(0,1,0,1,0,0,0)
        if not has_brunch_health then
            player:AddMaxHearts(4)
            player:AddHearts(4)
            has_brunch_health = true
        end
    end
end

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
                EffectVariant.SHOCKWAVE,
                0,            -- Entity Subtype
                dmg_target.Position,
                Vector(0, 0), -- Velocity
                player
            ):ToEffect():SetRadii(5,10)
            Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.SHOCKWAVE,
                0,            -- Entity Subtype
                dmg_target.Position,
                Vector(0, 0), -- Velocity
                player
            ):ToEffect():SetRadii(2,8)
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
-- Tech Alpha Logic
---------------------------------------
local function handleTechAlpha(player)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local entity_will_shoot = nil
        local roll_max = 60 - player.Luck * 2

        if roll_max < 30 then
            roll_max = 30
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
            roll_max = roll_max * 2
        end

        if entity.Type == EntityType.ENTITY_TEAR and not entity:HasEntityFlags(FLAG_HEMOPHILIA_SHOT) then
            entity_will_shoot = true
        elseif entity.Type == EntityType.ENTITY_BOMBDROP then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
                if entity:ToBomb().IsFetus then
                    entity_will_shoot = true
                end
            end
        elseif entity.Type == EntityType.ENTITY_KNIFE then
            if entity:ToKnife().IsFlying then
                entity_will_shoot = true
            end
        elseif entity.Type == EntityType.ENTITY_LASER then
            if entity:ToLaser():IsCircleLaser() then
                entity_will_shoot = true
            end
        end

        if entity_will_shoot then
            local laser_roll = math.random(1,roll_max)
            if laser_roll == 1 then
                local closest_enemy = nil
                local previous_distance = nil
                for _, enemy in ipairs(Isaac.GetRoomEntities()) do
                    if enemy:IsActiveEnemy(false) and enemy:IsVulnerableEnemy() then
                        local distance_to_enemy = entity.Position:Distance(enemy.Position)
                        if not previous_distance then
                            closest_enemy = enemy
                            previous_distance = distance_to_enemy
                        elseif distance_to_enemy  < previous_distance then
                            closest_enemy = enemy
                            previous_distance = distance_to_enemy
                        end
                    end
                end

                if closest_enemy then
                    local direction_vector = closest_enemy.Position - entity.Position
                    direction_vector = direction_vector:Normalized() * (player.ShotSpeed * 13)
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
                        player:FireTechXLaser(entity.Position, direction_vector, 30)
                    else
                        player:FireTechLaser(entity.Position, 0, direction_vector, false, false)
                    end
                end
            end
        end
    end
end

local function applyTechAlphaCache ()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(PASSIVE_TECH_ALPHA) then
        player:AddNullCostume(TECH_ALPHA_COSTUME)
    end
end

---------------------------------------
-- ABYSS Logic
---------------------------------------
function Alphabirth:triggerAbyss(damaged_entity, damage_amount, damage_flag, damage_source, invincible_frames)
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(PASSIVE_ABYSS) then
        local damaged_npc = damaged_entity:ToNPC()
        if damaged_npc then
            if damaged_entity:IsActiveEnemy(false) and
                    damaged_entity:IsVulnerableEnemy() and not
                    damaged_npc:IsBoss() and
                    damage_source.Entity:HasEntityFlags(FLAG_ABYSS_SHOT) then
                local entity_has_void = false
                for _, entity in ipairs(Isaac.GetRoomEntities()) do
                    if entity:HasEntityFlags(FLAG_VOID) then
                        entity_has_void = true
                    end
                end

                if not entity_has_void then
                    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT,
                        EffectVariant.PULLING_EFFECT,
                        0,
                        damaged_entity.Position,
                        damaged_entity.Velocity,
                        damaged_entity
                    )
                    effect = effect:ToEffect()
                    effect:FollowParent(damaged_entity)
                    effect:SetTimeout(1000)
                    damaged_entity:GetData()["status_timer"] = 240
                    damaged_entity:AddEntityFlags(FLAG_VOID)
                    damaged_entity:AddEntityFlags(EntityFlag.FLAG_FREEZE)
                    damaged_entity:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                end
            end
        end
    end
end

local function handleAbyss()
    local player = Isaac.GetPlayer(0)
    local luck_modifier = 80 - player.Luck * 3
    if luck_modifier < 2 then
        luck_modifier = 2
    end

    local roll = math.random(1,luck_modifier)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_TEAR and entity.Variant ~= ENTITY_VARIANT_ABYSS_TEAR and entity.FrameCount == 1 and roll < 11 then
            entity:GetSprite():ReplaceSpritesheet(0, 'gfx/animations/effects/sheet_tears_abyss.png')
            entity:GetSprite():LoadGraphics()
            entity:AddEntityFlags(FLAG_ABYSS_SHOT)
        end

        local is_void_entity = false
        if entity:HasEntityFlags(FLAG_VOID) then
            is_void_entity = true
            if colorRawData(entity.Color) ~= colorRawData(Color(0,0,0,1,0,0,0)) then
                entity:GetData()["clr"] = entity.Color
                entity.Color = Color(0,0,0,1,0,0,0)
            end

            for _, entity2 in ipairs(Isaac.GetRoomEntities()) do
                local entity2_npc = entity2:ToNPC()
                if entity2_npc then
                    if entity2:IsActiveEnemy(false) and
                            entity2:IsVulnerableEnemy() and not
                            entity2_npc:IsBoss() and not
                            entity2:HasEntityFlags(FLAG_VOID) then
                        local direction_vector = entity.Position - entity2.Position
                        direction_vector = direction_vector:Normalized() * 3
                        entity2.Velocity = entity2.Velocity + direction_vector
                    elseif entity2.Type == EntityType.ENTITY_PICKUP and
                            entity2.Variant ~= PickupVariant.PICKUP_COLLECTIBLE and
                            entity2.Variant ~= PickupVariant.PICKUP_BIGCHEST and
                            entity2.Variant ~= PickupVariant.PICKUP_BED then
                        local direction_vector = entity.Position - entity2.Position
                        direction_vector = direction_vector:Normalized() * 3
                        entity2.Velocity = entity2.Velocity + direction_vector
                    end
                end
            end

            entity:GetData()["status_timer"] = entity:GetData()["status_timer"] - 1
            if entity:GetData()["status_timer"] == 0 then
                entity.Color = entity:GetData()["clr"]
                entity:ClearEntityFlags(FLAG_VOID)
                entity:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
                entity:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            end
        end

        if entity.Type == EntityType.ENTITY_EFFECT and
                entity.Variant == EffectVariant.PULLING_EFFECT and not
                entity.Parent:HasEntityFlags(FLAG_VOID) then
            entity:Remove()
        end
    end
end

local function applyAbyssCache(player, cache_flag)
    if player:HasCollectible(PASSIVE_ABYSS) then
        player:AddNullCostume(ABYSS_COSTUME)
    end
end

---------------------------------------
-- Hemophilia Logic
---------------------------------------

local explosionRadius = 4
local tear_cap = 15
local tear_min = 4
local tears = {}

function Alphabirth:triggerHemophilia(dmg_target, dmg_amount, dmg_source, dmg_flags)
    local player = Isaac.GetPlayer(0)
    if dmg_target:IsActiveEnemy() and
            dmg_target.HitPoints <= dmg_amount and
            player:HasCollectible(PASSIVE_HEMOPHILIA) and
            math.random(1,3) == 1 then
        if not dmg_target:HasEntityFlags(FLAG_HEMOPHILIA_APPLIED) then
            local numberOfTears = 8 + player.Luck
            local tear_offset = math.random(-2,2)
            numberOfTears = numberOfTears + tear_offset
            if numberOfTears > tear_cap then
                numberOfTears = tear_cap
            elseif numberOfTears < tear_min then
                numberOfTears = tear_min
            end

            for i=1, numberOfTears do
                tears[i] = player:FireTear(dmg_target.Position,
                    Vector(math.random(-explosionRadius, explosionRadius),
                    math.random(-explosionRadius, explosionRadius)),
                    false,
                    false,
                    true
                )
                tears[i]:ChangeVariant(1)
                tears[i].TearFlags = 0
                tears[i].Scale = 1
                tears[i].Height = -60
                tears[i].FallingSpeed = -4 + math.random()*-4
                tears[i].FallingAcceleration = math.random() + 0.5
                tears[i]:AddEntityFlags(FLAG_HEMOPHILIA_SHOT)
            end

            dmg_target:BloodExplode()
            dmg_target:AddEntityFlags(FLAG_HEMOPHILIA_APPLIED)
            tears = {}
        end
    end
end

local function applyHemophiliaCache(pl, fl)
    if pl:HasCollectible(PASSIVE_HEMOPHILIA) and fl == CacheFlag.CACHE_TEARCOLOR then
        pl:AddNullCostume(HEMOPHILIA_COSTUME)
        pl.TearColor = Color(35,1,1,1,0,0,0)
    end
end


---------------------------------------
-- Gloom Skull Logic
---------------------------------------

local didMax = false

local function maxOutDevilDeal()
    didMax = true
end

local function applyGloomSkullCache(player, cache_flag)
    if cache_flag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(PASSIVE_GLOOM_SKULL) then
        player.Damage = player.Damage + 1.5
        Game():GetLevel():AddCurse(Isaac.GetCurseIdByName("Curse of Darkness"), false)

        maxOutDevilDeal()
    elseif cache_flag == CacheFlag.CACHE_TEARCOLOR and player:HasCollectible(PASSIVE_GLOOM_SKULL) then
        player:AddNullCostume(GLOOM_SKULL_COSTUME)
    end
end

---------------------------------------
-- Judas' Fez Logic
---------------------------------------
local health_reduction_applied = false
local function applyJudasFezCache(player, cache_flag)
    if cache_flag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(PASSIVE_JUDAS_FEZ) then
        player.Damage = player.Damage * 1.35
        if not health_reduction_applied then
            local hearts = player:GetMaxHearts() - 2
            player:AddMaxHearts(hearts * -1)
            player:AddSoulHearts(hearts)
            health_reduction_applied = true
        end
    end
    if cache_flag == CacheFlag.CACHE_TEARCOLOR and player:HasCollectible(PASSIVE_JUDAS_FEZ) then
        player:AddNullCostume(JUDAS_FEZ_COSTUME)
    end
end

local combat_rooms_visited = 0
local function handleJudasFez()
    local player = Isaac.GetPlayer(0)
    local room = Game():GetRoom()
    if room:IsFirstVisit() and not room:IsClear() and room:GetFrameCount() == 1 then
       combat_rooms_visited = combat_rooms_visited + 1
       if combat_rooms_visited == 3 then
          player:UseCard(Card.CARD_DEVIL)
          combat_rooms_visited = 0
       end
    end
end


---------------------------------------
-- Hot Coals Logic
---------------------------------------
local dmg_modifier = 1
local frame_count = 0
local function applyHotCoalsUpdate(player, cache_flag)
    if player:HasCollectible(PASSIVE_HOT_COALS) and cache_flag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage * dmg_modifier
    elseif player:HasCollectible(PASSIVE_HOT_COALS) and cache_flag == CacheFlag.CACHE_TEARCOLOR then
        player:AddNullCostume(HOT_COALS_COSTUME)
    end
end

local function handleHotCoals()
    local player = Isaac.GetPlayer(0)
    local direction = player:GetMovementVector()
    if (direction:Length() == 0.0) then
        dmg_modifier = 0.8
        frame_count = 0
    else
        dmg_modifier = 1.4
        trail = Isaac.Spawn(EntityType.ENTITY_EFFECT,
            EffectVariant.PLAYER_CREEP_BLACKPOWDER ,
            1,
            player.Position,
            Vector(0, 0),
            player
        ):ToEffect()

        trail:SetTimeout(15)
        trail:SetColor(Color(0.5,0,0,0.5,100,100,100), 0, 0, false, false)

        frame_count = frame_count + 1
        if frame_count == 150 then
            Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.POOF01,
                0,
                player.Position,
                Vector(0, 0),
                player
            )

            flame = Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.RED_CANDLE_FLAME,
                0,
                player.Position,
                Vector(0,0),
                player
            ):ToEffect()
            frame_count = 0
        end
    end
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    player:EvaluateItems()
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
-- Damned Logic
---------------------------------------

local has_damned = false
local damned_health_applied = false
local damned_has_respawned = false
local function applyDamnedCache(player, cache_flag)
    if cache_flag == CacheFlag.CACHE_FLYING and has_damned then
        player.CanFly = true
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

---------------------------------------
-- Birth Control Logic
---------------------------------------

local birthControlStats = {
    HP = 0,
    Damage = 0,
    MoveSpeed = 0,
    ShotSpeed = 0,
    Luck = 0,
    Range = 0
}

local function birthControlUpdate()
    local player = Isaac.GetPlayer(0)
    for _,item in ipairs(birthControl_pool) do
        if player:HasCollectible(item) and player:HasCollectible(PASSIVE_BIRTH_CONTROL) then
            player:RemoveCollectible(item)
            local roll = math.random(1,6)
            if roll == 1 then
                birthControlStats.Damage = birthControlStats.Damage + (math.random(2, 8) /10)
            elseif roll == 2 then
                birthControlStats.MoveSpeed = birthControlStats.MoveSpeed + (math.random(1, 3) /10)
            elseif roll == 3 then
                birthControlStats.ShotSpeed = birthControlStats.ShotSpeed + (math.random(1, 3) /10)
            elseif roll == 4 then
                birthControlStats.Luck = birthControlStats.Luck + (math.random(10, 20) /10)
            elseif roll == 5 then
                birthControlStats.Range = birthControlStats.Range + (math.random(5, 10) /10)
            elseif roll == 6 then
                birthControlStats.HP = birthControlStats.HP + 2
                player:AddMaxHearts(2, true)
            end
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
        end
    end
end

local function applyBirthControlCache (pl, fl)
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(PASSIVE_BIRTH_CONTROL) then
        player:AddNullCostume(BIRTH_CONTROL_COSTUME)
        if fl == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + birthControlStats.Damage
        end
        if fl == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + birthControlStats.MoveSpeed
        end
        if fl == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + birthControlStats.ShotSpeed
        end
        if fl == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + birthControlStats.Luck
        end
        if fl == CacheFlag.CACHE_RANGE then
            player.TearFallingSpeed = player.TearFallingSpeed + birthControlStats.Range
        end
    end
end

---------------------------------------
-- Quill Feather Logic
---------------------------------------

local function applyQuillFeatherCache(player, flag)
    if Isaac.GetPlayer(0):HasCollectible(PASSIVE_QUILL_FEATHER) and flag == CacheFlag.CACHE_TEARCOLOR then
        Isaac.GetPlayer(0):AddNullCostume(QUILL_FEATHER_COSTUME)
    end
end

local quillFeatherNumberOfTears = 15
local function handleQuillFeather()
    local player = Isaac.GetPlayer(0)
    local chance = 5 + player.Luck * 2
    for _,e in ipairs(Isaac.GetRoomEntities()) do
        if e.Type == EntityType.ENTITY_TEAR and
                math.random(1,50) < chance and not
                e:HasEntityFlags(FLAG_QUILL_FEATHER_APLLIED) and
                e.FrameCount == 1 then
            e.Color = Color(0,0,0,1,0,0,0)
            e:AddEntityFlags(FLAG_QUILL_FEATHER_SHOT)
            local tear_entity = e:ToTear()
            tear_entity:ChangeVariant(TearVariant.CUPID_BLUE)
            tear_entity.TearFlags = setbit(tear_entity.TearFlags, TEAR_FLAGS.FLAG_PIERCING)
        end
    end
end

function Alphabirth:triggerQuillFeather(dmg_target, dmg_amount, dmg_flags, dmg_source)
    local player = Isaac.GetPlayer(0)
    if dmg_source.Entity:HasEntityFlags(FLAG_QUILL_FEATHER_SHOT) then
        for i=1,quillFeatherNumberOfTears do
            local direction_vector = dmg_source.Entity.Velocity
            local angle = 30
            local random_angle = math.rad(math.random(-math.floor(angle), math.floor(angle)))
            local cos_angle = math.cos(random_angle)
            local sin_angle = math.sin(random_angle)
            local shot_direction = Vector(cos_angle * direction_vector.X - sin_angle * direction_vector.Y,
                sin_angle * direction_vector.X + cos_angle * direction_vector.Y
            )
            local magnitude = {0.8,0.9,1,1.1,1.2}
            local shot_vector = shot_direction:__mul(magnitude[math.random(#magnitude)*player.ShotSpeed])

            tears[i] = player:FireTear(dmg_source.Position, shot_vector, false, false, true)
            tears[i].Height = -20
            tears[i].TearFlags = setbit(tears[i].TearFlags, TEAR_FLAGS.FLAG_PIERCING)
            tears[i]:ChangeVariant(TearVariant.CUPID_BLUE)
            tears[i].Color = Color(0,0,0,1,0,0,0)
            tears[i]:AddEntityFlags(FLAG_QUILL_FEATHER_APLLIED)
        end
        dmg_source.Entity:Remove()
    end
end

---------------------------------------
-- Hoarder Logic
---------------------------------------
local hoarderDamage = 0
local ratio = 1/25 --1 dmg up for 25 consumables

local function handleHoarder()
    local player = Isaac.GetPlayer(0)
    local consumables = player:GetNumCoins() + player:GetNumBombs() + player:GetNumKeys()
    if consumables * ratio ~= hoarderDamage then
        hoarderDamage = consumables * ratio
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end
end

local function applyHoarderCache(player, cache_flag)
    if player:HasCollectible(PASSIVE_HOARDER) and cache_flag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + hoarderDamage
    elseif player:HasCollectible(PASSIVE_HOARDER) and cache_flag == CacheFlag.CACHE_TEARCOLOR then
        player:AddNullCostume(HOARDER_COSTUME)
    end
end

-------------------------------------------------------------------------------
---- TRINKET LOGIC
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
---- POCKET ITEMS LOGIC
-------------------------------------------------------------------------------

---------------------------------------
-- Naudiz Logic
---------------------------------------

function Alphabirth:triggerNaudizEffect()
    local player = Isaac.GetPlayer(0)
    local coins = player:GetNumCoins()
    local bombs = player:GetNumBombs()
    local keys = player:GetNumKeys()
    local consumables = {coins, bombs, keys}
    local max = 99
    local toGive = 1
    for i=1, #consumables do
        if consumables[i] < max then
            max = consumables[i]
            toGive = i
        end
    end
    if toGive == 1 then
        player:AddCoins(10)
    elseif toGive == 2 then
        player:AddBombs(10)
    elseif toGive == 3 then
        player:AddKeys(10)
    end
    return true
end

-------------------------------------------------------------------------------
---- ENTITY LOGIC (Familiars, Enemies, Bosses)
-------------------------------------------------------------------------------
---------------------------------------
-- Leech Creep Logic
---------------------------------------
function Alphabirth:onWallCreepUpdate(creep)
    if creep.Variant == ENTITY_VARIANT_LEECH_CREEP then
        if creep.State == NpcState.STATE_ATTACK then
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if entity.Type == EntityType.ENTITY_PROJECTILE and
                    entity.Variant == 0 and
                    entity.SpawnerType == ENTITY_TYPE_LEECH_CREEP and
                    entity.SpawnerVariant == ENTITY_VARIANT_LEECH_CREEP then

                    creep:GetData()["SpawnFly"] = true
                    creep:GetData()["SpawnPos"] = entity.Position
                    creep:GetData()["SpawnVel"] = entity.Velocity
                    entity:Remove()
                end
            end
        end
        if creep:GetData()["SpawnFly"] and creep:GetSprite():GetFrame() == 10 then
            Isaac.Spawn(EntityType.ENTITY_DART_FLY, 0, 0, creep:GetData()["SpawnPos"], creep:GetData()["SpawnVel"], creep)
            creep:GetData()["SpawnFly"] = false
        end
    elseif not creep:HasEntityFlags(FLAG_MORPH_TRIED) then
        if math.random(7) == 1 then
            creep:ToNPC():Morph(creep.Type, ENTITY_VARIANT_LEECH_CREEP, 0, 0)
        end
        creep:AddEntityFlags(FLAG_MORPH_TRIED)
    end
end

---------------------------------------
-- 4 Eyed Crawler Logic
---------------------------------------
function Alphabirth:onCrawlerUpdate(night)
    if night.Variant == ENTITY_VARIANT_FOUR_EYE then
        local sprite = night:GetSprite()

        if sprite:GetFrame() == 38 then -- Attack Frame
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if entity.Type == EntityType.ENTITY_PROJECTILE and
                        entity.Variant == 0 and
                        entity.SpawnerType == ENTITY_TYPE_FOUR_EYE and
                        entity.SpawnerVariant == ENTITY_VARIANT_FOUR_EYE then

                    -- night:GetData()["TargetPos"] = night:GetPlayerTarget().Position
                    night:GetData()["TearVariant"] = entity.Variant
                    night:GetData()["CanShoot"] = true
                    night:GetData()["ShotCooldown"] = 0

                    entity:Remove()
                end
            end
        end

        if night:GetData()["CanShoot"] then
            if night:GetData()["ShotCooldown"] >= 8 then
                night:GetData()["CanShoot"] = false
            elseif night:GetData()["ShotCooldown"] % 2 == 0 then
                fireProjectiles(1, 0, 12, night:GetData()["TearVariant"], night.Position, night:GetPlayerTarget().Position, night)
            end
        end
        night:GetData()["ShotCooldown"] = night:GetData()["ShotCooldown"] + 1
    elseif not night:HasEntityFlags(FLAG_MORPH_TRIED) then
        if math.random(5) == 1 then
            night:ToNPC():Morph(night.Type, ENTITY_VARIANT_FOUR_EYE, 0, 0)
        end
        night:AddEntityFlags(FLAG_MORPH_TRIED)
    end
end

---------------------------------------
-- Dip Ulcer Logic
---------------------------------------
function Alphabirth:onUlcerUpdate(ulcer)
    if ulcer.Variant == ENTITY_VARIANT_DIP_ULCER then
        local ulcer_sprite = ulcer:GetSprite() -- 42

        if ulcer_sprite:GetFrame() == 42 then
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if entity.Type == EntityType.ENTITY_DART_FLY and
                        entity.SpawnerType == EntityType.ENTITY_ULCER and
                        entity.SpawnerVariant == ENTITY_VARIANT_DIP_ULCER then
                    local type = math.random(0,1)
                    entity:ToNPC():Morph(EntityType.ENTITY_DIP, type, 0, 0)
                end
            end
        end
    elseif not ulcer:HasEntityFlags(FLAG_MORPH_TRIED) then
        if math.random(1,4) == 1 then
            ulcer:ToNPC():Morph(ulcer.Type, ENTITY_VARIANT_DIP_ULCER, 0, 0)
        end
        ulcer:AddEntityFlags(FLAG_MORPH_TRIED)
    end
end

---------------------------------------
-- Round Worm Trio Logic
---------------------------------------
function Alphabirth:onRoundWormUpdate(worm)
    -- Handle Round Worm Trio Logic
    if worm.Variant == ENTITY_VARIANT_ROUND_TRIO then -- It's a Trio Worm!
        local worm_sprite = worm:GetSprite()

        if worm_sprite:GetFrame() == 38 then -- Attack Frame
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if entity.Type == EntityType.ENTITY_PROJECTILE and
                        entity.Variant == 0 and
                        entity.SpawnerType == EntityType.ENTITY_ROUND_WORM and
                        entity.SpawnerVariant == ENTITY_VARIANT_ROUND_TRIO then

                    local target = worm:GetPlayerTarget()
                    local projectiles = fireProjectiles(3, 15, 8, entity.Variant, entity.Position, target.Position, worm)
                    entity:Remove()
                end
            end
        end
        -- Handle Round Worm Trio Spawning
    elseif not worm:HasEntityFlags(FLAG_MORPH_TRIED) then
        if math.random(5) == 1 then
            worm:ToNPC():Morph(worm.Type, ENTITY_VARIANT_ROUND_TRIO, 0, 0)
        end
        worm:AddEntityFlags(FLAG_MORPH_TRIED)
    end
end

---------------------------------------
-- Host Logic
---------------------------------------
function Alphabirth:onHostUpdate(host)
    local player = host:GetPlayerTarget()
    if host.Variant >= 200 then
        if host.State == NpcState.STATE_ATTACK then
            if host.StateFrame == 27 then -- Approximate attack frame.
                if host.Variant == ENTITY_VARIANT_BRIMSTONE_HOST then
                    player_saved_position = host:GetData()[0]
                    local direction_vector = (player_saved_position - host.Position):Normalized()
                    local direction_angle = direction_vector:GetAngleDegrees()
                    local brimstone_laser = EntityLaser.ShootAngle(1, host.Position, direction_angle, 15, Vector(0,-10), host)
                    brimstone_laser.DepthOffset = 200
                end

                for _, entity in ipairs(Isaac.GetRoomEntities()) do
                    if entity.Type == EntityType.ENTITY_PROJECTILE and
                            entity.Variant == 0 and
                            entity.SpawnerType == EntityType.ENTITY_HOST and
                            entity.SpawnerVariant >= 200 then
                        entity:Remove()
                    end
                end
            elseif host.StateFrame == 20 then -- Attack the position the player was in earlier.
                host:GetData()[0] = player.Position
            end
        elseif host.State == NpcState.STATE_SPECIAL then
            local host_sprite = host:GetSprite()
            if not host_sprite:IsPlaying("Bombed") then
                host_sprite:Play("Bombed", true)
            end

            if host.StateFrame == 15 then
                host.State = NpcState.STATE_IDLE
            end
        end
    elseif host.FrameCount == 1 then
        local level = Game():GetLevel()
        local stage = level:GetAbsoluteStage()
        local spawnroll = math.random(1,3)
        if spawnroll == 1 then
            Isaac.DebugString(tostring(stage))
            local canreplace = false
            if stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE3_2 then
                canreplace = true
            elseif stage == LevelStage.STAGE5 and not level:IsAltStage() then
                canreplace = true
            end

            if canreplace then
                Isaac.Spawn(EntityType.ENTITY_HOST,
                    ENTITY_VARIANT_BRIMSTONE_HOST,
                    0,
                    host.Position,
                    host.Velocity,
                    host)
                host:Remove()
            end
        end
    end
end

function Alphabirth:triggerHostTakeDamage(dmg_target, dmg_amount, dmg_flags, dmg_source)
    if dmg_target.Variant >= 200 then
        local host = dmg_target:ToNPC()
        Isaac.DebugString(host.State)
        if host.State ~= NpcState.STATE_ATTACK and dmg_flags == DamageFlag.DAMAGE_EXPLOSION then
            host.State = NpcState.STATE_SPECIAL
            host.StateFrame = 0
            host.ProjectileCooldown = 30
            return false
        end

        if host.State == NpcState.STATE_IDLE or host.State == NpcState.STATE_SPECIAL then
            return false
        end
    end
end

---------------------------------------
-- Zygote Logic
---------------------------------------

function Alphabirth:onEmbryoUpdate(entity)
    if entity.FrameCount > 1 or math.random(1, 3) ~= 1 then
        return
    end
    -- Only one Zygote can exist in a room
    local entities = Isaac.GetRoomEntities()
    for i=1, #entities do
        local room_entity = entities[i]
        if room_entity.Type == ENTITY_TYPE_ZYGOTE and room_entity.Variant == ENTITY_VARIANT_ZYGOTE then
            return
        end
    end
    entity:Morph(ENTITY_TYPE_ZYGOTE, ENTITY_VARIANT_ZYGOTE, 0, 0)
end

function Alphabirth:onZygoteUpdate(zygote)
    if zygote.Variant == ENTITY_VARIANT_ZYGOTE then
        local data = zygote:GetData()
        if zygote.FrameCount == 1 then
            if not data.gen then
                data.gen = 1
            end
            data.targetVel = Vector(0, 0)
        end
        local sprite = zygote:GetSprite()
        if sprite:IsPlaying("Walk Neutral") then
            if data.gen < 4 and sprite:GetFrame() == 23 and math.random(1,4) == 1 then
                sprite:Play("Walk Happy", true)
            end
            if sprite:GetFrame() == 0 then
                data.targetVel = (Isaac.GetRandomPosition() - zygote.Position):Normalized()*3
            end
        elseif sprite:IsPlaying("Walk Happy") then
            if sprite:GetFrame() == 23 then
                sprite:Play("Split", true)
            end
        elseif sprite:IsPlaying("Split") then
            if sprite:IsEventTriggered("Split") then
                local clone = Isaac.Spawn(zygote.Type, zygote.Variant, zygote.SubType, zygote.Position + Vector(-7, 0), Vector(0, 0), zygote)
                clone:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                local cloneSprite = clone:GetSprite()
                cloneSprite:Play("Clone", true)
                local power = 20
                local yVel = math.random()*power*2 - power
                zygote.Position = zygote.Position + Vector(8, 0)
                zygote.Velocity = zygote.Velocity + Vector(power, yVel)
                clone.Velocity = Vector(-power, -yVel)
                data.gen = data.gen + 1
                clone:GetData().gen = data.gen
                clone.HitPoints = zygote.HitPoints
            end
            if sprite:GetFrame() == 23 then
                data.done = true
                sprite:Play("Walk Neutral", true)
            end
        elseif sprite:IsPlaying("Clone") then
            if sprite:GetFrame() == 23 then
                sprite:Play("Walk Neutral", true)
            end
        else
            sprite:Play("Walk Neutral", true)
        end
        if sprite:IsEventTriggered("Landed") then
            data.targetVel = Vector(0, 0)
            zygote:PlaySound(SoundEffect.SOUND_GOOATTACH0, 1, 0, false, 1)
        end
        zygote.Velocity = zygote.Velocity*0.70 + data.targetVel*0.30
        if zygote.Velocity.X < 0 then
            zygote.FlipX = true
        else
            zygote.FlipX = false
        end
    end
end

---------------------------------------
-- Headless Round Worm Logic
---------------------------------------

--Enemy configuration
local numberOfShotsHeadlessWorm = Vector(3, 5) --A number between 2 and 4
local shotRadiusHeadlessWorm = 50 --Radius of the shots

function Alphabirth:handleHeadlessRoundWorm(entity)
    if entity.FrameCount == 1 and math.random(5) == 1 then
        entity:ToNPC():Morph(entity.Type, ENTITY_VARIANT_HEADLESS_ROUND_WORM, 0, 0)
    end
    if entity.Variant == ENTITY_VARIANT_HEADLESS_ROUND_WORM then

        if entity:ToNPC().State == NpcState.STATE_JUMP then --for roundworms the jump state is going underground
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, entity.Position, Vector(0,0), entity)
        end

        if entity:ToNPC().State == NpcState.STATE_ATTACK then
            for i, e in ipairs(Isaac.GetRoomEntities()) do
                if e.Type == EntityType.ENTITY_PROJECTILE and e.FrameCount == 1 and e.SpawnerType == EntityType.ENTITY_ROUND_WORM and e.SpawnerVariant == ENTITY_VARIANT_HEADLESS_ROUND_WORM then

                    local projectileNumber = math.random(numberOfShotsHeadlessWorm.X, numberOfShotsHeadlessWorm.Y)

                    for i = 1, projectileNumber do
                        local spread = math.random(1, 359) + (i - 1)*math.random(1, 560)
                        local projectiles = fireProjectiles(1, spread, 3, e.Variant, e.Position, Vector(math.random(-shotRadiusHeadlessWorm, shotRadiusHeadlessWorm), math.random(-shotRadiusHeadlessWorm, shotRadiusHeadlessWorm)))
                    end
                    e:Remove()
                end
            end
        end
    end
end

---------------------------------------
-- Lobotomy logic
---------------------------------------

function Alphabirth:onGaperUpdate(entity)
    if entity.FrameCount > 1 or math.random(1, 10) ~= 1 then
        return
    end
    Isaac.Spawn(ENTITY_TYPE_LOBOTOMY, ENTITY_VARIANT_LOBOTOMY, 0, entity.Position, entity.Velocity, entity)
    entity:Remove()
end

function Alphabirth:onLobotomyUpdate(lobotomy)
    if lobotomy.Variant ~= ENTITY_VARIANT_LOBOTOMY then
        return
    end
    local data = lobotomy:GetData()

    if not data.initialized then
        local sprite = lobotomy:GetSprite()
        sprite:PlayOverlay("Head", true)
        data.soundCountdown = 50
        data.targetVel = Vector(0, 0)
        data.died = false
        data.initialized = true
    end

    if math.random(1, 10) == 1 then
        data.targetVel = (Isaac.GetRandomPosition() - lobotomy.Position):Normalized()*3
    end
    lobotomy.Velocity = lobotomy.Velocity * 0.7 + data.targetVel * 0.3
    lobotomy:AnimWalkFrame("WalkHori", "WalkVert", 0.1)
    if data.soundCountdown < 0 then
        lobotomy:PlaySound(SoundEffect.SOUND_ZOMBIE_WALKER_KID, 0.8, 0, false, 0.9+math.random()*0.1)
        data.soundCountdown = math.random(40, 80)
    end
    data.soundCountdown = data.soundCountdown - 1
    if lobotomy:IsDead() and not data.died then
        -- using Game::Spawn instead of Isaac.Spawn so
        -- that it never spawns the variant of the brain
        local brain = Game():Spawn(32, 0, lobotomy.Position, Vector(0,0), lobotomy, 0, 1):ToNPC()

        lobotomy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        brain.HitPoints = 8
        brain.State = 0
        brain:SetSize(10, Vector(1,1), 12)
        brain.Scale = 0.9
        data.died = true
    end
end

---------------------------------------
-- Blooderfly Logic
---------------------------------------
local blooderfly_target = nil
local in_range = false
function Alphabirth:blooderflyUpdate(blooderfly)
    local player = Isaac.GetPlayer(0)

    if blooderfly_target == nil then
        blooderfly:FollowPosition(player.Position)
        blooderfly_target = findClosestEnemy(player)
    else
        local dir = blooderfly_target.Position:__sub(blooderfly.Position)
        local hyp = math.sqrt(dir.X * dir.X + dir.Y * dir.Y)
        dir.X = dir.X / hyp
        dir.Y = dir.Y / hyp
        local pos = Vector(0,0)
        pos.X = blooderfly.Position.X + dir.X * 44
        pos.Y = blooderfly.Position.Y + dir.Y * 55

        if blooderfly_target.Position:Distance(blooderfly.Position) < 25 then
            in_range = true
            blooderfly:FollowPosition(blooderfly_target.Position)
        else
            blooderfly:FollowPosition(pos)
        end
        if blooderfly_target:IsDead() then
            blooderfly_target = nil

            if in_range then
                --Hemophilia Effect
                local tears = {}
                for i = 1, 3 do
                    tears[i] = player:FireTear(blooderfly.Position,
                        Vector(math.random(-4, 4),
                            math.random(-4, 4)),
                        false,
                        false,
                        true
                    )

                    tears[i]:ChangeVariant(1)
                    tears[i].TearFlags = 0
                    tears[i].Scale = 1
                    tears[i].Height = -30
                    tears[i].FallingSpeed = -4 + math.random()*-4
                    tears[i].FallingAcceleration = math.random() + 0.5
                end
                Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.PLAYER_CREEP_RED,0,blooderfly.Position,Vector(0, 0),player)
                Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.LARGE_BLOOD_EXPLOSION,0,blooderfly.Position,Vector(0, 0),player)
                tears = {}
                in_range = false
            end

            if(math.random(8) == 1) then
                Isaac.Spawn(
                    EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_HEART,
                    1,
                    blooderfly.Position,
                    blooderfly.Velocity,
                    blooderfly
                )
            end
        end
    end
end

local function applyBlooderflyCache(player, cache_flag)
    local blooderfly_exists = false
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_FAMILIAR and
                entity.Variant == ENTITY_VARIANT_BLOODERFLY then
            if player:HasCollectible(PASSIVE_BLOODERFLY) then
                blooderfly_exists = true
            else
                entity:Remove()
            end
        end
    end

    if cache_flag == CacheFlag.CACHE_FAMILIARS and player:HasCollectible(PASSIVE_BLOODERFLY) then
        if not blooderfly_exists and not player:HasCollectible(PASSIVE_BIRTH_CONTROL) then
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR,
                ENTITY_VARIANT_BLOODERFLY,
                0,
                player.Position,
                Vector(0,0),
                player)
        end
    end
end

---------------------------------------
-- Kamikaze Fly Logic
---------------------------------------

--Entity Configuration
local kamikazeFlyCooldown = Vector(100,260) --Value between 100 and 260

function Alphabirth:onKamikazeFly(kamikazeFly)
    if kamikazeFly.Variant == ENTITY_VARIANT_KAMIKAZE_FLY then
        --Setup Cooldown
        if not kamikazeFly:GetData()["shot_delay"] then
            kamikazeFly:GetData()["shot_delay"] = math.random(kamikazeFlyCooldown.X, kamikazeFlyCooldown.Y)
            Isaac.DebugString(kamikazeFly:GetData()["shot_delay"])
        elseif kamikazeFly:GetData()["shot_delay"] > 0 then
            kamikazeFly:GetData()["shot_delay"] = kamikazeFly:GetData()["shot_delay"] - 1
            Isaac.DebugString(kamikazeFly:GetData()["shot_delay"])
        end
        if kamikazeFly:GetData()["shot_delay"] == 0 then
            kamikazeFly:GetData()["shot_delay"] = math.random(kamikazeFlyCooldown.X, kamikazeFlyCooldown.Y)
            kamikazeFly:GetData()["animation_timer"] = 28
            kamikazeFly:GetSprite():Play("DropBomb", 1)
        end

        --Attack
        if kamikazeFly:GetData()["animation_timer"] then
            if kamikazeFly:GetData()["animation_timer"] > 0 then
                kamikazeFly:SetSpriteFrame("DropBomb", 0 + math.abs(kamikazeFly:GetData()["animation_timer"] - 28))
                Isaac.DebugString("Frame" .. 0 + math.abs(kamikazeFly:GetData()["animation_timer"] - 28))
                if math.abs(kamikazeFly:GetData()["animation_timer"] - 28) == 21 then
                    Isaac.Spawn(EntityType.ENTITY_BOMBDROP, 0, 0, kamikazeFly.Position:__sub(Vector(0,-30)), Vector(0,0), kamikazeFly)
                end
                kamikazeFly:GetData()["animation_timer"] = kamikazeFly:GetData()["animation_timer"] - 1
            else
                kamikazeFly:GetData()["animation_timer"] = nil
            end
        end
    end
end

---------------------------------------
-- Spirit Eye Logic
---------------------------------------
local homing_tears = {}
local tear_count = 6
local SPIRIT_SYNERGIES = {
    CollectibleType.COLLECTIBLE_DR_FETUS,
    CollectibleType.COLLECTIBLE_TECH_X,
    CollectibleType.COLLECTIBLE_TECHNOLOGY,
    CollectibleType.COLLECTIBLE_TECHNOLOGY_2,
    CollectibleType.COLLECTIBLE_BRIMSTONE,
    CollectibleType.COLLECTIBLE_MOMS_KNIFE,
    CollectibleType.COLLECTIBLE_EPIC_FETUS
}
local knife_exists = false

function Alphabirth:onSpiritEyeUpdate(spirit_eye)
    local player = Isaac.GetPlayer(0)
    local player_previous_tearcolor = player.TearColor
    local player_previous_lasercolor = player.LaserColor

    player.TearColor = Color(0.6, 0, 0.6, 0.5, 0, 0, 0)
    -- Since lasers are bright red by default, I put a very bright blue overlay on top.
    player.LaserColor = Color(1, 0, 0, 1, 0, 0, 255)

    if player:HasCollectible(SPIRIT_SYNERGIES[1]) then -- DR_FETUS
        spirit_eye:MoveDiagonally(0.35)
        for _,entity in ipairs(Isaac.GetRoomEntities()) do
            if entity:ToBomb() and entity.Position:Distance(spirit_eye.Position) <= 25 and not entity:HasEntityFlags(FLAG_SPIRIT_EYE_SHOT) and not
            entity:HasEntityFlags(FLAG_QUILL_FEATHER_APLLIED) then
                local bomb = entity:ToBomb()
                bomb:AddEntityFlags(FLAG_SPIRIT_EYE_SHOT)
                bomb.ExplosionDamage = bomb.ExplosionDamage * 1.8
                bomb.Color = Color(0.6, 0, 0.6, 0.5, 0, 0, 0)
            end
        end
    elseif player:HasCollectible(SPIRIT_SYNERGIES[2]) then -- TECH_X
        spirit_eye:MoveDiagonally(0.44)
        if Isaac.GetFrameCount() % 44 == 0 then
            local laser = player:FireTechXLaser(spirit_eye.Position, spirit_eye.Velocity:__mul(2), 10)
            laser.TearFlags = setbit(laser.TearFlags, TEAR_FLAGS.FLAG_HOMING)
            laser:SetTimeout(10)
        end
    elseif player:HasCollectible(SPIRIT_SYNERGIES[3]) or player:HasCollectible(SPIRIT_SYNERGIES[4]) then --TECH_1 and TECH_2
        spirit_eye:FollowPosition(player.Position)
        if Isaac.GetFrameCount() % 61 == 0 then
            for i = 1, 3 do
                local laser = player:FireTechLaser(spirit_eye.Position, 0, RandomVector(), false, false)
                laser.TearFlags = setbit(laser.TearFlags, TEAR_FLAGS.FLAG_HOMING)
            end
        end
    elseif player:HasCollectible(SPIRIT_SYNERGIES[5]) then -- BRIMSTONE
        spirit_eye:FollowPosition(player.Position)
        if Isaac.GetFrameCount() % 79 == 0 then
            local laser = player:FireDelayedBrimstone(RandomVector():GetAngleDegrees(), spirit_eye)
            local rotation_roll = math.random(1, 2)
            local rotation_speed = math.random(2.0, 3.0)
            if rotation_roll == 1 then
                rotation_speed = -rotation_speed
            end
            laser:SetActiveRotation(0, math.random(90, 180), rotation_speed, false)
            laser:SetTimeout(24)
        end
    elseif player:HasCollectible(SPIRIT_SYNERGIES[6]) then -- MOMS_KNIFE
        spirit_eye:FollowPosition(player.Position:__mul(1.1))
        if knife_exists == false then
            local knife = player:FireKnife(spirit_eye, 0, false, 0)
            knife_exists = true
        end
    elseif player:HasCollectible(SPIRIT_SYNERGIES[7]) then -- EPIC_FETUS
        spirit_eye:MoveDiagonally(0.5)
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity:IsVulnerableEnemy() and entity.Position:Distance(spirit_eye.Position) <= 25 and math.random(100) <= 5 then
                entity:AddFreeze(EntityRef(spirit_eye), 100)
            end
        end
    else
        spirit_eye:MoveDiagonally(0.35)
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_TEAR and entity.Position:Distance(spirit_eye.Position) <= 25 and not entity:HasEntityFlags(FLAG_SPIRIT_EYE_SHOT) and not
            entity:HasEntityFlags(FLAG_QUILL_FEATHER_APLLIED) then
                local direction_vector = entity.Velocity
                entity:Die()
                for i = 1, tear_count do
                    local angle = 15
                    local random_angle = math.rad(math.random(-math.floor(angle), math.floor(angle)))
                    local cos_angle = math.cos(random_angle)
                    local sin_angle = math.sin(random_angle)
                    local shot_direction = Vector(cos_angle * direction_vector.X - sin_angle * direction_vector.Y,
                        sin_angle * direction_vector.X + cos_angle * direction_vector.Y
                    )
                    local magnitude = {0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2}
                    local shot_vector = shot_direction:__mul(magnitude[math.random(#magnitude)])

                    homing_tears[i] = player:FireTear(spirit_eye.Position, shot_vector, false, false, true)
                    homing_tears[i].TearFlags = setbit(homing_tears[i].TearFlags, TEAR_FLAGS.FLAG_HOMING)
                    homing_tears[i]:AddEntityFlags(FLAG_SPIRIT_EYE_SHOT)
                end
            end
        end
    end

    player.TearColor = player_previous_tearcolor
    player.LaserColor = player_previous_lasercolor
    homing_tears = {}
end

local function applySpiritEyeCache(player, cache_flag)
    local spirit_eye_exists = false
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_FAMILIAR and
                entity.Variant == ENTITY_VARIANT_SPIRIT_EYE then
            if player:HasCollectible(PASSIVE_SPIRIT_EYE) then
                spirit_eye_exists = true
            else
                entity:Remove()
            end
        end
    end

    if cache_flag == CacheFlag.CACHE_FAMILIARS and player:HasCollectible(PASSIVE_SPIRIT_EYE) then
        if not spirit_eye_exists and not player:HasCollectible(PASSIVE_BIRTH_CONTROL) then
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR,
                ENTITY_VARIANT_SPIRIT_EYE,
                0,
                player.Position,
                Vector(0,0),
                player)
        end
    end
end

---------------------------------------
-- Infested Baby Logic
---------------------------------------
local infestedEntity
local infestedBabySpider
local animationCooldown = 0
local spiderCooldown = 0

function Alphabirth:onInfestedBabyUpdate(familiar)
    familiar:ToFamiliar():FollowParent()
    familiar.FireCooldown = 999999
    if animationCooldown == 0 then
        familiar:ToFamiliar():Shoot()
    end
    if infestedBabySpider and infestedBabySpider:IsDead() then
        infestedBabySpider = nil
        spiderCooldown = 25
    end
    if Isaac.GetPlayer(0):GetFireDirection() ~= -1 and infestedBabySpider == nil and spiderCooldown == 0 then
        infestedBabySpider = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, 0, familiar.Position, Vector(0,0), familiar)
        if Isaac.GetPlayer(0):GetFireDirection() == Direction.UP then
            familiar:GetSprite():Play("ShootUp", 1)
        elseif Isaac.GetPlayer(0):GetFireDirection() == Direction.DOWN then
            familiar:GetSprite():Play("ShootDown", 1)
        elseif Isaac.GetPlayer(0):GetFireDirection() == Direction.LEFT then
            familiar:GetSprite():Play("ShootSide", 1)
            familiar:GetSprite().FlipX = true
        elseif Isaac.GetPlayer(0):GetFireDirection() == Direction.RIGHT then
            familiar:GetSprite():Play("ShootSide", 1)
        end
        animationCooldown = 8
        playSound(SoundEffect.SOUND_SPIDER_COUGH, 0.5, 0, false, 1)
    end
    for _, e in ipairs(Isaac.GetRoomEntities()) do
        if e.Parent == familiar and e.Type == EntityType.ENTITY_TEAR then
            e:Remove()
        end
    end
    if animationCooldown > 0 then
        animationCooldown = animationCooldown - 1
    end
    if spiderCooldown > 0 then
        spiderCooldown = spiderCooldown - 1
    end
end


local function applyInfestedBabyCache(pl, fl)
    if fl == CacheFlag.CACHE_FAMILIARS and pl:HasCollectible(PASSIVE_INFESTED_BABY) == false and infestedEntity then
        infestedEntity:Remove()
        infestedEntity = nil
    end
    if fl == CacheFlag.CACHE_FAMILIARS and pl:HasCollectible(PASSIVE_INFESTED_BABY) and not infestedEntity then
        infestedEntity = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, ENTITY_VARIANT_INFESTED_BABY, 0, pl.Position, Vector(0, 0), pl)
    end
end

function Alphabirth:onInfestedBabyInit(familiar)

end

---------------------------------------
-- Post-Update Callback
---------------------------------------
local currentRoom = Game():GetRoom()
local activeCharge
local canDrop = false
local endor_health = 0
local endor_type = Isaac.GetPlayerTypeByName("Endor")

function Alphabirth:modUpdate()
    local player = Isaac.GetPlayer(0)
    local game = Game()
    local level = game:GetLevel()
    local room = game:GetRoom()
    local frame = game:GetFrameCount()
    local player_type = player:GetPlayerType()

    --Endor
    if player_type == endor_type and frame > 1 then
        if player:GetMaxHearts() > endor_health then
            health_change = player:GetMaxHearts() - endor_healths
            player:AddEternalHearts(health_change / 2)
            player:AddMaxHearts(-health_change, false)
            endor_health = endor_health + health_change
        end

        if player:GetMaxHearts() + player:GetEternalHearts() * 2 > endor_health then
            endor_health = endor_health + 2
        end

        for i = 1, 24 do
            if player:IsBlackHeart(i) then
                player:RemoveBlackHeart(i)
                player:AddSoulHearts(-2)
                player:TakeDamage(2, 0, EntityRef(player), 0)
            end
        end
    end

    --Additional Alastor's Candle Logic
    if player:HasCollectible(ACTIVE_ALASTORS_CANDLE) and flames_exist then
        handleAlastorsCandleFlames()
        if room:GetFrameCount() == 1 then
            for i=1, number_of_fires do
                flames[i]:Die()
                Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    EffectVariant.POOF01,
                    0,            -- Entity Subtype
                    flames[i].Position,
                    Vector(0, 0), -- Velocity
                    nil
                )
            end
            flames_exist = false
        end
    end

    if not player:HasCollectible(PASSIVE_CRACKED_ROCK) then
        handleCrackedRockSpawnChance()
    end
    triggerCurses(player)

    if player:HasCollectible(PASSIVE_QUILL_FEATHER) then
        handleQuillFeather()
    end

    -- Reset variables each run
    if frame == 1 then
        cauldron_points = 0
        didMax = false
        hasCyborg = false
        cyborg_progress = {}
        has_damned = false
        damned_progress = {}
        damned_health_applied = false
        damned_has_respawned = false
        birthControlStats = {
            HP = 0,
            Damage = 0,
            MoveSpeed = 0,
            ShotSpeed = 0,
            Luck = 0,
            Range = 0
        }
        bloodDriveTimesUsed = 0
        has_brunch_health = false
        chalice_souls = 0
        blacklightUses = 0
        darkenCooldown = 0

        if player_type == endor_type then
            player:AddNullCostume(ENDOR_BODY_COSTUME)
            player:AddNullCostume(ENDOR_HEAD_COSTUME)
            player:AddCollectible(ACTIVE_CAULDRON, 0, true)
            player:AddCollectible(PASSIVE_SPIRIT_EYE, 0, true)
            player:AddMaxHearts(-player:GetMaxHearts())
            player:AddSoulHearts(4)
            player:AddEternalHearts(1)
        end
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end

    -- Max Deal with the Devil chance
    if didMax == true and Game():GetRoom():GetFrameCount() == 1 then
        Isaac.GetPlayer(0):GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_GOAT_HEAD, false)
    end

	for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if level:GetCurseName() ~= "Curse of the Blind" then
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

            if entity.Type == EntityType.ENTITY_PICKUP and
                    entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and
                    entity.SubType == ACTIVE_CHALICE_OF_BLOOD then
                local sprite = entity:GetSprite()
                if chalice_souls <= 5 then
                    sprite:ReplaceSpritesheet(1,"gfx/Items/Collectibles/collectible_chaliceofblood.png")
                elseif chalice_souls <= 10 then
                    sprite:ReplaceSpritesheet(1,"gfx/Items/Collectibles/collectible_chaliceofblood2.png")
                elseif chalice_souls < 15 then
                    sprite:ReplaceSpritesheet(1,"gfx/Items/Collectibles/collectible_chaliceofblood3.png")
                else
                    sprite:ReplaceSpritesheet(1,"gfx/Items/Collectibles/collectible_chaliceofblood4.png")
                end
                sprite:LoadGraphics()
            end
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

    --Damned Transformation Detector
    if Game():GetFrameCount() % 60 == 0 then
        if not has_damned then
            for _, item in ipairs(damned_pool) do
                if player:HasCollectible(item) and contains(damned_progress, item) == false then
                    table.insert(damned_progress, item)
                end
            end
            if #damned_progress >= 3 then
                has_damned = true
                player:AddNullCostume(DAMNED_COSTUME)
                player:AddCacheFlags(CacheFlag.CACHE_ALL)
                player:EvaluateItems()

                if not damned_health_applied then
                    damned_health_applied = true
                    local hearts = player:GetMaxHearts()
                    player:AddMaxHearts(hearts * -1, true)
                    player:AddBlackHearts(24)
                end
            end
        end
    end

    --Damned Respawn Logic
    if player:IsDead() and has_damned and not damned_has_respawned then
        damned_has_respawned = true
        player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false, true, true, false)
        player:Revive()
        player:AddBlackHearts(10)
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
    handleBlacklight()

    if player:HasCollectible(PASSIVE_TECH_ALPHA) then
        handleTechAlpha(player)
    end

    if player:HasCollectible(PASSIVE_ABYSS) then
        handleAbyss()
    end
    if player:HasCollectible(PASSIVE_HOT_COALS) then
        handleHotCoals()
    end

    if Game():GetFrameCount() % 10 == 0 then
        birthControlUpdate()
    end

    if bloodDriveTimesUsed > 0 then
        handleBloodDrive()
    end

    if player:HasCollectible(PASSIVE_HOARDER) then
        handleHoarder()
    end

    -- Chalice of blood handling
    if player:HasCollectible(ACTIVE_CHALICE_OF_BLOOD) then
       handleChaliceOfBlood()
    end

    -- Judas' Fez Handling
    if player:HasCollectible(PASSIVE_JUDAS_FEZ) then
        handleJudasFez()
    else
        health_reduction_applied = false
    end

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
                    ACTIVE_ALASTORS_CANDLE, PASSIVE_AIMBOT, PASSIVE_BLOODERFLY, PASSIVE_CRACKED_ROCK,
                    PASSIVE_GLOOM_SKULL, PASSIVE_HEMOPHILIA, PASSIVE_TECH_ALPHA, PASSIVE_BIRTH_CONTROL,
                    PASSIVE_SPIRIT_EYE, PASSIVE_INFESTED_BABY, ACTIVE_BLOOD_DRIVE, PASSIVE_JUDAS_FEZ,
                    PASSIVE_HOT_COALS, PASSIVE_QUILL_FEATHER, PASSIVE_BRUNCH, ACTIVE_CHALICE_OF_BLOOD,
                    PASSIVE_ABYSS, ACTIVE_BLACKLIGHT, PASSIVE_HOARDER
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
    local charge = player:GetActiveCharge()
    if player:HasCollectible(ACTIVE_BIONIC_ARM) and cache_flag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + (charge/6)
    end
    applyGloomSkullCache(player, cache_flag)
    applyCrackedRockCache(player, cache_flag)
    applyAimbotCache(player, cache_flag)
    applyBlooderflyCache(player, cache_flag)
    applyHemophiliaCache(player, cache_flag)
    applyBirthControlCache(player, cache_flag)
    applyCyborgCache(player, cache_flag)
    applySpiritEyeCache(player, cache_flag)
    applyAbyssCache(player, cache_flag)
    applyInfestedBabyCache(player, cache_flag)
    applyJudasFezCache(player, cache_flag)
    applyBrunchCache(player, cache_flag)
    applyHotCoalsUpdate(player, cache_flag)
    applyChaliceOfBloodCache(player, cache_flag)
    applyQuillFeatherCache(player, cache_flag)
    applyTechAlphaCache(player, cache_flag)
    applyHoarderCache(player, cache_flag)
    applyDamnedCache(player, cache_flag)
    if player:GetPlayerType() == endor_type then
        player.CanFly = true
        if cache_flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage - 1.25
        elseif cache_flag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + 0.2
        elseif cache_flag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay - 3
        end
    end
end

-------------------
-- Active Handling
-------------------
Alphabirth_mod:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerCauldron, ACTIVE_CAULDRON)
Alphabirth_mod:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerSurgeonSimulator, ACTIVE_SURGEON_SIMULATOR)
Alphabirth_mod:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerMirror, ACTIVE_MIRROR)
Alphabirth_mod:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerBionicArm, ACTIVE_BIONIC_ARM)
Alphabirth_mod:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerAlastorsCandle, ACTIVE_ALASTORS_CANDLE)
Alphabirth_mod:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerBloodDrive, ACTIVE_BLOOD_DRIVE)
Alphabirth_mod:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerChaliceOfBlood, ACTIVE_CHALICE_OF_BLOOD)
Alphabirth_mod:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerBlacklight, ACTIVE_BLACKLIGHT)


-------------------
-- Pocket Handleing
-------------------

Alphabirth_mod:AddCallback(ModCallbacks.MC_USE_CARD, Alphabirth.triggerNaudizEffect, POCKETITEM_NAUDIZ)

-------------------
-- Passive Handling
-------------------

-------------------
-- Player Effects
-------------------

-------------------
-- Take Damage Updates
-------------------
Alphabirth_mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Alphabirth.triggerCrackedRockEffect)
Alphabirth_mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Alphabirth.triggerHemophilia)
Alphabirth_mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Alphabirth.triggerAbyss)
Alphabirth_mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Alphabirth.triggerQuillFeather)

Alphabirth_mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Alphabirth.triggerHostTakeDamage, EntityType.ENTITY_HOST)

-------------------
-- Entity Handling
-------------------

-- Alphabirth:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Alphabirth.onBlooderflyInit, ENTITY_VARIANT_BLOODERFLY)
Alphabirth_mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Alphabirth.blooderflyUpdate, ENTITY_VARIANT_BLOODERFLY)

-- Alphabirth:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Alphabirth.onSpiritEyeInit, ENTITY_VARIANT_SPIRIT_EYE)
Alphabirth_mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Alphabirth.onSpiritEyeUpdate, ENTITY_VARIANT_SPIRIT_EYE)

Alphabirth_mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Alphabirth.onInfestedBabyInit, ENTITY_VARIANT_INFESTED_BABY)
Alphabirth_mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Alphabirth.onInfestedBabyUpdate, ENTITY_VARIANT_INFESTED_BABY)

Alphabirth_mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Alphabirth.onHostUpdate, EntityType.ENTITY_HOST)

Alphabirth_mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Alphabirth.onEmbryoUpdate, EntityType.ENTITY_EMBRYO)
Alphabirth_mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Alphabirth.onZygoteUpdate, ENTITY_TYPE_ZYGOTE)

Alphabirth_mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Alphabirth.onRoundWormUpdate, EntityType.ENTITY_ROUND_WORM)
Alphabirth_mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Alphabirth.handleHeadlessRoundWorm, EntityType.ENTITY_ROUND_WORM)
Alphabirth_mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Alphabirth.onGaperUpdate, EntityType.ENTITY_GAPER)
Alphabirth_mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Alphabirth.onCrawlerUpdate, EntityType.ENTITY_NIGHT_CRAWLER)
Alphabirth_mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Alphabirth.onLobotomyUpdate, ENTITY_TYPE_LOBOTOMY)
Alphabirth_mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Alphabirth.onKamikazeFly, ENTITY_TYPE_KAMIKAZE_FLY)

Alphabirth_mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Alphabirth.onUlcerUpdate, EntityType.ENTITY_ULCER)

Alphabirth_mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Alphabirth.onWallCreepUpdate, EntityType.ENTITY_BLIND_CREEP)
-------------------
-- Mod Updates
-------------------

Alphabirth_mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Alphabirth.modUpdate)
Alphabirth_mod:AddCallback(ModCallbacks.MC_POST_RENDER, Alphabirth.cauldronUpdate)
Alphabirth_mod:AddCallback(ModCallbacks.MC_POST_RENDER, Alphabirth.chaliceOfBloodUpdate)
Alphabirth_mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Alphabirth.evaluateCache)
Alphabirth_mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Alphabirth.playerInit)
