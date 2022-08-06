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

#endregion

function mall_data_init() 
{
	#region Database
	/// @ignore
	global.__mallTypesMaster = {};
	/// @ignore
	global.__mallTypesKeys   = [];

	/// @type {Struct<Struct.MallStat>}
	/// @ignore
	global.__mallStatsMaster = {};
	/// @type {Array<String>}
	/// @ignore
	global.__mallStatsKeys   = [];

	/// @ignore
	global.__mallStatesMaster = {};
	/// @ignore
	global.__mallStatesKeys   = [];
	
	/// @ignore
	// Un modifier puede ser un elemento o algun tipo de propiedad.
	global.__mallModsMaster = {};
	/// @ignore
	global.__mallModsKeys  = [];
	
	/// @ignore
	global.__mallEquipmentMaster = {};
	/// @ignore
	global.__mallEquipmentKeys   = [];

	#endregion
	
	#region Pocket
	/// @ignore
	global.__mallPocketBag  = {}; // Bolsillos			
	/// @ignore
	global.__mallPocketData = {}; // Guardar informacion	
	
	#endregion
	
	#region Dark
	/// @ignore
	global.__mallDarkData   = {};
	/// @ignore
	global.__mallDarkActive = [];
	
	#endregion
	
	#region Utils
	/// @ignore
	/// @desc Metodo sin nada para no crear infinitos 
	global.__mallDummyMethodReal   = function(_TEMP=0)  {return (_TEMP); }
	
	/// @ignore
	/// @desc Metodo sin nada para no crear infinitos
	global.__mallDummyMethodString = function(_TEMP="") {return (_TEMP); }
	
	// -- Grupo
	
	/// @ignore
	global.__mallPartyGroups   = {};
	/// @ignore
	global.__mallPartyTemplate = {};
	
	mall_database	();
	pocket_database	();
	dark_database	();
	
	party_database	();
	
	#endregion
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
	if (MALL_ERROR) show_error("Mall Error: " + string(_MSG) );	
}


// Llamar al inicio.
mall_data_init();