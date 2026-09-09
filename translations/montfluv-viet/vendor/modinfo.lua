--[[

    -----------------------------------------------  写在前面  ------------------------------------------------

    ！！！！！！！！！！！！！！！！！！！！！！
    岛屿生成的相关代码禁止搬运！二次发布！自用！
    ！！！！！！！！！！！！！！！！！！！！！！

    -----------------------------------------  关于mod中代码借鉴的问题  -----------------------------------------

    1. 岛屿、地皮、樱花建筑、樱花相关文本等
    岛屿的动态生成参考了樱花林（虽然没有继续使用），地皮、配方顺序等逻辑都有参考樱花林
    设计这个mod之前，作者受樱花林的激发产生了很多有趣的想法，所以一直很想与樱花林联动
    之前与ADM（樱花林的作者）聊过，ADM给了很多帮助，很感谢
    所以添加一个专属的小雕塑作纪念，并添加樱桃子与羽润的特殊事件对话等等
    后续章节会推出山参在樱花林花盆中种植的设计，简单尝试过视觉效果，感觉很不错

    2. 洞天塔
    可随身携带的小房子idea来自B站网友的建议，但是我个人不喜欢不能旋转视角的室内环境，所以没有采用流行的“锁死背景贴图的，且不能旋转视角”的那套方案
    旧版洞天塔借鉴自北甍大佬的《Candy House（糖果屋）》
    新版洞天塔为世界之外的独立世界
    注意：糖果屋的代码架构参考取得了糖果屋作者“北甍”的同意，如果有同好mod制作者想要参考糖果屋代码，还请取得原作者的同意，不要随意更改发布
    注意：本mod中关于岛屿生成的相关代码禁止搬运！二次发布！自用！
    
    3. 朱厌
    朱厌的设计原型是官方熔炉的生物beetletaur（地域独眼巨猪），代码参考自mod《ReForge（回炉）》。
    《ReForge》的代码受到RECEX SHARED SOURCE LICENSE (version 1.0)许可证的保护，在该许可证的限制下，
    开发者可以理解、学习该部分源码，但是---不能在没有作者许可的情况下修改、分发或用于其它项目---。
    注意：本mod已经与《ReForge》作者取得联系，并得到了作者的支持与许可。
    该代码不提供任何形式的担保，使用者需自行承担使用该代码的风险。
    具体许可条款请参考：<https://raw.githubusercontent.com/Recex/Licenses/master/SharedSourceLicense/LICENSE.txt>

    4. 世外岛屿
    世外岛屿的代码为付费购买，威吊做了一点简单的混淆，不允许破解及二次发布。
    想使用这部分代码模块，可以自行联系Jerry老板进行购买，或者联系威吊分摊一小部分费用以二次使用。

    -----------------------------------------           另外          -----------------------------------------

    我自己写代码的时候遇到很多内容不能理解，要一点点去自己翻，蛮累的，解释上面这些内容也是为了后来者可以有个参考，不至于一头雾水
    我自己的代码实现夹杂在这些内容里面有点不好分辨了，但如果想了解具体实现的话，可以联系我，我会尽可能提供帮助
    更重要的是，不许未经作者允许直接复用代码
    以及希望未来有更多优秀的代码可以出现

]]

local SH_LANGUAGE = 'en'
if locale  == "es" then
    SH_LANGUAGE = 'es'
elseif locale == "zh" or locale == "zht" or locale == "zhr" then
    SH_LANGUAGE = 'ch'
else
    SH_LANGUAGE = 'en'
end

name = "[DST] Montfluv"
author = "你要帮帮威吊"
version = "1.2.35"

local info_version = "[ Version "..version.." ]\n"
description = info_version..[[

󰀛background： 
Independent island outside of the world. 
Creatures and features based on the background of "Classic of Mountains and Seas".

Build your own base, explore the tower and defeat the beasts...
]]

if SH_LANGUAGE == 'es' then
    name = "[DST] Montfluv"
    description = info_version..[[

󰀛Contexto： 
¡Montañas y Ríos agrega algunas islas paradisíacas fuera del mapa! Solo necesitas resolver algunos acertijos para ir y construir tu base segura.

󰀛¡El segundo piso de la Torre de la Caverna Celestial ya está abierto, con más espacio para construir tu base!

󰀮Comentarios：
¡Se agradecen informes de errores, compartir ideas creativas y sugerencias para la interfaz!
]]
elseif SH_LANGUAGE == 'ch' then
    name = "[DST] 山河表里"
    description = info_version..[[

󰀛背景： 
山河表里在地图之外增加了一些世外岛屿，你只需要破解一些谜题，就能前往搭建自己的安全基地！

󰀛洞天塔二层已经开放，拥有更大的建家空间！

󰀮反馈：
QQ群聊：962910391
欢迎BUG反馈、脑洞分享、UI建议！
]]
end

