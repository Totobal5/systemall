#macro POCKET_BAG "HEROES"
#macro POCKET_ITEMTYPE_ETC    "ETC"
#macro POCKET_ITEMTYPE_CONSM  "CONSUMIBLE"

#macro POCKET_ITEMTYPE_ARMA   "ARMA"

#macro POCKET_ITEMTYPE_ARMDU1 "ARMADURA1"
#macro POCKET_ITEMTYPE_ARMDU2 "ARMADURA2"
#macro POCKET_ITEMTYPE_PIES1 "PIES 1"
#macro POCKET_ITEMTYPE_PIES2 "PIES 1"

#macro POCKET_ITEMTYPE_ACCES1 "ACCESORIO1"  // Accesorios normales
#macro POCKET_ITEMTYPE_ACCES2 "ACCESORIO2"  // Accesorios especiales

#macro POCKET_ITEMTYPE_ENEMY  "P.ENEMIGOS"

/// @ignore
function pocket_database()
{
	// Inventario de los heroes
	#region --- SETUP
	#region Crear pocket
	pocket_create_bag(POCKET_BAG, function() {
		// Cambiar propiedades default
		order = [ [], [], [] ];
		items = {consumible: {}, equipo: {}, etc: {} };
		
		// Cambiar "set"
		set = function(_key, _count, _index, _vars) {
			var _rt = {
				result: true, item: undefined, left: 0
			}
			
			var _item = pocket_data_get(_key);
			var _array, _struct;
			#region Seleccionar
			switch (_item.type) {
				// Todo lo consumible
				case POCKET_ITEMTYPE_CONSM:
					_array  = order[0];
					_struct = items.consumible;
				break;
				
				// Todo tipo de equipable
				case POCKET_ITEMTYPE_ARMA  : case POCKET_ITEMTYPE_ARMDU1: case POCKET_ITEMTYPE_ACCES1:
				case POCKET_ITEMTYPE_ACCES2:
					_array  = order[1];
					_struct = items.equipo;
				break;
				
				// Todo lo demás
				default:
					_array  = order[2];
					_struct = items.etc;
				break;
			}
			
			#endregion
		
			// No existe agrear
			if (!variable_struct_exists(_struct, _key) ) {
				_struct[$ _key] = new itemComponent(_key);
			}
			// Si existe aumentar valor
			else {
				var _rem = array_find_index(_array, method({key: _key}, function(v,i) {
					return (v == key);
				}) );
				array_delete(order, _rem, 1); // Eliminar
				
				_struct[$ _key].count = _count;
			}
			
			// Posicionar
			array_set(_array, _index, _key);
			// Actualizar orden de objetos
			updateItems();
			return _rt;
		}
		
		get = function(_key, _vars) {
			// Feather disable GM2047
			var _item = pocket_data_get(_key);
			switch (_item.type) {
				// Todo lo equipable
				case POCKET_ITEMTYPE_ARMA  : case POCKET_ITEMTYPE_ARMDU1: case POCKET_ITEMTYPE_ACCES1:
				case POCKET_ITEMTYPE_ACCES2:
					return (items.equipo[$ _key] );
				break;
				
				// Todo lo consumible
				case POCKET_ITEMTYPE_CONSM: return (items.consumible[$ _key] ); break;
				
				// Todo lo demás
				default: return (items.etc[$ _key] ); break;
			}
		}
		
		add = function(_key, _count, _vars) {
			var _rt = {
				result: true, item: undefined, left: 0
			}
			
			var _item = pocket_data_get(_key);
			var _array, _struct;
			#region Seleccionar sub-bolsillo
			switch (_item.type) {
				// Todo lo consumible
				case POCKET_ITEMTYPE_CONSM:
					_array  = order[0];
					_struct = items.consumible;
				break;
				
				// Todo tipo de equipable
				case POCKET_ITEMTYPE_ARMA  : case POCKET_ITEMTYPE_ARMDU1: case POCKET_ITEMTYPE_ACCES1:
				case POCKET_ITEMTYPE_ACCES2:
					_array  = order[1];
					_struct = items.equipo;
				break;
				
				// Todo lo demás
				default:
					_array  = order[2];
					_struct = items.etc;
				break;
			}
			
			#endregion

			if (!variable_struct_exists(_struct, _key) ) {
				array_push(_array, _key);
				var n=array_length(_array) - 1;
				_struct[$ _key] = new itemComponent(_key, _count, n);
			}
			else {
				var _itemSum = _struct[$ _key].count + _count;
				// Comprobar limite menor
				if (_itemSum <= limit[0] ) {
					var _t = remove(_key);
					_rt.result = false;
					_rt.item   = _t;
				
				} 
				// Comprobar limite superior
				else if (_itemSum > limit[1] ) {
					_struct[$ _key].count = limit[1];
					var _t = limit[1] - _itemSum;
					_rt.left   = _t;
				} 
				// Agregar
				else {
					_struct[$ _key].count = _itemSum;
				}
			}
			// Actualizar orden de objetos
			updateItems();
			return _rt;
		}
		
		remove = function(_key) {
			var _item = pocket_data_get(_key);
			var _array, _struct;
			#region Seleccionar sub-bolsillo
			switch (_item.type) {
				// Todo lo consumible
				case POCKET_ITEMTYPE_CONSM:
					_array  = order[0];
					_struct = items.consumible;
				break;
				
				// Todo tipo de equipable
				case POCKET_ITEMTYPE_ARMA  : case POCKET_ITEMTYPE_ARMDU1: case POCKET_ITEMTYPE_ACCES1:
				case POCKET_ITEMTYPE_ACCES2:
					_array  = order[1];
					_struct = items.equipo;
				break;
				
				// Todo lo demás
				default:
					_array  = order[2];
					_struct = items.etc;
				break;
			}
			
			#endregion

			var t=_struct[$ _key];
			if (is_undefined(t) ) return t;

			// Eliminar
			array_delete(_array, t.index, 1);
			variable_struct_remove(_struct, _key);
		
			updateItems();
		
			return (t);
		}
		
		/// @desc Actualiza el orden de los objetos
		updateItems = function() {
			static fc = function(v, i) {
				var _item = items.consumible[$ v];
				_item.index = i;
			};
			static fe = function(v, i) {
				var _item = items.equipo[$ v];
				_item.index = i;
			}
			static ft = function(v, i) {
				var _item = items.etc[$ v];
				_item.index = i;
			}
			
			array_foreach(order[0], fc);
			array_foreach(order[1], fe);
			array_foreach(order[2], ft);
		}
			
		foreach = function(_function, _vars=all) {
			// Feather ignore all
			var _struct, _array;
			
			#region Ciclar por todos
			if (_vars == all) {
				var i=0; repeat(array_length(order) ) {
					var _array = order[i];
					switch (i) {
						case 0: _struct = items.consumible; break;
						case 1: _struct = items.equipo;     break;
						case 2: _struct = items.etc   ;     break;
					}
			
					var j=0; repeat(array_length(_array) ) {
						var _key   = _array[j];
						var _count = _struct[$ _key].count;
						_function(pocket_data_get(_key), _count, i, j);
						j = j + 1;
					}
			
					i = i + 1;
				}
			}
			
			#endregion
			
			#region 1 en especifico
			else {
				switch (_vars) {
					case 0: _struct = items.consumible; break;
					case 1: _struct = items.equipo;     break;
					case 2: _struct = items.etc   ;     break;
				}
				_array = order[_vars];
				var j=0; repeat(array_length(_array) ) {
					var _key   = _array[j];
					var _count = _struct[$ _key].count;
					_function(pocket_data_get(_key), _count, i, j);
					j = j + 1;
				}
			}
			
			#endregion
		}
			
		save = function() {
			var _s={order: [[], [], []], items: {consumible: {}, equipo: {}, etc: {} } }
			var i=0; repeat(array_length(order) ) {
				var _sub = order[i];
				var _sitem, _oitem;
				switch (i)
				{
					case 0: _sitem = _s.items.consumible; _oitem = items.consumible; break;
					case 1: _sitem = _s.items.equipo; _oitem = items.equipo; break;
					case 2: _sitem = _s.items.etc; _oitem = items.etc; break;
				}
				
				var j=0; repeat(array_length(_sub) ) {
					var _key = _sub[j];
					array_push(_s.order[i], _key)
					variable_struct_set(_sitem, _key, {
						key  : _key,
						count: _oitem[$ _key].count,
						index: j
					});
					
					j++;
				}
				i++;
			}

			return _s;
		}
	
		load = function(_l) {
			// Cargar objetos
			order = _l.order;
			items = _l.items;
		
			updateItems(); // Actualizar
		}
	});

	#endregion
	
	dark_create_function("fPocketRestoreEN"    , function(_caster, _target) {
		var _rt = {result: false, restore: 0};
		
		var _stats = _target.getStat();
		var _energ = _stats.get(STAT_EN);
		// Si no hay por que curar
		if (_energ.actual != _energ.control) {
			return _rt;
		}
		else {
			// variables del objeto (definidas en pocket_database_consumibles)
			var _amount  = getVar("restore") ?? 0;
			var _numtype = getVar("numtype") ?? MALL_NUMTYPE.REAL;
			var _numtarg = getVar("numtarget") ?? 0; // Restaurar por porcentaje
			
			var _value  = _stats.add(STAT_EN, _amount, _numtype, _numtarg);
			_rt.result  = (_value != 0);
			_rt.restore = _value;
		
			return (_rt);
		}
	})
	dark_create_function("fPocketRestoreEMP"   , function(_caster, _target) {
		var _rt = {result: false, restore: 0};
		
		var _stats = _target.getStat();
		var _energ = _stats.get(STAT_EPM);
		// From item
		var _amount  = getVar("restore") ?? 0;
		var _numtype = getVar("numtype") ?? MALL_NUMTYPE.REAL;
		var _numtarg = getVar( "target") ?? 0; // Restaurar por porcentaje
		
		var _value  = _stats.add(STAT_EPM, _amount, _numtype, _numtarg);
		_rt.result  = (_value != 0);
		_rt.restore = _value;
		
		return (_rt);
	});
	dark_create_function("fPocketRestoreEN&EMP", function(_caster, _target) {
		var _rt = {result: [false, false], restore: [0, 0]};
		
		var _stats = _target.getStat(), _value;
		// From item
		var _amount  = getVar("restore") ?? 0;
		if (!is_array(_amount) ) {
			var _t = _amount;
			_amount = [_t, _t];	
		}
		var _numtype = getVar("numtype") ?? MALL_NUMTYPE.REAL;
		var _numtarg = getVar( "target") ?? 0; // Restaurar por porcentaje
		
		_value  = _stats.add(STAT_EN, _amount[0], _numtype, _numtarg);
		_rt.result  [0] = (_value != 0);
		_rt.restore [0] = _value;
		
		_value = _stats.add(STAT_EPM, _amount[1], _numtype, _numtarg);
		_rt.result  [1] = (_value != 0);
		_rt.restore [1] = _value;

		return (_rt);
	});

	dark_create_function("fPocketRevive"       , function(_caster, _target) {
		/// @self ItemPocket
		var _rt = {result: false, restore: 0};
		var _control = _target.getControl(); // Obtener control
		// Si esta en false
		var _vivo = _control.get(STATE_VIVO);
		if (!_vivo.init) {
			var _stats = _target.getStat();
			var _en = _stats.get(STAT_EN);
			// Si la energia esta en 0
			if (_en.actual <= 0) {
				// From item
				var _amount  = getVar("restore") ?? 0;
				var _numtype = getVar("numtype") ?? MALL_NUMTYPE.REAL;
				var _numtarg = getVar("numtarget") ?? 0; // Restaurar por porcentaje
				var _value = _stats.add(STAT_EN, _amount, _numtype, _numtarg);
				_vivo.init = true;
				
				_rt.result  = true  ; 
				_rt.restore = _value;
			}
		}
		
		return (_rt);
	});
	
	#endregion
	
	pocket_database_consumibles();
	
	// Objetos que no se pueden usar, solo vender
	pocket_database_objetos();
	
	pocket_database_jon();
	
	pocket_database_gabi();

	pocket_database_fernando();
	
	// Para slots
	pocket_database_cuerpo();
	pocket_database_accesorio1();

	pocket_database_enemigos();
}

