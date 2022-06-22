#macro MALL_TRACE			true
#macro MALL_DUMMY_METHOD	global.__mall_dummy_method

// -- STATS
#macro MALL_STAT_FUN		function(lvl, stat, extra)
#macro MALL_STAT_ROUND		1								// 0: value, 1: round(x), 2: floor(x)
#macro MALL_STAT_DEFAULT_MAX 9999	
#macro MALL_STAT_DEFAULT_MIN 0

// -- STATES
	// PREFIJO PREDETERMINADO PARA LOS STATES
#macro MALL_STATE_PREFIX_ATTACK	".ATTACK"
#macro MALL_STATE_PREFIX_DEFEND	".DEFEND"

// -- ELEMENTS
	// PREFIJO PREDETERMINADO PARA LOS ELEMENTS
#macro MALL_ELEMENT_PREFIX_ATTACK ".ATTACK"
#macro MALL_ELEMENT_PREFIX_DEFEND ".DEFEND"

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
#macro MALL_DARK_TYPE_TICK		"TICK"

#endregion

function mall_data_init() 
{
	#region Database
	/// @ignore
	global.__mall_groups_master		= (new Collection() );
	/// @ignore
	global.__mall_stats_master		= [];
	/// @ignore	
	global.__mall_states_master		= [];
	/// @ignore
	global.__mall_states_prefix		= {};
	/// @ignore
	global.__mall_elements_master	= [];
	/// @ignore
	global.__mall_elements_prefix	= {};
	/// @ignore
	global.__mall_parts_master		= [];

	#endregion
	
	#region Pocket
	/// @ignore
	global.__mall_pocket_bag = {};		// Bolsillos			
	/// @ignore
	global.__mall_pocket_database = {};	// Guardar informacion	
	
	#endregion
	
	#region Dark
	/// @ignore
	global.__mall_dark_database = {};
	/// @ignore
	global.__mall_dark_effects_active = [];
	
	#endregion
	
	#region Utils
	/// @ignore
	/// @desc Metodo sin nada para no crear infinitos 
	global.__mall_dummy_method = function(_temp=0) {return (_temp ); }
		
	// Grupo default
	/// @ignore
	global.__mall_group_actual	= undefined;			// Iniciar cuando se pueda noma oe
	/// @ignore
	global.__mall_party_groups	= new Collection();	// Donde se guardan listas con distintas entidades	
	/// @ignore
	global.__mall_party_templates = {};					// Plantillas para crear entidades party	
	/// party_key -> party_list	
	
	mall_database	();
	pocket_database	();
	dark_database	();
	
	party_database	();
	
	#endregion
}

/// @param message Mensaje a mostrar
function __mall_trace(_msg) 
{
	if (MALL_TRACE) show_debug_message("MALL: " + string(_msg) );
}

// Llamar al inicio.
mall_data_init();