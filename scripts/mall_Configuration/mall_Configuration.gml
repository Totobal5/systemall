#macro __MALL_VERSION       "v2.8"
#macro __MALL_MY_VERSION    __MALL_VERSION+"::1.0"
#macro __MALL_TRACE         true
#macro __MALL_ERROR         true
#macro __MALL_SAFETY        true

#region STATS
#macro __MALL_STAT_ROUND        round
#macro __MALL_STAT_MAX          9999
#macro __MALL_STAT_MIN          0

#macro __MALL_STAT_LEVEL_MIN    0
#macro __MALL_STAT_LEVEL_MAX    100

enum STAT_NUMTARG 
{
    CURRENT, 
    PEAK, 
    EQUIPMENT, 
    CONTROL, 
    LASCURRENT, 
    LASPEAK
}

#endregion

#region PARTY
// Indicar procesos realizados
#macro __MALL_PARTY_TRACE           true
#macro __MALL_PARTY_TRACE_LEVELUP   true

// Comprobar por errores
#macro __MALL_PARTY_SAFETY          false
#macro __MALL_PARTY_LEVEL_MIN       1
#macro __MALL_PARTY_LEVEL_MAX       100

#endregion

#region POCKET
#macro __MALL_POCKET_TRACE      true
#macro __MALL_POCKET_BAG_MIN    0
#macro __MALL_POCKET_BAG_MAX    99

#endregion

#region DARK
#macro __MALL_DARK_TRACE        true
#macro __MALL_DARK_SAFETY       false

/*	0: Inicio del turno
	1: Final  del turno
    2: En el inicio y final del turno */	
enum MALL_EFFECT_TURN 
{
	START, 
	END, 
	BOTH
}

#endregion

#region WATE
#macro __MALL_WATE_TRACE        true
#macro __MALL_WATE_SAFETY       false

#endregion

enum MALL_NUMTYPE   {REAL,  PERCENT}

enum MALL_NUMVAL    {VALUE, TYPE}

/// @desc Donde se guardan todos los datos que se utilizarán por Systemall.
function Systemall()
{
    // -- Componentes
    static stats     = {};
    static statsKeys = [];
    
    // -- Core
    static dark =     {};
    static groups =   {};
    static entities = {};
    
    static items = {};
    static bags  = {};
    static types = {};
    
    static wate =       {};
    static gangs =      {};
    static messages =   [];
    static mcurrent =   undefined;
}
// Generar la base de datos (estaticos)
Systemall(); 
var _f = new Mall()


// Iniciar comandos y funciones
dark_database();

// Iniciar states, stats, slots, types
mall_database();

// Iniciar objetos
pocket_database();

// Iniciar entidades
party_database();

// Iniciar templates de combates
wate_database();