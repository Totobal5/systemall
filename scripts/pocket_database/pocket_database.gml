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
	/// Feather ignore all
	// Inventario de los heroes
	var _bag = function() : PocketBag() constructor {
		order = array_create_ext(3, function() {return array_create(0); });
		items = {consumibles: {}, equipos: {}, etc: {} };
		
		/// @param {Struct.PocketItem} item
		set = function(_item, _count, _index, _vars) 
		{
			static dfilter = function(item) {return (itemkey == item.key); }; 
			var _return = {result: true, item: undefined, left: 0};
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
			
			var _itemkey = _item.key;
			// No existe agrear
			if (!struct_exists(_struct, _itemkey) ) {
				_struct[$ _itemkey] = new itemComponent(_item, _count, _index);
			}
			// Si existe aumentar valor y mover del indice antiguo
			else {
				var _filter = method({itemkey: _itemkey}, dfilter);
				var _found =  array_find_index(_array, _filter);
				// Eliminar
				array_delete(_array, _found, 1);
				
				_struct[$ _itemkey].count = _count;
			}
			
			// Posicionar
			array_set(_array, _index, _itemkey);
			
			// Actualizar orden de objetos
			updateItems();
			
			return _return;
		}
		
		/// @param {string} itemkey
		/// @return {Struct.PocketItem}
		get = function(_key) 
		{
			if (is_string(_key) ) {
				if (!struct_exists(items.consumibles, _key) ) return (items.consumibles[$ _key] );
				if (!struct_exists(items.equipos, _key) )     return (items.equipos[$ _key] );
				if (!struct_exists(items.etc, _key) )         return (items.etc[$ _key] );
				return undefined;
			}
		}
		
		/// @desc Agrega o elimina objetos de esta bolsa
		/// @param {Struct.PocketItem} item
		/// @param {real} count
		add = function(_item, _count)
		{
			var _return = {result: true, item: undefined, left: 0};
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
			
			var _itemkey = _item.key;
			if (struct_exists(_struct, _itemkey) ) {
				array_push(_array, _itemkey);
				// Agregar componente
				_struct[$ _itemkey] = new itemComponent(_itemkey, _count, array_length(_array)-1);
			}
			else {
				var _sitem =  _struct[$ _itemkey];
				var _bcount = _sitem.count + _count;
				// Comprobar limite menor (La cantidad de este objeto llego al minimo)
				if (_bcount <= limit[0] ) {
					var _removeitem = remove(_itemkey);
					_return.result = false;
					_return.item =   _removeitem;
				}
				// Comprobar limite superior (No se pudo agregar contenido)
				else if (_bcount > limit[1]) {
					_sitem.count = limit[1];
					_return.result = false;
					_return.left =   limit[1] - _bcount;
				}
				// Solo agregar
				else {
					_sitem.count = _bcount;
				}
			}
			
			// Actualizar orden de objetos
			updateItems();
			
			return _return;
		}
		
		/// @return {Struct.PocketBag$$itemComponent}
		remove = function(_key)
		{
			var _array, _struct;
			if (struct_exists(items.consumibles, _key) ) {
				_array = order[0]; _struct = items.consumibles;
			}
			if (struct_exists(items.equipos, _key) )     {
				_array = order[1]; _struct = items.equipos;
			}
			if (struct_exists(items.etc, _key) )         {
				_array = order[1]; _struct = items.etc;
			}
			
			var _sitem = _struct[$ _key];
			if (is_undefined(_sitem) ) exit; // Evitar errores
			
			// Eliminar
			array_delete( _array, _sitem.index, 1);
			struct_remove(_struct, _key);
			
			updateItems();
			
			return (_sitem);
		}

		/// @desc Actualiza el orden de los objetos
		updateItems = function() 
		{
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

		save = function() 
		{
			var _this = self;
			var _save = {order: variable_clone(_this.order), items: {consumibles: {}, equipos: {}, etc: {} } }
			var i=0; repeat(array_length(order) ) {
				var _sub = order[i], _sitems, _oitems;
				#region Seleccionar
				switch (i) {
					case 0: _sitems = _save.items.consumibles;   _oitems = items.consumibles;     break;
					case 1: _sitems = _save.items.equipos;       _oitems = items.equipos;         break;
					case 2: _sitems = _save.items.etc;           _oitems = items.etc;             break;
				}
				
				#endregion
				
				var j=0; repeat(array_length(_sub) ) {
					var _key =   _sub[j];
					var _oitem = _oitems[$ _key];
					
					array_push(_save.order[i], _key)
					variable_struct_set(_sitems, _key, {
						construct: _oitem.item.is, // Obtener el constructor de este objeto
						count: _oitem.count,       // Guardar numeros
						index: j                   // Guardar indice
					});
					
					j++;
				}
				
				i++;
			}

			return _save;
		}

		load = function(_l) 
		{
			// Cargar objetos
			order = _l.order;
			var i=0; repeat(array_length(order) ) {
				var _sub = order[i], _sitems, _oitems;
				#region Seleccionar
				switch (i) {
					case 0: _sitems = _l.items.consumibles;   _oitems = items.consumibles;     break;
					case 1: _sitems = _l.items.equipos;       _oitems = items.equipos;         break;
					case 2: _sitems = _l.items.etc;           _oitems = items.etc;             break;
				}
				#endregion
				
				// Crear constructors
				var j=0; repeat(array_length(_sub) ) {
					var _key =   _sub[j];
					var _sitem = _sitems[$ _key];
					// Añadir al array
					array_push(_sub, _key);
					// Crear constructor
					var _cn = new script_execute(_sitem.construct);
					set(_cn, _sitem.count, _sitem.index); // Añadir objeto
				}
			}
			
			// Actualizar
			updateItems();
		}
	}
	pocket_create_bag(POCKET_BAG, new _bag());


	#region -- Items
	#macro POCKET_ITEM_MANZANA_ROJA "POCKET.MANZANA.ROJA"
	pocket_create(function() : PocketItem(POCKET_ITEM_MANZANA_ROJA, POCKET_ITEMTYPE_CONSM) constructor 
	{
		buy=60; sell=20;
		
		/// @param {struct.PartyEntity} caster
		/// @param {struct.PartyEntity} target
		static use = function(caster, target) 
		{
			var _return = {result: false, restore: 0};
		
			var _en = target.statGet(STAT_EN);
			// Si no hay por que curar
			if (_en.actual != _en.control) return _return;
			// Curar si se puede
			var _value  = target.statAdd(STAT_EN, restore, restoreType, restoreNumtarget);
			_return.result  = (_value != 0);
			_return.restore = _value;
		
			return (_return);
		}
		
		// Valores para curar
		restore     = 30;
		restoreType = MALL_NUMTYPE.PERCENT;
		restoreNumtarget = 5;
	} ());
	
	
	#endregion
}

