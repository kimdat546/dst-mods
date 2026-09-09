-- local _G = GLOBAL
-- local STRINGS = _G.STRINGS
local ___________NAMES = STRINGS.NAMES
local _________ACTIONS = STRINGS.ACTIONS
local _______SKINNAMES = STRINGS.SKIN_NAMES
local ________ANNOUNCE = STRINGS.CHARACTERS.GENERIC
local ________DESCRIBE = STRINGS.CHARACTERS.GENERIC.DESCRIBE
local _____RECIPE_DESC = STRINGS.RECIPE_DESC
local ___OPEN_CRAFTING = STRINGS.ACTIONS.OPEN_CRAFTING
local CRAFTING_FILTERS = STRINGS.UI.CRAFTING_FILTERS
local ___CUSTOMIZATION = STRINGS.UI.CUSTOMIZATIONSCREEN
local ________COOKBOOK = STRINGS.UI.COOKBOOK
local ________CRAFTING = STRINGS.UI.CRAFTING


STRINGS.SH_MODNAME = "Montfluv"
___CUSTOMIZATION.DSC_WITH_VINES = "La torre viene con enredaderas parásitas"
___CUSTOMIZATION.DSC_YURUN_FRIEND = "Yurun comienza amistoso"
___CUSTOMIZATION.DSC_WITH_BAN = "Tabúes adjuntos en la isla dentro de la torre"
___CUSTOMIZATION.DSC_WITH_KOI = "Aparecen carpas koi dentro de la torre"
___CUSTOMIZATION.ZHUYUAN_DIFFICULTY_LEVEL = "Nivel de dificultad para matar a Zhu Yan"
___CUSTOMIZATION.QINYUAN_DIFFICULTY_LEVEL = "Nivel de dificultad de muerte súbita de Qin Yuan"
___CUSTOMIZATION.GOUMANG_DROP_CHANCE = "Probabilidad de caída de la marca de Gou Mang"
___CUSTOMIZATION.TACO_DROP_CHANCE = "Probabilidad de caída del burrito espacio-temporal"
___CUSTOMIZATION.GOUMANG_GROW_SPEED = "Velocidad de regeneración de Gou Mang"
___CUSTOMIZATION.GANODERMA_GROW_SPEED = "Velocidad de regeneración del Ganoderma"
___CUSTOMIZATION.MIGUTREE_GROW_SPEED = "Velocidad de regeneración de la rama de Migutree"
___CUSTOMIZATION.SEANEST_GROW_SPEED = "Velocidad de regeneración del nido de pájaro marino"
___CUSTOMIZATION.XIRANG_CD_SPEED = "Velocidad de enfriamiento de Xirang"
___CUSTOMIZATION.CLOUDMOVE_CD_SPEED = "Velocidad de enfriamiento de Cloudmove"
___CUSTOMIZATION.KUNPENG_WITH_PACK = "Kunpeng siempre da una mochila"
---------------------------------------------------------------
------------------------动作 名称-------------------------------
---------------------------------------------------------------
_________ACTIONS.ACTIVATE.KNOCKPIG = "Llamar a la puerta"
_________ACTIONS.ACTIVATE.PUSHSTONE = "Presionar"
_________ACTIONS.ACTIVATE.JUMPHOLE = "Saltar abajo"
_________ACTIONS.ACTIVATE.SH_SPIN_MIGU = "Guiar el camino"
_________ACTIONS.ACTIVATE.DSC_UPGRADE = "Sacrificar"
_________ACTIONS.DEPLOY.DSC_PLACE = "Desbloquear"
_________ACTIONS.DEPLOY.SH_BOAT_PLACE = "Colocar"
_________ACTIONS.DEPLOY.UNROLL_SCROLL = "Desenrollar"
_________ACTIONS.DEPLOY.SH_PIECE_PLACE = "Poner pieza"
_________ACTIONS.DEPLOY.SH_ABYSS_PLACE = "Colocar"
_________ACTIONS.SHBOATMOUNT = "Embarcar"
_________ACTIONS.SHBOATDISMOUNT = "Desembarcar"
_________ACTIONS.SHACTIVATELIGHT = "Encender"
_________ACTIONS.SHDESACTIVATELIGHT = "Apagar"
_________ACTIONS.SHRETRIEVE = "Recuperar"

---------------------------------------------------------------
------------------------制作提示------------------------------
---------------------------------------------------------------
________CRAFTING.NEEDSPDSPIG_SHOP = "Necesitamos la ayuda de Zhu Yuan"

---------------------------------------------------------------
------------------------N P C昵称------------------------------
---------------------------------------------------------------
-- NPCs fijos, el dúo Zhu Yuan Yu Run
-- Más tarde, al descifrar el sello de la torre, Zhu Yuan estará dispuesto a salir y Yu Run podrá salir de la torre.
STRINGS.DEEPSEACAVE_CROW    = { "Yu Run", } -- { "Wu Ya", "Ya Yu", "Yu Run", "Run Wu" }
STRINGS.DEEPSEACAVE_PIGMAN  = { "Zhu Yuan", } -- { "Zhen Zhu", "Zhu Yuan", "Yuan Ze", "Ze Zhen" }

---------------------------------------------------------------
------------------------物品名称--------------------------------
---------------------------------------------------------------
___________NAMES.SHANHAI_KUNLUNISLAND = "Isla de la Vena del Dragón Kunlun"
___________NAMES.SHANHAI_DEEPSEACAVE = "Primer piso de la Torre de la Caverna Celestial"
___________NAMES.SHANHAI_DEEPSEACAVE_TWO = "Segundo piso de la Torre de la Caverna Celestial"
___________NAMES.SH_FLY = "Escoba voladora"
___________NAMES.SH_COOKPOTFIRE = "Fuego de la cocina"
___________NAMES.SH_BOAT = "Pequeño bote de hojas"
___________NAMES.SH_HELPER = "Voz antigua"
___________NAMES.SH_SEASTACK = "Pilar de erosión marina"
___________NAMES.SH_MARSH_PLANT = "Planta"
___________NAMES.SH_POND_ALGAE = "Alga"
___________NAMES.SH_TICTACTOE_GAME = "Tres en raya"

___________NAMES.TORTOISE_CUSTARD = "Budín de huevo de tortuga"
___________NAMES.SHANHAI_BUBBLETEA = "Té de burbujas Shan Hai Xian Cao"
___________NAMES.SH_GANODERMAICE = "Hielo sobre Ganoderma"
___________NAMES.SH_NEVEROLD = "Elixir de la inmortalidad"
___________NAMES.SH_TACO = "Burrito de Montañas y Ríos"
___________NAMES.SH_ZHULONG_TACO = "Burrito del Tiempo y el Espacio"
___________NAMES.SH_BACKYOUNG = "Píldora del rejuvenecimiento"

___________NAMES.STATUE_CHAOFENG = "Estatua de Cien Pájaros Adorando al Fénix"
___________NAMES.STATUE_ZHULONG_USE = "Estatua de Zhu Long, Crepúsculo y Aurora"
___________NAMES.STATUE_NIEPAN = "Estatua del Renacimiento en el Fuego"
___________NAMES.STATUE_EATMOON = "Estatua del Perro Celestial Comiendo la Luna"
___________NAMES.STATUE_ZHUYAN = "Estatua de Zhu Yan, el Desastre Bélico"
___________NAMES.SH_CHERRYSTATUE = "Estatua del plano de unión"
___________NAMES.DEEPSEACAVE_UPGRADER = "Altar de sacrificio"
___________NAMES.SH_SEASONAQUARIUM = "Acuario de los Cuatro Símbolos"
___________NAMES.SHANHAI_SHELLCHEST = "Cofre de conchas"
___________NAMES.SHANHAI_HIDDENCELLAR_USE = "Cofre de candado de piedra"
___________NAMES.SHANHAI_SMALLSTATUE = "Pequeña estatua conmemorativa"
___________NAMES.XUANHE_POND = "Estanque del Río Suspendido"
___________NAMES.DEEPSEACAVE = "Torre de la Caverna Celestial"
___________NAMES.DEEPSEACAVE_SEAL = "Sello de la Torre de la Caverna Celestial"
___________NAMES.DEEPSEACAVE_EXIT = "Salida de la Caverna Celestial"
___________NAMES.DEEPSEACAVE_WALL = "Pared de la Caverna Celestial"
___________NAMES.DEEPSEACAVE_POOL = "Pequeño estanque de piedra"
___________NAMES.DSC_POOL = "Pequeño estanque de piedra"
___________NAMES.DEEPSEACAVE_PIGHOUSE = "La cabaña de Zhu Yuan"
___________NAMES.SHANHAI_NORMALPILE = "Montículo de tierra algo grande"
___________NAMES.SHANHAI_SECRETPLACE = "Formación mágica de Zhu Long"
___________NAMES.SHANHAI_SECRETORDER = "Escala musical"
___________NAMES.SHANHAI_GONG = "Gong"
___________NAMES.SHANHAI_SHANG = "Shang"
___________NAMES.SHANHAI_JUE = "Jue"
___________NAMES.SHANHAI_ZHI = "Zhi"
___________NAMES.SHANHAI_YU = "Yu"
___________NAMES.SHANHAI_FINISHORDER = "="
___________NAMES.SH_ROCK_1 = "Roca decorativa"
___________NAMES.SH_SEANEST = "Nido de pájaro marino"
___________NAMES.SH_SEANEST_KIT = "Poste de mejillón"
___________NAMES.STATUE_ZHULONG = "Zhu Long sellado"
___________NAMES.SH_BRIDGE = "Puente colgante de madera"
___________NAMES.SH_ZHUYAN_SPAWNER = "Montaña Xiao Ci"
___________NAMES.SH_TICTACTOE_BOARD = "Tablero de tres en raya"
___________NAMES.DSC_CAVE_ENTRANCE = "Entrada de la cueva celestial bloqueada"
___________NAMES.DSC_CAVE_ENTRANCE_OPEN = "Entrada de la cueva celestial"
___________NAMES.DSC_CAVE_EXIT = "Escalera de la caverna celestial"
___________NAMES.DSC_MUSHROOM_TO_2 = "Ganoderma camuflado"
___________NAMES.XUANHE_FALL = "Cascada del Río Suspendido"
___________NAMES.SH_ABYSSPILLAR = "Pequeño pilote de madera"
___________NAMES.SH_ABYSSPILLAR_ITEM = "Pequeño pilote de madera"
___________NAMES.DSC_CAVE_MAGICSEAL = "Cadena selladora de demonios"
___________NAMES.DSC_CAVE_MAGICPLACVE = "Formación selladora de demonios"
___________NAMES.DSC_CAVE_STAFFLIGHT = "Estrella enana de la caverna celestial"

___________NAMES.DSC_OCEANTREE_PILLAR = "Árbol torcido gigante"
___________NAMES.SHANHAI_HIDDENEXIT = "Roca prominente"
___________NAMES.SHANHAI_HIDDENEXIT_2 = "Grieta del segundo piso"
___________NAMES.SHANHAI_HIDDENCELLAR = "Roca misteriosa"
___________NAMES.SHANHAI_GOUMANG_ITEM = "Hoja de Gou Mang"
___________NAMES.SHANHAI_GOUMANG_PLANT = "Gou Mang"
___________NAMES.SHANHAI_GOUMANG = "Marca de Gou Mang"
___________NAMES.SHANHAI_SHANSHEN = "Ginseng de montaña"
___________NAMES.SHANHAI_SHANSHEN_ACTIVE = "Espíritu del ginseng de montaña"
___________NAMES.SHANHAI_SHANSHEN_PLANTED = "Ginseng de montaña"
___________NAMES.SHANHAI_COOKEDSHANSHEN = "Esencia de ginseng de montaña"
___________NAMES.SHANHAI_XIRANG = "Tierra misteriosa"
___________NAMES.SHANHAI_XIRANG_ITEM = "Xirang (tierra mística)"
___________NAMES.SHANHAI_GANODERMA = "Ganoderma"
___________NAMES.GANODERMA_CAP = "Ganoderma"
___________NAMES.GANODERMA_CAP_COOKED = "Ganoderma asado"
___________NAMES.SHANHAI_MUSHROOMGUARD1 = "Cornamenta de ciervo"
___________NAMES.SHANHAI_MUSHROOMGUARD2 = "Cornamenta de ciervo"
___________NAMES.SHANHAI_MUSHROOMGUARD3 = "Cornamenta de ciervo"
___________NAMES.SHANHAI_PINECONE_SAPLING = "Retoño de pino siempreverde hinchado"
___________NAMES.SHANHAI_GINKGO = "Ginkgo"
___________NAMES.SHANHAI_GINKGOLEAVE = "Hoja de ginkgo"
___________NAMES.SHANHAI_GINKGOLEAVE_GROUND = "Decoración de hojas de ginkgo"
___________NAMES.SHANHAI_GINKGO_SAPLING = "Retoño de ginkgo"
___________NAMES.SHANHAI_GINKGO_TREE = "Árbol de ginkgo"
___________NAMES.SHANHAI_SEED_GEM = "Enredadera de semilla de geoda"
___________NAMES.SHANHAI_SEED_NIGHT = "Enredadera de semilla de baya nocturna"
___________NAMES.SHANHAI_SEED_TALLBIRDEGG = "Enredadera de semilla de huevo de pájaro alto"
___________NAMES.SHANHAI_SEED_SHANSHEN = "Enredadera de semilla de ginseng de montaña"
___________NAMES.SHANHAIVINE_GEM = "Enredadera de geoda"
___________NAMES.SHANHAIVINE_NIGHT = "Enredadera de baya nocturna"
___________NAMES.DSC_EGGVINE = "Enredadera de huevo de pájaro alto"
___________NAMES.SHANHAI_PINECONE = "Retoño hinchado"
___________NAMES.SHANHAIVINE_MOON = "Enredadera floral"
___________NAMES.DSC_FLOWERVINE = "Enredadera floral"
___________NAMES.SHANHAI_EXITVINE = "Enredadera floral"
___________NAMES.SHANHAI_FLOWERVINE = "Guirnalda floral"
___________NAMES.DUG_SHANHAI_GOUMANG_PLANT = "Planta de Gou Mang"
___________NAMES.SH_FLOWER = "Flor de montaña"
___________NAMES.SH_MIGUTREE = "Árbol Migutree (árbol de guía)"
___________NAMES.SH_MIGUTWIG = "Rama de Migutree"
___________NAMES.SH_PLANTDECO = "Pequeña maceta"
___________NAMES.SH_ANIMAL_TRACK = "Rastro extraño"
___________NAMES.SADDLE_KUN_GROUND = "Nube"
___________NAMES.DSC_OCEANTREE_PILLAR_2 = "Árbol torcido gigante"
___________NAMES.SH_THULECITE = "Fruto de thulecita"
___________NAMES.SH_THULECITE_SEEDS = "Semilla de veta mineral"
___________NAMES.FARM_PLANT_SH_THULECITE = "Planta de fruto de thulecita"
___________NAMES.SH_THULECITE_OVERSIZED = "Fruto de thulecita gigante"
___________NAMES.SH_THULECITE_OVERSIZED_WAXED = "Fruto de thulecita gigante encerado"

