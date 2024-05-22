
--[[ 
TODO:

Load starting color channels from level string
Get list of objects and store color triggers appropriately
Handle color changes within level
]]--

local TICK_TIME = 30 -- ticks per second

local playerReference = physics.getPlayer()

local baseColor = {
  bg = loader.startColorBG,
  g = loader.startColorG
}

local colorTriggers = {}

ID_DEFS[29] = {}; ID_DEFS[30] = {};

if false then -- debug color trigger locations
  local SC = 1.5
  local sBase = tolua(game.level.newSprite())
  sBase.beginFill(0xFFFF0000);sBase.drawCircle(0*SC,-5.8*SC,5*SC);
  sBase.beginFill(0xFF00FF00);sBase.drawCircle(5*SC,3*SC,5*SC);
  sBase.beginFill(0xFF0000FF);sBase.drawCircle(-5*SC,3*SC,5*SC);
  local s29 = sBase.clone()
  s29.addText("BG",-8*SC,-5*SC,0xFFFFFFFF,8*SC)
  ID_DEFS[29].sprite = s29
  local s30 = sBase.clone()
  s30.addText("G",-4*SC,-5*SC,0xFFFFFFFF,8*SC)
  ID_DEFS[30].sprite = s30
end

local ground_Color
local ground_Layer
local upd_Ground_Color
local updateGround
local forceColorUpdate = false
do -- the Ground
  ground_Color = tolua(game.level.newArtLayer(0))
  ground_Layer = tolua(game.level.newArtLayer(0))
  ground_Color.layerNum = 14
  ground_Layer.layerNum = 15

  local function GDtoPR3y(y)
    return y * -(40/30) * SCALE
  end

  local function PR3toGDy(x,y)
    return y * -(30/40) / SCALE
  end

  -- Figure everything out
  local twoGround = { -- true: 2 grounds, false: 1 ground
    cube = false,
    ship = true,
    ball = true,
  }

  local groundOff = {
    ship = 150,
    ball = 120,
  }

  local groundSprite = tolua(game.level.newSprite())
  do
    groundSprite.beginGradientFill(
      toarray{0xC0000000,0x00000000},
      toarray{0,255},
      toobject{
        rotation = 90, height = 60,
      }
    ) -- Vertical grad.
    groundSprite.drawRect(0,0,120,80)
    groundSprite.endFill()
    -- Horizontal gradient
    groundSprite.beginGradientFill(
      toarray{0x20FFFFFF,0xFFFFFFFF,0x20FFFFFF},
      toarray{0,127,255},
      toobject{
        width = 120,
        spreadMethod = "repeat",
      }
    )
    groundSprite.drawRect(0,-1,120,3)
    groundSprite.endFill()
  end

  local lastY = 700
  local lastY2 = -700
  local groundClear = tolua(ground_Layer.clear)
  local groundDraw = tolua(ground_Layer.drawSprite)
  local lastMode = "none"
  local floor = math.floor

  updateGround = function()
    local mode = playerReference.mode
    if mode ~= lastMode then
      lastY = math.huge;lastY2 = math.huge
    end
    if twoGround[mode] then
      local newY1 = GDtoPR3y(0 - groundOff[mode]) + 240
      local newY2 = GDtoPR3y(0 + groundOff[mode]) + 240
      if newY ~= lastY or newY2 ~= lastY2 then
        forceColorUpdate = true
        lastY = newY1
        lastY2 = newY2
        groundClear()
        groundDraw(groundSprite,-338*SCALE + 338,newY1,5.626 * SCALE,1 * SCALE)
        groundDraw(groundSprite,-338*SCALE + 338,newY2,5.626 * SCALE,-1 * SCALE)
      end
    else
      local camy = playerReference.realCamY
      lastY2 = -math.huge
      local newY = GDtoPR3y(0 - camy) -- Calculate Y relative to camera
      newY = newY + 240 -- Offset from center
      if floor(newY*10 + 0.5) ~= floor(lastY*10 + 0.5) then
        lastY = newY
        -- redraw
        forceColorUpdate = true
        groundClear()
        groundDraw(groundSprite,-338*SCALE + 338,newY,5.626 * SCALE,1 * SCALE)
      end
    end
  end

  local bmap = tolua(game.level.newStamp(1,1))
  local bmapspix = tolua(bmap.setPixel)
  local colReset = tolua(ground_Color.clear)
  local colDraw = tolua(ground_Color.drawStamp)

  upd_Ground_Color = function(color)
    bmapspix(0,0,0xFF000000 + color)
    if twoGround[playerReference.mode] then -- draw two grounds
      local x1,y1,x2,y2 = -338*SCALE + 338, lastY, 338*SCALE + 338, 240*SCALE + 240;
      colReset()
      if y1 <= y2 then
        colDraw(bmap,x1,y1,x2-x1,y2-y1)
      end
      y1 = lastY2; y2 = -240*SCALE + 240
      if y1 >= y2 then
        colDraw(bmap,x1,y1,x2-x1,y2-y1)
      end
    else -- draw one ground
      local x1,y1,x2,y2 = -338*SCALE + 338, lastY, 338*SCALE + 338, 240*SCALE + 240;
      colReset()
      if y1 <= y2 then
        colDraw(bmap,x1,y1,x2-x1,y2-y1)
      end
    end
  end