#region -- Items


	
#macro POCKET_ITEM_MANZANA_VERDE "POCKET.MANZANA.VERDE"
function IT_ManzanaVerde() : IT_ManzanaRoja() constructor
{
	key = POCKET_ITEM_MANZANA_VERDE;
	buy *= 4; sell *= 2;
	restore *= 1.5;
}
	
#macro POCKET_ITEM_MANZANA_LADY "POCKET.MANZANA.VERDE"
function IT_ManzanaLady() : IT_ManzanaRoja() constructor
{
	key = POCKET_ITEM_MANZANA_LADY;
	buy *= 8; sell *= 4;
	restore *= 2.1;
}
	
// -- Recuperar EN
#macro POCKET_ITEM_AGUA_MINERAL "POCKET.AGUA.MINERAL"
function IT_AguaMineral() : PocketItem(POCKET_ITEM_AGUA_MINERAL, POCKET_ITEMTYPE_CONSM) constructor
{
	buy = 80; sell=10;
		
	/// @param {struct.PartyEntity} caster
	/// @param {struct.PartyEntity} target
	fnUse = function(caster, target) {
		var _return = {result: false, restore: 0};
		var _epm =    target.statGet(STAT_EPM);
		// From item
		var _value  = target.statAdd(STAT_EPM, restore, type, numtarget);
		_return.result  = (_value != 0);
		_return.restore = _value;
			
		return (_return);
	}
		
	restore =   15; 
	type =      MALL_NUMTYPE.PERCENT;
	numtarget = 5;
}

#macro POCKET_ITEM_BEBIDA "POCKET.BEBIDA"
function IT_Bebida() : IT_AguaMineral() constructor
{
	key = POCKET_ITEM_BEBIDA
	buy*=2; sell*=2;
	restore *= 2;
}
	
#macro POCKET_ITEM_BEBIDA_ENERGETICA "POCKET.BEBIDA.ENERGETICA"
function IT_BebidaEN() : IT_Bebida() constructor
{
	key = POCKET_ITEM_BEBIDA_ENERGETICA;
	buy*=2; sell*=2;
	restore *= 1.5;
}
	

// -- Recuperar EN y EMP
#macro POCKET_ITEM_PERLA_AZUL "POCKET.PERLA.AZUL"
function IT_PerlaAzul() : PocketItem(POCKET_ITEM_PERLA_AZUL, POCKET_ITEMTYPE_CONSM) constructor
{
	buy=300; sell=10;
	/// @param {Struct.PartyEntity} caster
	/// @param {Struct.PartyEntity} target
	fnUse = function(caster, target) {
		var _result = {result: [false, false], restore: [0, 0]};
		
		var _stats = _target.getStat(), _value;
			
		_value  = target.statAdd(STAT_EN, restoreEN, numtype, numtarg);
		_result.result  [0] = (_value != 0);
		_result.restore [0] = _value;
			
		_value = target.statAdd(STAT_EPM, restoreEPM, numtype, numtarg);
		_result.result  [1] = (_value != 0);
		_result.restore [1] = _value;
			
		return (_result);
	}
		
	restoreEN  = 15;
	restoreEPM = 15;
		
	numtype = MALL_NUMTYPE.PERCENT;
	numtarg = 0;
}
	
#macro POCKET_ITEM_PERLA_ROJA "POCKET.PERLA.ROJA"
function IT_PerlaRoja() : IT_PerlaAzul() constructor
{
	key = POCKET_ITEM_PERLA_ROJA;
	restoreEN  = round(restoreEN *1.6);
	restoreEPM = round(restoreEPM*1.5);
}
	
#macro POCKET_ITEM_PERLA_VERDE "POCKET.PERLA.VERDE"
function IT_PerlaVerde() : IT_PerlaRoja() constructor 
{
	key = POCKET_ITEM_PERLA_VERDE;
	restoreEN  *= 2; 
	restoreEPM *= 1.5;
}

// -- Revivir
#macro POCKET_ITEM_ESCENCIA_AZUL "POCKET.ESCENCIA.AZUL"
function IT_EscenciaAzul() : PocketItem(POCKET_ITEM_ESCENCIA_AZUL, POCKET_ITEMTYPE_CONSM) constructor {
	buy = 200; sell = 150;
		
	/// @param {Struct.PartyEntity} caster
	/// @param {Struct.PartyEntity} target
	fnCanUse = function(caster, target) {
		return (!target.controlState(STATE_VIVO) && target.statGet(STAT_EN).control <= 0); 
	}

	/// @param {Struct.PartyEntity} caster
	/// @param {Struct.PartyEntity} target
	fnUse = function(caster, target) {
		/// @self Struct.PocketItem
		var _result =  {result: false, restore: 0};
		// Si esta en false
		var _en =    target.statGet(STAT_EN);
		var _value = target.statAdd(STAT_EN, restore, numtype, numtarg);
		// Indicar que esta vivo
		target.controlStateSet(STATE_VIVO, true);
			
		// Cambiar resultado
		_result.result  = true;
		_result.restore = _value;
			
		return (_result);
	}
		
	restore = 30;
	numtype = MALL_NUMTYPE.PERCENT;
	numtarg = STAT_NUMTARG.CONTROL;
}
	
#macro POCKET_ITEM_ESCENCIA_ROJA "POCKET.ESCENCIA.ROJA"
function IT_EscenciaRoja()  : IT_EscenciaAzul() constructor
{
	key = POCKET_ITEM_ESCENCIA_ROJA;
	restore *= 1.5;
}
	
