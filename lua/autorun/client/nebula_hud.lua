NebulaHUD = {}

local playerinfo = Material("nebularp/ui/background.vmt")
local playerLid = Material("nebularp/ui/lid.vmt")
local gradient = Material("vgui/gradient-l")

local img_path = "NebulaHUD.Player" .. os.time()
local avatar_rt = GetRenderTargetEx(img_path, 256, 256, -1, MATERIAL_RT_DEPTH_SHARED, 512, 0, -1)
local avatar_mat = CreateMaterial(img_path, "UnlitGeneric", {
    ["$basetexture"] = avatar_rt:GetName(),
    ["$alphatest"] = 1,
    ["$allowAlphaToCoverage"] = 1,
    ["$alphatestreference"] = 1,
})

local lightWhite = Color(255, 255, 255, 25)
local darkColor = Color(16, 18, 20, 250)
local healthColor = Color(224, 19, 47)
local healthColorBright = Color(255, 123, 0, 50)
local armorColor = Color(20, 122, 255)
local armorColorBright = Color(83, 221, 255, 125)
local greenColor = Color(43, 199, 77)

local gr = surface.GetTextureID("vgui/gradient-d")
local darkCircle = Material("ui/asap/shadow")
local lastKnownModel

NebulaHUD.Margin = 32

