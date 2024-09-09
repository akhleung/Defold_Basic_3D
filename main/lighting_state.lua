local M = {}

local light_position = {}

local light_radii = {}

local light_color = {}

local num_lights = 0

local ambient_color = vmath.vector4()

local sun_direction = vmath.vector4()

local sun_color = vmath.vector4();

function M.add_light(position, radii, color)
    table.insert(light_position, position)
    table.insert(light_radii, radii)
    table.insert(light_color, color)
    num_lights = #light_position
    return num_lights
end

function M.get_light(id)
    return light_position[id], light_radii[id], light_color[id]
end

function M.set_light_position(id, position)
    light_position[id] = position
end

function M.set_light_radii(id, radii)
    light_radii[id] = radii
end

function M.set_light_color(id, color)
    light_color[id] = color
end

function M.get_num_lights()
    return num_lights
end

function M.set_ambient_color(ambient)
    ambient_color = ambient
end

function M.get_ambient_color()
    return ambient_color
end

function M.get_lights()
    return light_position, light_radii, light_color
end

function M.get_sun_direction()
    return sun_direction
end

function M.set_sun_direction(sun_dir)
    sun_direction = sun_dir
end

function M.get_sun_color()
    return sun_color
end

function M.set_sun_color(sun_col)
    sun_color = sun_col
end

return M