#macro POCKET_ITEM_ESCENCIA_VERDE "POCKET.ESCENCIA.VERDE"
function IT_EscenciaVerde() : IT_EscenciaAzul() constructor
{
	key = POCKET_ITEM_ESCENCIA_VERDE;
	restore *= 1.4;
}

#endregion

#region -- Jon Items
// LVL 1 -> 6
#macro POCKET_ITEM_CUCHARITA "POCKET.JON.CUCHARITA"
function IT_JonCucharita() : PocketItem(POCKET_ITEM_CUCHARITA, POCKET_ITEMTYPE_ARMA, 150,80) constructor 
{
	setStat(STAT_PODER, 12, MALL_NUMTYPE.REAL);
}
	
// LVL 6 -> 12
#macro POCKET_ITEM_CUCHARA_PLASTICA "POCKET.JON.CUCHARA.PLASTICA"
function IT_JonCucharaPlastica() : PocketItem(POCKET_ITEM_CUCHARA_PLASTICA, POCKET_ITEMTYPE_ARMA) constructor {
	buy  = 320;
	sell = 100;
		
	setStat(STAT_FUERZA, 6 , MALL_NUMTYPE.REAL,  STAT_FESPECIAL, 5, MALL_NUMTYPE.REAL);
	setStat(STAT_PODER , 16, MALL_NUMTYPE.REAL);
}
	
// LVL 6 -> 12
#macro POCKET_ITEM_TENEDOR_PLASTICO "POCKET.JON.TENEDOR.PLASTICA"
function IT_JonTenedorPlastico() : PocketItem(POCKET_ITEM_TENEDOR_PLASTICO, POCKET_ITEMTYPE_ARMA) constructor {
	buy = 480;
	sell= 100;
	setStat(
		STAT_FUERZA,    8 , MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 10, MALL_NUMTYPE.REAL,
		STAT_PODER,     11, MALL_NUMTYPE.REAL
		);
}
	
// LVL 12 -> 24
#macro POCKET_ITEM_CUCHARA_HIERRO "POCKET.JON.CUCHARA.HIERRO"
function IT_JonCucharaHierro() : PocketItem(POCKET_ITEM_CUCHARA_HIERRO, POCKET_ITEMTYPE_ARMA) constructor {
	buy = 680;
	sell= 300;
		
	setStat(
		STAT_FUERZA, 10, MALL_NUMTYPE.REAL,  STAT_FESPECIAL, 11, MALL_NUMTYPE.REAL,
		STAT_PODER , 19, MALL_NUMTYPE.REAL
		);
}
	
// LVL 12 -> 24
#macro POCKET_ITEM_TENEDOR_HIERRO "POCKET.JON.TENEDOR.HIERRO"
function IT_JonTenedorHierro() : PocketItem(POCKET_ITEM_TENEDOR_HIERRO, POCKET_ITEMTYPE_ARMA) constructor {
	buy = 725;
	sell= 320;
		
	setStat(
		STAT_FUERZA   , 15, MALL_NUMTYPE.REAL,
		STAT_DEFENSA  ,  3, MALL_NUMTYPE.REAL, STAT_DESPECIAL, -6, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 14, MALL_NUMTYPE.REAL,
		STAT_PODER, 18, MALL_NUMTYPE.REAL
		);
}
	
// LVL 24 -> 30
#macro POCKET_ITEM_CUCHARA_PLATA "POCKET.JON.CUCHARA.PLATA"
function IT_JonCucharaPlata() : PocketItem(POCKET_ITEM_CUCHARA_PLATA, POCKET_ITEMTYPE_ARMA) constructor {
	buy = 6_000;
	sell= 1_000;
		
	setStat(
		STAT_FUERZA, 14, MALL_NUMTYPE.REAL, STAT_FESPECIAL, 17, MALL_NUMTYPE.REAL,
		STAT_PODER , 22, MALL_NUMTYPE.REAL
		);
}
	
// LVL 24 -> 30
#macro POCKET_ITEM_TENEDOR_PLATA "POCKET.JON.TENEDOR.PLATA"
function IT_JonTenedorPlata() : PocketItem(POCKET_ITEM_CUCHARA_HIERRO, POCKET_ITEMTYPE_ARMA) constructor {
	buy = 6_000;
	sell= 1_200;
		
	setStat(
		STAT_FUERZA   , 22, MALL_NUMTYPE.REAL,
		STAT_DEFENSA  ,  5, MALL_NUMTYPE.REAL, STAT_DESPECIAL, -16, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 18, MALL_NUMTYPE.REAL,
		STAT_PODER, 25, MALL_NUMTYPE.REAL,
		);
}
	
// Mezcla de tenedor y cuchara
// LVL 30 -> 36
#macro POCKET_ITEM_CUCHARA_TENEDOR_HIERRO "POCKET.JON.CUCHARA_TENEDOR.HIERRO"
function IT_JonCTHierro() : PocketItem(POCKET_ITEM_CUCHARA_TENEDOR_HIERRO, POCKET_ITEMTYPE_ARMA) constructor {
	buy = 6_000;
	sell= 1_600;
	
	setStat(
		STAT_FUERZA   , 16, MALL_NUMTYPE.REAL, STAT_DEFENSA  , 4, MALL_NUMTYPE.REAL,
		STAT_FESPECIAL, 14, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 2, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 11, MALL_NUMTYPE.REAL, 
		STAT_PODER    , 26, MALL_NUMTYPE.REAL 
		);
}

// LVL 36 -> 42
#macro POCKET_ITEM_CUCHARA_TENEDOR_PLATA "POCKET.JON.CUCHARA_TENEDOR.PLATA"
function IT_JonCTPlata() : PocketItem(POCKET_ITEM_CUCHARA_TENEDOR_PLATA, POCKET_ITEMTYPE_ARMA) constructor {
	buy  = 6_000;
	sell = 1_600;

	setStat(
		STAT_FUERZA ,   20, MALL_NUMTYPE.REAL, STAT_DEFENSA  , 10, MALL_NUMTYPE.REAL,
		STAT_FESPECIAL, 20, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 10, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 16, MALL_NUMTYPE.REAL,
		STAT_PODER    , 30, MALL_NUMTYPE.REAL,
		);
}
	