local back = surface.GetTextureID("nebularp/ui/weaponback")
local savedStrings = {}
local red = Color(255, 50, 20)
local purple = Color(223, 49, 133)
function NebulaHUD:DrawWeaponInfo()
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) then return end

    surface.SetDrawColor(color_white)
    surface.SetMaterial(darkCircle)
    surface.DrawTexturedRectUV(ScrW() - 400, ScrH() - 200, 400, 512, 1, 0, 0, 1)

    local class = wep:GetClass()
    local isBuilder = class == "weapon_physgun" or class == "gmod_tool"
    if (isBuilder) then
        local clr = LocalPlayer():GetCount("props") >= LocalPlayer():GetMaxProps() and red or color_white
        local tx, _ = draw.SimpleText(LocalPlayer():GetMaxProps(), NebulaUI:Font(52), ScrW() - 16, ScrH() - 4, clr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        local tbx, _ = draw.SimpleText(LocalPlayer():GetCount("props") .. "/", NebulaUI:Font(32), ScrW() - 20 - tx, ScrH() - 8, clr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText("Props:", NebulaUI:Font(24), ScrW() - 20 - tx - tbx - 8, ScrH() - 8, clr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end

    local name = wep:GetPrintName()
    local fontSize = savedStrings[name] or 32
    surface.SetFont(NebulaUI:Font(fontSize, true))
    local tx, _ = 0, 0

    tx, _ = surface.GetTextSize(name)
    if (tx > 400) then
        while (tx > 400) do
            fontSize = fontSize - 1
            surface.SetFont(NebulaUI:Font(fontSize, true))
            tx, _ = surface.GetTextSize(name)
        end
    end

    if (AUTOICON_DRAWWEAPONSELECTION) then
        AUTOICON_DRAWWEAPONSELECTION(wep, ScrW() - 128, ScrH() - 200, 128, 128, 255)
        AUTOICON_DRAWWEAPONSELECTION(wep, ScrW() - 128, ScrH() - 200, 128, 128, 255)
    end

    draw.SimpleText(name, NebulaUI:Font(fontSize, true), ScrW() - 16, ScrH() - 56, purple, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    surface.SetDrawColor(Color(255, 255, 255, 200))
    surface.DrawRect(ScrW() - 256 - 16, ScrH() - 52, 256, 1)

    if (isBuilder) then return end

    local ammo = wep:Clip1()
    local maxammo = wep:GetMaxClip1()
    local totalAmmo = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())

    if (ammo <= 0 and totalAmmo <= 0) then
        draw.SimpleText("NO AMMO", NebulaUI:Font(32, true), ScrW() - 16, ScrH() - 8, Color(255, 255, 255, 50), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    elseif (ammo != -1 and totalAmmo >= 0) then
        local tx, _ = draw.SimpleText(totalAmmo, NebulaUI:Font(40, true), ScrW() - 16, ScrH() - 6, Color(255, 255, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(ammo .. "/", NebulaUI:Font(28, true), ScrW() - 20 - tx, ScrH() - 6, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

        local amount = ammo / maxammo
        local pulse = math.cos(RealTime() * 8)
        draw.RoundedBox(0, ScrW() - 272, ScrH() - 46, 256 - tx - 8, 8, Color(0, 0, 0, 255))
        draw.RoundedBox(0, ScrW() - 271, ScrH() - 45, (254 - tx - 8) * math.Clamp(amount, 0, 1), 6, amount < .35 and Color(255, 150 + 105 * pulse, 150 + 105 * pulse) or Color(220, 220, 220))
    elseif (ammo == -1 and totalAmmo > 0) then
        draw.SimpleText(totalAmmo, NebulaUI:Font(42, true), ScrW() - 16, ScrH() - 6, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end
end

if IsValid(ply_avatar) then
    ply_avatar:Remove()
end

NebulaHUD.MatWritten = false
function NebulaHUD:DrawPlayer()
    if (self.MatWritten) then
        surface.SetMaterial(darkCircle)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(0, ScrH() - 200, 600, 512, 0)
        surface.SetMaterial(avatar_mat)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(-16, ScrH() - 256, 256, 256)
        
        draw.RoundedBoxEx(8, -1, ScrH() - 37, 322, 38, lightWhite, true, false, false, false)
        draw.RoundedBoxEx(8, 0, ScrH() - 36, 320, 36, darkColor, true, false, false, false)

        local p = LocalPlayer()
        local armor = p:Armor()
        local health = p:Health()
        local maxHealth = p:GetMaxHealth()
        local maxArmor = p:GetMaxArmor()

        draw.RoundedBox(6, 4, ScrH() - 32, 312, armor > 0 and 18 or 20, color_black)
        draw.RoundedBox(6, 4, ScrH() - 12, 312, 8, color_black)

        local healthAmount = math.Clamp(health / maxHealth, 0, 1)
        draw.RoundedBox(6, 5, ScrH() - 31, 310 * healthAmount, armor > 0 and 16 or 26, healthColor)
        surface.SetTexture(gr)
        surface.SetDrawColor(healthColorBright)
        surface.DrawTexturedRect(5, ScrH() - 31, 310 * healthAmount, armor > 0 and 16 or 26)

        if (armor > 0) then
            local tx, _ = draw.SimpleText(health, NebulaUI:Font(24), 10, ScrH() - 36, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("/" .. maxHealth, NebulaUI:Font(18), 10 + tx, ScrH() - 31, lightWhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            local armorAmount = math.Clamp(armor / maxArmor, 0, 1)
            draw.RoundedBox(6, 5, ScrH() - 11, 310 * armorAmount, 6, armorColor)
            surface.SetTexture(gr)
            surface.SetDrawColor(armorColorBright)
            surface.DrawTexturedRect(5, ScrH() - 11, 310 * armorAmount, 6)
        else
            local tx, _ = draw.SimpleText(health, NebulaUI:Font(32), 10, ScrH() - 36, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("/" .. maxHealth, NebulaUI:Font(20), 12 + tx, ScrH() - 26, lightWhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local x = 148
        local y = ScrH() - 67
        draw.RoundedBoxEx(8, x - 1, y - 1, 174, 31, lightWhite, true, true, false, false)
        draw.RoundedBoxEx(8, x, y, 172, 30, darkColor, true, true, false, false)

        draw.RoundedBoxEx(8, x + 4, y + 4, 164, 22, color_black, true, true, false, false)

        local money = tostring(DarkRP.formatMoney(p:getDarkRPVar("money")))
        local space = 0
        local margin = 0
        x = 166
        y = y + 16
        draw.SimpleText("£", NebulaUI:Font(22, false), x + margin, y, greenColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        for k = #money, 3, -1 do
            draw.SimpleText(money[k], NebulaUI:Font(22, false), (x + margin) - space + 146, y, greenColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            space = space + 10
        end

        x = x - 20
        draw.SimpleText(p:Nick(), NebulaUI:Font(22, false), x, y - 46, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(team.GetName(p:Team()), NebulaUI:Font(20, false), x, y - 28, team.GetColor(p:Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        return
    end
    if not IsValid(LocalPlayer()) or IsValid(ply_avatar) then return end

    ply_avatar = vgui.Create("DModelPanel")
    ply_avatar:SetSize(200, 256)
    ply_avatar:SetMouseInputEnabled(false)

    ply_avatar:SetModel(LocalPlayer():GetModel())
    ply_avatar.LayoutEntity = function() end

    ply_avatar:SetFOV(35)
    local boneid = ply_avatar.Entity:LookupBone("ValveBiped.Bip01_Head1")
    if boneid then
        local headPos, _ = ply_avatar.Entity:GetBonePosition(boneid)
        local radius = ply_avatar.Entity:GetModelRadius()
        ply_avatar:SetCamPos(headPos + Vector(radius / 2, -radius / 3, 0))
        ply_avatar:SetLookAt(headPos)
    else
        local headPos = Vector(0, 0, 68)
        local radius = ply_avatar.Entity:GetModelRadius()
        ply_avatar:SetCamPos(headPos + Vector(radius / 2, -radius / 3, 0))
        ply_avatar:SetLookAt(headPos)
    end
    ply_avatar:SetPaintedManually(true)

    cam.IgnoreZ(true)
    render.PushRenderTarget(avatar_rt)
    render.ClearDepth()
    render.Clear(0, 0, 0, 0)
    render.SetWriteDepthToDestAlpha( false )
    render.SuppressEngineLighting(true)

    ply_avatar:Paint(200, 256)

    render.SuppressEngineLighting(false)
    render.SetWriteDepthToDestAlpha( false )
    render.PopRenderTarget()
    cam.IgnoreZ(false)

    avatar_mat:SetTexture("$basetexture", avatar_rt)
    self.MatWritten = true

    ply_avatar:Remove()

    lastKnownModel = LocalPlayer():GetModel()
    timer.Create("VerifyPlayerModel", 3, 0, function()
        if (lastKnownModel != LocalPlayer():GetModel()) then
            self.MatWritten = false
        end
    end)
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
        //NebulaHUD:DrawLocalPlayer()
        NebulaHUD:DrawPlayer()
        NebulaHUD:DrawWeaponInfo()
    end
end)