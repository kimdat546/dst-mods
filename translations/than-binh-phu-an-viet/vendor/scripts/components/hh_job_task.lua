local HH_UTILS = require("utils/hh_utils")
local HH_JOB_MONSTER = require("job/hh_job_monster")

local function createMonsterTable()
    local hh_table = {}
    for i, v in pairs(HH_UTILS:HHCopyTable(HH_JOB_MONSTER)) do
        hh_table[i] = 0
    end
    return hh_table
end
----
---职业系统
---
local HH_COM = Class(function(self, inst)
    self["inst"] = inst
    --选择的任务-上限6
    self["choose_tasks"] = {}
    --当前已经接取的任务-上限9
    self["tasks"] = {}

    --记录怪物击杀次数-接任务会自动重置对应生物的数量 置为0
    self["monster_num"] = createMonsterTable()
    --todo 换人/变猴子保存任务进度

end)

----
---当一个任务达到完成目标时会在展示页提示
---
function HH_COM:SendTaskSuccess()

end
----
---debug
---
function HH_COM:DebugString()
    local player = self["inst"]

    return ""
end

return HH_COM