-- 个人网址，即使没有也必须留空
forumthread = ""
-- api版本，单机写6，联机写10
api_version = 10
-- mod加载的优先级，不写就默认为0，越大越优先加载
priority = -3097

all_clients_require_mod = true
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
client_only_mod = false

icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

server_filter_tags = SH_LANGUAGE == 'ch' and { "山河表里", "山河" } or { "Montfluv" }

if SH_LANGUAGE == 'ch' then
    configuration_options = {
        -- 游戏设置
        {name = "Title", label = "游戏设置", options = {{description = "", data = ""}}, default = ""},
        {   name = "language",
            label = "游戏语言",                                  
            hover = "设置游戏内的语言，会同步影响到山河绘卷",                  
            options = {
                { description = "西语", data = "es" }, 
                { description = "英文", data = "en" }, 
                { description = "中文", data = "ch" }, 
            },
            default = "ch"                   -- 默认值，与可选项里的值匹配作为默认值
        },
        -- 洞天塔设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "洞天塔设置", options = {{description = "", data = ""}}, default = ""},
        {   name = "dsc_with_vines",
            label = "扭曲的大树自带寄生藤蔓",
            hover = "【世界生成后修改无效】开启后，一层大树的花藤被替换为3种寄生藤蔓",
            options = {
                {description = "开启",      data = true},
                {description = "关闭(默认)", data = false},
            },
            default = false
        },
        {   name = "dsc_with_koi",
            label = "洞天一层锦鲤出没",
            hover = "【重启世界后生效】是否让锦鲤在洞天一层的海洋出没",
            options = {
                {description = "是",      data = true},
                {description = "否(默认)", data = false},
            },
            default = false
        },
        {   name = "dsc_with_ban",
            label = "洞天一层的附岛禁忌",
            hover = "是否开启洞天一层的附岛禁忌，强制传送玩家离开？",
            options = {
                {description = "关闭",      data = false},
                {description = "开启(默认)", data = true},
            },
            default = true
        },
        {   name = "dsc_yurun_friend",
            label = "开局羽润好感度",
            hover = "是否开局直接拉满羽润的好感度，不做好感度任务了",
            options = {
                {description = "默认(默认)", data = false},
                {description = "拉满！",      data = true},
            },
            default = false
        },
        {   name = "dsc_mob_kill",
            label = "塔内敌对生物的处理",
            hover = "设置移除、秒杀出现在洞天塔内的一些生物，你需要它们的掉落物吗？",
            options = {
                {description = "秒杀",      data = true},
                {description = "移除(默认)", data = false},
            },
            default = false
        },
        -- 异兽强度设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "异兽强度设置", options = {{description = "", data = ""}}, default = ""},
        {   name = "sh_zhuyan_difficulty",
            label = "朱厌战斗强度",
            hover = "设置朱厌的战斗强度",
            options = {
                {description = "非常弱小",      data = 1},
                {description = "弱小",        data = 2},
                {description = "正常(默认)",    data = 3},
                {description = "强大",        data = 4},
                {description = "非常强大",      data = 5},
            },
            default = 3
        },
        {   name = "sh_qinyuan_difficulty",
            label = "钦原战斗强度",
            hover = "设置钦原的战斗强度",
            options = {
                {description = "非常弱小",      data = 1},
                {description = "弱小",        data = 2},
                {description = "正常(默认)",    data = 3},
                {description = "强大",        data = 4},
                {description = "非常强大",      data = 5},
            },
            default = 3
        },
        -- 爆率设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "道具爆率设置", options = {{description = "", data = ""}}, default = ""},
        {   name = "kunpeng_with_pack",
            label = "鲲鹏掉落坎普斯背包",
            hover = "设置鲲鹏掉落坎普斯背包的几率",
            options = {
                {description = "不掉落",           data = 0},
                {description = "0.1%",          data = 0.001},
                {description = "1%",            data = 0.01},
                {description = "3%(默认)",        data = 0.03},
                {description = "5%",            data = 0.05},
                {description = "10%",           data = 0.1},
                {description = "30%",           data = 0.3},
                {description = "50%",           data = 0.5},
                {description = "必定掉落",      data = 1.0},
            },
            default = 0.03
        },
        {   name = "goumang_dropchance",
            label = "句芒印记爆率",
            hover = "设置句芒印记的掉落几率",
            options = {
                {description = "不掉落",          data = 0},
                {description = "0.1%",          data = 0.001},
                {description = "1%",            data = 0.01},
                {description = "3%",            data = 0.03},
                {description = "7%(默认)",      data = 0.07},
                {description = "10%",           data = 0.1},
                {description = "30%",           data = 0.3},
                {description = "50%",           data = 0.5},
                {description = "必定掉落",      data = 1.0},
            },
            default = 0.07
        },
        {   name = "sh_timetaco_drop",
            label = "时空卷饼爆率",
            hover = "设置时空卷饼的掉落几率",
            options = {
                {description = "不掉落",          data = 0},
                {description = "0.1%(默认)",      data = 0.001},
                {description = "0.5%",          data = 0.005},
                {description = "1%",            data = 0.01},
                {description = "3%",            data = 0.03},
                {description = "10%",           data = 0.1},
                {description = "30%",           data = 0.3},
                {description = "50%",           data = 0.5},
                {description = "必定掉落",      data = 1.0},
            },
            default = 0.001
        },
        -- 生物再生和道具CD设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "生物再生和道具CD设置", options = {{description = "", data = ""}}, default = ""},
        {   name = "goumang_regrow",
            label = "句芒植株再生速度",
            hover = "设置句芒植株的基础再生速度",
            options = {
                {description = "1天",      data = 1},
                {description = "2天",        data = 2},
                {description = "3天(默认)",    data = 3},
                {description = "5天",        data = 4},
                {description = "10天",      data = 5},
            },
            default = 3
        },
        {   name = "ganoderma_regen",
            label = "灵芝长成速度",
            hover = "设置灵芝被采摘后的基础再生速度（下雨才会消耗这个计时）",
            options = {
                {description = "1天",           data = 16},
                {description = "2天(默认)",       data = 32},
                {description = "3天",           data = 48},
                {description = "5天",           data = 80},
                {description = "10天",           data = 160},
            },
            default = 32
        },
        {   name = "ganoderma_regrow",
            label = "灵芝再生速度",
            hover = "设置灵芝被铲除后的基础再生速度",
            options = {
                {description = "3天",           data = 3},
                {description = "5天",           data = 5},
                {description = "10天",           data = 10},
                {description = "15天",           data = 15},
                {description = "20天",           data = 20},
                {description = "30天(默认)",       data = 30},
                {description = "70天",           data = 70},
            },
            default = 30
        },
        {   name = "migutree_regrow",
            label = "迷榖树长成速度",
            hover = "设置迷榖树的基础再生速度",
            options = {
                {description = "3天",            data = 3},
                {description = "5天",            data = 5},
                {description = "10天(默认)",      data = 10},
                {description = "15天",           data = 15},
                {description = "30天",           data = 30},
            },
            default = 10
        },
        {   name = "xirang_cd",
            label = "息壤冷却时间",
            hover = "设置息壤的冷却时间",
            options = {
                {description = "1天",            data = 1},
                {description = "2天",            data = 2},
                {description = "3天(默认)",      data = 3},
                {description = "5天",           data = 5},
                {description = "10天",           data = 10},
            },
            default = 3
        },
        -- {   name = "xirang_regrow",
        --     label = "息壤再生时间",
        --     hover = "设置息壤的再生时间",
        --     options = {
        --         {description = "3天",            data = 3},
        --         {description = "5天",            data = 5},
        --         {description = "10天",           data = 10},
        --         {description = "15天",           data = 15},
        --         {description = "30天(默认)",      data = 30},
        --         {description = "50天",           data = 50},
        --     },
        --     default = 30
        -- },
        {   name = "dsc_copytool_cd",
            label = "云开冷却时间",
            hover = "设置云开的冷却时间",
            options = {
                {description = "无CD",            data = 0},
                {description = "0.1天(默认)",      data = 0.1},
                {description = "0.5天",           data = 0.5},
                {description = "1天",           data = 1},
            },
            default = 0.1
        },
        -- 料理设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "料理设置", options = {{description = "", data = ""}}, default = ""},
        {   name = "sh_ganodermaice_on",
            label = "芝上谈冰功效",
            hover = "关闭后，食用芝上谈冰不再解锁全科技",
            options = {
                {description = "关闭(默认)",      data = false},
                {description = "开启", data = true},
            },
            default = false
        },
        -- 显示设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "显示设置", options = {{description = "", data = ""}}, default = ""},
        {   name = "sh_migu_fx",
            label = "迷榖枝白天常亮",
            hover = "关闭后，冬季白天和黄昏的迷榖枝将不再发光（不包括洞穴）",
            options = {
                {description = "关闭",      data = false},
                {description = "开启(默认)", data = true},
            },
            default = true
        },
        -- {   name = "sh_leafpack_fx",
        --     label = "小叶篓顶部特效",
        --     hover = "关闭后，装备小叶篓不再出现暗影仆从手持小叶",
        --     options = {
        --         {description = "关闭",      data = false},
        --         {description = "开启(默认)", data = true},
        --     },
        --     default = true
        -- },
        {   name = "dsc_oceantree_fx",
            label = "扭曲的大树顶部树叶",
            hover = "关闭后，靠近扭曲的大树将不再出现顶部树叶遮盖",
            options = {
                {description = "关闭",      data = false},
                {description = "开启(默认)", data = true},
            },
            default = true
        },
        -- 末尾间隔行
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
    }
