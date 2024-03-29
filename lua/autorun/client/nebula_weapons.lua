local cachedHistory = {}
local slot = 0
local inner = 0
local alpha = 0
local hold = 0
local active = false
local fadeOut = false
local w = 96
local h = 48
local limits = {}

hook.Add("HUDPaint", "NebulaRP.WeaponSelector", function()
    if not active then return end

    if not fadeOut and alpha <= 255 then
        alpha = Lerp(FrameTime() * 4, alpha, 260)

        if alpha > 255 then
            fadeOut = true
            alpha = 255
            hold = 2
        end
    elseif fadeOut and alpha > 0 then
        if hold > 0 then
            hold = hold - FrameTime()
        else
            alpha = Lerp(FrameTime() * 16, alpha, -1)

            if alpha <= 0 then
                active = false
            end
        end
    end

    local totalHeight = 8

    for k = 1, 6 do
        w = 96
        local tAlpha = alpha / 255

        if slot ~= k then
            tAlpha = tAlpha * 0.7
        end

        local hasCache = cachedHistory[k] ~= nil
        totalHeight = totalHeight + (not hasCache and 16 or (w + 8))
        local x, y = ScrW() / 2 - w * 4.5 + totalHeight, 32

        if not hasCache then
            tAlpha = tAlpha * 0.5
            x = x + w * 1 - 8
            draw.RoundedBox(4, x, y, 8, h, Color(255, 255, 255, 10 * tAlpha))
            draw.RoundedBox(4, x + 1, y + 1, 6, h - 2, Color(16, 0, 24, 250 * tAlpha))
        else
            draw.RoundedBox(8, x, y, w, h, Color(255, 255, 255, 10 * tAlpha))
            draw.RoundedBox(8, x + 1, y + 1, w - 2, h - 2, Color(16, 0, 24, 250 * tAlpha))
            draw.SimpleText(k, NebulaUI:Font(32, true), x + w / 2, y + h / 2, Color(255, 255, 255, tAlpha * (slot == k and 255 or 100)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            if slot == k then
                w = 128
                y = y + 52
                x = x - w * 1 - 8

                for i, control in pairs(cachedHistory[k]) do
                    if not IsValid(control.Weapon) then continue end
                    if i == inner then
                        draw.RoundedBox(8, x + (w + 8) * i - 1, y - 1, w + 2, 94, Color(255, 255, 255, 15 * tAlpha))
                    end

                    draw.RoundedBox(8, x + (w + 8) * i, y, w, 92, Color(16, 0, 24, (i == inner and 255 or 100) * tAlpha))
                    AUTOICON_DRAWWEAPONSELECTION(control.Weapon, x + (w + 8) * i, y - 18, 128, 88, (i == inner and not fadeOut) and 255 or 150 * tAlpha)

                    if i == inner then
                        draw.SimpleText(control.Weapon:GetPrintName(), NebulaUI:Font(18), x + (w + 8) * i + w / 2, y + h + 28, Color(255, 255, 255, 255 * tAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        AUTOICON_DRAWWEAPONSELECTION(control.Weapon, x + (w + 8) * i, y - 18, 128, 88, 255 * tAlpha)
                    elseif IsValid(control.Weapon) then
                        draw.SimpleText(control.Weapon:GetPrintName(), NebulaUI:Font(18), x + (w + 8) * i + w / 2, y + h + 28, Color(190, 94, 209, 255 * tAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
            end
        end
    end
end)

local function createCache()
    local ply = LocalPlayer()
    if table.Count(ply:GetWeapons()) == 0 then return false end
    cachedHistory = {}

    for k, v in pairs(ply:GetWeapons()) do
        local wepSlot = v:GetSlot() + 1
        limits[1] = math.min(limits[1] or wepSlot, wepSlot)
        limits[2] = math.max(limits[2] or wepSlot, wepSlot)

        if not cachedHistory[wepSlot] then
            cachedHistory[wepSlot] = {}
        end

        table.insert(cachedHistory[wepSlot], {
            Slot = v:GetSlotPos(),
            Weapon = v
        })
    end

    for k, v in pairs(cachedHistory) do
        table.sort(v, function(a, b) return a.Slot > b.Slot end)
    end

    local wep = ply:GetActiveWeapon()

    if IsValid(wep) then
        slot = wep:GetSlot() + 1

        for k, v in pairs(cachedHistory[slot]) do
            if v.Weapon == wep then
                inner = k
                break
            end
        end
    else
        for k, v in pairs(ply:GetWeapons()) do
            slot = v:GetSlot() + 1
            inner = 1
            break
        end
    end
end

local fast = GetConVar("hud_fastswitch")

hook.Add("PlayerBindPress", "NebulaRP.WeaponSelector", function(ply, bind, pressed)
    if fast:GetBool() then return end
    if not pressed then return end

    if IsValid(NebulaTarot.CardHUD) and NebulaTarot.CardHUD.ShouldDisplay then
        return
    end

    if active and bind == "+attack" then
        surface.PlaySound("common/wpn_hudoff.wav")
        RunConsoleCommand("use", cachedHistory[slot][inner].Weapon:GetClass())
        alpha = 125
        fadeOut = true
        hold = 0

        return true
    elseif active and bind == "+attack2" and LocalPlayer():GetActiveWeapon():GetClass() ~= "gmod_camera" then
        alpha = 125
        fadeOut = true
        hold = 0
        surface.PlaySound("ui/hint.wav")

        return true
    end

    if string.StartWith(bind, "slot") then
        local pos = tonumber(string.sub(bind, 5))
        if pos > 6 then return end

        if not active then
            createCache()
            if cachedHistory[pos] == nil then return end
            surface.PlaySound("ui/hint.wav")
            active = true
            fadeOut = false
            hold = 0
            slot = pos
            inner = 1
        elseif cachedHistory[pos] then
            inner = inner + 1

            if inner > table.Count(cachedHistory[pos]) then
                inner = 1
            end

            fadeOut = false
            hold = 0
            slot = pos
        end

        surface.PlaySound("ui/buttonclick.wav")

        return true
    end

    if bind == "invprev" or bind == "invnext" then
        if input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT) then return true end
        surface.PlaySound("common/talk.wav")

        if not active then
            local res = createCache()
            if res == false then return false end
        else
            inner = inner + (bind == "invprev" and 1 or -1)

            if inner < 1 then
                slot = slot - 1

                while not cachedHistory[slot] do
                    slot = slot - 1

                    if slot < 1 then
                        slot = limits[2]
                    end
                end

                inner = #cachedHistory[slot]
            elseif inner > #cachedHistory[slot] then
                slot = slot + 1
                inner = 1

                while not cachedHistory[slot] do
                    slot = slot + 1

                    if slot > limits[2] then
                        slot = limits[1]
                    end
                end
            end
        end

        active = true
        fadeOut = false
        hold = 0

        return true
    end
end)