/// @ignore
function pocket_database_consumibles()
{
	#region Consumibles
	
		#region Objetos para recuperar EN
	#macro POCKET_ITEM_MANZANA_ROJA "POCKET.MANZANA.ROJA"
	pocket_create_data(
		new PocketItem(POCKET_ITEM_MANZANA_ROJA, POCKET_ITEMTYPE_CONSM, 60, 20).
		setFunUse("fPocketRestoreEN").
		setVar("restore", 30).setVar("numtype", MALL_NUMTYPE.PERCENT).setVar("numtarget", 5)
	);

	pocket_create_data(
		new PocketItem("POCKET.MANZANA.VERDE", POCKET_ITEMTYPE_CONSM, 60, 20).
		setFunUse("fPocketRestoreEN").setVar("restore", 60).setVar("numtype", MALL_NUMTYPE.PERCENT)
	);

	pocket_create_data(
		new PocketItem("POCKET.MANZANA.AZUL", POCKET_ITEMTYPE_CONSM, 60, 20).
		setFunUse("fPocketRestoreEN").setVar("restore", 90).setVar("numtype", MALL_NUMTYPE.PERCENT)
	); 

	#endregion

		#region Objetos para recupear EMP
	pocket_create_data(
		new PocketItem("POCKET.AGUAMINERAL", POCKET_ITEMTYPE_CONSM, 80, 10).
		setFunUse("fPocketRestoreEMP").setVar("restore", 15).setVar("numtype", MALL_NUMTYPE.PERCENT)
	);

	pocket_create_data(
		new PocketItem("POCKET.BEBIDA", POCKET_ITEMTYPE_CONSM, 80, 10).
		setFunUse("fPocketRestoreEMP").setVar("restore", 30).setVar("numtype", MALL_NUMTYPE.PERCENT)
	)

	pocket_create_data(
		new PocketItem("POCKET.ENERGETICA", POCKET_ITEMTYPE_CONSM, 80, 10).
		setFunUse("fPocketRestoreEMP").setVar("restore", 45).setVar("numtype", MALL_NUMTYPE.PERCENT)
	)

	#endregion

		#region Objetos para recupear EN y EMP
	pocket_create_data(
		new PocketItem("POCKET.PERLA.AZUL", POCKET_ITEMTYPE_CONSM, 80, 10).
		setFunUse("fPocketRestoreEN&EMP").setVar("restore", [15, 15]).setVar("numtype", MALL_NUMTYPE.PERCENT)
	);

	pocket_create_data(
		new PocketItem("POCKET.PERLA.ROJA", POCKET_ITEMTYPE_CONSM, 80, 10).
		setFunUse("fPocketRestoreEN&EMP").setVar("restore", [25, 25]).setVar("numtype", MALL_NUMTYPE.PERCENT)
	)

	pocket_create_data(
		new PocketItem("POCKET.PERLA.VERDE", POCKET_ITEMTYPE_CONSM, 80, 10).
		setFunUse("fPocketRestoreEN&EMP").setVar("restore", [40, 35]).setVar("numtype", MALL_NUMTYPE.PERCENT)
	)

	#endregion

		#region Objetos para revivir
	pocket_create_data(
		new PocketItem("POCKET.ESCENCIA.AZUL", POCKET_ITEMTYPE_CONSM, 200, 150).
		setFunUse("fPocketRevive").
		// Revivir con un 20% de la energia peak
		setVar("restore", 30).setVar("numtype", MALL_NUMTYPE.REAL).setVar("target", 2)
	);
	
	pocket_create_data(
		new PocketItem("POCKET.ESCENCIA.ROJA", POCKET_ITEMTYPE_CONSM, 200, 150).
		setFunUse("fPocketRevive").
		// Revivir con un 40% de la energia peak
		setVar("restore", 45).setVar("numtype", MALL_NUMTYPE.REAL).setVar("target", 2)
	);
	
	pocket_create_data(
		new PocketItem("POCKET.ESCENCIA.VERDE", POCKET_ITEMTYPE_CONSM, 200, 150).
		setFunUse("fPocketRevive").
		// Revivir con un 60% de la energia peak
		setVar("restore", 60).setVar("numtype", MALL_NUMTYPE.REAL).setVar("target", 2)
	);
	
	#endregion
	
	#endregion	
}

