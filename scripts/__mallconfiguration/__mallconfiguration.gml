#macro MALL_FILE_PATH working_directory

#macro MALL_DUMMY_METHOD global.__mall_dummy_method
#macro MALL_TRACE true
// -- STATS
#macro MALL_STAT_FUN function(lvl, stat, extra)
#macro MALL_STAT_ROUND 1 // 0: value, 1: round(x), 2: floor(x)
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

#endregion

#region DARK
#macro MALL_DARK function(caster, target, extra)
#macro MALL_DARK_TYPE_MAGIC	"MAGIA"
#macro MALL_DARK_TYPE_TICK  "TICK"

#endregion

function mall_data_init() {
	#region Database
	global.__mall_groups_master  = (new Collection() );
	global.__mall_stats_master  = [];
	
	global.__mall_states_master = [];
	global.__mall_states_prefix = {};

	global.__mall_elements_master = [];
	global.__mall_elements_prefix = {};

	global.__mall_parts_master    = [];
	
	global.__mall_itemstype_master = [];
	/// @type {Struct.Struct.MallItemtype}
	global.__mall_itemstype_index  = {};
	
	global.__mall_actions_master = [];
	global.__mall_actions_index  = {};
	
	#endregion
	
	#region Pocket
	global.__mall_pocket = [];	// Bolsillos
	global.__mall_pocket_database = {};	// Guardar informacion	
	
	#endregion
	
	#region Dark
	global.__mall_dark_database = {};
	global.__mall_dark_effects_active = [];
	
	#endregion
	
	#region Utils
	/* @ignore Metodo sin nada para no crear infinitos */
	global.__mall_dummy_method = function(_temp=0) {
		return _temp; 
	}
	// Grupo default
	
	/// @type {Struct.MallGroup}
	global.__mall_actual_group = mall_add_group("default");
	/// @type {Struct.Collection}
	global.__mall_party = new Collection();
	
	#endregion
}

/// @param message Mensaje a mostrar
function __mall_trace(_msg) {
	if (MALL_TRACE) {
		show_debug_message("MALL: " + string(_msg) );	
	}
}

// Llamar al inicio.
mall_data_init();