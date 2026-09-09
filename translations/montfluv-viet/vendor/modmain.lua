
-- 设置访问全局变量
GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

-- 测试命令
require("debugcommands")
-- 初始化文本
require("shanhai_strings/translation_ch/strings")
local translation = GetModConfigData("language")

local characters = {
    "wilson", "willow", "wolfgang", "wendy", "wx78", "wickerbottom", 
    "woodie", "waxwell", "wathgrithr", "webber", "winona", "wortox", 
    "wormwood", "warly", "wurt", "walter", "wanda", "wirlywings"
}
for i, character in ipairs(characters) do
    require("shanhai_strings/translation_ch/"..character)
end

if translation ~= "ch" then
    if translation == "en" then
        require("shanhai_strings/strings")
        for i, character in ipairs(characters) do
            require("shanhai_strings/"..character)
        end
        
    else
        require("shanhai_strings/translation_"..translation.."/strings")
        for i, character in ipairs(characters) do
            require("shanhai_strings/translation_"..translation.."/"..character)
        end
    end
end

-- 初始化MOD
local inits = {
    "init_techtrees",       -- 科技复用
    "init_prefabs",         -- 预制品
    "init_assets",          -- assets
    "init_tuning",          -- 数值设置
    "init_widgets",         -- 容器空间
    "init_actions",         -- 新加动作
    "init_ui",              -- 新增UI
    "init_retrofit",        -- 新增地形
    "init_recipes",         -- 科技配方
    "init_cooking",         -- 烹饪料理
    "init_background",      -- 加载背景
}
for _, v in pairs(inits) do
    modimport("init/"..v)
end
modimport("init/init_other")

-- 针对塔内空间的控制
modimport("init/init_house")

-- 相关RPC的定义
modimport("scripts/shanhai_defs/shanhai_rpc")

-- Hook的内容单独提取出来了，但是不包含洞天塔的相关Hook
modimport("scripts/shanhai_defs/shanhai_postinit_def.lua")
modimport("scripts/shanhai_defs/sh_postinit_boat.lua")

-- 额外的hook
modimport("main/postinit")

-- 基于风铃草大佬开放级的皮肤系统
-- modimport("init/init_skin_api")
-- modimport("init/init_skin_origin")