___________NAMES.SHANHAI_STARFLY = "Guía estelar"
___________NAMES.SHANHAI_MOONFALL = "Caída lunar"
___________NAMES.SADDLE_KUN = "Silla de montar de nube"
___________NAMES.SHANHAI_REDROPE = "Cuerda roja"
___________NAMES.SH_SPARKLER_SMALL = "Varita mágica"
___________NAMES.SH_SPARKLER_1 = "Fuegos artificiales pequeños"
___________NAMES.SH_SPARKLER_2 = "Fuegos artificiales"
___________NAMES.SH_SPARKLER_3 = "Fuegos artificiales grandes"
___________NAMES.SH_KILLALL_WEAPON = "Cuerno de Zhu Yan"
___________NAMES.SH_IRONOPENWORK_BASE = "Fuegos artificiales pequeños de Pi Xiu"
___________NAMES.SH_IRONOPENWORK_BASE_KIT = "Componentes de fuegos artificiales pequeños de Pi Xiu"
___________NAMES.SH_FIREWORKS = "Fuegos artificiales de cuervo pequeño"
___________NAMES.SHANHAI_WINTER_TREE = "Árbol siempreverde festivo"
___________NAMES.DSC_LIGHT = "Fuego extraño"
___________NAMES.DSC_COPYTOOL = "Nubes despejadas"
___________NAMES.XUANHE_PASSPORT = "Jade espiritual del Río Suspendido"
___________NAMES.SH_REDPAPER = "Papel de pistas"
___________NAMES.SH_HEALTH = "Salud"
___________NAMES.SH_DESC = "Pergamino de Montañas y Ríos"
___________NAMES.TURF_SH_ICELAND = "Loseta de superficie helada"
___________NAMES.TURF_SH_SMALLSTONE = "Loseta de jardín"
___________NAMES.TURF_SH_XMM = "Loseta XMM"
___________NAMES.TURF_SH_COLORXMM = "Loseta Mingming"
___________NAMES.TURF_SH_LITTLESTONE = "Loseta de grava"
___________NAMES.TURF_SH_MANYSTONE = "Loseta de gravilla"
___________NAMES.SH_QYSTICK = "Aguijón de cola de Qin Yuan"
___________NAMES.SH_FEATHER_PHOENIX = "Pluma multicolor"
___________NAMES.SHPIGHAT = "Disfraz sencillo"
___________NAMES.SH_MAGICSHANSHEN = "Escoba mágica de ginseng"
___________NAMES.SH_BACKPACK_LEAF = "Cesta de hojas"
___________NAMES.SH_LEAFBOAT_ITEM = "Pequeño bote de hojas"
___________NAMES.SH_LEAFBOAT = "Pequeño bote de hojas"
___________NAMES.SH_BOAT_TORCH = "Vela de hoja pequeña"
___________NAMES.SH_FEATHERSAIL = "Vela de hoja pequeña"
___________NAMES.SH_BASEFAN = "Ventilador pequeño"
___________NAMES.SH_ZYBELL = "Campanilla de Zhu Yan"
___________NAMES.SH_PANFLUTE = "Flauta de pan de hoja pequeña"
___________NAMES.SH_TICTACTOE_PIECE_X = "Pieza de ajedrez"
___________NAMES.SH_TICTACTOE_PIECE_O = "Pieza de ajedrez"
___________NAMES.SH_MAGICVEST = "Túnica de mangas del cosmos"

___________NAMES.DSC_MUSHROOM_TO_2_BLUEPRINT = "Planos de Ganoderma camuflado"
___________NAMES.SHANHAI_GOUMANG_BLUEPRINT = "Planos de la marca de Gou Mang"
___________NAMES.STATUE_CHAOFENG_BLUEPRINT = "Planos de Cien Pájaros Adorando al Fénix"
___________NAMES.STATUE_ZHULONG_USE_BLUEPRINT = "Planos de Zhu Long, Crepúsculo y Aurora"
___________NAMES.STATUE_EATMOON_BLUEPRINT = "Planos del Perro Celestial Comiendo la Luna"
___________NAMES.SH_CHERRYSTATUE_BLUEPRINT = "Planos de unión"
___________NAMES.XUANHE_FALL_BLUEPRINT = "Planos de la cascada del Río Suspendido"
___________NAMES.SH_MIGUTREE_BLUEPRINT = "Planos del árbol Migutree"

___________NAMES.DEEPSEACAVE_PIGMAN = "Zhu Yuan"
___________NAMES.DEEPSEACAVE_CROW = "Yu Run"
___________NAMES.KUNPENG = "Kun"
___________NAMES.SHANHAI_PHOENIX = "Imagen ilusoria del Fénix"
___________NAMES.KUNPENG_ATTACK_HORN = "Kun"
___________NAMES.KUNPENG_HORN = "Cuerno de Kun"
___________NAMES.SHANHAI_ZHUYAN = "Zhu Yan"
___________NAMES.SHANHAI_BLUEFLY = "Mariposa"
___________NAMES.SHANHAI_GREENFLY = "Mariposa de hojas"
___________NAMES.SHANHAI_ORANGEFLY = "Mariposa de hoja de albaricoque"
___________NAMES.SHANHAI_WHITEFLY = "Mariposa"
___________NAMES.KUN_RIDER = "Kunpeng"
___________NAMES.DSC_TREECRAB = "Cangrejo brillante"
___________NAMES.SH_PAPERBIRD = "Golondrina de papel"
___________NAMES.SH_QINYUAN = "Qin Yuan"
___________NAMES.SH_FISHSPAWNER = "Banco de peces pequeños"
___________NAMES.DEEPSEACAVE_FISH = "Carpa koi de la caverna celestial"
___________NAMES.SH_CRITTER_FOXING = "Zorro de nueve colas"
___________NAMES.SH_CRITTER_FOXING_BUILDER = "Zorro de nueve colas"
___________NAMES.SH_FSM_MONKEY_ZHUYAN = "Zhu Yan pequeño"
___________NAMES.DSC_ELDERSWAMPIG = "Anciano de tierras extrañas"
___________NAMES.DSC_PIG_SHOP = "La tiendita de Zhu Yuan"
___________NAMES.DSC_PIG_SHOP_ABANDONED = "Tiendita cerrada"
___________NAMES.SH_BACKPACK_LEAF_FX = "Sirviente de hojas pequeñas"
___________NAMES.SH_MONKEY = "Mono"


------------------------配方说明--------------------------------
_____RECIPE_DESC.SHANHAI_REDROPE = "¿Acaso no se puede teñir con bayas?"
_____RECIPE_DESC.DUG_SHANHAI_GOUMANG_PLANT = "Revívelo a un pequeño costo"
_____RECIPE_DESC.STATUE_ZHULONG_USE = "Usa el poder de Zhu Long para controlar el tiempo"
_____RECIPE_DESC.STATUE_ZHUYAN = "Zhu Yan es experto en sembrar discordia"
_____RECIPE_DESC.STATUE_CHAOFENG = "Invoca a esa enorme figura en el cielo"
_____RECIPE_DESC.STATUE_NIEPAN = "Ayúdanos a revivir a algunos amigos, o enemigos"
_____RECIPE_DESC.STATUE_EATMOON = "Nunca muerde personas, pero muerde otras cosas"
_____RECIPE_DESC.SH_SPARKLER_SMALL = "Lanza magia feliz"
_____RECIPE_DESC.SH_SPARKLER_1 = "Consigue un poco de ambiente festivo"
_____RECIPE_DESC.SH_SPARKLER_2 = "Comparte la alegría festiva"
_____RECIPE_DESC.SH_SPARKLER_3 = "Cuidado, no prendas fuego a la montaña"
_____RECIPE_DESC.SHANHAI_STARFLY = "El poder de las estrellas y la gravedad"
_____RECIPE_DESC.SHANHAI_MOONFALL = "No hace falta esperar a la próxima lluvia de estrellas"
_____RECIPE_DESC.SADDLE_KUN = "Solución perfecta para la silla de montar en el mar"
_____RECIPE_DESC.SHANHAI_SHELLCHEST = "Tantos fragmentos de concha, al fin sirven para algo"
_____RECIPE_DESC.SHANHAI_HIDDENCELLAR_USE = "Bodega de piedra más grande"
_____RECIPE_DESC.BOAT_ANCIENT_CONTAINER = "Usa el ingenio, no solo los marineros saben hacer esto"
_____RECIPE_DESC.SHANHAI_SMALLSTATUE = "¿Por qué no regresan los eventos? ¿Quién sabe?"
_____RECIPE_DESC.SHANHAI_FLOWERVINE = "Flores hermosas, luna llena, personas duraderas"
_____RECIPE_DESC.SHANHAI_PINECONE = "Ahora no tenemos que preocuparnos de que se extinga"
_____RECIPE_DESC.DEEPSEACAVE_UPGRADER = "Mejora el espacio dentro de tu torre"
_____RECIPE_DESC.SH_SEASONAQUARIUM = "El crecimiento de los cultivos ya no está limitado por la estación"
_____RECIPE_DESC.SH_CHERRYSTATUE = "Para conmemorar la amistad de los pequeños monstruos"
_____RECIPE_DESC.SHANHAI_SEED_GEM = "¡Fuente más estable de frutos de geoda!"
_____RECIPE_DESC.SHANHAI_SEED_NIGHT = "¡Fuente más estable de bayas nocturnas!"
_____RECIPE_DESC.SHANHAI_SEED_TALLBIRDEGG = "¡Fuente más estable de huevos de pájaro alto!"
_____RECIPE_DESC.SHANHAI_SEED_SHANSHEN = "Planta ginseng de montaña"
_____RECIPE_DESC.SHANHAIVINE_MOON = "Decoración de enredadera floral de árbol lunar"
_____RECIPE_DESC.SH_IRONOPENWORK_BASE_KIT = "Cuidado, no prendas fuego a la montaña"
_____RECIPE_DESC.SH_FIREWORKS = "Fuegos artificiales con forma de cuervo"
_____RECIPE_DESC.SH_ROCK_1 = "Decoración de paisaje hecha de piedra"
_____RECIPE_DESC.SH_SEANEST_KIT = "¿Poste de madera? ¡Mejillón!"
_____RECIPE_DESC.SH_PLANTDECO = "Pueden usarse para decorar la base"
_____RECIPE_DESC.SH_DESC = "Guía de ayuda del MOD"
_____RECIPE_DESC.TURF_SH_ICELAND = "¡Mil millas de hielo!"
_____RECIPE_DESC.TURF_SH_SMALLSTONE = "Pequeñas piedras esparcidas en el jardín"
_____RECIPE_DESC.TURF_SH_XMM = "Gracias XMM"
_____RECIPE_DESC.TURF_SH_COLORXMM = "Esta vez gracias a X Mingming"
_____RECIPE_DESC.TURF_SH_LITTLESTONE = "Suelo de grava grande"
_____RECIPE_DESC.TURF_SH_MANYSTONE = "Suelo de gravilla pequeña"
_____RECIPE_DESC.DEEPSEACAVE_SEAL = "Escribe un hechizo mágico en papel"
_____RECIPE_DESC.SH_QYSTICK = "Impregnar el aguijón de abeja con energía celestial"
_____RECIPE_DESC.SH_CRITTER_FOXING_BUILDER = "Adopta un zorro de nueve colas"
_____RECIPE_DESC.SHPIGHAT = "¡Infíltrate en la tribu de cerdos!"
_____RECIPE_DESC.SHANHAI_GINKGOLEAVE_GROUND = "Decora tu base con hojas de ginkgo"
_____RECIPE_DESC.SHANHAI_GOUMANG = "Condensar manualmente la energía del cielo y la tierra"
_____RECIPE_DESC.SH_MIGUTREE = "Usa el poder de Gou Mang para revivir ese árbol brillante"
_____RECIPE_DESC.SH_MAGICSHANSHEN = "Crea un artefacto occidental con materiales orientales, ¡a volar!"
_____RECIPE_DESC.SH_ABYSSPILLAR = "Nos permite cruzar el océano"
_____RECIPE_DESC.SH_ABYSSPILLAR_ITEM = "Nos permite cruzar el océano"
-- _____RECIPE_DESC.SH_ABYSSPILLAR_BOMB = "Bomba de pequeño escalón de piedra"
_____RECIPE_DESC.SADDLE_KUN_GROUND = "Nube pegajosa, no preguntes de qué está hecha"
_____RECIPE_DESC.SH_BACKPACK_LEAF = "¡Mochila que repele la lluvia y aísla el calor!"
_____RECIPE_DESC.SH_BASEFAN = "Hace que el aroma de la olla llegue más lejos"
_____RECIPE_DESC.SH_LEAFBOAT_ITEM = "¡Ahora es la Era de los Descubrimientos!"
_____RECIPE_DESC.SH_PANFLUTE = "Es el eco de una voz antigua"
_____RECIPE_DESC.SEASTACK = "Hace tiempo que queríamos arrecifes"
_____RECIPE_DESC.MARSH_PLANT = "Decoración de pequeña planta"
_____RECIPE_DESC.POND_ALGAE = "Decoración de pequeño musgo"
_____RECIPE_DESC.DSC_MUSHROOM_TO_2 = "Ahora podemos ir al segundo piso"
_____RECIPE_DESC.DSC_PIG_SHOP = "Tienda de segunda mano del Continente Eterno"
_____RECIPE_DESC.DSC_COPYTOOL = "Mapa viviente que te lleva de vuelta a la torre"
_____RECIPE_DESC.XUANHE_FALL = "Crea tu propio paisaje acuático de estilo antiguo"
_____RECIPE_DESC.DSC_MUSHROOM_TO_2_BLUEPRINT = "Aprende a hacer un catapulta"
_____RECIPE_DESC.SHANHAI_GOUMANG_BLUEPRINT = "Usa tu propio método para condensar la vida"
_____RECIPE_DESC.STATUE_CHAOFENG_BLUEPRINT = "Cien pájaros adorando al fénix, renacer de las cenizas"
_____RECIPE_DESC.STATUE_ZHULONG_USE_BLUEPRINT = "Zhu Long, el crepúsculo y la aurora, ver, dormir, respirar, exhalar"
_____RECIPE_DESC.STATUE_EATMOON_BLUEPRINT = "El perro celestial come la luna, guau guau guau guau"
_____RECIPE_DESC.SH_CHERRYSTATUE_BLUEPRINT = "Planos de la estatua del plano de unión"
_____RECIPE_DESC.XUANHE_FALL_BLUEPRINT = "Aprende a hacer una cascada decorativa"
_____RECIPE_DESC.SH_MIGUTREE_BLUEPRINT = "Aprende a trasplantar un árbol Migutree"
_____RECIPE_DESC.DSC_POOL = "Cava un hoyo, llénalo de agua"

