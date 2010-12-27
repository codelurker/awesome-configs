-- some helper functins to make keybindings a bit more readable (?)
function key_gen(args, ...)
    -- try to make keybindings look less messy
    -- vargs[1] must be a function address suitable for awful.key()
    local vargs = {...}
    if args == nil or vargs == nil then return end

    local key = args.key
    nvargs = #vargs

    -- sanity
    if type(key) ~= 'string' then return end
    if vargs ~= nil and type(vargs[1]) ~= 'function' then
        return
    end

    local modkeys = {}
    if args.modifiers ~= nil and type(args.modifiers) ~= 'table' then
        return
    else
        modkeys = args.modifiers or {}
    end

    if args.use_modkey == nil or args.use_modkey == true then
        table.insert(modkeys, settings.modkey)
    end

    local f = table.remove(vargs, 1)
    if nvargs > 1 then
        return awful.key.new(modkeys, key, function()
            f(unpack(vargs)) end)
    else
        return awful.key(modkeys, key, f)
    end
end

function key_app(args, ...)
    -- applications that are started by util.spawn...
    -- i add "Mod1" to application starting
    local vargs = {...}
    local modkeys = args.modfiers or {}
    table.insert(modkeys, "Mod1")
    args.modifiers = modkeys

    return key_gen(args, awful.util.spawn, unpack(vargs), false)
end

globalkeys = awful.util.table.join(
    -- global keys
    key_gen({key = "t", modifiers = {"Control", "Shift"}},
        keygrabber.run, tag_strmatch),
    key_gen({modifiers = {"Control"}, key = "r"}, awesome.restart),
    key_gen({modifiers = {"Shift"}, key = "q"}, awesome.quit),
    key_gen({key = "space"}, awful.tag.viewnext),
    key_gen({key = "space", modifiers = {"Shift"}}, awful.tag.viewprev),
    key_gen({key = "space", modifiers = {"Control"}}, workspace_next),
    key_gen({key = "space", modifiers = {"Control", "Shift"}}, workspace_prev),
    key_gen({key = "j"}, awful.client.focus.byidx, 1),
    key_gen({key = "k"}, awful.client.focus.byidx, -1),
    key_gen({key = "e"}, revelation.revelation),

    -- tag manipulation
    key_gen({key = "Escape"}, awful.tag.history.restore),
    key_gen({key = "n"},
        function()
            awful.tag.move(awful.tag.getidx() + 1)
            tag_reconcile()
        end),
    key_gen({key = "n", modifiers = {"Shift"}},
        function()
            awful.tag.move(awful.tag.getidx() - 1)
            tag_reconcile()
        end),
    key_gen({key = "n", modifiers = {"Control"}}, function(t)
        tag_to_screen(t)
    end),
    key_gen({key = "r", modifiers = {"Shift"}}, function()
        awful.tag.rename()
        tag_reconcile()
    end),
    key_gen({key = "d", modifiers = {"Shift"}}, function()
        clients = awful.tag.selected():clients()
        tag_delete()
        for _,c in pairs(clients) do
            for _, t in pairs(c:tags()) do
                print(c.name, t.name)
            end
        end
    end),
    key_gen({key = "a", modifiers = {"Shift"}}, function()
        local scr = client.focus.screen
        index = #screen[scr]:tags() + 1
        prefix = index .. ":"
        awful.prompt.run(
            {text = prefix},
            widgets.promptbox[mouse.screen].widget,
            function(name)
                t = tag_make(name, false)
                awful.tag.viewonly(t)
            end)
        end),
    key_gen({key = "a", modifiers = {"Control"}}, function()
        if client.focus then
            local i = #screen[mouse.screen]:tags() + 1
            local c = client.focus
            local t = screen[mouse.screen]:tags()[i]

            if t == nil then
                local new_tag_name = i .. ":" ..
                (c.instance:gsub("%s.+$", "") or "new")
                t = tag_make(new_tag_name, false)
            end

            local last_tags = c:tags()
            awful.client.movetotag(t, c)
            awful.tag.viewonly(t)
        end
    end),

    -- Layout manipulation
    key_gen({key = "j", modifiers = {"Shift"}}, awful.client.swap.byidx, 1),
    key_gen({key = "k", modifiers = {"Shift"}}, awful.client.swap.byidx, -1),
    key_gen({key = "s"}, awful.screen.focus_relative, 1),
    key_gen({key = "s", modifiers = {"Shift"}}, awful.client.movetoscreen),
    key_gen({key = "u"}, awful.client.urgent.jumpto),
    key_gen({key = "Tab"}, function()
        awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end),

    -- applications
    key_gen({key = "Return"}, function()
        awful.util.spawn(settings.apps.terminal, false) end),
    key_app({key="f"}, settings.apps.filemgr),
    -- key_app({key="c"}, "galculator"),
    key_app({modifiers = {"Shift"}, key = "g"}, "gimp"),
    key_app({key = "v"}, "/home/perry/.bin/vim-start.sh"),

    key_gen({key = "XF86AudioRaiseVolume", use_modkey = false}, volume.vol,
        "up", "5"),
    key_gen({key = "XF86AudioLowerVolume", use_modkey = false}, volume.vol,
        "down", "5"),
    key_gen({key = "XF86AudioMute", use_modkey = false}, volume.vol ),

    -- Clients
    key_gen({key = "q"}, awful.client.incwfact, 0.03),
    key_gen({key = "a"}, awful.client.incwfact, -0.03),
    key_gen({key = "l"}, awful.tag.incmwfact, 0.03),
    key_gen({key = "h"}, awful.tag.incmwfact, -0.03),
    key_gen({key = "h", modifiers = {"Shift"}}, awful.tag.incnmaster, 1),
    key_gen({key = "l", modifiers = {"Shift"}}, awful.tag.incnmaster, -1),
    key_gen({key = "h", modifiers = {"Control"}}, awful.tag.incncol, 1),
    key_gen({key = "l", modifiers = {"Control"}}, awful.tag.incncol, -1),
    key_gen({key ="l", modifiers = {"Mod1"}}, awful.layout.inc,
            settings.layouts, 1),
    key_gen({key = "l", modifiers = {"Mod1", "Shift"}}, awful.layout.inc,
            settings.layouts, -1),

    -- Prompt
    key_gen({key = "F1"}, function() widgets.promptbox[mouse.screen]:run()
    widgets.promptbox[mouse.screen].widget.text = "" end),
    key_gen({key = "F2"}, function()
        widgets.promptbox[mouse.screen]:run(nil, nil, function(args)
            cmd = "urxvt -name man -e zsh -c \'man "
            cmd = cmd .. unpack(args) .. "\'"
            print("MANKB::::::::::::::: ",cmd)
            awfult.util.spawn_with_shell(cmd)
        end) end),

    -- power
    key_app({key = "h"}, 'sudo pm-hibernate'),
    key_app({key = "r"}, 'sudo reboot'),
    key_gen({key = "s", modifiers = {"Mod1"}}, function()
        awful.util.spawn('slock',false)
        os.execute('sudo pm-suspend')
    end),

    -- monitors
    key_app({key = "F4"}, '/home/perry/.bin/stupid --soyo'),
    key_app({key = "F5"}, '/home/perry/.bin/stupid --sync --pos left-of'),
    key_app({key = "F6"}, '/home/perry/.bin/stupid --off')
)

