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
local BIRTH_CONTROL_COSTUME = Isaac.GetCostumeIdByPath("gfx/animations/costumes/accessories/animation_costume_birthcontrol.anm2")

---------------------------------------
-- Entity Flag Declaration
---------------------------------------
-- use FLAG_YOUR_FLAG = 1 << FlagID

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
local PASSIVE_BIRTH_CONTROL = Isaac.GetItemIdByName("Birth Control")
local PASSIVE_SPIRIT_EYE = Isaac.GetItemIdByName("Spirit Eye")
local PASSIVE_INFESTED_BABY = Isaac.GetItemIdByName("Infested Baby")

---------------------------------------
-- Entity Variant Declaration
---------------------------------------

local ENTITY_VARIANT_BLOODERFLY = Isaac.GetEntityVariantByName("Blooderfly")
local ENTITY_VARIANT_SPIRIT_EYE = Isaac.GetEntityVariantByName("Spirit Eye")
local ENTITY_VARIANT_INFESTED_BABY = Isaac.GetEntityVariantByName("Infested Baby")

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

local birthControl_pool = {
    PASSIVE_INFESTED_BABY,
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
-- Tech Alpha Logic
---------------------------------------
local function handleTechAlpha(player)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local entity_will_shoot = nil
        local roll_max = 30
        if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
            roll_max = roll_max * 2
        end

        if entity.Type == EntityType.ENTITY_TEAR then
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
                    direction_vector = closest_enemy.Position - entity.Position
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

local didMax = false

local function maxOutDevilDeal()
    didMax = true
end

local function applyGloomSkullCache(player, cache_flag)
    if cache_flag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(PASSIVE_GLOOM_SKULL) then
        player.Damage = player.Damage + 1.5
        Game():GetLevel():AddCurse(Isaac.GetCurseIdByName("Curse of Darkness"), false)

        player:AddNullCostume(GLOOM_SKULL_COSTUME)
        maxOutDevilDeal()
    end
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
    if blooderfly == nil then
        Isaac.DebugString("PROBLEM SPAWNING BLOODERFLY")
    end
end

local blooderfly
local blooderfly_target = nil
local in_range = false
function Alphabirth:blooderflyUpdate(_,familiar)
    local player = Isaac.GetPlayer(0)

    if blooderfly_target == nil then
        blooderfly:FollowPosition(player.Position)
        blooderfly_target = chooseRandomTarget()
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

local blooderfly_exists = false
local function applyBlooderflyCache(player, cache_flag)
    if cache_flag == CacheFlag.CACHE_FAMILIARS and player:HasCollectible(PASSIVE_BLOODERFLY) and blooderfly_exists == false then
        blooderfly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, ENTITY_VARIANT_BLOODERFLY, 0, player.Position, Vector(0,0), player):ToFamiliar()
        blooderfly_exists = true
    end
end

---------------------------------------
-- Spirit Eye Logic
---------------------------------------
local spirit_eye
local can_collide = true
local frames = 0
local homing_tears = {}
local tear_count = 6
local TEAR_FLAGS = {
    FLAG_HOMING = 1 << 2
}

function Alphabirth:onSpiritEyeInit(_,familiar)
    if spirit_eye == nil then
        Isaac.DebugString("Spawning Error : Spirit Eye")
    end
end