------------------------科技、绘卷--------------------------------
CRAFTING_FILTERS.SHANHAIJING = "Montañas y Ríos Interior y Exterior"
___________NAMES.SHANHAIJING_BOOK = "Clásico de las Montañas y los Mares"

---------------------------------------------------------------
------------------------额外文本--------------------------------
---------------------------------------------------------------
-- 刷新皮肤
STRINGS.SH_SKINS_UPDATE = "Actualizar skins"
-- 种藤的等级
STRINGS.SH_LEVEL = "Nivel"
-- 时空卷饼
STRINGS.SH_TIMETACO_PRE = "Burrito-"
-- 原山海经的文本
STRINGS.SHANHAIJING_UI = {
BOOK_DESCRIBE = "Neblina oculta la cima de la montaña, el río de estrellas en silencio",
BOOK_BUTTON = "Leyenda",
FENGHUANG = "Fénix",
KUNPENG = "Kunpeng",
YAZI = "Ya Zi",
ZHUYAN = "Zhu Yan",
ZHULONG = "Zhu Long",
}
-- 皮肤名称
_______SKINNAMES.SH_CROW_MOON = "Flor de árbol lunar"
_______SKINNAMES.SH_CROW_GOUMANG = "Hoja de Gou Mang"
_______SKINNAMES.SH_FLOWER_WHITE = "Árbol de los pañuelos (Davidia involucrata)"
_______SKINNAMES.SH_FLOWER_ORANGE = "Lirio"
_______SKINNAMES.SH_FLOWER_YELLOW = "Allamanda (flor amarilla)"
_______SKINNAMES.sh_rock_1 = "Clásico"
_______SKINNAMES.shanhai_decovine = "Clásico"
_______SKINNAMES.shanhai_flowervine = "Clásico"

-- 皮肤提示文本
STRINGS.SH_SKINS = {
    KEY_IS_NULL = "La clave o los datos cifrados no pueden estar vacíos",
    DATA_IS_INVAILD = "Datos cifrados inválidos",
    DATAFORMAT_ERROR = "Error de descifrado: formato de datos incorrecto",
    CDK_IS_NULL = "El CDK no puede estar vacío",
    CDK_NOT_FULL = "Por favor, verifica si el CDK es estándar y está completo",
    CDK_DECRYPT_ERROR = "Error al analizar el CDK",
    WITH_OTHER_CDK = "Se mezcló el CDK de otra persona",
    CDK_IS_INVALID = "CDK inválido",
    VALIDATE_SUCCESS = "¡Canje exitoso!",
    SYNC_SUCCESS = "Sincronización exitosa, gracias por el apoyo, pequeño jefe",
    SYNC_FAIL = "Error de sincronización\nPor favor, verifica si el script está ejecutándose",
    CDK_BUTTON = "Canjear CDK",
    SYNC_BUTTON = "Actualizar skins",
    CLOSE_BUTTON = "Cerrar",
    SKIN_INFO = "\nInformación de skin:",
    FAIL_INFO = "Error de canje:",
}

