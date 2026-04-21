-- scripts/colorscheme.lua
local opt = require 'mp.options'
local msg = require 'mp.msg'

local opts = { theme = "Default" }
opt.read_options(opts, "colorscheme")

local palettes = {
    ["Default"] = {
        accent = "#FF8232",
        fg = "#FFFFFF",
        bg = "#000000"
    },
    ["Claude"] = {
        accent = "#DA7756",
        fg = "#EDE8E0",
        bg = "#1F1E1C"
    },
    ["Gruvbox Dark Hard"] = {
        accent = "#5BC2E7",
        fg = "#EBDBB2",
        bg = "#1D2021"
    }
}

local function expand_theme(base)
    return {
        -- osc_color = base.bg,
        seekbarbg_color = base.bg,
        thumbnail_box_color = base.bg,
        window_title_color = base.fg,
        window_controls_color = base.fg,
        title_color = base.fg,
        cache_info_color = base.fg,
        time_color = base.fg,
        chapter_title_color = base.fg,
        side_buttons_color = base.fg,
        middle_buttons_color = base.fg,
        playpause_color = base.fg,
        nibble_current_color = base.fg,
        seekbar_cache_color = base.fg,
        thumbnail_box_outline = base.fg,
        seekbarfg_color = base.accent,
        seek_handle_color = base.accent,
        seek_handle_border_color = base.accent,
        nibble_color = base.accent,
        hover_effect_color = base.accent,
        held_element_color = base.accent,
    }
end

local function generate_colorscheme_file()
    local base = palettes[opts.theme] or palettes["Default"]
    local theme = expand_theme(base)
    
    local path = mp.command_native({"expand-path", "~~/script-opts/modernz-colorscheme.conf"})
    local file = io.open(path, "w")
    if not file then
        msg.error("Failed to write colorscheme file")
        return
    end
    
    for key, value in pairs(theme) do
        file:write(string.format("%s=%s\n", key, value))
    end
    file:close()
    
    msg.info("Generated colorscheme: " .. opts.theme)
end

generate_colorscheme_file()

mp.register_script_message("reload-theme", function()
    opt.read_options(opts, "colorscheme")
    generate_colorscheme_file()
    mp.commandv("script-message", "modernz-reload")
    mp.commandv("show-text", "Theme: " .. opts.theme, "2000")
end)