/// @ignore
function pocket_database_jon()
{
	#macro POCKET_ITEM_CUCHARITA    "POCKET.JON.CUCHARITA"
	pocket_create_data( // LVL 1 -> 6
		new PocketItem(POCKET_ITEM_CUCHARITA, POCKET_ITEMTYPE_ARMA, 150, 80).setStat(STAT_PODER, 12, MALL_NUMTYPE.REAL)
	);
	
	#macro POCKET_ITEM_CUCHARA_PLASTICA "POCKET.JON.CUCHARA.PLASTICA"
	pocket_create_data( // LVL 6 -> 12
		new PocketItem(POCKET_ITEM_CUCHARA_PLASTICA, POCKET_ITEMTYPE_ARMA,  320, 111).setStat(
			STAT_FUERZA,  6, MALL_NUMTYPE.REAL, STAT_FESPECIAL, 5, MALL_NUMTYPE.REAL,
			STAT_PODER , 16, MALL_NUMTYPE.REAL
		)
	); // 4 3 6
	#macro POCKET_ITEM_TENEDOR_PLASTICO "POCKET.JON.TENEDOR.PLASTICA"
	pocket_create_data( // LVL 6 -> 12
		new PocketItem(POCKET_ITEM_TENEDOR_PLASTICO, POCKET_ITEMTYPE_ARMA,  560, 155).setStat(
			STAT_FUERZA   ,  8, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 10, MALL_NUMTYPE.REAL,
			STAT_PODER    , 11, MALL_NUMTYPE.REAL
		)
	); // 7 4 5

	#macro POCKET_ITEM_CUCHARA_HIERRO "POCKET.JON.CUCHARA.HIERRO"
	pocket_create_data( // LVL 12 -> 24
		new PocketItem(POCKET_ITEM_TENEDOR_PLATA, POCKET_ITEMTYPE_ARMA, 6000, 1600).setStat(
			STAT_FUERZA , 10, MALL_NUMTYPE.REAL, STAT_FESPECIAL, 11, MALL_NUMTYPE.REAL, 
			STAT_PODER  , 19, MALL_NUMTYPE.REAL 
		)
	);
	#macro POCKET_ITEM_TENEDOR_HIERRO "POCKET.JON.TENEDOR.HIERRO"
	pocket_create_data( // LVL 12 -> 24
		new PocketItem(POCKET_ITEM_TENEDOR_HIERRO, POCKET_ITEMTYPE_ARMA, 920, 300).setStat(
			STAT_FUERZA   , 15, MALL_NUMTYPE.REAL,
			STAT_DEFENSA  ,  3, MALL_NUMTYPE.REAL, STAT_DESPECIAL, -6, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 14, MALL_NUMTYPE.REAL,
			STAT_PODER, 18, MALL_NUMTYPE.REAL
		)
	); // 2 -10

	#macro POCKET_ITEM_CUCHARA_PLATA "POCKET.JON.CUCHARA.PLATA"
	pocket_create_data( // LVL 24 -> 30
		new PocketItem(POCKET_ITEM_CUCHARA_PLATA, POCKET_ITEMTYPE_ARMA,  6000, 1600).setStat(
			STAT_FUERZA, 14, MALL_NUMTYPE.REAL, STAT_FESPECIAL, 17, MALL_NUMTYPE.REAL,
			STAT_PODER , 22, MALL_NUMTYPE.REAL
		)
	); 	
	#macro POCKET_ITEM_TENEDOR_PLATA "POCKET.JON.TENEDOR.PLATA"
	pocket_create_data( // LVL 24 -> 30
		new PocketItem(POCKET_ITEM_CUCHARA_HIERRO, POCKET_ITEMTYPE_ARMA, 6000, 1600).setStat(
			STAT_FUERZA   , 22, MALL_NUMTYPE.REAL,
			STAT_DEFENSA  ,  5, MALL_NUMTYPE.REAL, STAT_DESPECIAL, -16, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 18, MALL_NUMTYPE.REAL,
			STAT_PODER, 25, MALL_NUMTYPE.REAL,
		)
	);

	// mezcla de tenedor y cuchara
	#macro POCKET_ITEM_CUCHARA_TENEDOR_HIERRO "POCKET.JON.CUCHARA_TENEDOR.HIERRO"
	pocket_create_data( // LVL 30 -> 36
		new PocketItem(POCKET_ITEM_CUCHARA_TENEDOR_HIERRO, POCKET_ITEMTYPE_ARMA,  6000, 1600).setStat(
			STAT_FUERZA   , 16, MALL_NUMTYPE.REAL, STAT_DEFENSA  , 4, MALL_NUMTYPE.REAL,
			STAT_FESPECIAL, 14, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 2, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 11, MALL_NUMTYPE.REAL, 
			STAT_PODER    , 26, MALL_NUMTYPE.REAL 
		)
	);
	#macro POCKET_ITEM_CUCHARA_TENEDOR_PLATA "POCKET.JON.CUCHARA_TENEDOR.PLATA"
	pocket_create_data( // LVL 36 -> 42
		new PocketItem(POCKET_ITEM_CUCHARA_TENEDOR_PLATA, POCKET_ITEMTYPE_ARMA,  6000, 1600).setStat(
			STAT_FUERZA ,   20, MALL_NUMTYPE.REAL, STAT_DEFENSA  , 10, MALL_NUMTYPE.REAL,
			STAT_FESPECIAL, 20, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 10, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 16, MALL_NUMTYPE.REAL,
			STAT_PODER    , 30, MALL_NUMTYPE.REAL,
		)
	);
	
	#macro POCKET_ITEM_CUCHARON_HIERRO "POCKET.JON.CUCHARON.HIERRO" // De ahora empezar a restar algunas estadisticas
	pocket_create_data( // LVL 42 -> 48
		new PocketItem(POCKET_ITEM_CUCHARON_HIERRO, POCKET_ITEMTYPE_ARMA,  6000, 1600).setStat(
			STAT_FUERZA   ,  25, MALL_NUMTYPE.REAL, STAT_DEFENSA  , 17, MALL_NUMTYPE.REAL,
			STAT_FESPECIAL,  25, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 17, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD,  21, MALL_NUMTYPE.REAL, 
			STAT_PODER    ,  37, MALL_NUMTYPE.REAL
		)
	);
	#macro POCKET_ITEM_CUCHARON_PLATA "POCKET.JON.CUCHARON.PLATA" // De ahora empezar a restar algunas estadisticas
	pocket_create_data( // LVL 48 -> 54
		new PocketItem(POCKET_ITEM_CUCHARON_PLATA, POCKET_ITEMTYPE_ARMA,  6000, 1600).setStat(
			STAT_FUERZA   ,  25, MALL_NUMTYPE.REAL, STAT_DEFENSA  , 17, MALL_NUMTYPE.REAL,
			STAT_FESPECIAL,  25, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 17, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD,  21, MALL_NUMTYPE.REAL, 
			STAT_PODER    ,  37, MALL_NUMTYPE.REAL
		)
	);
}

