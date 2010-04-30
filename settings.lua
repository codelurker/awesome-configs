-- awesome rc variables
settings = {}
settings.theme_path = os.getenv("HOME").."/.config/awesome/themes/dk_grey"

settings = {
    --{{{
    modkey     = "Mod4",
    theme_path = os.getenv("HOME").."/.config/awesome/themes/dk_grey",
    icon_path  = beautiful.iconpath,
    mwfact80   = ((screen.count() - 1) > 0 and 0.4) or 0.52,

    apps = {
        --{{{
        terminal  = "urxvt",
        browser   = "firefox",
        mail      = "/home/perry/.bin/mutt-start.sh",
        filemgr   = "thunar",
        music     = "mocp --server",
        editor    = "/home/perry/.bin/vim-start.sh"
    },
    --}}}

    layouts = {
        --{{{
        awful.layout.suit.tile.left,
        awful.layout.suit.tile,
        awful.layout.suit.max,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.floating
    },
    --}}}

    tags = { vim = { screen = 1,
                        mwfact = 0.4,
                        layout = awful.layout.suit.tile},
            web = { screen = 1,
                        mwfact = 0.6,
                        layout = awful.layout.suit.tilebottom},
            mail = { screen = math.min(2, screen.count()),
                        mwfact = 0.4,
                        layout = awful.layout.suit.tile},
            vbx = { screen = 1,
                        mwfact = 0.4,
                        layout = awful.layout.suit.tile},
            mail = { screen = 1,
                        mwfact = 0.4}
    },


    opacity = {
        -- {{{
        default = {focus = 1.0, unfocus = 0.90},
        Easytag = {focus = 1.0, unfocus = 0.95},
        mutt = {focus = 1.0, unfocus = 0.95},
        Gschem  = {focus = 1.0, unfocus = 1.0},
        Gimp    = {focus = 1.0, unfocus = 1.0},
        MPlayer = {focus = 1.0, unfocus = 1.0},
        Ipython = {focus = 1.0, unfocus = 1.0},
    },
    --}}}
}
--}}}

return settings



-- vim:set ft=lua ts=4 sw=4 et ai: --
