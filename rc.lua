-- rc.lua for awesome-git'ish window manager
---------------------------
-- bioe007, perrydothargraveatgmaildotcom
--
print("Entered rc.lua: " .. os.time())
require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
require("naughty")
-- custom modules
require("markup")
require("shifty")
require("mocp")
require("calendar")
require("battery")
require("markup")
require("fs")
require("volume")
require("vicious")
require("revelation")
print("Modules loaded: " .. os.time())

settings = {}
settings.theme_path = os.getenv("HOME").."/.config/awesome/themes/grey"
beautiful.init(settings.theme_path.."/theme.lua")

-- {{{ Variable definitions
settings = {
  modkey = "Mod4",
  theme_path = os.getenv("HOME").."/.config/awesome/themes/grey",
  icon_path = beautiful.iconpath,

  --{{{ apps
  apps = {
    terminal  = "urxvt",
    browser   = "firefox",
    mail      = "/home/perry/.bin/mutt-start.sh",
    filemgr   = "thunar",
    music     = "mocp --server",
    editor    = "/home/perry/.bin/vim-start.sh"
  },
  --}}}

  --{{{ settings.layouts
  layouts = {
    awful.layout.suit.tile.left,
    awful.layout.suit.tile,
    awful.layout.suit.max,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating
  },
  --}}}

  -- {{{ opacity
  opacity = { 
    default = { focus = 1.0, unfocus = 0.8 },
    Easytag = { focus = 1.0, unfocus = 0.9 },
    Gschem  = { focus = 1.0, unfocus = 1.0 },
    Gimp    = { focus = 1.0, unfocus = 1.0 },
    MPlayer = { focus = 1.0, unfocus = 1.0 },
  },
  -- }}}
}

--{{{ SHIFTY configuration
--{{{ configured tags
shifty.config.tags = {
  w2     =  { layout = awful.layout.suit.tile.bottom, mwfact = 0.62,
                exclusive = false, solitary = false, position = 1, init = true,
                screen = 2 }, 

  vim     =  { layout = awful.layout.suit.tile, mwfact = 0.62,
                exclusive = false, solitary = false, position = 1, init = true,
                screen = 1, slave = true, spawn = settings.apps.editor  }, 

  ds     =  { layout = awful.layout.suit.max        , mwfact = 0.70,
                exclusive = false, solitary = false, position = 2, init = false,
                persist = false, nopopup = false , slave = false }, 

  dz     =  { layout = awful.layout.suit.tile       , mwfact = 0.70,
                exclusive = false, solitary = false, position = 3, init = false,
                nopopup = true, leave_kills = true }, 

  web    =  { layout = awful.layout.suit.tile.bottom, mwfact = 0.65,
                exclusive = true, solitary = true, position = 4,  init = false,
                spawn   = settings.apps.browser }, 

  mail   =  { layout = awful.layout.suit.tile        , mwfact = 0.55,
                exclusive = false, solitary = false, position = 5, init = false,
                spawn   = settings.apps.mail, slave       = true  }, 

  vbx    =  { layout = awful.layout.suit.tile.bottom , mwfact = 0.75,
                exclusive = true, solitary = true, position = 6, init = false,
                spawn = 'VBoxSDL -vm xp2' }, 


  media  =  { layout = awful.layout.suit.floating    , exclusive = false , 
                solitary  = false, position = 8     }, 

  gimp  =  { layout = awful.layout.suit.tile    , exclusive = false , 
                solitary  = false, position = 8, ncol = 3, mwfact = 0.75,
                nmaster=1,
                spawn = 'gimp-2.6', slave = true                                    }, 

  office =  { layout = awful.layout.suit.tile        , position  = 9 }
}
--}}}

--{{{ application matching rules
shifty.config.apps = {
  { match   = { "vim","gvim" }, 
    tag     = "vim"                                         },

  { match   = { "Navigator","Vimperator","Gran Paradiso" }, 
    tag     = "web"                                         },

  { match   = { "mutt", "Shredder.*" },
    tag     = "mail"                                        },

  { match   = { "OpenOffice.*" },
    tag     = "office"                                      },

  { match   = { "pcb","gschem", "eagle" },
    tag     = "dz",
    slave   = false                                         },

  { match   = { "PCB_Log","Status","Page Manager" }, 
    tag     = "dz", 
    slave   = true                                          },

  { match   = { "acroread","Apvlv","Evince" }, 
    tag     = "ds"                                          },

  { match   = { "VBox.*","VirtualBox.*" },
    tag     = "vbx"                                         },

  { match   = { "Mirage","gtkpod","Ufraw","easytag"},
    tag     = "media",
    nopopup = true                                          },

  { match   = { "gimp%-image%-window","Ufraw"               },
    tag     = "gimp"                                        },

  { match   = { "gimp%-dock","gimp%-toolbox" },
    tag     = "gimp",                                     
    slave   = true, dockable = true, honorsizehints=false   },

  { match   = { "dialog", "Gnuplot", "galculator","R Graphics" }, 
    float   = true, honorsizehints = true                   },

  { match   = { "MPlayer" }, 
    float   = true, honorsizehints = true, ontop=true       },

  { match   = { "urxvt","vim","mutt" },
    honorsizehints = false, 
    slave   = true                                          },

  { match = { "" }, 
    buttons = awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
        awful.button({ settings.modkey }, 1, awful.mouse.client.move),
        awful.button({ settings.modkey }, 3, awful.mouse.client.resize),
        awful.button({ settings.modkey }, 8, awful.mouse.client.resize))
  }
}
--}}}

shifty.config.defaults={ layout = awful.layout.suit.tile.bottom, ncol = 1, floatBars=true, 
    run = function(tag)
            naughty.notify({ text = markup.fg(beautiful.fg_normal, markup.fg( beautiful.fg_sb_hi, "Shifty Created: "..
                            (awful.tag.getproperty(tag,"position") or shifty.tag2index(mouse.screen,tag)).." : "..
                            (tag.name or "foo")))
            })
        end, 
}

shifty.config.sloppy = true

-- }}}

shifty.modkey = settings.modkey
-- }}}

