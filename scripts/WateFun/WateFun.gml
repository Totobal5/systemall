global._WATE_CONTROLLER = noone;
global._WATE_DATA		= noone;
global._WATE_MESSAGES	= noone;

global._WATE_TURNS  	= -1;

#macro WATE     	global._WATE_CONTROLLER
#macro WATE_DATA	global._WATE_DATA
#macro WATE_BUS		global._WATE_MESSAGES

#macro WATE_TURNS   global._WATE_TURNS
#macro WATE_AMOUNT 6
#macro WATE_PRIORSTAT "vel"

enum WATE_BACK_TYPE  {COLOR , SPRITE}
enum WATE_GROUPS	 {PLAYER, ENEMS, __SIZE}
enum WATE_STATE 	 {NORMAL, PAUSE, TRANS}

#region Constructors

function wate_controller() constructor {
	state = WATE_STATE.TRANS;
	
	turns = 0;
	timer = [];
	prior = "";
	
	// Donde se almacenan las entidades
	entities = ds_priority_create(); 
	
	// Con esto se comprueba principalmente que no existan más de este tipo de instancia.
	groups = array_create(WATE_GROUPS.__SIZE, [] );
	grid   = array_create(WATE_GROUPS.__SIZE, [] );	// Donde dibujar las entidades
	
	// Si no existe el bus de mensajes crearlo
	if (!ds_exists(WATE_BUS, ds_type_priority) ) WATE_BUS = ds_queue_create();
	
	#region Metodos
	static AddEntity  = function(_entity, _priority) {
		// Agregar
		ds_priority_add(entities , _entity, _priority);
		
		var _index = _entity.group;
		
		array_push(groups[_index], _entity);
		array_push(grid  [_index], _entity.render_pos);
	}
	
	static PassEntity = function(_entities) {
		var i = 0, _name;
		
		if (is_array(_entities) ) { // Es un array
			
			
		} else {	// Es una lista
			
		}
	}
	
	static Organize = function() {
		var _arr = array_create(WATE_GROUPS.__SIZE, [] );
		
		ds_priority_clear(entities);
		
		var i = 0; repeat(array_length(groups) ) {
			var inside = groups[i];
			
			var j = 0; repeat(array_length(inside) ) {
				var _entity = inside[i];
				var _group  = _entity.group;
				var _comp   = _entity.stats_final.Get(statprior);	// Obtener valor para comparar y crear los turnos.				
				
				// Agregar
				ds_priority_add(entities, _entity, _comp);  // Recrear turnos
				array_push	   (_arr[i] , _entity);			// Recrear entidades		
				
				++j;
			}
			
			++i;
		}
		
		groups = _arr;
	}
	
	/// @param Crea las instancias asociadas
	static ActorsCreate = function() {
			
	}
	
	/// @param
	static SetPriority  = function(_prior) {
		prior = _prior;
		
		return self;
	}
	
	#endregion
}

/// @desc Informacion para pasarla al controlador, pensar que es una dungeon
function wate_data() constructor {	
	// -- Enemigos
	packs = []; // Se almacenan varios packs (enemigos y loot) Si se tiene una mazmorra o algo por el estilo esto funciona a la maravilla ya que permite tener 
	            // varios conjuntos de enemigos para seleccionar.
    	
	enems = [];
	loot  = [];
	
	group_ignore = [];  // Si ignora a alguien perteneciente al grupo o no.
	
	// -- Background
	back_type  = WATE_BACK_TYPE.COLOR;
	back_color = [c_white, c_black];
	back_spr   = noone;
	
	// Si tiene algo especial
	especial	= false;
	timer		= [];
	
	// -- Ext
	trans_start = undefined;
	trans_end   = undefined;
	
	trans_part = 0;
	
	#region Metodos
	
	/// @param pack_class
	static PackAdd = function(_pack) {
        array_push(packs, _pack);
        return self;
	}
    
    static GetPack = function(_index) {
        return (packs[_index] );
    }
    
    /// @desc Establece que enemigos generará y los loots que se obtendrán a partir del pack seleccionado.
    static Unpack  = function(_pack_index) {
    	if (_pack_index == undefined) _pack_index = irandom(array_length(packs) - 1);
    	
    	if (_pack_index == -1) exit;
    	
        var _packer = GetPack(_pack_index); /// @is {wate_pack}
        
        var _iloot_random = array_length(_packer.loot) - 1;
        
        var i = 0; repeat(array_length(_packer.pack) ) {
            var _ienemy = _packer.GetEnemy(i);
            var _ienemy_chance = _ienemy[2]; // obtener probabilidad de aparecer

        	// Se consigue agregar el enemigo
    		if (percent_chance(_ienemy_chance) ) {
        		// Agregar enemigo
        		array_push(enems, _ienemy);
        		
        		// loot
        		if (_iloot_random > -1) { // Hay loot
        			var _iloot = _packer.GetLoot(irandom(_iloot_random) ); // Obtener un loot random	
        			
		            var _iloot_amount = _iloot [1];
		        	var _iloot_chance = _iloot [2]; 
		        	
	        		if (is_array(_iloot_amount) ) { // Entre cantidades
						var _amount = max(_iloot_amount[0], _iloot_amount[1] * percent_between(_iloot_chance) );

						_iloot[1] = _amount;
						
						array_push(loot, _iloot);
						
	        		} else { // Boleano
						if (percent_chance(_iloot_chance) ) array_push(loot, _iloot);
	        		}		        	
        		}
        		

    		}
        	
        	++i;    
        }
        
        return self;
    }
    
    /// @desc Limpia variables que se utilizan en otros combates.
    static Clean   = function() {
    	enems = [];
    	loot  = [];
    	
    	timer = [];
    	
    	return self;
    }
    
        #region Timer
    static AddTimer   = function(_type, _finish, _callback) {
        array_push(timer, (new wate_turns(_type, _finish, _callback) ) );
        return self;
    }
    
    #endregion
    
    static GetEnemy = function(_index) {
    	return (enems[_index]);
    }
    
	#endregion
}

