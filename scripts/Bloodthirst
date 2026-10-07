Bowser = Bowser or {}

local status = gmcp.Char
    and gmcp.Char.Guild
    and gmcp.Char.Guild.Bloodthirst
    and gmcp.Char.Guild.Bloodthirst.Status

if status == "Ready" and not Bowser.bloodthirstCooldown then

    Bowser.bloodthirstCooldown = true

    send("bloodthirst")

    tempTimer(2, function()
        Bowser.bloodthirstCooldown = false
    end)

end
