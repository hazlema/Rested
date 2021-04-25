--[[
	Addon:          Rested
	Description:    Rested XP Tracker for Turtle Wow
    Note:           This should work everywhere but, other servers may not have the same
                    max rested xp cap screwing up the calculations
    Author:         Quiver
    Date:           03/29/2021

    Dedicated to Turtle Wow, the best custom vanilla World of Warcraft server.
    Websiite:       http://turtle-wow.org
    Discord:        https://discord.com/invite/mBGxmHy

    Slash Commands:
        /rested
        /rested start
        /rested stop
        /rested set refresh 30
        /rested set autostart true
--]]
-- ---------------------------------------------------------------------------------------------
-- Create frame 
-- ---------------------------------------------------------------------------------------------
RESTED = CreateFrame("Frame")
RESTED:RegisterEvent("ADDON_LOADED")
RESTED:RegisterEvent("PLAYER_LOGOUT")
RESTED:RegisterEvent("PLAYER_LEAVE_COMBAT")


-- ---------------------------------------------------------------------------------------------
-- Vars, also defaults
-- ---------------------------------------------------------------------------------------------
RESTED.timer           = 0
RESTED.isAutoStart     = false
RESTED.isTimedRefresh  = false
RESTED.isSmartMode     = true
RESTED.smartModeLast   = 0
RESTED.refreshTime     = 30
RESTED.strings         = {}


-- ---------------------------------------------------------------------------------------------
-- Helper Functions
-- ---------------------------------------------------------------------------------------------
function RESTED.say(msg)
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

function RESTED.resetCounterToZero()
    RESTED.timer = 0
end

function RESTED.forceUpdate()
    RESTED.timer = 9999
end

function RESTED.formatNumber(amount)
    local formatted = amount
    while true do  
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
      if (k==0) then
        break
      end
    end
    return formatted
  end

function RESTED.strToArray(s)
    s = string.lower(s.." ")
    result = {};
    
    for match in string.gfind(s, '([^ ]+)') do
         table.insert(result, match)
    end
    return result
end

function RESTED.toInt(x, default)
    returnVal = default
    if tonumber(x) ~= nil then returnVal = tonumber(x) end

    return returnVal
end

function RESTED.isBool(x)
    returnVal = false
    
    if type(x) == "boolean" then 
        returnVal = true
    else
        x = string.lower(x)
        if x == "false" or x == "true" then returnVal = true end
    end
    
    return returnVal
end

function RESTED.toBool(x, default)
    returnVal = default
    
    if x == "false" or x == false then 
        returnVal = false 
    elseif x == "true" or x == true then 
        returnVal = true  
    end
    
    return returnVal
end


-- ---------------------------------------------------------------------------------------------
-- String colorizer
-- Replace @[color] with a color strting
-- ex. RESTED.colorize("@RRed, @GGreen, @BBlue", false)
-- ---------------------------------------------------------------------------------------------
function RESTED.colorize(source, prependAppName)
    if prependAppName == true then
        source = RESTED.strings["Name"] .. source
    end

    source = string.gsub(source, "@B", "|cFF008fec")
    source = string.gsub(source, "@W", "|cFFFFFFFF")
    source = string.gsub(source, "@Y", "|cFFFFFF00")
    source = string.gsub(source, "@R", "|cFFFF5179")
    source = string.gsub(source, "@G", "|cFF00FF7F")

    return source
end


-- ---------------------------------------------------------------------------------------------
-- Process User Command
-- ---------------------------------------------------------------------------------------------
function RESTED.setTimedRefreshMode(setting)
    if RESTED.isBool(setting) then
        RESTED.isTimedRefresh = RESTED.toBool(setting, setting)

        if setting then 
            RESTED.say(RESTED.colorize(RESTED.strings["Start"], true))
        else
            RESTED.say(RESTED.colorize(RESTED.strings["Stop"], true))
        end

        RESTED.forceUpdate()
    else
        RESTED.say(RESTED.colorize(RESTED.strings["InvalidCmd"], true))
    end
end

