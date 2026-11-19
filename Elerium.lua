--[[
    Librería de UI estilo "ImGui" para Roblox (Luau)
    Versión legible del script minificado original.

    Uso básico:
        local lib = loadstring(...)()
        local window = lib:AddWindow("Mi ventana")
        local tab = window:AddTab("Principal")
        tab:AddButton("Hola", function() print("click") end)
        tab:AddSwitch("Activar", function(on) print(on) end)
        tab:AddSlider("Velocidad", function(v) print(v) end, {min = 0, max = 100})
        tab:AddKeybind("Atajo", function(key) print(key) end)
        local dropdown = tab:AddDropdown("Modo", function(choice) print(choice) end)
        dropdown:Add("Opción 1")
]]

----------------------------------------------------------------------
-- Configuración
----------------------------------------------------------------------
local config = {
    main_color = Color3.fromRGB(41, 74, 122),
    min_size   = Vector2.new(400, 300),
    toggle_key = Enum.KeyCode.RightShift, -- muestra/oculta toda la UI
    can_resize = true,
}

-- Elimina una instancia anterior de la UI si existe
do
    local old = game:GetService("CoreGui"):FindFirstChild("imgui")
    if old then
        old:Destroy()
    end
end

----------------------------------------------------------------------
-- Helpers para construir los prefabs
----------------------------------------------------------------------
local WHITE = Color3.new(1, 1, 1)

-- Assets de imágenes redondeadas (9-slice)
local ROUND_12 = "rbxassetid://2851926732"
local ROUND_4  = "rbxassetid://2851929490"
local ROUND_8  = "rbxassetid://2851928141"
local CIRCLE   = "rbxassetid://266543268"

local function thumbnail(assetId)
    return "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=" .. assetId
end

-- Crea una instancia, aplica propiedades y la parenta al final.
-- Los GuiObject empiezan con fondo blanco (como en el original).
local function create(className, props, parent)
    local instance = Instance.new(className)
    if instance:IsA("GuiObject") then
        instance.BackgroundColor3 = WHITE
    end
    for property, value in pairs(props) do
        instance[property] = value
    end
    instance.Parent = parent
    return instance
end

-- Agrega las propiedades de una imagen 9-slice con esquinas redondeadas
local function sliced(image, radius, props)
    props.Image = image
    props.ScaleType = Enum.ScaleType.Slice
    props.SliceCenter = Rect.new(radius, radius, radius, radius)
    return props
end

local FONT = Enum.Font.FredokaOne
local TEXT_GRAY = Color3.fromRGB(200, 200, 200)
local BLUE = Color3.fromRGB(41, 74, 122)

----------------------------------------------------------------------
-- Prefabs (plantillas que luego se clonan; viven en un Frame oculto)
----------------------------------------------------------------------
local screenGui = create("ScreenGui", { Name = "imgui" }, game:GetService("CoreGui") or gethui())

local prefabs = create("Frame", {
    Name = "Prefabs",
    Size = UDim2.new(0, 100, 0, 100),
    Visible = false,
}, screenGui)

-- Label
create("TextLabel", {
    Name = "Label",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 200, 0, 20),
    Font = FONT,
    Text = "Hello, world 123",
    TextColor3 = WHITE,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
}, prefabs)

-- Window
local windowPrefab = create("ImageLabel", sliced(ROUND_12, 12, {
    Name = "Window",
    Active = true,
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Position = UDim2.new(0, 20, 0, 20),
    Selectable = true,
    Size = UDim2.new(0, 200, 0, 200),
    ImageColor3 = Color3.fromRGB(21, 22, 23),
}), prefabs)

create("Frame", { -- esquina para redimensionar
    Name = "Resizer",
    Active = true,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -20, 1, -20),
    Size = UDim2.new(0, 20, 0, 20),
}, windowPrefab)

local barPrefab = create("Frame", { -- barra de título
    Name = "Bar",
    BackgroundColor3 = BLUE,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 5),
    Size = UDim2.new(1, 0, 0, 15),
}, windowPrefab)

create("ImageButton", { -- botón de colapsar
    Name = "Toggle",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 5, 0, -2),
    Size = UDim2.new(0, 20, 0, 20),
    ZIndex = 2,
    Image = thumbnail(98003173280742),
}, barPrefab)

create("ImageLabel", sliced(ROUND_12, 12, {
    Name = "Base",
    BackgroundColor3 = BLUE,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0.8, 0),
    Size = UDim2.new(1, 0, 0, 10),
    ImageColor3 = BLUE,
}), barPrefab)

create("ImageLabel", sliced(ROUND_12, 12, {
    Name = "Top",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, -5),
    Size = UDim2.new(1, 0, 0, 10),
    ImageColor3 = BLUE,
}), barPrefab)

create("Frame", { -- contenedor de las páginas de cada pestaña
    Name = "Tabs",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 15, 0, 60),
    Size = UDim2.new(1, -30, 1, -60),
    ClipsDescendants = true,
}, windowPrefab)

create("TextLabel", { -- título de la ventana
    Name = "Title",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 30, 0, 3),
    Size = UDim2.new(0, 200, 0, 20),
    Font = FONT,
    Text = "Gamer Time",
    TextColor3 = WHITE,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
}, windowPrefab)

local tabSelectionPrefab = create("ImageLabel", sliced(ROUND_4, 4, { -- barra con los botones de pestañas
    Name = "TabSelection",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 15, 0, 30),
    Size = UDim2.new(1, -30, 0, 25),
    Visible = false,
    ImageColor3 = Color3.fromRGB(37, 38, 40),
}), windowPrefab)

local tabScrollingPrefab = create("ScrollingFrame", {
    Name = "TabScrolling",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0),
    CanvasSize = UDim2.new(0, 0, 1, 0),
    ScrollBarThickness = 0,
    ScrollingDirection = Enum.ScrollingDirection.X,
}, tabSelectionPrefab)

local tabButtonsPrefab = create("Frame", {
    Name = "TabButtons",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 0, 1, 0),
    ClipsDescendants = true,
}, tabScrollingPrefab)

create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 2),
}, tabButtonsPrefab)

create("Frame", { -- línea inferior de la barra de pestañas (se destruye al crear la ventana)
    BackgroundColor3 = Color3.fromRGB(32, 58, 95),
    BorderColor3 = Color3.fromRGB(27, 42, 53),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 2),
}, tabSelectionPrefab)

-- Tab (página de contenido)
local tabPrefab = create("Frame", {
    Name = "Tab",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Visible = false,
}, prefabs)

create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 5),
}, tabPrefab)

-- TextBox
local textBoxPrefab = create("TextBox", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 20),
    ZIndex = 2,
    Font = FONT,
    PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
    PlaceholderText = "Input Text",
    Text = "",
    TextColor3 = TEXT_GRAY,
    TextSize = 14,
}, prefabs)

create("ImageLabel", sliced(ROUND_4, 4, {
    Name = "TextBox_Roundify_4px",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ImageColor3 = Color3.fromRGB(52, 53, 56),
}), textBoxPrefab)

-- Slider
local sliderPrefab = create("ImageLabel", sliced(ROUND_4, 4, {
    Name = "Slider",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 20),
    ImageColor3 = Color3.fromRGB(37, 38, 40),
}), prefabs)

create("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 0.5, -10),
    Size = UDim2.new(0, 0, 0, 20),
    ZIndex = 2,
    Font = FONT,
    Text = "Slider",
    TextColor3 = TEXT_GRAY,
    TextSize = 14,
}, sliderPrefab)

create("ImageLabel", sliced(ROUND_4, 4, {
    Name = "Indicator",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 0, 0, 20),
    ImageColor3 = Color3.fromRGB(65, 67, 71),
}), sliderPrefab)