elseif SH_LANGUAGE == 'es' then
    configuration_options = {
        -- 游戏设置
        {name = "Title", label = "Configuración del juego", options = {{description = "", data = ""}}, default = ""},
        {   name = "language",
            label = "Idioma del juego",
            hover = "Establece el idioma del juego, también afectará a 'Shan He Hui Juan'",
            options = {
                { description = "Español",  data = "es" },
                { description = "Inglés",   data = "en" },
                { description = "Chino",    data = "ch" },
            },
            default = "ch"                   -- Valor por defecto, coincide con un valor de las opciones
        },
        -- 洞天塔设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "Configuración de la Torre Dongtian", options = {{description = "", data = ""}}, default = ""},
        {   name = "dsc_with_vines",
            label = "El gran árbol retorcido viene con enredaderas parásitas",
            hover = "【Inefectivo después de la generación del mundo】 Si está activado, las enredaderas del árbol del primer piso se reemplazan por 3 tipos de enredaderas parásitas",
            options = {
                {description = "Activado",      data = true},
                {description = "Desactivado (por defecto)", data = false},
            },
            default = false
        },
        {   name = "dsc_with_koi",
            label = "Aparece koi en el primer piso de la Torre",
            hover = "【Efectivo tras reiniciar el mundo】 ¿Hacer que el koi aparezca en el océano del primer piso de la Torre Dongtian?",
            options = {
                {description = "Sí",      data = true},
                {description = "No (por defecto)", data = false},
            },
            default = false
        },
        {   name = "dsc_with_ban",
            label = "Prohibición de islas adicionales en el primer piso",
            hover = "¿Activar la prohibición de islas adicionales en el primer piso de la Torre Dongtian, forzando a los jugadores a teletransportarse fuera?",
            options = {
                {description = "Desactivar",      data = false},
                {description = "Activar (por defecto)", data = true},
            },
            default = true
        },
        {   name = "dsc_yurun_friend",
            label = "Puntos de afinidad iniciales de Yurun",
            hover = "¿Llenar directamente los puntos de afinidad de Yurun al inicio, sin hacer las misiones de afinidad?",
            options = {
                {description = "Por defecto (por defecto)", data = false},
                {description = "¡Llenar!",      data = true},
            },
            default = false
        },
        {   name = "dsc_mob_kill",
            label = "Manejo de criaturas hostiles dentro de la Torre",
            hover = "Configura para eliminar o matar instantáneamente algunas criaturas que aparecen en la Torre Dongtian. ¿Necesitas sus objetos caídos?",
            options = {
                {description = "Matar instantáneamente",      data = true},
                {description = "Eliminar (por defecto)", data = false},
            },
            default = false
        },
        -- 异兽强度设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "Configuración de dificultad de Bestias Anómalas", options = {{description = "", data = ""}}, default = ""},
        {   name = "sh_zhuyan_difficulty",
            label = "Dificultad de combate de Zhuyan",
            hover = "Establece la dificultad de combate de Zhuyan",
            options = {
                {description = "Muy débil",      data = 1},
                {description = "Débil",        data = 2},
                {description = "Normal (por defecto)",    data = 3},
                {description = "Fuerte",        data = 4},
                {description = "Muy fuerte",      data = 5},
            },
            default = 3
        },
        {   name = "sh_qinyuan_difficulty",
            label = "Dificultad de combate de Qinyuan",
            hover = "Establece la dificultad de combate de Qinyuan",
            options = {
                {description = "Muy débil",      data = 1},
                {description = "Débil",        data = 2},
                {description = "Normal (por defecto)",    data = 3},
                {description = "Fuerte",        data = 4},
                {description = "Muy fuerte",      data = 5},
            },
            default = 3
        },
        -- 爆率设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "Configuración de tasas de caída de objetos", options = {{description = "", data = ""}}, default = ""},
        {   name = "kunpeng_with_pack",
            label = "Kunpeng deja caer la mochila de Krampus",
            hover = "Establece la probabilidad de que Kunpeng deje caer la mochila de Krampus",
            options = {
                {description = "No cae",           data = 0},
                {description = "0.1%",          data = 0.001},
                {description = "1%",            data = 0.01},
                {description = "3% (por defecto)",        data = 0.03},
                {description = "5%",            data = 0.05},
                {description = "10%",           data = 0.1},
                {description = "30%",           data = 0.3},
                {description = "50%",           data = 0.5},
                {description = "Cae siempre",      data = 1.0},
            },
            default = 0.03
        },
        {   name = "goumang_dropchance",
            label = "Tasa de caída del sello de Goumang",
            hover = "Establece la probabilidad de caída del sello de Goumang",
            options = {
                {description = "No cae",          data = 0},
                {description = "0.1%",          data = 0.001},
                {description = "1%",            data = 0.01},
                {description = "3%",            data = 0.03},
                {description = "7% (por defecto)",      data = 0.07},
                {description = "10%",           data = 0.1},
                {description = "30%",           data = 0.3},
                {description = "50%",           data = 0.5},
                {description = "Cae siempre",      data = 1.0},
            },
            default = 0.07
        },
        {   name = "sh_timetaco_drop",
            label = "Tasa de caída del taco del tiempo",
            hover = "Establece la probabilidad de caída del taco del tiempo",
            options = {
                {description = "No cae",          data = 0},
                {description = "0.1% (por defecto)",      data = 0.001},
                {description = "0.5%",          data = 0.005},
                {description = "1%",            data = 0.01},
                {description = "3%",            data = 0.03},
                {description = "10%",           data = 0.1},
                {description = "30%",           data = 0.3},
                {description = "50%",           data = 0.5},
                {description = "Cae siempre",      data = 1.0},
            },
            default = 0.001
        },
        -- 生物再生和道具CD设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "Configuración de regeneración de criaturas y enfriamiento de objetos", options = {{description = "", data = ""}}, default = ""},
        {   name = "goumang_regrow",
            label = "Velocidad de regeneración de la planta Goumang",
            hover = "Establece la velocidad de regeneración base de la planta Goumang",
            options = {
                {description = "1 día",      data = 1},
                {description = "2 días",        data = 2},
                {description = "3 días (por defecto)",    data = 3},
                {description = "5 días",        data = 4},
                {description = "10 días",      data = 5},
            },
            default = 3
        },
        {   name = "ganoderma_regen",
            label = "Velocidad de crecimiento del Ganoderma",
            hover = "Establece la velocidad de regeneración base del Ganoderma después de ser cosechado (solo consume este tiempo cuando llueve)",
            options = {
                {description = "1 día",           data = 16},
                {description = "2 días (por defecto)",       data = 32},
                {description = "3 días",           data = 48},
                {description = "5 días",           data = 80},
                {description = "10 días",           data = 160},
            },
            default = 32
        },
        {   name = "ganoderma_regrow",
            label = "Velocidad de regeneración del Ganoderma",
            hover = "Establece la velocidad de regeneración base del Ganoderma después de ser desenterrado",
            options = {
                {description = "3 días",           data = 3},
                {description = "5 días",           data = 5},
                {description = "10 días",           data = 10},
                {description = "15 días",           data = 15},
                {description = "20 días",           data = 20},
                {description = "30 días (por defecto)",       data = 30},
                {description = "70 días",           data = 70},
            },
            default = 30
        },
        {   name = "migutree_regrow",
            label = "Velocidad de crecimiento del árbol Migutree",
            hover = "Establece la velocidad de regeneración base del árbol Migutree",
            options = {
                {description = "3 días",            data = 3},
                {description = "5 días",            data = 5},
                {description = "10 días (por defecto)",      data = 10},
                {description = "15 días",           data = 15},
                {description = "30 días",           data = 30},
            },
            default = 10
        },
        {   name = "xirang_cd",
            label = "Tiempo de enfriamiento de Xirang",
            hover = "Establece el tiempo de enfriamiento de Xirang",
            options = {
                {description = "1 día",            data = 1},
                {description = "2 días",            data = 2},
                {description = "3 días (por defecto)",      data = 3},
                {description = "5 días",           data = 5},
                {description = "10 días",           data = 10},
            },
            default = 3
        },
        -- {   name = "xirang_regrow",
        --     label = "Tiempo de regeneración de Xirang",
        --     hover = "Establece el tiempo de regeneración de Xirang",
        --     options = {
        --         {description = "3 días",            data = 3},
        --         {description = "5 días",            data = 5},
        --         {description = "10 días",           data = 10},
        --         {description = "15 días",           data = 15},
        --         {description = "30 días (por defecto)",      data = 30},
        --         {description = "50 días",           data = 50},
        --     },
        --     default = 30
        -- },
        {   name = "dsc_copytool_cd",
            label = "Tiempo de enfriamiento de Yunkai",
            hover = "Establece el tiempo de enfriamiento de Yunkai",
            options = {
                {description = "Sin CD",            data = 0},
                {description = "0.1 días (por defecto)",      data = 0.1},
                {description = "0.5 días",           data = 0.5},
                {description = "1 día",           data = 1},
            },
            default = 0.1
        },
        -- 料理设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "Configuración de cocina", options = {{description = "", data = ""}}, default = ""},
        {   name = "sh_ganodermaice_on",
            label = "Efecto de 'Zhi Shang Tan Bing'",
            hover = "Si se desactiva, comer 'Zhi Shang Tan Bing' ya no desbloqueará todas las tecnologías",
            options = {
                {description = "Desactivado (por defecto)",      data = false},
                {description = "Activado", data = true},
            },
            default = false
        },
        -- 显示设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "Configuración de visualización", options = {{description = "", data = ""}}, default = ""},
        {   name = "sh_migu_fx",
            label = "Rama de Miguluz siempre encendida de día",
            hover = "Si se desactiva, la rama de Miguluz no brillará durante el día y el anochecer en invierno (excluyendo las cuevas)",
            options = {
                {description = "Desactivado",      data = false},
                {description = "Activado (por defecto)", data = true},
            },
            default = true
        },
        -- {   name = "sh_leafpack_fx",
        --     label = "Efecto superior de la cesta de hojas pequeñas",
        --     hover = "Si se desactiva, equipar la cesta de hojas pequeñas ya no mostrará a un sirviente de sombras sosteniendo una hoja pequeña",
        --     options = {
        --         {description = "Desactivado",      data = false},
        --         {description = "Activado (por defecto)", data = true},
        --     },
        --     default = true
        -- },
        {   name = "dsc_oceantree_fx",
            label = "Hojas de la copa del gran árbol retorcido",
            hover = "Si se desactiva, al acercarse al gran árbol retorcido no aparecerá la cobertura de hojas de la copa",
            options = {
                {description = "Desactivado",      data = false},
                {description = "Activado (por defecto)", data = true},
            },
            default = true
        },
        -- 末尾间隔行
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
    }