function Alphabirth:onSpiritEyeUpdate(_,familiar)
    local player = Isaac.GetPlayer(0)
    spirit_eye:MoveDiagonally(0.35)

    if can_collide == false then
        frames = frames + 1
        if frames % 15 == 0 then
            can_collide = true
        end
    end

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_TEAR and entity.Position:Distance(spirit_eye.Position) <= 25 and can_collide then
            local direction_vector = entity.Velocity
            can_collide = false
            entity:Die()
            for i = 1, tear_count do
                local angle = 15
                local random_angle = math.rad(math.random(-math.floor(angle), math.floor(angle)))

                local cos_angle = math.cos(random_angle)
                local sin_angle = math.sin(random_angle)

                local shot_direction = Vector(cos_angle * direction_vector.X - sin_angle * direction_vector.Y,
                    sin_angle * direction_vector.X + cos_angle * direction_vector.Y
                )
                local magnitude = {0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4}
                local shot_vector = shot_direction:__mul(magnitude[math.random(#magnitude)])

                homing_tears[i] = player:FireTear(spirit_eye.Position, shot_vector, false, false, true)
                homing_tears[i].TearFlags = TEAR_FLAGS.FLAG_HOMING
                homing_tears[i].Color = Color(0.6, 0, 0.6, 0.5, 0, 0, 0)
            end
        end
    end
end


local spirit_eye_exists = false
local function applySpiritEyeCache(player, cache_flag)
    if cache_flag == CacheFlag.CACHE_FAMILIARS and player:HasCollectible(PASSIVE_SPIRIT_EYE) and spirit_eye_exists == false then
        spirit_eye = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, ENTITY_VARIANT_SPIRIT_EYE, 0, player.Position, Vector(0,0), player):ToFamiliar()
        spirit_eye_exists = true
    end
end

---------------------------------------
-- Infested Baby
---------------------------------------
local infestedEntity
local infestedBabySpider
local animationCooldown = 0

function Alphabirth:onInfestedBabyUpdate(familiar)
    familiar:ToFamiliar():FollowParent()
    familiar.FireCooldown = 999999
    if animationCooldown == 0 then
        familiar:ToFamiliar():Shoot()
    end
    if infestedBabySpider and infestedBabySpider:IsDead() then
        infestedBabySpider = nil
    end
    if Isaac.GetPlayer(0):GetFireDirection() ~= -1 and infestedBabySpider == nil then
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

function Alphabirth:modUpdate()
    local player = Isaac.GetPlayer(0)
    local game = Game()
    local room = game:GetRoom()
    local frame = game:GetFrameCount()

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

    -- Reset variables each run
    if frame == 1 then
        cauldron_points = 0
        didMax = false
        hasCyborg = false
        cyborg_progress = {}
        birthControlStats = {
            HP = 0,
            Damage = 0,
            MoveSpeed = 0,
            ShotSpeed = 0,
            Luck = 0,
            Range = 0
        }
        bloodDriveTimesUsed = 0
        spirit_eye_exists = false
        blooderfly_exists = false
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

    if player:HasCollectible(PASSIVE_TECH_ALPHA) then
        handleTechAlpha(player)
    end

    if Game():GetFrameCount() % 10 == 0 then
        birthControlUpdate()
    end

    if bloodDriveTimesUsed > 0 then
        handleBloodDrive()
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
                    PASSIVE_SPIRIT_EYE, PASSIVE_INFESTED_BABY,ACTIVE_BLOOD_DRIVE
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
    applyInfestedBabyCache(player, cache_flag)
end

-------------------
-- Active Handling
-------------------
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerCauldron, ACTIVE_CAULDRON)
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerSurgeonSimulator, ACTIVE_SURGEON_SIMULATOR)
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerMirror, ACTIVE_MIRROR)
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerBionicArm, ACTIVE_BIONIC_ARM)
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerAlastorsCandle, ACTIVE_ALASTORS_CANDLE)
Alphabirth:AddCallback(ModCallbacks.MC_USE_ITEM, Alphabirth.triggerBloodDrive, ACTIVE_BLOOD_DRIVE)


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

Alphabirth:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Alphabirth.onSpiritEyeInit, ENTITY_VARIANT_SPIRIT_EYE)
Alphabirth:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Alphabirth.onSpiritEyeUpdate, ENTITY_VARIANT_SPIRIT_EYE)

Alphabirth:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Alphabirth.onInfestedBabyInit, ENTITY_VARIANT_INFESTED_BABY)
Alphabirth:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Alphabirth.onInfestedBabyUpdate, ENTITY_VARIANT_INFESTED_BABY)
-------------------
-- Mod Updates
-------------------

Alphabirth:AddCallback(ModCallbacks.MC_POST_UPDATE, Alphabirth.modUpdate)
Alphabirth:AddCallback(ModCallbacks.MC_POST_RENDER, Alphabirth.cauldronUpdate)
Alphabirth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Alphabirth.evaluateCache)
