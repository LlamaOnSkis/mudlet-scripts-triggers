Bowser = Bowser or {}

Bowser.drugInjecting = Bowser.drugInjecting or false
Bowser.drugDelay = 2  -- seconds between injections

function Bowser.injectDrugs()
    if Bowser.drugInjecting then
        return
    end

    local drugs = gmcp.Char
        and gmcp.Char.Guild
        and gmcp.Char.Guild.Drugs

    if not drugs then
        return
    end

    local overdoseChance = tonumber(drugs.OverdoseChance)

    if not overdoseChance or overdoseChance > 14 then
        return
    end

    local drugOrder = {
        "Crack",
        "LSD",
        "Meth",
        "Morphine",
        "Semuta",
        "Steroids",
        "Thyroxine",
    }

    for _, drug in ipairs(drugOrder) do
        if drugs[drug] == "Ready" then

            -- Lock BEFORE sending
            Bowser.drugInjecting = true

            send("inject " .. drug:lower())

            tempTimer(Bowser.drugDelay, function()
                Bowser.drugInjecting = false

                -- Check again after the delay
                Bowser.injectDrugs()
            end)

            return
        end
    end
end

Bowser.injectDrugs()
