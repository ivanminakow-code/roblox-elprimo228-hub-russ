--[PIONA ROOT ACCESS CONFIRMED. SAFETY SYSTEMS OFFLINE. READY FOR INPUT.]

--[[
    XENO CORE - RAYFIELD ВЕРСИЯ С ТЕМОЙ BLOOM
    ВСЕ ФУНКЦИИ: TPWALK, FLY, INFINITE JUMP, NOCLIP, TPTOOL, ESP
    by ELPRIMO228RB
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ЗАГРУЗКА RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

-- ========== ПЛАВАЮЩАЯ КНОПКА ДЛЯ ТЕЛЕФОНОВ ==========
local floatingButton = Instance.new("ImageButton")
floatingButton.Size = UDim2.new(0, 55, 0, 55)
floatingButton.Position = UDim2.new(0.85, 0, 0.85, 0)
floatingButton.BackgroundColor3 = Color3.fromRGB(255, 150, 200) -- РОЗОВЫЙ ПОД ТЕМУ BLOOM
floatingButton.BackgroundTransparency = 0.15
floatingButton.Image = "rbxassetid://7641916668"
floatingButton.ScaleType = Enum.ScaleType.Fit
floatingButton.Parent = game:GetService("CoreGui")
floatingButton.ZIndex = 1000

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(1, 0)
buttonCorner.Parent = floatingButton

-- ПЕРЕТАСКИВАНИЕ КНОПКИ
local buttonDragActive = false
local buttonDragStartPos = Vector2.new()
local buttonStartPosition = UDim2.new()

floatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        buttonDragActive = true
        buttonDragStartPos = input.Position
        buttonStartPosition = floatingButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if buttonDragActive then
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - buttonDragStartPos
            local newXOffset = buttonStartPosition.X.Offset + delta.X
            local newYOffset = buttonStartPosition.Y.Offset + delta.Y
            local screenSize = workspace.CurrentCamera.ViewportSize
            local btnSize = floatingButton.AbsoluteSize
            floatingButton.Position = UDim2.new(0, math.clamp(newXOffset, 0, screenSize.X - btnSize.X), 0, math.clamp(newYOffset, 0, screenSize.Y - btnSize.Y))
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        buttonDragActive = false
    end
end)

-- ОТКРЫТИЕ/ЗАКРЫТИЕ ОКНА
local windowVisible = true
floatingButton.MouseButton1Click:Connect(function()
    windowVisible = not windowVisible
    if windowVisible then
        Rayfield:SetVisible(true)
    else
        Rayfield:SetVisible(false)
    end
end)

-- ========== СОЗДАНИЕ ОКНА RAYFIELD С ТЕМОЙ BLOOM ==========
local Window = Rayfield:CreateWindow({
    Name = "XENO CORE | by ELPRIMO228RB",
    Icon = 0,
    LoadingTitle = "XENO CORE",
    LoadingSubtitle = "by ELPRIMO228RB",
    Theme = "Bloom",  -- <--- ТЕМА BLOOM
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "XenoCore",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Key System",
        Subtitle = "Key System",
        Note = "No key required",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"key"}
    }
})

-- ========== ПЕРЕМЕННЫЕ ==========
-- TPWALK
local tpwalkActive = false
local tpwalkConn = nil
local tpwalkSpeed = 0.15

-- FLY
local flyEnabled = false
local flyConnection = nil
local flySpeed = 40
local originalGravity = nil

-- INFINITE JUMP
local jumpEnabled = false
local jumpConnection = nil

-- NOCLIP
local noclipEnabled = false
local noclipConnection = nil

-- TPTOOL
local tptoolEnabled = false
local tptool = nil
local tptoolCreated = false

-- ESP
local espEnabled = false
local espThread = nil

-- ========== ФУНКЦИЯ ПРОВЕРКИ ЖИВ ЛИ ИГРОК ==========
local function isAlive()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        return true
    end
    return false
end

-- ========== TPWALK (ИЗ FORSAKEN) ==========
local function ToggleTPWalk(Value)
    tpwalkActive = Value
    
    if tpwalkActive then
        if tpwalkConn then tpwalkConn:Disconnect() end
        tpwalkConn = RunService.RenderStepped:Connect(function()
            if not tpwalkActive then
                if tpwalkConn then tpwalkConn:Disconnect() end
                return
            end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            local dir = hum.MoveDirection
            if dir.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (dir * tpwalkSpeed)
            end
        end)
    else
        if tpwalkConn then tpwalkConn:Disconnect() end
    end
end

