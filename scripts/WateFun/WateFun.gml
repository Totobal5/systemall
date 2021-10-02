global._WATE_CREATOR  = noone;
global._WATE_MESSAGES = noone;
global._WATE_TURNS    = -1;

#macro WATE        global._WATE_CREATOR
#macro WATE_TURNS  global._WATE_TURNS
#macro WATE_AMOUNT 6

enum BACK_TYPE {
    COLOR ,
    SPRITE,
}

function wate_data() constructor {	
	// -- Enemigos
	packs = []; // Se almacenan varios packs (enemigos y loot) Si se tiene una mazmorra o algo por el estilo esto funciona a la maravilla ya que permite tener 
	            // varios conjuntos de enemigos para seleccionar.
    	
	enems = [];
	loot  = [];
	
	group_ignore = [];  // Si ignora a alguien perteneciente al grupo o no.
	
	// -- Background
	back_type  = BACK_TYPE.COLOR;
	back_color = [c_white, c_black];
	back_spr   = noone;
	
	// Si tiene algo especial
	especial	= false;
	timer		= [];
	
	// -- Ext
	trans = 0;	// 0: Normal
	
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
    static TimerClass = function(_type, _finish, _callback) constructor {
        type = _type;   // 0 Turn
        
        pass   = 0; // Tiempo o turnos pasados
        finish = _finish; // Terminar        
        
        callback = _callback;   // Funcion que ejecutar.
        
        #region Metodos
        static update = function() {
            pass++;
            
            if (pass >= finish) callback();
        }
        
        #endregion
    }
    
    static AddTimer   = function(_type, _finish, _callback) {
        array_push(timer, (new TimerClass(_type, _finish, _callback) ) );
        return self;
    }
    
    #endregion
    
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

function wate_battle() {
	// Guardar jugador
	if (jugador_ex) actor_congelar(oJugador);
	
	// Crear instancias.
	switch(WATE.trans) {
		default:
			fx_create(oFX_desaparecer_circulos, "Method_end", function() {
				// Establecer que se inicio un combate
				GAME.set_state(GAME_MODE_COMBATE);
				
				if (jugador_ex) {
					plyClass.Set(oJugador.x, oJugador.y, oJugador.Profundidad, oJugador.Direccion);			
				}	
				
				with (oJugador) instance_destroy();
				
				// -- Crear controlador de batallas
				var _ins = instance_create_layer(0, 0, lyr_cont, oBatallas_global);
			});

			break;
	}
}

function wate_init() {
	// Lista principal
	Entys = ds_list_create();
	
	// -- Crear jugadores
	Allys = ds_list_create();
	Enems = ds_list_create();
	
	// -- Allys
	var _size = GROUP_size;
	
	for (var i = 0; i < _size; i++) {
		var _psj = GROUP_get(i);
		
		// Agregar a la lista
		ds_list_add(Allys, _psj);
		ds_list_add(Entys, _psj);
		
		// Crear una instancia que este anclado a él.
		var _ins = instance_create_layer(0, 0, lyr_mid, oAlly_padre);
		
		with (_ins) Anclado = _psj;
	}
	
	// -- Enems
	var _size = array_length(WATE.enems);
	
	for (var i = 0; i < _size; i++) {
		var _enem = WATE.enems[i];
		
		// Agregar a la lista
		ds_list_add(Allys, _enem);
		ds_list_add(Entys, _enem);
		
		// Crear una instancia que este anclado a él.
		var _ins = instance_create_layer(0, 0, lyr_mid, _enem[0] );
		
		with (_ins) Anclado = _enem[1];		
	}
	
	// Ordenar velocidades
	wate_sort_speed(Entys);
	
	wate_sort_speed(Allys);
	wate_sort_speed(Enems);
}

/// @fun wate_sort_speed(List, Sort)
/// @param List
/// @param Sort
function wate_sort_speed(_list, _sort)	{
	if (is_undefined(_sort) ) _sort = true;
	
	var _new  = ds_list_create();
	
	var i = 0;
	
	var fun = function(a, b, s) {
		if ( s && (a < b) ) return true;
		if (!s && (a > b) ) return true;
		
		return false;
	}
	
	while (!ds_list_empty(_list) ) {
		#region Ordenar dependiendo del "_sort"
		var _size = ds_list_size(_list);
		
		var _os  = _list[| i][1].VEL;
		var _rep = false;
		var _pos = 0;
		
		for (var j = i; j < _size; j++) {
			var _ns = _list[| j][1].VEL;
			
			// Obtengo el mayor
			if (fun(_os, _ns, _sort) ) {
				_os  = _ns;
				_pos = j;	
			}
		}
		
		// Elimina de la lista el más rapido
		ds_list_add	  (_new, _list[| _pos] );
		ds_list_delete(_list, _pos);
	
		i++;
		
		#endregion
	}
	
	// Limpiar ordenar y destruir
	ds_list_clear	(_list);
	ds_list_copy	(_list, _new);
	ds_list_destroy	(_new);
}

function wate_pack_flaite1(_lvlmin = 0, _lvlmax = 100) {
    var _pack = (new wate_create_pack() );
    
    _pack.AddEnemy(oEnemy_parent, group_create_enemyparent(irandom_range(_lvlmin, _lvlmax) ), 100);
    _pack.AddEnemy(oEnemy_parent, group_create_enemyparent(irandom_range(_lvlmin, _lvlmax) ), 75 );
    _pack.AddEnemy(oEnemy_parent, group_create_enemyparent(irandom_range(_lvlmin, _lvlmax) ), 50 );
    
    _pack.AddLoot ("OBJ.MANZANA", 3, 50).AddLoot ("GOLD", [800, 1600], 80);

	return _pack;
}





