--// LocalScript (StarterGui)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local PlaceId = game.PlaceId

-- ฟังก์ชันดึง server list
local function getServers(limit)
    local servers = {}
    local cursor = ""
    while #servers < limit do
        local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100&cursor="..cursor
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and result and result.data then
            for _, s in ipairs(result.data) do
                if s.id ~= game.JobId and s.maxPlayers then
                    s.playing = math.random(0, s.maxPlayers) -- 👈 สุ่มจำนวนคน
                    table.insert(servers, s)
                end
            end
            cursor = result.nextPageCursor or ""
            if cursor == "" then break end
        else
            break
        end
    end
    return servers
end

-- ฟังก์ชันรีเฟรช
local function refreshServers(listFrame)
    listFrame:ClearAllChildren()

    local loading = Instance.new("TextLabel")
    loading.Size = UDim2.new(1, 0, 1, 0)
    loading.Text = "กำลังหาผัวลิต ทาเดียวตะ"
    loading.TextColor3 = Color3.new(1,1,1)
    loading.BackgroundTransparency = 1
    loading.Font = Enum.Font.GothamBold
    loading.TextSize = 18
    loading.Parent = listFrame

    task.spawn(function()
        local servers
        repeat
            servers = getServers(100)
            if #servers == 0 then task.wait(2) end
        until #servers > 0

        listFrame:ClearAllChildren()

        for i, s in ipairs(servers) do
            local item = Instance.new("Frame")
            item.Size = UDim2.new(0, 180, 0, 80)
            item.Position = UDim2.new(0, (i-1)*190, 0, 5)
            item.BackgroundColor3 = Color3.fromRGB(40,40,40)
            item.BorderSizePixel = 0
            item.Parent = listFrame

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, -10, 0, 20)
            title.Position = UDim2.new(0, 5, 0, 5)
            title.BackgroundTransparency = 1
            title.Text = "ผัวลิตคนที่ "..i
            title.TextColor3 = Color3.new(1,1,1)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 14
            title.Parent = item

            local info = Instance.new("TextLabel")
            info.Size = UDim2.new(1, -10, 0, 20)
            info.Position = UDim2.new(0, 5, 0, 30)
            info.BackgroundTransparency = 1
            info.Text = string.format("%d / %d ผัวลิตทั้งหมด", s.playing, s.maxPlayers)
            info.TextColor3 = Color3.new(1,1,1)
            info.TextXAlignment = Enum.TextXAlignment.Center
            info.Font = Enum.Font.Gotham
            info.TextSize = 14
            info.Parent = item

            local joinBtn = Instance.new("TextButton")
            joinBtn.Size = UDim2.new(0.9, 0, 0, 20)
            joinBtn.Position = UDim2.new(0.05, 0, 1, -25)
            joinBtn.Text = "เข้าไปหาผัวลิต"
            joinBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
            joinBtn.TextColor3 = Color3.new(1,1,1)
            joinBtn.Font = Enum.Font.GothamBold
            joinBtn.TextSize = 14
            joinBtn.Parent = item

            joinBtn.MouseButton1Click:Connect(function()
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, player)
            end)
        end

        listFrame.CanvasSize = UDim2.new(0, #servers * 190, 0, 0)
    end)
end

-- GUI หลัก
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.ResetOnSpawn = false

-- แผงหลัก
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 1000, 0, 220)
mainFrame.Position = UDim2.new(0.5, -500, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(30,30,30)
title.Text = "เอาไว้หาผัวลิต"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- Scroll Frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -60)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollingDirection = Enum.ScrollingDirection.X
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = mainFrame

-- ปุ่ม Refresh
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 120, 0, 40)
refreshBtn.Position = UDim2.new(0.5, -60, 0.5, -170)
refreshBtn.Text = "เปลี่ยนผัวลิต"
refreshBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
refreshBtn.TextColor3 = Color3.new(1,1,1)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 18
refreshBtn.Parent = screenGui

refreshBtn.MouseButton1Click:Connect(function()
    refreshServers(scrollFrame)
end)

-- ✅ ปุ่มเล็กมุมขวาบนเปิดปิดแผง
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 30, 0, 30)
toggleBtn.Position = UDim2.new(1, -35, 0, 5)
toggleBtn.Text = "≡"
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Parent = screenGui

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- โหลดครั้งแรก
refreshServers(scrollFrame)
