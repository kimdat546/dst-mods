local HH_UTILS = require("utils/hh_utils")

--特效配置类
local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local HH_LIST = {
    --闪光特效
    ["hh_sparkle_fx"] = {
        ["tex"] = "fx/sparkle.tex",
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {
            { 0, IntColour(255, 255, 255, 200) },
            { 1, IntColour(255, 255, 255, 255) },
        },
        ["scale_envelope"] = {
            { 0, { 2.8, 2.8 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },
        },
        ["life_time"] = 1,
        ["uv_frame_size"] = { 0, 0.25, 1 },
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = false,
    },
    --------------------------------------------球状------------------------------------
    --蓝色球状
    ["hh_ball_fx_blue"] = {
        ["tex"] = resolvefilepath("images/fx/hh_ball_blue.tex"),
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = {
            { 0, IntColour(255, 255, 255, 200) },
            { 1, IntColour(255, 0, 0, 0) },
        },
        ["scale_envelope"] = {
            { 0, { 1.5, 1.5 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },

        },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = false,
    },
    --橙色球状
    ["hh_ball_fx_orange"] = {
        ["tex"] = resolvefilepath("images/fx/hh_ball_orange.tex"),
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = {
            { 0, IntColour(255, 255, 255, 200) },
            { 1, IntColour(255, 0, 0, 0) },
        },
        ["scale_envelope"] = {
            { 0, { 1.5, 1.5 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },
        },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = false,
    },
    --红色球状
    ["hh_ball_fx_red"] = {
        ["tex"] = resolvefilepath("images/fx/hh_ball_red.tex"),
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = { { 0, IntColour(255, 255, 255, 200) }, { 1, IntColour(255, 0, 0, 0) }, },
        ["scale_envelope"] = { { 0, { 1.5, 1.5 } }, { 0.3, { 0, 0 } }, { 1, { 0, 0 } }, },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = false,
    },
    --绿色球状
    ["hh_ball_fx_green"] = {
        ["tex"] = resolvefilepath("images/fx/hh_ball_green.tex"),
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = { { 0, IntColour(255, 255, 255, 200) }, { 1, IntColour(255, 0, 0, 0) }, },
        ["scale_envelope"] = { { 0, { 1.5, 1.5 } }, { 0.3, { 0, 0 } }, { 1, { 0, 0 } }, },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = false,
    },
    --紫色球状
    ["hh_ball_fx_purple"] = {
        ["tex"] = resolvefilepath("images/fx/hh_ball_purple.tex"),
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = { { 0, IntColour(255, 255, 255, 200) }, { 1, IntColour(255, 0, 0, 0) }, },
        ["scale_envelope"] = { { 0, { 1.5, 1.5 } }, { 0.3, { 0, 0 } }, { 1, { 0, 0 } }, },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = false,
    },
    --------------------------------------------星星------------------------------------
    --白色星星
    ["hh_fx_star_white"] = {
        ["tex"] = resolvefilepath("images/fx/hh_fx_star.tex"),
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {
            { 0, IntColour(255, 255, 255, 200) },
            { 1, IntColour(255, 255, 255, 255) },
        },
        ["scale_envelope"] = {
            { 0, { 3.6, 3.6 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },
        },
        ["life_time"] = 1,
        --["uv_frame_size"] = { 0, 0.25, 1 },
        --["uv_frame_size"] = { 1, 0.25, 1 },
        --effect:SetUVFrameSize(5, 0.25, 1)
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = false,
    },
    --紫色六角星-好看
    ["hh_fx_star_purple"] = {
        ["tex"] = resolvefilepath("images/fx/hh_fx_star.tex"),
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {
            { 0, IntColour(122, 30, 255, 255) },
            { 0.5, IntColour(122, 20, 255, 255) },
            { 0.75, IntColour(122, 10, 255, 255) },
            { 1, IntColour(200, 5, 255, 255) },
        },
        ["scale_envelope"] = {
            { 0, { 3.6, 3.6 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },
        },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = false,
    },
    --红色星星
    ["hh_fx_star_red"] = {
        ["tex"] = resolvefilepath("images/fx/hh_fx_star.tex"),
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {
            { 0, IntColour(255, 0, 0, 255) },
            { 0.5, IntColour(255, 0, 0, 255) },
            { 0.75, IntColour(255, 0, 0, 255) },
            { 1, IntColour(255, 0, 0, 255) },
        },
        ["scale_envelope"] = {
            { 0, { 3.6, 3.6 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },
        },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = false,
    },
    --蓝色星星
    ["hh_fx_star_blue"] = {
        ["tex"] = resolvefilepath("images/fx/hh_fx_star.tex"),
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {
            { 0, IntColour(0, 101, 255, 255) },
            { 1, IntColour(0, 101, 255, 255) },
        },
        ["scale_envelope"] = {
            { 0, { 3.6, 3.6 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },
        },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = false,
    },
    --橙色星星
    ["hh_fx_star_orange"] = {
        ["tex"] = resolvefilepath("images/fx/hh_fx_star.tex"),
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {
            { 0, IntColour(255, 102, 0, 255) },
            { 1, IntColour(255, 102, 0, 255) },
        },
        ["scale_envelope"] = {
            { 0, { 3.6, 3.6 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },
        },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = false,
    },
    --黄色星星
    ["hh_fx_star_yellow"] = {
        ["tex"] = resolvefilepath("images/fx/hh_fx_star.tex"),
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {
            { 0, IntColour(255, 242, 0, 255) },
            { 1, IntColour(255, 242, 0, 255) },
        },
        ["scale_envelope"] = {
            { 0, { 3.6, 3.6 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },
        },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = false,
    },
    --绿色星星
    ["hh_fx_star_green"] = {
        ["tex"] = resolvefilepath("images/fx/hh_fx_star.tex"),
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["color_envelope"] = {
            { 0, IntColour(101, 255, 0, 255) },
            { 1, IntColour(101, 255, 0, 255) },
        },
        ["scale_envelope"] = {
            { 0, { 3.6, 3.6 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },
        },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["need_kill_all"] = false,
    },
    --文字特效
    --["hh_word_01"] = {
    --    ["tex"] = resolvefilepath("images/fx/hh_word_01.tex"),
    --    ["shader"] = "shaders/particle.ksh",
    --    ["color_envelope"] = {
    --        { 0, IntColour(255, 255, 255, 255) },
    --        --{ 0.5, IntColour(122, 20, 255, 255) },
    --        --{ 0.75, IntColour(122, 10, 255, 255) },
    --        { 1, IntColour(255, 255, 255, 255) },
    --    },
    --    ["scale_envelope"] = {
    --        { 0, { 3.6, 3.6 } },
    --        { 0.3, { 0, 0 } },
    --        { 1, { 0, 0 } },
    --    },
    --    ["life_time"] = 1,
    --    ["emitters_num"] = 1,
    --    ["max_num"] = 120,
    --    ["blend_mode"] = BLENDMODE["AlphaBlended"],
    --    ["need_kill_all"] = false,
    --},
    --------------------------炮塔-------------------------------------
    ["hh_turret_fx_ice"] = {
        ["tex"] = resolvefilepath("images/fx/hh_ball_blue.tex"),
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = {
            { 0, IntColour(255, 255, 255, 200) },
            { 1, IntColour(255, 0, 0, 0) },
        },
        ["scale_envelope"] = {
            { 0, { 2.5, 2.5 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },

        },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = false,
    },
    ["hh_turret_fx_fire"] = {
        ["tex"] = resolvefilepath("images/fx/hh_ball_red.tex"),
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = { { 0, IntColour(255, 255, 255, 200) }, { 1, IntColour(255, 0, 0, 0) }, },
        ["scale_envelope"] = { { 0, { 1.5, 1.5 } }, { 0.3, { 0, 0 } }, { 1, { 0, 0 } }, },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = false,
    },
    ["hh_turret_fx_poison"] = {
        ["tex"] = resolvefilepath("images/fx/hh_ball_green.tex"),
        ["shader"] = "shaders/particle.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["AlphaBlended"],
        ["color_envelope"] = { { 0, IntColour(255, 255, 255, 200) }, { 1, IntColour(255, 0, 0, 0) }, },
        ["scale_envelope"] = { { 0, { 1.5, 1.5 } }, { 0.3, { 0, 0 } }, { 1, { 0, 0 } }, },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = false,
    },
    --------------------------炮塔-------------------------------------
    --------------------------2025文字特效-------------------------------------
    --猪
    ["hh_fx_pig_white"] = {
        ["tex"] = resolvefilepath("images/fx/hh_fx_pig.tex"),
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["color_envelope"] = {
            { 0, IntColour(255, 255, 255, 200) },
            { 1, IntColour(255, 0, 0, 0) },
        },
        ["scale_envelope"] = {
            { 0, { 1.5, 1.5 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },

        },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = false,
    },
    ["hh_fx_pig_purple"] = {
        ["tex"] = resolvefilepath("images/fx/hh_fx_pig.tex"),
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["color_envelope"] = {
            { 0, IntColour(122, 30, 255, 255) },
            { 0.5, IntColour(122, 20, 255, 255) },
            { 0.75, IntColour(122, 10, 255, 255) },
            { 1, IntColour(200, 5, 255, 255) },
        },
        ["scale_envelope"] = {
            { 0, { 1.5, 1.5 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },
        },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = false,
    },
    ["hh_fx_pig_blue"] = {
        ["tex"] = resolvefilepath("images/fx/hh_fx_pig.tex"),
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["color_envelope"] = {
            { 0, IntColour(0, 101, 255, 255) },
            { 1, IntColour(0, 101, 255, 255) },
        },
        ["scale_envelope"] = {
            { 0, { 1.5, 1.5 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },
        },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = false,
    },
    ["hh_fx_pig_orange"] = {
        ["tex"] = resolvefilepath("images/fx/hh_fx_pig.tex"),
        ["shader"] = "shaders/vfx_particle_add.ksh",
        ["uv_frame_size"] = nil,
        ["blend_mode"] = BLENDMODE["Additive"],
        ["color_envelope"] = {
            { 0, IntColour(255, 102, 0, 255) },
            { 1, IntColour(255, 102, 0, 255) },
        },
        ["scale_envelope"] = {
            { 0, { 1.5, 1.5 } },
            { 0.3, { 0, 0 } },
            { 1, { 0, 0 } },
        },
        ["life_time"] = 1,
        ["emitters_num"] = 1,
        ["max_num"] = 120,
        ["need_kill_all"] = false,
    },
    --------------------------2025文字特效-------------------------------------
}
return HH_LIST