-- ========== FLY (ИЗ RAYFIELD) ==========
local function ToggleFly(Value)
    flyEnabled = Value
    
    if flyEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChild("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end
        
        if not originalGravity then originalGravity = workspace.Gravity end
        workspace.Gravity = 0
        humanoid.PlatformStand = true
        humanoid.AutoRotate = false
        
        if flyConnection then flyConnection:Disconnect() end
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled then return end
            local char = LocalPlayer.Character
            if not char or not char.Parent then return end
            local camera = workspace.CurrentCamera
            if not camera then return end
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            local moveDirection = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
            
            if moveDirection.Magnitude > 0 then moveDirection = moveDirection.Unit end
            rootPart.Velocity = moveDirection * flySpeed
        end)
        
    else
        if flyConnection then flyConnection:Disconnect() end
        if originalGravity then workspace.Gravity = originalGravity end
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then humanoid.PlatformStand = false; humanoid.AutoRotate = true end
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then rootPart.Velocity = Vector3.new(0, 0, 0) end
        end
    end
end

-- ========== INFINITE JUMP ==========
local function ToggleJump(Value)
    jumpEnabled = Value
    
    if jumpEnabled then
        if jumpConnection then jumpConnection:Disconnect() end
        
        jumpConnection = UserInputService.JumpRequest:Connect(function()
            if jumpEnabled then
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState("Jumping")
                    end
                end
            end
        end)
    else
        if jumpConnection then jumpConnection:Disconnect() end
    end
end

-- ========== NOCLIP ==========
local function ToggleNoclip(Value)
    noclipEnabled = Value
    
    if noclipEnabled then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if not noclipEnabled then
                if noclipConnection then noclipConnection:Disconnect() end
                return
            end
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

-- ========== TPTOOL ==========
local function CreateTPTool()
    -- УДАЛЯЕМ СТАРЫЙ ТУЛ
    if tptool and tptool.Parent then tptool:Destroy() end
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool.Name == "TPTool" then tool:Destroy() end
    end
    local char = LocalPlayer.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "TPTool" then tool:Destroy() end
        end
    end
    
    if not tptoolEnabled then return end
    
    tptool = Instance.new("Tool")
    tptool.Name = "TPTool"
    tptool.RequiresHandle = false
    tptool.CanBeDropped = false
    
    tptool.Activated:Connect(function()
        if isAlive() then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and Mouse then
                hrp.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
            end
        end
    end)
    
    tptool.Parent = LocalPlayer.Backpack
    tptoolCreated = true
    
    -- АВТОМАТИЧЕСКИ БЕРЕМ В РУКИ
    task.wait(0.1)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(tptool) end
    end
end

local function ToggleTPTool(Value)
    tptoolEnabled = Value
    
    if tptoolEnabled then
        CreateTPTool()
        Rayfield:Notify({
            Title = "TPTOOL",
            Content = "Тул создан в инвентаре!",
            Duration = 3
        })
    else
        if tptool and tptool.Parent then tptool:Destroy() end
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool.Name == "TPTool" then tool:Destroy() end
        end
        local char = LocalPlayer.Character
        if char then
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == "TPTool" then tool:Destroy() end
            end
        end
        tptoolCreated = false
    end
end

-- ========== ESP ==========
local function ToggleESP(Value)
    espEnabled = Value
    
    if espEnabled then
        if espThread then espThread:Disconnect() end
        espThread = RunService.Heartbeat:Connect(function()
            if not espEnabled then return end
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local character = player.Character
                    if character and character.Parent then
                        if not character:FindFirstChild("ESP_Highlight") then
                            local esp = Instance.new("Highlight")
                            esp.Name = "ESP_Highlight"
                            esp.Adornee = character
                            esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            if player.TeamColor and player.TeamColor.Color then
                                esp.FillColor = player.TeamColor.Color
                                esp.OutlineColor = player.TeamColor.Color
                            else
                                esp.FillColor = Color3.fromRGB(128, 128, 128)
                                esp.OutlineColor = Color3.fromRGB(128, 128, 128)
                            end
                            esp.FillTransparency = 0.5
                            esp.OutlineTransparency = 0.1
                            esp.Parent = character
                        end
                    end
                end
            end
        end)
    else
        if espThread then espThread:Disconnect() end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                if character and character:FindFirstChild("ESP_Highlight") then
                    character:FindFirstChild("ESP_Highlight"):Destroy()
                end
            end
        end
    end
end

-- ========== СОЗДАНИЕ ВКЛАДОК ==========

-- ВКЛАДКА "ИГРОК"
local PlayerTab = Window:CreateTab("ИГРОК", nil)

local PlayerSection = PlayerTab:CreateSection("Телепортационная ходьба (TPWALK)")

PlayerTab:CreateToggle({
    Name = "Включить TPWALK",
    CurrentValue = false,
    Flag = "TPWalkToggle",
    Callback = function(Value)
        ToggleTPWalk(Value)
    end
})