create("TextLabel", {
    Name = "Value",
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -55, 0.5, -10),
    Size = UDim2.new(0, 50, 0, 20),
    Font = FONT,
    Text = "0%",
    TextColor3 = TEXT_GRAY,
    TextSize = 14,
}, sliderPrefab)

create("TextLabel", { -- "]"
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -20, -0.75, 0),
    Size = UDim2.new(0, 26, 0, 50),
    Font = FONT,
    Text = "]",
    TextColor3 = Color3.fromRGB(160, 160, 160),
    TextSize = 14,
}, sliderPrefab)

create("TextLabel", { -- "["
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -65, -0.75, 0),
    Size = UDim2.new(0, 26, 0, 50),
    Font = FONT,
    Text = "[",
    TextColor3 = Color3.fromRGB(160, 160, 160),
    TextSize = 14,
}, sliderPrefab)

-- Circle (efecto ripple de los botones)
create("ImageLabel", {
    Name = "Circle",
    BackgroundTransparency = 1,
    Image = CIRCLE,
    ImageTransparency = 0.5,
}, prefabs)

-- Layout del propio contenedor de prefabs (se usa en formatWindows)
create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 20),
}, prefabs)

-- Dropdown
local dropdownPrefab = create("TextButton", {
    Name = "Dropdown",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 200, 0, 20),
    ZIndex = 2,
    Font = FONT,
    Text = "      Dropdown",
    TextColor3 = TEXT_GRAY,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
}, prefabs)

create("ImageLabel", { -- flecha
    Name = "Indicator",
    BackgroundTransparency = 1,
    Position = UDim2.new(0.9, -10, 0.1, 0),
    Rotation = -90,
    Size = UDim2.new(0, 15, 0, 15),
    ZIndex = 2,
    Image = thumbnail(4744658743),
}, dropdownPrefab)

local dropdownBoxPrefab = create("ImageLabel", sliced(ROUND_4, 4, { -- caja con la lista
    Name = "Box",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 25),
    Size = UDim2.new(1, 0, 0, 150),
    ZIndex = 3,
    ImageColor3 = Color3.fromRGB(33, 34, 36),
}), dropdownPrefab)

local dropdownObjectsPrefab = create("ScrollingFrame", {
    Name = "Objects",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = 3,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0),
}, dropdownBoxPrefab)

create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, dropdownObjectsPrefab)

create("ImageLabel", sliced(ROUND_4, 4, { -- fondo del botón (debe ser el 3er hijo)
    Name = "TextButton_Roundify_4px",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ImageColor3 = Color3.fromRGB(52, 53, 56),
}), dropdownPrefab)

-- TabButton
local tabButtonPrefab = create("TextButton", {
    Name = "TabButton",
    BackgroundColor3 = BLUE,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 71, 0, 20),
    ZIndex = 2,
    Font = FONT,
    Text = "Test tab",
    TextColor3 = TEXT_GRAY,
    TextSize = 14,
}, prefabs)

create("ImageLabel", sliced(ROUND_4, 4, {
    Name = "TextButton_Roundify_4px",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ImageColor3 = Color3.fromRGB(52, 53, 56),
}), tabButtonPrefab)

-- Folder
local folderPrefab = create("ImageLabel", sliced(ROUND_4, 4, {
    Name = "Folder",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 20),
    ImageColor3 = Color3.fromRGB(21, 22, 23),
}), prefabs)

local folderButtonPrefab = create("TextButton", {
    Name = "Button",
    BackgroundColor3 = BLUE,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 20),
    ZIndex = 2,
    Font = FONT,
    Text = "      Folder",
    TextColor3 = WHITE,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
}, folderPrefab)

create("ImageLabel", sliced(ROUND_4, 4, {
    Name = "TextButton_Roundify_4px",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ImageColor3 = BLUE,
}), folderButtonPrefab)

create("ImageLabel", { -- flecha
    Name = "Toggle",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 5, 0, 0),
    Size = UDim2.new(0, 20, 0, 20),
    Image = thumbnail(4731371541),
}, folderButtonPrefab)

local folderObjectsPrefab = create("Frame", {
    Name = "Objects",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 25),
    Size = UDim2.new(1, -10, 1, -25),
    Visible = false,
}, folderPrefab)

create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 5),
}, folderObjectsPrefab)

-- HorizontalAlignment (fila de elementos)
local horizontalPrefab = create("Frame", {
    Name = "HorizontalAlignment",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 20),
}, prefabs)

create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 5),
}, horizontalPrefab)

-- Console / editor de código (NO lo usa la librería; se conserva del original)
local consolePrefab = create("ImageLabel", sliced(ROUND_8, 8, {
    Name = "Console",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 200),
    ImageColor3 = Color3.fromRGB(33, 34, 36),
}), prefabs)

local consoleScroll = create("ScrollingFrame", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 1),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 4,
}, consolePrefab)

local consoleSource = create("TextBox", {
    Name = "Source",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 40, 0, 0),
    Size = UDim2.new(1, -40, 0, 10000),
    ZIndex = 3,
    ClearTextOnFocus = false,
    Font = Enum.Font.Code,
    MultiLine = true,
    PlaceholderColor3 = Color3.fromRGB(204, 204, 204),
    Text = "",
    TextColor3 = WHITE,
    TextSize = 15,
    TextStrokeColor3 = WHITE,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, consoleScroll)

local function syntaxLayer(name, color, zIndex)
    create("TextLabel", {
        Name = name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = zIndex or 5,
        Font = Enum.Font.Code,
        Text = "",
        TextColor3 = color,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, consoleSource)
end

syntaxLayer("Comments",        Color3.fromRGB(59, 200, 59))
syntaxLayer("Globals",         Color3.fromRGB(132, 214, 247))
syntaxLayer("Keywords",        Color3.fromRGB(248, 109, 124))
syntaxLayer("RemoteHighlight", Color3.fromRGB(0, 145, 255))
syntaxLayer("Strings",         Color3.fromRGB(173, 241, 149))
syntaxLayer("Tokens",          WHITE)
syntaxLayer("Numbers",         Color3.fromRGB(255, 198, 0), 4)
syntaxLayer("Info",            Color3.fromRGB(0, 162, 255))

create("TextLabel", {
    Name = "Lines",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 40, 0, 10000),
    ZIndex = 4,
    Font = Enum.Font.Code,
    Text = "1\n",
    TextColor3 = WHITE,
    TextSize = 15,
    TextWrapped = true,
    TextYAlignment = Enum.TextYAlignment.Top,
}, consoleScroll)

-- ColorPicker
local colorPickerPrefab = create("ImageLabel", sliced(ROUND_4, 4, {
    Name = "ColorPicker",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 180, 0, 110),
    ImageColor3 = Color3.fromRGB(52, 53, 56),
}), prefabs)

local palettePrefab = create("ImageLabel", sliced("rbxassetid://698052001", 4, {
    Name = "Palette",
    BackgroundTransparency = 1,
    Position = UDim2.new(0.05, 0, 0.05, 0),
    Size = UDim2.new(0, 100, 0, 100),
}), colorPickerPrefab)

create("ImageLabel", sliced(ROUND_12, 12, { -- puntero de la paleta
    Name = "Indicator",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 5, 0, 5),
    ZIndex = 2,
    ImageColor3 = Color3.new(0, 0, 0),
}), palettePrefab)

create("ImageLabel", sliced(ROUND_4, 4, { -- muestra del color elegido
    Name = "Sample",
    BackgroundTransparency = 1,
    Position = UDim2.new(0.8, 0, 0.05, 0),
    Size = UDim2.new(0, 25, 0, 25),
}), colorPickerPrefab)

local brightnessPrefab = create("ImageLabel", { -- el prefab se llama "Saturation" pero controla el brillo (V)
    Name = "Saturation",
    Position = UDim2.new(0.65, 0, 0.05, 0),
    Size = UDim2.new(0, 15, 0, 100),
    Image = "rbxassetid://3641079629",
}, colorPickerPrefab)

