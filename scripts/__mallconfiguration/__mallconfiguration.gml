#macro MALL_MY_VERSION  ":1.0"
#macro MALL_VERSION     "v2.5"+MALL_MY_VERSION
#macro MALL_TRACE       true
#macro MALL_ERROR       true
#macro MALL_MSJ_DV		"MallRPG "

// -- STATS
#macro MALL_STAT_ROUND       1               // 0: value, 1: round(x), 2: floor(x)
#macro MALL_STAT_DEFAULT_MAX 9999
#macro MALL_STAT_DEFAULT_MIN 0

#macro MALL_STAT_DEFAULT_LEVEL_MIN 0
#macro MALL_STAT_DEFAULT_LEVEL_MAX 100

#region PARTY
#macro MALL_PARTY_TRACE true
#macro MALL_PARTY_MIN_LEVEL 1
#macro MALL_PARTY_MAX_LEVEL 100

#endregion

#region POCKET
#macro MALL_POCKET_TRACE true
#macro MALL_POCKET_BAG_MIN	 0
#macro MALL_POCKET_BAG_MAX	99

#endregion

#region DARK
#macro MALL_DARK_TRACE true

#endregion

#region WATE
#macro MALL_WATE_TRACE true

#endregion

enum MALL_NUMTYPE {REAL , PERCENT}
enum MALL_NUMVAL  {VALUE, TYPE}

#region Database
function MallDatabase()
{
	static data = {
		dark:   {
			commands : {},
			functions: {
				// Definir defaults
				fMallStatEquip: function(_entity, _stat) {_stat.actual = _stat.control; },
			}
		},
		
		types:     {},
		typesKeys: [],
		
		stats:     {},
		statsKeys: [],
		
		states:     {},
		statesKeys: [],
		
		slots:     {},
		slotsKeys: [],
		
		mods:     {},  // modifiers modifier
		modsKeys: [],   //
		
		party:  {
			templates: {},
			groups:    {}
		},
		
		pocket: {
			items: {},
			bags : {},
			type : {}
		},
			
		wate:   {
			templates: {}
		}
	}
	return data;
}

#endregion

#region Utils
global.__mallRadio = ds_queue_create();

#endregion

/// @ignore
function mall_data_init() 
{	
	dark_database	(); // Iniciar comandos y funciones
	mall_database	(); // Iniciar states, stats, slots, types
	pocket_database	();
	
	// Ultimo en iniciarse
	party_database	();
}

// Llamar al inicio.
mall_data_init();