Bowser = Bowser or {}

--------------------------------------------------
-- CONFIGURATION
--------------------------------------------------

Bowser.characterName = "Bowser"

-- Circular hunting route
Bowser.route = {
    "east",
    "northeast",
    "north",
    "door",
    "out",
    "north",
    "north",
    "door",
    "out",
    "north",
    "north",
    "door",
    "south",
    "north",
    "north",
    "south",
    "west",
    "south",
    "north",
    "north",
    "south",
    "west",
    "south",
    "north",
    "north",
    "south",
    "west",
    "south",
    "north",
    "north",
    "south",
    "out",
    "south",
    "south",
    "door",
    "out",
    "south",
    "south",
    "door",
    "out",
    "south",
    "southeast",
    "east"
}

--------------------------------------------------
-- TIMING
--------------------------------------------------

-- Time to collect room output after "look"
Bowser.roomScanDelay = 0.75

-- Time after a kill before sending the next fkill.
-- Gives corpse/loot triggers time to run.
Bowser.afterCombatDelay = 1.5

-- Time after moving before scanning the new room.
Bowser.afterMoveDelay = 0.50

-- Time after waking from coma before resuming.
Bowser.afterComaDelay = 0.75


--------------------------------------------------
-- STATE
--------------------------------------------------

Bowser.hunt = Bowser.hunt or {}

-- Only initialize these if they do not already exist.
-- This prevents the script from accidentally stopping
-- an active hunt if Mudlet executes it again.

if Bowser.hunt.active == nil then
    Bowser.hunt.active = false
end

Bowser.hunt.state = Bowser.hunt.state or "stopped"
Bowser.hunt.path = Bowser.hunt.path or {}
Bowser.hunt.enemies = Bowser.hunt.enemies or 0

if Bowser.hunt.contested == nil then
    Bowser.hunt.contested = false
end

Bowser.hunt.contestedBy = Bowser.hunt.contestedBy

if Bowser.hunt.coma == nil then
    Bowser.hunt.coma = false
end

-- Separate timers for separate jobs.
Bowser.hunt.roomTimer = Bowser.hunt.roomTimer
Bowser.hunt.moveTimer = Bowser.hunt.moveTimer
Bowser.hunt.combatTimer = Bowser.hunt.combatTimer
Bowser.hunt.comaTimer = Bowser.hunt.comaTimer


--------------------------------------------------
-- COPY ROUTE
--------------------------------------------------

function Bowser.copyRoute()

    local copy = {}

    for i, direction in ipairs(Bowser.route) do
        copy[i] = direction
    end

    return copy
end


--------------------------------------------------
-- CANCEL TIMER
--------------------------------------------------

function Bowser.cancelTimer(timerName)

    local timer = Bowser.hunt[timerName]

    if timer then
        killTimer(timer)
        Bowser.hunt[timerName] = nil
    end
end


--------------------------------------------------
-- CANCEL ALL HUNT TIMERS
--------------------------------------------------

function Bowser.cancelHuntTimers()

    Bowser.cancelTimer("roomTimer")
    Bowser.cancelTimer("moveTimer")
    Bowser.cancelTimer("combatTimer")
    Bowser.cancelTimer("comaTimer")
end


--------------------------------------------------
-- START HUNT
--------------------------------------------------

function Bowser.startRoute()

    if Bowser.hunt.active then

        cecho(
            "\n<yellow>[HUNT] Already running. State: "
            .. tostring(Bowser.hunt.state)
            .. "\n"
        )

        return
    end

    Bowser.cancelHuntTimers()

    Bowser.hunt.active = true
    Bowser.hunt.state = "ready"

    Bowser.hunt.path = Bowser.copyRoute()

    Bowser.hunt.enemies = 0

    Bowser.hunt.contested = false
    Bowser.hunt.contestedBy = nil

    Bowser.hunt.coma = false

    cecho(
        "\n<green>[HUNT] Started.\n"
    )

    Bowser.enterRoom()
end


--------------------------------------------------
-- STOP HUNT
--------------------------------------------------

