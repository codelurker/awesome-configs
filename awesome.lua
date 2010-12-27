-- rc.lua for awesome-git'ish window manager
---------------------------
-- bioe007, perrydothargraveatgmaildotcom
--
print("Entered rc.lua: " .. os.time())
require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
settings = {}
theme_path = os.getenv("HOME").."/.config/awesome/themes/dk_grey"
beautiful.init(theme_path.."/theme.lua")
require("naughty")
-- custom modules
require("markup")
-- require("mpc")

    require("calendar")
    require("battery")
    require("markup")
    require("fs")

require("volume")
require("vicious")
require("revelation")
require("ptaglist")
print("Modules loaded: " .. os.time())

function match (table1, table2)
    -- Returns true if all pairs in table1 are present in table2
    for k, v in pairs(table1) do
        if table2[k] ~= v and not table2[k]:find(v) then
            return false
        end
    end
    return true
end


function run_or_raise(cmd, properties, move)
    -- spawn or find a client
    local clients = client.get()
    local focused = client.focus
    local findex = 0
    local matched_clients = {}
    local n = 0
    local move_client = move

    for i, c in pairs(clients) do
        --make an array of matched clients
        if match(properties, c) then
            n = n + 1
            matched_clients[n] = c
            if c == focused then
                findex = n
            end
        end
    end
    if n > 0 then
        local c = matched_clients[1]
        -- if the focused window matched switch focus to next in list
        if 0 < findex and findex < n then
            c = matched_clients[findex+1]
        end
        local ctags = c:tags()

        if table.getn(ctags) == 0 then
            -- ctags is empty, show client on current tag
            local curtag = awful.tag.selected()
            awful.client.movetotag(curtag, c)
        elseif move_client == "viewonly" then
            awful.tag.viewonly(ctags[1])
        elseif move_client == "viewmore" then
            ctags[1].selected = true
        else
            -- the default behavior is to add the current tag
            table.insert(ctags, awful.tag.selected())
            c:tags(ctags)
        end
        -- And then focus the client
        client.focus = c
        c:raise()
        return
    end
    awful.util.spawn(cmd)
end

function client_restore(c)
    --
    c.minimized = false
    awful.tag.viewmore(c:tags(), c.screen)
    client.focus = c
    client.focus:raise()
end

function client_filtermenu(filter, value, f)
    -- Find all clients such that c[filter] == value, then show them
    -- on a menu.
    if not filter then return end
    clients = client.get()

    m = {}
    m.items = {}
    for i, c in ipairs(clients) do
        if c[filter] and c[filter] == value then
            m.items[#m.items +1] = {
                awful.util.escape(c.name),
                function() f(c) end,
                c.icon
            }
        end
    end
    if #m.items >= 1 then
        local menu = awful.menu.new(m)
        menu:show(true)
        return menu
    end
end

function tag_restore_defaults(t)
    --
    local t_defaults = settings.tags[t.name]

    if t_defaults == nil then return end

    for k,v in pairs(t_defaults) do
        awful.tag.setproperty(t, k, v)
    end
end

function workspace_next()
    for s=1,screen.count() do
        awful.tag.viewnext(screen[s])
    end
end

function workspace_prev()
    for s=1,screen.count() do
        awful.tag.viewprev(screen[s])
    end
end

function tm_key(obj, key, value)
    --
    if obj[key] then
        if type(value) == 'string' then
            -- after stripping any leading number from the obj[key]
            -- for strings, return the difference of length of a capture
            -- so the closer to zero the better match
            print("LUA:108:", value,
                            obj[key]:gsub("^%d+:",""),
                            obj[key]:gsub("^%d+:",""):match('^('..value..'.+)'))
            tmp_str = obj[key]:gsub("^%d+:","")

            if tmp_str:match('^('..value..'.-)') then
                return #(tmp_str:match('^('..value..'.+)') or '')
            else
                return false
            end

        elseif obj[key] == value then
            -- non strings just do simple comparison
            return true
        else
            return false
        end
    else
        print('no such tm_key', obj, key, value)
    end
end

function tfind(t, v)
    -- return the index of v in t, false if not v in t
    for i, tv in ipairs(t) do
        if tv == v then return i end
    end
    return false
end

