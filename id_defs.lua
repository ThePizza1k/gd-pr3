local baseGamePortal
do
  local x,y = -17,-59
  local s = tolua(game.level.newSprite())
  local mt,lt,ct,cct = tolua(s.moveTo),tolua(s.lineTo),tolua(s.curveTo),tolua(s.cubicCurveTo)
  local ls = tolua(s.lineStyle)
  ls(0xFF000000,3,toobject{caps = round, joints = miter})
  mt(23+x,15+y);lt(30+x,27+y);lt(33+x,43+y);lt(34+x,60+y);lt(33+x,77+y);lt(28+x,94+y);lt(23+x,103+y);
  mt(30+x,15+y);lt(37+x,27+y);lt(40+x,43+y);lt(41+x,60+y);lt(40+x,77+y);lt(35+x,94+y);lt(30+x,103+y);
  mt(37+x,15+y);lt(44+x,27+y);lt(47+x,43+y);lt(48+x,60+y);lt(47+x,77+y);lt(42+x,94+y);lt(37+x,103+y);
  mt(23+x,15+y);lt(37+x,15+y);mt(23+x,103+y);lt(37+x,103+y);
  mt(18+x,31+y);lt(16+x,40+y);lt(15+x,50+y);lt(14+x,60+y);lt(15+x,70+y);lt(16+x,81+y);lt(19+x,88+y);
  mt(11+x,22+y);lt(9+x,30+y);lt(6+x,40+y);lt(5+x,50+y);lt(4+x,60+y);lt(5+x,70+y);lt(6+x,81+y);lt(9+x,88+y);lt(13+x,97+y);
  mt(3+x,97+y);lt(14+x,97+y);
  ls(0xFF000000,6,toobject{caps = round, joints = miter})
  mt(0+x,30+y);lt(18+x,30+y);mt(-3+x,39+y);lt(20+x,39+y);mt(-5+x,49+y);lt(22+x,49+y);mt(-5+x,60+y);lt(23+x,60+y);mt(-4+x,69+y);lt(22+x,69+y);
  mt(-2+x,80+y);lt(19+x,80+y);mt(0+x,89+y);lt(17+x,89+y);
  mt(15+x,102+y);lt(36+x,102+y);mt(21+x,93+y);lt(41+x,93+y);
  mt(26+x,77+y);lt(45+x,77+y);
  mt(26+x,42+y);lt(45+x,42+y);
  mt(15+x,16+y);lt(36+x,16+y);mt(21+x,27+y);lt(41+x,27+y);
  s.endFill()
  baseGamePortal = s
end

local baseGravPortal
do
  local x,y = -17,-59
  local s = tolua(game.level.newSprite())
  local mt,lt,ct,cct = tolua(s.moveTo),tolua(s.lineTo),tolua(s.curveTo),tolua(s.cubicCurveTo)
  local ls = tolua(s.lineStyle)
  -- nothing in particular actually
  baseGravPortal = s
end


