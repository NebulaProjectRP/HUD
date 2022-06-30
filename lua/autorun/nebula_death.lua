local validDecals = {}
local meta = FindMetaTable("Player")

if SERVER then
    util.AddNetworkString("NebulaRP.SetDecal")
    util.AddNetworkString("NebulaRP.SyncDecals")
    util.AddNetworkString("NebulaRP.SendDeath")
end

function meta:setDeathDecal(decal)
    if not validDecals[decal] then MsgN("Not valid decal") return end

    if (SERVER and self._decals[decal] == nil) then
        return
    elseif (CLIENT and NebulaInv.Decals[decal] == nil) then
        return
    end

    for k, v in pairs(SERVER and self._decals or NebulaInv.Decals) do
        if (v) then
            if SERVER then
                self._decals[k] = false
            else
                NebulaInv.Decals[k] = false
            end
            break
        end
    end

    if SERVER then
        self._decals[decal] = true
    else
        NebulaInv.Decals[decal] = true
    end

    self:SetNWString("DecalName", decal)
    if CLIENT then
        net.Start("NebulaRP.SetDecal")
        net.WriteString(decal)
        net.SendToServer()
    else
        MsgN("Saving decal")
        self:saveDecal()
    end
end

if SERVER then
    function meta:addDecal(decal)
        if not validDecals[decal] then return end
        self:SetNWString("DecalName", decal)
        if not self._decals[decal] then
            self._decals[decal] = true
            self:saveDecal()
        end
    end

    function meta:giveDecals()
        local decals = 4
        local selected = true
        self._decals = {}
        for id, _ in RandomPairs(validDecals) do
            self._decals[id] = selected
            if (selected) then
                self:SetNWString("DecalName", id)
            end
            selected = false
            decals = decals - 1
            if (decals <= 0) then
                break
            end
        end
        self:saveDecal()
        net.Start("NebulaRP.SyncDecals")
        net.WriteUInt(table.Count(self._decals), 8)
        for id, eq in pairs(self._decals) do
            net.WriteString(id)
            net.WriteBool(eq)
        end
        net.Send(self)
    end
end

net.Receive("NebulaRP.SetDecal", function(l, ply)
    ply:setDeathDecal(net.ReadString())
end)

net.Receive("NebulaRP.SyncDecals", function()
    local count = net.ReadUInt(8)
    NebulaInv.Decals = {}
    for k = 1, count do
        NebulaInv.Decals[net.ReadString()] = net.ReadBool()
    end
end)

local progress = 0
local targetView
local idealAng
local idealFov = 60
hook.Add("CalcView", "NebulaRP.ShowDeathCam", function(ply, pos, ang, fov, near, far)
    if (ply:Alive()) then return end
    if not targetView then return end
    if not idealAng then return end
    if not IsValid(ply._killerEntity) then
        ply._killerEntity = ply
    end
    if not IsValid(ply:GetRagdollEntity()) then return end

    if (progress <= 1) then
        progress = progress + FrameTime()
    end

    local idealTarget = ply:GetRagdollEntity():GetPos() + ply:GetViewOffset()
    local diff = (ply._killerEntity:GetShootPos() - idealTarget):GetNormalized():Angle()

    targetView = LerpVector(progress, targetView, idealTarget)
    idealAng = LerpAngle(FrameTime() * 10, idealAng, diff)

    local dist = math.Clamp(idealTarget:Distance(ply._killerEntity:GetPos()), 200, 1024) / 1024
    idealFov = Lerp(FrameTime() * 5, idealFov, math.Clamp((1 - dist) * 100, 10, 120))
    return {
        origin = targetView,
        angles = idealAng,
        fov = idealFov
    }
end)

local tab = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"] = 1,
    ["$pp_colour_colour"] = 1,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}

hook.Add("RenderScreenspaceEffects", "NebulaRP.DrawDeath", function()
    local ply = LocalPlayer()
    if (ply:Alive()) then return end

    tab["$pp_colour_colour"] = .1 + (1 - progress) * .9
    tab["$pp_colour_mulr"] = progress * .15
    DrawColorModify(tab)
end)

net.Receive("NebulaRP.SendDeath", function()
    progress = 0
    targetView = LocalPlayer():GetShootPos()
    idealAng = EyeAngles()
    idealFov = LocalPlayer():GetFOV()
    LocalPlayer()._killerEntity = net.ReadEntity() or LocalPlayer()

    local pnl = vgui.Create("DPanel")
    local idealY = ScrH() - 196
    if IsValid(NebulaUI.DamageUI) then
        idealY = ScrH() - 196 - 72
    end

    pnl:SetSize(256, 64)
    pnl:SetPos(ScrW() / 2 - 128, ScrH())
    pnl:MoveTo(ScrW() / 2 - 128, idealY, 0.5, 0)
    pnl:SetAlpha(0)
    pnl:AlphaTo(255, .5, 0)
    local iconName = (IsValid(LocalPlayer()._killerEntity) and LocalPlayer()._killerEntity or LocalPlayer()):GetNWString("DecalName")
    pnl.Icon = Material("nebularp/decals/" .. iconName)
    pnl.Attacker = LocalPlayer()._killerEntity:Nick()
    pnl.Disposed = false
    pnl.Paint = function(s, w, h)
        NebulaUI.Derma.TextEntry(0, 0, w, h)
        surface.SetMaterial(s.Icon)
        surface.SetDrawColor(color_white)
        DisableClipping(true)
        surface.DrawTexturedRectRotated(w / 2, -56, 96, 96, 0)
        DisableClipping(false)
        draw.SimpleText("You were killed by:", NebulaUI:Font(24), w / 2, 4, Color(255, 255, 255, 100), 1, 0)
        draw.SimpleText(s.Attacker, NebulaUI:Font(32), w / 2, 8 + 16, color_white, 1, 0)
        if s:GetAlpha() > 200 and not s.Disposed and LocalPlayer():Alive() then
            s.Disposed = true
            s:AlphaTo(0, .3, 0, function()
                s:Remove()
            end)
        end
    end
    NebulaUI.DeathPanel = pnl
end)

hook.Add("PlayerDeath", "NebulaRP.DeathSend", function(ply, inf, att)
    net.Start("NebulaRP.SendDeath")
    net.WriteEntity(att)
    net.Send(ply)
end)

local files, _ = file.Find("materials/nebularp/decals/*.vmt", "GAME")
for _, id in pairs(files) do
    local name = string.sub(id, 1, -5)
    validDecals[name] = true
end
