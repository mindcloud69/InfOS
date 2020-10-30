comp = require("component");
color = {
    red = 0xFF0000, green = 0x00FF00, blue = 0x0000FF,
    purple = 0x5500FF, cyan = 0x00A6FF, lightGreen = 0x00CC00,
    lightGray = 0x272c2e, darkGray = 0x121010, white = 0x000000
}
local graphics = {}

function pixel(GPU, x, y, color)
    local screenY = math.ceil(y/2); local baseChar, baseForeground, baseBackground = GPU.get(x, screenY)
    GPU.setForeground(color)
    GPU.setBackground(baseBackground)
    if y % 2 == 1 then --Upper half of pixel
        GPU.set(x, screenY, "▀");
    else --Lower half of pixel
        GPU.set(x, screenY, "▄");
    end
end


function graphics.rect(GPU, x, y, w, h, color)
        local hLeft = h
        if x > 0 and y > 0 then
        if y % 2 == 0 then
            for i = x, x+w-1 do
                pixel(GPU, i, y, color)
            end
            hLeft = hLeft - 1
        end
        GPU.setBackground(color)
        GPU.setForeground(color)
        if hLeft % 2 == 1 then
            GPU.fill(x, math.ceil(y/2)+(h-hLeft), w, (hLeft-1)/2, "█")
            for j = x, x+w-1 do
                pixel(GPU, j, y+h-1, color)
            end
        else
            GPU.fill(x, math.ceil(y/2)+(h-hLeft), w, hLeft/2, "█")
        end
    end
end

function graphics.text(GPU, x, y, color, string)
    if y % 2 == 0 then error("Text position must be odd on y axis") end
    local screenY = math.ceil(y/2)
    GPU.setForeground(color);
    for i = 0, #string-1 do
        local baseChar, baseForeground, baseBackground = GPU.get(x+i, screenY)
        GPU.setBackground(baseBackground)
        GPU.fill(x+i, screenY, 1, 1, string:sub(i+1, i+1))
    end
end

function graphics.centeredText(GPU, x, y, color, string)
    if y % 2 == 0 then error("Text position must be odd on y axis") end
    local screenY = math.ceil(y/2)
    local oldForeground = GPU.setForeground(color); local oldBackground = GPU.getBackground()
    for i = 0, #string-1 do
        local baseChar, baseForeground, baseBackground = GPU.get(x+i-math.ceil(#string/2)+1, screenY)
        GPU.setBackground(baseBackground)
        GPU.fill(x+i-math.ceil(#string/2)+1, screenY, 1, 1, string:sub(i+1, i+1))
    end
    GPU.setBackground(oldBackground); GPU.setForeground(oldForeground)
end

function graphics.border(GPU, w, h, color)
    draw.rect(GPU, 1, 1, w, 1, color)
    draw.rect(GPU, 1, h*2, w, 1, color)
    draw.rect(GPU, 1, 1, 1, h*2, color)
    draw.rect(GPU, w, 1, 1, h*2, color)
end

function copyWindow(GPU, x, y, page, destination)
    destination = 0 or destination
    GPU.bitblt(destination, x, math.ceil(y/2), 160, 46, page, 1, 1)
end
windows = {}
function graphics.update()
    local function redraw()
        for window, params in pairs(windows) do
            copyWindow(params.GPU, params.x, params.y, params.page)
        end
    end
    for name, params in pairs(windows) do
        params.GPU.setActiveBuffer(params.page)
        params.update(params.GPU, name, params.address)
        params.GPU.setActiveBuffer(0)
    end
    redraw()
    os.sleep()
end

return graphics