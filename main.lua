local Alphabirth = {}
Isaac.RegisterMod(Alphabirth,"Alphabirth Pack 2",1)
Isaac.DebugString("I'm alive!")

----------------------------------------
-- Config
----------------------------------------

----------------------------------------
-- Initialize the RNG
----------------------------------------
math.randomseed(Random())
math.random();math.random();math.random();

----------------------------------------
-- Costume Declaration
----------------------------------------

----------------------------------------
-- Entity Flag Declaration
----------------------------------------
-- use EntityFlag.FLAG_YOUR_FLAG = 1 << FlagID

----------------------------------------
-- Curse Declaration
----------------------------------------
-- use LevelCurse.CURSE_YOUR_CURSE = 1 << CurseID

----------------------------------------
-- Active Declaration
----------------------------------------
-- use CollectibleType.COLLECTIBLE_YOUR_ITEM = ItemID

----------------------------------------
-- Passive Declaration
----------------------------------------
-- use CollectibleType.COLLECTIBLE_YOUR_ITEM = ItemID

----------------------------------------
-- Trinket Declaration
----------------------------------------
-- use TrinketType.TRINKET_YOUR_ITEM = TrinketID

----------------------------------------
-- Variables that need to be loaded early
----------------------------------------




----------------------------------------
-- Post-Update Callback
----------------------------------------
function Alphabirth:modUpdate()
end

----------------------------------------
-- Callbacks
----------------------------------------
Alphabirth:AddCallback(ModCallbacks.MC_POST_UPDATE, Alphabirth.modUpdate)