/// @desc 
function wate_pack() constructor {
    pack = [];
    loot = [];
    
    #region Metodos
    static AddEnemy = function(_ins, _group_class, _prob) {
        // [Instancia, GROUP, Probabilidad]
        array_push(pack, [_ins, _group_class, _prob] );
        return self;
    }
    
    static AddLoot  = function(_keybag, _amount, _prob) {
        // [Key, Cantidad, Probabilidad]
        array_push(loot, [_keybag, _amount, _prob] );
        
    	/* 
    		["USB.MANZANA", 3		, 50]
    		["USB.MANZANA", [3, 5]	, 50]
   		*/        
            
        return self;
    }
    
    static GetEnemy = function(_index) {
        return (pack[_index] );
    }
    
    static GetLoot  = function(_index) {
        return (loot[_index] );
    }
    
    #endregion
}

function wate_timer(_type, _finish, _callback) constructor {
    type = _type;   // 0 Turn
    
    pass   = 0; // Tiempo o turnos pasados
    finish = _finish; // Terminar        
    
    callback = _callback;   // Funcion que ejecutar.
    
    #region Metodos
    static Update = function() {
        pass++;
        
        if (pass >= finish) callback();
    }
    
    #endregion
}

#endregion

/// @param priority_stat
/// @desc Inicia un combate
function wate_battle(_prior) {
	if (_prior == undefined) _prior = WATE_PRIORSTAT;
	
	if (!is_struct(WATE) ) WATE = (new wate_controller() ).SetPriority(_prior);
	
	// Unpack
	WATE_DATA.Clean().Unpack();
	
	var i = 0, _entity, _comp;
	
	/// Grupo
	repeat(group_get_count() ) {
		_entity = group_get(i);
		_comp   = _entity.stats_final.Get(_prior);	// Obtener valor para comparar y crear los turnos.
		
		// Se mantiene el nombre de los personajes en el grupo
		WATE.AddEntity(_entity, _comp);
		
		++i;
	} i = 0;	
	
	/// Enemigos
	repeat(array_length(WATE_DATA.enems) ) {
		_entity = WATE_DATA.GetEnemy(i)[1];
		_comp   = _entity.stats_final.Get(_prior);	// Obtener valor para comparar y crear los turnos.
		
		WATE.AddEntity(_entity, _comp);
		
		++i;
	}

	
}

/// @param data_class {wate_pack}
function wate_set_data(_data) {
	// referencia a la data
	WATE_DATA = _data;
}


/// @returns {wate_pack}
function wate_pack_flaite1(_lvlmin = 1, _lvlmax = 100) {
    var _pack = (new wate_pack() );
    
    _pack.AddEnemy(oEnemy_parent, group_create_enemyparent(irandom_range(_lvlmin, _lvlmax) ), 100);
    _pack.AddEnemy(oEnemy_parent, group_create_enemyparent(irandom_range(_lvlmin, _lvlmax) ), 75 );
    _pack.AddEnemy(oEnemy_parent, group_create_enemyparent(irandom_range(_lvlmin, _lvlmax) ), 50 );
    
    _pack.AddLoot ("OBJ.MANZANA", 3, 50).AddLoot ("GOLD", [800, 1600], 80);

	return _pack;
}

/// @returns {wate_pack}
function wate_pack_flaite2(_lvlmin = 1, _lvlmax = 100) {
    var _pack = (new wate_pack() );
    
    _pack.AddEnemy(oEnemy_parent, group_create_enemyparent(irandom_range(_lvlmin, _lvlmax) ), 100);
    _pack.AddEnemy(oEnemy_parent, group_create_enemyparent(irandom_range(_lvlmin, _lvlmax) ), 100);
    _pack.AddEnemy(oEnemy_parent, group_create_enemyparent(irandom_range(_lvlmin, _lvlmax) ), 100);
    
    _pack.AddLoot ("OBJ.MANZANA", 3, 50).AddLoot ("GOLD", [10000, 15000], 50);

	return _pack;
}