end

local setColor = {

}

local resetColors

do
    --loader.startColorBG = {40, 62, 255}
    --loader.startColorG = {0, 19, 200}
  local lastC = 0
  local drawStamp = tolua(loader.bg_layer.drawStamp)
  local floor = math.floor
  local r_stamp = tolua(game.level.newStamp(1,1))
  local spix = tolua(r_stamp.setPixel)
  setColor.bg = function(red,green,blue)
    local c = 0xFF000000 + (0x10000 * floor(red)) + (0x100 * floor(green)) + floor(blue)
    if c ~= lastC then
      lastC = c
      spix(0,0,c)
      drawStamp(r_stamp,-338*SCALE + 338,-240*SCALE + 240,675*SCALE,480*SCALE)
    end
  end

  local lastCG = 0

  setColor.g = function(red,green,blue)
    local c = 0xFF000000 + (0x10000 * floor(red)) + (0x100 * floor(green)) + floor(blue)
    if c ~= lastCG or forceColorUpdate then
      forceColorUpdate = false
      lastCG = c
      upd_Ground_Color(c)
    end
  end

  resetColors = function()
    setColor.bg(loader.startColorBG[1],loader.startColorBG[2],loader.startColorBG[3])
    setColor.g(loader.startColorG[1],loader.startColorG[2],loader.startColorG[3])
    baseColor = {
      bg = loader.startColorBG,
      g = loader.startColorG
    }
  end
  resetColors()

end

local colType = {
  [29] = "bg",
  [30] = "g", -- ground
}

do

  for i in pairs(colType) do
    colorTriggers[colType[i]] = {}
  end

  -- Grab objects and store color triggers
  do

    local function findTriggers(objs,wait)
      local num = 0
      for i=1,#objs do
        local obj = objs[i]
        if colType[obj.id] then -- 29: bg, 30: ground
          local ct = colorTriggers[colType[obj.id]]
          ct[#ct + 1] = obj
          num = num + 1
--[[
          local str = ""
          for i in pairs(obj) do
            str = str .. i ..": ".. obj[i] ..", \n"
          end
          player.chat(str)
]]--
        end

        if i%500 == 0 then
          wait()
        end
      end
      for i in pairs(colorTriggers) do
        table.sort(colorTriggers[i],function(o1,o2) return o1.x < o2.x end)
      end
      player.chat("Located ".. num .." color triggers")
    end

    loader.requestObjects(findTriggers)

  end

end

local function lerp(a,b,m)
  return b*m + (1-m)*a
end

local alive = true
local frame = 0
local nextTrigger = { -- Possible next trigger
  bg = 1,
  g = 1,
}

local activeTriggers = {
  bg = {},
  g = {},
}

local function reset()
  nextTrigger = { -- Possible next trigger
    bg = 1,
    g = 1,
  }
  activeTriggers = {
    bg = {},
    g = {},
  }
  resetColors()
end

local colorHandle = function()
  frame = frame + 1
  local p = playerReference
  updateGround()
  if not alive and p.run then
    alive = p.run
    reset()
  else -- run shit
    alive = p.run
    local x = p.x
    for i in pairs(nextTrigger) do -- find new triggers
      local index = nextTrigger[i]
      local at = activeTriggers[i]
      while true do
        local ctix = colorTriggers[i][index]
        if ctix and ctix.x < x then
          at[#at + 1] = ctix
          ctix.startFrame = frame
          nextTrigger[i] = index + 1
          index = index + 1
        else
          break
        end
      end
    end
    for i in pairs(activeTriggers) do -- handle old ones
      local at = activeTriggers[i]
      local cs = baseColor[i]
      local c = {cs[1],cs[2],cs[3]}
      local removeAt = 0
      for j=1,#at do
        local trigger = at[j]
        local dur = (frame - trigger.startFrame) / ((trigger.duration+0.000001) * TICK_TIME) -- adding tiny bit of time just in case a duration is 0
        if dur > 1 then dur = 1 end
        c[1],c[2],c[3] = lerp(c[1],trigger.red,dur),lerp(c[2],trigger.green,dur),lerp(c[3],trigger.blue,dur)
        if dur == 1 then
          removeAt = j
        end
      end
      if removeAt > 0 then
        local t = table.remove(at,removeAt)
        for j = removeAt-1,1,-1 do
          table.remove(at,j)
        end
        baseColor[i] = {t.red,t.green,t.blue}
      end
      setColor[i](c[1],c[2],c[3])
    end
  end
end

loader.attachSystem(colorHandle,"color")



player.teleportto(1,0)