/// @ignore
function pocket_database_gabi()
{
	#macro POCKET_ITEM_GUANTES_BLANCOS "POCKET.GABI.GUANTES.BLANCOS" // Enfoque especial
	pocket_create_data( // 50 -> 56
		new PocketItem(POCKET_ITEM_GUANTES_BLANCOS, POCKET_ITEMTYPE_ARMA, 1020, 104).setStat(
			STAT_FUERZA, 18, MALL_NUMTYPE.REAL,  STAT_FESPECIAL, 28, MALL_NUMTYPE.REAL,
			STAT_PODER , 43, MALL_NUMTYPE.REAL
		)
	); // 4 6 3
	#macro POCKET_ITEM_GUANTES_NEGROS "POCKET.GABI.GUANTES.NEGROS" // Enfoque fisico
	pocket_create_data( // 50 -> 56
		new PocketItem(POCKET_ITEM_GUANTES_NEGROS, POCKET_ITEMTYPE_ARMA, 2200, 500).setStat(
			STAT_FUERZA   , 28, MALL_NUMTYPE.REAL, 
			STAT_VELOCIDAD, 16, MALL_NUMTYPE.REAL,
			STAT_PODER    , 38, MALL_NUMTYPE.REAL
		)
	); // 4 6 3
	
	#macro POCKET_ITEM_GUANTES_ROJOS "POCKET.GABI.GUANTES.ROJOS"
	pocket_create_data( // 62 -> 68
		new PocketItem(POCKET_ITEM_GUANTES_ROJOS, POCKET_ITEMTYPE_ARMA, 2800, 500).setStat(
			STAT_FUERZA   ,  22, MALL_NUMTYPE.REAL, STAT_FESPECIAL, 34, MALL_NUMTYPE.REAL,
			STAT_DEFENSA  , -10, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD,  13, MALL_NUMTYPE.REAL,
			STAT_PODER    ,  46, MALL_NUMTYPE.REAL
		)
	); // -3 4 
	#macro POCKET_ITEM_GUANTES_VERDES "POCKET.GABI.GUANTES.VERDES"
	pocket_create_data( // 62 -> 68
		new PocketItem(POCKET_ITEM_GUANTES_VERDES, POCKET_ITEMTYPE_ARMA, 2620, 100).setStat(
			STAT_FUERZA   , 32, MALL_NUMTYPE.REAL, STAT_DEFENSA, 10, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 22, MALL_NUMTYPE.REAL,
			STAT_PODER    , 41, MALL_NUMTYPE.REAL
		)
	); // 4 
	
	#macro POCKET_ITEM_GUANTES_CUERO "POCKET.GABI.GUANTES.CUERO"
	pocket_create_data( // 73 -> 78
		new PocketItem(POCKET_ITEM_GUANTES_CUERO, POCKET_ITEMTYPE_ARMA, 2620, 100).setStat(
			STAT_FUERZA   , 26, MALL_NUMTYPE.REAL, STAT_DEFENSA  , -13, MALL_NUMTYPE.REAL,
			STAT_FESPECIAL, 38, MALL_NUMTYPE.REAL, STAT_DESPECIAL,  13, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 15, MALL_NUMTYPE.REAL,
			STAT_PODER    , 40, MALL_NUMTYPE.REAL
		)
	);	
}

