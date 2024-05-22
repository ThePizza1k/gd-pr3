--[[ 
TODO:

Load starting gamemode and speed from level settings

Handle physics for:
 Soon:
  Mini size
 Later:
  Other gamemodes (UFO, wave)
 Eventually:
  Slopes (oh no)
 
]]--

function math.lerp(a,b,m)
  return m*b + (1-m)*a
end

local maxX

physics = {}

local AttemptNumber = 1
local countAttempt
do
  local spr = tolua(game.level.newSprite())
  local lay = tolua(game.level.newArtLayer(1))
  lay.layerNum = 100
  countAttempt = function()
    lay.clear()
    spr.clear()
    spr.addText("Attempt ".. AttemptNumber,120*SCALE,-300*SCALE,0xFFFFFFFF,48*SCALE)
    lay.drawSprite(spr)
  end
end

local collide = {}

do
  local function AABB(h1,h2)
    return (h1.x1 < h2.x2) and (h1.x2 > h2.x1) and (h1.y1 < h2.y2) and (h1.y2 > h2.y1)
  end

  local sqrt = math.sqrt
  local function circle(h1,h2)
    local d = math.sqrt((h2.x - h1.x)^2 + (h2.y - h1.y)^2)
    return d < (h1.r + h2.r)
  end

  local function lol() -- unimplemented hitbox shit, so no collision i guess
    return false
  end

  collide.AABB = AABB
  collide.circle = circle
  collide.lol = lol
end

local pCam = {x = 0, y = 0}
local function setCameraCenter(x,y)
  local tx,ty = x * (1/30) * SCALE,y * -(1/30) * SCALE
  pCam.x = tx - 8.4375
  pCam.y = ty - 6
end

local spriteData = {
  cube = (function()
    local s = tolua(game.level.newSprite())
    s.beginFill(0xFFFF6060)
    s.lineStyle(0xFF6060FF,8,toobject{
      pixelHinting = true,
      caps = "square",
      joints = "miter",
    })
    s.drawRect(-15,-15,30,30)
    s.endFill()
    s.lineStyle(0xFF000000,2,toobject{
      pixelHinting = true,
      caps = "square",
      joints = "miter",
    })
    s.drawRect(-19,-19,38,38)
    return s
  end)(),
}

do -- more sprite data
  spriteData.ship = (function()
    local s = tolua(game.level.newSprite())
    local cubeCopy = tolua(spriteData.cube.clone())
    cubeCopy.scaleX = 0.545; cubeCopy.scaleY = 0.545;
    cubeCopy.x = 2
    cubeCopy.y = -7
    s.addChild(cubeCopy)
    local shipOverlay = tolua(game.level.newSprite())
    local mt = tolua(shipOverlay.moveTo); local lt = tolua(shipOverlay.lineTo);
    shipOverlay.lineStyle(0xFF000000,2);
    shipOverlay.beginFill(0xFF7DFF00);
    mt(55,43);lt(80,36);lt(80,24);lt(55,16);lt(55,43);
    mt(27,23);lt(27,43);lt(54,43);lt(54,23);lt(27,23);
    mt(10,15);lt(10,46);lt(26,40);lt(26,20);lt(10,15);
    mt(01,23);lt(1,38);lt(10,38);lt(10,23);lt(01,23);
    shipOverlay.beginFill(0xFF00FFFF);
    mt(18,2);lt(18,24);lt(68,24);lt(68,18);lt(24,14);lt(24,2);lt(18,2);
    shipOverlay.x = -25; shipOverlay.y = -11
    shipOverlay.scaleX = 0.623; shipOverlay.scaleY = 0.623
    s.addChild(shipOverlay)
    return s
  end)()

  spriteData.ball = (function()
    local s = tolua(game.level.newSprite())
    local lt = tolua(s.lineTo);
    s.moveTo(21,0);
    s.lineStyle(0xFF000000,2); s.beginFill(0xFF6060FF)
    for theta = 0,360,40 do
      local x,y = 21*math.cos(math.rad(theta)),21*math.sin(math.rad(theta))
      lt(x,y); lt(x*0.8,y*0.8);
    end
    s.endFill()
    s.moveTo(12,0);
    s.lineStyle(0xFF000000,1); s.beginFill(0xFFFF6060)
    for theta = 0,360,40 do
      local x,y = 12*math.cos(math.rad(theta)),12*math.sin(math.rad(theta))
      lt(x,y); lt(x*0.75,y*0.75);
    end
    s.endFill()
    return s
  end)()
