ant = { x = 1.0, y = 1.0, alpha = 0.0 }
light = { x = 300, y = 300 }

ant_radius = 20

xres = love.graphics.getWidth()
yres = love.graphics.getHeight()

rocks = {}

function dist(a, b)
	return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

function sarea(a, b, c)
	return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
end

function intersec(a, b, c, d)
	return sarea(a,b,c) * sarea(a,b,d) <= 0 and sarea(c,d,a) * sarea(c,d,b) <= 0;
end

function place_rocks()
	local file = io.open("rocks", "r")
	for line in file:lines() do
		local v = string.gmatch(line, "%w+")
		rocks[#rocks + 1] = ({ x1 = v(1), y1 = v(2), x2 = v(3), y2 = v(4) })
	end
end

function light_intensity(x, y)
	local shadow_col = 0
	local intense = dist(light, { x = x, y = y })
	local is_lightened = true
	for k, v in pairs(rocks) do
		local a = { x = x, y = y }
		local b = { x = light.x, y = light.y }
		local c = { x = v.x1, y = v.y1 }
		local d = { x = v.x2, y = v.y2 }

	--	if intersec(a, b, c, d) and dist(a, c) < shadow_dist
	--		and dist(a, d) < shadow_dist then
		if intersec(a, b, c, d) then
			local d = math.abs(sarea(a, c, d)) / (2 * dist(c, d))
			if d < 70 then
				if d > 5 then
					is_lightened = false
					shadow_col = 0
				else
					is_lightened = false
					shadow_col = 255
				end
			end

			--if shadow_col < 10 then
			--	shadow_col = 255
			--end
			--shadow_col = 0
		end
	end

	if not is_lightened then
		return shadow_col / 255
	else
		return math.max(0, 255 - intense / 2) / 255
	end
end

function draw_light(light)
	grain = 10
	shadow_dist = 250

	for i = 0, xres / grain do
		for j = 0, yres / grain do
			x = grain * i
			y = grain * j

			local shadow_col = light_intensity(x, y)
			love.graphics.setColor(shadow_col, shadow_col, shadow_col)
			love.graphics.rectangle("fill", i * grain, j * grain, grain, grain)
		end
	end
end

function draw_ant(ant)
	love.graphics.setColor(222/255, 222/255, 222/255)
	love.graphics.circle("fill", ant.x, ant.y, ant_radius, 8)
	love.graphics.setColor(0, 0, 0)
	love.graphics.circle("fill", ant.x, ant.y, ant_radius * 0.9, 8)

	vec_len = 15
	vec_x = math.cos(ant.alpha) * vec_len
	vec_y = math.sin(ant.alpha) * vec_len
	love.graphics.setColor(200/255, 1/255, 1/255)
	love.graphics.circle("fill", ant.x - vec_x, ant.y - vec_y, 4, 8)

	love.graphics.setColor(255/255, 30/255, 30/255)
	font = love.graphics.newFont("fonts/Kroftsmann.ttf", 40)
	love.graphics.setFont(font)
	--text = love.graphics.newText( font, "123")
	love.graphics.print(math.floor(100 * light_intensity(ant.x, ant.y)), ant.x, ant.y + 20)
	-- text:add("123", ant.x, ant.y) --, sx, sy, ox, oy, kx, ky )
end

function love.update(dt)
	vec_len = 5.0
	vec_x = math.cos(ant.alpha) * vec_len
	vec_y = math.sin(ant.alpha) * vec_len

	if love.keyboard.isDown("right") then
		ant.alpha = ant.alpha + 5 * dt
	end
	if love.keyboard.isDown("left") then
		ant.alpha = ant.alpha - 5 * dt
	end

	ant.alpha = ant.alpha % (2 * math.pi)
	if love.keyboard.isDown("down") then
		ant.x = ant.x + vec_x, ant_radius
		ant.y = ant.y + vec_y
	end
	if love.keyboard.isDown("up") then
		ant.x = ant.x - vec_x
		ant.y = ant.y - vec_y
	end


	ant.y = math.min(math.max(ant.y, ant_radius), yres - ant_radius)
	ant.x = math.min(math.max(ant.x, ant_radius), xres - ant_radius)
end

function love.draw()
	draw_light(light)
	draw_ant(ant)
end

function love.load()
	place_rocks()
end
