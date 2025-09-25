--[[
AKUNBITCH DEVOURER - Painel compacto, drag, remove acessórios/roupas, agora com TODOS os objetos
Botón simple ON/OFF verde/rojo para spam equip/unequip de todos los Tools.
by LennonTheGoat + adaptado
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- ================= REMOVE TODOS ACCESORIOS/ROPA =================
local function removeAllAccessoriesFromCharacter()
    local character = player.Character
    if not character then return end
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Accessory")
        or item:IsA("LayeredClothing")
        or item:IsA("Shirt")
        or item:IsA("ShirtGraphic")
        or item:IsA("Pants")
        or item:IsA("BodyColors")
        or item:IsA("CharacterMesh") then
            pcall(function() item:Destroy() end)
        end
    end
end
player.CharacterAdded:Connect(function()
    task.wait(0.2)
    removeAllAccessoriesFromCharacter()
end)
if player.Character then
    task.defer(removeAllAccessoriesFromCharacter)
end

-- ================= DIMENSIONES =================
local SCALE = 0.7
local PANEL_WIDTH, PANEL_HEIGHT = math.floor(212*SCALE), math.floor(90*SCALE)
local PANEL_RADIUS = math.floor(13*SCALE)
local TITLE_HEIGHT = math.floor(32*SCALE)
local BTN_WIDTH = math.floor(0.89*PANEL_WIDTH)
local BTN_HEIGHT = math.floor(34*SCALE)
local BTN_RADIUS = math.floor(8*SCALE)
local BTN_FONT_SIZE = math.floor(17*SCALE)
local TITLE_FONT_SIZE = math.floor(19*SCALE)
local BTN_Y0 = math.floor(38*SCALE)

-- ================= FUNCIONES EQUIP/UNEQUIP TODOS TOOLS =================
local running = false
local function equipAllTools()
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not character or not backpack then return end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = character
        end
    end
end

local function unequipAllTools()
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not character or not backpack then return end
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = backpack
        end
    end
end

local function startLoop()
    running = true
    task.spawn(function()
        while running do
            equipAllTools()
            task.wait(0.035)
            unequipAllTools()
            task.wait(0.035)
        end
    end)
end

local function stopLoop()
    running = false
    unequipAllTools()
end

-- ================= REMOVE PANEL ANTIGUO =================
local old = playerGui:FindFirstChild("AkunBitchDevourerPanel")
if old then old:Destroy() end

-- ================= PANEL UI =================
local gui = Instance.new("ScreenGui")
gui.Name = "AkunBitchDevourerPanel"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame", gui)
main.Name = "MainPanel"
main.Size = UDim2.new(0, PANEL_WIDTH, 0, PANEL_HEIGHT)
main.Position = UDim2.new(1, -PANEL_WIDTH-10, 0, 10) -- esquina superior derecha
main.BackgroundColor3 = Color3.fromRGB(13,13,13)
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, PANEL_RADIUS)

-- ================= DRAG DEL PANEL =================
do
    local dragging, dragInput, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ================= TÍTULO =================
local title = Instance.new("TextLabel", main)
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, TITLE_HEIGHT)
title.Position = UDim2.new(0,0,0,0)
title.Text = "AKUNBITCH DEVOURER"
title.Font = Enum.Font.GothamBlack
title.TextSize = TITLE_FONT_SIZE
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextStrokeTransparency = 0.08
title.TextStrokeColor3 = Color3.fromRGB(220,220,220)

-- ================= BOTÓN SIMPLE =================
local button = Instance.new("TextButton", main)
button.Size = UDim2.new(0, BTN_WIDTH, 0, BTN_HEIGHT)
button.Position = UDim2.new(0, (PANEL_WIDTH-BTN_WIDTH)/2, 0, BTN_Y0)
button.Text = "OFF - Devourer (All Tools)"
button.BackgroundColor3 = Color3.fromRGB(200,50,50)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Font = Enum.Font.GothamBold
button.TextSize = BTN_FONT_SIZE
button.BorderSizePixel = 0
Instance.new("UICorner", button).CornerRadius = UDim.new(0, BTN_RADIUS)

local state = false
local function updateVisual()
    if state then
        button.Text = "ON - Devourer (All Tools)"
        button.BackgroundColor3 = Color3.fromRGB(50,200,50)
    else
        button.Text = "OFF - Devourer (All Tools)"
        button.BackgroundColor3 = Color3.fromRGB(200,50,50)
    end
end
updateVisual()

button.MouseButton1Click:Connect(function()
    state = not state
    updateVisual()
    if state then
        startLoop()
    else
        stopLoop()
    end
end)

-- ================= REINICIA AL RESPAWN =================
player.CharacterAdded:Connect(function()
    state = false
    updateVisual()
    stopLoop()
    task.wait(0.2)
    removeAllAccessoriesFromCharacter()
end)
