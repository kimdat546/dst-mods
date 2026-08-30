local HH_UTILS = require("utils/hh_utils")
local HH_FX_CONFIG = require("enums/hh_fx_config")
local function CreateFx(fx_name, data)
    local function IntColour(r, g, b, a)
        return { r / 255, g / 255, b / 255, a / 255 }
    end
    --开始读取参数
    local fx_image = data["tex"] or "fx/sparkle.tex"
    local fx_shader = data["shader"] or "shaders/vfx_particle_add.ksh" --会有一点点紫色
    --粒子的颜色变化+大小变化 对应id
    local color_update_name = fx_name .. "color"
    local scale_update_name = fx_name .. "scale"

    local assets = { Asset("IMAGE", fx_image), Asset("SHADER", fx_shader), }

    local color_list = data["color_envelope"] or {
        { 0, IntColour(255, 255, 255, 200) },
        { 1, IntColour(255, 0, 0, 0) },
    }
    local glow_max_scale = 1.8 * 1.5
    local scale_list = data["scale_envelope"] or {
        { 0, { glow_max_scale, glow_max_scale } },
        { 0.3, { 0, 0 } },
        { 1, { 0, 0 } },
    }
    --粒子生命周期
    local GLOW_MAX_LIFETIME = data["life_time"] or 1

    --粒子图片 多图进行裁切
    local hh_uv_frame_size = data["uv_frame_size"] or nil
    --触发器数量
    local hh_emitters_num = data["emitters_num"] or 1

    --粒子最多的数量
    local hh_max_num_particles = data["max_num"] or 100
    --粒子混合模式
    local hh_blend_mode = data["blend_mode"] or BLENDMODE["Additive"]
    local hh_death_kill_all = data["need_kill_all"] or false

    local function InitEnvelope()
        -- 添加颜色变化，猜测表中第一个元素是一个类似渐变或者时间的东西
        -- 比如0表示生命周期的初始，1表示100%
        -- 后面是颜色值，对应rgba，最后一个a是透明度
        EnvelopeManager:AddColourEnvelope(color_update_name, color_list)
        -- 添加位置变化，与上面颜色变化一样，猜测表中第一个元素是一个类似渐变或者时间的东西
        -- 后面参数是缩放的大小了
        EnvelopeManager:AddVector2Envelope(scale_update_name, scale_list)
        InitEnvelope = nil
        IntColour = nil
    end


    -- 粒子触发器里第三个参数fn里调用的方法，展示粒子大小，方向，速度，生命周期等等信息
    local function emit_glow_fn(effect, emitter_fn)
        --移动速度
        --local vx, vy, vz = .005 * UnitRand(), 0.1, .005 * UnitRand()
        local vx, vy, vz = 0, 0, 0
        local lifetime = GLOW_MAX_LIFETIME --* (.9 + math.random() * .1)
        local px, py, pz = emitter_fn()
        px, py, pz = 0, 0, 0
        --px = px + math.random(-1, 1) * .2 -- 给x轴一个偏移量
        --py = py + math.random(-1, 1) * .2 -- 给y轴一个偏移量，测试发现y轴才是高度轴
        --pz = pz + math.random(-1, 1) * .2 -- 给z轴一个偏移量。给坐标偏移量是为了让出现的心不会在一块挤着
        --local uv_offset = math.random(0, 3) * .25
        local uv_offset = 0
        effect:AddRotatingParticle(
                0,
                lifetime, -- lifetime  生命周期
                px, py, pz, -- position  位置
                vx, vy, vz, -- velocity  速度
                uv_offset, -- angle               角度
                0    -- angle velocity           角速度
        )
    end

    local function fn()
        local inst = CreateEntity()

        inst["entity"]:AddTransform()
        inst["entity"]:AddNetwork()

        inst:AddTag("FX")

        inst["entity"]:SetPristine()

        inst["persists"] = false

        --Dedicated server does not need to spawn local particle fx
        if TheNet:IsDedicated() then
            return inst
        elseif InitEnvelope ~= nil then
            InitEnvelope() -- 初始化颜色和形状变化的设置
        end
        -- 给prefab添加粒子特效
        local effect = inst["entity"]:AddVFXEffect()
        -- 初始化有几个触发器
        effect:InitEmitters(hh_emitters_num)
        -- 渲染的资源，就是做的贴图与一个shader
        effect:SetRenderResources(0, fx_image, fx_shader)
        -- 循环状态开启
        effect:SetRotationStatus(0, true)

        if HH_UTILS:IsHHType(hh_uv_frame_size, "table") then
            --图片裁切
            effect:SetUVFrameSize(unpack(hh_uv_frame_size))
        end
        -- 最大粒子数
        effect:SetMaxNumParticles(0, hh_max_num_particles)
        -- 最大生命周期
        effect:SetMaxLifetime(0, 1)
        -- 颜色变化
        effect:SetColourEnvelope(0, color_update_name)
        -- 形状变化
        effect:SetScaleEnvelope(0, scale_update_name)
        -- 粒子混合模式 具体看常量类效果
        effect:SetBlendMode(0, hh_blend_mode)
        --未知
        effect:EnableBloomPass(0, true)
        effect:SetSortOrder(0, 0)
        effect:SetSortOffset(0, 2)
        --实体移除 是否清除所有粒子
        --effect:SetKillOnEntityDeath(0, hh_death_kill_all)
        --
        --effect:SetAcceleration(0, 0, -1.5, 0)
        --不知道干嘛
        --effect:SetDragCoefficient(1, .95)
        --effect:EnableDepthTest(0, false)--不启用深度测试
        -----------------------------------------------------
        local num_to_emit = 0
        local sphere_emitter = CreateSphereEmitter(0.5)
        inst["last_pos"] = inst:GetPosition()
        EmitterManager:AddEmitter(inst, nil, function()
            inst["last_pos"] = inst:GetPosition()
            --num_to_emit = num_to_emit + 0.5
            num_to_emit = num_to_emit + 0.5
            while num_to_emit > 1 do
                emit_glow_fn(effect, sphere_emitter)
                num_to_emit = num_to_emit - 1
            end
        end)

        return inst
    end
    return Prefab(fx_name, fn, assets)
end

local all_prefab = {}

for i, v in pairs(HH_FX_CONFIG) do
    table["insert"](all_prefab, CreateFx(i, v))
end
return unpack(all_prefab)