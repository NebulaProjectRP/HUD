NebulaHUD = {}

local playerinfo = Material("nebularp/ui/background.vmt")
local playerLid = Material("nebularp/ui/lid.vmt")
local gradient = Material("vgui/gradient-l")
NebulaHUD.Margin = 32
function NebulaHUD:DrawLocalPlayer()
    local margin = self.Margin
    local ply = LocalPlayer()
    surface.SetMaterial(playerinfo)
    surface.SetDrawColor(color_white)
    surface.DrawTexturedRect(margin, ScrH() - (98 + margin), 256, 128)

    draw.SimpleText(ply:Health(), NebulaUI:Font(14), 42 + margin, ScrH() - (62 + margin), Color(238, 10, 105), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    draw.SimpleText(ply:Armor(), NebulaUI:Font(14), 42 + margin, ScrH() - (50 + margin), Color(113, 148, 238), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

    local percent = math.Clamp(ply:Health() / ply:GetMaxHealth(), 0, 1)
    surface.SetDrawColor(239, 10, 106)
    surface.DrawRect(46 + margin, ScrH() - (59 + margin), 149 * percent, 10)
    
    surface.SetMaterial(gradient)
    surface.SetDrawColor(117, 0, 25)
    surface.DrawTexturedRect(46 + margin, ScrH() - (59 + margin), 149 * percent, 10)

    percent = math.Clamp(ply:Armor() / ply:GetMaxArmor(), 0, 1)

    surface.SetDrawColor(29, 213, 230)
    surface.DrawRect(46 + margin, ScrH() - (48 + margin), 149 * percent, 10)
    
    surface.SetDrawColor(36, 139, 212)
    surface.DrawTexturedRect(46 + margin, ScrH() - (48 + margin), 149 * percent, 10)
    if (RPExtraTeams and RPExtraTeams[ply:Team()]) then
        draw.SimpleText(RPExtraTeams[ply:Team()].name, NebulaUI:Font(24), 10 + margin, ScrH() - (76 + margin), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local money = tostring(DarkRP.formatMoney(ply:getDarkRPVar("money")))
    local space = 0
    draw.SimpleText("$", NebulaUI:Font(16, true), 24 + margin, ScrH() - (19 + margin), Color(130, 205, 250), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    for k = #money, 2, -1 do
        draw.SimpleText(money[k], NebulaUI:Font(15, true), (192 + margin) - space, ScrH() - (19 + margin), Color(130, 205, 250), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        space = space + 12
    end

    surface.SetMaterial(playerLid)
    surface.SetDrawColor(RPExtraTeams[ply:Team()].color)
    surface.DrawTexturedRect(2 + margin, ScrH() - (98 + margin), 256, 128)
end

local back = surface.GetTextureID("nebularp/ui/weaponback")
function NebulaHUD:DrawWeaponInfo()
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) then return end

    surface.SetTexture(back)
    surface.SetDrawColor(color_white)
    surface.DrawTexturedRect(ScrW() - (256 + self.Margin), ScrH() - (96 + self.Margin), 256, 128)
    
    local tx, ty = draw.SimpleText(wep:GetPrintName(), NebulaUI:Font(18, true), ScrW() - (self.Margin + 8), ScrH() - (34 + self.Margin), Color(223, 49, 133), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    surface.SetDrawColor(Color(255, 255, 255, 200))
    surface.DrawRect(ScrW() - (self.Margin + 178), ScrH() - (28 + self.Margin), 172, 1)

    local ammo = wep:Clip1()
    local maxammo = wep:GetMaxClip1()
    local totalAmmo = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())

    if (ammo <= 0 and totalAmmo <= 0) then
        draw.SimpleText("- NO AMMO -", NebulaUI:Font(28, true), ScrW() - (self.Margin + 84), ScrH() - (self.Margin + 56), Color(255, 255, 255, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    elseif (ammo != -1 and totalAmmo > 0) then
        local tx, _ = draw.SimpleText(totalAmmo, NebulaUI:Font(32, true), ScrW() - (self.Margin + 10), ScrH() - (self.Margin + 56), Color(255, 255, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(ammo .. "/", NebulaUI:Font(24, true), ScrW() - (self.Margin + 12 + tx), ScrH() - (self.Margin + 56), Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

        local amount = ammo / maxammo
        local pulse = math.cos(RealTime() * 8)
        draw.RoundedBox(8, ScrW() - (self.Margin + 178), ScrH() - (self.Margin + 22), 172, 16, Color(0, 0, 0, 255))
        draw.RoundedBox(8, ScrW() - (self.Margin + 178), ScrH() - (self.Margin + 22), 172 * math.Clamp(amount, 0, 1), 16, amount < .35 and Color(255, 150 + 105 * pulse, 150 + 105 * pulse) or Color(220, 220, 220))
    elseif (ammo == -1 and totalAmmo > 0) then
        draw.SimpleText(totalAmmo, NebulaUI:Font(32, true), ScrW() - (self.Margin + 10), ScrH() - (self.Margin + 56), Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end
end

local disable = {
    ["DarkRP_LocalPlayerHUD"] = true,
    ["CHudWeapon"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
}
hook.Add("HUDShouldDraw", "Nebula.HUDShouldDraw", function(el)
    if (disable[el]) then return false end
    //MsgN(el)
end)

hook.Add("HUDPaint", "Nebula.HUD", function()
    NebulaHUD:DrawLocalPlayer()
    NebulaHUD:DrawWeaponInfo()
end)