---------------------------------------------------------------
-------------------------台词文本--------------------------------
---------------------------------------------------------------
-------------------------鲲鹏的台词------------------------------
STRINGS.KUN_IDLE = {
    "Los tiempos han cambiado, el mundo es diferente",
    "Mi especie una vez pobló este océano",
    "He regresado desde el abismo…",
}
STRINGS.KUN_ATTACK_LINES = {
    "¡Libertad!",
    "¡Recibe mi ira!",
    "Este mundo ya no es como antes, ¡pero solo la venganza perdura en mi corazón!",
    "¡Fuera de aquí! ¡Mortal!",
}
STRINGS.KUN_ICE_LINES = {
    "Mi poder mágico se ha desvanecido demasiado…",
    "¡Congélate!",
    "¡Hielo!",
    "¡Veamos si la escarcha aún obedece mis órdenes!",
}
STRINGS.KUN_SACK = {
    "Mi poder mágico se ha desvanecido demasiado…",
    "Un pequeño regalo de agradecimiento…",
    "Gracias por venir a verme",
}
STRINGS.KUN_EAT = {
    "¿Has venido a rescatarme?",
    "Dicen que hay un gran tiburón de escarcha en el mar, tiene una colección de botas...",
    "Necesito unas botas de fuga, ¿puedes ayudarme?",
    "Gracias por venir a verme",
}
STRINGS.KUN_ESCAPE = {
    "¡Libertad!",
    "Los tiempos han cambiado, el mundo es diferente",
    "¡Veamos si el océano aún obedece mis órdenes!",
    "Este mundo ya no es como antes, ¡pero solo la libertad perdura en mi corazón!",
}

    -- La mayor parte del texto de Zhu Yuan fue generada por ChatGPT 4o, ajustado por Wei Diao
    -------------------------Diálogos de Zhu Yuan------------------------------
    STRINGS.ZHUYUAN_NIGHT = {
        "Salir a tiempo es la bendición de un cerdo",
        "Aunque sea tarde, hay que dormir",
        "El cerebro está inactivo, necesita urgentemente el servicio de la manta",
        "Sobrecarga cerebral porcina, regreso a cargar",
        "Un cerdo elegante nunca se queda despierto hasta tarde",
        "Sigan trabajando hasta tarde, el cerdo se va a su habitación",
        "El sol se va a casa, el cerdo también",
        "¡Ja, cerdo gordo golpeando la puerta!",
        "Yo y la cama, enamorados mutuos",
        "¡No ser entusiasta al salir del trabajo es un problema de actitud!",
        "El conocimiento necesita sedimentarse, el cerdo necesita acostarse",
        "El cerdo tiene una cita con el Duque Zhou",
    }
    STRINGS.ZHUYUAN_STEAL_FOUND = {
        "¡Esto es una inspección in situ de la vida útil de los alimentos!",
        "El cerdo está investigando el control de progreso de la tecnología de refrigeración...",
        "Ahem, la hermeticidad de esta nevera... necesita ser revisada",
        "El cerdo te ayuda a verificar la función de detección de la puerta de la nevera",
        "¡Desperdiciar cosas valiosas es un gran pecado! ¡El cerdo está asumiendo la culpa por ti!",
        "Hace calor, el cerdo viene a enfriar su estómago",
        "La puerta de la nevera se abrió sola",
        "Fue la gravedad la que hizo que este trozo de carne cayera en la boca del cerdo",
        "Prueba de veneno, una noble tradición dejada por Shennong en la antigüedad",
        "¡Perspectiva! ¡Compartir es una virtud!",
        "La cálida transmisión de la cadena alimenticia, ¿no la entiendes?",
        "La nevera sedujo al cerdo con su aire frío",
        "El cerdo no robó comida, la comida se ofreció voluntariamente",
        "La comida lanzó un grito del alma de '¡cómeme rápido!'",
    }
    STRINGS.ZHUYUAN_TOPLAYER = {
        "El pueblo toma el cielo como su principio, el cerdo toma la comida como... todo",
        "Haz más neveras, el cerdo puede ser el almacenero",
        "Luego el cerdo cuelga al cuervo, tú recoges las cosas que caigan",
        "¿No necesitas dormir?",
        "Zhu Yuan, ¿suena bastante elegante, no?",
        "¿No entiendes el idioma porcino? ¡La educación aún necesita extenderse!",
        "¡Cuando el cerdo estaba en Hamlet, era un guardaespaldas de la corte!",
        "¡Eh, ven a comer!",
        "Tu equipo, más ornamental que práctico",
        "Golondrina de papel que transmite sentimientos, mensajes a miles de millas",
        "¿Qué es... 'usar las pinzas de cangrejo para ordenar a los cerdos y monos'?",
        "La sabiduría del cerdo, mitad en los libros, mitad en la olla",
        "Si la doctrina no se entiende, el cerdo también sabe algo de artes marciales",
        "¿Sabes por qué los cerdos son inteligentes?",
        "¿Observar las estrellas por la noche? El cerdo es mejor observando la nevera de noche",
        "Hablar de guerra en el papel es superficial, manejar la cuchara al lado de la olla es lo verdadero",
        "El cerdo tararea una melodía, dividiendo Gong, Shang, Jue, Zhi, Yu",
        "La llamada sabiduría, tres partes de estudio, siete partes de comida llena",
        "La receta del cerdo, la conozco de memoria al revés",
        "El cerdo está feliz de que el Gran Rey Cerdo todavía esté vivo",
        "El cerdo tardó mucho en reparar la formación mágica de la cueva",
    }
    STRINGS.ZHUYUAN_OPENFRIDGE = {
        "Silenciosamente, no hagan ruido",
        "¡Hora de buscar tesoros!",
        "¡Inicia la compra a precio cero!",
        "Solo pasando, si consigo algo, es destino",
        "El paso debe ser elegante, los movimientos rápidos",
        "El cerdo tiene un apetito muy pequeño",
        "Compartir recursos no autorizado",
        "¡Puerta de la nevera, obedece la llamada del cerdo!",
        "Deja que el cerdo vea qué sorpresa hay hoy",
        "¡Abrir! ¡Abrir!",
        "El corazón se acelera, es la diversión de abrir una caja sorpresa",
        "El cerdo viene a inspeccionar su futura propiedad",
        "El cerdo puede abrir la nevera, el cerdo te mostrará cómo se hace, ja",
    }
    -- STRINGS.ZHUYUAN_FRIDGE = {
    --     "¡Nevera! ¿Hay sistema de electricidad en la torre?",
    --     "Vino y comida suficientes, salgo con un andar porcino~",
    --     "Cien pasos después de comer, se puede vivir hasta los noventa y nueve",
    --     "Este efecto de refrigeración, ¿es la legendaria formación de hielo?",
    --     "Con la nevera, la vida del cerdo está medio completa",
    --     "¡El cerdo te proclama como el más fuerte!",
    -- }
    STRINGS.ZHUYUAN_COOK = {
        "El cerdo calcula con su pata, este archivo podría terminar en separación",
        "La vida hace que al cerdo le sea difícil",
        "Cocinar es crear, lavar platos es destruir",
        "El cerdo solo puede garantizar cocinarlo, no que sepa bien",
        "Total, esto también se va a echar a perder pronto",
        "¡Ding! La comida sorpresa aleatoria ya está en línea",
        "Cocinar es una apuesta arriesgada",
        "¿Delicia culinaria o cocina oscura? Que el cielo lo decida",
        "El cerdo se encarga de la parte mística de la cocina, la parte física se la deja a la olla",
        "Que esté cocido cuenta como éxito, lo salado o insípido es la sorpresa que da el cielo",
        "Según la receta del cerdo, se hace así",
        "Receta secreta exclusiva, no mata a nadie",
    }
    STRINGS.ZHUYUAN_COOKPOT = {
        "¿Estas ollas van a explotar?",
        "Mientras haya olla, hay esperanza",
        "Una olla vacía es una falta de respeto a los ingredientes",
        "Es hora de que esta olla cumpla su sagrada misión",
        "Este es el momento cumbre de la olla",
        "Una olla sin ingredientes es como un bolígrafo sin tinta",
    }
    STRINGS.ZHUYUAN_BACKSELF = {
        "El cerdo escuchó algo sobre una torre de chocolate...",
        "Después de comer, hacer la digestión, se trata de un paseo tranquilo",
        "El pájaro malo seguro está difamando al cerdo",
        "La expedición del cerdo son las estrellas... y el piso de arriba",
        "Con la linterna frontal puesta, el cerdo es un cerdo luminoso nocturno",
        "El segundo piso está reparado, pero ¿y el tercero?...",
        "Lleno de comida, literalmente",
        "Pensar en la vida del cerdo, comenzando con un paseo",
        "El cerdo no está gordo, es que el conocimiento es más pesado",
        "Caminar más para poder comer más",
        "Cien vueltas caminando, pueden intercambiarse por medio panecillo al vapor",
        "Subir alto y mirar lejos, lo que se ve es el humo de la cocina",
        "Donde llega la luz del cerdo, no hay sobras ni restos que se puedan esconder",
        "Este es el gran camino de 'moverse en la quietud, buscar comida después de estar lleno'",
        "Capacidad estomacal, no solo para contener comida, sino también para contener a todos los glotones del mundo",
        "De repente siento que mis patas levantan viento, en realidad es hambre",
        "'¿Gran sabiduría parece un pez'? El cerdo cree que no es tan bueno como 'gran sabiduría parece un cerdo'",
        "¡Pájaro malo, no hagas ruido!",
        "¡Pájaro malo, quieres que el cerdo te cuente 'Culinaria de Aves'?",
    }
    STRINGS.ZHUYUAN_OVEREAT = {
        "Siete partes lleno, tres partes elegancia",
        "La razón le dice al cerdo que debe parar",
        "No hay ingredientes que despierten el deseo de degustar del cerdo",
        "Erupc~",
        "El estómago del cerdo dice que sí, pero el cinturón del cerdo dice que no",
        "El cerdo no quiere comer, es que la boca tiene sus propias ideas",
        "Reserva de alimentos... ejem, parece que se reservó hasta la garganta",
    }
    STRINGS.ZHUYUAN_GIVEBACK = {
        "Casa vacía, cuatro paredes, viento fresco, vida miserable del cerdo",
        "¿El jugador ya está tan pobre que necesita la compasión del cerdo?",
        "Rayos, parece que el cerdo se comió la economía del jugador",
        "El hambre, realmente ha comenzado",
        "Es hora de llevar a cabo un gran movimiento de búsqueda de comida",
        "Ni siquiera hay sobras frías, la vida del cerdo no tiene esperanza",
        "El cerdo debe considerar la viabilidad de la fotosíntesis",
    }
    STRINGS.ZHUYUAN_CANNOTCOOK = {
        "El noble se mantiene alejado de la cocina, los antiguos no me engañaron",
        "El talento del cerdo está en campos más amplios",
        "El humo aceitoso es el enemigo del conocimiento",
        "Las manos del cerdo son para sostener libros y palillos, no para sostener espátulas",
        "Cocinar interfiere con la pura apreciación del cerdo por la buena comida",
        "Cada oficio tiene su especialidad, la del cerdo es el 'arte de comer'",
    }
    STRINGS.ZHUYUAN_STARVE = {
        "¡Ay! ¡El cerdo se muere de hambre!",
        "¡Alimentar! ¡Inmediatamente!",
        "Energía insuficiente, las cuatro patas echan raíces…",
        "¡Cadáveres de hambre por todas partes!",
        "¡Salven al niño! ¡Salven al cerdito!",
        "¡Los HP del cerdo están llegando a cero!",
        "Hambriento hasta que el pecho toque la espalda",
        "¡Extremidades débiles, órganos internos vacíos!",
        "El estómago del cerdo está cantando 'La leyenda del lobo hambriento'...",
        "Hambriento hasta desmayarse...",
        "¡El hambre es una tortura para el cerdito!",
    }
    STRINGS.ZHUYUAN_STARVE_SUCCESS = {
        "¡Eres realmente un hombre de gran sabiduría!",
        "¡Un aroma a comida, es el gran hechizo de resurrección del cerdo!",
        "El cerdo siente que el conocimiento y la fuerza han regresado juntos",
        "La gracia de una gota de agua, debería... ¡debería ser otro tazón!",
        "Salvaste el mundo del cerdo",
        "¡Eres el padre renacido del cerdo! Bueno, ¡padre de la comida!",
        "¡El cerdo, después de llenarse, está dispuesto a componer un poema para ti!",
        "¡Esta gracia, esta virtud, inolvidable incluso sin dientes!",
        "A partir de hoy, eres el cuidador principal del cerdo",
        "Siento que la inteligencia ha retomado la colina alta",
        "¡Esta bondad, el cerdo primero la registra en el estómago!",
        "¡Gracias, has preservado la semilla de la sabiduría para el mundo!",
        "¡Revivido!",
    }
    STRINGS.ZHUYUAN_STARVE_FAIL = {
        "El mundo es frío, el corazón del cerdo puede atestiguarlo…",
        "La conciencia del jugador, probablemente fue robada junto con la comida",
        "Error de cálculo, tenderse como cadáver también debería elegir un lugar central",
        "El cerdo va a morir, muere muy tranquilo… ¡mentira!",
        "Anotado en la libreta, la enésima vez que me ignoran",
        "¿Es esto la naturaleza humana? El cerdo lo ha visto claro",
        "En la lápida del cerdo pondrán: Muerto por la indiferencia del jugador",
        "Nunca más me junto con jugadores que no dan de comer",
        "El corazón está muy frío, más que el estómago sin comida...",
        "El cerdo está aquí, la comida está lejos",
        "¿El sacrificio del cerdo ni siquiera puede cambiar un poco tu culpa?",
        "La herencia del cerdo... es... un estómago lleno de... aire",
    }
    STRINGS.ZHUYUAN_DANCE_PLANT = {
        "¡Dang Dang Kang Kang, crece rápido~!",
        "¡Crecimiento, vida, felicidad y mis amigos~!",
        "¡Crece! ¡Crece! ¡Crece! ¡Crece rápido y bien!",
        "¡Señor Gou Mang! ¡Ayuda, que salgan rábanos de tres pies!",
        "¡En nombre de Dang Kang, te otorgo vitalidad!",
        "¡Bum cha-cha, crece rápido, hay esperanza de cenar extra esta noche!",
        "¡Hojas que crecen, flores que florecen, frutos que dan para que el cerdo alabe!",
        "¡Crece rápido, crece gordo, el estómago del cerdo está al mando!",
    }
    STRINGS.ZHUYUAN_CANNOT_DANCE = {
        "El feng shui aquí no es bueno, afecta la magia del cerdo",
        "La formación mágica necesita espacio",
        "Bueno, hoy no es un día apropiado para mover tierra",
        "Aquí no es apropiado para realizar rituales",
        "Aquí las venas de la tierra están bloqueadas, déjame desatascarlas un rato",
    }
    STRINGS.ZHUYUAN_TALK_PANICBOSS = {
        "¡Maten al cerdo! ¡Socorro!!",
        "¡Corran rápido!",
        "¡Retirada estratégica! ¡Rápido!",
        "¡La vida del cerdo está en juego, cerdos ociosos, aléjense!",
        "¡Corre! ¿Acaso esperas a convertirte en cerdo rojo estofado?",
        "¡Un noble no se para bajo un muro peligroso, y un cerdo tampoco!",
    }
    STRINGS.ZHUYUAN_TALK_FIND_MEAT = {
        "La voluntad del cerdo es débil ante la buena comida",
        "Esta maldita tentación",
        "¡Comida! Con aroma a libertad",
        "Un bocado, ¿cuántas libras ganará el cerdo?",
        "Esto no es glotonería, es la búsqueda devota de la buena comida",
        "¡Esto es una trampa abierta! La carne movió la mano primero",
        "En la antigüedad, Liu Xiahui se sentaba con una mujer en brazos sin alterarse, hoy el cerdo ve carne...",
        "La luz de la carne brilla, el plato es perfecto",
        "Si el pájaro malo ve esta escena, seguro se burlará",
        "La práctica del cerdo siempre se rompe al ver carne",
        "El cerdo reflexiona tres veces: ¿Se puede comer? ¿Debería comerse? ¿Cómo comerlo?",
        "Oler este aroma carnoso es como escuchar los sonidos antiguos",
        "Esta carne es nube auspiciosa",
        "La carne cayó al suelo en menos de 3 segundos",
    }
    STRINGS.ZHUYUAN_TALK_ATTEMPT_TRADE = {
        "Tu mirada hacia el cerdo no es muy pura, ¿verdad?",
        "¿Intercambio de objetos, o intercambio de comida por favores?",
        "Intercambio equivalente, sin engaños a niños o ancianos",
        "¿Quieres cambiar algo con el cerdo? Muestra tu sinceridad",
        "Una mano entrega el dinero, la otra entrega la mercancía",
        "El cerdo tiene cosas buenas en sus manos",
    }
    STRINGS.ZHUYUAN_TALK_GIVE_GIFT = {
        "¡Monedas de hocico de cerdo, sin engaños a niños o ancianos!",
        "Toma, toma, no molestes más al cerdo mientras come",
        "Toma, para ti, no lo cuentes por ahí",
        "Este objeto tiene conexión contigo",
        "Guárdalo bien, en un momento crucial puede… puede que sirva para cambiar un panecillo al vapor",
        "El regalo del cerdo, contiene... bueno... los sentimientos del cerdo",
    }
    STRINGS.ZHUYUAN_FIGHTCROW = {
        "¡Vamos a pelear!",
        "¿Comparar magia o comparar capacidad para comer?",
        "¡La táctica del cerdo: ¡dominar con el peso!",
        "¡Las habilidades del guardaespaldas de la corte, el cerdo no las ha olvidado!",
        "¡Pájaro ruidoso, ¿reconoces este 'tanque de carne'?!",
        "Plumas no desarrolladas, el cerdo puede dejarte tres movimientos",
        "¡Hoy te haré ver lo que es 'el conocimiento es peso'!",
        "¡El cerdo al cargar, ¡hasta él mismo tiene miedo!",
        "¡Ataque porcino violento!",
        "Fin de los saludos, ¡toma esto!",
        "¡El cerdo te enseñará algunos movimientos de 'el cocinero desmiembra al buey'!",
        "¡Toma esto! ¡Eructo que estremece el cielo!",
        "El señor Dang Kang no permite que el cerdo actúe, el pájaro malo es la excepción",
        "El cerdo va a taparte la boca",
        "¡Pájaro malo! ¡Robando los bocadillos del cerdo!",
    }
    STRINGS.ZHUYUAN_GOSHOP = {
        "Puerta de cerdo, carne y vino apestan, el cuervo arruga el ceño",
        "Llegando, llegando",
        "¡Cliente, por aquí, por favor!",
        "Espere un momento, cliente",
        "Cerdo gordo golpeando la puerta",
        "Ataque porcino violento",
        "¡Si no compras, no toques!",
    }
    STRINGS.ZHUYUAN_HITSHOP = {
        "Vienes a destruir el negocio",
        "La tienda desapareció, el cielo se derrumbó",
        "Mejor me hagas una tienda nueva",
    }
    STRINGS.ZHUYUAN_TALKSHOP = {
        "No toques al azar, ¿eh?",
        "¿Qué quieres?",
        "Servicio con sonrisa~",
        "El cliente es Dios~",
    }
    STRINGS.ZHUYUAN_BREWSHOP = {
        "Enseguida está listo",
        "Preparando el stock",
        "El trabajo lento produce buen trabajo",
    }

    -- 羽润的文本大部分由ChatGPT 4o生成，威吊自行调整
    -------------------------羽润的台词------------------------------
    STRINGS.YURUN_SHOCK = {
        "¡Oh no, alguien me lanzó un hechizo a Corvus!",
        "¡Achís!",
        "¡La cabeza de Corvus!",
        "¿Es un ataque aéreo?",
    }
    STRINGS.YURUN_ANGRY = {
        "Estás lleno de maldad, la próxima vez no caigas en manos de Corvus.",
        "Cuando Corvus era joven, era más educado que tú.",
        "¡Corvus ya no es tu mejor amigo del mundo!",
        "¿Engañas los sentimientos de Corvus?",
        "Hoy Corvus no quiere hablar más contigo.",
        "De ahora en adelante, habla menos con Corvus.",
        "¡Pequeño monstruo arrogante, te convertirás en cuervo asado por bestias feroces!",
        "¿Quieres carne de cerdo larga fresca? Corvus la tiene aquí.",
        "¡Esta semana no podrás salir de rojo!",
        "¡Tu mérito -1! -1! -1!",
        "¡Corvus te pondrá en la lista de morosos!",
        "¡Corvus borra tu mérito de esta semana!",
        "Corvus te sacará de la lista de reproducción compartida.",
        "Corvus cree que tu conciencia se ha ido.",
        "Corvus te escribirá en la 'Guía de cómo morir siendo un villano'.",
        "¡Al salir de la torre, un rayo te dejará sin una sola pluma!",
        "¡Realmente no eres un buen pájaro!",
    }
    STRINGS.YURUN_CAMPFIRE = {
        "La luz de la fogata tranquiliza a Corvus.",
        "¡La fogata es como las alas del gran Fénix!",
        "La habilidad de los humanos para hacer fuego es asombrosa.",
        "Corvus quiere un brasero con alas.",
        "¿Agregamos más ramas?",
        "¡Antes, al gran Fénix le encantaba arreglar sus plumas con fuego!",
        "No te acerques demasiado al fuego, las plumas de Corvus no son a prueba de fuego.",
        "Ten cuidado, no dejes que el fuego queme a Corvus.",
        "Corvus se siente como el dios del fuego Zhu Rong.",
        "Corvus también quiere ayudarte a agregar combustible.",
        "Corvus se siente calentito por todas partes.",
        "A Corvus le gusta la fogata.",
        "El crepitar de las llamas.",
        "El fuego puede ahuyentar a los monstruos.",
        "Corvus se siente lleno de energía.",
        "Si el fuego es demasiado fuerte, Corvus se convertirá en cuervo asado.",
        "Si el fuego es demasiado débil, Corvus temblará.",
    }
    STRINGS.YURUN_TOCHERRYPLAYER = {
        "¿Puedes contarle a Corvus sobre el bosque de cerezos?",
        "Corvus también quiere ir a ver el bosque de cerezos.",
        "¡Él le contó muchas historias sobre el bosque de cerezos a Corvus!",
        "¡Antes había un terreno del bosque de cerezos en la torre!",
        "Corvus quiere probar las cerezas.",
        "¿Hay flores mágicas en el bosque de cerezos?",
        "¿Realmente llueven pétalos de cerezo en el bosque de cerezos?",
        "¡El viento en el bosque de cerezos trae un aroma dulce!",
        "¿Realmente hay cerezos antiguos?",
        "¿Es real la leyenda del bosque de cerezos?",
        "El bosque de cerezos es hermoso como un sueño.",
        "¿Hay cerezas azules?",
        "¿Refresco de cereza? Corvus cree que mejor no.",
    }
    STRINGS.YURUN_TOPLAYER = {
        "Corvus vio a una chica llamada Charlie, no es fácil de tratar.",
        "¿Has visto al gran Fénix?",
        "¿Necesitas algo de Corvus?",
        "Hola, pequeño monstruo sin plumas.",
        "Corvus siente curiosidad por ti.",
        "¿Serás buen amigo de Corvus?",
        "¿Buscar ayuda? Primero aclaro, ¡Corvus no es bueno para pelear!",
        "Corvus cree que los humanos siempre piensan demasiado.",
        "¡Oye! ¡Oye! Corvus tiene hambre.",
        "¿Prestas tu arma para que Corvus juegue un rato?",
        "A Corvus le gusta estar contigo.",
        "¿Puede ayudar Corvus?",
        "Pareces muy ocupado.",
        "No eres tan hábil como Corvus, pero estás bien.",
        "¿Enseñas a Corvus algo de lo que sabes?",
        "Tu apariencia ocupada atrae a Corvus.",
        "¿Acabas de estar holgazaneando?",
        "Cuéntale un pequeño secreto a Corvus, Corvus lo guardará.",
        "¿Corvus es muy especial, no?",
        "¡Corvus es el pájaro más inteligente de la torre!",
        "Corvus cree que te pareces a él.",
        "Pareces un pequeño héroe.",
        "Corvus espera que recibas regalos rojos todos los días.",
        "Hoy Corvus se arregló un poco el cabello, ¿qué te parece?",
        "¿Vienes a arrancarle plumas a Corvus?",
        "¿Extrañas a Corvus?",
        "Corvus cree que podrías cambiarte de ropa.",
        "Me asustaste.",
        "Sin plumas, ¡y sin cola! Qué pobre eres.",
        "La magia se transmite a Corvus, no a los humanos, búscalo con el cerdo.",
        "¿Encontraste plumas de colores?",
        "Tienes mucho talento, ¡aprende a ser un cuervo con Corvus!",
        "¿El cerdo dice que es un guardaespaldas de la corte? ¡En realidad solo prueba la comida!",
    }
    STRINGS.YURUN_BACKSELF = {
        "A Corvus le gusta su nombre, ¡pero el cerdo tonto siempre se equivoca!",
        "Corvus aprendió algunas palabras en otros idiomas…",
        "Corvus está aprendiendo idiomas: Miau, miau miau miau…",
        "Magia occidental, hechicería oriental, Corvus sabe un poco de cada una.",
        "Corvus quiere probar un té de burbujas Shan Hai Xian Cao.",
        "Corvus quiere una pluma de colores…",
        "Corvus también quiere probar la carpa koi gigante debajo de la torre…",
        "Corvus tiene un plan de decoración, necesita ayuda para mover piedras grandes.",
        "Corvus lo extraña mucho...",
        "La luna cayó y rompió la torre.",
        "Corvus usó magia para tapar el agujero de la torre.",
        "Corvus quiere comer piedras brillantes.",
        "El aire aquí está muy seco.",
        "¿Por qué el mundo es tan grande y Corvus tan pequeño?",
        "Corvus aún no puede salir de esta torre.",
        "Corvus extraña su pequeño nido.",
        "Los lugares oscuros dan miedo a Corvus.",
        "Este árbol es raro, Corvus sospecha que se va a volver espíritu.",
        "A Corvus le gusta más su pequeño nido.",
        "Corvus quiere un plumaje más brillante.",
        "Antes, Corvus y el cerdo tonto podían entrar y salir de la torre libremente.",
        "¡Achís! ¡El cerdo tonto está maldiciendo a Corvus!",
    }
    STRINGS.YURUN_NIGHT = {
        "Buenas noches",
        "Corvus regresa al nido~",
        "Muerto de sueño",
        "Pequeña cama, aquí viene Corvus",
        "Corvus quiere descansar un rato",
        "El viento es muy agradable",
        "Hoy el viento es muy suave",
    }
    STRINGS.YURUN_SCARED = {
        "¡Ataque enemigo, escóndete!",
        "¡No te muevas!",
        "Las plumas de Corvus se erizaron",
        "¡No lo asustes!",
        "¡Chas!",
        "Escóndete rápido",
        "¡Llegó el enemigo!",
        "Espero que no sea un monstruo",
        "¡Retirada rápida!",
        "¡Corre!",
        "¡Las patas de Corvus se debilitaron!",
        "¡Esto no está bien!",
    }
    STRINGS.YURUN_HASGIFT = {
        "Gracias, pero primero deja que Corvus termine su bocadillo.",
        "Espera un momento, Corvus",
        "Corvus no puede sostener más",
        "¿Quieres que Corvus se convierta en un cuervo gordo?",
        "Gracias, pero Corvus necesita hacer dieta.",
    }
    -- STRINGS.YURUN_KEEPGIFT = {
    --  "¡Corvus recibió otro regalo!",
    --     "Corvus está muy conmovido",
    --     "Eres muy amable",
    --     "A Corvus le gusta esto",
    --     "Es muy considerado",
    --     "¿Realmente es para Corvus?",
    --     "Corvus lo cuidará mucho",
    -- }
    STRINGS.YURUN_REFUSEGIFT = {
        "Si insistes, Corvus podría tirarlo.",
        "Guárdalo para el cerdo tonto.",
        "Corvus pensó que me entendías bien.",
        "A Corvus no le gusta.",
        "Corvus no necesita esto mucho.",
        "¡Dáselo al pájaro de la jaula!",
        "Esto… a Corvus no le gusta.",
        "Esto no le queda bien a Corvus.",
        "Mejor quédate con esto tú mismo.",
        "Esta cosa es muy pesada.",
        "¿Solo me das esto a Corvus?",
    }
    STRINGS.YURUN_COOKPOT = {
        "¿Esta comida es para Corvus?",
        "¿Qué se cocina en la olla?",
        "Corvus huele algo rico.",
        "Corvus quiere probar un bocado, solo un pequeño bocado.",
        "A Corvus casi se le cae la saliva.",
        "Espero que no sea sopa de fideos con sangre de cuervo.",
        "¡Huele a lo que más le gusta a Corvus!",
        "¿Puede comer Corvus?",
        "Corvus justo tiene hambre.",
        "¿Le pusiste frutas que le gustan a Corvus?",
        "Creo que Corvus ha olido este sabor antes.",
        "Corvus se está poniendo un poco ansioso.",
        "¿Esto está hecho especialmente para Corvus?",
        "¿Puedes dejar que el cuervo pruebe un poco?",
        "Los cuervos están listos para disfrutar de su deliciosa comida.",
    }
    STRINGS.YURUN_KNOCKPIG = {
        "¡Cerdo tonto, sal!",
        "¡Perezoso, levántate!",
        "¡Cerdo tonto, Corvus preparó panceta fresca!",
        "¡Si no sales, Corvus va a prender fuego!",
        "¡Sal, la torre se está incendiando!",
        "Esos pequeños monstruos sin plumas quieren verte, cerdo.",
        "Cerdo tonto, ¿sigues vivo?",
        "¡Si no sales, Corvus te arrancará los pelos!",
        "¡Afuera dicen que alguien es más perezoso que un cerdo!",
        "¡Abre la puerta, Corvus encontró un pato que baila!",
        "¡Cerdo tonto, al árbol le salieron piedras, sal a ver!",
    }
    STRINGS.YURUN_HAPPYDANCE = {
        "Corvus necesita practicar magia con esfuerzo.",
        "Espero que le guste~",
        "Espero poder satisfacerle~",
        "Este es el máximo grado de Corvus.",
        "Nueva magia que aprendió Corvus.",
        "¡Reúne energía, fuego!",
        "¡Corvus debe acumular energía espiritual!",
        "¡Como muestra de respeto!",
        "¡Arde!",
    }
    STRINGS.YURUN_ADDFUEL = {
        "La fogata no es lo suficientemente fuerte.",
        "Corvus encontró un buen trozo de madera.",
        "La fogata no debe apagarse.",
        "Corvus es un genio de los braseros.",
        "La fogata necesita leña.",
        "El fuego aún no es lo suficientemente brillante.",
        "La fogata recuperó el ánimo de inmediato.",
        "Corvus es un experto en combustible.",
        "Agregar un poco de leña.",
        "Corvus viene a salvarla.",
        "¿Corvus es especialmente hábil, no?",
        "No te preocupes.",
        "La fogata es el mejor amigo por la noche.",
        "Corvus siente que ayudó mucho.",
    }
    STRINGS.YURUN_CHERRYGIFT = {
        "¡Cerezas! ¡Grandes cerezas!",
        "Corvus no ha comido esto, Corvus está muy agradecido contigo.",
        "¿Has visto el bosque de cerezos? ¡Corvus, eres increíble!",
    }
    STRINGS.YURUN_MAGICGIFT = {
        "¡Magia occidental, hechicería oriental, Corvus sabe un poco de cada una!",
        "Si no tienes alas, Corvus, ¡entonces usa esta magia como sustituto!",
        "Esta es la magia que Corvus aprendió a escondidas de un mago.",
    }
    STRINGS.YURUN_GIVEGIFT = {
        "Este es el tesoro de Corvus.",
        "Cuídalo bien, ¿eh?",
        "Este es el regalo que Corvus eligió cuidadosamente.",
        "Esto es lo que Corvus te regala.",
        "Corvus supo de inmediato que debería ser tuyo.",
        "Esto es lo que Corvus 'tomó prestado' de otro lugar.",
        "¿Corvus es generoso, no?",
        "En el futuro, sé bueno con Corvus también.",
        "Corvus piensa que este objeto es muy mágico, te lo regalo.",
        "¡No dudes en usarlo!",
        "Necesitarás esto.",
        "Esto no es un producto ordinario.",
        "Un pequeño detalle de Corvus.",
        "Algo que Corvus 'consiguió' con inteligencia y sabiduría.",
        "No preguntes cómo lo conseguí.",
        "Esto es lo que Corvus preparó especialmente para ti.",
        "Esta cosa vale muchas cosas brillantes.",
        "¡Corvus recibió un regalo!",
        "Corvus está muy conmovido.",
        "Eres muy amable.",
        "A Corvus le gusta esto.",
        "Es muy considerado.",
        "¿Realmente es para Corvus?",
        "Corvus lo cuidará mucho.",
    }
    STRINGS.YURUN_GETFEATHER = {
        "¡Encontraste al gran Fénix!",
        "¡Plumas de colores!",
        "¡Eres buen amigo de Corvus!",
        "¡Corvus ha estado buscando esto!",
    }
    STRINGS.YURUN_FIGHTPIG = {
        "¡Corvus va a darte en el trasero de cerdo!",
        "¡Cuervo montando en avión!",
        "Trasero de cerdo redondo, perfecto para que Corvus entrene sus garras.",
        "¿Ataque porcino violento? Corvus ve que es un pastel de arroz rodante.",
        "Corvus te clavará una pluma de pájaro, ¡y luego te pateará como volante!",
        "Si pierdes, ¡no llores!",
        "¡Cerdo tonto que no puede volar!",
        "¡En el mundo de las artes marciales, solo la velocidad es invencible!",
        "¡La paciencia de Corvus y tu cinturón están igual de flojos!",
    }

