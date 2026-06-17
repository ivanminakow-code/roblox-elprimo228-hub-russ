--[[
    XENO_CORE_V6 - ПОЛНОСТЬЮ НА РУССКОМ
    С ПЛАВАЮЩЕЙ КНОПКОЙ ДЛЯ ТЕЛЕФОНОВ
    TPWALK ИЗ FORSAKEN, FLY ИЗ RAYFIELD, INFINITE JUMP ИЗ ПРИМЕРА
    ESP, НОКЛИП, TPTOOL (ТУЛ В ИНВЕНТАРЕ)
--]]

-- 1. ЗАГРУЗКА БИБЛИОТЕКИ LUNA
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()
if not Luna then error("ОШИБКА ЗАГРУЗКИ LUNA") end

-- 2. ПЕРЕМЕННЫЕ
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- 3. ГЛОБАЛЬНОЕ СОСТОЯНИЕ
local PlayerState = {
    TPCapability = { Active = false, Speed = 15, TargetSpeed = 0.15 },
    FlyCapability = { Active = false, Speed = 40 },
    JumpCapability = { Active = false },
    NoclipCapability = { Active = false },
    TPToolCapability = { Active = false }
}

-- 4. ПЕРЕМЕННЫЕ ФУНКЦИЙ
local tpwalkConn = nil
local flyConnection = nil
local flyEnabled = false
local flySpeed = 40
local originalGravity = nil
local InfiniteJumpEnabled = false
local noclipConnection = nil

-- ПЕРЕМЕННЫЕ TPTOOL
local tptool = nil
local tptoolCreated = false

-- ПЕРЕМЕННЫЕ ESP
local espEnabled = false
local espThread = nil

-- ========== ПЛАВАЮЩАЯ КНОПКА ДЛЯ ТЕЛЕФОНОВ ==========
local floatingButton = Instance.new("ImageButton")
floatingButton.Size = UDim2.new(0, 55, 0, 55)
floatingButton.Position = UDim2.new(0.85, 0, 0.85, 0)
floatingButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
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

-- ОТКРЫТИЕ/ЗАКРЫТИЕ ОКНА ЧЕРЕЗ КНОПКУ
local windowVisible = true
floatingButton.MouseButton1Click:Connect(function()
    windowVisible = not windowVisible
    if windowVisible then
        local gui = Window._Gui
        if gui then
            gui.Enabled = true
        end
    else
        local gui = Window._Gui
        if gui then
            gui.Enabled = false
        end
    end
end)

-- ========== ФУНКЦИЯ ПРОВЕРКИ ЖИВ ЛИ ИГРОК ==========
local function isAlive(Player)
    local Player = Player or LocalPlayer
    if Player and Player.Character and 
       Player.Character:FindFirstChildOfClass("Humanoid") and 
       Player.Character:FindFirstChild("HumanoidRootPart") then
        return true
    else
        return false
    end
end

-- ========== ФУНКЦИЯ TPTOOL (СОЗДАНИЕ ТУЛА) ==========
local function CreateTPTool()
    -- УДАЛЯЕМ СТАРЫЙ ТУЛ
    if tptool and tptool.Parent then
        tptool:Destroy()
        tptool = nil
        tptoolCreated = false
    end
    
    -- УДАЛЯЕМ ТУЛ ИЗ БЭКПАКА ЕСЛИ ОН ТАМ ЕСТЬ
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool.Name == "TPTool" then
            tool:Destroy()
        end
    end
    
    -- УДАЛЯЕМ ТУЛ ИЗ РУК ЕСЛИ ОН ТАМ ЕСТЬ
    local char = LocalPlayer.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "TPTool" then
                tool:Destroy()
            end
        end
    end
    
    if not PlayerState.TPToolCapability.Active then
        return
    end
    
    -- СОЗДАЕМ НОВЫЙ ТУЛ
    tptool = Instance.new("Tool")
    tptool.Name = "TPTool"
    tptool.RequiresHandle = false
    tptool.CanBeDropped = false
    
    -- СОЗДАЕМ GUICONFIG ДЛЯ ТУЛА
    local toolGui = Instance.new("Tool")
    -- НЕ ИСПОЛЬЗУЕМ
    
    -- АКТИВАЦИЯ ТУЛА
    tptool.Activated:Connect(function()
        if isAlive() then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and Mouse then
                -- ТЕЛЕПОРТ В ТОЧКУ КЛИКА + 3 СТУДИИ ВВЕРХ
                hrp.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
            end
        end
    end)
    
    -- ПОМЕЩАЕМ В БЭКПАК
    tptool.Parent = LocalPlayer.Backpack
    tptoolCreated = true
