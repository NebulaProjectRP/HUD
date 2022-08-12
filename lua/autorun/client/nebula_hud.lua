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
    surface.DrawTexturedRect(margin, ScrH() - (120 + margin), 256, 128)

    draw.SimpleText(ply:Health(), NebulaUI:Font(16), 52 + margin, ScrH() - (76 + margin), Color(238, 10, 105), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    draw.SimpleText(ply:Armor(), NebulaUI:Font(16), 52 + margin, ScrH() - (62 + margin), Color(113, 148, 238), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

    local percent = math.Clamp(ply:Health() / ply:GetMaxHealth(), 0, 1)
    surface.SetDrawColor(239, 10, 106)
    surface.DrawRect(57 + margin, ScrH() - (74 + margin), 187 * percent, 12)
    
    surface.SetMaterial(gradient)
    surface.SetDrawColor(117, 0, 25)
    surface.DrawTexturedRect(57 + margin, ScrH() - (74 + margin), 187 * percent, 12)

    percent = math.Clamp(ply:Armor() / ply:GetMaxArmor(), 0, 1)

    surface.SetDrawColor(29, 213, 230)
    surface.DrawRect(56 + margin, ScrH() - (60 + margin), 188 * percent, 12)
    
    surface.SetDrawColor(36, 139, 212)
    surface.DrawTexturedRect(56 + margin, ScrH() - (60 + margin), 188 * percent, 12)
    if (RPExtraTeams and RPExtraTeams[ply:Team()]) then
        draw.SimpleText(RPExtraTeams[ply:Team()].name, NebulaUI:Font(28), 10 + margin, ScrH() - (96 + margin), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetMaterial(playerLid)
        surface.SetDrawColor(RPExtraTeams[ply:Team()].color)
        surface.DrawTexturedRect(margin, ScrH() - (122 + margin), 256, 128)
    end

    local money = tostring(DarkRP.formatMoney(ply:getDarkRPVar("money")))
    local space = 0
    draw.SimpleText("£", NebulaUI:Font(18, true), 28 + margin, ScrH() - (23 + margin), Color(130, 205, 250), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    for k = #money, 3, -1 do
        draw.SimpleText(money[k], NebulaUI:Font(18, true), (240 + margin) - space, ScrH() - (22 + margin), Color(130, 205, 250), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        space = space + 12
    end

end

local back = surface.GetTextureID("nebularp/ui/weaponback")
local savedStrings = {}
local red = Color(255, 50, 20)
function NebulaHUD:DrawWeaponInfo()
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) then return end

    local class = wep:GetClass()
    if (class == "weapon_physgun" or class == "gmod_tool") then
        local clr = LocalPlayer():GetCount("props") >= LocalPlayer():GetMaxProps() and red or color_white
        local tx, _ = draw.SimpleText(LocalPlayer():GetMaxProps(), NebulaUI:Font(48, true), ScrW() - 36, ScrH() - 168, clr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        local tbx, _ = draw.SimpleText(LocalPlayer():GetCount("props") .. "/", NebulaUI:Font(32, true), ScrW() - 36 - tx, ScrH() - 168, clr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText("Props:", NebulaUI:Font(24), ScrW() - 36 - tx - tbx - 8, ScrH() - 168, clr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end

    surface.SetTexture(back)
    surface.SetDrawColor(color_white)
    surface.DrawTexturedRect(ScrW() - (256 + self.Margin), ScrH() - (128 + self.Margin), 256, 128)
    
    local name = wep:GetPrintName()
    local fontSize = savedStrings[name] or 24
    surface.SetFont(NebulaUI:Font(fontSize, true))
    local tx, _ = 0, 0
    
    tx, _ = surface.GetTextSize(name)
    if (tx > 230) then
        while(tx > 230) do
            fontSize = fontSize - 1
            surface.SetFont(NebulaUI:Font(fontSize, true))
            tx, _ = surface.GetTextSize(name)
        end
    end

    if (AUTOICON_DRAWWEAPONSELECTION) then
        AUTOICON_DRAWWEAPONSELECTION(wep, ScrW() - 94 - self.Margin, ScrH() - 148 - self.Margin, 86, 86, 255)
    end

    draw.SimpleText(name, NebulaUI:Font(fontSize, true), ScrW() - (self.Margin + 8), ScrH() - (46 + self.Margin), Color(223, 49, 133), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    surface.SetDrawColor(Color(255, 255, 255, 200))
    surface.DrawRect(ScrW() - (self.Margin + 238), ScrH() - (36 + self.Margin), 230, 1)

    local ammo = wep:Clip1()
    local maxammo = wep:GetMaxClip1()
    local totalAmmo = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())

    if (ammo <= 0 and totalAmmo <= 0) then
        draw.SimpleText("NO AMMO", NebulaUI:Font(32, true), ScrW() - (self.Margin + 10 + 84), ScrH() - (self.Margin + 78), Color(255, 255, 255, 50), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    elseif (ammo != -1 and totalAmmo >= 0) then
        local tx, _ = draw.SimpleText(totalAmmo, NebulaUI:Font(40, true), ScrW() - (self.Margin + 10 + 84), ScrH() - (self.Margin + 74), Color(255, 255, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(ammo .. "/", NebulaUI:Font(28, true), ScrW() - (self.Margin + 12 + tx + 84), ScrH() - (self.Margin + 78), Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

        local amount = ammo / maxammo
        local pulse = math.cos(RealTime() * 8)
        draw.RoundedBox(8, ScrW() - (self.Margin + 238), ScrH() - (self.Margin + 26), 230, 16, Color(0, 0, 0, 255))
        draw.RoundedBox(8, ScrW() - (self.Margin + 238), ScrH() - (self.Margin + 26), 230 * math.Clamp(amount, 0, 1), 16, amount < .35 and Color(255, 150 + 105 * pulse, 150 + 105 * pulse) or Color(220, 220, 220))
    elseif (ammo == -1 and totalAmmo > 0) then
        draw.SimpleText(totalAmmo, NebulaUI:Font(42, true), ScrW() - (self.Margin + 10 + 80), ScrH() - (self.Margin + 74), Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end
end

local disable = {
    ["DarkRP_LocalPlayerHUD"] = true,
    //["CHudWeapon"] = true,
    ["CHudAmmo"] = true,
    ["CHudDamageIndicator"] = true,
    ["CHudSecondaryAmmo"] = true,
}
hook.Add("HUDShouldDraw", "Nebula.HUDShouldDraw", function(el)
    if (disable[el]) then return false end
end)

hook.Add("HUDPaint", "Nebula.HUD", function()
    if (LocalPlayer():Alive()) then
        NebulaHUD:DrawLocalPlayer()
        NebulaHUD:DrawWeaponInfo()
    end
end)