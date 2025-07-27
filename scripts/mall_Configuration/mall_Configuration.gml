#macro __MALL_VERSION		"v2.8"
#macro __MALL_VERSION_MINE	__MALL_VERSION+"::1.0"
#macro __MALL_TRACE			true
#macro __MALL_ERROR			true
#macro __MALL_SAFETY		true

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
	/// @ignore Struct con todos los archivos cargados.
	static __master = {};
	/// @ignore Struct con todas las funciones accesibles por Systemall.
	static __functions = {};

	// -- Componentes --
	/// @ignore Base de datos donde se guardan todos los constructors de estadisticas del sistema.
	static __stats = {};
	static __stats_keys = [];

	/// @ignore Base de datos donde se guardan los "Estados" del sistema.
	static __states = {}
	static __states_keys = [];
	
	/// @ignore Base de datos donde se guardan todos los constructors de slots del sistema.
	static __slots = {};
	static __slots_keys = [];
	
	/// @ignore Base de datos donde se guardan todos los items del sistema.
	static __items = {};
	static __items_keys = [];
	
	/// @ignore Base de datos donde se guardan todas las mochilas del sistema.
	static __bags = {};
	static __bags_keys = [];
	
	/// @ignore Base de datos donde se guardan todos los grupos del sistema.
	static __groups = {};
	static __groups_keys = [];
	
	/// @ignore Base de datos donde se guardan todas las entidades del sistema.
	static __entities = {};
	static __entities_keys = [];	
	
	/// @ignore Base de datos donde se guardan todos los comandos y efectos del sistema.
	static __dark = {};
	static __dark_keys = [];	
	
	/// @ignore Base de datos donde se guardan todos los "Tipos" del sistema.
    static __types = {};
	static __types_keys = [];
	
	/// @ignore Base de datos donde se guardan todos los "Grupos" de batalla del sistema (Para enfrentamientos).
    static __wate = {};
	static __wate_keys = [];
	
	/// @ignore Sistema de Broadcast y Mensajes para el sistema.
    static __broadcast = {};
	static __messages = [];
}

/// @desc	Carga un archivo maestro que indica los lugares de otros archivos separados por el subsistema al que pertenecen.
///			De esta manera se vería de algo así {Stats: [.json...], Party: [.json], Pocket: [.json], Dark: [.json]}
function mall_system_load(_json)
{
	
}

// Generar statics
script_execute(Systemall);
script_execute(Mall);

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