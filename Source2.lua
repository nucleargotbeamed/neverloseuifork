print("forked")
-- init
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- services
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new

-- additional
local utility = {}

-- Neverlose-inspired themes
local objects = {}
local themes = {
    Background = Color3.fromRGB(9, 9, 13),
    Glow = Color3.fromRGB(14, 191, 255),
    Accent = Color3.fromRGB(7, 15, 25),
    LightContrast = Color3.fromRGB(0, 20, 40),
    DarkContrast = Color3.fromRGB(3, 5, 13),
    TextColor = Color3.fromRGB(255, 255, 255),
    Element = Color3.fromRGB(61, 133, 224)
}

do
    function utility:Create(instance, properties, children)
        local object = Instance.new(instance)
        
        for i, v in pairs(properties or {}) do
            object[i] = v
            
            if typeof(v) == "Color3" then -- save for theme changer later
                local theme = utility:Find(themes, v)
                
                if theme then
                    objects[theme] = objects[theme] or {}
                    objects[theme][i] = objects[theme][i] or setmetatable({}, {__mode = "k"})
                    
                    table.insert(objects[theme][i], object)
                end
            end
        end
        
        for i, module in pairs(children or {}) do
            module.Parent = object
        end
        
        return object
    end
    
    function utility:Tween(instance, properties, duration, ...)
        tween:Create(instance, tweeninfo(duration, ...), properties):Play()
    end
    
    function utility:Wait()
        run.RenderStepped:Wait()
        return true
    end
    
    function utility:Find(table, value) -- table.find doesn't work for dictionaries
        for i, v in  pairs(table) do
            if v == value then
                return i
            end
        end
    end
    
    function utility:Sort(pattern, values)
        local new = {}
        pattern = pattern:lower()
        
        if pattern == "" then
            return values
        end
        
        for i, value in pairs(values) do
            if tostring(value):lower():find(pattern) then
                table.insert(new, value)
            end
        end
        
        return new
    end
    
    function utility:Pop(object, shrink)
        local clone = object:Clone()
        
        clone.AnchorPoint = Vector2.new(0.5, 0.5)
        clone.Size = clone.Size - UDim2.new(0, shrink, 0, shrink)
        clone.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        clone.Parent = object
        clone:ClearAllChildren()
        
        object.ImageTransparency = 1
        utility:Tween(clone, {Size = object.Size}, 0.2)
        
        spawn(function()
            wait(0.2)
        
            object.ImageTransparency = 0
            clone:Destroy()
        end)
        
        return clone
    end
    
    function utility:InitializeKeybind()
        self.keybinds = {}
        self.ended = {}
        
        input.InputBegan:Connect(function(key)
            if self.keybinds[key.KeyCode] then
                for i, bind in pairs(self.keybinds[key.KeyCode]) do
                    bind()
                end
            end
        end)
        
        input.InputEnded:Connect(function(key)
            if key.UserInputType == Enum.UserInputType.MouseButton1 then
                for i, callback in pairs(self.ended) do
                    callback()
                end
            end
        end)
    end
    
    function utility:BindToKey(key, callback)
         
        self.keybinds[key] = self.keybinds[key] or {}
        
        table.insert(self.keybinds[key], callback)
        
        return {
            UnBind = function()
                for i, bind in pairs(self.keybinds[key]) do
                    if bind == callback then
                        table.remove(self.keybinds[key], i)
                    end
                end
            end
        }
    end
    
    function utility:KeyPressed() -- yield until next key is pressed
        local key = input.InputBegan:Wait()
        
        while key.UserInputType ~= Enum.UserInputType.Keyboard do
            key = input.InputBegan:Wait()
        end
        
        wait() -- overlapping connection
        
        return key
    end
    
    function utility:DraggingEnabled(frame, parent)
    
        parent = parent or frame
        
        -- stolen from wally or kiriot, kek
        local dragging = false
        local dragInput, mousePos, framePos

        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                mousePos = input.Position
                framePos = parent.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        input.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            end
        end)
    end
    
    function utility:DraggingEnded(callback)
        table.insert(self.ended, callback)
    end
    
end

-- classes

local library = {} -- main
local page = {}
local section = {}

