global._WATE_CONTROLLER = noone;
global._WATE_DATA		= noone;
global._WATE_MESSAGES	= noone;

global._WATE_TURNS  	= -1;

#macro WATE     	global._WATE_CONTROLLER
#macro WATE_DATA	global._WATE_DATA
#macro WATE_BUS		global._WATE_MESSAGES


#macro WATE_TURNS   global._WATE_TURNS
#macro WATE_AMOUNT 6

enum WATE_BACK_TYPE  {COLOR , SPRITE}
enum WATE_GROUPS	 {PLAYER, ENEMS, __SIZE}
enum WATE_STATE 	 {NORMAL, PAUSE, TRANS}

#region Constructors

function wate_controller() constructor {
	state = WATE_STATE.NORMAL;
	
	turns = 0;
	timer = [];
	statprior = "";
	
	// Donde se almacenan las entidades
	entities = ds_priority_create(); 
	
	// Con esto se comprueba principalmente que no existan más de este tipo de instancia.
	groups = array_create(WATE_GROUPS.__SIZE, [] );
	grid   = array_create(WATE_GROUPS.__SIZE, [] );	// Donde dibujar las entidades
	
	// Si no existe el bus de mensajes crearlo
	if (!ds_exists(WATE_BUS, ds_type_priority) ) WATE_BUS = ds_queue_create();
	
	#region Metodos
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

	

	#endregion
}

/// @desc
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
    	if (_pack_index == undefined) _pack_index = irandom(array_length(packs) );
    	
        var _packer = GetPack(_pack_index); /// @is {wate_create_pack}
        
        var _randomloot = array_length(_packer.loot);
        
        var i = 0; repeat(array_length(_packer.pack) ) {
            var ienemy = _packer.GetEnemy(i);
            var iloot  = _packer.GetLoot (irandom(_randomloot) ); // Obtener un loot random
            
            var ienemy_chance = ienemy[2];	// obtener probabilidad de aparecer
            
            var iloot_amount  = iloot [1];
        	var iloot_chance  = iloot [2];
        
        	// Se consigue agregar el enemigo
    		if (ienemy_chance < irandom(100) ) {        	
        		// Agregar enemigo
        		array_push(enems, ienemy);
        		
        		// loot
        		if (is_array(iloot_amount) ) { // Entre cantidades
        			var _random = irandom(iloot_chance);
					var _amount = max(iloot_amount[0], iloot_amount[1] * (100 - _random) / 100);
					
					iloot[1] = _amount;
					
					array_push(loot, iloot);
					
        		} else { // Boleano
					if (iloot_chance < irandom(100) ) array_push(loot, iloot);
        		}
    		}
        	
        	++i;    
        }
    }
    
    /// @desc Limpia variables que se utilizan en otros combates.
    static Clean   = function() {
    	enems = [];
    	loot  = [];
    	
    	timer = [];
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
function wate_create_pack() constructor {
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

/// @desc Inicia un combate
function wate_battle(_data, _prioritystat, _startcall, _endcall) {
	if (_startcall == undefined) _startcall = _data.trans_start;
	if   (_endcall   ==   undefined)   _endcall   = _data.trans_end	;
	
	if (!is_struct(WATE) ) WATE = (new wate_controller() );
	
	WATE.statprior = _prioritystat;
	
	// Inicial
	if (!is_undefined(_startcall) )	_startcall(_data);
	
	WATE_DATA = _data;	// referencia a la data
	
	/// Grupo
	var i = 0; repeat(group_get_count() ) {
		var _enemy = group_get(i);
		var _group = _enemy.group;
		var _comp  = _enemy.stats_final.Get(_prioritystat);	// Obtener valor para comparar y crear los turnos.
		
		// Agregar
		ds_priority_add(WATE.entities, _enemy, _comp);
		
		array_push(WATE.groups[_group], _enemy);
		array_push(WATE.grid  [_group], _enemy.render_pos);
		
		++i;
	}	
	
	/// Enemigos
	var i = 0; repeat(array_length(_data.enems) ) {
		var _enemy = _data.GetEnemy(i);
		var _group = _enemy.group;
		var _comp  = _enemy.stats_final.Get(_prioritystat);	// Obtener valor para comparar y crear los turnos.
		
		// Agregar
		ds_priority_add(WATE.entities, _enemy, _comp);
		
		array_push(WATE.groups[_group], _enemy);
		array_push(WATE.grid  [_group], _enemy.render_pos);
		
		++i;
	}
	
	// Terminar
	if (!is_undefined(_endcall) )	_endcall(_data);
}

function wate_pack_flaite1(_lvlmin = 0, _lvlmax = 100) {
    var _pack = (new wate_create_pack() );
    
    _pack.AddEnemy(oEnemy_parent, group_create_enemyparent(irandom_range(_lvlmin, _lvlmax) ), 100);
    _pack.AddEnemy(oEnemy_parent, group_create_enemyparent(irandom_range(_lvlmin, _lvlmax) ), 75 );
    _pack.AddEnemy(oEnemy_parent, group_create_enemyparent(irandom_range(_lvlmin, _lvlmax) ), 50 );
    
    _pack.AddLoot ("OBJ.MANZANA", 3, 50).AddLoot ("GOLD", [800, 1600], 80);

	return _pack;
}