end

-- ========== ФУНКЦИЯ TPTOOL (ВКЛ/ВЫКЛ) ==========
local function ToggleTPTool(Value)
    PlayerState.TPToolCapability.Active = Value
    
    if Value then
        -- СОЗДАЕМ ТУЛ
        CreateTPTool()
        
        -- АВТОМАТИЧЕСКИ БЕРЕМ В РУКИ
        task.wait(0.1)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:EquipTool(tptool)
            end
        end
        
        Luna:Notification({
            Title = "TPTOOL",
            Icon = "check_circle",
            ImageSource = "Material",
            Content = "TPTool создан в инвентаре! Используйте кликом"
        })
        
    else
        -- УДАЛЯЕМ ТУЛ
        if tptool and tptool.Parent then
            tptool:Destroy()
            tptool = nil
            tptoolCreated = false
        end
        
        -- УДАЛЯЕМ ТУЛ ИЗ БЭКПАКА
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool.Name == "TPTool" then
                tool:Destroy()
            end
        end
        
        -- УДАЛЯЕМ ТУЛ ИЗ РУК
        local char = LocalPlayer.Character
        if char then
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == "TPTool" then
                    tool:Destroy()
                end
            end
        end
    end
end

-- ========== ФУНКЦИЯ TPWALK (ИЗ FORSAKEN) ==========
local function ApplyTPWalk()
    if not PlayerState.TPCapability.Active then
        if tpwalkConn then 
            tpwalkConn:Disconnect() 
            tpwalkConn = nil
        end
        return
    end
    
    if tpwalkConn then tpwalkConn:Disconnect() end
    
    tpwalkConn = RunService.RenderStepped:Connect(function()
        if not PlayerState.TPCapability.Active then
            if tpwalkConn then 
                tpwalkConn:Disconnect() 
                tpwalkConn = nil
            end
            return
        end
        
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        
        local dir = hum.MoveDirection
        if dir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (dir * PlayerState.TPCapability.TargetSpeed)
        end
    end)
end

-- ========== ФУНКЦИЯ FLY (ИЗ RAYFIELD) ==========
local function ToggleFly(Value)
    flyEnabled = Value
    PlayerState.FlyCapability.Active = Value
    
    if flyEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChild("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end
        
        if not originalGravity then 
            originalGravity = workspace.Gravity 
        end
        workspace.Gravity = 0
        humanoid.PlatformStand = true
        humanoid.AutoRotate = false
        
        if flyConnection then 
            flyConnection:Disconnect() 
            flyConnection = nil
        end
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled then 
                return 
            end
            
            local char = LocalPlayer.Character
            if not char or not char.Parent then return end
            
            local camera = workspace.CurrentCamera
            if not camera then return end
            
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            local moveDirection = Vector3.new()
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then 
                moveDirection = moveDirection + camera.CFrame.LookVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then 
                moveDirection = moveDirection - camera.CFrame.LookVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then 
                moveDirection = moveDirection - camera.CFrame.RightVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then 
                moveDirection = moveDirection + camera.CFrame.RightVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                moveDirection = moveDirection + Vector3.new(0, 1, 0) 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 
                moveDirection = moveDirection - Vector3.new(0, 1, 0) 
            end
            
            if moveDirection.Magnitude > 0 then 
                moveDirection = moveDirection.Unit 
            end
            
            rootPart.Velocity = moveDirection * flySpeed
        end)
        
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        if originalGravity then 
            workspace.Gravity = originalGravity 
        end
        
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then 
                humanoid.PlatformStand = false 
                humanoid.AutoRotate = true 
            end
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then 
                rootPart.Velocity = Vector3.new(0, 0, 0) 
            end
        end
    end
