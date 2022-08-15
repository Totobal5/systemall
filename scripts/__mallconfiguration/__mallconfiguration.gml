#macro MALL_TRACE	true
#macro MALL_ERROR	true
#macro MALL_DUMMY_METHOD	global.__mall_dummy_method

// -- STATS
#macro MALL_STAT_ROUND	1		// 0: value, 1: round(x), 2: floor(x)
#macro MALL_STAT_DEFAULT_MAX 9999	
#macro MALL_STAT_DEFAULT_MIN 0

#macro MALL_STAT_DEFAULT_LEVEL_MIN 0
#macro MALL_STAT_DEFAULT_LEVEL_MAX 100

#region PARTY
#macro MALL_PARTY_SHOW_MESSAGE true

#endregion

#region POCKET
#macro POCKET_DATABASE_DUMMY	"POCKET.DUMMY"
#macro POCKET_BAG_MIN	 0
#macro POCKET_BAG_MAX	99

#endregion

#region DARK
#macro MALL_DARK function(caster, target, extra)
#macro MALL_DARK_TYPE_MAGIC	"MAGIA"
#macro MALL_DARK_TYPE_TICK	"TICK"

#endregion

#region ENUMS
enum MALL_NUMTYPE {REAL , PERCENT}
enum MALL_NUMVAL  {VALUE, TYPE}
// Para ciclar entre componentes (??)
enum MALL_COMPONENTS {MODIFY, STATES, STAT, EQUIPMENT, TYPE, COMPONENT}
global.__mallComponentsTypes = [0, 1, 2, 3, 4, 5];
global.__mallComponentsIsOff = [];

#endregion

/// @ignore
function mall_data_init() 
{
	#region Database
	
	global.__mallTypesMaster = {};
	global.__mallTypesKeys   = [];

	global.__mallStatsMaster = {};
	global.__mallStatsKeys   = [];

	global.__mallStatesMaster = {};
	global.__mallStatesKeys   = [];
	
	// Un modifier puede ser un elemento o algun tipo de propiedad.
	global.__mallModifyMaster = {};
	global.__mallModifyKeys  = [];
	
	global.__mallEquipmentMaster = {};
	global.__mallEquipmentKeys   = [];

	#endregion
	
	#region Pocket
	global.__mallPocketBag   = {}; // Bolsillos
	global.__mallPocketData  = {}; // Guardar informacion
	global.__mallPocketTypes = {}; // Tipos de objetos
	#endregion
	
	#region Dark
	global.__mallDarkData   = {};
	global.__mallDarkActive = [];
	
	#endregion

	#region Party
	global.__mallPartyTemplate = {};
	global.__mallPartyGroups   = {};

	#endregion

	#region Utils
	global.__mallMessages = {};
	
	#endregion
	
	mall_database	();
	pocket_database	();
	dark_database	();
	
	party_database	();
}

/// @param message Mensaje a mostrar
function __mall_trace(_MSG) 
{
	if (MALL_TRACE) 
	{
		show_debug_message("Mall: " + string(_MSG) );
	}
}

/// @param message Mensaje a mostrar
function __mall_error(_MSG)
{
	if (MALL_ERROR) show_error("Mall Error: " + string(_MSG), true);
}

// Llamar al inicio.
mall_data_init();