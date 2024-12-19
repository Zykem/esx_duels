--[[
    Permissions that get bypassed when joining a duel:
    
    - Spoofed bullet shot (some weapons cause this detection for some reason)
    - Explosion (Player can shoot on objects that will cause explosions -> false-ban)
    - Spoofed Weapons (Player will receive client-sided weapons, so we avoid false-bans by bypassing it just for the deathmatch)
    - Blacklisted weapons (Player wont get weapon removed)

]]

local anticheatResource = Config.anticheatResource

local fiveguardTempPermissions = {
    Client = {
        'BypassSpoofedBulletShot'
    },
    Misc = {
        'BypassExplosion',
        'BypassSpoofedWeapons'
    },
    Weapon = {
        'BypassWeaponDmgModifier'
    },
    Blacklist = {
        'BypassWeaponBlacklist'
    }
}

---@param source number | string
---@param toggle boolean
function TogglePlayerBypass(source, toggle)
    if not Config.anticheat then
        return
    end
    
    if Config.anticheat == 'fiveguard' then
        local anticheatExport = exports[Config.anticheatResourceName]

        assert(anticheatExport ~= nil, 'FiveGuard resource not found.')

        for category, permissions in pairs(fiveguardTempPermissions) do
            for _, permission in ipairs(permissions) do
                anticheatExport:SetTempPermission(source, category, permission, toggle, false)
            end
        end
    end
end