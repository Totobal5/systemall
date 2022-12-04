#macro MALL_MY_VERSION  ":1.0"
#macro MALL_VERSION     "v2.5"+MALL_MY_VERSION
#macro MALL_TRACE       true
#macro MALL_ERROR       true

// -- STATS
#macro MALL_STAT_ROUND	1               // 0: value, 1: round(x), 2: floor(x)
#macro MALL_STAT_DEFAULT_MAX 9999       
#macro MALL_STAT_DEFAULT_MIN 0

#macro MALL_STAT_DEFAULT_LEVEL_MIN 0
#macro MALL_STAT_DEFAULT_LEVEL_MAX 100

#region PARTY
#macro MALL_TRACE_PARTY true
#macro MALL_PARTY_MIN_LEVEL 1
#macro MALL_PARTY_MAX_LEVEL 100
#endregion

#region POCKET
#macro MALL_POCKET_TRACE true
#macro MALL_POCKET_BAG_MIN	 0
#macro MALL_POCKET_BAG_MAX	99

#endregion

#region DARK
#macro MALL_DARK function(caster, target, extra)
#macro MALL_DARK_TYPE_MAGIC	"MAGIA"
#macro MALL_DARK_TYPE_TICK	"TICK"

#endregion

enum MALL_NUMTYPE {REAL , PERCENT}
enum MALL_NUMVAL  {VALUE, TYPE}

#region Database
function MallDatabase()
{
	static data = {
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
	
		dark:   {
			commands: {}
		},
		
		wate:   {
			templates: {}	
		}
	}
	return data;
}

#endregion

	
#region Dark
global.__mallDarkData   = {};
global.__mallDarkActive = [];
	
#endregion

#region Party
global.__mallPartyTemplate = {};
global.__mallPartyGroups   = {};

#endregion

#region Wate
global.__mallWateCombats  = {}	// Grupo de peleas

#endregion

#region Utils
global.__mallRadio = ds_queue_create();

#endregion

/// @ignore
function mall_data_init() 
{	
	mall_database	();
	pocket_database	();
	dark_database	();
	
	party_database	();
}

// Llamar al inicio.
mall_data_init();