create("Frame", {
    Name = "Indicator",
    BorderSizePixel = 0,
    Size = UDim2.new(0, 20, 0, 2),
    ZIndex = 2,
}, brightnessPrefab)

-- Switch
local switchPrefab = create("TextButton", {
    Name = "Switch",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 20, 0, 20),
    ZIndex = 2,
    Font = Enum.Font.SourceSans,
    Text = "",
    TextColor3 = WHITE,
    TextSize = 14,
}, prefabs)

create("ImageLabel", sliced(ROUND_4, 4, {
    Name = "TextButton_Roundify_4px",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ImageColor3 = BLUE,
    ImageTransparency = 0.5,
}), switchPrefab)

create("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Position = UDim2.new(1.2, 0, 0, 0),
    Size = UDim2.new(0, 20, 0, 20),
    Font = FONT,
    Text = "Switch",
    TextColor3 = TEXT_GRAY,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
}, switchPrefab)

-- Button
local buttonPrefab = create("TextButton", {
    Name = "Button",
    BackgroundColor3 = BLUE,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 91, 0, 20),
    ZIndex = 2,
    Font = FONT,
    TextColor3 = WHITE,
    TextSize = 14,
}, prefabs)

create("ImageLabel", sliced(ROUND_4, 4, {
    Name = "TextButton_Roundify_4px",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ImageColor3 = BLUE,
}), buttonPrefab)

-- DropdownButton (cada opción del dropdown)
create("TextButton", {
    Name = "DropdownButton",
    BackgroundColor3 = Color3.fromRGB(33, 34, 36),
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 20),
    ZIndex = 3,
    Font = FONT,
    Text = "      Button",
    TextColor3 = TEXT_GRAY,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
}, prefabs)

-- Keybind
local keybindPrefab = create("ImageLabel", sliced(ROUND_4, 4, {
    Name = "Keybind",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 200, 0, 20),
    ImageColor3 = Color3.fromRGB(52, 53, 56),
}), prefabs)

create("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 0, 1, 0),
    Font = FONT,
    Text = "Keybind",
    TextColor3 = TEXT_GRAY,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
}, keybindPrefab)

local keybindInputPrefab = create("TextButton", {
    Name = "Input",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -85, 0, 2),
    Size = UDim2.new(0, 80, 1, -4),
    ZIndex = 2,
    Font = FONT,
    Text = "RShift",
    TextColor3 = TEXT_GRAY,
    TextSize = 12,
    TextWrapped = true,
}, keybindPrefab)

create("ImageLabel", sliced(ROUND_4, 4, {
    Name = "Input_Roundify_4px",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ImageColor3 = Color3.fromRGB(74, 75, 80),
}), keybindInputPrefab)

-- Contenedor donde viven las ventanas reales
local windowsContainer = create("Frame", {
    Name = "Windows",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 0, 20),
    Size = UDim2.new(1, 20, 1, -20),
}, screenGui)

----------------------------------------------------------------------
-- Lógica de la librería
----------------------------------------------------------------------
script.Parent = screenGui

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local state = { binding = false } -- true mientras se asigna una tecla en un Keybind

-- Conexiones globales para poder limpiarlas al destruir la UI
local connections = {}

local function track(connection)
    table.insert(connections, connection)
    return connection
end