tag_searches = {
    --table of tag/key pairs to appy to tag_search() function
    dz = {key = "g", spawn = 'gschem'},
    web = {key = "w" , spawn = settings.apps.browser},
    mail = {key = "m", spawn = settings.apps.mail},
    vbox = {key = "v",
            modifiers = {"Mod1", "Shift"},
            spawn = 'VBoxSDL --evdevkeymap --nohostkeys r -vm xp2'},
}

globalkeys = awful.util.table.join(globalkeys,
    awful.key({settings.modkey, "Mod1"}, "c", function ()
        run_or_raise("galculator", {class = "Galculator"})
    end),
    awful.key({ "Mod1" }, "c", function ()
     -- If you want to always position the menu on the same place set
     -- coordinates
     awful.menu.menu_keys.down = { "Down", "Alt_L" }
     local cmenu = awful.menu.clients({width=245},
                            { keygrabber=true, coords={x=525, y=330} })
 end))

for tag, search_table in pairs(tag_searches) do
    --bind searches to tag_search functionality
    -- for view exclusive
    globalkeys = awful.util.table.join(globalkeys,
                    key_gen(search_table, function()
                        if not tag_search(tag) then
                            awful.util.spawn(search_table.spawn, false)
                        end
                    end))

    -- for view merged
    if search_table.modifiers then
        mod_table = search_table.modifiers
        table.insert(mod_table, "Control")
    else
        mod_table = {"Control"}
    end
    k_table = {key = search_table.key, modifiers = mod_table}

    globalkeys = awful.util.table.join(globalkeys,
                    key_gen(k_table, function()
                        if not tag_search(tag, true) then
                            awful.util.spawn(search_table.spawn, false)
                        end
                    end))
end

for i = 1, 9 do
    -- bind the numeric keys to 'normal' awesome keybindings
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({settings.modkey}, "#" .. i + 9, function ()
            local s = mouse.screen
            local tags = screen[s]:tags()
            local t = tags[i]

            if t == nil then
                local count = #tags

                local prefix = (count + 1) .. ":"
                awful.prompt.run({text = prefix},
                    widgets.promptbox[mouse.screen].widget,
                    function(name)
                        t = tag_make(name, false)
                        awful.tag.viewonly(t)
                    end)
            else
                awful.tag.viewonly(t)
            end
        end),

        awful.key({settings.modkey, "Control"}, i, function()
            awful.tag.viewtoggle(screen[mouse.screen]:tags()[i])
        end),

        awful.key({settings.modkey, "Shift"}, i, function()
            if client.focus then
                local c = client.focus
                slave = not (client.focus ==
                                awful.client.getmaster(mouse.screen))
                t = screen[mouse.screen]:tags()[i]

                if t == nil then
                    local new_tag_name = i .. ":" ..
                                        (c.instance:gsub("%s.+$", "") or "new")
                    t = tag_make(new_tag_name, false)
                end

                local last_tags = c:tags()
                awful.client.movetotag(t, c)
                awful.tag.viewonly(t)
                if slave then awful.client.setslave(c) end
            end
        end)
    )
end

return globalkeys