end


local hitboxData = {
  cube = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, r = 15},
  ship = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, r = 15}, -- lol
  ball = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, r = 15}, -- lol 2
}

local Collision_Array = {}


do -- Get list of objects, store collidables appropriately
  local c = Collision_Array
  local function addObjAt(obj,x,y)
    if not c[x] then c[x] = {} end
    if not c[x][y] then c[x][y] = {} end
    c[x][y][#(c[x][y]) + 1] = obj
  end

  local function transform(obj)
    local hitbase = ID_DEFS[obj.id].hb
    if (not hitbase.type) or (hitbase.type == "AABB") then
      local hb = {t = "AABB"} -- t relates to hitbox shape, not what it does. at least here.
      local x1,y1,x2,y2 = hitbase.x1,hitbase.y1,hitbase.x2,hitbase.y2
      if obj.scale then
        local s = obj.scale
        x1,y1,x2,y2 = x1*s,y1*s,x2*s,y2*s
      end
      local x,y = obj.x, obj.y
      if obj.flipX then x1,x2 = -x2,-x1 end
      if obj.flipY then y1,y2 = -y2,-y1 end
      -- rotation handle
      if obj.rotation and obj.rotation ~= 0 then
        if obj.rotation%360 == 90 then
          x1,y1,x2,y2 = y1,-x2,y2,-x1
        elseif obj.rotation%360 == 180 then
          x1,y1,x2,y2 = -x2,-y2,-x1,-y1
        elseif obj.rotation%360 == 270 then -- I'm hardcoding this because it's easier.
          x1,y1,x2,y2 = -y2,x1,-y1,x2
        else -- lmao not dealing with that
          hb.t = "lol" -- In these cases, x1,y1,x2,y2 will remain as a bounding box.
        end
      end
      if hb.t == "AABB" then
        hb = {t = hb.t, x1 = x+x1, y1 = y+y1, x2 = x+x2, y2 = y+y2, type = hitbase.t}
      end
      if hitbase.f then hb.f = hitbase.f end
      obj.hitbox = hb
    elseif hitbase.type == "circle" then
      local hb = {type = hitbase.t, t = "circle", r = hitbase.r, x = obj.x, y = obj.y}
      if obj.scale then hb.r = hb.r * obj.scale end
      if hitbase.f then hb.f = hitbase.f end
      hb.x1 = hb.x-hb.r; hb.x2 = hb.x+hb.r; hb.y1 = hb.y-hb.r; hb.y2 = hb.y+hb.r; -- generate bounding box
      obj.hitbox = hb
    else
      -- uhhhhhh idk
      obj.hitbox = {t = "lol"}
    end
  end

  local floor = math.floor
  local function convertCoords(x,y)
    return floor(x/30),floor(y/30)
  end

  local debugHitboxes = {debug = false}
  if debugHitboxes.debug then
    debugHitboxes.layer = tolua(game.level.newArtLayer(1))
    debugHitboxes.layer.layerNum = 1000
    local s = {AABB = {}, circle = {}}
    s.AABB.kill = (function()
      local spr = tolua(game.level.newSprite())
      spr.lineStyle(0xFFFF0000, 2, toobject{
        scaleMode = "none",
        joints = "miter",
        pixelHinting = true,
        caps = "square",
      })
      spr.drawRect(0,0,2,2)
      spr.endFill()
      return spr
    end)()
    debugHitboxes.layer.drawSprite(s.AABB.kill,-600,400,50,50)
    s.AABB.block = (function()
      local spr = tolua(game.level.newSprite())
      spr.lineStyle(0xFF0000FF, 2, toobject{
        scaleMode = "none",
        joints = "miter",
        pixelHinting = true,
        caps = "square",
      })
      spr.drawRect(0,0,2,2)
      spr.endFill()
      return spr
    end)()
    debugHitboxes.layer.drawSprite(s.AABB.block,-400,400,50,50)
    s.AABB.special = (function()
      local spr = tolua(game.level.newSprite())
      spr.lineStyle(0xFF00FF00, 2, toobject{
        scaleMode = "none",
        joints = "miter",
        pixelHinting = true,
        caps = "square",
      })
      spr.drawRect(0,0,2,2)
      spr.endFill()
      return spr
    end)()
    debugHitboxes.layer.drawSprite(s.AABB.special,-200,400,50,50)
    s.circle.kill = (function()
      local spr = tolua(game.level.newSprite())
      spr.lineStyle(0xFFFF0000, 2, toobject{
        scaleMode = "none",
        joints = "miter",
        pixelHinting = true,
        caps = "square",
      })
      spr.drawCircle(1,1,1)
      spr.endFill()
      return spr
    end)()
    debugHitboxes.layer.drawSprite(s.circle.kill,0,400,50,50)
    debugHitboxes.sprites = s
  end

  loader.requestObjects(function(objs,wait)
    maxX = loader.getMaxX()
    local colArr = {}
    for i=1,#objs do
      local obj = objs[i]
      if ID_DEFS[obj.id].hb then
        colArr[#colArr+1] = obj
        transform(obj)
      end
      if i%300 == 0 then wait() end
    end
    player.chat("There are ".. #colArr .." objects with collision")
    -- arrayify the collidables. Actually a nightmare.
    for i=1,#colArr do
      local obj = colArr[i]
      local hb = obj.hitbox
      if hb.t ~= "lol" then
        local x1,y1 = convertCoords(hb.x1,hb.y1)
        local x2,y2 = convertCoords(hb.x2,hb.y2)
        for x = x1,x2,1 do
          for y = y1,y2,1 do
            addObjAt(obj,x,y)
          end
        end
      end
      if i%100 == 0 then wait() end
    end

    if debugHitboxes.debug then
      local dS = tolua(debugHitboxes.layer.drawSprite)
      local sprites = debugHitboxes.sprites
      local nL = 0
      for i=1,#colArr do
        local hb = colArr[i].hitbox
        if hb.t ~= "lol" then
          if sprites[hb.t][hb.type] then
            nL = nL + 1
            dS(sprites[hb.t][hb.type],hb.x1 * (40/30) * SCALE,hb.y1 * -(40/30) * SCALE,(hb.x2-hb.x1) * (20/30) * SCALE,(hb.y2-hb.y1) * -(20/30) * SCALE)
          else
            player.chat("ERROR: sprites[".. hb.t .."][" .. hb.type .."]")
          end
        end
        if i%50 == 0 then
          player.chat("Tried to draw ".. i .."/".. #colArr .. " hitboxes (".. i-nL .. " invalid)")
          wait() 
        end

      end
    end
    
  end)
end

local PHYS_TICKS = 8 -- ticks per frame (30 fps)

local dt = 1/(PHYS_TICKS*30)

-- Reference lists
local speeds = {
  [0] = 251.16,
  [1] = 311.58,
  [2] = 387.42,
  [3] = 468,
  [4] = 576,
}


-- Player vars

local P = {
  speed = 1,
  mode = "cube",
  vy = 0,
  x = 0,
  y = 15,
  target_rot = 0,
  rot = 0,
  run = true,
  respawn = 0,
  camY = 105,
  realCamY = 105,
  pressed = false,
  lastPressed = false,
  action = false,
  gravity = 1,
  win = false,
  onGround = true,
  vrot = 0,
  size = 1,
}

local function resetPlayer()
  P.speed = 1
  P.mode = "cube"
  P.vy = 0
  P.x = 0
  P.y = 15
  P.target_rot = 0
  P.rot = 0
  P.run = true
  P.respawn = 0
  P.camY = 105
  P.realCamY = 105
  P.gravity = 1
  P.pressed = false
  P.lastPressed = false
  P.action = false
  P.onGround = true
  P.vrot = 0
  P.size = 1
end

local rotateToTarget

do
  local FACTORS = {
    cube = 0.133975, -- 0.25
    ship = 0.064586, -- 0.125
    ball = 0.292893 -- 0.5
  }
  local abs = math.abs
  local function lerp(a,b,m)
    return m*b + (1-m)*a
  end

  rotateToTarget = function(rot,target)
    local t2 = 0
    if target > 180 then
      t2 = target - 360
    else
      t2 = target + 360
    end
    if abs(target-rot) < abs(t2-rot) then
      return lerp(rot,target,FACTORS[P.mode])
    else
      return lerp(rot,t2,FACTORS[P.mode])
    end
  end
end

local playerLayer = tolua(game.level.newArtLayer(1))
playerLayer.layerNum = 20

local playerCollidesWith
do -- collision checks

  local floor = math.floor
  local function convertCoords(x,y)
    return floor(x/30),floor(y/30)
  end

  local phb = {}
  local AABB = {}
  local circle = {}

  playerCollidesWith = function()
    local hbase = hitboxData[P.mode]
    local size = P.size
    AABB = {x1 = size*hbase.x1 + P.x, x2 = size*hbase.x2 + P.x, y1 = size*hbase.y1 + P.y, y2 = size*hbase.y2 + P.y}
    circle = {x = P.x, y = P.y, r = hbase.r * P.size}
    phb.AABB = AABB
    phb.circle = circle
    local colArr = {}
    local objs = {}
    local x1,y1 = convertCoords(AABB.x1,AABB.y1)
    local x2,y2 = convertCoords(AABB.x2,AABB.y2)
    for x = x1,x2 do -- find possible collisions
      local colx = Collision_Array[x]
      if colx then
        for y = y1,y2 do
          local cy = colx[y]
          if cy then
            for u=1,#cy do
              local obj = cy[u]
              if not objs[obj] then -- Prevent duplicate collisions
                colArr[#colArr + 1] = obj
                objs[obj] = true
              end 
            end -- end for u =
          end -- endif cy
        end -- end for y =
      end -- endif cox
    end -- end for x =
    -- actually check collisions
    local finalArray = {}
    for i=1,#colArr do
      local hbType = colArr[i].hitbox.t
      local v = collide[hbType](phb[hbType],colArr[i].hitbox)
      if v then finalArray[#finalArray + 1] = colArr[i] end
    end
    return finalArray
  end -- end playerCollidesWith
end


local solidhitboxData = {
  cube = {x1 = -4.5, y1 = -4.5, x2 = 4.5, y2 = 4.5},
  ship = {x1 = -4.5, y1 = -4.5, x2 = 4.5, y2 = 4.5}, -- lol
  ball = {x1 = -4.5, y1 = -4.5, x2 = 4.5, y2 = 4.5}, -- lol 2
}

local function getSolidHitbox(x,y,s)
  local hitbase = solidhitboxData[P.mode]
  return {x1 = hitbase.x1*s + x, y1 = hitbase.y1*s + y, x2 = hitbase.x2*s + x, y2 = hitbase.x2*s + y}
end

local function kill()
  P.run = false
  P.respawn = 30
  setCameraCenter(P.x+60,P.realCamY)
end

local tickSwitch = {
}

do
  do -- CUBE
    P.onGround = true
    tickSwitch.cube = function(pressed)
      local oldvy = P.vy
      P.x = P.x + dt * speeds[P.speed]
      local sizemult = (P.size == 0.6) and 0.8 or 1

      local groundHeight = 0
      if P.gravity > 0 then
        P.onGround = (P.y <= (groundHeight + 15*P.size) and P.vy <= 0) -- true or uncertain
      else
        groundHeight = 3000 -- This is a max height I just picked i suppose
        P.onGround = false -- uncertain.
        if P.y > groundHeight then -- skill issue
          kill()
          return
        end
        if P.y < 5*P.size and P.vy < 0 then
          kill()
          return
        end
      end

      local shb = getSolidHitbox(P.x,P.y,P.size)
      local collisions = playerCollidesWith()
      for i=1,#collisions do
        local c = collisions[i]
        if c.hitbox.type == "kill" then -- It's over...
          kill()
          return
        elseif c.hitbox.type == "block" then -- Maybe over...
          local allowKill = true
          if P.gravity > 0 then
            local pGh = c.hitbox.y2 -- highest spot.
            local diff = (pGh + 15*P.gravity*P.size) - P.y
            if diff <= 10 and P.vy <= 0 then
              groundHeight = math.max(groundHeight,pGh)
              P.onGround = true
              allowKill = false
            end
          else
            local pGh = c.hitbox.y1 -- lowest spot.
            local diff = (pGh + 15*P.gravity*P.size) - P.y
            if diff >= -10 and P.vy >= 0 then
              groundHeight = math.min(groundHeight,pGh)
              P.onGround = true
              allowKill = false
            end
          end
          if allowKill and collide.AABB(shb,c.hitbox) then kill() end
        elseif c.hitbox.type == "special" then -- oooh interesting
          c.hitbox.f(c,P)
        end
      end
      -- Do collision checks.
      if P.vy * P.gravity > 0 then P.onGround = false end
      -- don't lock if leaving ground
      if math.abs((groundHeight + 15*P.gravity*P.size) - P.y) > 15 then P.onGround = false end
      -- don't lock if ridiculously far from lock-position
      if P.onGround then -- lock, unless leaving ground
        P.vy = 0
        P.y = groundHeight + 15*P.gravity*P.size
        P.target_rot = math.floor((P.rot/90) + 0.5) * 90
        if P.pressed and not P.action then 
          P.vy = 1.01*604.4652*P.gravity*sizemult -- testing slightly higher than 604.4652
          P.onGround = false
          P.action = false
        elseif P.pressed then
          P.vy = 604.4652*P.gravity*sizemult -- testing slightly higher than 604.4652
          P.onGround = false
          P.action = false
        end
      else -- ur not on the ground
        local oldPVY = P.vy
        P.y = P.y + dt*oldPVY
        P.vy = oldPVY - dt*267.145719856*10.386*P.gravity
        if P.vy * P.gravity <= -810.225 then P.vy = -810.225 * P.gravity end
        P.y = P.y + 0.5 * dt * (P.vy - oldPVY)
        P.target_rot = (P.target_rot + dt*430*P.gravity)%360 -- trying 400
      end
      -- Do camera shit
      if P.mode == "cube" then
        if (P.y - P.camY) > 75 then
          P.camY = P.y - 75
        elseif (P.y - P.camY) < -75 then
          P.camY = P.y + 75
        end
      end
      P.realCamY = math.lerp(P.realCamY,P.camY,0.0253206) -- 0.05
      
      -- Handle rotation
      P.rot = rotateToTarget(P.rot,P.target_rot)%360
      setCameraCenter(P.x+60,P.realCamY)
    end -- end function

  end

  do -- SHIP
    tickSwitch.ship = function(pressed)
      local didAction = false
      --local oldvy = P.vy
      P.x = P.x + dt * speeds[P.speed]
      local mult = (math.abs(P.vy) < 104.4) and 0.8 or 1.2 
      local sizemult = 1/((P.size == 0.6) and 0.85 or 1)
      -- -0.32 * 10.386
      if P.pressed then
        local oldPVY = P.vy
        P.y = P.y + dt*oldPVY
        P.vy = oldPVY + dt*107.625649913*10.386*P.gravity * mult * 5/4 * sizemult
        if P.vy * P.gravity >= (432 * sizemult) then P.vy = 432 * P.gravity * sizemult end
        P.y = P.y + 0.5 * dt * (P.vy - oldPVY)
        didAction = true
      else
        local oldPVY = P.vy
        P.y = P.y + dt*oldPVY
        P.vy = oldPVY - dt*107.625649913*10.386*P.gravity * mult * sizemult
        if P.vy * P.gravity <= (-346 * sizemult) then P.vy = -346 * P.gravity * sizemult end
        P.y = P.y + 0.5 * dt * (P.vy - oldPVY)
      end

      local shb = getSolidHitbox(P.x,P.y,P.size)
      local collisions = playerCollidesWith()
      for i=1,#collisions do
        local c = collisions[i]
        if c.hitbox.type == "kill" then -- It's over...
          kill()
          return
        elseif c.hitbox.type == "block" then -- Maybe over...
          local y1 = c.hitbox.y1 -- lowest spot.
          local y2 = c.hitbox.y2 -- highest spot
          if P.y > (y2 + 5) then 
            P.y = y2 + 15 * P.size
            if P.vy < 0 then P.vy = 0 end
          elseif P.y < (y1 - 5) then
            P.y = y1 - 15 * P.size
            if P.vy > 0 then P.vy = 0 end
          end

          if collide.AABB(shb,c.hitbox) then
            kill()
            return
          end
        elseif c.hitbox.type == "special" then -- oooh interesting
          c.hitbox.f(c,P)
        end
      end

      if P.y > (P.camY + 150 - 15*P.size) then
        P.y = P.camY + 150 - 15*P.size
        if P.vy*P.gravity > 0 then P.vy = 0 end
      elseif P.y < (P.camY - (150 - 15*P.size)) then
        P.y = P.camY - (150 - 15*P.size)
        if P.vy*P.gravity < 0 then P.vy = 0 end
      end

      P.target_rot = -math.deg(math.atan(0.75 * P.vy/speeds[P.speed]))
      P.rot = rotateToTarget(P.rot,P.target_rot)%360
      P.realCamY = math.lerp(P.realCamY,P.camY,0.0253206) -- 0.05
      setCameraCenter(P.x+60,P.realCamY)
      if didAction then P.action = false end
    end
  end

  do -- BALL
    P.onGround = true
    tickSwitch.ball = function()
      P.x = P.x + dt * speeds[P.speed]
      local sizemult = (P.size == 0.6) and 0.8 or 1
      if not P.onGround then
        local oldPVY = P.vy
        P.y = P.y + dt*oldPVY
        P.vy = oldPVY - dt*160.287431914*10.386*P.gravity
        if P.vy * P.gravity >= 1090.6875 then P.vy = 1090.6875 * P.gravity
        elseif P.vy * P.gravity <= -810.225 then P.vy = -810.225 * P.gravity end
        P.y = P.y + 0.5 * dt * (P.vy - oldPVY)
      end

      -- Collision
      P.onGround = false -- not on the ground until proven otherwise
      local shb = getSolidHitbox(P.x,P.y,P.size)

      local collisions = playerCollidesWith()
      for i=1,#collisions do
        local c = collisions[i]
        if c.hitbox.type == "kill" then -- It's over...
          kill()
          return
        elseif c.hitbox.type == "block" then -- Maybe over...
          if P.gravity > 0 then
            local pGh = c.hitbox.y2 -- highest spot.
            if P.y > (pGh + 5) and P.vy <= 0 then
              P.y = pGh + 15*P.size
              P.vy = 0
              P.onGround = true
            end
          else
            local pGh = c.hitbox.y1 -- lowest spot.
            if P.y < (pGh - 5) and P.vy >= 0 then
              P.y = pGh - 15*P.size
              P.vy = 0
              P.onGround = true
            end
          end
          if collide.AABB(shb,c.hitbox) then kill() end
        elseif c.hitbox.type == "special" then -- oooh interesting
          c.hitbox.f(c,P)
        end
      end


      if P.y > (P.camY + (120 - 15*P.size)) then
        if P.gravity < 0 then
          P.y = P.camY + (120 - 15*P.size)
          if P.vy > 0 then P.vy = 0 P.onGround = true end
        elseif P.y > (P.camY + (120 - 4.5*P.size)) then kill() end
      elseif P.y < (P.camY - (120 - 15*P.size)) then
        if P.gravity > 0 then
          P.y = P.camY - (120 - 15*P.size)
          if P.vy < 0 then P.vy = 0 P.onGround = true end
        elseif P.y < (P.camY - (120 - 4.5*P.size)) then kill() end
      end

      if P.onGround then
        P.vrot = P.gravity * speeds[P.speed] --* math.pi
      end

      if P.onGround and P.pressed and P.action then
        P.vy = 155.8125 * P.gravity * sizemult
        P.gravity = -P.gravity
        P.action = false
        P.onGround = false
      end

      P.target_rot = (P.target_rot + 1.5*dt*P.vrot)%360
      P.rot = rotateToTarget(P.rot,P.target_rot)%360

      P.realCamY = math.lerp(P.realCamY,P.camY,0.0253206) -- 0.05
      setCameraCenter(P.x+60,P.realCamY)

    end
  end

end

local pClear = tolua(playerLayer.clear)
local pDraw = tolua(playerLayer.drawSprite)
local key = tolua(player.keypressed)
local winFrames = 0

local flipDrawWithGravity = {
  cube = false,
  ship = true,
}

local function tickBase()
  if P.run then
    if not P.pressed then P.action = true end
    P.pressed = tolua(player.spacepressed) or tolua(key(keys.W)) or tolua(key(keys.UP))
    for i=1,PHYS_TICKS do
      tickSwitch[P.mode]()
      P.lastPressed = P.pressed
      if not P.run then break end
    end
    pClear()
    if flipDrawWithGravity[P.mode] and P.gravity < 0 then
      pDraw(spriteData[P.mode],P.x * (40/30) * SCALE, P.y * -(40/30) * SCALE, SCALE*P.size, -SCALE*P.size, P.rot)
    else
      pDraw(spriteData[P.mode],P.x * (40/30) * SCALE, P.y * -(40/30) * SCALE, SCALE*P.size, SCALE*P.size, P.rot)
    end
    if P.x > (maxX - 240) then
      P.win = true
      P.run = false
    end
    player.camerax = pCam.x
    player.cameray = pCam.y
  elseif P.win then
    winFrames = winFrames + 1
    if winFrames <= 75 then
      P.x = math.lerp(P.x,maxX,(winFrames/75)^3)
      P.y = math.lerp(P.y,P.camY,(winFrames/75)^3)
      P.realCamY = math.lerp(P.realCamY,P.camY,0.05)
      setCameraCenter(0,P.realCamY)
      player.cameray = pCam.y
      spriteData[P.mode].alpha = 1 - ((winFrames/75)^3)
      pClear()
      pDraw(spriteData[P.mode],P.x * (40/30) * SCALE, P.y * -(40/30) * SCALE, SCALE*P.size, SCALE*P.size, P.rot)
    else
      player.finish()
    end
  else
    P.respawn = P.respawn - 1
    P.realCamY = math.lerp(P.realCamY,P.camY,0.05)
    setCameraCenter(P.x+60,P.realCamY)
    player.camerax = pCam.x
    player.cameray = pCam.y
    if P.respawn < 0 then
      AttemptNumber = AttemptNumber + 1
      resetPlayer()
      countAttempt()
    end
  end
end

player.fov = 1/SCALE

loader.attachSystem(tickBase,"physics")

countAttempt()


function physics.getAttempts() return AttemptNumber end
function physics.getPlayer() return P end
  
player.teleportto(1,0)