/// @ignore
function pocket_database_fernando()
{
	#macro POCKET_ITEM_MONEDA_988 "POCKET.FEN.MONEDA.988"
	pocket_create_data( // 40 - 47
		(new PocketItem(POCKET_ITEM_MONEDA_988, POCKET_ITEMTYPE_ARMA) ).setStat(
			STAT_FUERZA , 20, MALL_NUMTYPE.REAL,
			STAT_CRITICO, 10, MALL_NUMTYPE.REAL,
			STAT_PODER  , 32, MALL_NUMTYPE.REAL
		)
	);
	#macro POCKET_ITEM_MONEDA_942 "POCKET.FEN.MONEDA.942"
	pocket_create_data( // 47 - 54
		(new PocketItem(POCKET_ITEM_MONEDA_942, POCKET_ITEMTYPE_ARMA) ).setStat(
			STAT_FUERZA   , 24, MALL_NUMTYPE.REAL,
			STAT_DESPECIAL, 11, MALL_NUMTYPE.REAL,
			STAT_CRITICO, 11, MALL_NUMTYPE.REAL,
			STAT_PODER  , 35, MALL_NUMTYPE.REAL
		)
	);
	#macro POCKET_ITEM_MONEDA_NIQUEL "POCKET.FEN.MONEDA.NIQUEL"
	pocket_create_data( // 61 - 68
		(new PocketItem(POCKET_ITEM_MONEDA_NIQUEL, POCKET_ITEMTYPE_ARMA) ).setStat(
			STAT_FUERZA   , 30, MALL_NUMTYPE.REAL, STAT_DEFENSA, 8, MALL_NUMTYPE.REAL,
			STAT_DESPECIAL,  9, MALL_NUMTYPE.REAL,
			STAT_CRITICO, 13, MALL_NUMTYPE.REAL,
			STAT_PODER  , 38, MALL_NUMTYPE.REAL
		)
	);
	#macro POCKET_ITEM_MONEDA_PLATA "POCKET.FEN.MONEDA.PLATA"
	pocket_create_data( // 68 - 75
		(new PocketItem(POCKET_ITEM_MONEDA_PLATA, POCKET_ITEMTYPE_ARMA) ).setStat(
			STAT_FUERZA   , 36, MALL_NUMTYPE.REAL, STAT_DEFENSA, 16, MALL_NUMTYPE.REAL,
			STAT_DESPECIAL, 16, MALL_NUMTYPE.REAL,
			STAT_CRITICO, 14, MALL_NUMTYPE.REAL,
			STAT_PODER  , 41, MALL_NUMTYPE.REAL
		)
	);
	#macro POCKET_ITEM_MONEDA_ORO "POCKET.FEN.MONEDA.ORO"
	pocket_create_data( // 75 - 82
		(new PocketItem(POCKET_ITEM_MONEDA_ORO, POCKET_ITEMTYPE_ARMA) ).setStat(
			STAT_FUERZA   , 42, MALL_NUMTYPE.REAL, STAT_DEFENSA, 24, MALL_NUMTYPE.REAL,
			STAT_DESPECIAL, 25, MALL_NUMTYPE.REAL,
			STAT_CRITICO, 16, MALL_NUMTYPE.REAL,
			STAT_PODER  , 44, MALL_NUMTYPE.REAL
		)
	);	
}