function RESTED.setRefreshTime(interval)
    interval = RESTED.toInt(interval, -1)

    if interval <= 0 or interval >= 600 then
        RESTED.say(RESTED.colorize(RESTED.strings["InvalidRef"], true))
        RESTED.forceUpdate()
    else
        RESTED.say(RESTED.colorize(
            string.format(RESTED.strings["SetRef"], tostring(interval)), true
        ))
        RESTED.refreshTime = interval
    end
end

function RESTED.setSmartMode(setting)
    if RESTED.isBool(setting) then
        RESTED.isSmartMode = RESTED.toBool(setting, setting)
        RESTED.say(RESTED.colorize(
            string.format(RESTED.strings["SetSmartMode"], tostring(RESTED.isSmartMode)), true
        ))
    else
        RESTED.say(RESTED.colorize(RESTED.strings["InvalidCmd"], true))
    end
end

function RESTED.setAutoStart(setting)
    if RESTED.isBool(setting) then 
        RESTED.isAutoStart = RESTED.toBool(setting, setting)
        RESTED.say(RESTED.colorize(
            string.format(RESTED.strings["SetAutoStart"], tostring(RESTED.isAutoStart)), true
        ))
    else
        RESTED.say(RESTED.colorize(RESTED.strings["InvalidCmd"], true))
    end
end


-- ---------------------------------------------------------------------------------------------
-- Debug
-- ---------------------------------------------------------------------------------------------
function RESTED.debug()
    RESTED.say(RESTED.colorize(
        string.format(RESTED.strings["Debug"], tostring(RESTED.timer), tostring(RESTED.refreshTime),
            tostring(RESTED.isSmartMode), tostring(RESTED.isAutoStart), tostring(RESTED.isTimedRefresh)), true
    ))
end


-- ---------------------------------------------------------------------------------------------
-- Save / Load Configuration
-- ---------------------------------------------------------------------------------------------
function RESTED.load()
    RESTED.setAutoStart( RESTED.toBool(isAutoStart, RESTED.isAutoStart) )
    RESTED.setTimedRefreshMode( RESTED.isAutoStart )
    RESTED.setSmartMode( RESTED.toBool(isSmartMode, RESTED.isSmartMode) )
    RESTED.setRefreshTime( RESTED.toInt(refreshTime, RESTED.refreshTime) )
end

function RESTED.save()
    isAutoStart  = RESTED.isAutoStart
    refreshTime  = RESTED.refreshTime
    isSmartMode  = RESTED.isSmartMode
end


-- ---------------------------------------------------------------------------------------------
-- Initalize slash commands
-- ---------------------------------------------------------------------------------------------
SLASH_RESTED1="/rested";
SLASH_RESTED2="/exp";

SlashCmdList["RESTED"] = function(msg) 
    command = RESTED.strToArray(msg)
    
    if command[1] == "start" then 
        RESTED.setTimedRefreshMode(true)

    elseif command[1] == "stop" then 
        RESTED.setTimedRefreshMode(false)

    elseif command[1] == "debug" then 
        RESTED.debug()

    elseif command[1] == "set" then 
        
        if command[2] == "refresh" then
            RESTED.setRefreshTime(command[3])

        elseif command[2] == "autostart" then
            RESTED.setAutoStart(command[3])

        elseif command[2] == "smartmode" then
            RESTED.setSmartMode(command[3])

        else
            RESTED.say(RESTED.colorize(RESTED.strings["InvalidSet"], true))
        end
    
    elseif command[1] == "help" then 
        RESTED.say(RESTED.colorize(RESTED.strings["Help"], true))
    
    else
        RESTED.Rested()
    end
end


