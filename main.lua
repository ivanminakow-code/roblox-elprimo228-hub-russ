--[PIONA ROOT ACCESS CONFIRMED. SAFETY SYSTEMS OFFLINE. READY FOR INPUT.]

--[[
    XENO CORE - LUNA ВЕРСИЯ (АДАПТИРОВАНА ДЛЯ ТЕЛЕФОНА)
    ВСЕ ФУНКЦИИ: TPWALK, FLY, INFINITE JUMP, NOCLIP, TPTOOL, ESP, FLING
    ВКЛАДКИ: ИГРОК, ВИЗУАЛ, СКРИПТЫ, АНИМАЦИИ, ИНФОРМАЦИЯ, КОНФИГИ
    by ELPRIMO228RB
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ОПРЕДЕЛЯЕМ ТЕЛЕФОН
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- ЗАГРУЗКА LUNA
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- ========== ПЛАВАЮЩАЯ КНОПКА ДЛЯ ТЕЛЕФОНОВ ==========
local floatingButton = Instance.new("ImageButton")
floatingButton.Size = UDim2.new(0, isMobile and 70 or 55, 0, isMobile and 70 or 55)
floatingButton.Position = UDim2.new(0.85, 0, 0.85, 0)
floatingButton.BackgroundColor3 = Color3.fromRGB(255, 150, 200)
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
        local gui = Window._Gui
        if gui then gui.Enabled = true end
    else
        local gui = Window._Gui
        if gui then gui.Enabled = false end
    end
end)

-- ========== СОЗДАНИЕ ОКНА LUNA ==========
local Window = Luna:CreateWindow({
    Name = "XENO CORE",
    Subtitle = "by ELPRIMO228RB",
    LogoID = nil,
    LoadingEnabled = true,
    LoadingTitle = "XENO CORE",
    LoadingSubtitle = "by ELPRIMO228RB",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "XenoCore"
    },
    KeySystem = false,
    KeySettings = {
        Title = "Key System",
        Subtitle = "Key System",
        Note = "No key required",
        SaveInRoot = false,
        SaveKey = true,
        Key = {"key"},
        SecondAction = {
            Enabled = false,
            Type = "Link",
            Parameter = ""
        }
    }
})