function Bowser.stopHunt()

    --------------------------------------------------
    -- DEBUG
    -- If the hunt ever mysteriously stops, this
    -- message tells us stopHunt() was actually called.
    --------------------------------------------------

    cecho(
        "\n<red>[HUNT] stopHunt() called. Previous state: "
        .. tostring(Bowser.hunt.state)
        .. "\n"
    )

    Bowser.hunt.active = false
    Bowser.hunt.state = "stopped"

    Bowser.hunt.path = {}
    Bowser.hunt.enemies = 0

    Bowser.hunt.contested = false
    Bowser.hunt.contestedBy = nil

    Bowser.hunt.coma = false

    Bowser.cancelHuntTimers()

    cecho(
        "<red>[HUNT] Stopped.\n"
    )
end


--------------------------------------------------
-- ENTER / SCAN CURRENT ROOM
--------------------------------------------------

function Bowser.enterRoom()

    if not Bowser.hunt.active then
        return
    end

    if Bowser.hunt.coma then
        return
    end

    --------------------------------------------------
    -- BEGIN FRESH ROOM SCAN
    --------------------------------------------------

    Bowser.hunt.state = "scanning"

    Bowser.hunt.enemies = 0

    Bowser.hunt.contested = false
    Bowser.hunt.contestedBy = nil

    -- Only cancel the room scan timer here.
    -- Do NOT touch combatTimer.
    Bowser.cancelTimer("roomTimer")

    cecho(
        "\n<cyan>[HUNT] Scanning room...\n"
    )

    send("look")

    --------------------------------------------------
    -- WAIT FOR ROOM OUTPUT
    --------------------------------------------------

    Bowser.hunt.roomTimer = tempTimer(
        Bowser.roomScanDelay,
        function()

            Bowser.hunt.roomTimer = nil

            if not Bowser.hunt.active then
                return
            end

            if Bowser.hunt.coma then
                return
            end

            if Bowser.hunt.state ~= "scanning" then
                return
            end

            --------------------------------------------------
            -- SOMEONE ELSE OWNS A MOB
            --------------------------------------------------

            if Bowser.hunt.contested then

                cecho(
                    "\n<magenta>[HUNT] Room contested by "
                    .. tostring(Bowser.hunt.contestedBy)
                    .. " - skipping.\n"
                )

                Bowser.hunt.state = "ready"

                Bowser.moveNext()

                return
            end

            --------------------------------------------------
            -- ROOM IS AVAILABLE
            --------------------------------------------------

            Bowser.hunt.state = "ready"

            Bowser.clearRoom()
        end
    )
end


--------------------------------------------------
-- TAGGED MOB DETECTED
--------------------------------------------------

function Bowser.contestedRoom(playerName)

    --------------------------------------------------
    -- IMPORTANT:
    --
    -- Random "look" commands may display tagged mobs.
    -- We ONLY care about tags while our hunting script
    -- is deliberately scanning a room.
    --------------------------------------------------

    if not Bowser.hunt.active then
        return
    end

    if Bowser.hunt.coma then
        return
    end

    if Bowser.hunt.state ~= "scanning" then
        return
    end

    if not playerName then
        return
    end

    local cleanName = playerName
        :gsub("^%s+", "")
        :gsub("%s+$", "")
        :lower()

    local myName = Bowser.characterName
        :gsub("^%s+", "")
        :gsub("%s+$", "")
        :lower()

    --------------------------------------------------
    -- OUR OWN TAG
    --
    -- Ignore it completely.
    --------------------------------------------------

    if cleanName == myName then
        return
    end

    --------------------------------------------------
    -- ANOTHER PLAYER OWNS THIS MOB
    --------------------------------------------------

    Bowser.hunt.contested = true
    Bowser.hunt.contestedBy = cleanName

    cecho(
        "\n<magenta>[HUNT] Mob tagged by "
        .. cleanName
        .. ".\n"
    )
end


--------------------------------------------------
-- ATTEMPT TO ATTACK ONE MOB
--------------------------------------------------