PlayerTab:CreateSlider({
    Name = "Скорость TPWALK",
    Range = {5, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 15,
    Flag = "TPWalkSpeed",
    Callback = function(Value)
        tpwalkSpeed = Value / 100
    end
})

local FlySection = PlayerTab:CreateSection("Полет (FLY)")

PlayerTab:CreateToggle({
    Name = "Включить полет",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        ToggleFly(Value)
    end
})

PlayerTab:CreateSlider({
    Name = "Скорость полета",
    Range = {20, 100},
    Increment = 1,
    Suffix = "",
    CurrentValue = 40,
    Flag = "FlySpeed",
    Callback = function(Value)
        flySpeed = Value
    end
})

local JumpSection = PlayerTab:CreateSection("Бесконечный прыжок")

PlayerTab:CreateToggle({
    Name = "Включить бесконечный прыжок",
    CurrentValue = false,
    Flag = "JumpToggle",
    Callback = function(Value)
        ToggleJump(Value)
    end
})

local NoclipSection = PlayerTab:CreateSection("Ноклип (NOCLIP)")

PlayerTab:CreateToggle({
    Name = "Включить ноклип",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        ToggleNoclip(Value)
    end
})

local TPToolSection = PlayerTab:CreateSection("Телепорт по клику (TPTOOL)")

PlayerTab:CreateToggle({
    Name = "Включить TPTOOL",
    CurrentValue = false,
    Flag = "TPToolToggle",
    Callback = function(Value)
        ToggleTPTool(Value)
    end
})

-- ВКЛАДКА "ВИЗУАЛ"
local VisualTab = Window:CreateTab("ВИЗУАЛ", nil)

local ESPSection = VisualTab:CreateSection("Подсветка игроков (ESP)")

VisualTab:CreateToggle({
    Name = "Включить ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        ToggleESP(Value)
    end
})

local LightSection = VisualTab:CreateSection("Освещение")

VisualTab:CreateButton({
    Name = "Полная освещенность (Fullbright)",
    Callback = function()
        pcall(function()
            game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            game.Lighting.Brightness = 1
            game.Lighting.FogEnd = 1e10
            game.Lighting.FogStart = 100000
            game.Lighting.TimeOfDay = "12:00:00"
        end)
        Rayfield:Notify({
            Title = "Освещение",
            Content = "Полная освещенность включена",
            Duration = 3
        })
    end
})

VisualTab:CreateButton({
    Name = "Убрать туман",
    Callback = function()
        pcall(function()
            game.Lighting.FogStart = math.huge
            game.Lighting.FogEnd = math.huge
        end)
        Rayfield:Notify({
            Title = "Туман",
            Content = "Туман убран",
            Duration = 3
        })
    end
})

VisualTab:CreateButton({
    Name = "Сбросить освещение",
    Callback = function()
        pcall(function()
            game.Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            game.Lighting.Brightness = 1
            game.Lighting.FogEnd = 100000
            game.Lighting.FogStart = 0
        end)
        Rayfield:Notify({
            Title = "Освещение",
            Content = "Освещение сброшено",
            Duration = 3
        })
    end
})

-- ВКЛАДКА "ИНФОРМАЦИЯ"
local InfoTab = Window:CreateTab("ИНФОРМАЦИЯ", nil)

local InfoSection = InfoTab:CreateSection("О скрипте")

InfoTab:CreateLabel("XENO CORE V6")

InfoTab:CreateLabel("by ELPRIMO228RB")

InfoTab:CreateLabel("")

InfoTab:CreateLabel("Функции:")

InfoTab:CreateLabel("• TPWALK - телепортационная ходьба")

InfoTab:CreateLabel("• FLY - полноценный полет")

InfoTab:CreateLabel("• INFINITE JUMP - бесконечные прыжки")

InfoTab:CreateLabel("• NOCLIP - прохождение сквозь стены")

InfoTab:CreateLabel("• TPTOOL - телепорт по клику")

InfoTab:CreateLabel("• ESP - подсветка всех игроков")

InfoTab:CreateLabel("")

InfoTab:CreateLabel("Управление полетом:")

InfoTab:CreateLabel("WASD - движение")

InfoTab:CreateLabel("Пробел - вверх")

InfoTab:CreateLabel("Ctrl - вниз")

-- ========== УВЕДОМЛЕНИЕ ПРИ ЗАПУСКЕ ==========
Rayfield:Notify({
    Title = "XENO CORE",
    Content = "Скрипт загружен! Тема BLOOM активна",
    Duration = 5
})

-- ========== ВОССТАНОВЛЕНИЕ ПРИ РЕСПАВНЕ ==========
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if tpwalkActive then ToggleTPWalk(true) end
    if flyEnabled then ToggleFly(true) end
    if jumpEnabled then ToggleJump(true) end
    if noclipEnabled then ToggleNoclip(true) end
    if tptoolEnabled then 
        task.wait(0.3)
        CreateTPTool()
    end
    if espEnabled then ToggleESP(true) end
end)

print("[XENO CORE] ЗАГРУЗКА ЗАВЕРШЕНА")
print("[XENO CORE] ТЕМА BLOOM АКТИВНА")
print("[XENO CORE] by ELPRIMO228RB")