// LVL 42 -> 48 De ahora empezar a restar algunas estadisticas
#macro POCKET_ITEM_CUCHARON_HIERRO "POCKET.JON.CUCHARON.HIERRO" 
function IT_JonCucharonHierro() : PocketItem(POCKET_ITEM_CUCHARON_HIERRO, POCKET_ITEMTYPE_ARMA) constructor {
	buy  = 6_000;
	sell = 1_600;
		
	setStat(
		STAT_FUERZA   ,  25, MALL_NUMTYPE.REAL, STAT_DEFENSA  , 17, MALL_NUMTYPE.REAL,
		STAT_FESPECIAL,  25, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 17, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD,  21, MALL_NUMTYPE.REAL, 
		STAT_PODER    ,  37, MALL_NUMTYPE.REAL
		);
}
	
// LVL 48 -> 54 De ahora empezar a restar algunas estadisticas
#macro POCKET_ITEM_CUCHARON_PLATA "POCKET.JON.CUCHARON.PLATA" 
function IT_JonCucharonPlata() : PocketItem(POCKET_ITEM_CUCHARON_PLATA, POCKET_ITEMTYPE_ARMA) constructor {
	buy = 6_000; sell = 1_600; 
		
	setStat(
		STAT_FUERZA   ,  25, MALL_NUMTYPE.REAL, STAT_DEFENSA  , 17, MALL_NUMTYPE.REAL,
		STAT_FESPECIAL,  25, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 17, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD,  21, MALL_NUMTYPE.REAL, 
		STAT_PODER    ,  37, MALL_NUMTYPE.REAL
		);
}

#endregion

#region -- Gabi Items
// LVL 50 -> 56
#macro POCKET_ITEM_GUANTES_BLANCOS "POCKET.GABI.GUANTES.BLANCOS" // Enfoque especial
function IT_GabiGuantesBlancos() : PocketItem(POCKET_ITEM_GUANTES_BLANCOS, POCKET_ITEMTYPE_ARMA) constructor 
{
	buy=1_020; sell=104;
	setStat(
		STAT_FUERZA, 18, MALL_NUMTYPE.REAL,  STAT_FESPECIAL, 28, MALL_NUMTYPE.REAL,
		STAT_PODER , 43, MALL_NUMTYPE.REAL
	);
}// 4 6 3 
// LVL 50 -> 56
#macro POCKET_ITEM_GUANTES_NEGROS "POCKET.GABI.GUANTES.NEGROS" // Enfoque fisico
function IT_GabiGuantesNegros() : PocketItem(POCKET_ITEM_GUANTES_NEGROS, POCKET_ITEMTYPE_ARMA) constructor 
{
	buy=2_200; sell=500;
		
	setStat(
		STAT_FUERZA   , 28, MALL_NUMTYPE.REAL, 
		STAT_VELOCIDAD, 16, MALL_NUMTYPE.REAL,
		STAT_PODER    , 38, MALL_NUMTYPE.REAL
	)
} // 4 6 3
	
// LVL 62 -> 68
#macro POCKET_ITEM_GUANTES_ROJOS "POCKET.GABI.GUANTES.ROJOS"
function IT_GabiGuantesRojos() : PocketItem(POCKET_ITEM_GUANTES_ROJOS, POCKET_ITEMTYPE_ARMA, 2800, 500) constructor 
{
	setStat(
		STAT_FUERZA   ,  22, MALL_NUMTYPE.REAL, STAT_FESPECIAL, 34, MALL_NUMTYPE.REAL,
		STAT_DEFENSA  , -10, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD,  13, MALL_NUMTYPE.REAL,
		STAT_PODER    ,  46, MALL_NUMTYPE.REAL
		);
}// -3 4 
// LVL 62 -> 68
#macro POCKET_ITEM_GUANTES_VERDES "POCKET.GABI.GUANTES.VERDES"
function IT_GabiGuantesVerdes() : PocketItem(POCKET_ITEM_GUANTES_VERDES, POCKET_ITEMTYPE_ARMA, 2620, 100) constructor
{
	setStat(
		STAT_FUERZA   , 32, MALL_NUMTYPE.REAL, STAT_DEFENSA, 10, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 22, MALL_NUMTYPE.REAL,
		STAT_PODER    , 41, MALL_NUMTYPE.REAL
		);
}// 4 
	
// LVL 73 -> 78
#macro POCKET_ITEM_GUANTES_CUERO "POCKET.GABI.GUANTES.CUERO"
function IT_GabiGuantesCuero() : PocketItem(POCKET_ITEM_GUANTES_CUERO, POCKET_ITEMTYPE_ARMA, 2620, 100) constructor
{
	setStat(
		STAT_FUERZA   , 26, MALL_NUMTYPE.REAL, STAT_DEFENSA  , -13, MALL_NUMTYPE.REAL,
		STAT_FESPECIAL, 38, MALL_NUMTYPE.REAL, STAT_DESPECIAL,  13, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 15, MALL_NUMTYPE.REAL,
		STAT_PODER    , 40, MALL_NUMTYPE.REAL
		);
}

#endregion

#region -- Fernando Items
// LVL 40 -> 47
#macro POCKET_ITEM_MONEDA_988 "POCKET.FEN.MONEDA.988"
function IT_FernMoneda988() : PocketItem(POCKET_ITEM_MONEDA_988, POCKET_ITEMTYPE_ARMA) constructor 
{	
	setStat(
		STAT_FUERZA , 20, MALL_NUMTYPE.REAL,
		STAT_CRITICO, 10, MALL_NUMTYPE.REAL,
		STAT_PODER  , 32, MALL_NUMTYPE.REAL
		);
}
	
// LVL 47 - 54
#macro POCKET_ITEM_MONEDA_942 "POCKET.FEN.MONEDA.942"
function IT_FernMoneda942() : PocketItem(POCKET_ITEM_MONEDA_942, POCKET_ITEMTYPE_ARMA) constructor
{
	setStat(
		STAT_FUERZA   , 24, MALL_NUMTYPE.REAL,
		STAT_DESPECIAL, 11, MALL_NUMTYPE.REAL,
		STAT_CRITICO, 11, MALL_NUMTYPE.REAL,
		STAT_PODER  , 35, MALL_NUMTYPE.REAL
		);
}
	
