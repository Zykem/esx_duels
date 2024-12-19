Config = {}

---@class Interaction
---@field coords vector4 | vector3 Position and heading of NPC (x, y, z, heading)
---@field pedModel? string | number Model of the NPC
---@field lobby? string Name of lobby to which the player will be routed to after joining.

-- The list of allowed lobbies players can join the queue for (if a lobby is specified in interaction and not here, it won't work.)
Config.allowedLobbies = {
    ['main'] = true,
    ['main2'] = true
}

---@type Interaction[]
Config.interactions = {
    { coords = vector4(1008.0527, -2306.0966, 29.493, 255.118), pedModel = 'g_m_m_chicold_01', lobby = 'main' },
    { coords = vector4(1016.14, -2300.690, 29.493, 153.118), pedModel = 'mp_m_freemode_01', lobby = 'main2' },
}

---@class DuelMap
---@field centerCoords vector3 Center of the map
---@field radius? number Optional. Radius of map
---@field mapName string Map display name
---@field teamSpawns table Team spawn points
---@field drawBorder? boolean Optional. Whether to draw the map border
---@field drawBorderDistance? number Optional. Distance to start drawing the border
---@field weapon? string Optional. Required weapon hash

---@ype DuelMap[]
Config.maps = {
    {
        centerCoords = vector3(1043.670, -2334.461, 30.509),
        radius = 50.0,
        mapName = 'docs',
        teamSpawns = {
            team1 = vector4(1045.951, -2311.7143, 29.493, 167.2440),
            team2 = vector4(1040.676, -2359.595, 29.543, 357.165)
        },
        drawBorder = true,
        drawBorderDistance = 40.0,
        weapon = 'WEAPON_PISTOL'
    }
}

-- back-up ped model if createInteraction does not find any
---@type string | number
Config.defaultPedModel = 'g_m_m_chicold_01'


Config.oxInventory = GetResourceState('ox_inventory') ~= 'missing'
Config.reviveEvent = 'esx_ambulancejob:revive'
Config.reviveDelay = 800 -- Delay in ms (how much to wait after revive)
Config.checkDeathMethod = 'natives' -- 'natives' or 'stateBags'
--[[
    natives: checks if ped is dead with IsPedDeadOrDying
    stateBags: check the isDead state bag on player (will wait 2 seconds since state bags do not sync automatically)
]]

Config.anticheat = false -- false | nil, 'fiveguard'
Config.anticheatResourceName = ''
--[[
    Anticheat bypass: made for servers that have certain anticheats which will block spawning of weapons, e.g fiveguard.
    Set Config.anticheat to nil or false if you don't need that.
]]