-- {{{ tag run or raise
function tagSearch(name)
  for s = 1, screen.count() do
    t = shifty.name2tag(name,s)
    if t ~= nil then
        if t.screen ~= mouse.screen then
            awful.screen.focus(t.screen)
        end
      awful.tag.viewonly(t)
      return true
    end
  end
  return false
end
-- }}}

-- {{{ wip
function tagScreenless()
    local allTags = {}
    local curTag = awful.tag.selected()
    for s = 1, screen.count() do
        t = shifty.name2tag(name,s)
        if t ~= nil then
            awful.tag.viewonly(t)
            awful.screen.focus(awful.util.cycle(screen.count(),s+mouse.screen))
            return true
        end
    end
    return false
end
-- }}}

-- {{{ tagPop() 
-- Called externally and just pops to or merges with my active vim server when 
-- new files are dumped to it. (vim-start.sh) 
-- though it could easily be used with any tag by passing a different 'name'
-- parameter
function tagPop(name)
    for s = 1, screen.count() do
        t = shifty.name2tag(name,s)
        if t ~= nil then
            if t.screen == awful.tag.selected().screen then
                t.selected = true
                awful.screen.focus(awful.util.cycle(screen.count(),s+mouse.screen))
            else
                awful.tag.viewonly(t)
                awful.screen.focus(awful.util.cycle(screen.count(),s+mouse.screen))
            end
        end
    end
end
-- }}}

