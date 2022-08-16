hook.Add("HUDPaint", "NebulaHUD.DrawHead", function(ply) end) --p(1):drawPlayerInfo()
local lightRed = Color(255, 75, 0, 200)
local lightBlue = Color(75, 150, 255, 200)
local lightWhite = Color(0, 0, 0, 120)
local yellow = Color(0, 102, 255)
local orange = Color(255, 150, 0, 255)
local gangs_clr = Color(0, 201, 10)
local plyMeta = FindMetaTable("Player")
local gradient_up = Material("vgui/gradient-d")
local gradient_left = Material("vgui/gradient-l")
local icons = Material("nebularp/ui/overhead")
local gradient_mid = Material("gui/center_gradient")
local icon_fun = {}

for k = 1, 4 do
    icon_fun[k] = GWEN.CreateTextureNormal((k - 1) * 64, 0, 64, 64, icons)
end

plyMeta.drawPlayerInfo = function(self)
    if not self.AvatarHUD then
        self.AvatarHUD = vgui.Create("AvatarImage")
        self.AvatarHUD:SetSize(24, 24)
        self.AvatarHUD:SetPlayer(self, 24)

        self.AvatarHUD.Think = function(s)
            if not IsValid(self) then
                s:Remove()
            end
        end

        self.AvatarHUD:SetPaintedManually(true)
    end

    local pos = self:GetPos() + self:OBBCenter() * 1.4 + EyeAngles():Right() * 12
    pos.z = pos.z + 10 -- The position we want is a bit above the position of the eyes
    pos = pos:ToScreen()

    if not self:getDarkRPVar("wanted") then
        -- Move the text up a few pixels to compensate for the height of the text
        pos.y = pos.y - 50
    end

    local nick = self:Nick()
    surface.SetFont(NebulaUI:Font(24))
    local tx, _ = surface.GetTextSize(nick)
    surface.SetMaterial(gradient_mid)
    surface.SetDrawColor(lightWhite)
    surface.DrawTexturedRect(pos.x, pos.y + 6, math.max(tx + 8, 172), 50)
    draw.SimpleText(nick, NebulaUI:Font(24), pos.x + 25, pos.y + 1 + 8, color_black, TEXT_ALIGN_LEFT)
    tx, _ = draw.SimpleText(nick, NebulaUI:Font(24), pos.x + 24, pos.y + 8, color_white, TEXT_ALIGN_LEFT)

    if IsValid(self.AvatarHUD) then
        self.AvatarHUD:SetSize(20, 20)
        self.AvatarHUD:SetPos(pos.x, pos.y + 10)
        self.AvatarHUD:PaintManual()
    end

    local healthWide = math.max(tx, 148)
    local health = math.Clamp(self:Health() / self:GetMaxHealth(), 0, 1)
    local armor = math.Clamp(self:Armor() / self:GetMaxArmor(), 0, 1)
    local push = 0
    surface.SetDrawColor(lightRed)
    surface.DrawRect(pos.x + 4, pos.y + 36, (healthWide - 8) * health, 6)
    surface.SetMaterial(gradient_left)
    surface.SetDrawColor(lightWhite)
    surface.DrawTexturedRect(pos.x + 4, pos.y + 36, (healthWide - 8) * health / 2, 6)

    if armor > 0 then
        surface.SetDrawColor(lightBlue)
        surface.DrawRect(pos.x + 4, pos.y + 36 + 8, (healthWide - 8) * armor, 6)
        surface.SetMaterial(gradient_left)
        surface.SetDrawColor(lightWhite)
        surface.DrawTexturedRect(pos.x + 4, pos.y + 36 + 8, (healthWide - 8) * armor / 2, 6)
        push = 8
    end

    surface.SetDrawColor(color_white)
    surface.DrawRect(pos.x, pos.y + 44 + push, healthWide, 2)
    surface.SetMaterial(gradient_up)
    surface.DrawTexturedRect(pos.x, pos.y + 36, 2, 8 + push)
    surface.DrawTexturedRect(pos.x + healthWide - 2, pos.y + 36, 2, 8 + push)

    if self:hasSuit() then
        surface.SetDrawColor(lightWhite)
        surface.DrawOutlinedRect(pos.x, pos.y + 52 + push, healthWide, 18)
        surface.DrawRect(pos.x, pos.y + 52 + push, healthWide, 18)
        surface.SetMaterial(gradient_left)
        surface.SetDrawColor(orange)
        surface.DrawTexturedRect(pos.x + 1, pos.y + 53 + push, healthWide - 2, 16)
        icon_fun[2](pos.x + 2, pos.y + 53 + push, 16, 16)
        draw.SimpleText(self:getSuitData().Name, NebulaUI:Font(18), pos.x + 18, pos.y + 50 + push, color_white, TEXT_ALIGN_LEFT)
        push = push + 20
    end

    if self:getGang() ~= nil and self:getGang() ~= "" then
        surface.SetDrawColor(lightWhite)
        surface.DrawOutlinedRect(pos.x, pos.y + 52 + push, healthWide, 18)
        surface.DrawRect(pos.x, pos.y + 52 + push, healthWide, 18)
        surface.SetMaterial(gradient_left)
        surface.SetDrawColor(gangs_clr)
        surface.DrawTexturedRect(pos.x + 1, pos.y + 53 + push, healthWide - 2, 16)
        icon_fun[1](pos.x + 2, pos.y + 53 + push, 16, 16)
        draw.SimpleText(self:GetNWString("Gang.Name", ""), NebulaUI:Font(18), pos.x + 18, pos.y + 50 + push, color_white, TEXT_ALIGN_LEFT)
        push = push + 20
    end

    if self:getTitle() ~= nil and self:getTitle() ~= "" and NebulaRanks.Ranks[self:getTitle()] then
        local rank = NebulaRanks.Ranks[self:getTitle()] or NebulaRanks.Ranks.default
        surface.SetDrawColor(lightWhite)
        surface.DrawOutlinedRect(pos.x, pos.y + 52 + push, healthWide, 18)
        surface.DrawRect(pos.x, pos.y + 52 + push, healthWide, 18)
        surface.SetMaterial(gradient_left)
        surface.SetDrawColor(rank.Color)
        surface.DrawTexturedRect(pos.x + 1, pos.y + 53 + push, healthWide - 2, 16)
        icon_fun[4](pos.x, pos.y + 52 + push, 16, 16, color_white)
        draw.SimpleText(rank.Name, NebulaUI:Font(18), pos.x + 18, pos.y + 50 + push, color_white, TEXT_ALIGN_LEFT)
        push = push + 20
    end

    if self:GetUserGroup() ~= "user" then
        surface.SetDrawColor(lightWhite)
        surface.DrawOutlinedRect(pos.x, pos.y + 52 + push, healthWide, 18)
        surface.DrawRect(pos.x, pos.y + 52 + push, healthWide, 18)
        local ct = NebulaUI.UserGroupTags[self:GetUserGroup()] or "User"
        surface.SetMaterial(gradient_left)
        surface.SetDrawColor(yellow)
        surface.DrawTexturedRect(pos.x, pos.y + 53 + push, (healthWide - 8) * 1, 16)
        -- local rank = NebulaRanks.Ranks[self:getTitle()] or NebulaRanks.Ranks.default
        icon_fun[3](pos.x + 1, pos.y + 54 + push, 14, 14, color_white)
        draw.SimpleText(ct, NebulaUI:Font(18), pos.x + 18, pos.y + 50 + push, color_white, TEXT_ALIGN_LEFT)
        push = push + 18
    end
end
--draw.DrawNonParsedText(health, "DarkRPHUD2", pos.x, pos.y + 20, color_white, 1)
--if GAMEMODE.Config.showjob then
--local teamname = self:getDarkRPVar("job") or team.GetName(self:Team())
--   draw.DrawNonParsedText(teamname, "DarkRPHUD2", pos.x, pos.y + 40, color_white, 1)
--end