-- 强制离开二岛的台词
STRINGS.DSC_FORCEMOVE = {
    "¡No debería haber entrado sin permiso a esta área!",
    "¿¡Qué es esto?!",
    "No tengo derecho a pisar aquí.",
    "¡Esta isla me está rechazando!",
}

-- 芝上谈冰缺少材料
STRINGS.SH_NO_INGREDIENT = {
    "¡Una mujer hábil no puede cocinar sin arroz!",
    "No hay ingredientes.",
    "Lo tengo en mente, pero no hay suficientes materiales.",
    "¿Intentando conseguir algo a cambio de nada?",
    "¡Primero debo recolectar estos materiales!",
}

-- 野生猪人的线索文本
STRINGS.REFUSE_READ = {
    "Sin carne, ¿por qué ayudarte?",
    "¿Buscar ayuda de un cerdo con las manos vacías?",
    "No eres amigo, no te ayudaré a leer.",
    "A menos que puedas dar una tarifa de consulta.",
    "La última vez dijiste que me invitarías a comer.",
    "¿Quieres algo gratis? ¿Ni siquiera traes leña para pedir arroz prestado?",
    "¡Los cerdos no son mano de obra gratuita!",
    "¡Carne! ¡Carne! ¡Primero dame carne!",
}
STRINGS.REDPAPER_CLUE_PRE = {
    "Dice:",
    "Déjame ver:",
    "Veo borroso:",
}
STRINGS.THE_ONLY_PASSWD = "Respuesta de descifrado de la Torre de la Caverna Celestial, "
STRINGS.THE_FAIL_PASSWD = "Contraseña perdida"
STRINGS.REDPAPER_CLUE_CORRECT = {
    -- "El secreto del Río Suspendido estará fuera del mundo...",
    -- "El jade espiritual del Río Suspendido es el pase al secreto del Río Suspendido.",
    "El fuego fatuo y las flores fragantes pueden contener: pétalos, frutos luminiscentes...",
    "La antigua energía espiritual del cielo y la tierra: marca de Gou Mang.",
    "Árbol dorado lleno como mariposas revoloteando: hojas de ginkgo.",
    "No se ven las huellas de viento y escarcha talladas en los huesos: gemas.",
    "¿Elixir de la inmortalidad vacío? ¡Deberías recolectarlo!",
    "¡Dale una calabaza a Yu Run en la noche de luna llena, te enseñará magia~",
}
STRINGS.REDPAPER_CLUE = {
    "¡Debes ayudar a Wei Diao!",
    "En el fondo del valle del amor, estoy en la desesperación.",
    "Hay un infiltrado, cancela la transacción.",
    "Quiero robarte el corazón, Bai Yu Tang se inclina respetuosamente.",
    "...¿Está bien la Concubina Xi?",
    "Todo trabajo y nada de diversión hace de Jack un chico aburrido.",
    "¡Realmente extrañamos Gravity Fall!",
    "Dile a Monica que lo siento.",
}

-- 烛龙的文本
STRINGS.ZHULONG = {
    GIFT = {
        "Como desees...",
        "Felicidades..",
        "Digno de celebrar...",
    },
    FIGHT = {
        "¿Te atreves a desafiarme?",
        "Aún no es el momento, niño...",
        "Vuelve cuando comprendas el poder del tiempo y el espacio...",
    },
    SUPERIOUS = {
        "Neblina que oculta la montaña~",
        "Olas que asombran los cuatro mares~",
    },
    WRONG = {
        "Usa tu pequeña cabeza, niño.",
        "Prueba suerte con la tribu de cerdos.",
        "Deberías prestar atención a esas golondrinas de papel...",
        "Esas golondrinas de papel esconden pistas.",
        "¿Realmente planeas adivinar a ciegas?",
        "Yo tampoco entiendo la escritura de los cerdos.",
    },
    EATTACO = {
        "¡Delicioso!",
        "¿Oh? ¿Una ofrenda para mí?",
        "Joven, he recibido tus buenas intenciones.",
    },
    TIMETACO = {
        "¡Ladrón del tiempo!",
        "¡Ladrón de la luz!",
        "¡Mi poder espacio-temporal!",
    },
}