// LVL 61 - 68
#macro POCKET_ITEM_MONEDA_NIQUEL "POCKET.FEN.MONEDA.NIQUEL"
function IT_FernMonedaNiquel() : PocketItem(POCKET_ITEM_MONEDA_NIQUEL, POCKET_ITEMTYPE_ARMA) constructor
{
	setStat(
		STAT_FUERZA   , 30, MALL_NUMTYPE.REAL, STAT_DEFENSA, 8, MALL_NUMTYPE.REAL,
		STAT_DESPECIAL,  9, MALL_NUMTYPE.REAL,
		STAT_CRITICO, 13, MALL_NUMTYPE.REAL,
		STAT_PODER  , 38, MALL_NUMTYPE.REAL
		);
}
	
// LVL 68 - 75
#macro POCKET_ITEM_MONEDA_PLATA "POCKET.FEN.MONEDA.PLATA"
function IT_FernMonedaPlata() : PocketItem(POCKET_ITEM_MONEDA_PLATA, POCKET_ITEMTYPE_ARMA) constructor
{
	setStat(
		STAT_FUERZA   , 36, MALL_NUMTYPE.REAL, STAT_DEFENSA, 16, MALL_NUMTYPE.REAL,
		STAT_DESPECIAL, 16, MALL_NUMTYPE.REAL,
		STAT_CRITICO, 14, MALL_NUMTYPE.REAL,
		STAT_PODER  , 41, MALL_NUMTYPE.REAL
		);
}
	
// LVL 75 - 82
#macro POCKET_ITEM_MONEDA_ORO "POCKET.FEN.MONEDA.ORO"
function IT_FernMonedaOro() : PocketItem(POCKET_ITEM_MONEDA_ORO, POCKET_ITEMTYPE_ARMA) constructor
{
	setStat(
		STAT_FUERZA   , 42, MALL_NUMTYPE.REAL, STAT_DEFENSA, 24, MALL_NUMTYPE.REAL,
		STAT_DESPECIAL, 25, MALL_NUMTYPE.REAL,
		STAT_CRITICO, 16, MALL_NUMTYPE.REAL,
		STAT_PODER  , 44, MALL_NUMTYPE.REAL
		);
}

#endregion


#region -- Equipo para el cuerpo
// -- Polera y Camisa 
// Polera: Defensa y Velocidad
// Camisa: Defensa y Despecial
	
// LVL 1 -> 4 (Jon, Susana)
#macro POCKET_ITEM_CAMISA_COLEGIO "POCKET.CUE.CAMISA.COLEGIO"
function IT_CPCamisaColegia() : PocketItem(POCKET_ITEM_CAMISA_COLEGIO, POCKET_ITEMTYPE_ARMDU1, 200,80) constructor 
{
	setStat(STAT_DEFENSA,6,MALL_NUMTYPE.REAL,  STAT_DESPECIAL,3,MALL_NUMTYPE.REAL);
} // Sumar: 6 3
// LVL 1 -> 4 (Jon, Susana)
#macro POCKET_ITEM_POLERA_COLEGIO "POCKET.POLERA.COLEGIO"
function IT_CPPoleraColegio() : PocketItem(POCKET_ITEM_POLERA_COLEGIO, POCKET_ITEMTYPE_ARMDU1, 200,80) constructor
{
	setStat(STAT_DEFENSA,5,MALL_NUMTYPE.REAL,  STAT_VELOCIDAD,4,MALL_NUMTYPE.REAL);
}; // Sumar: 5 7
	
// LVL 4 -> 9 (Jon, Susana)
#macro POCKET_ITEM_CAMISA_CUADROS "POCKET.CAMISA.CUADROS"
function IT_CPCamisaCuadros() : PocketItem(POCKET_ITEM_CAMISA_CUADROS, POCKET_ITEMTYPE_ARMDU1, 200,80) constructor
{
	setStat(STAT_DEFENSA,12,MALL_NUMTYPE.REAL,  STAT_DESPECIAL,6,MALL_NUMTYPE.REAL);
};
// LVL 4 -> 9 (Jon, Susana)
#macro POCKET_ITEM_POLERA_COLORIDA "POCKET.POLERA.COLORIDA"
function IT_CPPoleraColorida() : PocketItem(POCKET_ITEM_POLERA_COLORIDA, POCKET_ITEMTYPE_ARMDU1, 200,80) constructor
{
	setStat(STAT_DEFENSA,10,MALL_NUMTYPE.REAL,  STAT_VELOCIDAD,7,MALL_NUMTYPE.REAL);
}
	
// LVL 9 -> 14 (Jon, Susana)
#macro POCKET_ITEM_CAMISA_VEBRES "POCKET.CAMISA.VEBRES" // Vebres marca famosa de ropa
function IT_CPCamisaVebres() : PocketItem(POCKET_ITEM_CAMISA_VEBRES, POCKET_ITEMTYPE_ARMDU1, 200,80) constructor
{
	setStat(STAT_DEFENSA,18,MALL_NUMTYPE.REAL,  STAT_DESPECIAL,9,MALL_NUMTYPE.REAL);
}; // Sumar: 6 3
// LVL 9 -> 14 (Jon, Susana)
#macro POCKET_ITEM_POLERA_VEBRES "POCKET.POLERA.VEBRES"
function IT_CPPoleraVebres() : PocketItem(POCKET_ITEM_POLERA_VEBRES, POCKET_ITEMTYPE_ARMDU1, 200,80) constructor
{
	setStat(STAT_DEFENSA,15,MALL_NUMTYPE.REAL,  STAT_VELOCIDAD,10,MALL_NUMTYPE.REAL);
}; // Sumar: 5 7
	
