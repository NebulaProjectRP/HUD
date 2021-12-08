NebulaHUD = {}

local playerinfo = Material("nebularp/ui/background.vmt")
local playerLid = Material("nebularp/ui/lid.vmt")
local gradient = Material("vgui/gradient-l")
function NebulaHUD:DrawLocalPlayer()
    local ply = LocalPlayer()
    surface.SetMaterial(playerinfo)
    surface.SetDrawColor(color_white)
    surface.DrawTexturedRect(16, ScrH() - 112, 256, 128)

    draw.SimpleText(ply:Health(), NebulaUI:Font(14), 58, ScrH() - 78, Color(238, 10, 105), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    draw.SimpleText(ply:Armor(), NebulaUI:Font(14), 58, ScrH() - 66, Color(113, 148, 238), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

    local percent = math.Clamp(ply:Health() / ply:GetMaxHealth(), 0, 1)
    surface.SetDrawColor(239, 10, 106)
    surface.DrawRect(62, ScrH() - 75, 149 * percent, 10)
    
    surface.SetMaterial(gradient)
    surface.SetDrawColor(117, 0, 25)
    surface.DrawTexturedRect(62, ScrH() - 75, 149 * percent, 10)

    percent = math.Clamp(ply:Armor() / ply:GetMaxArmor(), 0, 1)

    surface.SetDrawColor(29, 213, 230)
    surface.DrawRect(62, ScrH() - 64, 149 * percent, 10)
    
    surface.SetDrawColor(36, 139, 212)
    surface.DrawTexturedRect(62, ScrH() - 64, 149 * percent, 10)
    draw.SimpleText(RPExtraTeams[ply:Team()].name, NebulaUI:Font(24), 26, ScrH() - 92, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    local money = tostring(DarkRP.formatMoney(ply:getDarkRPVar("money")))
    local space = 0
    draw.SimpleText("$", NebulaUI:Font(16, true), 40, ScrH() - 34, Color(130, 205, 250), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    for k = #money, 2, -1 do
        draw.SimpleText(money[k], NebulaUI:Font(15, true), 208 - space, ScrH() - 33, Color(130, 205, 250), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        space = space + 12
    end

    surface.SetMaterial(playerLid)
    surface.SetDrawColor(RPExtraTeams[ply:Team()].color)
    surface.DrawTexturedRect(18, ScrH() - 111, 256, 128)
end

hook.Add("HUDShouldDraw", "Nebula.HUDShouldDraw", function(el)
    if (el == "DarkRP_LocalPlayerHUD") then return false end
end)

hook.Add("HUDPaint", "Nebula.HUD", function()
    NebulaHUD:DrawLocalPlayer()
end)