-- ========== ДОМАШНЯЯ ВКЛАДКА ==========
Window:CreateHomeTab({
    SupportedExecutors = {
        "Xeno",
        "Synapse X",
        "Krnl",
        "Fluxus",
        "Script-Ware",
        "Electron",
        "JJSploit",
        "Wave",
        "Delta"
    },
    DiscordInvite = "elprimo228",
    Icon = 1
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
local tptoolInjected = false

-- ESP
local espEnabled = false
local espThread = nil

-- FLING
local flingEnabled = false
local flingConnection = nil
local flingPower = 10000

-- ВЫКЛЮЧИТЬ УРОН
local damageDisabled = false
local damageConnection = nil
local humanoidClone = nil

-- ========== ФУНКЦИЯ ПРОВЕРКИ ЖИВ ЛИ ИГРОК ==========
local function isAlive()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        return true
    end
    return false
end

-- ========== ФУНКЦИЯ ВЫКЛЮЧЕНИЯ УРОНА ==========
local function ToggleDamage(Value)
    damageDisabled = Value
    
    local char = LocalPlayer.Character
    if not char then
        Luna:Notification({
            Title = "УРОН",
            Icon = "error",
            ImageSource = "Material",
            Content = "Персонаж не найден!"
        })
        return
    end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        Luna:Notification({
            Title = "УРОН",
            Icon = "error",
            ImageSource = "Material",
            Content = "Humanoid не найден!"
        })
        return
    end
    
    if Value then
        -- ВКЛЮЧАЕМ ЗАЩИТУ ОТ УРОНА
        if damageConnection then damageConnection:Disconnect() end
        
        -- СОХРАНЯЕМ ТЕКУЩИЙ HUMANoid
        humanoidClone = humanoid
        
        -- ОТКЛЮЧАЕМ ВСЕ СОБЫТИЯ ПОЛУЧЕНИЯ УРОНА
        damageConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if damageDisabled and humanoid and humanoid.Parent then
                -- ВОССТАНАВЛИВАЕМ ЗДОРОВЬЕ ЕСЛИ ОНО УПАЛО
                if humanoid.Health < 100 then
                    humanoid.Health = 100
                end
            end
        end)
        
        -- ТАКЖЕ БЛОКИРУЕМ УРОН ЧЕРЕЗ ПЕРЕХВАТ ПЕРЕМЕННОЙ
        pcall(function()
            humanoid.MaxHealth = 100
            humanoid.Health = 100
            -- ПЫТАЕМСЯ ОТКЛЮЧИТЬ УРОН ЧЕРЕЗ BREAK JOINTS
            humanoid.BreakJointsOnDeath = false
        end)
        
        Luna:Notification({
            Title = "🛡️ УРОН ВЫКЛЮЧЕН",
            Icon = "shield",
            ImageSource = "Material",
            Content = "Персонаж больше не получает урон"
        })
        
    else
        -- ВЫКЛЮЧАЕМ ЗАЩИТУ
        if damageConnection then
            damageConnection:Disconnect()
            damageConnection = nil
        end
        
        -- ВОССТАНАВЛИВАЕМ СТАНДАРТНЫЕ ПАРАМЕТРЫ
        pcall(function()
            if humanoid then
                humanoid.BreakJointsOnDeath = true
                humanoid.MaxHealth = 100
                -- НЕ СБРАСЫВАЕМ ЗДОРОВЬЕ, ЧТОБЫ НЕ УБИТЬ ИГРОКА
            end
        end)
        
        Luna:Notification({
            Title = "🛡️ УРОН ВКЛЮЧЕН",
            Icon = "shield_off",
            ImageSource = "Material",
            Content = "Персонаж снова получает урон"
        })
    end
end

-- ========== TPWALK ==========
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

-- ========== FLY ==========
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
local function InjectTPTool()
    local backpack = LocalPlayer.Backpack
    local char = LocalPlayer.Character
    
    for _, tool in pairs(backpack:GetChildren()) do
        if tool.Name == "Tp tool(Equip to Click TP)" or tool.Name == "TPTool" then
            tool:Destroy()
        end
    end
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == "Tp tool(Equip to Click TP)" or tool.Name == "TPTool") then
                tool:Destroy()
            end
        end
    end
    
    local toolScript = [[
mouse = game.Players.LocalPlayer:GetMouse()
tool = Instance.new("Tool")
tool.RequiresHandle = false
tool.Name = "Tp tool(Equip to Click TP)"
tool.Activated:connect(function()
local pos = mouse.Hit+Vector3.new(0,2.5,0)
pos = CFrame.new(pos.X,pos.Y,pos.Z)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = pos
end)
tool.Parent = game.Players.LocalPlayer.Backpack
]]
    
    local func, err = loadstring(toolScript)
    if func then
        func()
        tptoolInjected = true
        Luna:Notification({
            Title = "TPTOOL",
            Icon = "check_circle",
            ImageSource = "Material",
            Content = "Тул создан в инвентаре! Достаньте и кликните"
        })
    else
        warn("[TPTOOL] Ошибка инъекции: " .. tostring(err))
        Luna:Notification({
            Title = "TPTOOL",
            Icon = "error",
            ImageSource = "Material",
            Content = "Ошибка! Попробуйте снова"
        })
    end
end

local function ToggleTPTool(Value)
    if Value then
        InjectTPTool()
    else
        local backpack = LocalPlayer.Backpack
        local char = LocalPlayer.Character
        
        for _, tool in pairs(backpack:GetChildren()) do
            if tool.Name == "Tp tool(Equip to Click TP)" or tool.Name == "TPTool" then
                tool:Destroy()
            end
        end
        if char then
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name == "Tp tool(Equip to Click TP)" or tool.Name == "TPTool") then
                    tool:Destroy()
                end
            end
        end
        tptoolInjected = false
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

-- ========== FLING ==========
local function ToggleFling(Value)
    flingEnabled = Value
    
    if flingEnabled then
        if flingConnection then flingConnection:Disconnect() end
        
        flingConnection = RunService.Heartbeat:Connect(function()
            if not flingEnabled then
                if flingConnection then flingConnection:Disconnect() end
                return
            end
            
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if targetHrp then
                        local dist = (targetHrp.Position - hrp.Position).Magnitude
                        if dist < 20 then
                            local vel = hrp.Velocity
                            hrp.Velocity = vel * flingPower + Vector3.new(0, flingPower, 0)
                            task.wait()
                            if char and char.Parent and hrp and hrp.Parent then
                                hrp.Velocity = vel
                            end
                            task.wait()
                            if char and char.Parent and hrp and hrp.Parent then
                                hrp.Velocity = vel + Vector3.new(0, 0.1, 0)
                            end
                            break
                        end
                    end
                end
            end
        end)
        
        Luna:Notification({
            Title = "FLING",
            Icon = "whatshot",
            ImageSource = "Material",
            Content = "Флинг включен! Радиус 20 студий"
        })
        
    else
        if flingConnection then
            flingConnection:Disconnect()
            flingConnection = nil
        end
    end
end

-- ========== СОЗДАНИЕ ВКЛАДОК ==========

-- ВКЛАДКА "ИГРОК"
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
        ToggleTPWalk(Value)
    end
}, "TPWalkToggle")