// LVL 40 -> 46 (Gabi, Fernando)
#macro POCKET_ITEM_PLATINAS_HIERRO "POCKET.PLATINAS.HIERRO" 
function IT_CPPlatinasHierro() : PocketItem(POCKET_ITEM_PLATINAS_HIERRO, POCKET_ITEMTYPE_ARMDU1, 530,200) constructor
{
	setStat(
		STAT_DEFENSA  , 30, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 15, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, -6, MALL_NUMTYPE.REAL,
		STAT_PODER, 4, MALL_NUMTYPE.REAL 
		);
};// 5 5 -4 1
// LVL 40 -> 46 (Gabi, Fernando)
#macro POCKET_ITEM_PLATINAS_ECTO "POCKET.PLATINAS.ECTO"
function IT_CPPlatinasEcto() : PocketItem(POCKET_ITEM_PLATINAS_ECTO, POCKET_ITEMTYPE_ARMDU1, 53,200) constructor
{
	setStat(
		STAT_DEFENSA, 14, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 30, MALL_NUMTYPE.REAL,
		STAT_PODER, 3, MALL_NUMTYPE.REAL
		);
}; // 5 5 1
	
// LVL 46 -> 52 (Gabi, Fernando)
#macro POCKET_ITEM_CHALECO_BLINDADO "POCKET.CHALECO.BLINDADO"
function IT_CPChalecoBlindado() : PocketItem(POCKET_ITEM_CHALECO_BLINDADO, POCKET_ITEMTYPE_ARMDU1, 530,200) constructor
{
	setStat(
		STAT_DEFENSA  ,  35, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 20, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, -10, MALL_NUMTYPE.REAL,
		STAT_PODER, 5, MALL_NUMTYPE.REAL 
		);
};
// LVL 46 -> 52 (Gabi, Fernando)
#macro POCKET_ITEM_CHALECO_IMBUIDO "POCKET.CHALECO.IMBUIDO"
function IT_CPChalecoImbuido() : PocketItem(POCKET_ITEM_CHALECO_IMBUIDO, POCKET_ITEMTYPE_ARMDU1, 53,200) constructor
{
	setStat(
		STAT_DEFENSA, 19, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 30, MALL_NUMTYPE.REAL,
		STAT_PODER  ,  4, MALL_NUMTYPE.REAL
		);
};
	
// LVL 52 -> 59 (Gabi, Fernando)
#macro POCKET_ITEM_CHALECO_REFORZADO "POCKET.CHALECO.REFORZADO"
function IT_CPChalecoReforzado() : PocketItem(POCKET_ITEM_CHALECO_REFORZADO, POCKET_ITEMTYPE_ARMDU1, 530,200) constructor
{
	setStat(
		STAT_DEFENSA  ,  40, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 25, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, -14, MALL_NUMTYPE.REAL,
		STAT_PODER, 6, MALL_NUMTYPE.REAL
		);
}; // 5 5 -4 1
// LVL 52 -> 59 (Gabi, Fernando)
#macro POCKET_ITEM_CHALECO_TRATADO "POCKET.CHALECO.TRATADO"
function IT_CPChalecoTratado() : PocketItem(POCKET_ITEM_CHALECO_TRATADO, POCKET_ITEMTYPE_ARMDU1, 530, 200) constructor
{
	setStat(
		STAT_DEFENSA, 24, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 35, MALL_NUMTYPE.REAL,
		STAT_PODER  ,  5, MALL_NUMTYPE.REAL
		);
}; // 5 5 1
	
// LVL 59 -> 66 (Gabi, Fernando)
#macro POCKET_ITEM_CHALECO_ELDRO "POCKET.CHALECO.ELDRO" // ELDRO fabricante de equipo para policias, militares, etc
function IT_CPChalecoEldro() : PocketItem(POCKET_ITEM_CHALECO_ELDRO, POCKET_ITEMTYPE_ARMDU1, 530,200) constructor
{
	setStat(
		STAT_DEFENSA  , 45, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 30, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD,-18, MALL_NUMTYPE.REAL,
		STAT_PODER, 7, MALL_NUMTYPE.REAL
		);
};
// LVL 59 -> 66 (Gabi, Fernando)
#macro POCKET_ITEM_CHALECO_ECTO "POCKET.CHALECO.ECTO"
function IT_CPChalecoEcto() : PocketItem(POCKET_ITEM_CHALECO_ECTO, POCKET_ITEMTYPE_ARMDU1, 53,200) constructor
{
	setStat(
		STAT_DEFENSA, 29, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 40, MALL_NUMTYPE.REAL,
		STAT_PODER  ,  6, MALL_NUMTYPE.REAL
		);
};
// LVL 66 -> 73 (Gabi, Fernando)
#macro POCKET_ITEM_CHALECO_SQUAD "POCKET.CHALECO.SQUAD" // SQUAD equipo para amenazas "normales" peligrosas
function IT_CPChalecoSquad() : PocketItem(POCKET_ITEM_CHALECO_SQUAD, POCKET_ITEMTYPE_ARMDU1,  530,200) constructor 
{
	setStat(
		STAT_DEFENSA  , 50, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 35, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD,-22, MALL_NUMTYPE.REAL,
		STAT_PODER, 8, MALL_NUMTYPE.REAL
		);
};
// LVL 66 -> 73 (Gabi, Fernando)
#macro POCKET_ITEM_CHALECO_ECTLDRO "POCKET.CHALECO.ECTLDRO" // Un chaleco Eldro imbuido en ecto
function IT_CPChalecoEctldro() : PocketItem(POCKET_ITEM_CHALECO_ECTLDRO, POCKET_ITEMTYPE_ARMDU1, 53,200) constructor
{
	setStat(
		STAT_DEFENSA, 34, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 45, MALL_NUMTYPE.REAL,
		STAT_PODER  ,  6, MALL_NUMTYPE.REAL
		);
};
	
// LVL 73 -> 80 (Gabi, Fernando)
#macro POCKET_ITEM_CHALECO_MILITAR "POCKET.CHALECO.MILITAR"
function IT_CPChalecoMilitar() : PocketItem(POCKET_ITEM_CHALECO_SQUAD, POCKET_ITEMTYPE_ARMDU1, 530,200) constructor
{
	setStat(
		STAT_DEFENSA  , 60, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 45, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD,-30, MALL_NUMTYPE.REAL,
		STAT_PODER, 10, MALL_NUMTYPE.REAL
		);
};
// LVL 73 -> 80 (Gabi, Fernando)
#macro POCKET_ITEM_CHALECO_MUERTO "POCKET.CHALECO.MUERO" // "Muerto" se refiere a que un espiritu lo posee
function IT_CPChalecoMuero() : PocketItem(POCKET_ITEM_CHALECO_ECTLDRO, POCKET_ITEMTYPE_ARMDU1, 53,200) constructor
{
	setStat(
		STAT_DEFENSA, 44, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 55, MALL_NUMTYPE.REAL,
		STAT_PODER  ,  8, MALL_NUMTYPE.REAL
		);
};

