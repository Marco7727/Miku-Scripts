-- 🔑 Marquitosuper12 Key System & Auto-Join Script 🔑
-- Compatible con sistema de Discord Bot integrado

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 🌐 Configuración de API
local API_BASE_URL = "https://121e871f-7129-414a-a149-5c8bfbfc0752-00-kvq9oqtrnxb.riker.replit.dev/"
local KEY_VALIDATION_ENDPOINT = API_BASE_URL .. "/api/key-validation"
local SERVER_DATA_ENDPOINT = API_BASE_URL .. "/api/roblox-script"

-- 🔧 Variables globales
local isValidated = false
local userKey = nil
local deviceHWID = nil
local autoJoinEnabled = false
local currentServers = {}

-- 📱 Generar HWID único del dispositivo
local function generateDeviceHWID()
    local hwid = ""
    
    -- Combinar múltiples factores únicos del dispositivo
    hwid = hwid .. tostring(player.UserId)
    hwid = hwid .. tostring(game.PlaceId) 
    
    -- Agregar información del cliente (esto será consistente por dispositivo)
    local success, clientInfo = pcall(function()
        return game:GetService("UserInputService").TouchEnabled .. 
               tostring(game:GetService("UserInputService").KeyboardEnabled) ..
               tostring(game:GetService("UserInputService").MouseEnabled) ..
               tostring(game:GetService("UserInputService").GamepadEnabled)
    end)
    
    if success then
        hwid = hwid .. clientInfo
    end
    
    -- Crear hash único más robusto
    local hashString = ""
    for i = 1, #hwid do
        local char = string.byte(hwid, i)
        hashString = hashString .. string.format("%02x", char)
    end
    
    -- Usar una función de hash simple pero efectiva
    local hash = 0
    for i = 1, #hashString do
        hash = ((hash * 31) + string.byte(hashString, i)) % 1000000000
    end
    
    return "MARQUITO_" .. tostring(hash) .. "_" .. string.sub(hashString, 1, 8)
end

-- 🔐 Validar key con el servidor
local function validateKey(key)
    if not key or key == "" then
        return false, "Key no puede estar vacía"
    end
    
    local url = KEY_VALIDATION_ENDPOINT .. "?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(deviceHWID)
    
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)
    
    if not success then
        return false, "Error de conexión: " .. tostring(response)
    end
    
    local data = HttpService:JSONDecode(response)
    
    if data.valid then
        local message = data.message or "Key válida! Bienvenid@ a Miku Scripts."
        if string.find(message, "HWID actualizado") then
            message = "✅ Key vinculada a este dispositivo exitosamente!"
        end
        return true, message
    else
        return false, data.message or "Key inválida"
    end
end

-- 🎮 Obtener datos de servidores desde la API
local function getServerData()
    local success, response = pcall(function()
        return HttpService:GetAsync(SERVER_DATA_ENDPOINT .. "?min_threshold=500000&max_threshold=50000000000")
    end)
    
    if not success then
        warn("Error obteniendo datos de servidores: " .. tostring(response))
        return {}
    end
    
    local data = HttpService:JSONDecode(response)
        warn("Datos de servidor inválidos")
        return
    end
    
    local placeId = serverData.data.place_id
    local jobId = serverData.data.job_id
    
    if not placeId or not jobId then
        warn("Place ID o Job ID faltante")
        return
    end
    
    print("🚀 Uniéndose a servidor: " .. serverData.data.money .. " | " .. serverData.data.players .. " jugadores")
    print("🏷️ Brainrot: " .. (serverData.data.brainrot_name or "Desconocido"))
    
    local success, error = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
    end)
    
    if not success then
        warn("Error al unirse al servidor: " .. tostring(error))
    end
end

-- 🖥️ Crear GUI de validación de key
local function createKeyValidationGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeyValidationGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔑 Miku Scripts Key System"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    -- Info HWID
    local hwidLabel = Instance.new("TextLabel")
    hwidLabel.Name = "HWIDLabel"
    hwidLabel.Size = UDim2.new(1, -20, 0, 30)
    hwidLabel.Position = UDim2.new(0, 10, 0, 60)
    hwidLabel.BackgroundTransparency = 1
    hwidLabel.Text = "📱 HWID: " .. deviceHWID
    hwidLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    hwidLabel.TextScaled = true
    hwidLabel.Font = Enum.Font.Gotham
    hwidLabel.Parent = mainFrame
    
    -- Campo de texto para key
    local keyTextBox = Instance.new("TextBox")
    keyTextBox.Name = "KeyTextBox"
    keyTextBox.Size = UDim2.new(1, -40, 0, 40)
    keyTextBox.Position = UDim2.new(0, 20, 0, 110)
    keyTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    keyTextBox.BorderSizePixel = 0
    keyTextBox.PlaceholderText = "Pega tu key aquí..."
    keyTextBox.Text = ""
    keyTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyTextBox.TextScaled = true
    keyTextBox.Font = Enum.Font.Gotham
    keyTextBox.Parent = mainFrame
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 6)
    keyCorner.Parent = keyTextBox
    
    -- Botón de validación
    local validateButton = Instance.new("TextButton")
    validateButton.Name = "ValidateButton"
    validateButton.Size = UDim2.new(1, -40, 0, 40)
    validateButton.Position = UDim2.new(0, 20, 0, 170)
    validateButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    validateButton.BorderSizePixel = 0
    validateButton.Text = "🔐 Validar Key"
    validateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    validateButton.TextScaled = true
    validateButton.Font = Enum.Font.GothamBold
    validateButton.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = validateButton
    
    -- Label de status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -20, 0, 60)
    statusLabel.Position = UDim2.new(0, 10, 0, 220)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Introduce tu key"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextWrapped = true
    statusLabel.Parent = mainFrame
    
    -- Función de validación
    validateButton.MouseButton1Click:Connect(function()
        local key = keyTextBox.Text:gsub("%s", "") -- Remover espacios
        
        if key == "" then
            statusLabel.Text = "❌ Por favor introduce una key"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        statusLabel.Text = "🔄 Validando key..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        validateButton.Text = "🔄 Validando..."
        
        wait(1) -- Pequeña pausa para UX
        
        local success, message = validateKey(key)
        
        if success then
            isValidated = true
            userKey = key
            statusLabel.Text = "✅ " .. message
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            validateButton.Text = "✅ Key Válida"
            
            wait(2)
            screenGui:Destroy()
            createMainGUI()
        else
            statusLabel.Text = "❌ " .. message
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            validateButton.Text = "🔐 Validar Key"
        end
    end)
    
    return screenGui