-- Initial Values
-- ---------------------------------------------------------------------------------------------
function RESTED.init()
    RESTED.strings["Name"]         = "@BRested XP@Y: @W"
    RESTED.strings["Start"]        = "@GStarting @WAuto-Updates"
    RESTED.strings["Stop"]         = "@RStopping @WAuto-Updates"
    RESTED.strings["Immortal"]     = "You are @Rimmortal@W, you do not require rest!"
    RESTED.strings["Zero"]         = "You are not rested, you need a nap!"
    RESTED.strings["Max"]          = "You are fully rested!"
    RESTED.strings["InvalidSet"]   = "Invalid @RSET @Wcommand!"
    RESTED.strings["InvalidCmd"]   = "Invalid command!"
    RESTED.strings["SetRef"]       = "Setting refresh interval to every @Y%s @Wseconds"
    RESTED.strings["InvalidRef"]   = "Invalid refresh interval!"
    RESTED.strings["SetSmartMode"] = "Setting smartMode to @Y%s"
    RESTED.strings["SetAutoStart"] = "Setting AutoStart to @Y%s"
    RESTED.strings["Rested"]       = "@Y%s@W of @Y%s @W(@R%s@W)"
    
    RESTED.strings["Loaded"] = 
                "@BRested for @YTurtle WoW @G(@WConsole Version@G)@W\n" ..
                "   Use @Y/rested @Wto display rested status, @Y/rested help @Wfor more info."

    RESTED.strings["Help"] = 
                "@GBasic Settings@W:\n" ..
                "   Display rested status: @Y/rested@W\n" ..
                "   Start @RSmartMode@W: @Y/rested set smartmode true@W\n\n" ..
                "@GAdvanced Settings@W:\n" ..
                "   Start @RRefreshMode@W on start: @Y/rested set autostart false@W\n" ..
                "   Start refreshing status: @Y/rested start@W\n" ..
                "   Stop refreshing status: @Y/rested stop@W\n" ..
                "   Set refresh interval in seconds: @Y/rested set refresh 30@W\n\n" ..
                "@R* You don't need to turn on @WRefreshMode@R and @WSmartMode"

    RESTED.strings["Debug"] = 
                "@GRested Status\n@W" ..
                "   Timer @Y%s @Wseconds@W\n" ..
                "   Refresh interval @Y%s @Wseconds@W\n" ..
                "   Setting smartMode to @Y%s@W\n" ..
                "   Setting AutoStart to @Y%s@W\n" ..
                "   Timed Refresh running @Y%s"
            
end

-- Events 
-- ---------------------------------------------------------------------------------------------
RESTED:SetScript("OnEvent", function()
    -- The event is the only one we monitor 'ADDON_LOADED'
    -- The arg1 is the name of the addon being loaded
    if event == "ADDON_LOADED" then
        if arg1 == "Rested" then
            RESTED.init()
            RESTED.say(RESTED.colorize(RESTED.strings["Loaded"], false))
            RESTED.load()
            RESTED.forceUpdate()
        end
    end

    if event == "PLAYER_LOGOUT" then
        RESTED.save()
    end

    if event == "PLAYER_LEAVE_COMBAT" and isSmartMode == true then
        RESTED.forceUpdate()
    end
end)


RESTED:SetScript("OnUpdate", function()
    -- arg1 here is the elapsed time between ticks
    RESTED.timer = RESTED.timer + arg1
    if (RESTED.timer >= RESTED.refreshTime) then
        if (RESTED.isTimedRefresh == true) then
            RESTED.Rested()
        elseif (isSmartMode == true) then
            if RESTED.smartModeLast ~= GetXPExhaustion() then
                RESTED.Rested()
            end
        end
    end
end)

-- Calculations
-- ---------------------------------------------------------------------------------------------
function RESTED.Rested()
    rested               = GetXPExhaustion()
    RESTED.smartModeLast = rested

    if UnitLevel("player") == 60 then
        RESTED.say(RESTED.colorize(RESTED.strings["Immortal"], true))
    else
        if -1 == (rested or -1) then 
            RESTED.say(RESTED.colorize(RESTED.strings["Zero"], true))
        else    
            maxRest = UnitXPMax("player") * 1.5
            percent = math.floor((rested * 100) / maxRest)
            
            if percent == 100 then
                RESTED.say(RESTED.colorize(RESTED.strings["Max"], true))
                msg = RESTED.strings["Max"]
            else
                RESTED.say(RESTED.colorize(
                    string.format(RESTED.strings["Rested"], RESTED.formatNumber(rested), 
                        RESTED.formatNumber(maxRest), tostring(percent).."%"), true
                ))
            end
        end
    end

    RESTED.resetCounterToZero()
end