#endregion

#region -- Equipo para los pies
// Zapatos
// LVL 8 -> 14 (Jon, Susana)
#macro POCKET_ITEM_ZAPATOS_MANCHADOS "POCKET.ZAPATOS.MANCHADOS"
function IT_PSZapatosManchados() : PocketItem(POCKET_ITEM_ZAPATOS_MANCHADOS,POCKET_ITEMTYPE_ACCES2,  320,130) constructor 
{
	setStat(
		STAT_DEFENSA,   7, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 9, MALL_NUMTYPE.REAL
		);
};
	
// LVL 14 -> 18 (Jon, Susana)
#macro POCKET_ITEM_ZAPATOS_GENERICOS "POCKET.ZAPATOS.GENERICOS"
function IT_PSZapatos() : PocketItem(POCKET_ITEM_ZAPATOS_GENERICOS,POCKET_ITEMTYPE_ACCES2,  320,130) constructor
{
	setStat(
		STAT_DEFENSA,   12, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 14, MALL_NUMTYPE.REAL
		);
};
	
// LVL 18 -> 24 (Jon, Susana)
#macro POCKET_ITEM_ZAPATOS_IMITACION "POCKET.ZAPATOS.IMITACION"
function IT_PSZapatosImitacion() : PocketItem(POCKET_ITEM_ZAPATOS_IMITACION,POCKET_ITEMTYPE_ACCES2,  320,130) constructor
{
	setStat(
		STAT_DEFENSA,   17, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 19, MALL_NUMTYPE.REAL
		);
};
	
// Zapatillas
// LVL 4 -> 8 (Jon, Susana)
#macro POCKET_ITEM_ZAPATILLAS_MANCHADAS "POCKET.ZAPATILLAS.MANCHADAS"
function IT_PSZapatillasManchadas() : PocketItem(POCKET_ITEM_ZAPATILLAS_MANCHADAS,POCKET_ITEMTYPE_ACCES2,  320,130) constructor 
{
	setStat(STAT_VELOCIDAD, 11, MALL_NUMTYPE.REAL);
}
	
// LVL 8 -> 14 (Jon, Susana)
#macro POCKET_ITEM_ZAPATILLAS_GASTADAS "POCKET.ZAPATILLAS.GASTADAS"
function IT_PSZapatillasGastadas() : PocketItem(POCKET_ITEM_ZAPATILLAS_GASTADAS,POCKET_ITEMTYPE_ACCES2,  320,130) constructor
{
	setStat(
		STAT_DEFENSA,    2, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 17, MALL_NUMTYPE.REAL
		);
};
	
// LVL 14 -> 18 (Jon, Susana)
#macro POCKET_ITEM_ZAPATILLAS "POCKET.ZAPATILLAS"
function IT_PSZapatillas() : PocketItem(POCKET_ITEM_ZAPATILLAS,POCKET_ITEMTYPE_ACCES2,  320,130) constructor
{
	setStat(
		STAT_DEFENSA,    4, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 23, MALL_NUMTYPE.REAL
		);
};
	
// LVL 18 -> 24 (Jon, Susana)
#macro POCKET_ITEM_ZAPATILLAS_IMITACION "POCKET.ZAPATILLAS.IMITACION"
function IT_PSZapatillasImitacion() : PocketItem(POCKET_ITEM_ZAPATILLAS_IMITACION,POCKET_ITEMTYPE_ACCES2,  320,130) constructor
{
	setStat(
		STAT_DEFENSA,    6, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 29, MALL_NUMTYPE.REAL
		);
};
// LVL 36 -> 40 (Jon, Fernando, Gabi)
#macro POCKET_ITEM_ZAPATILLAS_SEGURIDAD "POCKET.ZAPATILLAS.SEGURIDAD"
function IT_PSZapatillasSeguridad() : PocketItem(POCKET_ITEM_ZAPATILLAS_SEGURIDAD,POCKET_ITEMTYPE_ACCES2,  650,150) constructor
{
	setStat(
		STAT_DEFENSA,   18, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 26, MALL_NUMTYPE.REAL
		);
};	

// Botas
// LVL 24 -> 36 (Gabi, Fernando)
#macro POCKET_ITEM_BOTAS "POCKET.BOTAS"
function IT_PSBotas() : PocketItem(POCKET_ITEM_BOTAS,POCKET_ITEMTYPE_ACCES2,  650,150) constructor
{
	setStat(
		STAT_DEFENSA,  16, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 4, MALL_NUMTYPE.REAL
		);
};
	
// LVL 24 -> 36 (Jon, Gabi, Fernando)
#macro POCKET_ITEM_BOTAS_LIGERAS "POCKET.BOTAS.LIGERAS"
function IT_PSBotasLigeras() : PocketItem(POCKET_ITEM_BOTAS_LIGERAS,POCKET_ITEMTYPE_ACCES2,  650,150) constructor
{
	setStat(
		STAT_DEFENSA,   8, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 9, MALL_NUMTYPE.REAL
		);
};
	
// LVL 30 -> 42 (Gabi, Fernando)
#macro POCKET_ITEM_BOTAS_ESCENCIA "POCKET.BOTAS.ESCENCIA"
function IT_PSBotasEscencia() : PocketItem(POCKET_ITEM_BOTAS_ESCENCIA,POCKET_ITEMTYPE_ACCES2,  650,150) constructor
{
	setStat(
		STAT_DEFENSA,   12, MALL_NUMTYPE.REAL,
		STAT_DESPECIAL, 14, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD,  4, MALL_NUMTYPE.REAL
		);
};	

#endregion

