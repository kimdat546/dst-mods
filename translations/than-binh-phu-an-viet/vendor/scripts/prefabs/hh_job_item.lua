local HH_ALL_PREFABS = require("job/hh_job_prefab")
local function addComPrefab(name, data)
    local function prefab_fn()
        local inst = CreateEntity()
        inst["entity"]:AddTransform()
        inst["entity"]:AddAnimState()
        inst["entity"]:AddNetwork()
        if data and data["client_fn"] then
            data["client_fn"](inst, name)
        end
        inst["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return inst
        end
        if data and data["server_fn"] then
            data["server_fn"](inst, name)
        end

        return inst
    end
    return Prefab(name, prefab_fn, data["assets"] or {})
end

local all_prefabs = {}
for i, v in pairs(HH_ALL_PREFABS) do
    table["insert"](all_prefabs, addComPrefab(i, v))
    STRINGS["NAMES"][string["upper"](i)] = v["name"] or "未定义"
    STRINGS["RECIPE_DESC"][string["upper"](i)] = v["recipe_str"] or "未定义"
    STRINGS["CHARACTERS"]["GENERIC"]["DESCRIBE"][string["upper"](i)] = v["desc"] or "未定义"
    if v["xml"] then
        local prefab_id = i
        local tex_id = prefab_id .. ".tex"
        if v["tex"] then
            tex_id = tostring(v["tex"])
        end
        RegisterInventoryItemAtlas(v["xml"], tex_id)
    end
end

return unpack(all_prefabs)