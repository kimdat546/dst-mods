local HH_UTILS = require("utils/hh_utils")
local HH_SHOP = {
    ["shop_a"] = {
        ["id"] = 1,
        ["prefab_id"] = "",
        --校验函数-客户端
        ["check_client_fn"] = function(player)
        end,
        --服务端校验 双端校验
        ["check_server_fn"] = function(player)
        end,
        --道具初始函数
        ["start_fn"] = function(inst, player)
        end,

    },


}
return HH_SHOP