end

-- ========== ФУНКЦИЯ INFINITE JUMP ==========
local function ApplyInfiniteJump()
    if InfiniteJumpEnabled then
        return
    end
    
    InfiniteJumpEnabled = true
    
    UserInputService.JumpRequest:Connect(function()
        if InfiniteJumpEnabled and PlayerState.JumpCapability.Active then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState("Jumping")
                end
            end
        end
    end)
end

-- ========== ФУНКЦИЯ НОКЛИП ==========
local function ToggleNoclip(Value)
    PlayerState.NoclipCapability.Active = Value
    
    if Value then
        if noclipConnection then noclipConnection:Disconnect() end
        
        noclipConnection = RunService.Stepped:Connect(function()
            if not PlayerState.NoclipCapability.Active then
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end
                return
            end
            
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ========== ФУНКЦИЯ ESP ==========
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
        if espThread then
            espThread:Disconnect()
            espThread = nil
        end
        
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

-- ========== СОЗДАНИЕ GUI (LUNA) ==========
local Window = Luna:CreateWindow({
    Name = "XENO CORE",
    Subtitle = "by ELPRIMO228RB",
    LogoID = nil,
    LoadingEnabled = false,
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "XenoConfig"
    },
    KeySystem = false
})

-- ========== ВКЛАДКА "ИГРОК" ==========
local PlayerTab = Window:CreateTab({
    Name = "Игрок",
    Icon = "person",
    ImageSource = "Material",
    ShowTitle = true
})

-- СЕКЦИЯ TPWALK
PlayerTab:CreateSection("Телепортационная ходьба (TPWALK)")

PlayerTab:CreateToggle({
    Name = "Включить TPWALK",
    Description = "Телепортирует при движении WASD",
    CurrentValue = false,
    Callback = function(Value)
        PlayerState.TPCapability.Active = Value
        if Value then
            ApplyTPWalk()
        else
            if tpwalkConn then 
                tpwalkConn:Disconnect() 
                tpwalkConn = nil
            end
        end
    end
}, "TPWalkToggle")

PlayerTab:CreateSlider({
    Name = "Скорость TPWALK",
    Range = {5, 100},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value)
        PlayerState.TPCapability.Speed = Value
        PlayerState.TPCapability.TargetSpeed = Value / 100
        if PlayerState.TPCapability.Active then
            ApplyTPWalk()
        end
    end
}, "TPWalkSlider")

PlayerTab:CreateDivider()

-- СЕКЦИЯ FLY
PlayerTab:CreateSection("Полет (FLY)")

PlayerTab:CreateToggle({
    Name = "Включить полет",
    Description = "Управление: WASD - движение, Пробел - вверх, Ctrl - вниз",
    CurrentValue = false,
    Callback = function(Value)
        ToggleFly(Value)
    end
}, "FlyToggle")

PlayerTab:CreateSlider({
    Name = "Скорость полета",
    Range = {20, 100},
    Increment = 1,
    CurrentValue = 40,
    Callback = function(Value)
        flySpeed = Value
        PlayerState.FlyCapability.Speed = Value
    end
}, "FlySpeed")

PlayerTab:CreateDivider()

-- СЕКЦИЯ INFINITE JUMP
PlayerTab:CreateSection("Бесконечный прыжок")

PlayerTab:CreateToggle({
    Name = "Включить бесконечный прыжок",
    Description = "Позволяет прыгать бесконечно в воздухе",
    CurrentValue = false,
    Callback = function(Value)
        PlayerState.JumpCapability.Active = Value
        if Value then
            ApplyInfiniteJump()
        else
            InfiniteJumpEnabled = false
        end
    end
}, "JumpToggle")

PlayerTab:CreateDivider()

