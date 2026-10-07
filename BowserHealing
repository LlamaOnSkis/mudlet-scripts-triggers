Bowser = Bowser or {}

function Bowser.hpPercent()
    local vitals = gmcp.Char and gmcp.Char.Vitals

    if not vitals or not vitals.hp or not vitals.maxhp or vitals.maxhp == 0 then
        return nil
    end

    return vitals.hp / vitals.maxhp
end

Bowser.healCooldown = 1.5
Bowser.lastHeal = Bowser.lastHeal or nil

function BowserHealing(event)

    local healTable = {
        {0.45, 5, 3},
        {0.55, 4, 1},
        {0.75, 2, 1},
        {0.90, 1, 0},
    }

    local hp = Bowser.hpPercent()

    if not hp then
        return
    end

    local now = getEpoch()

    -- Only block if I've actually healed recently
    if Bowser.lastHeal and
       (now - Bowser.lastHeal) < Bowser.healCooldown then
        return
    end

    for _, heal in ipairs(healTable) do
        local threshold, slices, binds = unpack(heal)

        if hp < threshold then
            local cmds = {}

            for i = 1, slices do
                cmds[#cmds + 1] = "eat slice"
            end

            for i = 1, binds do
                cmds[#cmds + 1] = "bind"
            end

            sendAll(unpack(cmds))

            Bowser.lastHeal = now

            --cecho(string.format(
              --  "\n<green>Healing at %.1f%% HP\n",
             --   hp * 100
           -- ))

            break
        end
    end
end