/// @ignore
function pocket_database_cuerpo()
{
	// -- Polera y Camisa 
	// Polera: Defensa y Velocidad
	// Camisa: Defensa y Despecial
	
	#macro POCKET_ITEM_CAMISA_COLEGIO "POCKET.CUE.CAMISA.COLEGIO"
	pocket_create_data( // LVL 1 -> 4 (Jon, Susana)
		new PocketItem(POCKET_ITEM_CAMISA_COLEGIO, POCKET_ITEMTYPE_ARMDU1,  200, 80).setStat(
			STAT_DEFENSA, 6, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 3, MALL_NUMTYPE.REAL
		)
	); // Sumar: 6 3
	#macro POCKET_ITEM_POLERA_COLEGIO "POCKET.POLERA.COLEGIO"
	pocket_create_data( // LVL 1 -> 4 (Jon, Susana)
		new PocketItem(POCKET_ITEM_POLERA_COLEGIO, POCKET_ITEMTYPE_ARMDU1,  200, 80).setStat(
			STAT_DEFENSA, 5, MALL_NUMTYPE.REAL,  STAT_VELOCIDAD, 4, MALL_NUMTYPE.REAL
		)
	); // Sumar: 5 7
	
	#macro POCKET_ITEM_CAMISA_CUADROS "POCKET.CAMISA.CUADROS"
	pocket_create_data( // LVL 4 -> 9 (Jon, Susana)
		new PocketItem(POCKET_ITEM_CAMISA_CUADROS, POCKET_ITEMTYPE_ARMDU1,  200, 80).setStat(
			STAT_DEFENSA, 12, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 6, MALL_NUMTYPE.REAL
		)
	);
	#macro POCKET_ITEM_POLERA_COLORIDA "POCKET.POLERA.COLORIDA"
	pocket_create_data( // LVL 4 -> 9 (Jon, Susana)
		new PocketItem(POCKET_ITEM_POLERA_COLORIDA, POCKET_ITEMTYPE_ARMDU1,  200, 80).setStat(
			STAT_DEFENSA, 10, MALL_NUMTYPE.REAL, STAT_VELOCIDAD, 7, MALL_NUMTYPE.REAL
		)
	);
	
	
	#macro POCKET_ITEM_CAMISA_VEBRES "POCKET.CAMISA.VEBRES" // Vebres marca famosa de ropa
	pocket_create_data( // LVL 9 -> 14 (Jon, Susana)
		new PocketItem(POCKET_ITEM_CAMISA_VEBRES, POCKET_ITEMTYPE_ARMDU1,  200, 80).setStat(
			STAT_DEFENSA, 18, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 9, MALL_NUMTYPE.REAL
		)
	); // Sumar: 6 3
	#macro POCKET_ITEM_POLERA_VEBRES "POCKET.POLERA.VEBRES"
	pocket_create_data( // LVL 9 -> 14 (Jon, Susana)
		new PocketItem(POCKET_ITEM_POLERA_VEBRES, POCKET_ITEMTYPE_ARMDU1,  200, 80).setStat(
			STAT_DEFENSA, 15, MALL_NUMTYPE.REAL, STAT_VELOCIDAD, 10, MALL_NUMTYPE.REAL
		)
	); // Sumar: 5 7
	
	

	#macro POCKET_ITEM_PLATINAS_HIERRO "POCKET.PLATINAS.HIERRO" 
	pocket_create_data( // LVL 40 -> 46 (Gabi, Fernando)
		new PocketItem(POCKET_ITEM_PLATINAS_HIERRO, POCKET_ITEMTYPE_ARMDU1,  530, 200).setStat(
			STAT_DEFENSA  , 30, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 15, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, -6, MALL_NUMTYPE.REAL,
			STAT_PODER, 4, MALL_NUMTYPE.REAL 
		)
	);// 5 5 -4 1
	#macro POCKET_ITEM_PLATINAS_ECTO "POCKET.PLATINAS.ECTO"
	pocket_create_data( // LVL 40 -> 46 (Gabi, Fernando)
		new PocketItem(POCKET_ITEM_PLATINAS_ECTO, POCKET_ITEMTYPE_ARMDU1, 53, 200).setStat(
			STAT_DEFENSA, 14, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 30, MALL_NUMTYPE.REAL,
			STAT_PODER, 3, MALL_NUMTYPE.REAL
		)
	); // 5 5 1
	
	#macro POCKET_ITEM_CHALECO_BLINDADO "POCKET.CHALECO.BLINDADO"
	pocket_create_data( // LVL 46 -> 52 (Gabi, Fernando)
		new PocketItem(POCKET_ITEM_CHALECO_BLINDADO, POCKET_ITEMTYPE_ARMDU1, 530, 200).setStat(
			STAT_DEFENSA  ,  35, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 20, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, -10, MALL_NUMTYPE.REAL,
			STAT_PODER, 5, MALL_NUMTYPE.REAL 
		)
	);
	#macro POCKET_ITEM_CHALECO_IMBUIDO "POCKET.CHALECO.IMBUIDO"
	pocket_create_data( // LVL 46 -> 52 (Gabi, Fernando)
		new PocketItem(POCKET_ITEM_CHALECO_IMBUIDO, POCKET_ITEMTYPE_ARMDU1, 53, 200).setStat(
			STAT_DEFENSA, 19, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 30, MALL_NUMTYPE.REAL,
			STAT_PODER  ,  4, MALL_NUMTYPE.REAL
		)
	);
	
	#macro POCKET_ITEM_CHALECO_REFORZADO "POCKET.CHALECO.REFORZADO"
	pocket_create_data( // LVL 52 -> 59 (Gabi, Fernando)
		new PocketItem(POCKET_ITEM_CHALECO_REFORZADO, POCKET_ITEMTYPE_ARMDU1,  530, 200).setStat(
			STAT_DEFENSA  ,  40, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 25, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, -14, MALL_NUMTYPE.REAL,
			STAT_PODER, 6, MALL_NUMTYPE.REAL
		)
	); // 5 5 -4 1
	#macro POCKET_ITEM_CHALECO_TRATADO "POCKET.CHALECO.TRATADO"
	pocket_create_data( // LVL 52 -> 59 (Gabi, Fernando)
		new PocketItem(POCKET_ITEM_CHALECO_TRATADO, POCKET_ITEMTYPE_ARMDU1, 530, 200).setStat(
			STAT_DEFENSA, 24, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 35, MALL_NUMTYPE.REAL,
			STAT_PODER  ,  5, MALL_NUMTYPE.REAL
		)
	); // 5 5 1
	
	#macro POCKET_ITEM_CHALECO_ELDRO "POCKET.CHALECO.ELDRO" // ELDRO fabricante de equipo para policias, militares, etc
	pocket_create_data( // LVL 59 -> 66 (Gabi, Fernando)
		new PocketItem(POCKET_ITEM_CHALECO_ELDRO, POCKET_ITEMTYPE_ARMDU1,  530, 200).setStat(
			STAT_DEFENSA  , 45, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 30, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD,-18, MALL_NUMTYPE.REAL,
			STAT_PODER, 7, MALL_NUMTYPE.REAL
		)
	);
	#macro POCKET_ITEM_CHALECO_ECTO "POCKET.CHALECO.ECTO"
	pocket_create_data( // LVL 59 -> 66 (Gabi, Fernando)
		new PocketItem(POCKET_ITEM_CHALECO_ECTO, POCKET_ITEMTYPE_ARMDU1, 53, 200).setStat(
			STAT_DEFENSA, 29, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 40, MALL_NUMTYPE.REAL,
			STAT_PODER  ,  6, MALL_NUMTYPE.REAL
		)
	);
	
	#macro POCKET_ITEM_CHALECO_SQUAD "POCKET.CHALECO.SQUAD" // SQUAD equipo para amenazas "normales" peligrosas
	pocket_create_data( // LVL 66 -> 73 (Gabi, Fernando)
		new PocketItem(POCKET_ITEM_CHALECO_SQUAD, POCKET_ITEMTYPE_ARMDU1,  530, 200).setStat(
			STAT_DEFENSA  , 50, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 35, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD,-22, MALL_NUMTYPE.REAL,
			STAT_PODER, 8, MALL_NUMTYPE.REAL
		)
	);
	#macro POCKET_ITEM_CHALECO_ECTLDRO "POCKET.CHALECO.ECTLDRO" // Un chaleco Eldro imbuido en ecto
	pocket_create_data( // LVL 66 -> 73 (Gabi, Fernando)
		new PocketItem(POCKET_ITEM_CHALECO_ECTLDRO, POCKET_ITEMTYPE_ARMDU1, 53, 200).setStat(
			STAT_DEFENSA, 34, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 45, MALL_NUMTYPE.REAL,
			STAT_PODER  ,  6, MALL_NUMTYPE.REAL
		)
	);
	
	#macro POCKET_ITEM_CHALECO_MILITAR "POCKET.CHALECO.MILITAR"
	pocket_create_data( // LVL 73 -> 80 (Gabi, Fernando)
		new PocketItem(POCKET_ITEM_CHALECO_SQUAD, POCKET_ITEMTYPE_ARMDU1,  530, 200).setStat(
			STAT_DEFENSA  , 60, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 45, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD,-30, MALL_NUMTYPE.REAL,
			STAT_PODER, 10, MALL_NUMTYPE.REAL
		)
	);
	#macro POCKET_ITEM_CHALECO_MUERTO "POCKET.CHALECO.MUERO" // "Muerto" se refiere a que un espiritu lo posee
	pocket_create_data( // LVL 73 -> 80 (Gabi, Fernando)
		new PocketItem(POCKET_ITEM_CHALECO_ECTLDRO, POCKET_ITEMTYPE_ARMDU1, 53, 200).setStat(
			STAT_DEFENSA, 44, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 55, MALL_NUMTYPE.REAL,
			STAT_PODER  ,  8, MALL_NUMTYPE.REAL
		)
	);
}