-- 长老的文本
STRINGS.DC_ELDER = {
    START = {
        "Llegaste.",
        "¿Quieres jugar un rato?",
        "El ajedrez primero, la amistad después.",
    },
    ANOTHER = {
        "¿Oh? ¿Tú también quieres intentarlo?",
        "No hay problema, este juego es más divertido con dos personas.",
    "Ve, desafiante.",
    },
    INGAME = {
        "Bueno, actuaré personalmente.",
        "Dejaré ver mis habilidades.",
    "Te daré una lección.",
    },
    NEXTMOVE = {
        "Eh...",
        "Sí, sí, ¡oh no, no! ¿Correcto?",
        "¿Con 5 piezas aún puedes vencerme al instante?",
        "No hagas trampa.",
        "Poner aquí es más apropiado.",
        "...",
        "El espectador ve claro, el jugador está confundido."
    },
    REWARD = {
        "¡Esta es tu recompensa!",
        "Debe haber un pequeño premio.",
    },
    EQUALWIN = "¡Empate!",
}

STRINGS.TICTACTOE = {
    ALREADYIN = {
        "Ya estoy en el juego.",
        "No puedo darlo dos veces.",
    },
    GAMEIN = {
        "Ahora debo ser espectador...",
        "Juego en progreso.",
    },
    STARTGAME = {
        "¡Ganaré!",
        "¡Soy un experto en tres en raya!",
    },
    ANNOUNCE_PRE = "¡Comienza el juego! Jugador(",
    ANNOUNCE_PST = ") mueve primero.",
    NOTGAMETINE = {
        "El juego no ha comenzado.",
        "¡Aún no es el momento!",
    },
    OUTGAME = {
        "No soy participante de esta partida.",
        "Un verdadero caballero observa sin hablar.",
    },
    WRONGPIECE = "Usé la pieza equivocada.",
    WRONGTURN = "No es mi turno ahora.",
    WRONGPLACE = "Posición inválida.",
    ALREADPLACED = "Ya hay una pieza en esta posición.",
    GAMEGOON_PRE = "Turno del jugador(",
    GAMEGOON_PST = ") para actuar.",
    WIN_PRE = "¡Jugador(",
    WIN_PST= ") gana!",
    ANOTHERROUND= "Bueno, ¡una vez más!",
    TIMEOUT = "Esperaste demasiado, ya debería terminar...",
}

---------------------------------------------------------------
-------------------------加载界面的文本台词----------------------
---------------------------------------------------------------
STRINGS.UI.LOADING_SCREEN_MONTFLUV_TIPS = {}
---------------------------------------------------------------
-------------------------天狗食月的事件台词----------------------
---------------------------------------------------------------
STRINGS.START_EAT_MOON = "Se escuchan ladridos desde el cielo…"
STRINGS.SUCCESS_EAT_MOON = "El brillo lunar se desvanece…"
STRINGS.BREAK_EAT_MOON = "Cuidado, se está cayendo…"


---------------------------------------------------------------
------------------------    宣告文本    ------------------------
---------------------------------------------------------------
-- 山海烧仙草
________COOKBOOK.FOOD_EFFECTS_SHANHAI_BUBBLETEA = "¡El gusto del pequeño Yu Run es muy bueno!"
________ANNOUNCE.FOOD_EFFECTS_SHANHAI_BUBBLETEA = {
    "Refrescante y agradable.",
    "Me siento mucho más tranquilo.",
    "¡El gusto del pequeño Yu Run es muy bueno!",
    "¡El pequeño Yu Run tiene sus razones para gustarle!",
}
-- 芝上谈冰
________COOKBOOK.FOOD_EFFECTS_SH_GANOERMAICE = "Lo que se aprende en el papel es superficial, saberlo bien requiere practicarlo personalmente."
________ANNOUNCE.FOOD_EFFECTS_SH_GANOERMAICE = {
    "Lo que se aprende en el papel es superficial, saberlo bien requiere practicarlo personalmente.",
    "Ayuda, pero debería hacerlo yo mismo.",
    "Esto resuelve una necesidad urgente.",
    "¡Ahora tengo una explosión de inspiración!",
}
-- 长生不老药
________COOKBOOK.FOOD_EFFECTS_SH_NEVEROLD = "Mis órganos parecen no haber recibido la noticia de la inmortalidad.."
________ANNOUNCE.FOOD_EFFECTS_SH_NEVEROLD = {
    "Quizás no envejezca, pero aún puedo quedarme calvo.",
    "Mis órganos parecen no haber recibido la noticia de la inmortalidad..",
    "Ya que soy inmortal, trabajaré horas extras hasta la explosión del universo.",
    "¡Este sabor es como leche caducada!",
}
-- 山河卷饼
________COOKBOOK.FOOD_EFFECTS_SH_TACO = "¡La tortilla debe ser delgada, el relleno abundante!"
________ANNOUNCE.FOOD_EFFECTS_SH_TACO = {
    "Contento, pero no llena mucho.",
    "A Zhu Long le gusta esto..",
    "Representante de la cultura alimentaria mexicana.",
    "Necesito otro.",
}
-- 不允许卷饼的食物
________ANNOUNCE.ACTIONFAIL.SHROLLFOOD = {
    BANFOOD = "Wei Diao dice que es demasiado excesivo, no puede ser.",
}
-- 沾光失败
________ANNOUNCE.ACTIONFAIL.MIGU_ZHANGUANG = {
    TOOLOW = "Aún no es tan bueno como el mío.",
}
-- 沾光成功
________ANNOUNCE.ANNOUNCE_ZHANGUANGE = {
    "Me aproveché mucho.",
    "Entre amigos debemos ayudarnos mutuamente.",
    "Aventurero help aventurero.",
}
-- 召回钦原
________ANNOUNCE.ACTIONFAIL.BEEBACK = {
    BACKFAIL = "Alguien se adelantó.",
}
-- 给予鲲鹏物品
________ANNOUNCE.ANNOUNCE_KUNPENG_TRIBUTE ={
    "¡Te traje algo!",
    "¡Esto es para ti!",
    "Guau... te ves, ejem, ¡grande!",
}
-- Forzar a la golondrina de papel a hablar
________ANNOUNCE.ACTIONFAIL.FORCEWRITE = {
    CANNOTWRITE = "No sabe nada.",
}
-- Dar fertilizante común a Gou Mang
________ANNOUNCE.ACTIONFAIL.FERTILIZE = {
    NOTXIRANG = "Creo que estos no son los nutrientes que quiere.",
}
-- Fracaso al injertar enredadera
________ANNOUNCE.ACTIONFAIL.LODGEOCEANTREE = {
    WRONGSEED = "Esta cosa no puede ponerse allí.",
    NOOCEANTREE = "No hay planta adentro para adherirse.",
}
-- Fracaso al liberar cangrejo brillante
________ANNOUNCE.ACTIONFAIL.RELEASECRAB = {
    NOOCEANTREE = "No hay adherido en el agua, se ahogarían.",
    ISINFECTED = "Ya hay cangrejos brillantes viviendo aquí.",
}
-- Mal momento para gastarle una broma a Yu Run
________ANNOUNCE.ACTIONFAIL.MIGU_DEST = {
    NOTGOODTIME = "Oye, está ocupado.",
}
-- Gastarle una broma a Yu Run
________ANNOUNCE.I_AM_BAD = {
    "Ay, qué malos somos.",
    "Ay, esto fue a propósito, sin querer.",
}
-- Injertar enredadera
________ANNOUNCE.ANNOUNCE_LODGE_OCEANTREE = {
    "La pequeña enredadera quiere alojarse un rato.",
    "¡Crece rápido~!",
}
-- Liberar cangrejo brillante
________ANNOUNCE.ANNOUNCE_RELEASE_CRAB = {
    "De ahora en adelante, este será su hogar.",
    "Yu Run tiene nuevos amiguitos.",
}
-- Fertilizar ciencia de Zi Gui
________ANNOUNCE.FERTSIVING = {
    "Zi Gui consumirá mucha de su fertilidad.",
    "Ahora necesita recuperarse un rato.",
}
-- Recolectar árbol Migutree
________ANNOUNCE.PICK_UP_MIGU = {
    "Ahora no me perderé.",
    "Iluminará mi camino.",
    "Tengo el presentimiento de que esto será útil.",
}
-- Dar plumas extra a Cien Pájaros Adorando al Fénix
________ANNOUNCE.ALREAY_GOT = {
    "Dar más no sirve.",
    "Esto no es un plumero.",
}
-- Capturar a Qin Yuan
________ANNOUNCE.ANNOUNCE_NET_QINYUAN = {
    "¡No dejes que escape!",
    "Su aguijón de cola es demasiado afilado.",
}
-- Dar cosas extrañas al pájaro de papel en la jaula
________ANNOUNCE.ANNOUNCE_GIVE_PAPERBIRD = {
    "¿La golondrina de papel come esto?",
    "Mejor dale un bolígrafo.",
    "Después de todo, no es un pájaro real.",
    "¿Qué quieres exactamente, habla en chino!",
}
-- Muerte de Qin Yuan
________ANNOUNCE.ANNOUNCE_QINYUAN_DEATH = {
    "¡Yo te maté!",
    "¡No!",
    "¡La pequeña abeja murió súbitamente!",
}
-- Recuperar a Qin Yuan
________ANNOUNCE.ANNOUNCE_QINYUAN_RETRIEVE = {
    "¡Vuelve~!",
    "También deberías descansar un rato.",
    "¡Oye! ¡No me apuntes con tu aguijón!",
}
-- Provocar a Qin Yuan
________ANNOUNCE.ANNOUNCE_QINYUAN_AGGRESSIVE = {
    "Sumérgete en la locura de las abejas~",
    "¡Adelante!",
    "¡Pincha! ¡Pincha con fuerza!",
}
-- Calmar a Qin Yuan
________ANNOUNCE.ANNOUNCE_QINYUAN_DEFENSIVE = {
    "No te emociones~",
    "Lo siento, vuelve rápido.",
    "Deberías controlar tu temperamento.",
}
-- Salvar a Kunpeng
________ANNOUNCE.ANNOUNCE_KUNRIDER_GOODBYE = {
    "¡Adiós, grandullón!",
    "La próxima vez ten cuidado~",
}
-- Fracaso al sellar demonio
________ANNOUNCE.ACTIONFAIL.DSCCAVESEAL = {
    NOSPAWNER = "Esto está demasiado lejos de su guarida.",
    SOMETHINGWRONG = "¿El hechizo falló?",
    CANTSEAL = "¡Ahora no es su momento más débil!",
}

-------------------------封印洞天的事件台词-----------------------
STRINGS.SHANHAI_SEAL = {
    SUCCESS = "Sellado exitoso.",
    FAIL = "No coincide, el sellado falló.",
    WIRED = "Su origen tiene problemas, no tiene poder de sellado.",
}
-------------------------Diálogos del evento de recolectar Gou Mang-----------------------
STRINGS.GOUMANG_LINES = {
    "¿Algo se cayó?",
    "¡Objeto condensado de la energía del cielo y la tierra!",
"Misterio del cielo y la tierra, no debe subestimarse.",
}
-------------------------Comprobación de objetos atraídos por Guía Estelar----------------------
STRINGS.WXTY_LINES = {
    "¡Esto es imposible!",
    "¿A dónde vas?",
    "¡Atrápalo rápido!",
    "¡Veo mis cosas volando en el cielo!",
    "¡Alerta máxima, sospecha de aparición de tornado leopardo!"
}
-------------------------Texto de apertura del secreto del Río Suspendido------------------------
STRINGS.XUANHE_GEN = {
    "El camino del cielo es oscuro y oculto, el mundo mundano está confundido.",
    "La era del caos reaparece, todas las cosas regresan al silencio.",
    "El firmamento sin sonido, el Río Suspendido susurra.",
    "El pájaro divino vuela alto, los cuatro mares con olas asombrosas.",
}
-------------------------Texto celestial de muerte de Zhu Yan------------------------
STRINGS.ZHUYAN_DEAD = {
    "¡Maldición!",
    "¡No te alegres!",
    "¿Crees que puedes matarme?",
    "No puedes matarme.",
    "Solo es la caída de una encarnación.",
    "¡Nos volveremos a ver!",
    "¡Regresaré!",
}
STRINGS.ZHUYAN_MUSIC = {
    "¡Música demoníaca!",
    "¡Hechizo!",
    "¡Pérdida de cordura!",
    "¡Desorientación!",
}
STRINGS.ZHUYAN_SUMMON = {
    "¡Guerra!",
    "¡Gran caos en el mundo!",
    "¡Desorden bélico!",
    "¡Conflicto interno!",
}
-------------------------Texto de anuncio de Zhu Long------------------------
STRINGS.ZHULONG_TEXT = {
    "¡Día y noche definidos!",
    "Día eterno, mirada penetrante como antorcha!",
    "Crepúsculo eterno, somnolencia y sueño!",
    "Noche eterna, cerrando los ojos, sueño largo...",
    "¿Extender el día? Me mantendré alerta.",
    "¿Extender el crepúsculo? Como desees.",
    "¿Extender la noche? Si te gusta, está bien.",
    "¡Devorar el día!",
    "¡Devorar el crepúsculo!",
    "¡Devorar la noche!",
}

---------------------------------------------------------------
------------------------不同物品的检查文本------------------------
---------------------------------------------------------------
-- 特殊物品【弃用】
________DESCRIBE.KUNPENG = "Super súper hegemonía submarina del norte oscuro"
________DESCRIBE.KUNPENG_ATTACK_HORN = "¿Es una broma?"
________DESCRIBE.KUNPENG_HORN = "Como una pequeña montaña"

