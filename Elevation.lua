-- Miku Scripts - Flotar ON/OFF (estable, funciona si estás en el aire)
local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === UI (celeste, título "Miku Scripts") ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MikuFloatUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 140)
Frame.Position = UDim2.new(0.1, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(150, 210, 255) -- celeste
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Miku Scripts"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(0, 40, 80)
Title.Parent = Frame

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(1, -20, 0, 40)
FloatBtn.Position = UDim2.new(0, 10, 0, 40)
FloatBtn.Text = "Flotar OFF"
FloatBtn.BackgroundColor3 = Color3.fromRGB(100, 190, 255)
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 16
FloatBtn.Parent = Frame
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 10)

local Counter = Instance.new("TextLabel")
Counter.Size = UDim2.new(1, -20, 0, 30)
Counter.Position = UDim2.new(0, 10, 0, 90)
Counter.BackgroundTransparency = 1
Counter.TextColor3 = Color3.fromRGB(0, 50, 100)
Counter.Font = Enum.Font.Gotham
Counter.TextSize = 16
Counter.Text = "15 s"
Counter.Parent = Frame

-- === Lógica de flotado ===
local floating = false
local bv -- BodyVelocity (solo en Y)
local countCoroutine

-- Chequea si hay suelo cerca (para elevar solo si estás en tierra)
local function isGrounded(hrp)
    local origin = hrp.Position
    local direction = Vector3.new(0, -5, 0)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {player.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, params)
    return result ~= nil
end

local function cleanBV()
    if bv and bv.Parent then
        bv:Destroy()
        bv = nil
    end
end

local function stopFloating()
    floating = false
    FloatBtn.Text = "Flotar OFF"
    FloatBtn.BackgroundColor3 = Color3.fromRGB(100, 190, 255)
    cleanBV()
    -- finalizar contador (si existe)
    if countCoroutine then
        -- la coroutine deja de ejecutar al ver floating == false
        countCoroutine = nil
    end
    Counter.Text = "15 s"
end

local function startFloating()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end

    floating = true
    FloatBtn.Text = "Flotar ON"
    FloatBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)

    -- Si estás en el suelo, te eleva un poco; si ya estás en el aire, conserva altura actual
    local grounded = isGrounded(hrp)
    if grounded then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)
    end

    -- Intentar quitar momento vertical instantáneamente (safe pcall)
    pcall(function()
        local vel = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
    end)

    -- Crear BodyVelocity que solo afecte el eje Y para evitar caída,
    -- dejando libre el movimiento horizontal
    cleanBV()
    bv = Instance.new("BodyVelocity")
    bv.Name = "MikuFloatBV"
    bv.Velocity = Vector3.new(0, 0, 0)
    -- MaxForce: solo en Y, lo suficientemente grande para contrarrestar gravedad
    bv.MaxForce = Vector3.new(0, 1e5, 0)
    bv.Parent = hrp

    -- Contador estable (no usamos task.cancel; el bucle respeta `floating`)
    countCoroutine = task.spawn(function()
        local timeLeft = 15
        while floating and timeLeft > 0 do
            Counter.Text = timeLeft .. " s"
            task.wait(1)
            timeLeft = timeLeft - 1
        end
        if floating then
            stopFloating()
        end
    end)
end

-- Toggle instantáneo (solo MouseButton1Click para que no haga hold)
FloatBtn.MouseButton1Click:Connect(function()
    if floating then
        stopFloating()
    else
        startFloating()
    end
end)

-- Aseguramos que si reaparecés, se limpie el BodyVelocity previo
player.CharacterAdded:Connect(function(char)
    -- pequeño delay para que el HRP exista y no quede BV colgado
    task.wait(1)
    cleanBV()
    -- reset estado visual del botón si quedó on por respawn
    floating = false
    FloatBtn.Text = "Flotar OFF"
    FloatBtn.BackgroundColor3 = Color3.fromRGB(100, 190, 255)
    Counter.Text = "15 s"
end)