end

-- 🎯 Crear GUI principal del auto-join
local function createMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoJoinGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🧠 Brainrot Auto-Join | Miku Scripts"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    -- Toggle de auto-join
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, -20, 0, 40)
    toggleButton.Position = UDim2.new(0, 10, 0, 50)
    toggleButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    toggleButton.Text = "🔴 Auto-Join: OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = mainFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleButton
    
    -- Lista de servidores
    local serverScrollFrame = Instance.new("ScrollingFrame")
    serverScrollFrame.Size = UDim2.new(1, -20, 1, -150)
    serverScrollFrame.Position = UDim2.new(0, 10, 0, 100)
    serverScrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    serverScrollFrame.BorderSizePixel = 0
    serverScrollFrame.ScrollBarThickness = 6
    serverScrollFrame.Parent = mainFrame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 6)
    scrollCorner.Parent = serverScrollFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = serverScrollFrame
    
    -- Función para actualizar lista de servidores
    local function updateServerList()
        -- Limpiar lista actual
        for _, child in pairs(serverScrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        currentServers = getServerData()
        
        for i, serverData in ipairs(currentServers) do
            if i > 10 then break end -- Máximo 10 servidores
            
            local serverFrame = Instance.new("Frame")
            serverFrame.Size = UDim2.new(1, -12, 0, 70)
            serverFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            serverFrame.BorderSizePixel = 0
            serverFrame.Parent = serverScrollFrame
            
            local serverCorner = Instance.new("UICorner")
            serverCorner.CornerRadius = UDim.new(0, 4)
            serverCorner.Parent = serverFrame
            
            -- Información del servidor
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Size = UDim2.new(0.7, 0, 1, 0)
            infoLabel.BackgroundTransparency = 1
            infoLabel.Text = "💰 " .. serverData.data.money .. "\n👥 " .. serverData.data.players .. "\n🏷️ " .. (serverData.data.brainrot_name or "Unknown")
            infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            infoLabel.TextScaled = true
            infoLabel.Font = Enum.Font.Gotham
            infoLabel.Parent = serverFrame
            
            -- Botón de join
            local joinButton = Instance.new("TextButton")
            joinButton.Size = UDim2.new(0.25, 0, 0.8, 0)
            joinButton.Position = UDim2.new(0.72, 0, 0.1, 0)
            joinButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            joinButton.Text = "🚀 Join"
            joinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            joinButton.TextScaled = true
            joinButton.Font = Enum.Font.GothamBold
            joinButton.Parent = serverFrame
            
            local joinCorner = Instance.new("UICorner")
            joinCorner.CornerRadius = UDim.new(0, 4)
            joinCorner.Parent = joinButton
            
            joinButton.MouseButton1Click:Connect(function()
                joinServer(serverData)
            end)
        end
        
        serverScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #currentServers * 75)
    end
    
    -- Toggle auto-join
    toggleButton.MouseButton1Click:Connect(function()
        autoJoinEnabled = not autoJoinEnabled
        
        if autoJoinEnabled then
            toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            toggleButton.Text = "🟢 Auto-Join: ON"
        else
            toggleButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
            toggleButton.Text = "🔴 Auto-Join: OFF"
        end
    end)
    
    -- Actualizar servidores cada 5 segundos
    spawn(function()
        while true do
            if isValidated then
                updateServerList()
            end
            wait(5)
        end
    end)
    
    -- Auto-join logic
    spawn(function()
        while true do
            if autoJoinEnabled and isValidated and #currentServers > 0 then
                local bestServer = currentServers[1] -- El primer servidor (mejor)
                if bestServer and bestServer.data and bestServer.data.money_per_second > 1000000 then -- Mínimo 1M/s
                    print("🤖 Auto-join activado! Uniéndose al mejor servidor...")
                    joinServer(bestServer)
                    wait(10) -- Esperar antes del próximo intento
                end
            end
            wait(3)
        end
    end)
    
    -- Actualización inicial
    updateServerList()
end

-- 🚀 Función principal de inicio
local function initializeScript()
    print("🔑 Iniciando Miku Scripts Key System...")
    
    -- Generar HWID
    deviceHWID = generateDeviceHWID()
    print("📱 HWID generado: " .. deviceHWID)
    
    -- Crear GUI de validación
    createKeyValidationGUI()
end

-- 🎮 Inicializar cuando el jugador esté listo
if player.Character then
    initializeScript()
else
    player.CharacterAdded:Connect(initializeScript)
end

print("✅ Script cargado exitosamente! Usa tu key para acceder.")