else
    configuration_options = {
        -- 游戏设置
        {name = "Title", label = "Game Settings", options = {{description = "", data = ""}}, default = ""},
        {   name = "language",
            label = "Game Language",
            hover = "Sets the in-game language, which also affects the Monfluv Desc.",
            options = {
                { description = "Spanish", data = "es" },
                { description = "English", data = "en" },
                { description = "Chinese", data = "ch" },
            },
            default = "en"                   -- Default value, matches the value in options as the default
        },
        -- 洞天塔设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "Montfluv Tower Settings", options = {{description = "", data = ""}}, default = ""},
        {   name = "dsc_with_vines",
            label = "Twisted Big Tree Comes with Parasitic Vines",
            hover = "[Invalid after world generation] When enabled, the flower vines on the first-floor big tree are replaced with 3 types of parasitic vines.",
            options = {
                {description = "Enabled",      data = true},
                {description = "Disabled (Default)", data = false},
            },
            default = false
        },
        {   name = "dsc_with_koi",
            label = "Koi Appear in Monfluv Tower First Floor",
            hover = "[Takes effect after world restart] Whether to allow koi to appear in the ocean of Montfluv Tower first floor.",
            options = {
                {description = "Yes",      data = true},
                {description = "No (Default)", data = false},
            },
            default = false
        },
        {   name = "dsc_with_ban",
            label = "Taboo of Attached Islands in Monfluv Tower First Floor",
            hover = "Whether to enable the taboo of attached islands in Monfluv Tower first floor, forcing players to teleport away?",
            options = {
                {description = "Disabled",      data = false},
                {description = "Enabled (Default)", data = true},
            },
            default = true
        },
        {   name = "dsc_yurun_friend",
            label = "Max Yurun's Favor",
            hover = "Whether to directly set Yurun's favor to maximum, skipping favor tasks.",
            options = {
                {description = "No (Default)", data = false},
                {description = "Yes",      data = true},
            },
            default = false
        },
        {   name = "dsc_mob_kill",
            label = "Handling of Hostile Creatures in the Tower",
            hover = "Set to remove or instantly kill some creatures that appear in the Monfluv Tower. Do you need their drops?",
            options = {
                {description = "Instant Kill",      data = true},
                {description = "Remove (Default)", data = false},
            },
            default = false
        },
        -- 异兽强度设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "Mobs Settings", options = {{description = "", data = ""}}, default = ""},
        {   name = "sh_zhuyan_difficulty",
            label = "Zhu Yan Battle Difficulty",
            hover = "Sets the battle strength of Zhu Yan.",
            options = {
                {description = "Very Weak",      data = 1},
                {description = "Weak",        data = 2},
                {description = "Normal (Default)",    data = 3},
                {description = "Strong",        data = 4},
                {description = "Very Strong",      data = 5},
            },
            default = 3
        },
        {   name = "sh_qinyuan_difficulty",
            label = "Qin Yuan's Battle Strength",
            hover = "Sets the battle strength of Qin Yuan.",
            options = {
                {description = "Very Weak",      data = 1},
                {description = "Weak",        data = 2},
                {description = "Normal (Default)",    data = 3},
                {description = "Strong",        data = 4},
                {description = "Very Strong",      data = 5},
            },
            default = 3
        },
        -- 爆率设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "Drop Chance Settings", options = {{description = "", data = ""}}, default = ""},
        {   name = "kunpeng_with_pack",
            label = "Kunpeng Drops Krampus Sack",
            hover = "Sets the chance for Kunpeng to drop a Krampus Sack.",
            options = {
                {description = "No Drop",           data = 0},
                {description = "0.1%",          data = 0.001},
                {description = "1%",            data = 0.01},
                {description = "3% (Default)",        data = 0.03},
                {description = "5%",            data = 0.05},
                {description = "10%",           data = 0.1},
                {description = "30%",           data = 0.3},
                {description = "50%",           data = 0.5},
                {description = "Guaranteed Drop",      data = 1.0},
            },
            default = 0.03
        },
        {   name = "goumang_dropchance",
            label = "Goumang's Fruit Drop Chance",
            hover = "Sets the drop chance for Goumang's Fruit.",
            options = {
                {description = "No Drop",          data = 0},
                {description = "0.1%",          data = 0.001},
                {description = "1%",            data = 0.01},
                {description = "3%",            data = 0.03},
                {description = "7% (Default)",      data = 0.07},
                {description = "10%",           data = 0.1},
                {description = "30%",           data = 0.3},
                {description = "50%",           data = 0.5},
                {description = "Guaranteed Drop",      data = 1.0},
            },
            default = 0.07
        },
        {   name = "sh_timetaco_drop",
            label = "Time Space Burrito Drop Chance",
            hover = "Sets the drop chance for Time Space Burrito.",
            options = {
                {description = "No Drop",          data = 0},
                {description = "0.1% (Default)",      data = 0.001},
                {description = "0.5%",          data = 0.005},
                {description = "1%",            data = 0.01},
                {description = "3%",            data = 0.03},
                {description = "10%",           data = 0.1},
                {description = "30%",           data = 0.3},
                {description = "50%",           data = 0.5},
                {description = "Guaranteed Drop",      data = 1.0},
            },
            default = 0.001
        },
        -- 生物再生和道具CD设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "Regrow & Cooldown Settings", options = {{description = "", data = ""}}, default = ""},
        {   name = "goumang_regrow",
            label = "Goumang Plant Regrowth Speed",
            hover = "Sets the base regrowth speed for Goumang plants.",
            options = {
                {description = "1 Day",      data = 1},
                {description = "2 Days",        data = 2},
                {description = "3 Days (Default)",    data = 3},
                {description = "5 Days",        data = 4},
                {description = "10 Days",      data = 5},
            },
            default = 3
        },
        {   name = "ganoderma_regen",
            label = "Ganoderma Regen Speed",
            hover = "Sets the base regen speed for Ganoderma.( Only count while raining)",
            options = {
                {description = "1 Day",           data = 16},
                {description = "2 Days(Default)", data = 32},
                {description = "3 Days",           data = 48},
                {description = "5 Days",           data = 80},
                {description = "10 Days",           data = 160},
            },
            default = 32
        },
        {   name = "ganoderma_regrow",
            label = "Ganoderma Regrowth Speed",
            hover = "Sets the base regrowth speed for Ganoderma.",
            options = {
                {description = "3 Days",           data = 3},
                {description = "5 Days",           data = 5},
                {description = "10 Days",           data = 10},
                {description = "15 Days",           data = 15},
                {description = "20 Days",           data = 20},
                {description = "30 Days (Default)", data = 30},
                {description = "70 Days",           data = 70},
            },
            default = 30
        },
        {   name = "migutree_regrow",
            label = "Migu Tree Regrowth Speed",
            hover = "Sets the base regrowth speed for Migu trees.",
            options = {
                {description = "3 Days",            data = 3},
                {description = "5 Days",            data = 5},
                {description = "10 Days (Default)",      data = 10},
                {description = "15 Days",           data = 15},
                {description = "30 Days",           data = 30},
            },
            default = 10
        },
        {   name = "xirang_cd",
            label = "Xirang Cooldown Time",
            hover = "Sets the cooldown time for Xirang.",
            options = {
                {description = "1 Day",            data = 1},
                {description = "2 Days",            data = 2},
                {description = "3 Days (Default)",      data = 3},
                {description = "5 Days",           data = 5},
                {description = "10 Days",           data = 10},
            },
            default = 3
        },
        -- {   name = "xirang_regrow",
        --     label = "Xirang Regrowth Time",
        --     hover = "Sets the regrowth time for Xirang.",
        --     options = {
        --         {description = "3 Days",            data = 3},
        --         {description = "5 Days",            data = 5},
        --         {description = "10 Days",           data = 10},
        --         {description = "15 Days",           data = 15},
        --         {description = "30 Days (Default)",      data = 30},
        --         {description = "50 Days",           data = 50},
        --     },
        --     default = 30
        -- },
        {   name = "dsc_copytool_cd",
            label = "Copytool Cooldown Time",
            hover = "Sets the cooldown time for Copytool.",
            options = {
                {description = "No Cooldown",            data = 0},
                {description = "0.1 Days (Default)",      data = 0.1},
                {description = "0.5 Days",           data = 0.5},
                {description = "1 Day",           data = 1},
            },
            default = 0.1
        },
        -- 料理设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {name = "Title", label = "Cooking Settings", options = {{description = "", data = ""}}, default = ""},
        {   name = "sh_ganodermaice_on",
            label = "Ganoderma Ice Effect",
            hover = "When disabled, eating Ganoderma Ice no longer unlocks all technologies.",
            options = {
                {description = "Disabled (Default)",      data = false},
                {description = "Enabled", data = true},
            },
            default = false
        },
        -- 显示设置
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
        {   name = "sh_migu_fx",
            label = "Migu Twig Light",
            hover = "When disabled, Migu Twig won't light anymore in winter's day and dusk(only forest)",
            options = {
                {description = "关闭",      data = false},
                {description = "开启(默认)", data = true},
            },
            default = true
        },
        -- {name = "Title", label = "Display Settings", options = {{description = "", data = ""}}, default = ""},
        -- {   name = "sh_leafpack_fx",
        --     label = "Leaf Backpack FX",
        --     hover = "When disabled, shadow servants will no longer appear holding small leaves when you equip the Leaf Basket.",
        --     options = {
        --         {description = "Disabled",      data = false},
        --         {description = "Enabled (Default)", data = true},
        --     },
        --     default = true
        -- },
        {   name = "dsc_oceantree_fx",
            label = "Twisted Tree FX",
            hover = "When disabled,  the top leaf cover will no longer appear when approaching the twisted tree.",
            options = {
                {description = "Disabled",      data = false},
                {description = "Enabled (Default)", data = true},
            },
            default = true
        },
        -- 末尾间隔行
        {name = "Title", label = "", options = {{description = "", data = ""}}, default = ""},
    }
end