function Bowser.clearRoom()

    if not Bowser.hunt.active then
        return
    end

    if Bowser.hunt.coma then
        return
    end

    --------------------------------------------------
    -- ONLY FKILL FROM READY STATE
    --------------------------------------------------

    if Bowser.hunt.state ~= "ready" then

        cecho(
            "\n<red>[HUNT] fkill blocked. State: "
            .. tostring(Bowser.hunt.state)
            .. "\n"
        )

        return
    end

    --------------------------------------------------
    -- DON'T ATTACK IN A CONTESTED ROOM
    --------------------------------------------------

    if Bowser.hunt.contested then

        Bowser.hunt.state = "ready"

        Bowser.moveNext()

        return
    end

    --------------------------------------------------
    -- SEND ONE FKILL
    --------------------------------------------------

    Bowser.hunt.state = "checking"

    cecho(
        "\n<red>[HUNT] fkill\n"
    )

    send("fkill")
end


--------------------------------------------------
-- ENEMY ENGAGED
--------------------------------------------------

function Bowser.enemyEngaged(name)

    if not Bowser.hunt.active then
        return
    end

    if Bowser.hunt.coma then
        return
    end

    --------------------------------------------------
    -- FKILL FOUND SOMETHING
    --------------------------------------------------

    if Bowser.hunt.state == "checking" then

        Bowser.hunt.state = "fighting"
        Bowser.hunt.enemies = 1

        cecho(
            "\n<cyan>[HUNT] Fighting "
            .. tostring(name)
            .. "\n"
        )
    end
end


--------------------------------------------------
-- ENEMY KILLED
--------------------------------------------------

function Bowser.enemyKilled(name)

    --------------------------------------------------
    -- "YOU KILLED X." IS AUTHORITATIVE.
    --
    -- We intentionally do NOT require the state
    -- to be "fighting".
    --------------------------------------------------

    if not Bowser.hunt.active then

        cecho(
            "\n<red>[HUNT] Kill detected, but hunt is inactive.\n"
        )

        return
    end

    if Bowser.hunt.coma then

        cecho(
            "\n<red>[HUNT] Kill detected during coma.\n"
        )

        return
    end

    Bowser.hunt.enemies = 0
    Bowser.hunt.state = "finishing"

    cecho(
        "\n<green>[HUNT] Killed "
        .. tostring(name)
        .. ".\n"
    )

    cecho(
        "<yellow>[HUNT] Next fkill in "
        .. tostring(Bowser.afterCombatDelay)
        .. " seconds.\n"
    )

    --------------------------------------------------
    -- IMPORTANT:
    --
    -- combatTimer is separate from moveTimer.
    -- Movement/scanning cannot accidentally cancel
    -- the post-kill fkill timer.
    --------------------------------------------------

    Bowser.cancelTimer("combatTimer")

    Bowser.hunt.combatTimer = tempTimer(
        Bowser.afterCombatDelay,
        function()

            Bowser.hunt.combatTimer = nil

            if not Bowser.hunt.active then

                cecho(
                    "\n<red>[HUNT] Next fkill cancelled "
                    .. "- hunt inactive.\n"
                )

                return
            end

            if Bowser.hunt.coma then

                cecho(
                    "\n<red>[HUNT] Next fkill cancelled "
                    .. "- coma.\n"
                )

                return
            end

            --------------------------------------------------
            -- SOMETHING CHANGED OUR STATE
            --------------------------------------------------

            if Bowser.hunt.state ~= "finishing" then

                cecho(
                    "\n<red>[HUNT] Next fkill cancelled. "
                    .. "State changed to: "
                    .. tostring(Bowser.hunt.state)
                    .. "\n"
                )

                return
            end

            --------------------------------------------------
            -- TRY NEXT MOB
            --------------------------------------------------

            Bowser.hunt.state = "ready"

            cecho(
                "\n<yellow>[HUNT] Sending next fkill...\n"
            )

            Bowser.clearRoom()
        end
    )
end


--------------------------------------------------
-- ROOM DEPLETED
--------------------------------------------------

function Bowser.roomDepleted()

    if not Bowser.hunt.active then
        return
    end

    if Bowser.hunt.coma then
        return
    end

    --------------------------------------------------
    -- ONLY ACCEPT:
    --
    -- "There is nothing here you can kill."
    --
    -- IF WE JUST SENT FKILL.
    --------------------------------------------------

    if Bowser.hunt.state ~= "checking" then
        return
    end

    Bowser.hunt.enemies = 0
    Bowser.hunt.state = "ready"

    cecho(
        "\n<yellow>[HUNT] Room depleted - moving.\n"
    )

    Bowser.moveNext()