-- Altar de sacrificio
________DESCRIBE.DEEPSEACAVE_UPGRADER = {
    IS_COOLDOWN = "¿Aún no?",
    IS_HOLDING = "¿Será esta la elección correcta?",
    GENERIC = "Los objetos colocados encima a menudo se pierden",
}
-- Salida
________DESCRIBE.DEEPSEACAVE_EXIT = {
    NO_ACCESS = "¿Quién cerró la puerta?",
    GENERIC = "Necesitamos hacer un ascensor",
}
-- Árbol gigante torcido
________DESCRIBE.DSC_OCEANTREE_PILLAR = {
    SINGLE_PAINTED = "¿Quién pintó eso?",
    DOUBLE_PAINTED = "Quiero pintarme yo también",
    LIGHT_SHOW = "Increíble",
    GENERIC = "La tenacidad de la vida lo impulsó a encontrar una salida",
}
-- Ganoderma
________DESCRIBE.SHANHAI_GANODERMA = {
    PICKED = "Ahora a ver cómo se las arreglan los pequeños hongos",
    GENERIC = "Pequeño demonio que crece en el suelo",
    INGROUND = "¿Qué es eso, una piruleta?",
}
-- Árbol de ginkgo
________DESCRIBE.SHANHAI_GINKGO_TREE = {
    BURNT = "Lo siento",
    SHORT_STUMP = "Deberíamos sentirnos culpables",
    SHORT = "No tiene muchas hojas",
    NORMAL_STUMP = "Lo siento mucho",
    NORMAL = "¿Las plantas también tienen etapas incómodas?",
    TALL_STUMP = "No deberíamos haber hecho esto",
    TALL_YELLOW = "Como si estuviera cubierto de mariposas doradas",
    GENERIC = "Prefiero cómo se ve cuando es dorado",
}
-- Torre de la Caverna Celestial
________DESCRIBE.DEEPSEACAVE = {
    IDLE = "Dentro hay un pequeño mundo mágico",
    IDLE_DEPLOY = "¡Por fuera parece pequeña, pero por dentro es sorprendentemente grande!",
    ACTIVATE = "Guau… ¡guau!",
    GENERIC = "¡Empaquetar! ¡Llevar!",
}
-- Zhu Yuan
________DESCRIBE.DEEPSEACAVE_PIGHOUSE = {
    CAN_KNOCK = "¡Abrir la puerta!",
    PIG_OUT = "El cerdo salió, ¿puedo mudarme adentro?",
    GENERIC = "Me encantaría mudarme adentro",
}
-- Yu Run
________DESCRIBE.DEEPSEACAVE_CROW = {
    SIT_LOOP = "Es muy obediente",
    HOLD = "Ej, qué fuerza tan grande",
    SHOW = "Quiero darle un abrazo",
    TOP = "Hoy todos somos Super Mario",
    GENERIC = "Es muy diferente a los otros cuervos pequeños",
}
-- Estanque sombrío
________DESCRIBE.DEEPSEACAVE_POOL = {
    GENERIC = "Qué agua tan clara y fría del estanque",
}
-- Sello de la Torre de la Caverna Celestial
________DESCRIBE.DEEPSEACAVE_SEAL = {
    GENERIC = "¿Con solo dibujar unos símbolos en el papel basta?",
}
-- Muro de la Torre de la Caverna Celestial
________DESCRIBE.DEEPSEACAVE_WALL = {
    GENERIC = "Puede protegerme de caer al vacío",
}
-- Silla de montar de nube
________DESCRIBE.SADDLE_KUN = {
    GENERIC = "¿Esto es una nube de verdad?",
}
-- Té de burbujas Shan Hai Xian Cao
________DESCRIBE.SHANHAI_BUBBLETEA = {
    GENERIC = "¿El vaso también se hizo en la olla?",
}
-- Cofre de conchas
________DESCRIBE.SHANHAI_SHELLCHEST = {
    GENERIC = "¿Resulta que esto se puede abrir?…",
}
-- Cofre de piedra (oculto)
________DESCRIBE.SHANHAI_HIDDENCELLAR = {
    GENERIC = "Material de piedra, sellado con cadenas",
}
-- Cofre de piedra
________DESCRIBE.SHANHAI_HIDDENCELLAR_USE = {
    GENERIC = "Material de piedra, sellado con cadenas",
}
-- Guirnalda floral
________DESCRIBE.SHANHAI_FLOWERVINE = {
    GENERIC = "Flores hermosas, luna llena, personas duraderas",
}
-- Mariposa (azul)
________DESCRIBE.SHANHAI_BLUEFLY = {
    GENERIC = "Puede curar mis heridas",
}
-- Mariposa (verde)
________DESCRIBE.SHANHAI_GREENFLY = {
GENERIC = "Hojas volando",
}
-- Mariposa (naranja)
________DESCRIBE.SHANHAI_ORANGEFLY = {
GENERIC = "La pequeña mariposa se camufló como una hoja",
}
-- Mariposa (blanca)
________DESCRIBE.SHANHAI_WHITEFLY = {
GENERIC = "¿Es esa una polilla lunar?",
}
-- Hoja de Gou Mang
________DESCRIBE.SHANHAI_GOUMANG_ITEM = {
GENERIC = "Desprende una fragancia fresca",
}
-- Planta de Gou Mang
________DESCRIBE.SHANHAI_GOUMANG_PLANT = {
IDLE = "Planta antigua y misteriosa",
NORMAL = "No pasa nada, puedo esperar",
DEAD = "El suelo del Continente Eterno no es adecuado para su crecimiento",
GENERIC = "¿Qué pasa?",
}
-- Marca de Gou Mang
________DESCRIBE.SHANHAI_GOUMANG = {
GENERIC = "Energía antigua, vagamente presente",
}
-- Salida oculta
________DESCRIBE.SHANHAI_HIDDENEXIT = {
GENERIC = "¿Qué tal si le damos un par de patadas para probar?",
}
-- Guía estelar
________DESCRIBE.SHANHAI_STARFLY = {
GENERIC = "Si pudiera usarse para pescar sería genial",
}
-- Caída lunar
________DESCRIBE.SHANHAI_MOONFALL = {
GENERIC = "¡Del cielo van a caer oro!",
}
-- Cornamenta de ciervo
________DESCRIBE.SHANHAI_MUSHROOMGUARD = {
GENERIC = "¿En primavera crecerá un ciervo sin ojos?",
}
-- Ganoderma recolectado
________DESCRIBE.GANODERMA_CAP = {
GENERIC = "Se ve mejor creciendo en el suelo",
}
-- Ganoderma asado
________DESCRIBE.GANODERMA_CAP_COOKED = {
GENERIC = "Qué aroma, quiero tragarlo de un bocado",
}
-- Semilla parásita de geoda
________DESCRIBE.SHANHAI_PARASITICSEED_GEM = {
GENERIC = "Hay que encontrarle un huésped adecuado",
}
-- Semilla parásita de visión nocturna
________DESCRIBE.SHANHAI_PARASITICSEED_NIGHT = {
GENERIC = "Hay que encontrarle un huésped adecuado",
}
-- Retoño hinchado
________DESCRIBE.SHANHAI_PINECONE = {
GENERIC = "Está ansioso por crecer",
}
-- Retoño de pino siempreverde hinchado
________DESCRIBE.SHANHAI_PINECONE_SAPLING = {
GENERIC = "¡Ánimo, pequeña vida!",
}
-- Fruto de ginkgo
________DESCRIBE.SHANHAI_GINKGO = {
GENERIC = "Tiene un olor extraño",
}
-- Retoño de ginkgo
________DESCRIBE.SHANHAI_GINKGO_SAPLING = {
GENERIC = "Eres tan pequeño, ¿te pisaré sin querer?",
}
-- Cuerda roja
________DESCRIBE.SHANHAI_REDROPE = {
GENERIC = "Mis dedos aún pueden sentir dolor",
}
-- Gong
________DESCRIBE.SHANHAI_GONG = {
GENERIC = "Gong",
}
-- Shang
________DESCRIBE.SHANHAI_SHANG = {
GENERIC = "Shang",
}
-- Jue
________DESCRIBE.SHANHAI_JUE = {
GENERIC = "Jue",
}
-- Zhi
________DESCRIBE.SHANHAI_ZHI = {
GENERIC = "Zhi",
}
-- Yu
________DESCRIBE.SHANHAI_YU = {
GENERIC = "Yu",
}
-- Enviar nota musical
________DESCRIBE.SHANHAI_FINISHORDER = {
GENERIC = "Terminar",
}
-- Formación mágica de Zhu Long
________DESCRIBE.SHANHAI_SECRETPLACE = {
GENERIC = "Muy duro, más exagerado que la piedra de la desesperación",
}
-- Espíritu del ginseng de montaña
________DESCRIBE.SHANHAI_SHANSHEN_ACTIVE = {
GENERIC = "No pensé que fuera tan resistente a los golpes",
}
-- Ginseng de montaña
________DESCRIBE.SHANHAI_SHANSHEN_PLANTED = {
GENERIC = "Fruta deliciosa",
}
-- Ginseng de montaña
________DESCRIBE.SHANHAI_SHANSHEN = {
GENERIC = "Ya tiene forma humana",
}
-- Esencia de ginseng de montaña
________DESCRIBE.SHANHAI_COOKEDSHANSHEN = {
GENERIC = "Después de asarlo solo queda esto",
}
-- Pequeña estatua
________DESCRIBE.SHANHAI_SMALLSTATUE = {
GENERIC = "Deberíamos rediseñarle una forma",
}
-- Enredadera de geoda
________DESCRIBE.SHANHAIVINE_GEM = {
GENERIC = "Cuidado, nos hará estallar la cabeza",
}
-- Enredadera de baya nocturna
________DESCRIBE.SHANHAIVINE_NIGHT = {
GENERIC = "Sinceramente, no tengo mucho apetito",
}
-- Enredadera floral lunar
________DESCRIBE.SHANHAIVINE_MOON = {
GENERIC = "Ojalá hubiera más colores de flores",
}
-- Árbol siempreverde festivo
________DESCRIBE.SHANHAI_WINTER_TREE = {
BURNT = "Uy",
BURNING = "Algo grave anda mal",
CANDECORATE = "Necesitamos bombillas y serpentinas",
YOUNG = "Se acerca la festividad",
}
-- Xirang
________DESCRIBE.SHANHAI_XIRANG_ITEM = {
GENERIC = "El pequeño montículo de tierra crece solo",
ONCOOLDOWN = "Necesita tiempo para reunir energía espiritual de nuevo",
}
-- Tierra misteriosa
________DESCRIBE.SHANHAI_XIRANG = {
GENERIC = "¿Hay algún tesoro adentro?",
}
-- Xirang
________DESCRIBE.SH_XIRANG = {
GENERIC = "Pequeño montículo de tierra lleno de energía espiritual",
}
-- Tierra misteriosa
________DESCRIBE.SH_XIRANG_PLANT = {
XIRANG_FULL = "¿Hay algún tesoro adentro?",
GENERIC = "Necesita tiempo para volver a crecer",
}
-- Zhu Yan
________DESCRIBE.SHANHAI_ZHUYAN = {
GUARD = "Puños más grandes que un saco de arena",
NORMAL = "Sin vigilancia, ¡buena oportunidad!",
}
-- Cien Pájaros Adorando al Fénix
________DESCRIBE.STATUE_CHAOFENG = {
GENERIC = "Al pequeño cuervo le gustará esto",
ALL_FOUND = "Sagrado, majestuoso",
}
-- Perro Celestial Comiendo la Luna
________DESCRIBE.STATUE_EATMOON = {
EYESCLOSE = "Gran perro guapo",
EYESOPEN = "Ahora me preocupa un poco, ¿no me morderá?",
MOONEATEN = "Corrió al cielo y le dio un pequeño mordisco a la luna",
NODOG = "En un abrir y cerrar de ojos, desapareció, ¿a dónde fue?",
}
-- Renacimiento en el Fuego
________DESCRIBE.STATUE_NIEPAN = {
IS_COOLDOWN = "No está tan ardiente, hay que esperar un rato",
IS_HOLDING = "Tengo el impulso de prenderle fuego",
IS_NOT_HOLDING = "¿Hoy vamos a comer a la plancha?",
}
-- Budín de huevo de tortuga
________DESCRIBE.TORTOISE_CUSTARD = {
GENERIC = "¿Este cuenco es un caparazón de tortuga?",
}
-- Estanque del Río Suspendido
________DESCRIBE.XUANHE_POND = {
STAGE_1 = "Necesita: el fuego fatuo y las flores fragantes pueden contener",
STAGE_2 = "Necesita: la energía espiritual del cielo y la tierra se condensa en esencia",
STAGE_3 = "Necesita: ¿árbol dorado lleno como mariposas revoloteando?",
STAGE_4 = "Necesita: ¿no se ven las huellas de viento y escarcha talladas en los huesos?",
STAGE_5 = "Me alegra poder ayudar",
}
-- Estatua del plano de unión
________DESCRIBE.SH_CHERRYSTATUE = {
GENERIC = "¿Están mirando el plano o el código?",
}
-- Acuario de los Cuatro Símbolos
________DESCRIBE.SH_SEASONAQUARIUM = {
SPRING = "Primavera, montaña perdida, gansos llorando en vano",
SUMMER = "Verano, ventana baja refleja dragones con escamas invertidas",
AUTUM = "Otoño, velas de plata, oso pintando piel",
WINTER = "Invierno, banquete, flores marchitas, ciervo con mirada perdida",
ALLSEA = "Año tras año, día tras día, abrir piel roja",
GENERIC = "Ahora podemos experimentar con la eficacia de los pequeños peces",
}
-- Montículo de tierra algo grande
________DESCRIBE.SHANHAI_NORMALPILE = {
GENERIC = "Mayores ganancias conllevan mayores riesgos",
}
-- Varita mágica
________DESCRIBE.SH_SPARKLER_SMALL = {
GENERIC = "Esto es científico",
}
-- Fuegos artificiales pequeños
________DESCRIBE.SH_SPARKLER_1 = {
GENERIC = "Sería mejor un poco más grande",
}
-- Fuegos artificiales
________DESCRIBE.SH_SPARKLER_2 = {
GENERIC = "Felices fiestas",
}
-- Fuegos artificiales grandes
________DESCRIBE.SH_SPARKLER_3 = {
GENERIC = "Ahora soy el más llamativo de la multitud",
}
-- Cuerno de Zhu Yan
________DESCRIBE.SH_KILLALL_WEAPON = {
GENERIC = "¡Gran caos en el mundo!",
}
-- Lanzador de fuegos artificiales
________DESCRIBE.SH_IRONOPENWORK_BASE = {
GENERIC = "¡Feliz Año Nuevo Chino!",
}
-- Componentes del lanzador de fuegos artificiales
________DESCRIBE.SH_IRONOPENWORK_BASE_KIT = {
GENERIC = "Colócalo rápido",
}
-- Fuegos artificiales de cuervo pequeño
________DESCRIBE.SH_FIREWORKS = {
GENERIC = "Tranquilo, no es un cuervo de verdad",
}
-- Hoja de ginkgo
________DESCRIBE.SHANHAI_GINKGOLEAVE = {
GENERIC = "Esto no son alas de mariposa",
}
-- ¿? Kunpeng
________DESCRIBE.KUN_RIDER = {
GENERIC = "Está atrapado aquí",
}
-- Flor de montaña
________DESCRIBE.SH_FLOWER = {
GENERIC = "¿Recoger o no recoger?",
}
-- Roca decorativa
________DESCRIBE.SH_ROCK_1 = {
GENERIC = "Rocas extrañas y escarpadas",
}
-- Planta de Gou Mang desenterrada
________DESCRIBE.DUG_SHANHAI_GOUMANG_PLANT = {
GENERIC = "La pequeña planta se va a mudar",
}
-- Enredadera de huevo de pájaro alto
________DESCRIBE.DSC_EGGVINE = {
GENERIC = "¿La evolución ya no funciona?",
}
-- Semilla parásita de huevo de pájaro alto
________DESCRIBE.SHANHAI_SEED_TALLBIRDEGG = {
GENERIC = "¿Qué le hemos hecho?",
}
-- Cangrejo brillante
________DESCRIBE.DSC_TREECRAB = {
GENERIC = "Se arrastrará hasta mis sueños",
}
-- Enredadera floral, curvada
________DESCRIBE.DSC_FLOWERVINE = {
GENERIC = "Encanto de curvas y recovecos",
}
-- Enredadera floral, en la salida
________DESCRIBE.SHANHAI_EXITVINE = {
GENERIC = "¡Apareció de repente!",
}
-- Árbol Migutree
________DESCRIBE.SH_MIGUTREE = {
GENERIC = "Se ve muy poco real",
MIGUTREE_FULL = "Quizás esto pueda guiarme en la dirección",
}
-- Rama de Migutree
________DESCRIBE.SH_MIGUTWIG = {
GENERIC = "Rama de navegación luminiscente",
}
-- Fuego extraño
________DESCRIBE.DSC_LIGHT = {
GENERIC = "¿Un cuervo pequeño común podría hacer esto?",
}
-- Nido de pájaro marino
________DESCRIBE.SH_SEANEST = {
GENERIC = "¡Ni mejillones, solo percebes y aves marinas!",
}
-- Poste de ave marina
________DESCRIBE.SH_SEANEST_KIT = {
GENERIC = "Deberíamos criar algunos mejillones",
}
-- Pequeña maceta
________DESCRIBE.SH_PLANTDECO = {
GENERIC = "Esto sí es jardinería",
}
-- Nubes despejadas
________DESCRIBE.DSC_COPYTOOL = {
GENERIC = "Espera a que las nubes se despejen para ver la luna llena",
YUNKAI_DEP = "¿Qué es eso, un pergamino de teletransporte?",
}
-- Jade espiritual del Río Suspendido
________DESCRIBE.XUANHE_PASSPORT = {
GENERIC = "Su elaboración no es común, definitivamente es algo bueno",
}
-- Formación mágica de Zhu Long
________DESCRIBE.STATUE_ZHULONG = {
GENERIC = "¡Me está mirando!",
}
-- Estatua de Zhu Long, Crepúsculo y Aurora
________DESCRIBE.STATUE_ZHULONG_USE = {
GENERIC = "¡El ciclo del tiempo ahora está bajo mi control!",
}
-- Rastro extraño
________DESCRIBE.SH_ANIMAL_TRACK = {
GENERIC = "¿Esto es... una huella?",
}
-- Golondrina de papel
________DESCRIBE.SH_PAPERBIRD = {
GENERIC = "Parece que tiene palabras en la espalda",
}
-- Papel de pistas
________DESCRIBE.SH_REDPAPER = {
GENERIC = "He visto escritura así en Pig Town",
}
-- Puente colgante de madera
________DESCRIBE.SH_BRIDGE = {
GENERIC = "He visto este diseño en otro lugar",
}
-- Qin Yuan
________DESCRIBE.SH_QINYUAN = {
GENERIC = "Qué aguijón de cola tan afilado, mejor no molestarlo",
}
-- Pintar montañas y ríos
________DESCRIBE.SH_DESC = {
GENERIC = "Debería calmarme y leer un libro",
}
-- Loseta de superficie helada
________DESCRIBE.TURF_SH_ICELAND = {
GENERIC = "Un trozo de... ¿hielo?",
}
-- Loseta de jardín
________DESCRIBE.TURF_SH_SMALLSTONE = {
GENERIC = "Un pequeño jardín",
}
-- Loseta XMM
________DESCRIBE.TURF_SH_XMM = {
GENERIC = "Una loseta XMM",
}
-- Loseta X Mingming
________DESCRIBE.TURF_SH_XMM = {
GENERIC = "Una loseta X Mingming",
}
-- Loseta de grava
________DESCRIBE.TURF_SH_LITTLESTONE = {
GENERIC = "Un trozo de grava",
}
-- Loseta de gravilla
________DESCRIBE.TURF_SH_MANYSTONE = {
GENERIC = "Un trozo de gravilla",
}
-- Aguijón de cola de vidrio
________DESCRIBE.SH_QYSTICK = {
GENERIC = "Aguijón de cola de vidrio",
}
-- Pluma multicolor
________DESCRIBE.SH_FEATHER_PHOENIX = {
    GENERIC = "Es la huella de que el Fénix estuvo aquí",
}
-- Estatua de Zhu Yan, el Desastre Bélico
________DESCRIBE.STATUE_ZHUYAN = {
    GENERIC = "¡Presagia desastre bélico, gran caos en el mundo!",
}
-- Zorro de nueve colas
________DESCRIBE.SH_CRITTER_FOXING = {
    GENERIC = "7, 8, 9... ¡tiene tantas colas!"
}
-- Disfraz sencillo
________DESCRIBE.SHPIGHAT = {
    GENERIC = "¿A quién puede engañar este disfraz?"
}
-- Semilla de ginseng de montaña
________DESCRIBE.SHANHAI_SEED_SHANSHEN = {
    GENERIC = "Plantar ginseng de montaña"
}
-- Decoración de hojas de ginkgo
________DESCRIBE.SHANHAI_GINKGOLEAVE_GROUND = {
    GENERIC = "¡Hojas doradas y brillantes!"
}
-- Escoba mágica de ginseng
________DESCRIBE.SH_MAGICSHANSHEN = {
    GENERIC = "Magia occidental, hechicería oriental, Corvus sabe un poco de cada una"
}
-- Hielo sobre Ganoderma
________DESCRIBE.SH_GANODERMAICE = {
    GENERIC = "Lo que se aprende en el papel es superficial, saberlo bien requiere practicarlo personalmente"
}
-- Elixir de la inmortalidad
________DESCRIBE.SH_NEVEROLD = {
    GENERIC = "Esto será una gran apuesta"
}
-- Píldora del rejuvenecimiento
________DESCRIBE.SH_BACKYOUNG = {
    GENERIC = "¿Quién puede rechazar la juventud eterna?"
}
-- Objeto de escalón de piedra
________DESCRIBE.SH_ABYSSPILLAR_ITEM = {
    GENERIC = "Esto hay que ponerlo en el mar"
}
-- -- Bomba de escalón de piedra
-- ________DESCRIBE.SH_ABYSSPILLAR_BOMB = {
--     GENERIC = "Esto puede romper el pequeño escalón de piedra"
-- }
-- Escalón de piedra
________DESCRIBE.SH_STONESTEP = {
    GENERIC = "Dar pasos demasiado grandes romperá los pantalones..."
}
-- Nube decorativa
________DESCRIBE.SADDLE_KUN_GROUND = {
    GENERIC = "Nubes extendidas en el suelo..."
}
-- Montaña Xiao Ci
________DESCRIBE.SH_ZHUYAN_SPAWNER = {
    GENERIC = "Sobre ella mucho jade blanco, debajo mucho cobre rojo"
}
-- Cesta de hojas de Ying Long
________DESCRIBE.SH_BACKPACK_LEAF = {
    GENERIC = "¡Tiene todas las ventajas del paraguas ocular y la mochila!"
}
-- Pequeño bote de hojas
________DESCRIBE.SH_LEAFBOAT_ITEM = {
    GENERIC = "Ponerlo en el agua, prepararse para navegar lejos"
}
-- Bote de una hoja flotante
________DESCRIBE.SH_LEAFBOAT = {
    GENERIC = "Es mejor que pueda soportar mucho peso"
}
-- Vela de una hoja pequeña
________DESCRIBE.SH_BOAT_TORCH = {
    GENERIC = "Incluso la llama más pequeña anhela iluminar un rincón del mundo"
}
-- Vela de plumas
________DESCRIBE.SH_FEATHERSAIL = {
    GENERIC = "Me recuerda a esos días de sufrimiento en el mundo de los naufragios"
}
-- Campanilla de Zhu Yan
________DESCRIBE.SH_ZYBELL = {
    GENERIC = "Pequeña y refinada"
}
-- Zhu Yuan
________DESCRIBE.DEEPSEACAVE_PIGMAN = {
    FAKEDEATH = "¿Qué le pasa?",
    STEALFOOD = "¡Oye! ¡Ladrón!",
    GENERIC = "Siempre parece estar ocupado",
}
-- Ventilador pequeño de hoja
________DESCRIBE.SH_BASEFAN = {
    GENERIC = "Inspirado en la temporada de polen de Hamlet",
}
-- Flauta de pan antigua
________DESCRIBE.SH_PANFLUTE = {
    GENERIC = "Esperaba que emitiera un sonido más hermoso",
}
-- Tablero de tres en raya
________DESCRIBE.SH_TICTACTOE_BOARD = {
    GENERIC = "Somos expertos en tres en raya",
    PLAYING = "El espectador no habla",
    FINISHED = "Juego terminado",
}
-- Pieza de tres en raya
________DESCRIBE.SH_TICTACTOE_PIECE_X = {
    GENERIC = "Es X, primer turno",
}
-- Pieza de tres en raya
________DESCRIBE.SH_TICTACTOE_PIECE_O = {
    GENERIC = "Es O, segundo turno",
}
-- Anciano
________DESCRIBE.DSC_ELDERSWAMPIG = {
    GENERIC = "¿Es el anciano de la gula? ¿Wei Diao no te cambió la piel?",
}
-- La tiendita de Zhu Yuan
________DESCRIBE.DSC_PIG_SHOP = {
    GENERIC = "¡Abrir, abrir la puerta!",
    ACTIVE = "¿Dónde aprendió eso?",
    BREWING = "¡Procesando!",
    BURNT = "Deberíamos tener cuidado con el fuego",
}
-- Efecto de la cesta de hojas
________DESCRIBE.SH_BACKPACK_LEAF_FX = {
    GENERIC = "Esos son los sirvientes de las sombras dentro de la cesta",
}
-- Entrada de la cueva celestial bloqueada
________DESCRIBE.DSC_CAVE_ENTRANCE = {
    GENERIC = "¡Ahora excavamos!",
}
-- Entrada de la cueva celestial
________DESCRIBE.DSC_CAVE_ENTRANCE_OPEN = {
    GENERIC = "Bajar a echar un vistazo no perderá nada",
    OPEN = "¡Los murciélagos no han descubierto esta salida!",
    FULL = "Ay, está lleno de gente",
}
-- Escalera de la caverna celestial
________DESCRIBE.DSC_CAVE_EXIT = {
    GENERIC = "Rayos, estoy atrapado",
    OPEN = "¡Veo la salida!",
    FULL = "Ay, está lleno de gente",
}
-- Pequeños monos de Zhu Yan
________DESCRIBE.SH_MONKEY = {
    GENERIC = "Se han vuelto extraordinariamente feroces",
}
-- Ganoderma camuflado
________DESCRIBE.DSC_MUSHROOM_TO_2 = {
    GENERIC = "Solo de verlo, me duele el trasero",
}
-- Salida oculta 2
________DESCRIBE.SHANHAI_HIDDENEXIT_2 = {
    GENERIC = "¿Qué tal si le damos un par de patadas para probar?",
}
-- Árbol torcido gigante
________DESCRIBE.DSC_OCEANTREE_PILLAR_2 = {
    GENERIC = "Creció desde el primer piso",
}
-- Cascada del Río Suspendido
________DESCRIBE.XUANHE_FALL = {
    GENERIC = "Catarata que cae tres mil pies",
}
-- Burrito de Montañas y Ríos
________DESCRIBE.SH_TACO = {
    GENERIC = "Deberíamos agregarle tiras picantes"
}
-- Burrito de Zhu Long
________DESCRIBE.SH_ZHULONG_TACO = {
    ROLLED = "¡La magia del tiempo y espacio finalmente se usa donde corresponde!",
    GENERIC = "¡Enrolla la comida rápido, enrolla la comida rápido!"
}
-- Cadena selladora de demonios
________DESCRIBE.DSC_CAVE_MAGICSEAL = {
    GENERIC = "¿No se romperá sola?"
}
-- Formación selladora de demonios
________DESCRIBE.DSC_CAVE_MAGICPLACVE = {
    GENERIC = "¡Quiero aprender esto, definitivamente!"
}
-- Estrella enana de la caverna celestial
________DESCRIBE.DSC_CAVE_STAFFLIGHT = {
    GENERIC = "Me hace sentir mucho más seguro"
}
-- Fruto de thulecita
________DESCRIBE.SH_THULECITE = {
    GENERIC = "Fruto de thulecita"
}
-- Semilla de veta mineral
________DESCRIBE.SH_THULECITE_SEEDS = {
    GENERIC = "¿Esto es piedra? ¿O semilla?"
}
-- Planta de fruto de thulecita
________DESCRIBE.FARM_PLANT_SH_THULECITE = {
    GENERIC = "Parece algún tipo de planta trepadora"
}
-- Fruto de thulecita gigante
________DESCRIBE.SH_THULECITE_OVERSIZED = {
    GENERIC = "Qué perezoso debió ser el creador de esta planta"
}
-- Fruto de thulecita gigante encerado
________DESCRIBE.SH_THULECITE_OVERSIZED_WAXED = {
    GENERIC = "Más grande, más brillante, más pesado"
}
-- Túnica de mangas del cosmos
________DESCRIBE.SH_MAGICVEST = {
    GENERIC = "Siempre es útil grabar más formaciones mágicas"
}

-- 模组适配内容
___________NAMES.SHANHAI_GOUMANG_WILTON = "Marca de Gou Mang"
_____RECIPE_DESC.SHANHAI_GOUMANG_WILTON = "Condensar manualmente la energía del cielo y la tierra"