local function disconnectAll()
    for _, connection in ipairs(connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    connections = {}
end

-- Mostrar/ocultar la UI con la tecla configurada
track(UserInputService.InputBegan:Connect(function(input, processed)
    local toggleKey = typeof(config.toggle_key) == "EnumItem" and config.toggle_key or Enum.KeyCode.RightShift
    if input.KeyCode == toggleKey then
        if script.Parent and not state.binding then
            script.Parent.Enabled = not script.Parent.Enabled
        end
    end
end))

-- Tween rápido. Con duración 0 aplica las propiedades directamente.
local function tween(instance, properties, duration)
    duration = duration or 0.1
    if duration == 0 then
        for property, value in pairs(properties) do
            instance[property] = value
        end
        return
    end
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(instance, info, properties)
    t:Play()
    return t
end

-- Aplica uno, dos o tres colores (degradado) a un objeto
local function setColor(instance, colors, rotation)
    local existing = instance:FindFirstChild("UIGradient")
    if existing then
        existing:Destroy()
    end

    if typeof(colors) == "Color3" then
        colors = { colors }
    end
    if not colors or #colors == 0 then
        return
    end

    local isImage = instance:IsA("ImageLabel") or instance:IsA("ImageButton")

    if #colors == 1 then
        if isImage then
            instance.ImageColor3 = colors[1]
        else
            instance.BackgroundColor3 = colors[1]
        end
        return
    end

    local gradient = Instance.new("UIGradient")
    gradient.Parent = instance
    gradient.Rotation = rotation or 0

    local keypoints
    if #colors == 2 then
        keypoints = {
            ColorSequenceKeypoint.new(0, colors[1]),
            ColorSequenceKeypoint.new(1, colors[2]),
        }
    else
        keypoints = {
            ColorSequenceKeypoint.new(0, colors[1]),
            ColorSequenceKeypoint.new(0.5, colors[2]),
            ColorSequenceKeypoint.new(1, colors[3]),
        }
    end
    gradient.Color = ColorSequence.new(keypoints)

    if isImage then
        instance.ImageColor3 = Color3.new(1, 1, 1)
    else
        instance.BackgroundColor3 = Color3.new(1, 1, 1)
    end
end

-- RGB (0-255) -> HSV (0-1)
local function rgbToHsv(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v = 0, 0, max
    local delta = max - min

    s = (max == 0) and 0 or delta / max

    if max == min then
        h = 0
    else
        if max == r then
            h = (g - b) / delta + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / delta + 2
        elseif max == b then
            h = (r - g) / delta + 4
        end
        h = h / 6
    end

    return h, s, v
end

-- Devuelve el valor de una propiedad o false si no existe
local function hasProperty(instance, property)
    local ok, value = pcall(function()
        return instance[tostring(property)]
    end)
    return ok and value
end

-- Ancho de un botón/label según su texto
local function textWidth(textObject)
    return textObject.TextBounds.X + 15
end

-- Posición del mouse (compensando la barra superior de Roblox)
local function getMousePosition()
    local location = UserInputService:GetMouseLocation()
    return Vector2.new(location.X + 1, location.Y - 35)
end

-- Efecto "ripple" al hacer click en un botón
local function ripple(button, x, y)
    task.spawn(function()
        button.ClipsDescendants = true

        local circle = prefabs:FindFirstChild("Circle"):Clone()
        circle.Parent = button
        circle.ZIndex = 1000

        local offsetX = x - circle.AbsolutePosition.X
        local offsetY = y - circle.AbsolutePosition.Y
        circle.Position = UDim2.new(0, offsetX, 0, offsetY)

        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
        circle:TweenSizeAndPosition(
            UDim2.new(0, size, 0, size),
            UDim2.new(0.5, -size / 2, 0.5, -size / 2),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.5,
            false
        )
        tween(circle, { ImageTransparency = 1 }, 0.5)

        task.wait(0.5)
        circle:Destroy()
    end)
end

----------------------------------------------------------------------
-- API pública
----------------------------------------------------------------------
local library = {}
local windowCount = 0 -- se usa para subir el ZIndex de cada ventana nueva

-- Convierte las posiciones actuales de las ventanas en posiciones fijas
-- (útil para "ordenar" las ventanas con un UIListLayout temporal)
local function freezeWindowPositions()
    local layout = prefabs:FindFirstChild("UIListLayout"):Clone()
    layout.Parent = windowsContainer

    local positions = {}
    for _, child in ipairs(windowsContainer:GetChildren()) do
        if not child:IsA("UIListLayout") then
            positions[child] = child.AbsolutePosition
        end
    end

    layout:Destroy()

    for child, position in pairs(positions) do
        child.Position = UDim2.new(0, position.X, 0, position.Y)
    end
end

function library:FormatWindows()
    freezeWindowPositions()
end

function library:AddWindow(title, options)
    windowCount = windowCount + 1

    -- Un dropdown abierto bloquea sliders, color pickers y cambio de pestaña
    local isDropdownOpen = false

    -- Opciones por defecto
    title = tostring(title or "New Window")
    options = typeof(options) == "table" and options or config

    options.tween_time = options.tween_time or 0.1

    options.title_bar = options.title_bar or { Color3.fromRGB(41, 74, 122) }
    if typeof(options.title_bar) == "Color3" then
        options.title_bar = { options.title_bar }
    end
    options.title_bar_transparency = options.title_bar_transparency or 0

    options.background = options.background or { Color3.new(0.08, 0.09, 0.1) }
    if typeof(options.background) == "Color3" then
        options.background = { options.background }
    end
    options.background_transparency = options.background_transparency or 0.1

    if not options.main_color then
        options.main_color = options.title_bar[1]
    end

    local tweenTime = options.tween_time

    -- Clon de la ventana
    local window = prefabs:FindFirstChild("Window"):Clone()
    window.Parent = windowsContainer
    window:FindFirstChild("Title").Text = title
    window.Size = UDim2.new(0, options.min_size.X, 0, options.min_size.Y)
    window.ZIndex = window.ZIndex + windowCount * 10

    ------------------------------------------------------------------
    -- Barra de título y barra de pestañas
    ------------------------------------------------------------------
    do
        local bar = window:FindFirstChild("Bar")
        local barTitle = bar:FindFirstChild("Title") -- nunca existe (el título está en la ventana), el bloque de abajo no se ejecuta
        local toggle = bar:FindFirstChild("Toggle")
        local base = bar:FindFirstChild("Base")
        local top = bar:FindFirstChild("Top")
        local tabSelection = window:FindFirstChild("TabSelection")
        local tabSelectionLine = tabSelection:FindFirstChild("Frame")

        local barHeight = 24
        local barPadding = (barHeight - 18) / 2

        bar.Size = UDim2.new(1, 0, 0, barHeight)
        bar.Position = UDim2.new(0, 0, 0, 0)

        if base then base:Destroy() end
        if top then top:Destroy() end

        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 5)
        barCorner.Parent = bar

        if toggle then
            toggle.Position = UDim2.new(0, 5, 0, barPadding)
        end

        if barTitle then
            local leftPadding = 25
            local rightPadding = 5
            barTitle.Position = UDim2.new(0, leftPadding, 0, barPadding)
            barTitle.Size = UDim2.new(1, -(leftPadding + rightPadding), 1, -barPadding * 2)
            barTitle.TextXAlignment = Enum.TextXAlignment.Center
        end

        bar.BackgroundTransparency = options.title_bar_transparency
        setColor(bar, options.title_bar, 0)

        if tabSelection then
            tabSelection.Size = UDim2.new(1, -30, 0, 22)
            tabSelection.Position = UDim2.new(0, 15, 0, 28)

            local selectionCorner = Instance.new("UICorner")
            selectionCorner.CornerRadius = UDim.new(0, 6)
            selectionCorner.Parent = tabSelection

            tabSelection.ImageTransparency = 0.4
            setColor(tabSelection, options.title_bar, 45)

            local scrolling = tabSelection:FindFirstChild("TabScrolling")
            if scrolling then
                local buttons = scrolling:FindFirstChild("TabButtons")
                if buttons then
                    local layout = buttons:FindFirstChild("UIListLayout")
                    if layout then
                        layout.VerticalAlignment = Enum.VerticalAlignment.Center
                        layout.Padding = UDim.new(0, 12)
                    end
                end
            end

            if tabSelectionLine then
                tabSelectionLine:Destroy()
            end
        end

        window.ImageTransparency = options.background_transparency
        setColor(window, options.background, 45)

        -- Primer handler del botón de colapsar
        -- (nota: el original conecta DOS handlers al mismo botón, este y el de más abajo)
        local tabsContainer = window:FindFirstChild("Tabs")
        toggle.MouseButton1Click:Connect(function()
            local visible = tabsContainer.Visible
            if visible then
                tabsContainer.Visible = false
                tween(window, { Size = UDim2.new(0, window.AbsoluteSize.X, 0, barHeight) }, tweenTime)
            else
                tabsContainer.Visible = true
                window.Size = UDim2.new(0, window.AbsoluteSize.X, 0, options.min_size.Y)
            end
        end)
    end

    ------------------------------------------------------------------
    -- Redimensionar la ventana
    ------------------------------------------------------------------
    local resizer = window:WaitForChild("Resizer")
    local windowApi = {}

    window.Draggable = true

    do
        local savedIcon = mouse.Icon
        local hoveringResizer = false

        resizer.MouseEnter:Connect(function()
            window.Draggable = false
            if options.can_resize then
                savedIcon = mouse.Icon
            end
            hoveringResizer = true
        end)

        resizer.MouseLeave:Connect(function()
            hoveringResizer = false
            if options.can_resize then
                mouse.Icon = savedIcon
            end
            window.Draggable = true
        end)

        local mouseDown = false
        local resizeConnection

        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                mouseDown = true
                if hoveringResizer and resizer.Active and options.can_resize then
                    resizeConnection = RunService.Heartbeat:Connect(function()
                        if not mouseDown or not resizer.Active then
                            if resizeConnection then
                                resizeConnection:Disconnect()
                                resizeConnection = nil
                            end
                            return
                        end

                        local mousePos = getMousePosition()
                        local width = mousePos.X - window.AbsolutePosition.X
                        local height = mousePos.Y - window.AbsolutePosition.Y
                        width = math.max(options.min_size.X, width)
                        height = math.max(options.min_size.Y, height)
                        window.Size = UDim2.new(0, width, 0, height)
                    end)
                end
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                mouseDown = false
                if resizeConnection then
                    resizeConnection:Disconnect()
                    resizeConnection = nil
                end
            end
        end)
    end

    ------------------------------------------------------------------
    -- Colapsar / expandir la ventana (segundo handler del botón Toggle)
    ------------------------------------------------------------------
    do
        local collapseButton = window:FindFirstChild("Bar"):FindFirstChild("Toggle")
        local expanded = true
        local canAnimate = true
        local savedTabVisibility = {}
        local savedHeight = window.AbsoluteSize.Y

        collapseButton.MouseButton1Click:Connect(function()
            if not canAnimate then return end
            canAnimate = false

            if expanded then
                -- Colapsar: ocultar páginas y encoger
                savedTabVisibility = {}
                for _, child in ipairs(window:FindFirstChild("Tabs"):GetChildren()) do
                    savedTabVisibility[child] = child.Visible
                    child.Visible = false
                end

                resizer.Active = false
                savedHeight = window.AbsoluteSize.Y

                tween(collapseButton, { Rotation = 0 }, tweenTime)
                tween(window, { Size = UDim2.new(0, window.AbsoluteSize.X, 0, 26) }, tweenTime)

                local base = collapseButton.Parent:FindFirstChild("Base")
                if base then
                    base.Transparency = 1
                end
            else
                -- Expandir: restaurar páginas y tamaño
                for child, wasVisible in pairs(savedTabVisibility) do
                    child.Visible = wasVisible
                end

                resizer.Active = true

                tween(collapseButton, { Rotation = 0 }, tweenTime)
                tween(window, { Size = UDim2.new(0, window.AbsoluteSize.X, 0, savedHeight) }, tweenTime)

                local base = collapseButton.Parent:FindFirstChild("Base")
                if base then
                    base.Transparency = options.title_bar_transparency
                end
            end

            expanded = not expanded

            task.delay(tweenTime, function()
                canAnimate = true
            end)
        end)
    end

    ------------------------------------------------------------------
    -- Pestañas
    ------------------------------------------------------------------
    do
        local tabsContainer = window:FindFirstChild("Tabs")
        local tabSelection = window:FindFirstChild("TabSelection")
        local tabScrolling = tabSelection:FindFirstChild("TabScrolling")
        local tabButtons = tabScrolling:FindFirstChild("TabButtons")

        local selectedTabButton = nil
        local particleConnection = nil

        -- Ajusta el ancho total de la barra de pestañas según sus botones
        local function resizeTabButtons()
            local totalWidth = 0
            local padding = tabButtons:FindFirstChildOfClass("UIListLayout").Padding.Offset or 0

            for _, child in ipairs(tabButtons:GetChildren()) do
                if child:IsA("TextButton") then
                    totalWidth = totalWidth + child.AbsoluteSize.X + padding
                end
            end

            tabButtons.Size = UDim2.new(0, totalWidth, 1, 0)
            if tabScrolling then
                tabScrolling.CanvasSize = UDim2.new(0, totalWidth, 0, 0)
            end
        end

        function windowApi:AddTab(tabName)
            local tabApi = {}
            tabName = tostring(tabName or "New Tab")

            tabSelection.Visible = true

            -- Botón de la pestaña
            local tabButton = prefabs:FindFirstChild("TabButton"):Clone()
            tabButton.Parent = tabButtons
            tabButton.Text = tabName
            tabButton.Size = UDim2.new(0, textWidth(tabButton) + 20, 0, 18)
            tabButton.ZIndex = tabButton.ZIndex + windowCount * 10
            tabButton.BackgroundTransparency = 1

            local tabButtonBackground = tabButton:GetChildren()[1]
            tabButtonBackground.ZIndex = tabButton.ZIndex + windowCount * 10
            tabButtonBackground.ImageTransparency = 1

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 4)
            buttonCorner.Parent = tabButton

            tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            tabButton.TextSize = 13
            tabButton.Font = Enum.Font.FredokaOne

            local buttonStroke = Instance.new("UIStroke")
            buttonStroke.Color = Color3.new(0, 0, 0)
            buttonStroke.Thickness = 1.2
            buttonStroke.Transparency = 0.7
            buttonStroke.Parent = tabButton

            -- Contorno que se muestra en la pestaña seleccionada
            local outline = Instance.new("Frame")
            outline.Name = "TabOutline"
            outline.Size = UDim2.new(1, 0, 1, 0)
            outline.BackgroundTransparency = 1
            outline.BorderSizePixel = 2
            outline.BorderColor3 = options.main_color
            outline.ZIndex = tabButton.ZIndex + 10
            outline.Visible = false

            local outlineCorner = Instance.new("UICorner")
            outlineCorner.CornerRadius = UDim.new(0, 4)
            outlineCorner.Parent = outline
            outline.Parent = tabButton

            -- Página de contenido de la pestaña
            local tabPage = prefabs:FindFirstChild("Tab"):Clone()
            tabPage.Parent = tabsContainer
            tabPage.ZIndex = tabPage.ZIndex + windowCount * 10
            tabPage.Visible = false
            tabPage.ClipsDescendants = false
            tabPage.Size = UDim2.new(1, 0, 1, 0)
            tabPage.BackgroundTransparency = 1

            local scroller = Instance.new("ScrollingFrame")
            scroller.Name = "TabScroller"
            scroller.Parent = tabPage
            scroller.Size = UDim2.new(1, 0, 1, 0)
            scroller.BackgroundTransparency = 1
            scroller.BorderSizePixel = 0
            scroller.ScrollBarThickness = 4
            scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
            scroller.ZIndex = tabPage.ZIndex
            scroller.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
            scroller.ScrollBarImageTransparency = 0.4

            -- El UIListLayout pasa de la página al scroller
            local listLayout = tabPage:FindFirstChildOfClass("UIListLayout")
            if listLayout then
                listLayout.Parent = scroller
            end

            local function updateCanvasSize()
                local contentHeight = listLayout.AbsoluteContentSize.Y
                scroller.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 10)
            end

            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
            updateCanvasSize()

            task.defer(resizeTabButtons)

            -- Partículas alrededor de la pestaña activa
            local function spawnParticles(button)
                if button ~= selectedTabButton then return end

                local size = button.AbsoluteSize

                for _ = 1, 3 do
                    task.spawn(function()
                        local particle = Instance.new("Frame")
                        particle.Name = "SimpleParticle"
                        particle.Size = UDim2.new(0, 1.5, 0, 1.5)
                        particle.AnchorPoint = Vector2.new(0.5, 0.5)
                        particle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        particle.BorderSizePixel = 0
                        particle.ZIndex = button.ZIndex + 15

                        local particleCorner = Instance.new("UICorner")
                        particleCorner.CornerRadius = UDim.new(1, 0)
                        particleCorner.Parent = particle

                        -- Nace en un borde aleatorio del botón
                        local side = math.random(1, 4)
                        local startX, startY = 0, 0
                        if side == 1 then
                            startX = math.random(5, size.X - 5)
                            startY = 1
                        elseif side == 2 then
                            startX = size.X - 1
                            startY = math.random(5, size.Y - 5)
                        elseif side == 3 then
                            startX = math.random(5, size.X - 5)
                            startY = size.Y - 1
                        else
                            startX = 1
                            startY = math.random(5, size.Y - 5)
                        end

                        particle.Position = UDim2.new(0, startX, 0, startY)
                        particle.Parent = button

                        -- Se mueve 6px hacia afuera desde el centro
                        local centerX, centerY = size.X / 2, size.Y / 2
                        local dirX, dirY = startX - centerX, startY - centerY
                        local length = math.sqrt(dirX * dirX + dirY * dirY)
                        dirX, dirY = dirX / length, dirY / length

                        local targetX = startX + dirX * 6
                        local targetY = startY + dirY * 6

                        local info = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                        local particleTween = TweenService:Create(particle, info, {
                            Position = UDim2.new(0, targetX, 0, targetY),
                            BackgroundTransparency = 1,
                        })
                        particleTween:Play()

                        task.wait(0.5)
                        if particle and particle.Parent then
                            particle:Destroy()
                        end
                    end)
                end
            end

            local function startParticleLoop()
                if particleConnection then
                    particleConnection:Disconnect()
                end
                particleConnection = RunService.Heartbeat:Connect(function()
                    if selectedTabButton and selectedTabButton.Parent then
                        spawnParticles(selectedTabButton)
                        task.wait(0.2)
                    end
                end)
            end

            -- Seleccionar esta pestaña
            local function selectTab()
                if isDropdownOpen then return end

                if selectedTabButton and selectedTabButton ~= tabButton then
                    local previousOutline = selectedTabButton:FindFirstChild("TabOutline")
                    if previousOutline then
                        previousOutline.Visible = false
                    end
                    selectedTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                end

                for _, child in ipairs(tabsContainer:GetChildren()) do
                    if child:IsA("Frame") then
                        child.Visible = false
                    end
                end

                selectedTabButton = tabButton

                local currentOutline = tabButton:FindFirstChild("TabOutline")
                if currentOutline then
                    currentOutline.Visible = true
                    currentOutline.BorderColor3 = options.main_color
                end

                tabButton.TextColor3 = Color3.new(1, 1, 1)

                startParticleLoop()
                tabPage.Visible = true
            end

            tabButton.MouseButton1Click:Connect(selectTab)

            tabButton.MouseEnter:Connect(function()
                if tabButton ~= selectedTabButton then
                    tabButton.TextColor3 = Color3.fromRGB(230, 230, 230)
                end
            end)

            tabButton.MouseLeave:Connect(function()
                if tabButton ~= selectedTabButton then
                    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end)

            function tabApi:Show()
                selectTab()
            end

            tabButton.AncestryChanged:Connect(function()
                if not tabButton.Parent then
                    if selectedTabButton == tabButton then
                        selectedTabButton = nil
                        if particleConnection then
                            particleConnection:Disconnect()
                            particleConnection = nil
                        end
                    end
                end
            end)

            -- La primera pestaña se selecciona sola (hijos: UIListLayout + 1 botón)
            if #tabButtons:GetChildren() == 2 then
                selectTab()
            end

            --------------------------------------------------------------
            -- Elementos que se pueden agregar a una pestaña
            --------------------------------------------------------------

            function tabApi:AddLabel(text)
                text = tostring(text or "New Label")

                local label = prefabs:FindFirstChild("Label"):Clone()
                label.Parent = scroller
                label.Text = text
                label.Size = UDim2.new(0, textWidth(label), 0, 20)
                label.ZIndex = label.ZIndex + windowCount * 10

                return label
            end

            function tabApi:AddButton(text, callback)
                text = tostring(text or "New Button")
                callback = typeof(callback) == "function" and callback or function() end

                local button = prefabs:FindFirstChild("Button"):Clone()
                button.Parent = scroller
                button.Text = text
                button.Size = UDim2.new(0, textWidth(button), 0, 20)
                button.ZIndex = button.ZIndex + windowCount * 10

                local background = button:GetChildren()[1]
                background.ZIndex = background.ZIndex + windowCount * 10
                background.ImageTransparency = options.title_bar_transparency or 0
                setColor(background, options.title_bar, 0)

                button.TextColor3 = Color3.new(1, 1, 1)

                button.MouseButton1Click:Connect(function()
                    ripple(button, mouse.X, mouse.Y)
                    pcall(callback)
                end)

                return button
            end

            function tabApi:AddSwitch(text, callback)
                local switchApi = {}
                text = tostring(text or "New Switch")
                callback = typeof(callback) == "function" and callback or function() end

                local switch = prefabs:FindFirstChild("Switch"):Clone()
                switch.Parent = scroller

                local switchTitle = switch:FindFirstChild("Title")
                switchTitle.Text = text
                switchTitle.ZIndex = switchTitle.ZIndex + windowCount * 10
                switch.ZIndex = switch.ZIndex + windowCount * 10

                local background = switch:GetChildren()[1]
                background.ZIndex = background.ZIndex + windowCount * 10
                background.ImageTransparency = options.title_bar_transparency or 0
                setColor(background, options.title_bar, 0)

                local enabled = false

                switch.MouseButton1Click:Connect(function()
                    enabled = not enabled
                    switch.Text = enabled and utf8.char(10003) or "" -- ✓
                    pcall(callback, enabled)
                end)

                function switchApi:Set(value)
                    enabled = typeof(value) == "boolean" and value or false
                    switch.Text = enabled and utf8.char(10003) or ""
                    pcall(callback, enabled)
                end

                return switchApi, switch
            end

            function tabApi:AddTextBox(placeholder, callback, opts)
                placeholder = tostring(placeholder or "New TextBox")
                callback = typeof(callback) == "function" and callback or function() end
                opts = typeof(opts) == "table" and opts or { clear = false }
                opts.clear = opts.clear == true

                local textBox = prefabs:FindFirstChild("TextBox"):Clone()
                textBox.Size = UDim2.new(0.5, -5, 0, 20)
                textBox.Parent = scroller
                textBox.PlaceholderText = placeholder
                textBox.ZIndex = textBox.ZIndex + windowCount * 10

                local background = textBox:GetChildren()[1]
                background.ZIndex = background.ZIndex + windowCount * 10
                background.ImageTransparency = options.title_bar_transparency or 0
                setColor(background, options.title_bar, 0)

                textBox.TextColor3 = Color3.new(1, 1, 1)
                textBox.PlaceholderColor3 = Color3.fromRGB(200, 200, 200)

                textBox.FocusLost:Connect(function(enterPressed)
                    if enterPressed and #textBox.Text > 0 then
                        pcall(callback, textBox.Text)
                        if opts.clear then
                            textBox.Text = ""
                        end
                    end
                end)

                return textBox
            end

            function tabApi:AddSlider(name, callback, opts)
                local sliderApi = {}
                name = tostring(name or "New Slider")
                callback = typeof(callback) == "function" and callback or function() end
                opts = typeof(opts) == "table" and opts or {}
                opts.min = opts.min or 0
                opts.max = opts.max or 100
                opts.readonly = opts.readonly or false

                local slider = prefabs:FindFirstChild("Slider"):Clone()
                slider.Parent = scroller
                slider.ZIndex = slider.ZIndex + windowCount * 10

                local titleLabel = slider:FindFirstChild("Title")
                local indicator = slider:FindFirstChild("Indicator")
                local valueLabel = slider:FindFirstChild("Value")

                titleLabel.ZIndex = titleLabel.ZIndex + windowCount * 10
                indicator.ZIndex = indicator.ZIndex + windowCount * 10
                valueLabel.ZIndex = valueLabel.ZIndex + windowCount * 10

                titleLabel.Text = name

                local isHovering = false
                local dragConnection

                slider.MouseEnter:Connect(function()
                    isHovering = true
                    window.Draggable = false
                end)

                slider.MouseLeave:Connect(function()
                    isHovering = false
                    window.Draggable = true
                end)

                -- Convierte un porcentaje (0-100) en el valor real del slider
                local function percentToValue(percent)
                    local range = opts.max - opts.min
                    return math.floor(range / 100 * percent + opts.min)
                end

                local isMouseDown = false

                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isMouseDown = true

                        if isHovering and not opts.readonly then
                            dragConnection = RunService.Heartbeat:Connect(function()
                                if not isMouseDown or isDropdownOpen then
                                    if dragConnection then
                                        dragConnection:Disconnect()
                                        dragConnection = nil
                                    end
                                    return
                                end

                                local mousePos = getMousePosition()
                                local alpha = math.clamp((mousePos.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)

                                indicator.Size = UDim2.new(alpha, 0, 0, 20)

                                local percent = math.floor(alpha * 100)
                                local value = percentToValue(percent)
                                valueLabel.Text = tostring(value)
                                pcall(callback, value)
                            end)
                        end
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isMouseDown = false
                        if dragConnection then
                            dragConnection:Disconnect()
                            dragConnection = nil
                        end
                    end
                end)

                -- Nota: Set recibe un PORCENTAJE (0-100), no el valor final
                function sliderApi:Set(percent)
                    percent = tonumber(percent) or 0
                    local alpha = math.clamp(percent, 0, 100) / 100

                    indicator.Size = UDim2.new(alpha, 0, 0, 20)

                    local value = percentToValue(math.floor(alpha * 100))
                    valueLabel.Text = tostring(value)
                    pcall(callback, value)
                end

                sliderApi:Set(opts.min)

                return sliderApi, slider
            end

            function tabApi:AddKeybind(name, callback, opts)
                local keybindApi = {}
                name = tostring(name or "New Keybind")
                callback = typeof(callback) == "function" and callback or function() end
                opts = typeof(opts) == "table" and opts or {}
                opts.standard = opts.standard or Enum.KeyCode.RightShift

                local keybind = prefabs:FindFirstChild("Keybind"):Clone()
                local input = keybind:FindFirstChild("Input")
                local titleLabel = keybind:FindFirstChild("Title")

                keybind.ZIndex = keybind.ZIndex + windowCount * 10
                input.ZIndex = input.ZIndex + windowCount * 10
                input:GetChildren()[1].ZIndex = input:GetChildren()[1].ZIndex + windowCount * 10
                titleLabel.ZIndex = titleLabel.ZIndex + windowCount * 10

                keybind.Parent = scroller
                titleLabel.Text = "  " .. name
                keybind.Size = UDim2.new(0, textWidth(titleLabel) + 80, 0, 20)

                -- Nombres cortos para mostrar en el botón
                local shortNames = {
                    RightControl = "RightCtrl",
                    LeftControl = "LeftCtrl",
                    LeftShift = "LShift",
                    RightShift = "RShift",
                    MouseButton1 = "Mouse1",
                    MouseButton2 = "Mouse2",
                }

                local currentKey = opts.standard

                function keybindApi:SetKeybind(keyCode)
                    local label = shortNames[keyCode.Name] or keyCode.Name
                    input.Text = label
                    currentKey = keyCode
                end

                UserInputService.InputBegan:Connect(function(inputObject, processed)
                    if state.binding then
                        task.defer(function()
                            state.binding = false
                        end)
                        return
                    end

                    if inputObject.KeyCode == currentKey and not processed then
                        pcall(callback, currentKey)
                    end
                end)

                keybindApi:SetKeybind(opts.standard)

                input.MouseButton1Click:Connect(function()
                    if state.binding then return end

                    input.Text = "..."
                    state.binding = true

                    local nextInput = UserInputService.InputBegan:Wait()
                    keybindApi:SetKeybind(nextInput.KeyCode)
                end)

                return keybindApi, keybind
            end

            function tabApi:AddDropdown(name, callback)
                local dropdownApi = {}
                name = tostring(name or "New Dropdown")
                callback = typeof(callback) == "function" and callback or function() end

                local dropdown = prefabs:FindFirstChild("Dropdown"):Clone()
                local box = dropdown:FindFirstChild("Box")
                local objects = box:FindFirstChild("Objects")
                local arrow = dropdown:FindFirstChild("Indicator")

                dropdown.ZIndex = dropdown.ZIndex + windowCount * 10
                box.ZIndex = box.ZIndex + windowCount * 10
                objects.ZIndex = objects.ZIndex + windowCount * 10
                arrow.ZIndex = arrow.ZIndex + windowCount * 10

                dropdown.Size = UDim2.new(0.5, -5, 0, 20)

                local dropdownBackground = dropdown:GetChildren()[3]
                dropdownBackground.ZIndex = dropdownBackground.ZIndex + windowCount * 10
                dropdownBackground.ImageTransparency = options.title_bar_transparency or 0
                setColor(dropdownBackground, options.title_bar, 0)

                box.ImageTransparency = options.background_transparency or 0.1
                setColor(box, options.background, 0)

                local boxCorner = Instance.new("UICorner")
                boxCorner.CornerRadius = UDim.new(0, 6)
                boxCorner.Parent = box

                objects.BackgroundTransparency = 1
                objects.Position = UDim2.new(0, 0, 0, 0)
                objects.Size = UDim2.new(1, 0, 1, 0)

                dropdown.Parent = scroller
                dropdown.Text = "      " .. name

                box.Size = UDim2.new(1, 0, 0, 0)
                box.Position = UDim2.new(0, 0, 0, 25)

                dropdown.TextColor3 = Color3.new(1, 1, 1)

                local isOpen = false
                local opensUpward = false

                -- Calcula la altura de la lista (máx. 200) y ajusta el scroll
                local function getListHeight()
                    local itemCount = #objects:GetChildren() - 1 -- el -1 es el UIListLayout
                    if itemCount >= 10 then
                        objects.CanvasSize = UDim2.new(0, 0, itemCount * 0.1, 0)
                    end
                    return math.min(itemCount * 20, 200)
                end

                local function tweenBoxTo(properties)
                    local info = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local boxTween = TweenService:Create(box, info, properties)
                    boxTween:Play()
                    return boxTween
                end

                local function closeBox()
                    isDropdownOpen = false

                    if opensUpward then
                        local closeTween = tweenBoxTo({
                            Size = UDim2.new(1, 0, 0, 0),
                            Position = UDim2.new(0, 0, 0, -5),
                        })
                        closeTween.Completed:Connect(function()
                            box.Position = UDim2.new(0, 0, 0, 25)
                        end)
                    else
                        tween(box, { Size = UDim2.new(1, 0, 0, 0) }, tweenTime)
                    end

                    tween(arrow, { Rotation = -90 }, tweenTime)
                end

                dropdown.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    local listHeight = getListHeight()

                    if isOpen then
                        if isDropdownOpen then return end -- ya hay otro dropdown abierto
                        isDropdownOpen = true

                        -- ¿Cabe hacia abajo dentro de la ventana?
                        local dropdownBottom = dropdown.AbsolutePosition.Y + dropdown.AbsoluteSize.Y
                        local windowBottom = window.AbsolutePosition.Y + window.AbsoluteSize.Y
                        local spaceBelow = windowBottom - dropdownBottom

                        if spaceBelow < listHeight then
                            -- Abrir hacia arriba
                            opensUpward = true
                            box.Position = UDim2.new(0, 0, 0, -listHeight - 5)
                            box.Size = UDim2.new(1, 0, 0, 0)
                            tweenBoxTo({
                                Size = UDim2.new(1, 0, 0, listHeight),
                                Position = UDim2.new(0, 0, 0, -listHeight - 5),
                            })
                            tween(arrow, { Rotation = -90 }, tweenTime)
                        else
                            -- Abrir hacia abajo
                            opensUpward = false
                            box.Position = UDim2.new(0, 0, 0, 25)
                            box.Size = UDim2.new(1, 0, 0, 0)
                            tween(box, { Size = UDim2.new(1, 0, 0, listHeight) }, tweenTime)
                            tween(arrow, { Rotation = 90 }, tweenTime)
                        end
                    else
                        closeBox()
                    end
                end)

                -- Agrega una opción a la lista
                function dropdownApi:Add(optionText)
                    local optionApi = {}
                    optionText = tostring(optionText or "New Object")

                    local option = prefabs:FindFirstChild("DropdownButton"):Clone()
                    option.Parent = objects
                    option.Text = "      " .. optionText
                    option.ZIndex = option.ZIndex + windowCount * 10 + 5
                    option.BackgroundTransparency = 1
                    option.TextColor3 = Color3.new(1, 1, 1)
                    option.BorderSizePixel = 0
                    option.TextXAlignment = Enum.TextXAlignment.Left

                    local optionCorner = option:FindFirstChildOfClass("UICorner")
                    if optionCorner then
                        optionCorner:Destroy()
                    end

                    local optionStroke = Instance.new("UIStroke")
                    optionStroke.Color = Color3.new(0, 0, 0)
                    optionStroke.Thickness = 1
                    optionStroke.Transparency = 0.3
                    optionStroke.Parent = option

                    option.MouseEnter:Connect(function()
                        option.BackgroundTransparency = 0.8
                        option.BackgroundColor3 = options.main_color
                    end)

                    option.MouseLeave:Connect(function()
                        option.BackgroundTransparency = 1
                    end)

                    -- Si la lista está abierta, crecer para incluir la nueva opción
                    if isOpen then
                        local listHeight = getListHeight()
                        if opensUpward then
                            tweenBoxTo({
                                Size = UDim2.new(1, 0, 0, listHeight),
                                Position = UDim2.new(0, 0, 0, -listHeight - 5),
                            })
                        else
                            tween(box, { Size = UDim2.new(1, 0, 0, listHeight) }, tweenTime)
                        end
                    end

                    option.MouseButton1Click:Connect(function()
                        if isDropdownOpen then
                            dropdown.Text = "      [ " .. optionText .. " ]"
                            isOpen = false
                            closeBox()
                            pcall(callback, optionText)
                        end
                    end)

                    function optionApi:Remove()
                        option:Destroy()
                    end

                    return option, optionApi
                end

                -- Nota: busca por NOMBRE de instancia (todas las opciones se llaman "DropdownButton")
                function dropdownApi:Remove(objectName)
                    local found = objects:FindFirstChild(objectName)
                    if found then
                        found:Destroy()

                        if dropdownApi.currentSelection == objectName then
                            local first = objects:GetChildren()[1]
                            local newText = first and first.Text or "No Selection"
                            dropdownApi.currentSelection = newText
                            dropdown.Text = "        [ " .. newText .. " ]"
                            pcall(callback, newText)
                        end
                    end
                end

                return dropdownApi, dropdown
            end

            function tabApi:AddColorPicker(callback)
                local pickerApi = {}
                callback = typeof(callback) == "function" and callback or function() end

                local picker = prefabs:FindFirstChild("ColorPicker"):Clone()
                picker.Parent = scroller
                picker.ZIndex = picker.ZIndex + windowCount * 10

                local palette = picker:FindFirstChild("Palette")
                local sample = picker:FindFirstChild("Sample")
                local brightnessBar = picker:FindFirstChild("Saturation") -- controla el brillo (V)

                palette.ZIndex = palette.ZIndex + windowCount * 10
                sample.ZIndex = sample.ZIndex + windowCount * 10
                brightnessBar.ZIndex = brightnessBar.ZIndex + windowCount * 10

                local hue, saturation, value = 0, 1, 1

                local function updateColor()
                    local color = Color3.fromHSV(hue, saturation, value)
                    sample.ImageColor3 = color
                    brightnessBar.ImageColor3 = Color3.fromHSV(hue, 1, 1)
                    pcall(callback, color)
                end

                -- Estado inicial
                sample.ImageColor3 = Color3.fromHSV(hue, saturation, value)
                brightnessBar.ImageColor3 = Color3.fromHSV(hue, 1, 1)

                local hoveringPalette, hoveringBrightness = false, false

                palette.MouseEnter:Connect(function()
                    window.Draggable = false
                    hoveringPalette = true
                end)
                palette.MouseLeave:Connect(function()
                    window.Draggable = true
                    hoveringPalette = false
                end)

                brightnessBar.MouseEnter:Connect(function()
                    window.Draggable = false
                    hoveringBrightness = true
                end)
                brightnessBar.MouseLeave:Connect(function()
                    window.Draggable = true
                    hoveringBrightness = false
                end)

                local paletteIndicator = palette:FindFirstChild("Indicator")
                local brightnessIndicator = brightnessBar:FindFirstChild("Indicator")
                paletteIndicator.ZIndex = paletteIndicator.ZIndex + windowCount * 10
                brightnessIndicator.ZIndex = brightnessIndicator.ZIndex + windowCount * 10

                local isMouseDown = false
                local dragConnection

                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isMouseDown = true

                        dragConnection = RunService.Heartbeat:Connect(function()
                            if not isMouseDown or isDropdownOpen then
                                if dragConnection then
                                    dragConnection:Disconnect()
                                    dragConnection = nil
                                end
                                return
                            end

                            if hoveringPalette then
                                local mousePos = getMousePosition()
                                local x = math.clamp((mousePos.X - palette.AbsolutePosition.X) / palette.AbsoluteSize.X, 0, 1)
                                local y = math.clamp((mousePos.Y - palette.AbsolutePosition.Y) / palette.AbsoluteSize.Y, 0, 1)

                                hue = x
                                saturation = 1 - y

                                paletteIndicator.Position = UDim2.new(
                                    x, -paletteIndicator.AbsoluteSize.X / 2,
                                    y, -paletteIndicator.AbsoluteSize.Y / 2
                                )
                                updateColor()

                            elseif hoveringBrightness then
                                local mousePos = getMousePosition()
                                local y = math.clamp((mousePos.Y - brightnessBar.AbsolutePosition.Y) / brightnessBar.AbsoluteSize.Y, 0, 1)

                                value = 1 - y

                                brightnessIndicator.Position = UDim2.new(0, 0, y, 0)
                                updateColor()
                            end
                        end)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isMouseDown = false
                        if dragConnection then
                            dragConnection:Disconnect()
                            dragConnection = nil
                        end
                    end
                end)

                function pickerApi:Set(color)
                    color = typeof(color) == "Color3" and color or Color3.new(1, 1, 1)
                    local h = rgbToHsv(color.r * 255, color.g * 255, color.b * 255)

                    sample.ImageColor3 = color
                    brightnessBar.ImageColor3 = Color3.fromHSV(h, 1, 1)
                    pcall(callback, color)
                end

                return pickerApi, picker
            end

            function tabApi:AddHorizontalAlignment()
                local rowApi = {}

                local row = prefabs:FindFirstChild("HorizontalAlignment"):Clone()
                row.Parent = scroller

                -- Agrega un botón dentro de la fila
                function rowApi:AddButton(...)
                    local results = { tabApi:AddButton(...) }
                    local button = results[#results]
                    button.Parent = row
                    return table.unpack(results)
                end

                return rowApi, row
            end

            function tabApi:AddFolder(folderName)
                local folderApi = {}
                folderName = tostring(folderName or "New Folder")

                local folder = prefabs:FindFirstChild("Folder"):Clone()
                local folderButton = folder:FindFirstChild("Button")
                local objects = folder:FindFirstChild("Objects")
                local arrow = folderButton:FindFirstChild("Toggle")

                folder.ZIndex = folder.ZIndex + windowCount * 10
                folderButton.ZIndex = folderButton.ZIndex + windowCount * 10
                objects.ZIndex = objects.ZIndex + windowCount * 10
                arrow.ZIndex = arrow.ZIndex + windowCount * 10
                folderButton:GetChildren()[1].ZIndex = folderButton:GetChildren()[1].ZIndex + windowCount * 10

                folder.Parent = scroller
                folderButton.Text = "      " .. folderName

                local folderBackground = folderButton:GetChildren()[1]
                folderBackground.ImageColor3 = options.main_color

                -- Altura total = cabecera (25) + cada hijo + 5 de separación
                local function calculateHeight()
                    local height = 25
                    for _, child in ipairs(objects:GetChildren()) do
                        if not child:IsA("UIListLayout") then
                            height = height + child.AbsoluteSize.Y + 5
                        end
                    end
                    return height
                end

                local isOpen = false
                local heartbeatConnection

                folderButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen

                    if isOpen then
                        tween(arrow, { Rotation = 90 }, tweenTime)
                        objects.Visible = true

                        if heartbeatConnection then
                            heartbeatConnection:Disconnect()
                        end
                        -- Mientras esté abierta, la carpeta ajusta su altura cada frame
                        heartbeatConnection = RunService.Heartbeat:Connect(function()
                            if isOpen then
                                folder.Size = UDim2.new(1, 0, 0, calculateHeight())
                            else
                                if heartbeatConnection then
                                    heartbeatConnection:Disconnect()
                                    heartbeatConnection = nil
                                end
                            end
                        end)
                    else
                        tween(arrow, { Rotation = 0 }, tweenTime)
                        objects.Visible = false
                        folder.Size = UDim2.new(1, 0, 0, 20)

                        if heartbeatConnection then
                            heartbeatConnection:Disconnect()
                            heartbeatConnection = nil
                        end
                    end
                end)

                -- La carpeta expone los mismos métodos Add* que la pestaña,
                -- pero metiendo el elemento creado dentro de la carpeta
                for methodName, method in pairs(tabApi) do
                    folderApi[methodName] = function(...)
                        local results = { method(...) }
                        local element = results[#results]
                        element.Parent = objects
                        return table.unpack(results)
                    end
                end

                return folderApi, folder
            end

            return tabApi, tabPage
        end
    end

    -- Sube el ZIndex de todo lo que ya exista dentro de la ventana
    for _, descendant in ipairs(window:GetDescendants()) do
        if hasProperty(descendant, "ZIndex") then
            descendant.ZIndex = descendant.ZIndex + windowCount * 10
        end
    end

    return windowApi, window
end

-- Si el script se destruye, limpiar las conexiones globales
script.AncestryChanged:Connect(function()
    if not script.Parent then
        disconnectAll()
    end
end)

return library
