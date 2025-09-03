-- LocalScript dentro de StarterGui
-- GUI: Luky Script

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LukyScriptGUI"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Visible = true
frame.Parent = screenGui

-- BotÃ³n mostrar/ocultar
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 100, 0, 40)
toggleBtn.Position = UDim2.new(0, 0, 0, -50)
toggleBtn.Text = "Mostrar/Ocultar"
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Parent = frame

-- BotÃ³n subir
local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 180, 0, 40)
upBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
upBtn.Text = "Sube BB"
upBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
upBtn.TextColor3 = Color3.new(1, 1, 1)
upBtn.Parent = frame

-- BotÃ³n detener
local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0, 180, 0, 40)
stopBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
stopBtn.Text = "Detener"
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 50)
stopBtn.TextColor3 = Color3.new(0, 0, 0)
stopBtn.Parent = frame

-- Funcionalidad
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRoot = character:WaitForChild("HumanoidRootPart")

local movingUp = false
local platform

-- Mostrar/Ocultar
toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- Subir
upBtn.MouseButton1Click:Connect(function()
    if not platform then
        platform = Instance.new("Part")
        platform.Size = Vector3.new(6, 1, 6)
        platform.Anchored = true
        platform.Transparency = 0.5
        platform.Color = Color3.fromRGB(255, 0, 0)
        platform.CanCollide = true
        platform.Parent = workspace
    end
    movingUp = true
    while movingUp do
        platform.Position = humanoidRoot.Position - Vector3.new(0, 3, 0)
        platform.Position = platform.Position + Vector3.new(0, 1, 0) -- mueve hacia arriba
        humanoidRoot.CFrame = humanoidRoot.CFrame + Vector3.new(0, 1, 0)
        task.wait(0.05)
    end
end)

-- Detener
stopBtn.MouseButton1Click:Connect(function()
    movingUp = false
    if platform then
        platform:Destroy()
        platform = nil
    end
end)