do
    library.__index = library
    page.__index = page
    section.__index = section
    
    -- new classes
    
    function library.new(title)
        local container = utility:Create("ScreenGui", {
            Name = "VenyxNeverlose",
            Parent = game.CoreGui
        }, {
            utility:Create("ImageLabel", {
                Name = "Main",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.25, 0, 0.052435593, 0),
                Size = UDim2.new(0, 643, 0, 682),
                Image = "rbxassetid://4641149554",
                ImageColor3 = themes.Background,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(4, 4, 296, 296)
            }, {
                -- Neverlose-style glow
                utility:Create("ImageLabel", {
                    Name = "Glow",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(-0.4, 0, -0.05, 0),
                    Size = UDim2.new(0, 939, 0, 754),
                    ZIndex = -1,
                    Image = "rbxassetid://4996891970",
                    ImageColor3 = themes.Glow,
                    ImageTransparency = 0.52
                }),
                -- Left sidebar (Neverlose style)
                utility:Create("ImageLabel", {
                    Name = "LeftFrame",
                    BackgroundTransparency = 0.1,
                    Position = UDim2.new(-0.314, 0, 0, 0),
                    Size = UDim2.new(0, 203, 0, 682),
                    Image = "rbxassetid://4641149554",
                    ImageColor3 = Color3.fromRGB(7, 15, 25),
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(4, 4, 296, 296)
                }, {
                    utility:Create("TextLabel", {
                        Name = "Title",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.109, 0, 0, 0),
                        Size = UDim2.new(0, 157, 0, 67),
                        Font = Enum.Font.FredokaOne,
                        Text = title,
                        TextColor3 = Color3.fromRGB(239, 248, 246),
                        TextSize = 33,
                        TextStrokeColor3 = Color3.fromRGB(27, 141, 240),
                        TextStrokeTransparency = 1
                    }),
                    utility:Create("Frame", {
                        Name = "Pages",
                        BackgroundTransparency = 1,
                        ClipsDescendants = true,
                        Position = UDim2.new(0, 0, 0.125, 0),
                        Size = UDim2.new(1, 0, 0.9, 0)
                    }, {
                        utility:Create("ScrollingFrame", {
                            Name = "Pages_Container",
                            Active = true,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, -20),
                            CanvasSize = UDim2.new(0, 0, 0, 314),
                            ScrollBarThickness = 0
                        }, {
                            utility:Create("UIListLayout", {
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = UDim.new(0, 24)
                            })
                        })
                    })
                }),
                -- Top bar (Neverlose style)
                utility:Create("ImageLabel", {
                    Name = "TopBar",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 38),
                    ZIndex = 5,
                    Image = "rbxassetid://4595286933",
                    ImageColor3 = themes.Accent,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(4, 4, 296, 296)
                }, {
                    utility:Create("TextLabel", {
                        Name = "Title",
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 19),
                        Size = UDim2.new(1, -46, 0, 16),
                        ZIndex = 5,
                        Font = Enum.Font.GothamBold,
                        Text = title,
                        TextColor3 = themes.TextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                }),
                -- Main content area
                utility:Create("Frame", {
                    Name = "Content",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0.112, 0),
                    Size = UDim2.new(1, 0, 0.888, 0)
                })
            })
        })
        
        utility:InitializeKeybind()
        utility:DraggingEnabled(container.Main.TopBar, container.Main)
        
        return setmetatable({
            container = container,
            pagesContainer = container.Main.LeftFrame.Pages.Pages_Container,
            pages = {},
            contentFrame = container.Main.Content
        }, library)
    end
    
    function page.new(library, title, icon)
        -- Neverlose-style tab button
        local button = utility:Create("TextButton", {
            Name = title,
            Parent = library.pagesContainer,
            BackgroundColor3 = Color3.fromRGB(13, 98, 144),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 159, 0, 26),
            AutoButtonColor = false,
            Font = Enum.Font.Gotham,
            Text = "",
            TextSize = 14
        }, {
            utility:Create("UICorner", {
                CornerRadius = UDim.new(0, 4)
            }),
            utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.088, 0, 0.214, 0),
                Size = UDim2.new(0, 56, 0, 15),
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            icon and utility:Create("ImageLabel", {
                Name = "Icon", 
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.012, 0, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                Image = "rbxassetid://" .. tostring(icon),
                ImageColor3 = themes.TextColor,
                ImageTransparency = 0.64,
                ScaleType = Enum.ScaleType.Fit
            }) or utility:Create("Frame")
        })
        
        -- Content container (Neverlose style scrolling frame)
        local container = utility:Create("ScrollingFrame", {
            Name = title,
            Parent = library.contentFrame,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 466),
            ScrollBarThickness = 0,
            Visible = false
        }, {
            utility:Create("Frame", {
                Name = "SectionsContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 580)
            }, {
                utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 13)
                })
            })
        })
        
        return setmetatable({
            library = library,
            container = container,
            button = button,
            sections = {},
            sectionsContainer = container.SectionsContainer
        }, page)
    end
    
    function section.new(page, title)
        -- Neverlose-style section with proper sizing
        local container = utility:Create("Frame", {
            Name = title,
            Parent = page.sectionsContainer,
            BackgroundColor3 = themes.LightContrast,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 285, 0, 28),
            ZIndex = 2,
            ClipsDescendants = false  -- Changed to false to see content
        }, {
            utility:Create("UICorner", {
                CornerRadius = UDim.new(0, 8)
            }),
            utility:Create("Frame", {
                Name = "Container",
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 8, 0, 30),
                Size = UDim2.new(1, -16, 0, 0),  -- Dynamic size will be set
                ClipsDescendants = false
            }, {
                utility:Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, -30, 0),
                    Size = UDim2.new(1, 0, 0, 23),
                    ZIndex = 2,
                    Font = Enum.Font.SourceSansBold,
                    Text = title,
                    TextColor3 = themes.TextColor,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTransparency = 1
                }),
                utility:Create("Frame", {
                    Name = "Line",
                    BackgroundColor3 = Color3.fromRGB(23, 50, 83),
                    BackgroundTransparency = 0.55,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.025, 0, -15, 0),
                    Size = UDim2.new(0.95, 0, 0, 1)
                }),
                utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8)
                })
            })
        })
        
        return setmetatable({
            page = page,
            container = container.Container,
            titleLabel = container.Container.Title,
            mainFrame = container,
            colorpickers = {},
            modules = {},
            binds = {},
            lists = {},
        }, section) 
    end
    
    function library:addPage(...)
        local page = page.new(self, ...)
        local button = page.button
        
        table.insert(self.pages, page)

        button.MouseButton1Click:Connect(function()
            self:SelectPage(page, true)
        end)
        
        return page
    end
    
    function page:addSection(...)
        local section = section.new(self, ...)
        
        table.insert(self.sections, section)
        
        return section
    end
    
    -- functions
    
    function library:setTheme(theme, color3)
        themes[theme] = color3
        
        for property, objects in pairs(objects[theme]) do
            for i, object in pairs(objects) do
                if not object.Parent or (object.Name == "Button" and object.Parent.Name == "ColorPicker") then
                    objects[i] = nil -- i can do this because weak tables :D
                else
                    object[property] = color3
                end
            end
        end
    end
    
    function library:toggle()
        if self.toggling then
            return
        end
        
        self.toggling = true
        
        local container = self.container.Main
        local topbar = container.TopBar
        
        if self.position then
            utility:Tween(container, {
                Size = UDim2.new(0, 643, 0, 682),
                Position = self.position
            }, 0.2)
            wait(0.2)
            
            utility:Tween(topbar, {Size = UDim2.new(1, 0, 0, 38)}, 0.2)
            wait(0.2)
            
            container.ClipsDescendants = false
            self.position = nil
        else
            self.position = container.Position
            container.ClipsDescendants = true
            
            utility:Tween(topbar, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
            wait(0.2)
            
            utility:Tween(container, {
                Size = UDim2.new(0, 643, 0, 0),
                Position = self.position + UDim2.new(0, 0, 0, 682)
            }, 0.2)
            wait(0.2)
        end
        
        self.toggling = false
    end
    
    -- new modules
    
    function library:Notify(title, text, callback)
        -- Neverlose-style notification
        local notification = utility:Create("Frame", {
            Name = "Notification",
            Parent = self.container,
            BackgroundColor3 = Color3.fromRGB(15, 25, 39),
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0, 200, 0, 67),
            Position = UDim2.new(0.8, 0, 0.1, 0),
            ZIndex = 3,
            ClipsDescendants = true
        }, {
            utility:Create("UICorner", {
                CornerRadius = UDim.new(0, 4)
            }),
            utility:Create("Frame", {
                Name = "Line",
                BackgroundColor3 = Color3.fromRGB(3, 168, 245),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0.925, 0),
                Size = UDim2.new(1, 0, 0, 5)
            }, {
                utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4)
                })
            }),
            utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.231, 0, 0.143, 0),
                Size = UDim2.new(0.5, 0, 0, 22),
                ZIndex = 4,
                Font = Enum.Font.Gotham,
                Text = title or "Notification",
                TextColor3 = themes.TextColor,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true
            }),
            utility:Create("TextLabel", {
                Name = "Text",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.231, 0, 0.6, 0),
                Size = UDim2.new(0.6, 0, 0, 22),
                ZIndex = 4,
                Font = Enum.Font.Gotham,
                Text = text or "",
                TextColor3 = Color3.fromRGB(220, 220, 220),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        })
        
        utility:DraggingEnabled(notification)
        
        local textSize = game:GetService("TextService"):GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))
        local width = math.max(textSize.X + 70, 200)
        
        notification.Size = UDim2.new(0, 0, 0, 67)
        utility:Tween(notification, {Size = UDim2.new(0, width, 0, 67)}, 0.2)
        
        wait(0.2)
        
        local active = true
        local close = function()
            if not active then
                return
            end
            
            active = false
            utility:Tween(notification, {
                Size = UDim2.new(0, 0, 0, 67),
                Position = notification.Position + UDim2.new(0, width, 0, 0)
            }, 0.2)
            
            wait(0.2)
            notification:Destroy()
        end
        
        if callback then
            notification.MouseButton1Click:Connect(function()
                if active then
                    callback(true)
                    close()
                end
            end)
        end
        
        spawn(function()
            wait(3)
            close()
        end)
        
        return notification
    end
    
    function section:addButton(title, callback)
        -- Neverlose-style button
        local button = utility:Create("TextButton", {
            Name = "Button",
            Parent = self.container,
            BackgroundColor3 = themes.DarkContrast,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 26),
            ZIndex = 2,
            AutoButtonColor = false,
            Font = Enum.Font.Gotham,
            Text = "",
            TextSize = 12
        }, {
            utility:Create("UICorner", {
                CornerRadius = UDim.new(0, 4)
            }),
            utility:Create("UIStroke", {
                Color = themes.Element,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Thickness = 1,
                Transparency = 0.8
            }),
            utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0.036, 0, 0, 0),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        })
        
        table.insert(self.modules, button)
        
        local text = button.Title
        local debounce
        
        button.MouseEnter:Connect(function()
            if not debounce then
                utility:Tween(button.UIStroke, {Transparency = 0.1}, 0.2)
            end
        end)
        
        button.MouseLeave:Connect(function()
            if not debounce then
                utility:Tween(button.UIStroke, {Transparency = 0.8}, 0.2)
            end
        end)
        
        button.MouseButton1Click:Connect(function()
            if debounce then
                return
            end
            
            debounce = true
            utility:Pop(button, 10)
            
            text.TextSize = 0
            utility:Tween(text, {TextSize = 14}, 0.2)
            
            wait(0.2)
            utility:Tween(text, {TextSize = 13}, 0.2)
            
            if callback then
                callback(function(...)
                    self:updateButton(button, ...)
                end)
            end
            
            debounce = false
        end)
        
        self:Resize()
        return button
    end
    
    function section:addToggle(title, default, callback)
        -- Neverlose-style toggle
        local toggle = utility:Create("TextButton", {
            Name = "Toggle",
            Parent = self.container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 26),
            ZIndex = 2,
            AutoButtonColor = false,
            Font = Enum.Font.SourceSans,
            Text = ""
        },{
            utility:Create("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.036, 0, 0.5, 0),
                Size = UDim2.new(0.5, 0, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("Frame", {
                Name = "ToggleFrame",
                BackgroundColor3 = themes.DarkContrast,
                BorderSizePixel = 0,
                Position = UDim2.new(0.87, 0, 0.233, 0),
                Size = UDim2.new(0, 38, 0, 15)
            }, {
                utility:Create("Frame", {
                    Name = "ToggleDot",
                    BackgroundColor3 = Color3.fromRGB(74, 87, 97),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, -0.059, 0),
                    Size = UDim2.new(0, 17, 0, 17)
                }, {
                    utility:Create("UICorner", {
                        CornerRadius = UDim.new(2, 0)
                    })
                })
            })
        })
        
        table.insert(self.modules, toggle)
        
        local active = default
        self:updateToggle(toggle, nil, active)
        
        toggle.MouseButton1Click:Connect(function()
            active = not active
            self:updateToggle(toggle, nil, active)
            
            if callback then
                callback(active, function(...)
                    self:updateToggle(toggle, ...)
                end)
            end
        end)
        
        self:Resize()
        return toggle
    end
    
    function section:addTextbox(title, default, callback)
        -- Neverlose-style textbox
        local textbox = utility:Create("TextButton", {
            Name = "Textbox",
            Parent = self.container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 26),
            ZIndex = 2,
            AutoButtonColor = false,
            Font = Enum.Font.SourceSans,
            Text = ""
        }, {
            utility:Create("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.036, 0, 0.5, 0),
                Size = UDim2.new(0.5, 0, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("Frame", {
                Name = "TextBoxFrame",
                BackgroundColor3 = themes.DarkContrast,
                BackgroundTransparency = 0.8,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.621, 0, 0.154, 0),
                Size = UDim2.new(0, 100, 0, 20)
            }, {
                utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 5)
                }),
                utility:Create("UIStroke", {
                    Color = themes.Element,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Thickness = 1,
                    Transparency = 0.9
                }),
                utility:Create("TextBox", {
                    Name = "Textbox", 
                    BackgroundTransparency = 1,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Position = UDim2.new(0.05, 0, 0, 0),
                    Size = UDim2.new(0.9, 0, 1, 0),
                    ZIndex = 3,
                    Font = Enum.Font.GothamSemibold,
                    Text = default or "",
                    TextColor3 = themes.TextColor,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Center
                })
            })
        })
        
        table.insert(self.modules, textbox)
        
        local frame = textbox.TextBoxFrame
        local input = frame.Textbox
        
        textbox.MouseButton1Click:Connect(function()
            if frame.Size ~= UDim2.new(0, 100, 0, 20) then
                return
            end
            
            utility:Tween(frame, {
                Size = UDim2.new(0, 200, 0, 20),
                Position = UDim2.new(0.5, -100, 0.154, 0)
            }, 0.2)
            
            wait()
            input.TextXAlignment = Enum.TextXAlignment.Left
            input:CaptureFocus()
        end)
        
        input:GetPropertyChangedSignal("Text"):Connect(function()
            if frame.BackgroundTransparency == 0.8 then
                utility:Tween(frame.UIStroke, {Transparency = 0.1}, 0.2)
                wait(0.1)
                utility:Tween(frame.UIStroke, {Transparency = 0.9}, 0.2)
            end
            
            if callback then
                callback(input.Text, nil, function(...)
                    self:updateTextbox(textbox, ...)
                end)
            end
        end)
        
        input.FocusLost:Connect(function()
            input.TextXAlignment = Enum.TextXAlignment.Center
            
            utility:Tween(frame, {
                Size = UDim2.new(0, 100, 0, 20),
                Position = UDim2.new(0.621, 0, 0.154, 0)
            }, 0.2)
            
            if callback then
                callback(input.Text, true, function(...)
                    self:updateTextbox(textbox, ...)
                end)
            end
        end)
        
        self:Resize()
        return textbox
    end
    
    function section:addKeybind(title, default, callback, changedCallback)
        -- Neverlose-style keybind
        local keybind = utility:Create("TextButton", {
            Name = "Keybind",
            Parent = self.container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 26),
            ZIndex = 2,
            AutoButtonColor = false,
            Font = Enum.Font.SourceSans,
            Text = ""
        }, {
            utility:Create("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.036, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("Frame", {
                Name = "KeybindFrame",
                BackgroundColor3 = themes.DarkContrast,
                BorderSizePixel = 0,
                Position = UDim2.new(0.8, 0, 0.2, 0),
                Size = UDim2.new(0, 60, 0, 17)
            }, {
                utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 3)
                }),
                utility:Create("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Size = UDim2.new(1, 0, 0.98, 0),
                    ZIndex = 3,
                    Font = Enum.Font.GothamSemibold,
                    Text = default and default.Name or "None",
                    TextColor3 = themes.TextColor,
                    TextSize = 11
                })
            })
        })
        
        table.insert(self.modules, keybind)
        
        local text = keybind.KeybindFrame.Text
        local frame = keybind.KeybindFrame
        
        local animate = function()
            if frame.BackgroundTransparency == 0 then
                utility:Pop(frame, 5)
            end
        end
        
        self.binds[keybind] = {callback = function()
            animate()
            
            if callback then
                callback(function(...)
                    self:updateKeybind(keybind, ...)
                end)
            end
        end}
        
        if default and callback then
            self:updateKeybind(keybind, nil, default)
        end
        
        keybind.MouseButton1Click:Connect(function()
            animate()
            
            if self.binds[keybind].connection then
                return self:updateKeybind(keybind)
            end
            
            if text.Text == "None" then
                text.Text = "..."
                
                local key = utility:KeyPressed()
                
                self:updateKeybind(keybind, nil, key.KeyCode)
                animate()
                
                if changedCallback then
                    changedCallback(key, function(...)
                        self:updateKeybind(keybind, ...)
                    end)
                end
            end
        end)
        
        self:Resize()
        return keybind
    end
    
    function section:addColorPicker(title, default, callback)
        -- Simplified Neverlose-style color picker
        local colorpicker = utility:Create("TextButton", {
            Name = "ColorPicker",
            Parent = self.container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 26),
            ZIndex = 2,
            AutoButtonColor = false,
            Font = Enum.Font.SourceSans,
            Text = ""
        },{
            utility:Create("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.036, 0, 0.5, 0),
                Size = UDim2.new(0.5, 0, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("TextButton", {
                Name = "ColorPreview",
                BackgroundColor3 = default or Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.925, 0, 0.231, 0),
                Size = UDim2.new(0, 15, 0, 15),
                ZIndex = 2,
                AutoButtonColor = false,
                Font = Enum.Font.SourceSans,
                Text = ""
            }, {
                utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0)
                }),
                utility:Create("UIStroke", {
                    Color = themes.Element,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Thickness = 2,
                    Transparency = 0.1
                })
            })
        })
        
        table.insert(self.modules, colorpicker)
        self:Resize()
        
        local preview = colorpicker.ColorPreview
        
        local color3 = default or Color3.fromRGB(255, 255, 255)
        
        colorpicker.MouseButton1Click:Connect(function()
            -- Create color picker popup
            local colorFrame = utility:Create("Frame", {
                Name = "ColorPickerPopup",
                Parent = self.page.library.container,
                BackgroundColor3 = Color3.fromRGB(0, 21, 40),
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, -131, 0.5, -81),
                Size = UDim2.new(0, 262, 0, 162),
                ZIndex = 10,
                ClipsDescendants = true
            }, {
                utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4)
                }),
                utility:Create("ImageLabel", {
                    Name = "Glow",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(-0.04, 0, -0.04, 0),
                    Size = UDim2.new(0, 286, 0, 178),
                    ZIndex = 9,
                    Image = "rbxassetid://4996891970",
                    ImageColor3 = themes.Glow,
                    ImageTransparency = 0
                }),
                utility:Create("TextButton", {
                    Name = "Close",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1.000,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.905, 0, 0.031, 0),
                    Size = UDim2.new(0, 27, 0, 21),
                    ZIndex = 11,
                    Font = Enum.Font.GothamBold,
                    Text = "X",
                    TextColor3 = Color3.fromRGB(20, 120, 213),
                    TextSize = 14.000
                }),
                utility:Create("ImageButton", {
                    Name = "ColorCanvas",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.042, 0, 0.088, 0),
                    Size = UDim2.new(0, 174, 0, 114),
                    ZIndex = 11,
                    Image = "rbxassetid://4155801252",
                    AutoButtonColor = false
                }, {
                    utility:Create("UICorner", {
                        CornerRadius = UDim.new(0, 4)
                    }),
                    utility:Create("ImageLabel", {
                        Name = "Cursor",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 18, 0, 18),
                        Position = UDim2.new(0, 0, 0, 0),
                        Image = "http://www.roblox.com/asset/?id=4805639000",
                        ZIndex = 12
                    })
                }),
                utility:Create("Frame", {
                    Name = "HueSlider",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.766, 0, 0.086, 0),
                    Size = UDim2.new(0, 28, 0, 114),
                    ZIndex = 11
                }, {
                    utility:Create("UICorner", {
                        CornerRadius = UDim.new(0, 4)
                    }),
                    utility:Create("UIGradient", {
                        Color = ColorSequence.new {
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)),
                            ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)),
                            ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)),
                            ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)),
                            ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))
                        },
                        Rotation = 270
                    }),
                    utility:Create("ImageLabel", {
                        Name = "Cursor",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 18, 0, 18),
                        Position = UDim2.new(0.5, 0, 0, 0),
                        Image = "http://www.roblox.com/asset/?id=4805639000",
                        ZIndex = 12
                    })
                }),
                utility:Create("TextBox", {
                    Name = "ColorValue",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.084, 0, 0.822, 0),
                    Size = UDim2.new(0, 151, 0, 20),
                    ZIndex = 11,
                    Font = Enum.Font.Arial,
                    Text = string.format("%d,%d,%d", math.floor(color3.r * 255), math.floor(color3.g * 255), math.floor(color3.b * 255)),
                    TextColor3 = themes.TextColor,
                    TextSize = 14
                }, {
                    utility:Create("UICorner", {
                        CornerRadius = UDim.new(0, 6)
                    }),
                    utility:Create("UIStroke", {
                        Color = themes.Element,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Thickness = 1,
                        Transparency = 0.9
                    })
                })
            })
            
            utility:DraggingEnabled(colorFrame)
            
            local canvas = colorFrame.ColorCanvas
            local hueSlider = colorFrame.HueSlider
            local colorValue = colorFrame.ColorValue
            local closeBtn = colorFrame.Close
            
            local hue, sat, brightness = Color3.toHSV(color3)
            
            local function updateColor(h, s, v)
                local newColor = Color3.fromHSV(h, s, v)
                preview.BackgroundColor3 = newColor
                canvas.ImageColor3 = Color3.fromHSV(h, 1, 1)
                colorValue.Text = string.format("%d,%d,%d", 
                    math.floor(newColor.r * 255), 
                    math.floor(newColor.g * 255), 
                    math.floor(newColor.b * 255))
                
                if callback then
                    callback(newColor, function(...)
                        -- Update function for color picker
                    end)
                end
            end
            
            closeBtn.MouseButton1Click:Connect(function()
                colorFrame:Destroy()
            end)
            
            canvas.MouseButton1Down:Connect(function()
                local connection
                connection = run.RenderStepped:Connect(function()
                    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                    local canvasPos = canvas.AbsolutePosition
                    local canvasSize = canvas.AbsoluteSize
                    
                    local x = math.clamp((mousePos.X - canvasPos.X) / canvasSize.X, 0, 1)
                    local y = math.clamp((mousePos.Y - canvasPos.Y) / canvasSize.Y, 0, 1)
                    
                    sat = x
                    brightness = 1 - y
                    
                    canvas.Cursor.Position = UDim2.new(x, 0, y, 0)
                    updateColor(hue, sat, brightness)
                end)
                
                utility:DraggingEnded(function()
                    if connection then
                        connection:Disconnect()
                    end
                end)
            end)
            
            hueSlider.MouseButton1Down:Connect(function()
                local connection
                connection = run.RenderStepped:Connect(function()
                    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                    local sliderPos = hueSlider.AbsolutePosition
                    local sliderSize = hueSlider.AbsoluteSize
                    
                    local y = math.clamp((mousePos.Y - sliderPos.Y) / sliderSize.Y, 0, 1)
                    
                    hue = 1 - y
                    
                    hueSlider.Cursor.Position = UDim2.new(0.5, 0, y, 0)
                    updateColor(hue, sat, brightness)
                end)
                
                utility:DraggingEnded(function()
                    if connection then
                        connection:Disconnect()
                    end
                end)
            end)
            
            colorValue.FocusLost:Connect(function()
                local r, g, b = colorValue.Text:match("(%d+),(%d+),(%d+)")
                if r and g and b then
                    r = math.clamp(tonumber(r), 0, 255)
                    g = math.clamp(tonumber(g), 0, 255)
                    b = math.clamp(tonumber(b), 0, 255)
                    
                    local newColor = Color3.fromRGB(r, g, b)
                    hue, sat, brightness = Color3.toHSV(newColor)
                    
                    preview.BackgroundColor3 = newColor
                    canvas.ImageColor3 = Color3.fromHSV(hue, 1, 1)
                    
                    if callback then
                        callback(newColor, function(...)
                            -- Update function for color picker
                        end)
                    end
                end
            end)
        end)
        
        return colorpicker
    end
    
    function section:addSlider(title, default, min, max, callback)
        -- Neverlose-style slider
        local slider = utility:Create("TextButton", {
            Name = "Slider",
            Parent = self.container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 26),
            ZIndex = 2,
            AutoButtonColor = false,
            Font = Enum.Font.SourceSans,
            Text = ""
        }, {
            utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.036, 0, 0.233, 0),
                Size = UDim2.new(0.5, 0, 0, 15),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("Frame", {
                Name = "SliderFrame",
                BackgroundColor3 = Color3.fromRGB(3, 30, 58),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.503, 0, 0.467, 0),
                Size = UDim2.new(0, 100, 0, 1)
            }, {
                utility:Create("Frame", {
                    Name = "SliderDot",
                    BackgroundColor3 = themes.Element,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, -8, 0),
                    Size = UDim2.new(0, 17, 0, 17)
                }, {
                    utility:Create("UICorner", {
                        CornerRadius = UDim.new(2, 0)
                    })
                })
            }),
            utility:Create("TextBox", {
                Name = "Value",
                BackgroundColor3 = themes.DarkContrast,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.909, 0, 0.267, 0),
                Size = UDim2.new(0, 23, 0, 13),
                Font = Enum.Font.SourceSans,
                Text = tostring(default and math.floor((default / max) * (max - min) + min) or min),
                TextColor3 = themes.TextColor,
                TextScaled = true,
                TextSize = 14,
                TextWrapped = true
            }, {
                utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 3)
                })
            })
        })
        
        table.insert(self.modules, slider)
        self:Resize()
        
        local valueBox = slider.Value
        local sliderFrame = slider.SliderFrame
        local sliderDot = sliderFrame.SliderDot
        
        local value = default or min
        
        local function setValue(val)
            value = math.clamp(val, min, max)
            local percent = (value - min) / (max - min)
            
            valueBox.Text = tostring(math.floor(value))
            utility:Tween(sliderDot, {
                Position = UDim2.new(percent, 0, -8, 0)
            }, 0.1)
            
            if callback then
                callback(value, function(...)
                    self:updateSlider(slider, ...)
                end)
            end
        end
        
        setValue(value)
        
        local dragging = false
        
        sliderDot.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                
                local connection
                connection = run.RenderStepped:Connect(function()
                    if not dragging then
                        if connection then
                            connection:Disconnect()
                        end
                        return
                    end
                    
                    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                    local framePos = sliderFrame.AbsolutePosition
                    local frameSize = sliderFrame.AbsoluteSize
                    
                    local percent = math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1)
                    local newValue = min + (max - min) * percent
                    
                    setValue(newValue)
                end)
                
                utility:DraggingEnded(function()
                    dragging = false
                    if connection then
                        connection:Disconnect()
                    end
                end)
            end
        end)
        
        valueBox.FocusLost:Connect(function()
            local num = tonumber(valueBox.Text)
            if num then
                setValue(num)
            else
                valueBox.Text = tostring(math.floor(value))
            end
        end)
        
        return slider
    end
    
    function section:addDropdown(title, list, callback)
        -- Neverlose-style dropdown
        local dropdown = utility:Create("TextButton", {
            Name = "Dropdown",
            Parent = self.container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 26),
            ZIndex = 2,
            AutoButtonColor = false,
            Font = Enum.Font.SourceSans,
            Text = ""
        }, {
            utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.036, 0, 0.233, 0),
                Size = UDim2.new(0.5, 0, 0, 15),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("Frame", {
                Name = "DropdownFrame",
                BackgroundColor3 = themes.DarkContrast,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.641, 0, 0.233, 0),
                Size = UDim2.new(0, 100, 0, 15)
            }, {
                utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 3)
                }),
                utility:Create("ImageLabel", {
                    Name = "Arrow",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.79, 0, -0.133, 0),
                    Size = UDim2.new(0, 18, 0, 18),
                    Image = "http://www.roblox.com/asset/?id=6034818372",
                    ImageColor3 = themes.Element
                }),
                utility:Create("TextLabel", {
                    Name = "ItemSelected",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.07, 0, 0.2, 0),
                    Size = UDim2.new(0.8, 0, 0, 9),
                    ZIndex = 3,
                    Font = Enum.Font.Gotham,
                    Text = "",
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })
        })
        
        table.insert(self.modules, dropdown)
        self:Resize()
        
        local frame = dropdown.DropdownFrame
        local arrow = frame.Arrow
        local selected = frame.ItemSelected
        
        local dropped = false
        local dropdownFrame
        
        local function createDropdownFrame()
            if dropdownFrame then
                dropdownFrame:Destroy()
            end
            
            dropdownFrame = utility:Create("Frame", {
                Name = "DropdownList",
                Parent = self.page.library.container,
                BackgroundColor3 = Color3.fromRGB(0, 18, 35),
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, -128, 0.5, 0),
                Size = UDim2.new(0, 257, 0, 130),
                ZIndex = 7,
                Visible = false
            }, {
                utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 3)
                }),
                utility:Create("ScrollingFrame", {
                    Name = "List",
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = themes.DarkContrast
                }, {
                    utility:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 3)
                    })
                })
            })
            
            return dropdownFrame
        end
        
        local function toggleDropdown()
            dropped = not dropped
            
            if dropped then
                dropdownFrame = createDropdownFrame()
                local listFrame = dropdownFrame.List
                
                for i, item in pairs(list or {}) do
                    local button = utility:Create("TextButton", {
                        Name = "Item",
                        Parent = listFrame,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -6, 0, 17),
                        Font = Enum.Font.Gotham,
                        Text = "- " .. item,
                        TextColor3 = themes.TextColor,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    button.MouseButton1Click:Connect(function()
                        selected.Text = item
                        if callback then
                            callback(item, function(...)
                                self:updateDropdown(dropdown, ...)
                            end)
                        end
                        toggleDropdown()
                    end)
                end
                
                listFrame.CanvasSize = UDim2.new(0, 0, 0, #(list or {}) * 20)
                dropdownFrame.Visible = true
                utility:Tween(arrow, {Rotation = 180}, 0.3)
                utility:Tween(dropdownFrame, {Size = UDim2.new(0, 257, 0, math.min(130, #(list or {}) * 20 + 10))}, 0.3)
            else
                if dropdownFrame then
                    utility:Tween(arrow, {Rotation = 0}, 0.3)
                    utility:Tween(dropdownFrame, {Size = UDim2.new(0, 257, 0, 0)}, 0.3)
                    wait(0.3)
                    dropdownFrame:Destroy()
                end
            end
        end
        
        dropdown.MouseButton1Click:Connect(function()
            toggleDropdown()
        end)
        
        return dropdown
    end
    
    -- class functions
    
    function library:SelectPage(page, toggle)
        if toggle and self.focusedPage == page then
            return
        end
        
        local button = page.button
        
        if toggle then
            -- Activate page
            button.BackgroundTransparency = 0.5
            button.Title.TextColor3 = themes.TextColor
            
            local focusedPage = self.focusedPage
            self.focusedPage = page
            
            if focusedPage then
                self:SelectPage(focusedPage)
            end
            
            -- Show page content
            wait(0.1)
            page.container.Visible = true
            
            if focusedPage then
                focusedPage.container.Visible = false
            end
            
            -- Show sections
            for i, section in pairs(page.sections) do
                utility:Tween(section.titleLabel, {TextTransparency = 0}, 0.1)
            end
            
            wait(0.05)
            page:Resize(true)
        else
            -- Deactivate page
            button.BackgroundTransparency = 1
            button.Title.TextColor3 = Color3.fromRGB(180, 180, 180)
            
            -- Hide sections
            for i, section in pairs(page.sections) do
                utility:Tween(section.titleLabel, {TextTransparency = 1}, 0.1)
            end
            
            wait(0.1)
            page.lastPosition = page.container.CanvasPosition.Y
            page:Resize()
        end
    end
    
    function page:Resize(scroll)
        local padding = 13
        local size = 0
        
        for i, section in pairs(self.sections) do
            size = size + section.mainFrame.AbsoluteSize.Y + padding
        end
        
        self.sectionsContainer.Size = UDim2.new(1, 0, 0, size)
        self.container.CanvasSize = UDim2.new(0, 0, 0, size)
        
        if scroll then
            utility:Tween(self.container, {CanvasPosition = Vector2.new(0, self.lastPosition or 0)}, 0.2)
        end
    end
    
    function section:Resize(smooth)
        if self.page.library.focusedPage ~= self.page then
            return
        end
        
        local padding = 8
        local contentHeight = 0
        
        -- Calculate the total height of all modules
        for i, module in pairs(self.modules) do
            contentHeight = contentHeight + module.AbsoluteSize.Y + padding
        end
        
        -- Add space for the title (which is at position -30)
        local totalHeight = math.max(30 + contentHeight, 60) -- Minimum height
        
        -- Set the container size
        self.container.Size = UDim2.new(1, -16, 0, contentHeight)
        
        -- Set the main frame size
        local mainFrameHeight = totalHeight + 8 -- Add some bottom padding
        
        if smooth then
            utility:Tween(self.mainFrame, {Size = UDim2.new(0, 285, 0, mainFrameHeight)}, 0.05)
        else
            self.mainFrame.Size = UDim2.new(0, 285, 0, mainFrameHeight)
            self.page:Resize()
        end
    end
    
    function section:getModule(info)
        if table.find(self.modules, info) then
            return info
        end
        
        for i, module in pairs(self.modules) do
            if (module:FindFirstChild("Title") or module:FindFirstChild("TextBox", true)) and 
               (module.Title and module.Title.Text == info or module:FindFirstChild("TextBox") and module.TextBox.Text == info) then
                return module
            end
        end
        
        error("No module found under "..tostring(info))
    end
    
    -- updates
    
    function section:updateButton(button, title)
        button = self:getModule(button)
        
        if button.Title then
            button.Title.Text = title
        end
    end
    
    function section:updateToggle(toggle, title, value)
        toggle = self:getModule(toggle)
        
        local dot = toggle.ToggleFrame.ToggleDot
        
        if title then
            toggle.Title.Text = title
        end
        
        if value ~= nil then
            if value then
                utility:Tween(dot, {
                    Position = UDim2.new(0, 20, -0.059, 0),
                    BackgroundColor3 = themes.Element
                }, 0.4)
            else
                utility:Tween(dot, {
                    Position = UDim2.new(0, 0, -0.059, 0),
                    BackgroundColor3 = Color3.fromRGB(74, 87, 97)
                }, 0.4)
            end
        end
    end
    
    function section:updateTextbox(textbox, title, value)
        textbox = self:getModule(textbox)
        
        if title then
            textbox.Title.Text = title
        end
        
        if value then
            textbox.TextBoxFrame.Textbox.Text = value
        end
    end
    
    function section:updateKeybind(keybind, title, key)
        keybind = self:getModule(keybind)
        
        local text = keybind.KeybindFrame.Text
        local bind = self.binds[keybind]
        
        if title then
            keybind.Title.Text = title
        end
        
        if bind and bind.connection then
            bind.connection = bind.connection:UnBind()
        end
            
        if key then
            if bind then
                bind.connection = utility:BindToKey(key, bind.callback)
            end
            text.Text = key.Name
        else
            text.Text = "None"
        end
    end
    
    function section:updateSlider(slider, title, value, min, max, lvalue)
        slider = self:getModule(slider)
        
        if title then
            slider.Title.Text = title
        end
        
        local valueBox = slider.Value
        local sliderFrame = slider.SliderFrame
        local sliderDot = sliderFrame.SliderDot
        
        if value then
            local clampedValue = math.clamp(value, min, max)
            local percent = (clampedValue - min) / (max - min)
            
            valueBox.Text = tostring(math.floor(clampedValue))
            utility:Tween(sliderDot, {
                Position = UDim2.new(percent, 0, -8, 0)
            }, 0.1)
            
            return clampedValue
        end
        
        return tonumber(valueBox.Text) or min
    end
    
    function section:updateDropdown(dropdown, title, list, callback)
        dropdown = self:getModule(dropdown)
        
        if title then
            dropdown.Title.Text = title
        end
        
        -- Note: Full dropdown refresh would require recreating the dropdown
        -- For simplicity, this just updates the selected text
        if type(list) == "string" then
            dropdown.DropdownFrame.ItemSelected.Text = list
        end
    end
end

print("Venyx with Neverlose UI loaded successfully!")
return library