/// @ignore
function pocket_database_pies()
{

	pocket_create_data( // LVL 8 -> 14 (Jon, Susana)
		new PocketItem("POCKET.ZAPATOS_MANCHADOS",  POCKET_ITEMTYPE_ACCES2,  320, 130).
		setStat(STAT_DEFENSA, 7).setStat(STAT_VELOCIDAD, 9, MALL_NUMTYPE.REAL)
	);
	pocket_create_data( // LVL 14 -> 18 (Jon, Susana)
		new PocketItem("POCKET.ZAPATOS",  POCKET_ITEMTYPE_ACCES2,  320, 130).
		setStat(STAT_DEFENSA, 12).setStat(STAT_VELOCIDAD, 14, MALL_NUMTYPE.REAL)
	);
	pocket_create_data( // LVL 18 -> 24 (Jon, Susana)
		new PocketItem("POCKET.ZAPATOS_DE_IMITACION",  POCKET_ITEMTYPE_ACCES2,  320, 130).
		setStat(STAT_DEFENSA, 17).setStat(STAT_VELOCIDAD, 19, MALL_NUMTYPE.REAL)
	);
	
	// Zapatillas
	pocket_create_data( // LVL 4 -> 8 (Jon, Susana)
		new PocketItem("POCKET.ZAPATILLAS_GASTADAS", POCKET_ITEMTYPE_ACCES2, 320, 130).setStat(STAT_VELOCIDAD, 11)
	);
	pocket_create_data( // LVL 8 -> 14 (Jon, Susana)
		new PocketItem("POCKET.ZAPATILLAS_MANCHADAS",  POCKET_ITEMTYPE_ACCES2,  320, 130).
		setStat(STAT_DEFENSA, 2).setStat(STAT_VELOCIDAD, 17, MALL_NUMTYPE.REAL)
	);
	pocket_create_data( // LVL 14 -> 18 (Jon, Susana)
		new PocketItem("POCKET.ZAPATILLAS",  POCKET_ITEMTYPE_ACCES2,  320, 130).
		setStat(STAT_DEFENSA, 4).setStat(STAT_VELOCIDAD, 23, MALL_NUMTYPE.REAL)
	);
	pocket_create_data( // LVL 18 -> 24 (Jon, Susana)
		new PocketItem("POCKET.ZAPATILLAS_DE_IMITACION",  POCKET_ITEMTYPE_ACCES2,  320, 130).
		setStat(STAT_DEFENSA, 6).setStat(STAT_VELOCIDAD, 29, MALL_NUMTYPE.REAL)
	);
	pocket_create_data( // LVL 36 -> 40 (Jon, Fernando, Gabi)
		new PocketItem("POCKET.ZAPATILLAS_DE_SEGURIDAD", POCKET_ITEMTYPE_ACCES2, 650, 150).
		setStat(STAT_DEFENSA, 18).setStat(STAT_VELOCIDAD, 26)
	);	

	// Botas
	#macro POCKET_ITEM_BOTAS "POCKET.BOTAS"
	pocket_create_data( // LVL 24 -> 36 (Gabi, Fernando)
		new PocketItem("POCKET.BOTAS", POCKET_ITEMTYPE_ACCES2, 650, 150).
		setStat(STAT_DEFENSA, 16).setStat(STAT_VELOCIDAD, 4)
	);
	#macro POCKET_ITEM_BOTAS_LIGERAS "POCKET.BOTAS.LIGERAS"
	pocket_create_data( // LVL 24 -> 36 (Jon, Gabi, Fernando)
		new PocketItem("POCKET.BOTAS.LIGERAS", POCKET_ITEMTYPE_ACCES2, 650, 150).
		setStat(STAT_DEFENSA, 8).setStat(STAT_VELOCIDAD, 9)
	);
	#macro POCKET_ITEM_BOTAS_ESCENCIA "POCKET.BOTAS.ESCENCIA"
	pocket_create_data( // LVL 30 -> 42 (Gabi, Fernando)
		new PocketItem("POCKET.BOTAS.ESCENCIA", POCKET_ITEMTYPE_ACCES2, 650, 150).
		setStat(STAT_DEFENSA, 12).setStat(STAT_DESPECIAL, 14).setStat(STAT_VELOCIDAD, 4)
	);	
}

