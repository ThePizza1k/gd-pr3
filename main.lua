SCALE = 1
local drawScale = 31/30

local speeds = {
  [0] = 251.16,
  [1] = 311.58,
  [2] = 387.42,
  [3] = 468,
  [4] = 576,
}

game.start.addListener(function()
  local chat = tolua(player.chat)
  levelString = "" -- paste level data into this
  player.disableup()
  player.disabledown()
  player.disableleft()
  player.disableright()

  player.newTimer(1,1,function()
    player.minimap = false
    player.stiffness = 0
    local kp = tolua(player.keypressed)
    if tolua(kp(keys.SHIFT)) and tolua(kp(keys.H)) then
      SCALE = 2
      player.chat("2x resolution enabled")
    end
  end)

  local vTypes = {
    ['1'] = "id",
    ['2'] = "x",
    ['3'] = "y",
    ['4'] = "flipX",
    ['5'] = "flipY",
    ['6'] = "rotation",
    ['7'] = "red", -- for triggers
    ['8'] = "green", -- for triggers
    ['9'] = "blue", -- for triggers
    ['10'] = "duration", -- for color triggers
    ['11'] = "touchTriggered", -- for triggers
    ['21'] = "base color",
    ['22'] = "detail color",
    ['23'] = "targetColorID",
    ['24'] = "z layer",
    ['32'] = "scale",
    ['35'] = "opacity", -- for triggers
    ['43'] = "base hsv",
    ['44'] = "default hsv",
    ['57'] = "group ID"
  }

  local unreq = {
    ids = {},
    vTypes = {},
  }

  local no_ID = 0

  do
    -- Define some useful functions first
    local sprite = tolua(game.level.newSprite)

    --[[
      hitbox types

      "block" - basic block you can stand on
      "kill" - kills u lol
      "special" - confers an action upon the player
    ]]--

    ID_DEFS = {
      [1] = {
        sprite = (function()
          local s = tolua(sprite()); local mt = tolua(s.moveTo);
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = square,pixelHinting = true,joints = "miter"})
          s.beginGradientFill(toarray{0xFF000000,0x00000000},toarray{0,255},toobject{width = 40,height = 40,x = -20,y = -20,rotation = 90})
          s.drawRect(-19,-19,38,38)
          s.endFill()
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"},
      },
      [2] = {
        sprite = (function()
          local s = tolua(sprite()); local rect = tolua(s.drawRect);
          s.beginFill(0xA0000000)
          rect(-19,-19,11,11);rect(-6,-19,12,11);rect(8,-19,11,11);
          s.beginFill(0x80000000)
          rect(-19,-6,11,12);rect(-6,-6,12,12);rect(8,-6,11,12);
          s.beginFill(0x60000000)
          rect(-19,8,11,11);rect(-6,8,12,11);rect(8,8,11,11);
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = square,pixelHinting = true,joints = "miter"})
          s.moveTo(-19,-19);s.lineTo(19,-19);
          s.endFill()
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"},
      },
      [3] = {
        sprite = (function()
          local s = tolua(sprite()); local rect = tolua(s.drawRect);
          s.beginFill(0xA0000000)
          rect(-19,-19,11,11);rect(-6,-19,12,11);rect(8,-19,11,11);rect(-19,-6,11,12);rect(-19,8,11,11)
          s.beginFill(0x80000000)
          rect(-6,-6,12,12);rect(8,-6,11,12);rect(-6,8,12,11);
          s.beginFill(0x60000000)
          rect(8,8,11,11);
          s.endFill()
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = square,pixelHinting = true,joints = "miter"})
          s.moveTo(-19,19);s.lineTo(-19,-19);s.lineTo(19,-19);
          s.endFill()
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"},
      },
      [4] = {
        sprite = (function()
          local s = tolua(sprite()); local rect = tolua(s.drawRect);
          s.beginFill(0xA0000000)
          rect(-19,-19,11,11);
          s.beginFill(0x80000000)
          rect(-19,-6,11,12);rect(-6,-6,12,12);rect(-6,-19,12,11);
          s.beginFill(0x60000000)
          rect(-19,8,11,11);rect(-6,8,12,11);rect(8,8,11,11);rect(8,-6,11,12);rect(8,-19,11,11);
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = square,pixelHinting = true,joints = "miter"})
          s.moveTo(-19,-19);s.lineTo(-19,-19);
          s.endFill()
          return s
        end)(), 
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"},
      },
      [5] = {
        sprite = (function()
          local s = tolua(sprite()); local rect = tolua(s.drawRect);
          s.beginFill(0x60000000)
          rect(-19,-19,11,11);rect(-6,-19,12,11);rect(8,-19,11,11);
          rect(-19,-6,11,12);rect(8,-6,11,12);
          rect(-19,8,11,11);rect(-6,8,12,11);rect(8,8,11,11);
          s.beginFill(0x50000000)
          rect(-6,-6,12,12)
          s.endFill()
          return s
        end)(),
      },
      [6] = {
        sprite = (function()
          local s = tolua(sprite()); local rect = tolua(s.drawRect);
          s.beginFill(0xA0000000)
          rect(-19,-19,11,11);rect(-6,-19,12,11);rect(8,-19,11,11);rect(-19,-6,11,12);rect(-19,8,11,11);rect(8,-6,11,12);rect(8,8,11,11);
          s.beginFill(0x80000000)
          rect(-6,-6,12,12);rect(-6,8,12,11);
          s.endFill()
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = square,pixelHinting = true,joints = "miter"})
          s.moveTo(-19,19);s.lineTo(-19,-19);s.lineTo(19,-19);s.lineTo(19,19);
          s.endFill()
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"},
      },
      [7] = {
        sprite = (function()
          local s = tolua(sprite()); local rect = tolua(s.drawRect);
          s.beginFill(0xA0000000)
          rect(-19,-19,11,11);rect(8,-19,11,11);rect(-19,-6,11,12);rect(-19,8,11,11);rect(8,-6,11,12);rect(8,8,11,11);
          s.beginFill(0x80000000)
          rect(-6,-6,12,12);rect(-6,8,12,11);rect(-6,-19,12,11);
          s.endFill()
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = square,pixelHinting = true,joints = "miter"})
          s.moveTo(-19,19);s.lineTo(-19,-19);s.moveTo(19,-19);s.lineTo(19,19);
          s.endFill()
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"},
      },
      [8] = {
        sprite = (function()
          local s = tolua(sprite()); local mt = tolua(s.moveTo);
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = square,pixelHinting = true,joints = "miter"})
          s.beginGradientFill(toarray{0xFF000000,0x00000000},toarray{0,255},toobject{width = 40,height = 40,x = -20,y = -20,rotation = 90})
          s.moveTo(0,-19)
          s.lineTo(19,19)
          s.lineTo(-19,19)
          s.lineTo(0,-19)
          s.endFill()
          return s
        end)(),
        hb = {x1 = -3, y1 = -5, x2 = 3, y2 = 5, t = "kill"},
      },
      [9] = {
        sprite = (function()
          local o = 15
          local s = tolua(sprite()); local lt = tolua(s.lineTo);
          s.beginGradientFill(toarray{0xFF000000,0x00000000},toarray{120,185},toobject{width = 40,height = 40,x = -20,y = -o,rotation = 90})
          s.moveTo(-19,15-o)
          lt(-15,10-o);lt(-12,13-o);lt(-9,4-o);lt(-6,14-o);lt(-1,3-o);lt(2,11-o);lt(5,7-o);lt(9,12-o);lt(12,8-o);lt(14,12-o);lt(17,10-o);lt(19,15-o);
          lt(19,30-o);lt(-19,30-o);lt(-19,15-o)
          s.endFill()
          return s
        end)(),
        hb = {x1 = -4, y1 = -5, x2 = 4, y2 = 4, t = "kill"}
      },
      [15] = {
        sprites = {[1] = (function()
          local s = tolua(sprite()); local lt = tolua(s.lineTo); local mt = tolua(s.moveTo);
          local ct = tolua(s.curveTo); local rect = tolua(s.drawRect);
          local o = 26
          s.beginFill(0xFF000000)
          mt(-3,-1+o);lt(3,-1+o);ct(3,-3+o,1,-3+o);lt(-1,-3+o);ct(-3,-3+o,-3,-1+o);
          s.beginFill(0xa6000000)
          rect(-1,-10+o,2,5)
          s.beginFill(0x9a000000)
          rect(-1,-17+o,2,5)
          s.beginFill(0x80000000)
          rect(-1,-24+o,2,5)
          s.beginFill(0x6d000000)
          rect(-1,-31+o,2,5)
          s.beginFill(0x5a000000)
          rect(-1,-38+o,2,5)
          s.beginFill(0x48000000)
          rect(-1,-45+o,2,5)
          s.endFill()
          return s
        end)(),
        [2] = (function()
          local s = tolua(sprite());
          s.beginFill(0xFF00FF00)
          s.drawCircle(0,-30,4)
          s.blendMode = "add"
          return s
        end)(),
        },
        blend2 = "add"
      },
      [16] = {
        sprites = {[1] = (function()
          local s = tolua(sprite()); local lt = tolua(s.lineTo); local mt = tolua(s.moveTo);
          local ct = tolua(s.curveTo); local rect = tolua(s.drawRect);
          local o = 17
          s.beginFill(0xFF000000)
          mt(-3,-1+o);lt(3,-1+o);ct(3,-3+o,1,-3+o);lt(-1,-3+o);ct(-3,-3+o,-3,-1+o);
          s.beginFill(0x9a000000)
          rect(-1,-10+o,2,5)
          s.beginFill(0x80000000)
          rect(-1,-17+o,2,5)
          s.beginFill(0x6a000000)
          rect(-1,-24+o,2,5)
          s.beginFill(0x48000000)
          rect(-1,-31+o,2,5)
          s.endFill()
          return s
        end)(),
        [2] = (function()
          local s = tolua(sprite());
          s.beginFill(0xFF00FF00)
          s.drawCircle(0,-25,4)
          s.blendMode = "add"
          return s
        end)(),
        },
        blend2 = "add"
      },
      [17] = {
        sprites = {[1] = (function()
          local s = tolua(sprite()); local lt = tolua(s.lineTo); local mt = tolua(s.moveTo);
          local ct = tolua(s.curveTo); local rect = tolua(s.drawRect);
          local o = 8
          s.beginFill(0xFF000000)
          mt(-3,-1+o);lt(3,-1+o);ct(3,-3+o,1,-3+o);lt(-1,-3+o);ct(-3,-3+o,-3,-1+o);
          s.beginFill(0x80000000)
          rect(-1,-10+o,2,5)
          s.beginFill(0x48000000)
          rect(-1,-17+o,2,5)
          s.endFill()
          return s
        end)(),
        [2] = (function()
          local s = tolua(sprite());
          s.beginFill(0xFF00FF00)
          s.drawCircle(0,-20,4)
          s.blendMode = "add"
          return s
        end)(),
        },
        blend2 = "add"
      },
      [35] = {
        sprite = (function()
          local s = tolua(sprite())
          s.beginGradientFill(
            toarray{0x00FFFF00,0xA0FFFF00},
            toarray{0,255},
            toobject{
              rotation = 90, spreadMethod = "repeat",
              width = 34, height = 24, y = 2
            }
          )
          s.drawRect(-17,-21,34,23)
          s.endFill()
          s.lineStyle(0xFFFFFFFF,1)
          s.beginFill(0xFFFFFF00)
          s.moveTo(-17,2);s.cubicCurveTo(-10,-4,10,-4,17,2);
          s.endFill()
          return s
        end)(),
        hb = {x1 = -12.5, y1 = -2, x2 = 12.5, y2 = 2, t = "special",f = function(o,p)
          local att = physics.getAttempts()
          if o.attemptUsed ~= att then
            o.attemptUsed = att
            p.vy = ({
              cube = 864.5,
              ship = 417,
              ball = 509.931818182,
              ufo = 509.931818182,
            })[p.mode] * p.gravity
            if p.size == 0.6 then p.vy = p.vy*0.8 end
            p.onGround = false
            if p.mode == "ball" then
              p.vrot = p.gravity * speeds[p.speed] --* math.pi
            end
          end
        end},
      },
      [36] = {
        sprite = (function()
          local s = tolua(sprite()); local dc = tolua(s.drawCircle)
          s.lineStyle(0xFFFFFFFF,2)
          dc(0,0,19)
          s.beginGradientFill(
            toarray{0xFFFFFF6E,0xFFFFEE3B},
            toarray{0,255},
            toobject{
              type = "radial",
              width = 26, height = 26, x = -13, y = -13,
              spreadMethod = "repeat",
            }
          )
          dc(0,0,13)
          s.endFill()
          return s
        end)(),
        hb = {x1 = -18, y1 = -18, x2 = 18, y2 = 18, t = "special",f = function(o,p)
          local att = physics.getAttempts()
          if o.attemptUsed ~= att and p.pressed and p.action then
            p.action = false
            o.attemptUsed = att
            p.vy = ({
              cube = 595.1178,
              ship = 544.5,
              ball = 415.5,
              ufo = 595.1178,
            })[p.mode] * p.gravity
            p.onGround = false
            if p.size == 0.6 then p.vy = p.vy*0.8 end
            if p.mode == "ball" then
              p.vrot = -p.gravity * speeds[p.speed] --* math.pi
            end
          end
        end}
      },
      [39] = {
        sprite = (function()
          local s = tolua(sprite()); local lt = tolua(s.lineTo)
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = square,pixelHinting = true,joints = "miter"})
          s.beginGradientFill(toarray{0xFF000000,0x00000000},toarray{0,255},toobject{width = 40,height = 16,x = -20,y = -8,rotation = 90})
          s.moveTo(-19,8);lt(0,-8);lt(19,8);lt(-19,8);
          s.endFill()
          return s
        end)(),
       hb = {x1 = -3, y1 = -3, x2 = 3, y2 = 3, t = "kill"},
      },
      [40] = {
        sprite = (function()
          local s = tolua(sprite()); local mt = tolua(s.moveTo);
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = square,pixelHinting = true,joints = "miter"})
          s.beginGradientFill(toarray{0xFF000000,0x00000000},toarray{0,255},toobject{width = 40,height = 16,x = -20,y = -8,rotation = 90})
          s.drawRect(-19,-8,38,16)
          s.endFill()
          return s
        end)(),
        hb = {x1 = -15, y1 = -7, x2 = 15, y2 = 7, t = "block"},
      },
      [61] = {
        sprite = (function()
          local s = tolua(sprite()); local mt = tolua(s.moveTo);
          local lt = tolua(s.lineTo);
          local cct = tolua(s.cubicCurveTo);
          s.beginGradientFill(
            toarray{0xFF000000,0x000000},
            toarray{0,255},
            toobject{
              spreadMethod = "pad",
              rotation = 90,
              height = 10,
              y = 3
            }
          )
          mt(0-20,16-20);cct(10-20,9-20,10-20,22-20,20-20,16-20);cct(30-20,9-20,30-20,22-20,40-20,16-20);
          lt(39-20,39-20);lt(0-20,39-20);lt(0-20,16-20);
          return s
        end)(),
        hb = {x1 = -5, y1 = -3, x2 = 5, y2 = 3, t = "kill"},
      },
      [62] = {
        sprite = (function()
          local s = tolua(sprite()); local mt = tolua(s.moveTo);
          local lt = tolua(s.lineTo);
          local cct = tolua(s.cubicCurveTo);
          s.beginFill(0xFF000000)
          mt(0-20,18-20);cct(11-20,10-20,11-20,28-20,21-20,17-20);
          cct(30-20,11-20,30-20,26-20,39-20,18-20);lt(39-20,10-20);lt(0-20,10-20);lt(0-20,18-20);
          s.endFill()
          s.beginFill(0xA0000000)
          mt(0-20,18-13);cct(11-20,10-13,11-20,28-13,21-20,17-13);
          cct(30-20,11-13,30-20,26-13,39-20,18-13);lt(39-20,10-20);lt(0-20,10-20);lt(0-20,18-13);
          s.endFill()
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = "none",pixelHinting = true})
          mt(0-20,9-20); s.lineTo(39-20,9-20);
          s.endFill()
          return s
        end)(),
        hb = {x1 = -15, y1 = -7, x2 = 15, y2 = 7, t = "block"},
      },
      [65] = {
        sprite = (function()
          local s = tolua(sprite()); local mt = tolua(s.moveTo);
          local lt = tolua(s.lineTo);
          local cct = tolua(s.cubicCurveTo);
          s.beginFill(0xFF000000)
          mt(0,96);cct(53,56,54,151,104,94);cct(152,46,146,119,185,78);
          cct(196,68,198,58,199,51);lt(0,51);lt(0,96)
          s.endFill()
          s.beginFill(0xA0000000)
          mt(0,135);cct(55,92,55,192,103,132);
          cct(150,81,135,155,180,97); cct(189,87,196,74,199,53);
          lt(0,53);lt(0,135);
          s.endFill()
          s.lineStyle(0xFFFFFFFF,10,toobject{caps = "none",pixelHinting = true})
          mt(0,51);lt(199,51);
          s.endFill()
          local s2 = tolua(sprite());
          s2.addChild(s); s.scaleX = 0.2; s.scaleY = 0.2;s.x = -20; s.y = -21;
          return s2
        end)(),
        hb = {x1 = -15, y1 = -7, x2 = 15, y2 = 7, t = "block"},
      },
      [66] = {
        sprite = (function()
          local s = tolua(sprite()); local mt = tolua(s.moveTo);
          local lt = tolua(s.lineTo);
          local cct = tolua(s.cubicCurveTo);
          s.beginFill(0xFF000000)
          mt(0,96);cct(53,56,54,151,104,94);cct(152,46,146,119,185,78);
          cct(196,68,198,58,199,51);lt(0,51);lt(0,96)
          s.endFill()
          s.beginFill(0xA0000000)
          mt(0,135);cct(55,92,55,192,103,132);
          cct(150,81,135,155,180,97); cct(189,87,196,74,199,53);
          lt(0,53);lt(0,135);
          s.endFill()
          s.lineStyle(0xFFFFFFFF,10,toobject{caps = "none",pixelHinting = true})
          mt(0,51);lt(199,51);
          s.endFill()
          local s2 = tolua(sprite());
          s2.addChild(s); s.scaleX = -0.2; s.scaleY = 0.2;s.x = 19; s.y = -21;
          return s2
        end)(),
        hb = {x1 = -15, y1 = -7, x2 = 15, y2 = 7, t = "block"},
      },
      [67] = {
        sprite = (function()
          local s = tolua(sprite())
          s.beginGradientFill(
            toarray{0x0000FFFF,0xA000FFFF},
            toarray{0,255},
            toobject{
              rotation = 90, spreadMethod = "repeat",
              width = 34, height = 24, y = 2
            }
          )
          s.drawRect(-16,-21,32,23)
          s.endFill()
          s.lineStyle(0xFFFFFFFF,1)
          s.beginFill(0xFF16FFFF)
          s.moveTo(-16,2);s.cubicCurveTo(-10,-5,10,-5,16,2);
          s.endFill()
          return s
        end)(),
        hb = {x1 = -12, y1 = -3, x2 = 12, y2 = 2, t = "special",f = function(o,p)
          local att = physics.getAttempts()
          local grav = 2*math.floor((((o.rotation or 0)%360)+90)/180) - 1
          if o.flipY then grav = -grav end
          if o.attemptUsed ~= att and p.gravity ~= grav then
            o.attemptUsed = att
            p.vy = ({
              cube = 311.625,
              ship = 259.6875,
              ball = 155.8125,
              ufo = 233.71875,
              wave = 0
            })[p.mode] * p.gravity
            if p.size == 0.6 then p.vy = p.vy*0.8 end
            p.gravity = grav
            p.onGround = false
          end
        end},
      },
      [68] = {
        sprite = (function()
          local s = tolua(sprite()); local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          local cct = tolua(s.cubicCurveTo);
          local x,y = -20,-20
          bf(0xA0000000);
          mt(0+x,11+y);cct(6+x,25+y,16+x,28+y,21+x,24+y);
          cct(25+x,21+y,31+x,23+y,39+x,11+y);lt(0+x,11+y);ef();
          bf(0xFF000000);
          mt(1+x,11+y);cct(7+x,20+y,14+x,22+y,21+x,18+y);
          cct(27+x,15+y,33+x,18+y,38+x,11+y);lt(1+x,11+y);ef();
          bf(0xFFFFFFFF); s.drawRect(0+x,10+y,40,2);ef();
          return s;
        end)(),
        hb = {x1 = -15, y1 = -7, x2 = 15, y2 = 7, t = "block"},
      },
      [69] = {
        sprite = (function()
          local s = tolua(sprite());local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          bf(0xCC000000);mt(0,0);lt(-19,-19);lt(-19,19);lt(0,0);ef()bf(0x99000000);lt(-19,-19);lt(19,-19);lt(0,0);ef()bf(0x66000000);lt(19,-19);lt(19,19);lt(0,0);ef()bf(0x33000000);lt(-19,19);lt(19,19);lt(0,0);ef()
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = "square", joints = "miter"})
          mt(-19,-19);lt(-19,19);lt(19,19);lt(19,-19);lt(-19,-19);
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [70] = {
        sprite = (function()
          local s = tolua(sprite());local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          bf(0xCC000000);mt(0,0);lt(-19,-19);lt(-19,19);lt(0,0);ef()bf(0x99000000);lt(-19,-19);lt(19,-19);lt(0,0);ef()bf(0x66000000);lt(19,-19);lt(19,19);lt(0,0);ef()bf(0x33000000);lt(-19,19);lt(19,19);lt(0,0);ef()
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = "square", joints = "miter"})
          mt(-19,-19);lt(19,-19)
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [71] = {
        sprite = (function()
          local s = tolua(sprite());local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          bf(0xCC000000);mt(0,0);lt(-19,-19);lt(-19,19);lt(0,0);ef()bf(0x99000000);lt(-19,-19);lt(19,-19);lt(0,0);ef()bf(0x66000000);lt(19,-19);lt(19,19);lt(0,0);ef()bf(0x33000000);lt(-19,19);lt(19,19);lt(0,0);ef()
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = "square", joints = "miter"})
          mt(-19,19);lt(-19,-19);lt(19,-19)
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [72] = {
        sprite = (function()
          local s = tolua(sprite());local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          bf(0xCC000000);mt(0,0);lt(-19,-19);lt(-19,19);lt(0,0);ef()bf(0x99000000);lt(-19,-19);lt(19,-19);lt(0,0);ef()bf(0x66000000);lt(19,-19);lt(19,19);lt(0,0);ef()bf(0x33000000);lt(-19,19);lt(19,19);lt(0,0);ef()
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = "square", joints = "miter"})
          mt(-19,-19);lt(-19,-19)
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [73] = {
        sprite = (function()
          local s = tolua(sprite());local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          bf(0xCC000000);mt(0,0);lt(-19,-19);lt(-19,19);lt(0,0);ef()bf(0x99000000);lt(-19,-19);lt(19,-19);lt(0,0);ef()bf(0x66000000);lt(19,-19);lt(19,19);lt(0,0);ef()bf(0x33000000);lt(-19,19);lt(19,19);lt(0,0);ef()
          return s
        end)(),
      },
      [74] = {
        sprite = (function()
          local s = tolua(sprite());local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          bf(0xCC000000);mt(0,0);lt(-19,-19);lt(-19,19);lt(0,0);ef()bf(0x99000000);lt(-19,-19);lt(19,-19);lt(0,0);ef()bf(0x66000000);lt(19,-19);lt(19,19);lt(0,0);ef()bf(0x33000000);lt(-19,19);lt(19,19);lt(0,0);ef()
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = "square", joints = "miter"})
          mt(-19,19);lt(-19,-19);lt(19,-19);lt(19,19);
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [75] = {
        sprite = (function()
          local s = tolua(sprite());local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          bf(0xCC000000);mt(0,0);lt(-19,-19);lt(-19,19);lt(0,0);ef()bf(0x99000000);lt(-19,-19);lt(19,-19);lt(0,0);ef()bf(0x66000000);lt(19,-19);lt(19,19);lt(0,0);ef()bf(0x33000000);lt(-19,19);lt(19,19);lt(0,0);ef()
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = "square", joints = "miter"})
          mt(-19,-19);lt(-19,19);mt(19,-19);lt(19,19);
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [76] = {
        sprite = (function()
          local s = tolua(sprite());local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          bf(0x7F000000);mt(-9,9);lt(9,9);lt(9,-9);lt(-9,9);ef();
          bf(0x99000000);mt(-9,9);lt(-9,-9);lt(9,-9);lt(-9,9);ef();
          bf(0x99000000);mt(-9,9);lt(-13,13);lt(13,13);lt(13,-13);lt(9,-9);lt(9,9);lt(-9,9);ef();
          bf(0xCC000000);mt(-9,9);lt(-13,13);lt(-13,-13);lt(13,-13);lt(9,-9);lt(-9,-9);lt(-9,9);ef();
          local dr = tolua(s.drawRect);
          bf(0xCC000000);dr(-13,13,26,7);dr(13,-13,7,26);ef();
          bf(0xE6000000);dr(-13,-20,26,7);dr(-20,-13,7,26);ef();
          bf(0xFFFFFFFF);dr(-20,-13,2,26);dr(18,-13,2,26);dr(-13,18,26,2);dr(-13,-20,26,2);
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [77] = {
        sprite = (function()
          local s = tolua(sprite());local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          bf(0x7F000000);mt(-9,9);lt(9,9);lt(9,-9);lt(-9,9);ef();
          bf(0x99000000);mt(-9,9);lt(-9,-9);lt(9,-9);lt(-9,9);ef();
          bf(0x99000000);mt(-9,9);lt(-13,13);lt(13,13);lt(13,-13);lt(9,-9);lt(9,9);lt(-9,9);ef();
          bf(0xCC000000);mt(-9,9);lt(-13,13);lt(-13,-13);lt(13,-13);lt(9,-9);lt(-9,-9);lt(-9,9);ef();
          local dr = tolua(s.drawRect);
          bf(0xCC000000);dr(-13,13,26,7);dr(13,-13,7,26);ef();
          bf(0xE6000000);dr(-13,-20,26,7);dr(-20,-13,7,26);ef();
          bf(0xFFFFFFFF);dr(-13,-20,26,2);
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [78] = {
        sprite = (function()
          local s = tolua(sprite());local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          bf(0x7F000000);mt(-9,9);lt(9,9);lt(9,-9);lt(-9,9);ef();
          bf(0x99000000);mt(-9,9);lt(-9,-9);lt(9,-9);lt(-9,9);ef();
          bf(0x99000000);mt(-9,9);lt(-13,13);lt(13,13);lt(13,-13);lt(9,-9);lt(9,9);lt(-9,9);ef();
          bf(0xCC000000);mt(-9,9);lt(-13,13);lt(-13,-13);lt(13,-13);lt(9,-9);lt(-9,-9);lt(-9,9);ef();
          local dr = tolua(s.drawRect);
          bf(0xCC000000);dr(-13,13,26,7);dr(13,-13,7,26);ef();
          bf(0xE6000000);dr(-13,-20,26,7);dr(-20,-13,7,26);ef();
          bf(0xFFFFFFFF);dr(-20,-13,2,26);dr(-13,-20,26,2);
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [80] = {
        sprite = (function()
          local s = tolua(sprite());local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          bf(0x7F000000);mt(-9,9);lt(9,9);lt(9,-9);lt(-9,9);ef();
          bf(0x99000000);mt(-9,9);lt(-9,-9);lt(9,-9);lt(-9,9);ef();
          bf(0x99000000);mt(-9,9);lt(-13,13);lt(13,13);lt(13,-13);lt(9,-9);lt(9,9);lt(-9,9);ef();
          bf(0xCC000000);mt(-9,9);lt(-13,13);lt(-13,-13);lt(13,-13);lt(9,-9);lt(-9,-9);lt(-9,9);ef();
          local dr = tolua(s.drawRect);
          bf(0xCC000000);dr(-13,13,26,7);dr(13,-13,7,26);ef();
          bf(0xE6000000);dr(-13,-20,26,7);dr(-20,-13,7,26);ef();
          return s
        end)(),
      },
      [81] = {
        sprite = (function()
          local s = tolua(sprite());local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          bf(0x7F000000);mt(-9,9);lt(9,9);lt(9,-9);lt(-9,9);ef();
          bf(0x99000000);mt(-9,9);lt(-9,-9);lt(9,-9);lt(-9,9);ef();
          bf(0x99000000);mt(-9,9);lt(-13,13);lt(13,13);lt(13,-13);lt(9,-9);lt(9,9);lt(-9,9);ef();
          bf(0xCC000000);mt(-9,9);lt(-13,13);lt(-13,-13);lt(13,-13);lt(9,-9);lt(-9,-9);lt(-9,9);ef();
          local dr = tolua(s.drawRect);
          bf(0xCC000000);dr(-13,13,26,7);dr(13,-13,7,26);ef();
          bf(0xE6000000);dr(-13,-20,26,7);dr(-20,-13,7,26);ef();
          bf(0xFFFFFFFF);dr(-20,-13,2,26);dr(18,-13,2,26);dr(-13,-20,26,2);
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [82] = {
        sprite = (function()
          local s = tolua(sprite());local bf = tolua(s.beginFill); local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);local ef = tolua(s.endFill);
          bf(0x7F000000);mt(-9,9);lt(9,9);lt(9,-9);lt(-9,9);ef();
          bf(0x99000000);mt(-9,9);lt(-9,-9);lt(9,-9);lt(-9,9);ef();
          bf(0x99000000);mt(-9,9);lt(-13,13);lt(13,13);lt(13,-13);lt(9,-9);lt(9,9);lt(-9,9);ef();
          bf(0xCC000000);mt(-9,9);lt(-13,13);lt(-13,-13);lt(13,-13);lt(9,-9);lt(-9,-9);lt(-9,9);ef();
          local dr = tolua(s.drawRect);
          bf(0xCC000000);dr(-13,13,26,7);dr(13,-13,7,26);ef();
          bf(0xE6000000);dr(-13,-20,26,7);dr(-20,-13,7,26);ef();
          bf(0xFFFFFFFF);dr(-20,-13,2,26);dr(18,-13,2,26);
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [83] = {
        sprite = (function()
          local s = tolua(sprite()); local rect = tolua(s.drawRect);
          s.beginFill(0xA0000000)
          rect(-19,-19,11,11);rect(8,-19,11,11);rect(-19,8,11,11);rect(8,8,11,11);
          s.beginFill(0x80000000)
          ;rect(-6,8,12,11);rect(-6,-19,12,11);rect(-19,-6,11,12);rect(8,-6,11,12)
          s.beginFill(0x60000000)
          rect(-6,-6,12,12)
          s.endFill()
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = square,pixelHinting = true,joints = "miter"})
          s.moveTo(-19,19);s.lineTo(-19,-19);s.lineTo(19,-19);s.lineTo(19,19);s.lineTo(-19,19);
          s.endFill()
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"},
      },
      [84] = {
        sprite = (function()
          local s = tolua(sprite()); local dc = tolua(s.drawCircle)
          s.lineStyle(0xFFFFFFFF,2)
          dc(0,0,19)
          s.beginGradientFill(
            toarray{0xFF80FFFF,0xFF40FFFF},
            toarray{0,255},
            toobject{
              type = "radial",
              width = 26, height = 26, x = -13, y = -13,
              spreadMethod = "repeat",
            }
          )
          dc(0,0,13)
          s.endFill()
          return s
        end)(),
        hb = {x1 = -18, y1 = -18, x2 = 18, y2 = 18, t = "special",f = function(o,p)
          local att = physics.getAttempts()
          if o.attemptUsed ~= att and p.pressed and p.action then
            p.action = false
            o.attemptUsed = att
            p.vy = ({
              cube = 477.825 * .5,
              ship = 477.825 * .5,
              ball = 332.4 * .5,
              ufo = 477.825 * .5,
            })[p.mode] * p.gravity
            if p.size == 0.6 then p.vy = p.vy*0.8 end
            p.gravity = -p.gravity
            p.onGround = false
          end
        end}
      },
      [88] = {
        sprite = (function()
          local s = tolua(sprite())
          s.beginGradientFill(
            toarray{0x00000000,0xFF000000},
            toarray{0,255},
            toobject{
              type = "radial", x = -36, y = -36, width = 72, height = 72, spreadMethod = "pad"
            }
          )
          local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);
          mt(0,-58);
          for i=0,18 do
            local theta = (2*math.pi*i/18)
            local x,y = math.sin(theta),-math.cos(theta)
            lt(x*58,y*58);lt(x*41,y*41);
          end
          s.endFill()
          return s
        end)(),
        hb = {r = 32, t = "kill", type = "circle"}
      },
      [89] = {
        sprite = (function()
          local s = tolua(sprite())
          s.beginGradientFill(
            toarray{0x00000000,0xFF000000},
            toarray{0,255},
            toobject{
              type = "radial", x = -23, y = -23, width = 46, height = 46, spreadMethod = "pad"
            }
          )
          local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);
          mt(0,-39);
          for i=0,12 do
            local theta = (2*math.pi*i/12)
            local x,y = math.sin(theta),-math.cos(theta)
            lt(x*39,y*39);lt(x*27,y*27);
          end
          s.endFill()
          return s
        end)(),
        hb = {r = 21, t = "kill", type = "circle"}
      },
      [90] = {
        sprite = (function()
          local s = tolua(sprite())
          s.beginFill(0xFF000000)
          s.drawRect(-20,-20,40,40)
          s.endFill()
          s.lineStyle(0xFFFFFFFF,2,toobject{
            joints = "miter",
            pixelHinting = true
          })
          s.drawRect(-19,-19,38,38)
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [91] = {
        sprite = (function()
          local s = tolua(sprite())
          s.beginFill(0xFF000000)
          s.drawRect(-20,-20,40,40)
          s.endFill()
          s.beginFill(0xFFFFFFFF)
          s.drawRect(-20,-20,40,2);
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [92] = {
        sprite = (function()
          local s = tolua(sprite())
          s.beginFill(0xFF000000)
          s.drawRect(-20,-20,40,40)
          s.endFill()
          s.beginFill(0xFFFFFFFF)
          s.drawRect(-20,-20,40,2);
          s.drawRect(-20,-20,2,40);
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [93] = {
        sprite = (function()
          local s = tolua(sprite())
          s.beginFill(0xFF000000)
          s.drawRect(-20,-20,40,40)
          s.endFill()
          s.beginFill(0xFFFFFFFF)
          s.drawRect(-20,-20,2,2);
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [94] = {
        sprite = (function()
          local s = tolua(sprite())
          s.beginFill(0xFF000000)
          s.drawRect(-20,-20,40,40)
          s.endFill()
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [95] = {
        sprite = (function()
          local s = tolua(sprite())
          s.beginFill(0xFF000000)
          s.drawRect(-20,-20,40,40)
          s.endFill()
          s.beginFill(0xFFFFFFFF)
          s.drawRect(-20,-20,40,2);
          s.drawRect(-20,-20,2,40);
          s.drawRect(19,-20,2,40);
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [96] = {
        sprite = (function()
          local s = tolua(sprite())
          s.beginFill(0xFF000000)
          s.drawRect(-20,-20,40,40)
          s.endFill()
          s.beginFill(0xFFFFFFFF)
          s.drawRect(-20,-20,2,40);
          s.drawRect(19,-20,2,40);
          return s
        end)(),
        hb = {x1 = -15, y1 = -15, x2 = 15, y2 = 15, t = "block"}
      },
      [98] = {
        sprite = (function()
          local s = tolua(sprite())
          s.beginGradientFill(
            toarray{0x00000000,0xFF000000},
            toarray{0,255},
            toobject{
              type = "radial", x = -16, y = -16, width = 32, height = 32, spreadMethod = "pad"
            }
          )
          local mt = tolua(s.moveTo); local lt = tolua(s.lineTo);
          mt(0,-27);
          for i=0,9 do
            local theta = (2*math.pi*i/9)
            local x,y = math.sin(theta),-math.cos(theta)
            lt(x*27,y*27);lt(x*18,y*18);
          end
          s.endFill()
          return s
        end)(),
        hb = {r = 12, t = "kill", type = "circle"}
      },
      [103] = {
        sprite = (function()
          local s = tolua(sprite()); local mt = tolua(s.moveTo);
          s.lineStyle(0xFFFFFFFF,2,toobject{caps = square,pixelHinting = true,joints = "miter"})
          s.beginGradientFill(toarray{0xFF000000,0x00000000},toarray{0,255},toobject{width = 27,height = 27,x = -14,y = -14,rotation = 90})
          s.moveTo(0,-13)
          s.lineTo(13,12)
          s.lineTo(-13,12)
          s.lineTo(0,-13)
          s.endFill()
          return s
        end)(),
        hb = {x1 = -2, y1 = -4, x2 = 2, y2 = 4, t = "kill"},
      },

    }

    ground_Sprite = tolua(sprite())

    do -- define ground sprite, repeats every 4 blocks
      local s = ground_Sprite
      local rect = tolua(s.drawRect);
      s.beginFill(0x40000000)
      rect(8,8,144,144)
      s.beginGradientFill(toarray{0x40000000,0xD0000000},toarray{0,255},toobject{width = 160,height = 160,x = 0,y = 0,rotation = 90})
      rect(0,0,160,160)
      s.endFill();
      s.lineStyle(0xFFFFFFFF,3,toobject{caps = square,pixelHinting = true,joints = "miter"})
      s.moveTo(0,1);s.lineTo(160,1);
      s.endFill()
    end

  end
  
  local function wait() -- To chill out.
    coroutine.yield()
  end

  loader = {}

  do --[[ STRING READER ]]--

    local function split(str) -- First splits into individual object strings.
      local strs = {}
      local find = string.find
      local i = 1
      local pos = find(str,';',1,true)
      while true do
        local p2 = find(str,';',pos+1,true)
        if p2 then
          strs[i] = str:sub(pos+1,p2-1)
          i = i + 1
          pos = p2
        else
          break
        end
        if i%500 == 0 then 
          player.chat("splitter: " .. i .. ", " .. pos .. "/" .. #str)
          wait() 
        end
      end
      return strs
    end

    local function parseOne(str) -- Parses an individual string and creates an object.
      local baseObj = {}
      local find = string.find
      local pos = 1
      while true do
        local p1 = find(str,',',pos,true) -- find first, then second comma
        if not p1 then break end
        local p2 = find(str,',',p1+1,true)
        if not p2 then
          p2 = #str + 1
        end
        local pType = str:sub(pos,p1-1)
        local pValue = tonumber(str:sub(p1+1,p2-1))
        baseObj[pType] = pValue
        pos = p2+1
      end
      local obj = {}
      for i in pairs(baseObj) do
        local vType = vTypes[i]
        if not vType then -- Unrecognized property, omit!
          local u = unreq.vTypes[i] or 0
          unreq.vTypes[i] = u + 1
          obj[i] = baseObj[i] -- Put it in there by numerical ID
        else
          obj[vType] = baseObj[i]
        end
      end
      if not obj.id then -- Object doesn't have an id?
        no_ID = no_ID + 1
        return nil
      end
      if not ID_DEFS[obj.id] then
        local u = unreq.ids[obj.id] or 0
        unreq.ids[obj.id] = u + 1
        return nil
      end
      return obj
    end

    loader.split = split
    loader.parseOne = parseOne
  end --[[ END STRING READER ]]--

  do --[[ OBJECT PLACER ]]--
    local bg_layer = game.level.newArtLayer(0)
    local bg_overlay = game.level.newArtLayer(0)
    --local ground_Layer = game.level.newArtLayer(1)
    local blendLayer = game.level.newArtLayer(1)
    local layer = game.level.newArtLayer(1)
    --local groundDrawSprite = tolua(ground_Layer.drawSprite)
    local drawSprite = tolua(layer.drawSprite)
    local drawBlendSprite = tolua(blendLayer.drawSprite)

    blendLayer.blendMode = "add"

    -- ground_Sprite

    local function place(obj)
      local sprite = ID_DEFS[obj.id].sprite
      if not sprite then 
        if ID_DEFS[obj.id].sprites then loader.placeCompound(obj) end
        return 
      end
      local blend = ID_DEFS[obj.id].blend or "normal"
      local x = (obj.x or 0) * (40/30)
      local y = (obj.y or 0) * -(40/30)
      local scaleX = (obj.scale or 1) * SCALE * 32/30
      local scaleY = (obj.scale or 1) * SCALE * 32/30
      if obj.flipX then scaleX = -scaleX end
      if obj.flipY then scaleY = -scaleY end
      local rotation = (obj.rotation or 0)
      if blend == "normal" then
        drawSprite(sprite,x*SCALE,y*SCALE,scaleX,scaleY,rotation)
      elseif blend == "add" then
        drawBlendSprite(sprite,x*SCALE,y*SCALE,scaleX,scaleY,rotation)
      end
    end

    local function placeCompound(obj)
      local id_def = ID_DEFS[obj.id]
      local sprites = id_def.sprites
      if not sprites then return end
      local x = (obj.x or 0) * (40/30)
      local y = (obj.y or 0) * -(40/30)
      local scaleX = (obj.scale or 1) * SCALE * 32/30
      local scaleY = (obj.scale or 1) * SCALE * 32/30
      if obj.flipX then scaleX = -scaleX end
      if obj.flipY then scaleY = -scaleY end
      local rotation = (obj.rotation or 0)
      for i=1,#sprites do
        local s = sprites[i]
        local blend = id_def["blend"..i] or "normal"
        if blend == "normal" then
          drawSprite(s,x*SCALE,y*SCALE,scaleX,scaleY,rotation)
        elseif blend == "add" then
          drawBlendSprite(s,x*SCALE,y*SCALE,scaleX,scaleY,rotation)
        end
      end
    end

    loader.place = place
    loader.placeCompound = placeCompound
    loader.baseGroundDraw = groundDrawSprite
    loader.bg_layer = tolua(bg_layer)
    loader.bg_overlay = tolua(bg_overlay)
  end

  do -- set up loader coroutine
    local completed = false
    local provideObjTo = {}
    local maximumX = -1000

    function loader.requestObjects(callback)
      provideObjTo[#provideObjTo + 1] = callback
    end


    --loader.bg_layer.setRect(-675,-480,2025,1440,0xFF283EFF)
    loader.startColorBG = {102, 0, 99}
    loader.startColorG = {191, 0, 255}

    --[[ OLD

    do
      local overRect = tolua(game.level.newSprite())
      overRect.beginFill(0x0f000000)
      overRect.drawRect(0,0,100,100)
      overRect.endFill()
      local dSprite = tolua(loader.bg_overlay.drawSprite)
      for i=1,120 do
        local s1 = math.random()*4
        local x,y = math.random(-675,-675+2025), math.random(-480,-480 + 1440)
        dSprite(overRect,x,y,s1,s1+((math.random()-0.5)*s1/2))
      end
    end

    ]]--
    xpcall(function()
    do
      local PADDING = 0.13 * SCALE
      local overRect = tolua(game.level.newSprite())
      overRect.alpha = 0.32
      --loader.bg_overlay.alpha = 0.35
      overRect.beginGradientFill(
        toarray{0xF0000000,0x10000000},
        toarray{0,255},
        toobject{
          width = 60, height = 60, --x = 30, y = 30,
          rotation = 90, spreadMethod = "pad"
        }
      )
      overRect.drawRect(0,0,60,60)
      overRect.endFill()
      overRect.lineStyle(0x28000000,3*SCALE,toobject{scaleMode = "none"})
      overRect.moveTo(1,0);overRect.lineTo(60,0);overRect.lineTo(60,55);
      local offx, offy = math.random(-30,30), math.random(-30,30)
      -- window = 675 x 480
      -- ARR WIDTH = 20 (20*60 = 1200), HEIGHT = 15 (15*60 = 900)
      -- START -300 on x, -200 on y (Padding)
      local function convArrToPos(x,y)
        return -360 + 60*x + offx, -260 + 60*y + offy
      end
      local function genArr(fill)
        local ARR = {}
        for i=1,20 do local u = {}; ARR[i] = u
          for j = 1,15 do u[j] = fill end
        end
        return ARR
      end
      local arrays = {genArr(true),genArr(true),genArr(true),genArr(true)};
      local posCount = {20*15,20*15,20*15,20*15}
      local function fillSquare(arrnum,x1,y1,x2,y2,fill)
        if x1 < 1 then x1 = 1 end
        if y1 < 1 then y1 = 1 end
        if x2 > 20 then x2 = 20 end
        if y2 > 15 then y2 = 15 end
        for x = x1,x2 do local u = arrays[arrnum][x]
          for y = y1,y2 do 
            if u[y] ~= fill then
              u[y] = fill; 
              posCount[arrnum] = posCount[arrnum] - 1
            end
          end
        end
        --posCount[arrnum] = posCount[arrnum] - ((x2-x1+1) * (y2-y1+1))
      end  -- me omw to write the most awful code known to man
      local rand = math.random
      local dSprite = tolua(loader.bg_overlay.drawSprite)
      -- Stage 1
        while true do
          local x,y = rand(1,20),rand(1,15)
          if arrays[1][x][y] then
            fillSquare(1,x-3,y-3,x+3,y+3,false)
            fillSquare(2,x-2,y-2,x+3,y+3,false)
            fillSquare(3,x-1,y-1,x+3,y+3,false)
            fillSquare(4,x,y,x+3,y+3,false)
            local rx,ry = convArrToPos(x,y)
            dSprite(overRect,rx,ry,4*SCALE - PADDING,4*SCALE - PADDING,0)
          end
          if posCount[4] < (0.75*20*15) or posCount[1] == 0 then break end
        end
      -- Stage 2
        while true do
          local x,y = rand(1,20),rand(1,15)
          if arrays[2][x][y] then
            fillSquare(2,x-2,y-2,x+2,y+2,false)
            fillSquare(3,x-1,y-1,x+2,y+2,false)
            fillSquare(4,x,y,x+2,y+2,false)
            local rx,ry = convArrToPos(x,y)
            dSprite(overRect,rx,ry,3*SCALE - PADDING,3*SCALE - PADDING,0)
          end
          if posCount[4] < (0.5*20*15) or posCount[2] == 0 then break end
        end
      -- Stage 3
        while true do
          local x,y = rand(1,20),rand(1,15)
          if arrays[3][x][y] then
            fillSquare(3,x-1,y-1,x+1,y+1,false)
            fillSquare(4,x,y,x+1,y+1,false)
            local rx,ry = convArrToPos(x,y)
            dSprite(overRect,rx,ry,2*SCALE - PADDING,2*SCALE - PADDING,0)
          end
          if posCount[4] < (0.25*20*15) or posCount[3] == 0 then break end
        end
      -- Final stage
        for x = 1,20 do for y = 1,15 do
          if arrays[4][x][y] then
            local rx,ry = convArrToPos(x,y)
            dSprite(overRect,rx,ry,SCALE - PADDING,SCALE - PADDING,0)
          end
        end end


    end
    end,function(err) player.alert(err) end)

    local function load()
      local strs = loader.split(levelString)
      local objs = {}
      local oLen = 1
      for i=1,#strs do
        local obj = loader.parseOne(strs[i])
        if obj then
          objs[oLen] = obj
          oLen = oLen + 1
        end
        if i%200 == 0 then
          chat("Parsed ".. i .. "/".. #strs .." objects")
          wait()
        end
      end 
      local maxX = 0
      for i=1,(oLen-1) do
        local o = objs[i]
        loader.place(o)
        if o.x and o.x > maxX then maxX = o.x end
        if i%40 == 0 then
          chat("Placed ".. i .. "/".. oLen-1 .." objects")
          wait()
        end
      end
      maximumX = maxX + 300
      --[[ no ground, something else handles it.
      for x=-320,((maxX+300)*(40/30)),160 do
        loader.baseGroundDraw(ground_Sprite,x*SCALE,0,SCALE,SCALE)
        if x%800 == 0 then
          chat("Ground at " .. x .. "/" .. ((maxX+400)*(40/30)))
          wait()
        end
      end
      ]]--
      player.chat("Providing objects to ".. #provideObjTo .." systems.")
      for i = 1, #provideObjTo do
        provideObjTo[i](objs,wait) -- Optionally provide wait function.
        wait()
      end

      player.chat("Level loaded!")
      local uStr = ""
      if no_ID > 0 then
        uStr = uStr .. "Objects without ID: ".. no_ID .. "\n"
      end
      uStr = uStr .. "Instances of unrecognized IDs: \n"
      local uID = 0
      for i in pairs(unreq.ids) do
        uStr = uStr .. i .. ": ".. unreq.ids[i] .. "\n"
        uID = uID + 1
      end
      local uPar = 0
      uStr = uStr .. "Instances of unrecognized paramTypes: \n"
      for i in pairs(unreq.vTypes) do
        uStr = uStr .. i .. ": ".. unreq.vTypes[i] .. "\n"
        uPar = uPar + 1
      end
      if no_ID > 0 or uID > 0 or uPar > 0 then
        player.alert(uStr)
      end
      completed = true
    end -- end Loader

    loader.co = coroutine.create(load)
    local coAlive = false

    function loader.startCoroutine()
      coAlive = true
    end

    function loader.getMaxX()
      return maximumX
    end

    local tick = {}

    local nameList = {}

    function loader.attachSystem(Func,Name)
      nameList[#nameList + 1] = Name
      tick[Name] = Func
    end

    
    player.tick.addListener(function()
      if coAlive then -- Still loading!
        local u,err = coroutine.resume(loader.co)
        if err then 
          if err == "cannot resume dead coroutine" then
            coAlive = false
          else
            player.chat(err,0xFF0000) 
          end
        end
      elseif completed then -- Tick everything
        for i=1,#nameList do
          xpcall(tick[nameList[i]],function(err)
            player.chat("ERROR: ".. err,0xFF0000)
          end)
        end
      end
    end)

  end
  
  
end)