-- СЕКЦИЯ НОКЛИП
PlayerTab:CreateSection("Ноклип (NOCLIP)")

PlayerTab:CreateToggle({
    Name = "Включить ноклип",
    Description = "Прохождение сквозь стены и объекты",
    CurrentValue = false,
    Callback = function(Value)
        ToggleNoclip(Value)
    end
}, "NoclipToggle")

PlayerTab:CreateDivider()

-- СЕКЦИЯ TPTOOL
PlayerTab:CreateSection("Телепорт по клику (TPTOOL)")

PlayerTab:CreateToggle({
    Name = "Включить TPTOOL",
    Description = "Создает тул в инвентаре. Клик - телепорт",
    CurrentValue = false,
    Callback = function(Value)
        ToggleTPTool(Value)
    end
}, "TPToolToggle")

-- ========== ВКЛАДКА "ВИЗУАЛ" ==========
local VisualTab = Window:CreateTab({
    Name = "Визуал",
    Icon = "visibility",
    ImageSource = "Material",
    ShowTitle = true
})

-- СЕКЦИЯ ESP
VisualTab:CreateSection("Подсветка игроков (ESP)")

VisualTab:CreateToggle({
    Name = "Включить ESP",
    Description = "Подсвечивает всех игроков цветом их команды",
    CurrentValue = false,
    Callback = function(Value)
        ToggleESP(Value)
    end
}, "ESPToggle")

VisualTab:CreateDivider()

-- СЕКЦИЯ ОСВЕЩЕНИЕ
VisualTab:CreateSection("Освещение")

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
        Luna:Notification({
            Title = "Освещение",
            Icon = "check_circle",
            ImageSource = "Material",
            Content = "Полная освещенность включена"
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
        Luna:Notification({
            Title = "Туман",
            Icon = "check_circle",
            ImageSource = "Material",
            Content = "Туман убран"
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
        Luna:Notification({
            Title = "Освещение",
            Icon = "check_circle",
            ImageSource = "Material",
            Content = "Освещение сброшено"
        })
    end
})

-- ========== ВКЛАДКА "ИНФОРМАЦИЯ" ==========
local InfoTab = Window:CreateTab({
    Name = "Информация",
    Icon = "info",
    ImageSource = "Material",
    ShowTitle = true
})

InfoTab:CreateParagraph({
    Title = "XENO CORE V6",
    Text = "Разработано для Executor Xeno\n\nФункции:\n• TPWALK - телепортационная ходьба\n• FLY - полноценный полет\n• INFINITE JUMP - бесконечные прыжки\n• NOCLIP - прохождение сквозь стены\n• TPTOOL - телепорт по клику (тул в инвентаре)\n• ESP - подсветка всех игроков\n\nУправление полетом:\nWASD - движение\nПробел - вверх\nCtrl - вниз\n\nTPTOOL:\nДостаньте тул из инвентаря и кликните\n\nДля телефона используйте плавающую кнопку"
})

-- ========== ВОССТАНОВЛЕНИЕ ПРИ РЕСПАВНЕ ==========
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if PlayerState.TPCapability.Active then ApplyTPWalk() end
    if PlayerState.FlyCapability.Active then ToggleFly(true) end
    if PlayerState.JumpCapability.Active then ApplyInfiniteJump() end
    if PlayerState.NoclipCapability.Active then ToggleNoclip(true) end
    if PlayerState.TPToolCapability.Active then 
        task.wait(0.3)
        CreateTPTool()
    end
    if espEnabled then ToggleESP(true) end
end)

-- ========== УВЕДОМЛЕНИЕ ==========
Luna:Notification({
    Title = "XENO CORE V6",
    Icon = "check_circle",
    ImageSource = "Material",
    Content = "Скрипт загружен! TPTOOL создает тул в инвентаре"
})

print("[XENO_CORE_V6] ЗАГРУЗКА ЗАВЕРШЕНА")
print("[XENO_CORE_V6] TPTOOL РАБОТАЕТ КАК В ВАШЕМ СКРИПТЕ")