function tunion(t1, t2)
    -- return the union of two tables
    union = {}
    for _, v1 in pairs(t1) do
        for _, v2 in pairs(t2) do
            if v1 == v2 then table.insert(union, v1) end
        end
    end
    return ((#union >= 1 and union) or nil)
end

function tag_match(filter, value, scr)
    s = scr or mouse.screen
    sel = awful.tag.selectedlist()
    matches = {}

    for _, tag in pairs(screen[s]:tags()) do
        tmval = tm_key(tag, filter, value)
        print("lua148:",tag.name, tmval, filter, value)
        if tmval ~= false then
            table.insert(matches, tag)
        end
    end
    return matches
end

local keymodifiers = {
    Control_L = 1,
    Control_R = 1,
    Caps_Lock = 1,
    Shift_Lock = 1,
    Meta_R = 1,
    Meta_L = 1,
    Super_L = 1,
    Super_R = 1}

function tag_strmatch()
    --dynamically select tags that match keyboard input
    str = ""
    osel = awful.tag.selectedlist()

    return function(mod, key, event)
        -- key release events
        if event == "release" then
            -- break when return is received
            if key == 'Return' then
                if pil ~= nil then
                    naughty.destroy(pil)
                end
                return false
            else
                return true
            end
        else
            if key == 'Return' then
                if pil ~= nil then
                    naughty.destroy(pil)
                end
                return false
            else
                return true
            end
            if key == 'Delete' then
                -- typo
                str = str:sub(1,str:len()-1)
            elseif not keymodifiers[key] then
                -- not a modifier key?
                str = str..key
            end
        end

        if pil ~= nil then
            naughty.destroy(pil)
        end

        pil = naughty.notify({text=str})
        if str:len() > 0 then
            m = tag_match('name', str, mouse.screen)
            for _, tag in pairs(m) do
                if not tfind(osel, tag) then
                    awful.tag.viewmore(awful.util.table.join(osel,m),
                                        mouse.screen)
                else
                    tag.selected = false
                end
            end
        end
        m_old = m
        return true
    end
end

function tag_slide(filter, value, scr)
    s = scr or mouse.screen

    -- to compare matches against currently selected tags
    sel = awful.tag.selectedlist(s)

    -- all matching tags
    m = tag_match(filter, value, s)

    -- the selected and matching tags
    u = tunion(m, sel)

    if #m > 1 then
        selquality = nil
        -- iterate over all the matches
        for t, quality in pairs(m) do

            if selquality ~= nil then
                selvalue = matches[tag]

            elseif quality < selquality then

                if tfind(sel, t) then
                    -- this tag is already selected, so un-select and
                    -- remove from the matches list
                    t.selected = not t.selected
                    m[t] = nil
                else
                    -- t.selected = t.selected
                    selquality = quality
                    best = t
                end
            end
        end
    else
        -- this is stupid
        for t, _ in pairs(m) do
            t.selected = not t.selected
        end
    end
end

function tag_search(name, merge)
    local merge = merge or false

    -- Return value, becomes the tag if found.
    local prexist = nil

    for s = 1, screen.count() do
        t = name2tag(name, s)
        if t == nil then
            t = tag_make(name, true)
        else
            prexist = t
        end
    end

    awful.screen.focus(t.screen)
    if merge then
        t.selected = not t.selected
    else
        awful.tag.viewonly(t)
    end
    return prexist
end

function name2tag(name, s)
    -- Find a tag based on its name and return tag and index if found.
    for s = 1, screen.count() do
        for i, t in ipairs(screen[s]:tags()) do
            -- FIXME: hackish
            if t.name == i .. ":" .. name then
                return t, i
            end
        end
    end
end

function tagPop(name)
    -- Called externally and just pops to or merges with my active vim server
    -- when new files are dumped to it. (vim-start.sh) though it could easily be
    -- used with any tag by passing a different 'name' parameter
    for s = 1, screen.count() do
        t = name2tag(name,s)
        if t ~= nil then
            if t.screen == awful.tag.selected().screen then
                t.selected = true
            else
                awful.tag.viewonly(t)
                awful.screen.focus(t.screen)
            end
        end
    end
end

function tag_make(name, prefix, leader)
    -- name is string, prefix can be function, string or bool
    -- leader is stripped from name when trying to id tags in settings.tags
    if name == nil or #name == 0 then return end;

    if type(prefix) == "function" then
        name = prefix() .. name
    elseif type(prefix) == "string" then
        name = prefix .. name
    elseif prefix == true then
        name = #screen[mouse.screen]:tags() + 1 .. ":" .. name
    end

    -- strip prefix and see if a match exists
    name_stripped = string.gsub(name, (leader or "%d+:"), "")
    local props = settings.tags[name_stripped] or
                    settings.tags.default

    if props.screen == nil then props.screen = mouse.screen end
-- print("creating tag", name, name_stripped, settings.tags[name_stripped] or settings.tags.default, props.screen, mouse.screen)
    t = awful.tag.add(name, props)
    return t
end

function tag_prefix(t, sep)
    local t = t or awful.tag.selected()

    local prefix = sep or ":"
    return awful.tag.getidx(t) .. prefix
end

function tag_reconcile(scr, prefix, pattern)
    -- fix tag names based on their current order
    local scr = scr or mouse.screen
    local tags = screen[scr]:tags()
    local prefix = prefix or tag_prefix
    local pattern = pattern or settings.tag_prefix or "^(%d+):"

    for i, t in ipairs(tags) do
        -- pattern must specify a capture suitable for comparison with i
        if i ~= string.match(t.name, pattern) then
            t.name = prefix(t) .. string.gsub(t.name, pattern, "")
        end
    end
end

function tag_delete(t, prefix, leader)
    local dt = t or awful.tag.selected()
    local d_scr = dt.screen

    awful.tag.delete(dt)
    tag_reconcile(d_scr, prefix, settings.tag_prefix)
    awful.tag.history.restore(dt.screen)
end

function tag_to_screen(t)
    -- move tag to next screen
    target_scr = awful.util.cycle(screen.count(),
                                    awful.tag.selected().screen + 1)
    lt = awful.tag.move_screen(target_scr, t)
    if lt ~= nil then
        awful.tag.viewonly(lt)
        mouse.screen = lt.screen
        if #lt:clients() > 0 then client.focus = lt:clients()[1] end
        tag_reconcile()
    end
end

settings   = dofile(awful.util.getdir("config").."/settings.lua")
widgets    = dofile(awful.util.getdir("config").."/widgets.lua")
globalkeys = dofile(awful.util.getdir("config").."/keys.lua")

for name, props in pairs(settings.tags) do
    if props.startup then
        tag_make(name, true)
    end
end

for s = 1, screen.count() do
    local t = screen[s]:tags()[1]

    if t ~= nil then
        awful.tag.viewonly(t)
    end
end

root.buttons(awful.util.table.join(awful.button({}, 4, awful.tag.viewnext),
                                   awful.button({}, 5, awful.tag.viewprev)))

-- Set keys
root.keys(globalkeys)

for _, v in pairs({"focus", "unfocus"}) do
    client.add_signal(v, function(c)
        c.border_color = beautiful["border_" .. v]

        --[[if #awful.tag.selected():clients() > 1 then
            c.border_width = beautiful.border_width
        else
            c.border_width = 0
        end ]]--

        if v == "focus" then
            c:raise()
        end
    end)
end

--[[screen.add_signal("tag::detach", function (s)
        print("detached")

        local clients = awful.client.get(s)
        -- if tags and #tags > 0 then
            -- c:tags({tags[1]})
            -- return
        -- end

        local tags = screen[s]:tags()
        for _, c in pairs(clients) do
            if c:tags() == nil then
                -- abandoned client, find a tag for this one
                if tags and #tags > 0 then
                    c:tags({tags[1]})
                end
            end
        end

        -- try now to find a tag anywhere for this client
        for s = 1, screen.count() do
            if s ~= c.screen then
                tags = screen[s]:tags()
                if tags and #tags > 0 then
                    c:tags({tags[1]})
                    return
                end
            end
        end
end) --]]

client.add_signal("manage", function (c, startup)
    --[[ c:add_signal("untagged", function (c)
    c:add_signal("tag::detach", function (c)
        print("detached", c.name)
        local tags = screen[c.screen]:tags()

        if tags and #tags > 0 then
            c:tags({tags[1]})
            return
        end

        -- try now to find a tag anywhere for this client
        for s = 1, screen.count() do
            if s ~= c.screen then
                tags = screen[s]:tags()
                if tags and #tags > 0 then
                    c:tags({tags[1]})
                    return
                end
            end
        end
    end) --]]--

    if not startup then
        if not c.master and not c.addmaster then
            awful.client.setslave(c)
        end

        -- Put windows in a smart way, only if they does not set an
        -- initial position.
        if not c.size_hints.user_position and not
                                        c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)
