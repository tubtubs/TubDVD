local dx = 1
local dy = 1
local cornerHits = 0
local minDelta = 1/60 -- ~60 FPS regardless of actual FPS
local help = [[TubDVD - Bouncing DVD logo when you go afk
/tubdvd enable/disable - enable or disable the AFK functionality
/tubdvd toggle - toggle when you're not AFK, shows or hides the logo
/tubdvd sound enable/disable - enable or disable the owen wilson wow
/tubdvd speed x - sets speed or displays current speed if no x provided]]

function BouncingDVD_Init()
    if DVD_Vars == nil then
        DVD_Vars = {
        speed = 200,
        cornerHits = 0,
        enable = true,
        sound = true,
        };
    end
    if DVD_Vars.enable then
        this:RegisterEvent("CHAT_MSG_SYSTEM")
    end
    BouncingDVDFrame:SetScript("OnUpdate", nil)
    BouncingDVDFrame:ClearAllPoints()
    BouncingDVDFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    -- Slash command to manually toggle
    SLASH_TUBDVD1 = "/tubdvd"
    SLASH_TUBDVD2 = "/tdvd"
    SLASH_TUBDVD3 = "/dvd"
    SlashCmdList["TUBDVD"] = function(args)
        args = string.lower(args) --decided to make args case insensitive
        a = string.gfind(args, '%S+')
        parsed_args = {}
        for i in a do
            table.insert(parsed_args,i)
        end
        l = getn(parsed_args)
        if l==0 then -- display help
            DEFAULT_CHAT_FRAME:AddMessage(help)
        elseif l==1 then
            if parsed_args[1] == "toggle" then 
                if BouncingDVDFrame:IsVisible() then
                    BouncingDVDFrame:Hide()
                    BouncingDVDFrame:SetScript("OnUpdate", nil)
                    BouncingDVDFrame:ClearAllPoints()
                    BouncingDVDFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                else
                    BouncingDVDFrame:ClearAllPoints()
                    BouncingDVDFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                    BouncingDVDFrame:Show()
                    BouncingDVDFrame:SetScript("OnUpdate", BouncingDVD_OnUpdate)
                end
            elseif parsed_args[1] == "speed" then
                DEFAULT_CHAT_FRAME:AddMessage("Current Speed: "..DVD_Vars.speed)
            elseif parsed_args[1] == "enable" then
                DVD_Vars.enable = true
                BouncingDVDFrame:RegisterEvent("CHAT_MSG_SYSTEM")
            elseif parsed_args[1] == "disable" then
                DVD_Vars.enable = false
                BouncingDVDFrame:UnregisterEvent("CHAT_MSG_SYSTEM")
            else
                DEFAULT_CHAT_FRAME:AddMessage("TubDVD: Unknown command")
            end
        elseif l==2 then
            if parsed_args[1] == "speed" then
                local t = tonumber(parsed_args[2])
                DVD_Vars.speed = tonumber(t)
                DEFAULT_CHAT_FRAME:AddMessage("Current Speed: "..DVD_Vars.speed)
            elseif parsed_args[1] == "sound" then
                if parsed_args[2] == "enable" then
                    DVD_Vars.sound = true
                    DEFAULT_CHAT_FRAME:AddMessage("TubDVD: Sound enabled")
                elseif parsed_args[2] == "disable" then
                    DVD_Vars.sound = false
                    DEFAULT_CHAT_FRAME:AddMessage("TubDVD: Sound disabled")
                else
                    DEFAULT_CHAT_FRAME:AddMessage("TubDVD: Unknown command")
                end
            else
                DEFAULT_CHAT_FRAME:AddMessage("TubDVD: Unknown command")
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage("TubDVD: Unknown command")
        end
    end
    DEFAULT_CHAT_FRAME:AddMessage("TubDVD Loaded! Type /dvd for more info.")
end

function BouncingDVD_OnEvent()
    if event=="CHAT_MSG_SYSTEM" then
        local afkString = string.gsub(MARKED_AFK_MESSAGE, "%%s", ".*")

        -- Check if the incoming system message matches the AFK format
        if arg1 and string.find(arg1, afkString) then
            -- Your custom logic goes here
            CloseAllWindows();
            UIParent:Hide();
            BouncingDVDFrame:ClearAllPoints()
            BouncingDVDFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            BouncingDVDFrame:Show()
            BouncingDVDFrame:SetScript("OnUpdate", BouncingDVD_OnUpdate)
        end

        if arg1 and string.find(arg1,CLEARED_AFK) then -- no longer afk
            BouncingDVDFrame:SetScript("OnUpdate", nil)
            BouncingDVDFrame:ClearAllPoints()
            BouncingDVDFrame:Hide()
            BouncingDVDFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            UIParent:Show();
        end
    elseif event=="PLAYER_LOGIN" then
        BouncingDVD_Init()
    end
end

local function IsFrameOffscreen(frame)
    if not frame then return true end
    
    local left = frame:GetLeft()
    local right = frame:GetRight()
    local top = frame:GetTop()
    local bottom = frame:GetBottom()
    
    -- If any coordinate is missing, the frame is not yet rendered
    if not left or not right or not top or not bottom then return true end

    -- Check if completely off-screen in any direction
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()

    if right < 0 or left > screenWidth or bottom > screenHeight or top < 0 then
        return true -- Frame is offscreen
    end
    
    return false -- Frame is onscreen
end

elapsed = 1
lastTime = GetTime()
function BouncingDVD_OnUpdate()

    --DEFAULT_CHAT_FRAME:AddMessage("Running...")
    elapsed = GetTime() - lastTime 
    --DEFAULT_CHAT_FRAME:AddMessage(elapsed)
    if elapsed >= minDelta then
        local x, y = this:GetCenter()
        local scale = UIParent:GetScale()
        local screenWidth = GetScreenWidth() * scale
        local screenHeight = GetScreenHeight() * scale
        local frameWidth = this:GetWidth() * scale
        local frameHeight = this:GetHeight() * scale

        -- Movement formula
        x = x + (dx * DVD_Vars.speed * elapsed)
        y = y + (dy * DVD_Vars.speed * elapsed)

        -- Bounce checks
        local hitX = false
        local hitY = false

        if x + (frameWidth / 2) > screenWidth then
            dx = -1
            hitX = true
        elseif x - (frameWidth / 2) <= 0 then
            dx = 1
            hitX = true
        end

        if y + (frameHeight / 2) > screenHeight then
            dy = -1
            hitY = true
        elseif y - (frameHeight / 2) <= 0 then
            dy = 1
            hitY = true
        end

        if hitX or hitY then
            local r = math.random()
            local g = math.random()
            local b = math.random()
            DVDLogoTexture:SetVertexColor(r, g, b, 1.0)
        end

        -- Track corner hits
        if hitX and hitY then
            DVD_Vars.cornerHits = DVD_Vars.cornerHits + 1
            DEFAULT_CHAT_FRAME:AddMessage("Corner Hits: " .. DVD_Vars.cornerHits)
            -- Add a texture color tint or flash here if desired!
            if DVD_Vars.sound then
                PlaySoundFile("Interface\\Addons\\TubDVD\\Sounds\\".. math.random(16) .. ".mp3")
            end
        end
        if x < 0 then x = 0 end
        if x > screenWidth then x = screenWidth-100 end
        if y < 0 then y = 0 end
        if y > screenHeight then y = screenHeight-100 end
        this:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
        --elapsed = elapsed + (GetTime()-lastTime)
        lastTime = GetTime()
    end
end