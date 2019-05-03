local font = require "libs.fonts"
local UI = object:extend()

	function UI:init(x, y, childs)
		self.x = x or 0
		self.y = y or 0
		self.hidden = false
		self.childs = childs or { }
		assert(type(self.childs) == "table", "Parameter 'childs' must be a table.")
		for i = 1, #self.childs do
			assert(childs[i] and childs[i].isInstanceOf(UI), "Only UI elements can be a part of UI.")
		end
	end

	function UI:on(event, callback)
		assert(type(event) == "string", "Event name must be string")
		assert(type(callback) == "function", "Callback must be a function")

		if type(self[event]) == "function" then
			local old = self[event]
			self[event] = function (...)
				old(...)
				callback(...)
			end
		end
		return self
	end

	function UI:hide()
		self.hidden = true
		return self
	end

	function UI:show()
		self.hidden = false
		return self
	end

	function UI:toggle()
		self.hidden = not self.hidden
		return self
	end

	function UI:edit(callback)
		if type(callback) == "function" then
			callback(self)
		elseif type(callback) == "table" then
			for k, v in pairs(callback) do
				self[k] = v
			end
		end
		return self
	end


	UI.Image = UI:extend()
	function UI.Image:init(file, x, y)
		self:super(x, y)
		self.resource = file and image.Load(file)
	end

	function UI.Image:draw()
		image.draw(self.resource, self.x, self.y)
	end


	UI.Video = UI:extend()
	function UI.Video:init(file, x, y, stretch)
		self:super(x, y)
		self.video = videos.load(file)
		self.stretch = stretch or false
	end

	function UI.Video:draw()
		videos.draw(self.video, self.x, self.y, self.stretch)
	end

	function UI.Video:play()
		self.video.resource:play()
		return self
	end

	function UI.Video:stop()
		self.video.resource:pause()
		self.video.resource:rewind()
		return self
	end

	function UI.Video:pause()
		self.video.resource:pause()
		return self
	end

	function UI.Video:hide()
		self.video.resource:pause()
		self.hidden = true
		return self
	end

	function UI.Video:show()
		self.video.resource:play()
		self.hidden = false
		return self
	end


	UI.Animation = UI:extend()
	function UI.Animation:init(file, x, y, w, h, row, col, frames, wait, looped)
		self:super(x, y)
		self.resource = file and image.Load(file, {w = w or 1, h = h or 1, x = row or 1, y = col or 1})
		self.frame = 1
		self.max_frames = frames
		self.wait = 0
		self.max_wait = wait or 1
		self.looped = looped or false
	end

	function UI.Animation:update(dt)
		if self.wait < self.max_wait then
			self.wait = self.wait + 1
		else
			self.wait = 0
			if self.frame < self.max_frames then
				self.frame = self.frame + 1
			elseif self.looped then
				self.frame = 1
			end
		end
	end

	function UI.Animation:draw()
		image.draw(self.resource, self.frame, self.x, self.y)
	end


	UI.Text = UI:extend()
	function UI.Text:init(text, fnt, x, y, color, align)
		self:super(x, y)
		self.text = text or ""
		self.align = align
		self.font = fnt or font.list.default
		self.color = color or { 1, 1, 1, 1 }
	end

	function UI.Text:draw()
		font.print(self.text, self.x, self.y, self.align, self.font, nil, nil, self.color)
	end

	function UI.Text:getWidth()
		return self.font:getWidth(self.text)
	end

	function UI.Text:getHeight()
		return self.font:getHeight(self.text)
	end


	UI.Button = UI:extend()
	function UI.Button:init(text, x, y, w, h, ox, oy, bg, use_mouse)
		self:super(x, y)
		self.ox = ox or 0
		self.oy = oy or 0
		self.text = type(text) == "string" and UI.Text:new(text, self.x + self.ox, self.y + self.oy) or text
		self.w = w or (self.text and self.text:getWidth()) or 1
		self.h = h or (self.text and self.text:getHeight()) or 1
		self.background = type(bg) == "string" and image.Load(bg) or bg
		self.use_mouse = use_mouse and true or false
		self.hover = false
		self.clicked = false
	end

	function UI.Button:mousemoved(x, y, dx, dy)
		if not self.use_mouse then return end
		local mx = x + dx - self.ox
		local my = y + dy - self.oy
		self.hover = mx > self.x and mx < self.x + self.w and my > self.y and my < self.y + self.h
		self.clicked = self.clicked and self.hover
	end

	function UI.Button:update(dt)
		-- hook
	end

	function UI.Button:click(x, y, button)
		-- hook
	end

	function UI.Button:setText(newText)
		if type(text) == "string" then
			self.text.text = newText
		else
			self.text = newText
		end
		self.w = self.text:getWidth()
		self.h = self.text:getHeight()
	end

	function UI.Button:mousepressed(x, y, button, istouch, presses)
		self.clicked = false
		if self.use_mouse and self.hover then
			self:click(x, y, button)
			self.clicked = true
		end
	end

	function UI.Button:draw()
		if self.background then
			image.draw(self.background, 0, self.x, self.y)
		end

		if self.text then
			self.text.x = self.x + self.ox
			self.text.y = self.y + self.oy
			self.text:draw()
		end
	end


	UI.List = UI:extend()
	function UI.List:init(x, y, childs)
		self:super(x, y, childs)
		self.cursor = 1
		self.size = #childs
 	end

 	function UI.List:keypressed(key)
 		local controls = settings.global.controls
 		for i = 1, #controls do
 			if key == controls[i].up then
 				local old = self.childs[self.cursor]
 				self.cursor = self.cursor > 1 and self.cursor - 1 or self.size
 				return self:change(self.childs[self.cursor], old)

 			elseif key == controls[i].down then
 				local old = self.childs[self.cursor]
 				self.cursor = self.cursor < self.size and self.cursor + 1 or 1
 				return self:change(self.childs[self.cursor], old)

 			elseif key == controls[i].attack and self.childs[self.cursor].click then
 				return self.childs[self.cursor]:click(nil, nil, 1)
 			end
 		end
 	end

 	function UI.List:change(new, old)
 		old.hover = false
 		new.hover = true
 	end

 	function UI.List:update(dt)
 		self.childs[self.cursor].hover = true
 	end

return UI