#region -- Equipo para accesorios 1
// LVL 1 -> 8 (Jon, Susana)
#macro POCKET_ITEM_GORRO_LANA "POCKET.ACC1.GORRO_DE_LANA"
function IT_ACCGorroLana() : PocketItem(POCKET_ITEM_GORRO_LANA, POCKET_ITEMTYPE_ACCES1, 220, 10) constructor
{
	setStat(STAT_DEFENSA, 2, MALL_NUMTYPE.REAL);
}
	
// LVL 1 -> 8 (Jon, Susana)
#macro POCKET_ITEM_CRUZ "POCKET.ACC1.CRUZ"
function IT_ACCCruz() : PocketItem(POCKET_ITEM_CRUZ, POCKET_ITEMTYPE_ACCES1, 220, 0) constructor 
{
	setStat(STAT_DEFENSA,3,MALL_NUMTYPE.REAL,  STAT_DESPECIAL,3,MALL_NUMTYPE.REAL);
}
	
// LVL 1 -> 8 (Jon)
#macro POCKET_ITEM_DIBUJO "POCKET.ACC1.DIBUJO"
function IT_ACCDibujo() : PocketItem(POCKET_ITEM_DIBUJO,  POCKET_ITEMTYPE_ACCES1,  100, 2) constructor
{
	setStat(STAT_PODER, 2, MALL_NUMTYPE.REAL)
		
	/// @desc En 2 turnos aumenta el ataque especial en un 10%
	/// @param {real} turn
	/// @param {struct.PartyEntity} caster
	static turnStart = function(turn, entity)
	{
		if (turn == 2) {
			entity.controlEffectAdd(new DK_ACCDibujo());
		}		
	}
}
	
// LVL 1 -> 8 (Jon, Susana)
#macro POCKET_ITEM_ZAPATOS_GASTADOS "POCKET.ZAPATOS.GASTADOS"
function IT_ACCZapatosGastados() : PocketItem(POCKET_ITEM_ZAPATOS_GASTADOS, POCKET_ITEMTYPE_ACCES1, 320, 130) constructor
{
	setStat(
		STAT_DEFENSA  , 1, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 1, MALL_NUMTYPE.REAL
		);
}
	
/*  */
	
// LVL 30 - 40
#macro POCKET_ITEM_AMULETO_GALLO "POCKET.ACC1.AMULETO.GALLO"
function IT_ACCAnilloGallo() : PocketItem(POCKET_ITEM_AMULETO_GALLO, POCKET_ITEMTYPE_ACCES1, 600, 500) constructor
{
	setStat(STAT_VELOCIDAD, 18, MALL_NUMTYPE.REAL);
}
	
// LVL 30 - 40
#macro POCKET_ITEM_ANILLO_TORO "POCKET.ACC1.ANILLO.TORO"
function IT_ACCAnilloToro() : PocketItem(POCKET_ITEM_ANILLO_TORO, POCKET_ITEMTYPE_ACCES1, 600, 500) constructor
{
	setStat(
		STAT_FUERZA ,    8, MALL_NUMTYPE.REAL, 
		STAT_DEFENSA,   24, MALL_NUMTYPE.REAL,  STAT_DESPECIAL,18,MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, -8, MALL_NUMTYPE.REAL,
		STAT_PODER,3,MALL_NUMTYPE.REAL
		);
}
	
// LVL 30 - 40
#macro POCKET_ITEM_ANILLO_CABRA "POCKET.ACC1.ANILLO.CABRA"
function IT_ACCAnilloCabra() : PocketItem(POCKET_ITEM_ANILLO_CABRA, POCKET_ITEMTYPE_ACCES1, 600, 500) constructor
{
	setStat(STAT_FUERZA,14,MALL_NUMTYPE.REAL,  STAT_VELOCIDAD,18,MALL_NUMTYPE.REAL);
}
	
// LVL 40 - 50
#macro POCKET_ITEM_ANILLO_CABALLO "POCKET.ACC1.ANILLO.CABALLO"
function IT_ACCAnilloCaballo() : PocketItem(POCKET_ITEM_ANILLO_CABALLO, POCKET_ITEMTYPE_ACCES1, 600, 500) constructor
{
	setStat(STAT_DEFENSA,20,MALL_NUMTYPE.REAL,  STAT_DESPECIAL,20,MALL_NUMTYPE.REAL);
}

#endregion

#region -- Equipo para objetos etc
#macro POCKET_ITEM_ECTOLITA "POCKET.OBJ.ECTOLITA"
function IT_DropsEctolita() : PocketItem(POCKET_ITEM_ECTOLITA, POCKET_ITEMTYPE_ETC, 0,50) constructor {}
	

#endregion


#region -- Equipo para los enemigos
// Para Floating Head 01
function IT_EnemyMiradaMiedo() : PocketItem("POCKET.ENE.MIRADA_DE_MIEDO", POCKET_ITEMTYPE_ENEMY) constructor
{
	buy=999_999; sell=0;
	setStat(STAT_PODER, 32);
}
	
// Para Floating Head 02
function IT_EnemyMiradaTemor() : PocketItem("POCKET.ENE.MIRADA_DE_TEMOR", POCKET_ITEMTYPE_ENEMY) constructor
{
	buy = 999_999; sell=0
	setStat(
		STAT_VELOCIDAD, 20, MALL_NUMTYPE.REAL,
		STAT_PODER    , 36, MALL_NUMTYPE.REAL
		);
}
	
// Para Dead Bird
function IT_EnemyAlasEcto() : PocketItem("POCKET.ENE.ALAS_DE_ECTO", POCKET_ITEMTYPE_ENEMY) constructor
{
	buy = 999_999; sell=0;
	setStat(STAT_PODER, 55);
}
	
// Para Dead Bird
function IT_EnemyAlasPeto() : PocketItem("POCKET.ENE.ALAS_DE_PETO", POCKET_ITEMTYPE_ENEMY) constructor
{
	buy = 999_999; sell=0;
	setStat(
		STAT_PODER,     45,
		STAT_DESPECIAL, 30
		);
}
	
// Para Zombie
function IT_EnemyDBlood() : PocketItem("POCKET.ENE.BLOOD", POCKET_ITEMTYPE_ENEMY) constructor
{
	buy = 999_999; sell=0;
	setStat(STAT_PODER, 55);
}

#endregion

