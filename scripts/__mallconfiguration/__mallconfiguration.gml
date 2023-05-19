#macro MALL_VERSION     "v2.8"
#macro MALL_MY_VERSION  MALL_VERSION+"::1.0"
#macro MALL_TRACE       true
#macro MALL_ERROR       true
#macro MALL_MSJ_DV      "MallRPG "

#region STATS
#macro MALL_STAT_ROUND       1               // 0: value, 1: round(x), 2: floor(x)
#macro MALL_STAT_DEFAULT_MAX 9999
#macro MALL_STAT_DEFAULT_MIN 0

#macro MALL_STAT_DEFAULT_LEVEL_MIN 0
#macro MALL_STAT_DEFAULT_LEVEL_MAX 100

enum STAT_NUMTARG {
	ACTUAL, PEAK, EQUIPMENT, CONTROL, LACTUAL, LPEAK
}

#endregion

#region PARTY
#macro __MALL_PARTY_TRACE true    // Indicar procesos realizados
#macro __MALL_PARTY_DEBUG false   // Comprobar por errores
#macro __MALL_PARTY_MIN_LEVEL 1
#macro __MALL_PARTY_MAX_LEVEL 100

#endregion

#region POCKET
#macro __MALL_POCKET_TRACE   true
#macro __MALL_POCKET_BAG_MIN 0
#macro __MALL_POCKET_BAG_MAX 99

#endregion

#region DARK
#macro MALL_DARK_TRACE true

#endregion

#region WATE
#macro MALL_WATE_TRACE true

#endregion

enum MALL_NUMTYPE 
{
	REAL , PERCENT
}

enum MALL_NUMVAL  
{
	VALUE, TYPE
}

function MallDatabase()
{
	// -- Componentes
	static types     = {};
	static typesKeys = [];
	static typesDebugMessage  = function(_str) {
		show_debug_message("MallRPG Types: \n{0}", _str); 
	}

	static stats     = {};
	static statsKeys = [];
	static statsDebugMessage  = function(_str) {
		show_debug_message("MallRPG Stats: \n{0}", _str); 
	}

	static slots     = {};
	static slotsKeys = [];
	static slotsDebugMessage  = function(_str) {
		show_debug_message("MallRPG Slots: \n{0}", _str); 
	}

	static states     = {};
	static statesKeys = [];
	static statesDebugMessage = function(_str) {
		show_debug_message("MallRPG States: \n{0}", _str); 
	}

	static mods     = {};
	static modsKeys = [];
	static modsDebugMessage   = function(_str) {
		show_debug_message("MallRPG Mods: \n{0}", _str); 
	}
	
	// -- Core
	static dark = {};
	static darkShow = function(_str) {show_debug_message("MallRPG Dark: \n{0}", _str); }
	
	static party  = {
		templates: {},
		groups:    {}
	}
	
	static pocket = {
		items: {},
		bags : {},
		type : {}
	}
	
	static items = {};
	
	static wate   = {
		manager  : {}, // Manager actual singleton
		templates: {}
	}
	
	static messages = ds_queue_create();
}

// Generar la base de datos (estaticos)
MallDatabase(); 
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
wate_database()