end


--------------------------------------------------
-- MOVE TO NEXT ROOM
--------------------------------------------------

function Bowser.moveNext()

    if not Bowser.hunt.active then
        return
    end

    --------------------------------------------------
    -- COMA SAFETY
    --------------------------------------------------

    if Bowser.hunt.coma then

        cecho(
            "\n<yellow>[HUNT] Move blocked - coma.\n"
        )

        return
    end

    --------------------------------------------------
    -- STATE SAFETY
    --------------------------------------------------

    if Bowser.hunt.state ~= "ready" then

        cecho(
            "\n<red>[HUNT] Move blocked. State: "
            .. tostring(Bowser.hunt.state)
            .. "\n"
        )

        return
    end

    --------------------------------------------------
    -- ENEMY SAFETY
    --------------------------------------------------

    if Bowser.hunt.enemies > 0 then

        cecho(
            "\n<red>[HUNT] Move blocked - enemy alive.\n"
        )

        return
    end

    --------------------------------------------------
    -- RESTART CIRCULAR ROUTE
    --------------------------------------------------

    if #Bowser.hunt.path == 0 then

        Bowser.hunt.path = Bowser.copyRoute()

        cecho(
            "\n<green>[HUNT] Route restarting.\n"
        )
    end

    local direction = table.remove(
        Bowser.hunt.path,
        1
    )

    Bowser.hunt.state = "moving"

    cecho(
        "\n<green>[HUNT] Moving: "
        .. tostring(direction)
        .. "\n"
    )

    send(direction)

    --------------------------------------------------
    -- WAIT FOR NEW ROOM
    --------------------------------------------------

    Bowser.cancelTimer("moveTimer")

    Bowser.hunt.moveTimer = tempTimer(
        Bowser.afterMoveDelay,
        function()

            Bowser.hunt.moveTimer = nil

            if not Bowser.hunt.active then
                return
            end

            if Bowser.hunt.coma then
                return
            end

            if Bowser.hunt.state ~= "moving" then
                return
            end

            Bowser.enterRoom()
        end
    )
end


--------------------------------------------------
-- COMA STARTED
--------------------------------------------------

function Bowser.comaStarted()

    if not Bowser.hunt.active then
        return
    end

    Bowser.hunt.coma = true
    Bowser.hunt.state = "coma"

    --------------------------------------------------
    -- CANCEL ALL PENDING HUNT ACTIONS
    --------------------------------------------------

    Bowser.cancelTimer("roomTimer")
    Bowser.cancelTimer("moveTimer")
    Bowser.cancelTimer("combatTimer")
    Bowser.cancelTimer("comaTimer")

    cecho(
        "\n<red>[HUNT] COMA detected - hunt paused.\n"
    )
end


--------------------------------------------------
-- COMA ENDED
--------------------------------------------------

function Bowser.comaEnded()

    if not Bowser.hunt.active then
        return
    end

    if not Bowser.hunt.coma then
        return
    end

    --------------------------------------------------
    -- CLEAR STALE COMBAT / ROOM STATE
    --------------------------------------------------

    Bowser.hunt.coma = false

    Bowser.hunt.enemies = 0

    Bowser.hunt.contested = false
    Bowser.hunt.contestedBy = nil

    Bowser.hunt.state = "recovering"

    cecho(
        "\n<green>[HUNT] Recovered from coma - resuming.\n"
    )

    Bowser.cancelTimer("comaTimer")

    Bowser.hunt.comaTimer = tempTimer(
        Bowser.afterComaDelay,
        function()

            Bowser.hunt.comaTimer = nil

            if not Bowser.hunt.active then
                return
            end

            if Bowser.hunt.coma then
                return
            end

            if Bowser.hunt.state ~= "recovering" then
                return
            end

            --------------------------------------------------
            -- RESCAN THE ROOM WE WOKE UP IN
            --------------------------------------------------

            Bowser.hunt.state = "ready"

            Bowser.enterRoom()
        end
    )
end