do
  local sprite = tolua(game.level.newSprite)
  ID_DEFS[10] = {
    sprite = (function()
      local x,y = -17,-59
      local s = tolua(baseGravPortal.clone()); local mt,lt,ct,cct = tolua(s.moveTo),tolua(s.lineTo),tolua(s.curveTo),tolua(s.cubicCurveTo)
      local ls = tolua(s.lineStyle)
      x, y = -17, -59
      ls(0,0)
      s.beginGradientFill(
        toarray{0xFF6AF3FF,0xFF00B3FF},
        toarray{70,185},
        toobject{
          rotation = 90,
          y = 60,
          spreadMethod = "repeat",
        }
      )
      mt(20+x,59+y);cct(20+x,54+y,19+x,22+y,9+x,22+y);cct(-1+x,22+y,-2+x,54+y,-2+x,59+y);cct(-2+x,64+y,-1+x,96+y,9+x,96+y);cct(19+x,96+y,20+x,64+y,20+x,59+y);
      lt(47+x,59+y);
      local function generateShell()
        cct(47+x,70+y,37+x,76+y,24+x,76+y);
        cct(24+x,86+y,17+x,105+y,9+x,105+y);cct(1+x,105+y,-8+x,86+y,-8+x,59+y);
        cct(-8+x,32+y,1+x,13+y,9+x,13+y);
        cct(17+x,13+y,24+x,32+y,24+x,42+y);
        cct(37+x,42+y,47+x,48+y,47+x,59+y);
      end
      generateShell()
      local ef = tolua(s.endFill); ef();ls(0xFFFFFFFF,2);generateShell();ef()
      s.beginFill(0xFFFFFFFF); ls(0xFF000000,1)
      mt(33+x,55+y);lt(26+x,53+y);lt(33+x,66+y);lt(40+x,53+y);lt(33+x,55+y);ef()
      return s
    end)(),
    hb = {x1 = -12.5, x2 = 12.5, y1 = -37, y2 = 37, t = "special", f = function(o,p)
      local att = physics.getAttempts()
      if o.attemptUsed ~= att then
        o.attemptUsed = att
        if p.gravity ~= 1 then
          p.gravity = 1
          p.vy = p.vy * 0.5
          --if p.size == 0.6 then p.vy = p.vy*0.8 end
        end
      end
    end,}
  }
  ID_DEFS[11] = {
    sprite = (function()
      local x,y = -17,-59
      local s = tolua(baseGravPortal.clone()); local mt,lt,ct,cct = tolua(s.moveTo),tolua(s.lineTo),tolua(s.curveTo),tolua(s.cubicCurveTo)
      local ls = tolua(s.lineStyle)
      x, y = -17, -59
      ls(0,0)
      s.beginGradientFill(
        toarray{0xFFFFFE43,0xFFFFE44D},
        toarray{70,185},
        toobject{
          rotation = 90,
          y = 60,
          spreadMethod = "repeat",
        }
      )
      mt(20+x,59+y);cct(20+x,54+y,19+x,22+y,9+x,22+y);cct(-1+x,22+y,-2+x,54+y,-2+x,59+y);cct(-2+x,64+y,-1+x,96+y,9+x,96+y);cct(19+x,96+y,20+x,64+y,20+x,59+y);
      lt(47+x,59+y);
      local function generateShell()
        cct(47+x,70+y,37+x,76+y,24+x,76+y);
        cct(24+x,86+y,17+x,105+y,9+x,105+y);cct(1+x,105+y,-8+x,86+y,-8+x,59+y);
        cct(-8+x,32+y,1+x,13+y,9+x,13+y);
        cct(17+x,13+y,24+x,32+y,24+x,42+y);
        cct(37+x,42+y,47+x,48+y,47+x,59+y);
      end
      generateShell()
      local ef = tolua(s.endFill); ef();ls(0xFFFFFFFF,2);generateShell();ef()
      s.beginFill(0xFFFFFFFF); ls(0xFF000000,1)
      mt(33+x,63+y);lt(26+x,65+y);lt(33+x,52+y);lt(40+x,65+y);lt(33+x,63+y);ef()
      return s
    end)(),
    hb = {x1 = -12.5, x2 = 12.5, y1 = -37, y2 = 37, t = "special", f = function(o,p)
      local att = physics.getAttempts()
      if o.attemptUsed ~= att then
        o.attemptUsed = att
        if p.gravity ~= -1 then
          p.gravity = -1
          p.vy = p.vy * 0.5
          --if p.size == 0.6 then p.vy = p.vy*0.8 end
        end
      end
    end,}
  }
  ID_DEFS[12] = {
    sprite = (function()
      local x,y = -17,-59
      local s = tolua(baseGamePortal.clone()); local mt,lt,ct,cct = tolua(s.moveTo),tolua(s.lineTo),tolua(s.curveTo),tolua(s.cubicCurveTo)
      local ls = tolua(s.lineStyle)
      x, y = -17, -59
      ls(0,0)
      s.beginGradientFill(
        toarray{0xFF5CFF5F,0xFF00FF00},
        toarray{70,185},
        toobject{
          rotation = 90,
          y = 60,
          spreadMethod = "repeat",
        }
      )
      mt(20+x,59+y);cct(20+x,54+y,19+x,22+y,9+x,22+y);cct(-1+x,22+y,-2+x,54+y,-2+x,59+y);cct(-2+x,64+y,-1+x,96+y,9+x,96+y);cct(19+x,96+y,20+x,64+y,20+x,59+y);
      lt(47+x,59+y);
      local function generateShell()
        cct(47+x,70+y,37+x,76+y,24+x,76+y);
        cct(24+x,86+y,17+x,105+y,9+x,105+y);cct(1+x,105+y,-8+x,86+y,-8+x,59+y);
        cct(-8+x,32+y,1+x,13+y,9+x,13+y);
        cct(17+x,13+y,24+x,32+y,24+x,42+y);
        cct(37+x,42+y,47+x,48+y,47+x,59+y);
      end
      generateShell()
      local ef = tolua(s.endFill); ef();ls(0xFFFFFFFF,2);generateShell();ef()
      s.beginFill(0xFFFFFFFF); ls(0xFF000000,1)
      mt(29+x,54+y);lt(29+x,64+y);lt(39+x,64+y);lt(39+x,54+y);lt(29+x,54+y);ef()
      local s2 = tolua(game.level.newSprite())
      do
        s2.lineStyle(0xFFFFFFFF,1)
        s2.beginGradientFill(
          toarray{0xFF38FF68,0xFF00F90E},
          toarray{0,255},
          toobject{
            x = 4, y = 4,
            width = 8, height = 8,
            spreadMethod = "repeat",
          }
        )
        s2.drawCircle(0,0,4); s2.endFill()
        local c = {25,110,40,81,40,37,25,8}
        local r = {0,135,215,0}
        for i=1,4 do
          local s3 = s2.clone()
          s3.x = c[2*i - 1] + x; s3.y = c[2*i] + y; s3.rotation = r[i]
          s.addChild(s3)
        end
      end
      
      return s
    end)(),
    hb = {x1 = -17, x2 = 17, y1 = -43, y2 = 43, t = "special", f = function(o,p)
      local att = physics.getAttempts()
      if o.attemptUsed ~= att then
        o.attemptUsed = att
        if p.mode ~= "cube" then
          p.vy = p.vy * 0.5
        end
        p.mode = "cube"
      end
    end,}
  }

  ID_DEFS[13] = {
    sprite = (function()
      local x,y = -17,-59
      local s = tolua(baseGamePortal.clone()); local mt,lt,ct,cct = tolua(s.moveTo),tolua(s.lineTo),tolua(s.curveTo),tolua(s.cubicCurveTo)
      local ls = tolua(s.lineStyle)
      x, y = -17, -59
      ls(0,0)
      s.beginGradientFill(
        toarray{0xFFFFA0FF,0xFFFF1EFF},
        toarray{70,185},
        toobject{
          rotation = 90,
          y = 60,
          spreadMethod = "repeat",
        }
      )
      mt(20+x,59+y);cct(20+x,54+y,19+x,22+y,9+x,22+y);cct(-1+x,22+y,-2+x,54+y,-2+x,59+y);cct(-2+x,64+y,-1+x,96+y,9+x,96+y);cct(19+x,96+y,20+x,64+y,20+x,59+y);
      lt(47+x,59+y);
      local function generateShell()
        cct(47+x,70+y,37+x,76+y,24+x,76+y);
        cct(24+x,86+y,17+x,105+y,9+x,105+y);cct(1+x,105+y,-8+x,86+y,-8+x,59+y);
        cct(-8+x,32+y,1+x,13+y,9+x,13+y);
        cct(17+x,13+y,24+x,32+y,24+x,42+y);
        cct(37+x,42+y,47+x,48+y,47+x,59+y);
      end
      generateShell()
      local ef = tolua(s.endFill); ef();ls(0xFFFFFFFF,2);generateShell();ef()
      s.beginFill(0xFFFFFFFF); ls(0xFF000000,1)
      mt(32+x,54+y);cct(44+x,54+y,49+x,62+y,29+x,62+y);cct(24+x,62+y,24+x,56+y,28+x,55+y);cct(28+x,52+y,31+x,50+y,32+x,54+y);ef()
      local s2 = tolua(game.level.newSprite())
      do
        s2.lineStyle(0xFFFFFFFF,1)
        s2.beginGradientFill(
          toarray{0xFFFF8EFF,0xFFFF53FF},
          toarray{0,255},
          toobject{
            x = 4, y = 4,
            width = 8, height = 8,
            spreadMethod = "repeat",
          }
        )
        s2.drawCircle(0,0,4); s2.endFill()
        local c = {25,110,40,81,40,37,25,8}
        local r = {0,135,215,0}
        for i=1,4 do
          local s3 = s2.clone()
          s3.x = c[2*i - 1] + x; s3.y = c[2*i] + y; s3.rotation = r[i]
          s.addChild(s3)
        end
      end
      
      return s
    end)(),
    hb = {x1 = -17, x2 = 17, y1 = -43, y2 = 43, t = "special", f = function(o,p)
      local att = physics.getAttempts()
      if o.attemptUsed ~= att then
        o.attemptUsed = att
        if p.mode ~= "ship" then 
          p.vy = p.vy * 0.5 
          if p.mode == "wave" then p.vy = p.vy * 0.4444444444 end
        end
        p.mode = "ship"
        local y = math.ceil((o.y-15)/30)*30
        p.camY = math.max(y,150)
        p.rot = 0
      end
    end,}
  }

  ID_DEFS[47] = {
    sprite = (function()
      local x,y = -17,-59
      local s = tolua(baseGamePortal.clone()); local mt,lt,ct,cct = tolua(s.moveTo),tolua(s.lineTo),tolua(s.curveTo),tolua(s.cubicCurveTo)
      local ls = tolua(s.lineStyle)
      x, y = -17, -59
      ls(0,0)
      s.beginGradientFill(
        toarray{0xFFFF8C6F,0xFFFF0201},
        toarray{70,185},
        toobject{
          rotation = 90,
          y = 60,
          spreadMethod = "repeat",
        }
      )
      mt(20+x,59+y);cct(20+x,54+y,19+x,22+y,9+x,22+y);cct(-1+x,22+y,-2+x,54+y,-2+x,59+y);cct(-2+x,64+y,-1+x,96+y,9+x,96+y);cct(19+x,96+y,20+x,64+y,20+x,59+y);
      lt(47+x,59+y);
      local function generateShell()
        cct(47+x,70+y,37+x,76+y,24+x,76+y);
        cct(24+x,86+y,17+x,105+y,9+x,105+y);cct(1+x,105+y,-8+x,86+y,-8+x,59+y);
        cct(-8+x,32+y,1+x,13+y,9+x,13+y);
        cct(17+x,13+y,24+x,32+y,24+x,42+y);
        cct(37+x,42+y,47+x,48+y,47+x,59+y);
      end
      generateShell()
      local ef = tolua(s.endFill); ef();ls(0xFFFFFFFF,2);generateShell();ef()
      s.beginFill(0xFFFFFFFF); ls(0xFF000000,1)
      s.drawCircle(34+x,59+y,7)
      local s2 = tolua(game.level.newSprite())
      do
        s2.lineStyle(0xFFFFFFFF,1)
        s2.beginGradientFill(
          toarray{0xFFFD6F46,0xFFFF3402},
          toarray{0,255},
          toobject{
            x = 4, y = 4,
            width = 8, height = 8,
            spreadMethod = "repeat",
          }
        )
        s2.drawCircle(0,0,4); s2.endFill()
        local c = {25,110,40,81,40,37,25,8}
        local r = {0,135,215,0}
        for i=1,4 do
          local s3 = s2.clone()
          s3.x = c[2*i - 1] + x; s3.y = c[2*i] + y; s3.rotation = r[i]
          s.addChild(s3)
        end
      end
      
      return s
    end)(),
    hb = {x1 = -17, x2 = 17, y1 = -43, y2 = 43, t = "special", f = function(o,p)
      local att = physics.getAttempts()
      if o.attemptUsed ~= att then
        o.attemptUsed = att
        if p.mode ~= "ball" then 
          p.vy = p.vy * 0.5 
          if p.mode == "wave" then p.vy = p.vy * .95 end
        end
        p.mode = "ball"
        local y = math.ceil((o.y-15)/30)*30
        p.camY = math.max(y,120)
        p.rot = 0
      end
    end,}
  }

  ID_DEFS[99] = {
    sprite = (function()
      local x,y = -17,-59
      local s = tolua(baseGravPortal.clone()); local mt,lt,ct,cct = tolua(s.moveTo),tolua(s.lineTo),tolua(s.curveTo),tolua(s.cubicCurveTo)
      local ls = tolua(s.lineStyle)
      x, y = -17, -59
      ls(0,0)
      s.beginGradientFill(
        toarray{0xFF00FF28,0xFF00C200},
        toarray{70,185},
        toobject{
          rotation = 90,
          y = 60,
          spreadMethod = "repeat",
        }
      )
      mt(20+x,59+y);cct(20+x,54+y,19+x,22+y,9+x,22+y);cct(-1+x,22+y,-2+x,54+y,-2+x,59+y);cct(-2+x,64+y,-1+x,96+y,9+x,96+y);cct(19+x,96+y,20+x,64+y,20+x,59+y);
      lt(47+x,59+y);
      local function generateShell()
        cct(47+x,70+y,37+x,76+y,24+x,76+y);
        cct(24+x,86+y,17+x,105+y,9+x,105+y);cct(1+x,105+y,-8+x,86+y,-8+x,59+y);
        cct(-8+x,32+y,1+x,13+y,9+x,13+y);
        cct(17+x,13+y,24+x,32+y,24+x,42+y);
        cct(37+x,42+y,47+x,48+y,47+x,59+y);
      end
      generateShell()
      local ef = tolua(s.endFill); ef();ls(0xFFFFFFFF,2);generateShell();ef()
      s.beginFill(0xFFFFFFFF); ls(0xFF000000,1)
      --mt(33+x,55+y);lt(26+x,53+y);lt(33+x,66+y);lt(40+x,53+y);lt(33+x,55+y);ef()
      mt(33+x,63+y);lt(26+x,65+y);lt(33+x,52+y);lt(40+x,65+y);lt(33+x,63+y);ef()
      return s
    end)(),
    hb = {x1 = -15.5, x2 = 15.5, y1 = -45, y2 = 45, t = "special", f = function(o,p)
      local att = physics.getAttempts()
      if o.attemptUsed ~= att then
        o.attemptUsed = att
        if p.size ~= 1 then
          p.size = 1
          --p.vy = p.vy * 0.5
        end
      end
    end,}
  }

  ID_DEFS[101] = {
    sprite = (function()
      local x,y = -17,-59
      local s = tolua(baseGravPortal.clone()); local mt,lt,ct,cct = tolua(s.moveTo),tolua(s.lineTo),tolua(s.curveTo),tolua(s.cubicCurveTo)
      local ls = tolua(s.lineStyle)
      x, y = -17, -59
      ls(0,0)
      s.beginGradientFill(
        toarray{0xFFFF73FF,0xFFD720FF},
        toarray{70,185},
        toobject{
          rotation = 90,
          y = 60,
          spreadMethod = "repeat",
        }
      )
      mt(20+x,59+y);cct(20+x,54+y,19+x,22+y,9+x,22+y);cct(-1+x,22+y,-2+x,54+y,-2+x,59+y);cct(-2+x,64+y,-1+x,96+y,9+x,96+y);cct(19+x,96+y,20+x,64+y,20+x,59+y);
      lt(47+x,59+y);
      local function generateShell()
        cct(47+x,70+y,37+x,76+y,24+x,76+y);
        cct(24+x,86+y,17+x,105+y,9+x,105+y);cct(1+x,105+y,-8+x,86+y,-8+x,59+y);
        cct(-8+x,32+y,1+x,13+y,9+x,13+y);
        cct(17+x,13+y,24+x,32+y,24+x,42+y);
        cct(37+x,42+y,47+x,48+y,47+x,59+y);
      end
      generateShell()
      local ef = tolua(s.endFill); ef();ls(0xFFFFFFFF,2);generateShell();ef()
      s.beginFill(0xFFFFFFFF); ls(0xFF000000,1)
      mt(33+x,55+y);lt(26+x,53+y);lt(33+x,66+y);lt(40+x,53+y);lt(33+x,55+y);ef()
      --mt(33+x,63+y);lt(26+x,65+y);lt(33+x,52+y);lt(40+x,65+y);lt(33+x,63+y);ef()
      return s
    end)(),
    hb = {x1 = -15.5, x2 = 15.5, y1 = -45, y2 = 45, t = "special", f = function(o,p)
      local att = physics.getAttempts()
      if o.attemptUsed ~= att then
        o.attemptUsed = att
        if p.size ~= 0.6 then
          p.size = 0.6
          --p.vy = p.vy * 0.5
        end
      end
    end,}
  }

end


player.teleportto(1,0)