-- {{{ widgets
widgets = {}

widgets.systray = widget({ type = "systray" }) 

-- {{{ -- SPACERS
widgets.lspace       = widget({ type = "textbox", align = "left" }) 
widgets.lspace.text  = " "
widgets.lspace.width = 5
widgets.rspace       = widget({type = "textbox", align = "right" }) 
widgets.rspace.text  = " "
widgets.rspace.width = 5
--}}}


-- {{{ -- DATE 
widgets.date = widget({type="textbox", align = 'right' })
widgets.date:add_signal("mouse::enter",function() calendar.add(0) end)
widgets.date:add_signal("mouse::leave",calendar.remove) 
widgets.date:buttons(awful.util.table.join(
  awful.button({}, 1, function() print("calendar add"); calendar.add(-1) end),
  awful.button({}, 4, function() print("calendar add"); calendar.add(-1) end),
  awful.button({}, 5, function() calendar.add(1) end)
))
vicious.register(
    widgets.date,
    vicious.widgets.date,
    markup.fg(beautiful.fg_sb_hi, '%k:%M'),
    59)
-- }}}

-- {{{ -- CPU
widgets.cpu = widget({type = "textbox", align = 'right' })
widgets.cpu.width = 40
vicious.register(
    widgets.cpu,
    vicious.widgets.cpu,
    'cpu:' .. markup.fg(beautiful.fg_sb_hi, '$2')
    )
-- }}}

-- {{{ MEMORY
widgets.memory = widget({type = "textbox", align = 'right' })
widgets.memory.width = 45
vicious.register(
    widgets.memory,
    vicious.widgets.mem,
    'mem:' ..  markup.fg(beautiful.fg_sb_hi,'$1')
    )
-- }}}

--{{{ MOCP, FS and BATTERY
widgets.mocp = mocp.init(settings.theme_path.."/music/sonata.png")
widgets.mocp.width = 120 

widgets.diskspace = fs.init({interval = 59,
                                parts = { ['sda7'] = {label = "/"},
                                          ['sda5'] = {label = "d"} } }) 
widgets.battery = battery.init()

-- VOLUME :: FIXME :: my buttons are broke
widgets.volume = volume.init()
--}}}

-- {{{ -- TAGLIST
widgets.taglist = {}
widgets.taglist.buttons = awful.util.table.join(
        awful.button({                } , 1, awful.tag.viewonly    ) , 
        awful.button({ settings.modkey} , 1, awful.client.movetotag) , 
        awful.button({                } , 3, awful.tag.viewtoggle  ) , 
        awful.button({ settings.modkey} , 3, awful.client.toggletag) , 
        awful.button({                } , 4, awful.tag.viewnext    ) , 
        awful.button({                } , 5, awful.tag.viewprev    ) 
    )
--}}}

-- {{{ -- TASKLIST
widgets.tasklist = {}
widgets.tasklist.buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
        if not c:isvisible() then awful.tag.viewonly(c:tags()[1]) end
        client.focus = c
        c:raise()
  end),

  awful.button({ }, 3, function ()
    if instance then instance:hide(); instance = nil
    else instance = awful.menu.clients({ width=250 }) end
  end),

  awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),

  awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end))

--}}}

widgets.promptbox = {}
widgets.layoutbox = {}
widgets.wibox = {}

-- {{{ -- STATUSBAR 
widget_table1 = {
    widgets.rspace   , 
    widgets.cpu      , widgets.rspace, 
    widgets.memory   , widgets.rspace, 
    widgets.battery  , widgets.rspace, 
    widgets.diskspace, widgets.rspace, 
    widgets.volume   , widgets.rspace, 
    widgets.mocp     , widgets.rspace, 
    widgets.systray  , widgets.rspace, 
    widgets.date     , widgets.rspace, 
    layout = awful.widget.layout.horizontal.rightleft
}

for s = 1, screen.count() do

    widgets.promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })

    widgets.layoutbox[s] = awful.widget.layoutbox(s)

    widgets.layoutbox[s]:buttons(awful.util.table.join(
            awful.button({}, 1, function () awful.layout.inc(settings.layouts, 1 ) end),
            awful.button({}, 3, function () awful.layout.inc(settings.layouts, -1) end),
            awful.button({}, 4, function () awful.layout.inc(settings.layouts, 1 ) end),
            awful.button({}, 5, function () awful.layout.inc(settings.layouts, -1) end))
        )

    -- Create a taglist widget
    widgets.taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, widgets.taglist.buttons)

    -- Create a tasklist widget
    widgets.tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, widgets.tasklist.buttons)

    -- add widgets to the 'statusbar' wibox
    widgets.wibox[s] = awful.wibox({ position = "top", screen = s })
    widgets.wibox[s].widgets = { 

        -- {{{ always have a taglist, promptbox and layoutbox
        { 
            layout = awful.widget.layout.horizontal.leftright,
            widgets.lspace      , widgets.layoutbox[s], 
            widgets.lspace      , widgets.taglist[s]  , 
            widgets.promptbox[s], widgets.lspace      , 
        },
        -- }}}
        
        (s==1 and widget_table1) or 
        { 
            widgets.rspace, widgets.date, widgets.rspace,
            layout = awful.widget.layout.horizontal.rightleft
        },

        widgets.tasklist[s], widgets.rspace,
        layout = awful.widget.layout.horizontal.leftright,
        height = widgets.wibox[s].height
    }