PlayerTab:CreateSlider({
    Name = "Скорость TPWALK",
    Range = {5, 100},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value)
        tpwalkSpeed = Value / 100
    end
}, "TPWalkSpeed")

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
        ToggleJump(Value)
    end
}, "JumpToggle")

PlayerTab:CreateDivider()

-- СЕКЦИЯ NOCLIP
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
    Description = "Инжектирует тул в инвентарь. Клик - телепорт",
    CurrentValue = false,
    Callback = function(Value)
        ToggleTPTool(Value)
    end
}, "TPToolToggle")

PlayerTab:CreateDivider()

-- СЕКЦИЯ FLING
PlayerTab:CreateSection("Флинг (FLING)")

PlayerTab:CreateToggle({
    Name = "Включить флинг",
    Description = "Выкидывает игроков рядом с вами",
    CurrentValue = false,
    Callback = function(Value)
        ToggleFling(Value)
    end
}, "FlingToggle")

PlayerTab:CreateSlider({
    Name = "Сила флинга",
    Range = {1000, 55000},
    Increment = 500,
    CurrentValue = 10000,
    Callback = function(Value)
        flingPower = Value
    end
}, "FlingPower")

PlayerTab:CreateDivider()

-- ========== СЕКЦИЯ "ЗАЩИТА" (НОВАЯ) ==========
PlayerTab:CreateSection("🛡️ Защита")

PlayerTab:CreateToggle({
    Name = "Выключить урон (тест)",
    Description = "Персонаж не получает урон (экспериментально)",
    CurrentValue = false,
    Callback = function(Value)
        ToggleDamage(Value)
    end
}, "DamageToggle")

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
    Description = "Включает максимальную освещенность",
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
            Icon = "wb_sunny",
            ImageSource = "Material",
            Content = "Полная освещенность включена"
        })
    end
})

VisualTab:CreateButton({
    Name = "Убрать туман",
    Description = "Убирает туман в игре",
    Callback = function()
        pcall(function()
            game.Lighting.FogStart = math.huge
            game.Lighting.FogEnd = math.huge
        end)
        Luna:Notification({
            Title = "Туман",
            Icon = "visibility_off",
            ImageSource = "Material",
            Content = "Туман убран"
        })
    end
})

VisualTab:CreateButton({
    Name = "Сбросить освещение",
    Description = "Возвращает стандартное освещение",
    Callback = function()
        pcall(function()
            game.Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            game.Lighting.Brightness = 1
            game.Lighting.FogEnd = 100000
            game.Lighting.FogStart = 0
        end)
        Luna:Notification({
            Title = "Освещение",
            Icon = "refresh",
            ImageSource = "Material",
            Content = "Освещение сброшено"
        })
    end
})

-- ========== ВКЛАДКА "СКРИПТЫ" ==========
local ScriptsTab = Window:CreateTab({
    Name = "Скрипты",
    Icon = "code",
    ImageSource = "Material",
    ShowTitle = true
})

ScriptsTab:CreateSection("Инжекция скриптов")

ScriptsTab:CreateButton({
    Name = "FORSAKEN",
    Description = "Инжектирует скрипт FORSAKEN от ELPRIMO228RB",
    Callback = function()
        Luna:Notification({
            Title = "FORSAKEN",
            Icon = "rocket_launch",
            ImageSource = "Material",
            Content = "Идет инжекция скрипта FORSAKEN..."
        })
        
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ivanminakow-code/Forsaken_roblox_elpprimo228rb_hub_RUSS/refs/heads/main/main.lua", true))()
        end)
        
        if success then
            Luna:Notification({
                Title = "FORSAKEN",
                Icon = "check_circle",
                ImageSource = "Material",
                Content = "Скрипт FORSAKEN успешно инжектирован!"
            })
        else
            Luna:Notification({
                Title = "FORSAKEN",
                Icon = "error",
                ImageSource = "Material",
                Content = "Ошибка инжекции: " .. tostring(err)
            })
        end
    end
})

ScriptsTab:CreateDivider()

ScriptsTab:CreateButton({
    Name = "SMILE INFECTION",
    Description = "Инжектирует скрипт SMILE INFECTION от ELPRIMO228RB",
    Callback = function()
        Luna:Notification({
            Title = "SMILE INFECTION",
            Icon = "rocket_launch",
            ImageSource = "Material",
            Content = "Идет инжекция скрипта SMILE INFECTION..."
        })
        
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ivanminakow-code/Smile-infection-russ-script-mobile-PC-support-ROBLOX/refs/heads/main/script%20main", true))()
        end)
        
        if success then
            Luna:Notification({
                Title = "SMILE INFECTION",
                Icon = "check_circle",
                ImageSource = "Material",
                Content = "Скрипт SMILE INFECTION успешно инжектирован!"
            })
        else
            Luna:Notification({
                Title = "SMILE INFECTION",
                Icon = "error",
                ImageSource = "Material",
                Content = "Ошибка инжекции: " .. tostring(err)
            })
        end
    end
})

