GLOBAL.setmetatable(env, { __index = function(t, k)
    return GLOBAL.rawget(GLOBAL, k)
end })
modimport("main/hh_assets.lua")
modimport("main/hh_config.lua")
modimport("main/hh_tunning.lua")
modimport("main/hh_string.lua")
modimport("main/hh_api.lua")
modimport("main/hh_act.lua")
modimport("main/hh_ui.lua")
modimport("main/hh_rpc.lua")
modimport("main/hh_sg.lua")
modimport("main/hh_recipe.lua")
modimport("main/hh_skin.lua")
--modimport("job/hh_job_ui.lua")
--modimport("job/hh_job_container.lua")
modimport("job/hh_job_rpc.lua")
--modimport("job/hh_job_api.lua")
--modimport("main/hh_container.lua")
PrefabFiles = {
    "hh_fx",
    "hh_prefabs",
    "hh_laser",
    "hh_weapon",
    "hh_build",
    "hh_lz_fx",
    "hh_com_prefab",
    "hh_boss",
    "hh_job_item",
}