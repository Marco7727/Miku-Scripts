-- CONFIG PRINCIPAL
local API_URL = "https://osjdbdidnxhjd.onrender.com"

local HttpService = game:GetService("HttpService")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoJoinUI"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 180)
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 200, 255) -- celeste
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(100, 230, 255) -- celeste más claro
Title.Text = "Miku Scripts" -- nombre cambiado
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Funciones utilitarias
local function formatMoney(num)
    if num >= 1e9 then
        return string.format("%.1fB", num / 1e9)
    elseif num >= 1e6 then
        return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1fK", num / 1e3)
    end
    return tostring(num)
end

local function parseInput(str)
    local num = tonumber(str)
    if num then
        return math.max(num * 1000000, 1e6)
    end
    return nil
end

-- Config por hwid
local hwid = "unknown_hwid"
pcall(function()
    hwid = game:GetService("RbxAnalyticsService"):GetClientId()
end)

local cfgFile = "autojoin_"..hwid..".json"

local function loadConfig()
    if isfile and isfile(cfgFile) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(cfgFile))
        end)
        if ok and type(data) == "table" then
            return data
        end
    end
    return { MinMS = 1000000 }
end

local function saveConfig(cfg)
    if writefile then
        writefile(cfgFile, HttpService:JSONEncode(cfg))
    end
end

local config = loadConfig()
local MinMS = config.MinMS or 1000000
local AutoJoinEnabled = false

-- Botón toggle
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -20, 0, 35)
Toggle.Position = UDim2.new(0, 10, 0, 50)
Toggle.BackgroundColor3 = Color3.fromRGB(100, 230, 255) -- celeste
Toggle.Text = "Auto Join: OFF"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 16
Toggle.Parent = MainFrame

Toggle.MouseButton1Click:Connect(function()
    AutoJoinEnabled = not AutoJoinEnabled
    Toggle.Text = "Auto Join: " .. (AutoJoinEnabled and "ON" or "OFF")
    Toggle.TextColor3 = AutoJoinEnabled and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(255, 255, 255)
end)

-- Label de mínimo
local MinLabel = Instance.new("TextLabel")
MinLabel.Size = UDim2.new(1, -20, 0, 25)
MinLabel.Position = UDim2.new(0, 10, 0, 95)
MinLabel.BackgroundTransparency = 1
MinLabel.Text = "Min M/s: " .. formatMoney(MinMS)
MinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MinLabel.Font = Enum.Font.Gotham
MinLabel.TextSize = 14
MinLabel.Parent = MainFrame

-- Caja de texto
local MinBox = Instance.new("TextBox")
MinBox.Size = UDim2.new(1, -20, 0, 25)
MinBox.Position = UDim2.new(0, 10, 0, 120)
MinBox.BackgroundColor3 = Color3.fromRGB(150, 230, 255) -- celeste suave
MinBox.Text = tostring(MinMS/1000000)
MinBox.TextColor3 = Color3.fromRGB(0, 0, 0)
MinBox.Font = Enum.Font.Gotham
MinBox.TextSize = 14
MinBox.ClearTextOnFocus = false
MinBox.Parent = MainFrame

MinBox.FocusLost:Connect(function()
    local val = parseInput(MinBox.Text)
    if val then
        MinMS = val
        MinLabel.Text = "Min M/s: " .. formatMoney(val)
        saveConfig({ MinMS = MinMS })
        MinBox.Text = tostring(MinMS/1000000)
    else
        MinBox.Text = tostring(MinMS/1000000)
    end
end)

-- HTTP request check
local request = http_request or syn and syn.request or request
if not request then
    warn("Tu executor no soporta http_request.")
    return
end

-- Buscar servers en API
local function checkServers()
    local res = request({ Url = API_URL, Method = "GET" })
    if not res or res.StatusCode ~= 200 then
        warn("Error al pedir datos de la API")
        return {}
    end
    local data = HttpService:JSONDecode(res.Body)
    if not data or not data.servers then return {} end

    local serversToTry = {}
    for _, server in ipairs(data.servers) do
        local s = server.data
        if s and s.money_per_second and s.money_per_second >= MinMS then
            table.insert(serversToTry, s)
        end
    end
    return serversToTry
end

-- Loop principal
task.spawn(function()
    while true do
        if AutoJoinEnabled then
            local servers = checkServers()
            if servers and #servers > 0 then
                local joined = false
                for _, s in ipairs(servers) do
                    local join_script = s.join_script
                    if join_script then
                        local func, err = loadstring(join_script)
                        if func then
                            local success, e = pcall(func)
                            if success then
                                print("[AutoJoin] Teleportado exitosamente a servidor con", s.money_per_second, "M/s")
                                joined = true
                                break
                            else
                                warn("[AutoJoin] No se pudo unir, intentando siguiente server:", e)
                            end
                        else
                            warn("Error cargando join_script:", err)
                        end
                    end
                end
                if not joined then
                    print("[AutoJoin] Todos los servers intentados fallaron, reintentando...")
                end
            else
                print("[AutoJoin] No hay servidores que cumplan MinMS:", formatMoney(MinMS))
            end
        end
        task.wait(1)
    end
end)