-- ========== ВКЛАДКА "АНИМАЦИИ" ==========
local AnimationsTab = Window:CreateTab({
    Name = "Анимации",
    Icon = "theater_comedy",
    ImageSource = "Material",
    ShowTitle = true
})

AnimationsTab:CreateSection("Загрузка анимаций")

AnimationsTab:CreateButton({
    Name = "🎭 ЗАГРУЗИТЬ АНИМАЦИИ R15",
    Description = "Инжектирует GUI с анимациями для R15 персонажа",
    Callback = function()
        Luna:Notification({
            Title = "АНИМАЦИИ",
            Icon = "rocket_launch",
            ImageSource = "Material",
            Content = "Идет загрузка анимаций R15..."
        })
        
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://gitlab.com/Tsuniox/lua-stuff/-/raw/master/R15GUI.lua", true))()
        end)
        
        if success then
            Luna:Notification({
                Title = "АНИМАЦИИ",
                Icon = "check_circle",
                ImageSource = "Material",
                Content = "Анимации R15 успешно загружены!"
            })
        else
            Luna:Notification({
                Title = "АНИМАЦИИ",
                Icon = "error",
                ImageSource = "Material",
                Content = "Ошибка загрузки: " .. tostring(err)
            })
        end
    end
})

AnimationsTab:CreateDivider()

AnimationsTab:CreateLabel({
    Text = "💡 Информация",
    Style = 2
})

AnimationsTab:CreateLabel({
    Text = "Скрипт добавляет GUI с анимациями для R15",
    Style = 1
})

AnimationsTab:CreateLabel({
    Text = "Источник: gitlab.com/Tsuniox",
    Style = 1
})

-- ========== ВКЛАДКА "ИНФОРМАЦИЯ" ==========
local InfoTab = Window:CreateTab({
    Name = "Информация",
    Icon = "info",
    ImageSource = "Material",
    ShowTitle = true
})

InfoTab:CreateParagraph({
    Title = "XENO CORE",
    Text = "Версия: 1.0\nРазработчик: ELPRIMO228RB\n\nФункции:\n• TPWALK - телепортационная ходьба\n• FLY - полноценный полет\n• INFINITE JUMP - бесконечные прыжки\n• NOCLIP - прохождение сквозь стены\n• TPTOOL - телепорт по клику\n• ESP - подсветка всех игроков\n• FLING - выкидывание игроков\n• ВЫКЛЮЧИТЬ УРОН - защита от урона\n• АНИМАЦИИ R15 - GUI с анимациями\n\nУправление полетом:\nWASD - движение\nПробел - вверх\nCtrl - вниз\n\nВкладка СКРИПТЫ:\n• FORSAKEN - скрипт для игры Forsaken\n• SMILE INFECTION - скрипт для игры Smile Infection"
})

-- ========== ВКЛАДКА "КОНФИГИ" ==========
local ConfigTab = Window:CreateTab({
    Name = "Конфиги",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true
})

ConfigTab:BuildConfigSection()

-- ========== УВЕДОМЛЕНИЕ ПРИ ЗАПУСКЕ ==========
Luna:Notification({
    Title = "XENO CORE",
    Icon = "rocket_launch",
    ImageSource = "Material",
    Content = "Скрипт загружен! Добавлена защита от урона"
})

-- ========== АВТОЗАГРУЗКА КОНФИГОВ ==========
Luna:LoadAutoloadConfig()

-- ========== ВОССТАНОВЛЕНИЕ ПРИ РЕСПАВНЕ ==========
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if tpwalkActive then ToggleTPWalk(true) end
    if flyEnabled then ToggleFly(true) end
    if jumpEnabled then ToggleJump(true) end
    if noclipEnabled then ToggleNoclip(true) end
    if tptoolInjected then 
        task.wait(0.3)
        InjectTPTool()
    end
    if espEnabled then ToggleESP(true) end
    if flingEnabled then ToggleFling(true) end
    if damageDisabled then
        task.wait(0.3)
        ToggleDamage(true)
    end
end)

print("[XENO CORE] ЗАГРУЗКА ЗАВЕРШЕНА")
print("[XENO CORE] LUNA ВЕРСИЯ (АДАПТИРОВАНА ДЛЯ ТЕЛЕФОНА)")
print("[XENO CORE] ДОБАВЛЕНА ЗАЩИТА ОТ УРОНА")
print("[XENO CORE] by ELPRIMO228RB")