/// @ignore
function pocket_database_accesorio1()
{
	#macro POCKET_ITEM_GORRO_LANA "POCKET.ACC1.GORRO_DE_LANA"
	pocket_create_data( // LVL 1 -> 8 (Jon, Susana)
		new PocketItem(POCKET_ITEM_GORRO_LANA, POCKET_ITEMTYPE_ACCES1, 220, 0).setStat(
			STAT_DEFENSA, 2, MALL_NUMTYPE.REAL
		)
	);
	
	#macro POCKET_ITEM_CRUZ "POCKET.ACC1.CRUZ"
	pocket_create_data( // LVL 1 -> 8 (Jon, Susana)
		new PocketItem(POCKET_ITEM_CRUZ, POCKET_ITEMTYPE_ACCES1, 220, 0).setStat(
			STAT_DEFENSA, 3, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 3, MALL_NUMTYPE.REAL
		)
	);
	
	#macro POCKET_ITEM_DIBUJO "POCKET.ACC1.DIBUJO"
	pocket_create_data( // LVL 1 -> 8 (Jon)
		new PocketItem(POCKET_ITEM_DIBUJO,  POCKET_ITEMTYPE_ACCES1,  100, 2).setStat(STAT_PODER, 2, MALL_NUMTYPE.REAL).
		// en 2 turnos aumenta el ataque especial en un 10%
		setFunTurn("fPocketJonDibujo")
	);
	
	#macro POCKET_ITEM_ZAPATOS_GASTADOS "POCKET.ZAPATOS.GASTADOS"
	pocket_create_data( // LVL 1 -> 8 (Jon, Susana)
		new PocketItem(POCKET_ITEM_ZAPATOS_GASTADOS, POCKET_ITEMTYPE_ACCES1, 320, 130).setStat(
			STAT_DEFENSA  , 1, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 1, MALL_NUMTYPE.REAL
		)
	);


	#macro POCKET_ITEM_AMULETO_GALLO "POCKET.ACC1.AMULETO.GALLO"
	pocket_create_data( // 30 - 40
		new PocketItem(POCKET_ITEM_AMULETO_GALLO, POCKET_ITEMTYPE_ACCES1, 600, 500).setStat(STAT_VELOCIDAD, 18, MALL_NUMTYPE.REAL)
	);	
	
	#macro POCKET_ITEM_ANILLO_TAURO "POCKET.ACC1.ANILLO.TAURO"
	pocket_create_data( // 30 - 40
		new PocketItem(POCKET_ITEM_ANILLO_TAURO, POCKET_ITEMTYPE_ACCES1, 600, 500).setStat(
			STAT_FUERZA   ,  8, MALL_NUMTYPE.REAL, STAT_DEFENSA, 24, MALL_NUMTYPE.REAL,
			STAT_DESPECIAL, 18, MALL_NUMTYPE.REAL,
			STAT_PODER, 3, MALL_NUMTYPE.REAL
		)
	);
	
	#macro POCKET_ITEM_ANILLO_ARIES "POCKET.ACC1.ANILLO.ARIES"
	pocket_create_data( // 30 - 40
		new PocketItem(POCKET_ITEM_ANILLO_ARIES, POCKET_ITEMTYPE_ACCES1, 600, 500).setStat(
			STAT_FUERZA, 14, MALL_NUMTYPE.REAL, STAT_VELOCIDAD, 18, MALL_NUMTYPE.REAL
		)
	);
	
	#macro POCKET_ITEM_ANILLO_CAPRICORNIO "POCKET.ACC1.ANILLO.CAPRICORNIO"
	pocket_create_data( // 40 - 50
		new PocketItem(POCKET_ITEM_ANILLO_CAPRICORNIO, POCKET_ITEMTYPE_ACCES1, 600, 500).setStat(
			STAT_DEFENSA, 20, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 20, MALL_NUMTYPE.REAL,
		)
	);
}

/// @ignore
function pocket_database_objetos()
{
	#macro POCKET_ITEM_ECTOLITA "POCKET.OBJ.ECTOLITA"
	pocket_create_data(
		(new PocketItem("POCKET.OBJ.ECTOLITA", POCKET_ITEMTYPE_CONSM, 0, 250) )
	);
}


/// @ignore
function pocket_database_enemigos()
{
	// Para Floating Head
	pocket_create_data(
		(new PocketItem("POCKET.ENE.MIRADA_DE_MIEDO", POCKET_ITEMTYPE_ENEMY, -100, -100) ).setStat(STAT_PODER, 32)
	);
	// Para Floating Head
	pocket_create_data(
		(new PocketItem("POCKET.ENE.MIRADA_DE_TEMOR", POCKET_ITEMTYPE_ENEMY, -100, -100) ).setStat(
			STAT_VELOCIDAD, 20, MALL_NUMTYPE.REAL,
			STAT_PODER    , 36, MALL_NUMTYPE.REAL
		)
	);

	// Para Dead Bird
	pocket_create_data(
		(new PocketItem("POCKET.ENE.ALAS_DE_ECTO", POCKET_ITEMTYPE_ENEMY, -100, -100) ).setStat(STAT_PODER, 55)
	);
	// Para Dead Bird
	pocket_create_data(
		(new PocketItem("POCKET.ENE.ALAS_DE_PETO", POCKET_ITEMTYPE_ENEMY, -100, -100) ).setStat(
			STAT_DESPECIAL, 26, MALL_NUMTYPE.REAL,
			STAT_PODER    , 45, MALL_NUMTYPE.REAL
		)
	);

	// Para Zombie
	pocket_create_data(
		(new PocketItem("POCKET.ENE.BLOOD", POCKET_ITEMTYPE_ENEMY, -100, -100) ).setStat(STAT_PODER, 55)
	);
}


