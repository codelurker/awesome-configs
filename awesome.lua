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
require("mocp")
require("calendar")
require("battery")
require("markup")
require("fs")
require("volume")
require("vicious")
require("revelation")
print("Modules loaded: " .. os.time())

function client_restore(c)
    -- {{{
    c.minimized = false
    awful.tag.viewmore(c:tags(), c.screen)
    client.focus = c
    client.focus:raise()
end
--}}}

function client_filtermenu(filter, value, f)
    -- {{{

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
            print(#m.items)
        end
    end
    if #m.items >= 1 then
        local menu = awful.menu.new(m)
        menu:show(true)
        return menu
    end
end
--}}}

function tag_restore_defaults(t)
    -- {{{
    local t_defaults = mytags[t.name]

    if t_defaults == nil then return end

    for k,v in pairs(t_defaults) do
        awful.tag.setproperty(t, k, v)
    end
end
--}}}

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
    -- {{{
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
--}}}

function tfind(t, v)
    -- {{{return the index of v in t, false if not v in t
    for i, tv in ipairs(t) do
        if tv == v then return i end
    end
    return false
end --}}}

function tunion(t1, t2)
    -- {{{return the union of two tables
    union = {}
    for _, v1 in pairs(t1) do
        for _, v2 in pairs(t2) do
            if v1 == v2 then table.insert(union, v1) end
        end
    end
    return ((#union >= 1 and union) or nil)
end --}}}

function tag_match(filter, value, scr)
    -- {{{return a list of tags matching tag[filter] = value
    s = scr or mouse.screen
    sel = awful.tag.selectedlist()
    matches = {}

    for _, tag in pairs(screen[s]:tags()) do
        tmval = tm_key(tag, filter, value)
        print("lua148:",tag.name, tmval, filter, value)
        if tmval ~= false then -- and (not tfind(sel, tag)) then
            table.insert(matches,tag) --] = tmval
        end
    end
    return matches
end
--}}}

local keymodifiers = {
    Control_L = 1,
    Control_R = 1,
    Caps_Lock = 1,
    Shift_Lock = 1,
    Meta_R = 1,
    Meta_L = 1,
    Super_L = 1,
    Super_R = 1,
}

function tag_strmatch()
--{{{dynamically select tags that match keyboard input

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
--}}}

function tag_slide(filter, value, scr)
    -- {{{
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

  -- capi.keygrabber.run(keyboardhandler(restore))
end
--}}}

function tag_search(name, merge)
    -- {{{
    local merge = merge or false

    for s = 1, screen.count() do
        t = name2tag(name, s)
        if t == nil then
            -- create the tag if it doesnt already exist
            t = awful.tag.add(name, settings.tags[name])
        end

        if t ~= nil then
            if t.screen ~= mouse.screen then
                awful.screen.focus(t.screen)
            end
            if merge then
                t.selected = not t.selected
            else
                awful.tag.viewonly(t)
            end
            return t
        end
    end
    return false
end
--}}}

function name2tag(name, s)
    --{{{ find a tag based on its name
    local s = s or mouse.screen
    for i, t in ipairs(screen[s]:tags()) do
        if t.name == name then
            return t, i
        end
    end
end
--}}}

-- Called externally and just pops to or merges with my active vim server when
-- new files are dumped to it. (vim-start.sh)
-- though it could easily be used with any tag by passing a different 'name'
-- parameter
function tagPop(name)
    -- {{{tagPop()
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
--}}}

settings   = dofile(awful.util.getdir("config").."/settings.lua")
widgets    = dofile(awful.util.getdir("config").."/widgets.lua")
globalkeys = dofile(awful.util.getdir("config").."/keys.lua")

for name, props in pairs(settings.tags) do
    awful.tag.add(name, props)
end

-- {{{Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
--}}}

-- Set keys
root.keys(globalkeys)

-- {{{signals
client.add_signal("focus", function(c)

    c.border_color = beautiful.border_focus

    if settings.opacity[c.class] then
       c.opacity = settings.opacity[c.class].focus
    else
        c.opacity = settings.opacity.default.focus or 1
    end
    c:raise()
end)

-- Hook function to execute when unfocusing a client.
client.add_signal("unfocus", function(c)

    c.border_color = beautiful.border_normal

    if settings.opacity[c.class] then
        c.opacity = settings.opacity[c.class].unfocus
    else
        c.opacity = settings.opacity.default.unfocus or 0.7
    end
end)
--}}}

-- vim:set ft=lua tw=80 fdm=marker ts=4 sw=4 et sta ai: --