end

-- }}}

-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(

    awful.key({ settings.modkey }, "space", awful.tag.viewnext),  -- move to next tag
    awful.key({ settings.modkey, "Control"}, "space", function()  -- move to next tag on all screens
        for s=1,screen.count() do
            awful.tag.viewnext(screen[s])
        end
        end ),  
    awful.key({ settings.modkey, "Shift" }, "space", awful.tag.viewprev), -- move to previous tag
    awful.key({ settings.modkey, "Control", "Shift"}, "space", function()  -- move to previous tag on all screens
        for s=1,screen.count() do
            awful.tag.viewprev(screen[s])
        end
        end ),  
    awful.key({ settings.modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
    end),
    awful.key({ settings.modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
    end),
    awful.key({ settings.modkey,    }, "e",  revelation.revelation),

    -- shiftycentric
    awful.key({ settings.modkey            }, "Escape",  function() awful.tag.history.restore() end), -- move to prev tag by history
    awful.key({ settings.modkey, "Shift"   }, "n",       shifty.send_prev),          -- move client to prev tag
    awful.key({ settings.modkey            }, "n",       shifty.send_next),          -- move client to next tag
    awful.key({ settings.modkey, "Control" }, "n",       function ()                 -- move a tag to next screen
        local ts = awful.tag.selected()
        awful.tag.history.restore(ts.screen,1)
        shifty.set(ts,{ screen = awful.util.cycle(screen.count(), ts.screen +1)})
        awful.tag.viewonly(ts)
        mouse.screen = ts.screen

        if #ts:clients() > 0 then
            local c = ts:clients()[1]
            client.focus = c
            c:raise()
        end
        
    end),
    awful.key({ settings.modkey, "Shift"   }, "r",       shifty.rename),             -- rename a tag
    awful.key({ settings.modkey            }, "d",       shifty.del),                -- delete a tag
    awful.key({ settings.modkey, "Shift"   }, "a",       shifty.add),                -- creat a new tag

    -- Layout manipulation
    awful.key({ settings.modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
    awful.key({ settings.modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
    awful.key({ settings.modkey }, "s", function () awful.screen.focus_relative(1) end),
    awful.key({ settings.modkey, "Shift" }, "s", awful.client.movetoscreen),   -- switch client to other screen
    awful.key({ settings.modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ settings.modkey,           }, "Tab", function ()
            awful.client.focus.history.previous()
            if client.focus then client.focus:raise() end
            end),

    -- {{{ - APPLICATIONS
    awful.key({ settings.modkey }, "Return", function () awful.util.spawn(settings.apps.terminal,false) end),

    -- run or raise type behavior but with benefits of shifty
    awful.key({ settings.modkey},"w", function () if not tagSearch("web") then awful.util.spawn(settings.apps.browser) end end),
    awful.key({ settings.modkey },"m", function () if not tagSearch("mail") then awful.util.spawn(settings.apps.mail) end end),
    awful.key({ settings.modkey, "Mod1", "Shift" },"v", function () if not tagSearch("vbx") then awful.util.spawn('VBoxSDL -vm xp2') end end),
    awful.key({ settings.modkey },"g", function () if not tagSearch("dz") then awful.util.spawn('gschem') end end),
    awful.key({ settings.modkey },"p", function () if not tagSearch("dz") then awful.util.spawn('pcb') end end),

    awful.key({ settings.modkey, "Mod1" },"f", function () awful.util.spawn(settings.apps.filemgr) end),
    awful.key({ settings.modkey, "Mod1" },"c", function () awful.util.spawn("galculator",false) end),
    awful.key({ settings.modkey, "Mod1", "Shift" } ,"g", function () awful.util.spawn('gimp') end),
    awful.key({ settings.modkey, "Mod1" },"o", function () awful.util.spawn('/home/perry/.bin/octave-start.sh',false) end),
    awful.key({ settings.modkey, "Mod1" },"v", function () awful.util.spawn('/home/perry/.bin/vim-start.sh',false) end),
    awful.key({ settings.modkey, "Mod1" },"i", function () awful.util.spawn('gtkpod',false) end),
    -- }}}

    -- {{{ - MEDIA
    -- music player
    awful.key({ settings.modkey, "Mod1" }, "p", function() mocp.play("PLAY") end),
    awful.key({},"XF86AudioPlay",               function() mocp.play("PLAY") end),
    awful.key({ settings.modkey },"Down",       function() mocp.play("FWD") end ),
    awful.key({ settings.modkey },"Up",         function() mocp.play("REV") end),
    awful.key({},"XF86AudioPrev",               function() mocp.play("REV") end),
    awful.key({},"XF86AudioNext",               function() mocp.play("FWD") end ),
    awful.key({},"XF86AudioStop",               function() mocp.play("STOP") end),

    awful.key({},"XF86AudioRaiseVolume", function() volume.vol("up","5") end),
    awful.key({},"XF86AudioLowerVolume", function() volume.vol("down","5") end),
    awful.key({ settings.modkey },"XF86AudioRaiseVolume",function() volume.vol("up","2")end),
    awful.key({ settings.modkey },"XF86AudioLowerVolume", function() volume.vol("down","2")end),
    awful.key({},"XF86AudioMute", function() volume.vol() end),
    -- }}} 
    
    -- {{{ WM
    awful.key({ settings.modkey, "Control" }, "r", awesome.restart),
    awful.key({ settings.modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ settings.modkey,           }, "l",     function () awful.tag.incmwfact( 0.03)    end),
    awful.key({ settings.modkey,           }, "h",     function () awful.tag.incmwfact(-0.03)    end),
    awful.key({ settings.modkey,           }, "q",     function (c) awful.client.incwfact( 0.03,c)    end),
    awful.key({ settings.modkey,           }, "a",     function (c) awful.client.incwfact( -0.03,c)    end),
    awful.key({ settings.modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ settings.modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ settings.modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ settings.modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ settings.modkey, "Mod1"    }, "l", function () awful.layout.inc(settings.layouts,  1) end),
    awful.key({ settings.modkey, "Mod1", "Shift"   }, "l", function () awful.layout.inc(settings.layouts, -1) end),

    -- Prompt
    awful.key({ settings.modkey },            "F1",     function () widgets.promptbox[mouse.screen]:run() end),
    -- }}}

    -- {{{ - POWER
    awful.key({ settings.modkey, "Mod1" },"h", function () awful.util.spawn('sudo pm-hibernate',false) end),
    awful.key({ settings.modkey, "Mod1" },"s", function () 
        awful.util.spawn('slock',false)
        os.execute('sudo pm-suspend')
    end),
    awful.key({ settings.modkey, "Mod1" },"r", function () awful.util.spawn('sudo reboot',false) end)
    -- }}} 
    
    )

-- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
clientkeys = awful.util.table.join(
    awful.key({ settings.modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ settings.modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ settings.modkey, "Shift"   }, "0",      function (c) c.sticky=not c.sticky            end),
    awful.key({ settings.modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ settings.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ settings.modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ settings.modkey, "Control"}, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
    )

shifty.config.clientkeys = clientkeys

-- Compute the maximum number of digit we need, limited to 9
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ settings.modkey }, i,
            function () awful.tag.viewonly(shifty.getpos(i)) end),
        awful.key({ settings.modkey, "Control" }, i,
            function ()t = shifty.getpos(i); t.selected = not t.selected end),
        awful.key({ settings.modkey, "Shift" }, i,
            function ()
                if client.focus then 
                    local c = client.focus
                    slave = not ( client.focus == awful.client.getmaster(mouse.screen))
                    t = shifty.getpos(i)
                    awful.client.movetotag(t)
                    awful.tag.viewonly(t)
                    if slave then awful.client.setslave(c) end
                end 
            end
        )
    )
end

-- Set keys
root.keys(globalkeys)
-- }}}

shifty.taglist = widgets.taglist
shifty.init()

-- {{{ signals
client.add_signal("focus", function (c)

    c.border_color = beautiful.border_focus

    if settings.opacity[c.class] then 
       c.opacity = settings.opacity[c.class].focus
    else
        c.opacity = settings.opacity.default.focus or 1
    end
end) 

-- Hook function to execute when unfocusing a client.
client.add_signal("unfocus", function (c)

    c.border_color = beautiful.border_normal

    if settings.opacity[c.class] then 
        c.opacity = settings.opacity[c.class].unfocus
    else
        c.opacity = settings.opacity.default.unfocus or 0.7
    end
end)
-- }}}

-- vim:set filetype=lua textwidth=120 fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --
