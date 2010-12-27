-- awesome rc variables
settings = {}
settings.theme_path = os.getenv("HOME").."/.config/awesome/themes/dk_grey"

-- need a better way, 0.52 is better for 1024x768 screen..
mwfact80 = ((screen.count() - 1) > 0 and 0.4) or 0.51

settings = {
    modkey     = "Mod4",
    theme_path = os.getenv("HOME").."/.config/awesome/themes/dk_grey",
    icon_path  = beautiful.iconpath,

    apps = {
        terminal  = "urxvt",
        browser   = "firefox",
        mail      = "/home/perry/.bin/mutt_start",
        filemgr   = "dolphin",
        editor    = "/home/perry/.bin/vim_start"
    },

    layouts = {
        awful.layout.suit.tile.left,
        awful.layout.suit.tile,
        awful.layout.suit.max,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.floating
    },

    tag_prefix = "^(%d+):",

    tags = {
        vim = {screen = 1,
                mwfact = mwfact80,
                layout = awful.layout.suit.tile,
                startup = true},
        web = {screen = 1,
                mwfact = 0.6,
                layout = awful.layout.suit.tile},
        mail = {screen = screen.count(),
                mwfact = mwfact80,
                layout = awful.layout.suit.tile,
                startup = true},
        vbox = {screen = 1,
                mwfact = 0.4,
                layout = awful.layout.suit.tile},
        ds = {screen = 1,
                mwfact = 0.6,
                layout = awful.layout.suit.max},
        default = {mwfact = 0.55,
                    layout = awful.layout.suit.tile}
    },

    opacity = {
        default = {focus = 1.00, unfocus = 0.90},
        Easytag = {focus = 1.00, unfocus = 0.95},
        mutt    = {focus = 1.00, unfocus = 0.95},
        Gschem  = {focus = 1.00, unfocus = 1.00},
        Gimp    = {focus = 1.00, unfocus = 1.00},
        MPlayer = {focus = 1.00, unfocus = 1.00},
        Ipython = {focus = 1.00, unfocus = 1.00}
    },
}

-- clientkeys
clientkeys = awful.util.table.join(
    awful.key({settings.modkey}, "f", function(c)
        c.fullscreen = not c.fullscreen  end),
    awful.key({settings.modkey, "Shift"}, "c", function(c) c:kill() end),
    awful.key({settings.modkey, "Shift"}, "0", function(c)
        c.sticky = not c.sticky end),
    awful.key({settings.modkey, "Mod1"}, "space", function(c)
        -- toggle floating on client
        awful.client.floating.toggle(c)
        if awful.client.floating.get(c) then
            awful.placement.centered(c)
            client.focus = c
            client.focus:raise()
        else
            awful.client.setslave(c)
        end
    end),
    awful.key({settings.modkey, "Control"}, "Return", function(c)
        c:swap(awful.client.getmaster())
    end),
    awful.key({settings.modkey, "Mod1"   }, "n", function(c)
        client_filtermenu('minimized',true, client_restore)
    end),
    awful.key({settings.modkey, "Control"}, "m",
        function(c)
            if c.maximized_horizontal then
                c.maximized_horizontal = false
                c.maximized_vertical = false
                c.minimized = true
            elseif c.minimized then
                c.minimized = false
                client.focus = c
                c:raise()
            else
                c.maximized_horizontal = not c.maximized_horizontal
                c.maximized_vertical   = not c.maximized_vertical
                c:raise()
            end
        end)
    )

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ settings.modkey }, 1, awful.mouse.client.move),
    awful.button({ settings.modkey }, 3, awful.mouse.client.resize))

awful.rules.rules = {
    {rule = {},
        properties = {border_width = beautiful.border_width,
                        border_color = beautiful.border_normal,
                        size_hints_honor = false,
                        focus = true,
                        keys = clientkeys,
                        buttons = clientbuttons}},
    {rule = {instance = "vim"},
        properties = {master = true},
        callback = function(c)
            awful.client.movetotag(tag_search("vim"), c)
        end},
    {rule = {instance = "Navigator"},
        callback = function(c)
            local t = tag_search("web", false)
            if t and t ~= false and #t:clients() > 0 then
                t = awful.tag.add(#screen[t.screen]:tags() + 1 .. ":web",
                                    settings.tags["web"])
                awful.client.movetotag(t, c)
            else
                awful.client.movetotag(t, c)
            end
        end},
    {rule = {instance = "google-chrome"},
        callback = function(c)
            local t = tag_search("web", false)
            if t and t ~= false and #t:clients() > 0 then
                t = awful.tag.add(#screen[t.screen]:tags() + 1 .. ":web",
                                    settings.tags["web"])
                awful.client.movetotag(t, c)
            else
                awful.client.movetotag(t, c)
            end
        end},
    {rule = {instance = "mutt"},
        callback = function(c)
            awful.client.movetotag(tag_search("mail"), c)
        end},
    {rule = {class = "VBox"},
        callback = function(c)
            awful.client.movetotag(tag_search("vbox"), c)
        end},
    {rule = {class = "Okular"},
        callback = function(c)
            awful.client.movetotag(tag_search("ds"), c)
        end},
    {rule = {class = "Skype"},
        properties = {floating = true, size_hints_honor = true},
        callback = function(c)
            awful.client.movetotag(tag_search("media"), c)
        end},
    {rule = {class = "Systemsettings"},
        properties = {floating = true, size_hints_honor = true},},
    {rule = {class = "Plasma-desktop"},
        properties = {floating = true, size_hints_honor = true},},
    {rule = {name = "Sonata"},
        properties = {floating = true, size_hints_honor = true, sticky=true}},
    {rule = {class = "MPlayer"},
        properties = {floating = true, size_hints_honor = true}},
    {rule = {class = "Smplayer"},
        properties = {floating = true, size_hints_honor = true}},
    {rule = {class = "Galculator"},
        properties = {floating = true, size_hints_honor = true}},
    {rule = {name = "Figure"},
        properties = {floating = true, size_hints_honor = true}}
    }

return settings
