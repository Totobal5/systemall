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
	pocket_create_bag(POCKET_BAG, new function() : PocketBag() constructor {
		order = array_create_ext(3, function() {return array_create(0); });
		items = {consumibles: {}, equipos: {}, etc: {} };
		
		/// @param {Struct.PocketItem} item
		static set = function(_item, _count, _index, _vars) 
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
		static get = function(_key) 
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
		static add = function(_item, _count)
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
		static remove = function(_key)
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
		static updateItems = function() 
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

		static save = function() 
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

		static load = function(_l) 
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
	}());


	#region -- Items
	// -- Recuperar EN
	#macro POCKET_ITEM_MANZANA_ROJA "POCKET.MANZANA.ROJA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_MANZANA_ROJA, POCKET_ITEMTYPE_CONSM) constructor 
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
	
	#macro POCKET_ITEM_MANZANA_VERDE "POCKET.MANZANA.VERDE"
	pocket_create(new function() : PocketItem(POCKET_ITEM_MANZANA_ROJA, POCKET_ITEMTYPE_CONSM) constructor
	{
		buy = 240; sell = 80;
		
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
		restore     = 45;
		restoreType = MALL_NUMTYPE.PERCENT;
		restoreNumtarget = 5;
	}());
	
	#macro POCKET_ITEM_MANZANA_LADY "POCKET.MANZANA.VERDE"
	pocket_create(new function() : PocketItem(POCKET_ITEM_MANZANA_LADY, POCKET_ITEMTYPE_CONSM) constructor 
	{
		buy=480; sell=80;
		
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
		restore     = 63;
		restoreType = MALL_NUMTYPE.PERCENT;
		restoreNumtarget = 5;	
	}());
	
	// -- Recuperar EPM
	#macro POCKET_ITEM_AGUA_MINERAL "POCKET.AGUA.MINERAL"	
	pocket_create(new function() : PocketItem(POCKET_ITEM_AGUA_MINERAL, POCKET_ITEMTYPE_CONSM) constructor
	{
		buy = 80; sell=10;
		
		/// @param {struct.PartyEntity} caster
		/// @param {struct.PartyEntity} target
		static use = function(caster, target) 
		{
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
		
	}() );
	
	#macro POCKET_ITEM_BEBIDA "POCKET.BEBIDA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_BEBIDA, POCKET_ITEMTYPE_CONSM) constructor
	{
		buy = 160; sell = 20;
		
		/// @param {struct.PartyEntity} caster
		/// @param {struct.PartyEntity} target
		static use = function(caster, target) 
		{
			var _return = {result: false, restore: 0};
			var _epm =    target.statGet(STAT_EPM);
			// From item
			var _value  = target.statAdd(STAT_EPM, restore, type, numtarget);
			_return.result  = (_value != 0);
			_return.restore = _value;
			
			return (_return);
		}
		
		restore =   30; 
		type =      MALL_NUMTYPE.PERCENT;
		numtarget = 5;					
	}());
	
	#macro POCKET_ITEM_BEBIDA_ENERGETICA "POCKET.BEBIDA.ENERGETICA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_BEBIDA, POCKET_ITEMTYPE_CONSM) constructor
	{
		buy = 320; sell = 40;
		
		/// @param {struct.PartyEntity} caster
		/// @param {struct.PartyEntity} target
		static use = function(caster, target) 
		{
			var _return = {result: false, restore: 0};
			var _epm =    target.statGet(STAT_EPM);
			// From item
			var _value  = target.statAdd(STAT_EPM, restore, type, numtarget);
			_return.result  = (_value != 0);
			_return.restore = _value;
			
			return (_return);
		}
		
		restore =   45; 
		type =      MALL_NUMTYPE.PERCENT;
		numtarget = 5;					
	}());

	// -- Recuperar EN y EMP
	#macro POCKET_ITEM_PERLA_AZUL "POCKET.PERLA.AZUL"
	pocket_create(new function() : PocketItem(POCKET_ITEM_PERLA_AZUL, POCKET_ITEMTYPE_CONSM) constructor
	{
		buy=300; sell=10;
		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static use = function(caster, target) 
		{
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
	}());

	#macro POCKET_ITEM_PERLA_ROJA "POCKET.PERLA.ROJA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_PERLA_ROJA, POCKET_ITEMTYPE_CONSM) constructor
	{
		buy = 600; sell = 100;

		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static use = function(caster, target) 
		{
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
		
		// 
		restoreEN  = 24;
		restoreEPM = 24;
		
		numtype = MALL_NUMTYPE.PERCENT;
		numtarg = 0;		
	}());

	#macro POCKET_ITEM_PERLA_VERDE "POCKET.PERLA.VERDE"
	pocket_create(new function() : PocketItem(POCKET_ITEM_PERLA_ROJA, POCKET_ITEMTYPE_CONSM) constructor
	{
		buy = 1200; sell = 200;

		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static use = function(caster, target) 
		{
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
		
		// 
		restoreEN  = 48;
		restoreEPM = 36;
		
		numtype = MALL_NUMTYPE.PERCENT;
		numtarg = 0;		
	}());
	
	// -- Revivir
	#macro POCKET_ITEM_ESCENCIA_AZUL "POCKET.ESCENCIA.AZUL"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ESCENCIA_AZUL, POCKET_ITEMTYPE_CONSM) constructor 
	{
		buy = 1200; sell = 150;
		
		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static canUse = function(caster, target) 
		{
			return (!target.controlState(STATE_VIVO) && target.statGet(STAT_EN).control <= 0); 
		}

		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static use = function(caster, target) 
		{
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
	}());
	
	#macro POCKET_ITEM_ESCENCIA_ROJA "POCKET.ESCENCIA.ROJA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ESCENCIA_ROJA, POCKET_ITEMTYPE_CONSM) constructor 
	{
		buy = 2560; sell = 600;
		
		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static canUse = function(caster, target) 
		{
			return (!target.controlState(STATE_VIVO) && target.statGet(STAT_EN).control <= 0); 
		}

		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static use = function(caster, target) 
		{
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
		
		restore = 45;
		numtype = MALL_NUMTYPE.PERCENT;
		numtarg = STAT_NUMTARG.CONTROL;
	}());

	#macro POCKET_ITEM_ESCENCIA_VERDE "POCKET.ESCENCIA.VERDE"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ESCENCIA_VERDE, POCKET_ITEMTYPE_CONSM) constructor 
	{
		buy = 5600; sell = 1200;
		
		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static canUse = function(caster, target) 
		{
			return (!target.controlState(STATE_VIVO) && target.statGet(STAT_EN).control <= 0); 
		}

		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static use = function(caster, target) 
		{
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
		
		restore = 60;
		numtype = MALL_NUMTYPE.PERCENT;
		numtarg = STAT_NUMTARG.CONTROL;
	}());


	#endregion

	#region -- Jon Items
	// LVL 1 -> 6
	#macro POCKET_ITEM_CUCHARITA "POCKET.JON.CUCHARITA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CUCHARITA, POCKET_ITEMTYPE_ARMA, 150,80) constructor 
	{
		setStat(STAT_PODER, 12, MALL_NUMTYPE.REAL);	
	}());
	
	// LVL 6 -> 12
	#macro POCKET_ITEM_CUCHARA_PLASTICA "POCKET.JON.CUCHARA.PLASTICA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CUCHARA_PLASTICA, POCKET_ITEMTYPE_ARMA, 300,100) constructor 
	{
		buy  = 320;
		sell = 100;
		
		setStat(STAT_FUERZA, 6 , MALL_NUMTYPE.REAL,  STAT_FESPECIAL, 5, MALL_NUMTYPE.REAL);
		setStat(STAT_PODER , 16, MALL_NUMTYPE.REAL);
	}());

	// LVL 6 -> 12
	#macro POCKET_ITEM_TENEDOR_PLASTICO "POCKET.JON.TENEDOR.PLASTICA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_TENEDOR_PLASTICO, POCKET_ITEMTYPE_ARMA, 480,100) constructor 
	{
		setStat(
			STAT_FUERZA,    8 , MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 10, MALL_NUMTYPE.REAL,
			STAT_PODER,     11, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 12 -> 24
	#macro POCKET_ITEM_CUCHARA_HIERRO "POCKET.JON.CUCHARA.HIERRO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CUCHARA_HIERRO, POCKET_ITEMTYPE_ARMA, 680,300) constructor 
	{
		setStat(
			STAT_FUERZA, 10, MALL_NUMTYPE.REAL,  STAT_FESPECIAL, 11, MALL_NUMTYPE.REAL,
			STAT_PODER , 19, MALL_NUMTYPE.REAL
			);
	}());
		
	// LVL 12 -> 24
	#macro POCKET_ITEM_TENEDOR_HIERRO "POCKET.JON.TENEDOR.HIERRO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_TENEDOR_HIERRO, POCKET_ITEMTYPE_ARMA, 720, 320) constructor 
	{
		setStat(
			STAT_FUERZA   , 15, MALL_NUMTYPE.REAL,
			STAT_DEFENSA  ,  3, MALL_NUMTYPE.REAL, STAT_DESPECIAL, -6, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 14, MALL_NUMTYPE.REAL,
			STAT_PODER, 18, MALL_NUMTYPE.REAL
			);
	}());
		
	// LVL 24 -> 30
	#macro POCKET_ITEM_CUCHARA_PLATA "POCKET.JON.CUCHARA.PLATA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CUCHARA_PLATA, POCKET_ITEMTYPE_ARMA, 6_000, 1_000) constructor 
	{
		setStat(
			STAT_FUERZA, 14, MALL_NUMTYPE.REAL, STAT_FESPECIAL, 17, MALL_NUMTYPE.REAL,
			STAT_PODER , 22, MALL_NUMTYPE.REAL
			);
	}());
		
	// LVL 24 -> 30
	#macro POCKET_ITEM_TENEDOR_PLATA "POCKET.JON.TENEDOR.PLATA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CUCHARA_HIERRO, POCKET_ITEMTYPE_ARMA, 6_000, 1_200) constructor 
	{
		setStat(
			STAT_FUERZA   , 22, MALL_NUMTYPE.REAL,
			STAT_DEFENSA  ,  5, MALL_NUMTYPE.REAL, STAT_DESPECIAL, -16, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 18, MALL_NUMTYPE.REAL,
			STAT_PODER, 25, MALL_NUMTYPE.REAL,
			);
	}());

	// Mezcla de tenedor y cuchara
	// LVL 30 -> 36
	#macro POCKET_ITEM_CUCHARA_TENEDOR_HIERRO "POCKET.JON.CUCHARA_TENEDOR.HIERRO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CUCHARA_TENEDOR_HIERRO, POCKET_ITEMTYPE_ARMA, 6_000, 1_600) constructor 
	{
		setStat(
			STAT_FUERZA   , 16, MALL_NUMTYPE.REAL, STAT_DEFENSA  , 4, MALL_NUMTYPE.REAL,
			STAT_FESPECIAL, 14, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 2, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 11, MALL_NUMTYPE.REAL, 
			STAT_PODER    , 26, MALL_NUMTYPE.REAL 
			);
	}());

	// LVL 36 -> 42
	#macro POCKET_ITEM_CUCHARA_TENEDOR_PLATA "POCKET.JON.CUCHARA_TENEDOR.PLATA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CUCHARA_TENEDOR_PLATA, POCKET_ITEMTYPE_ARMA, 6_000, 1_600) constructor 
	{
		setStat(
			STAT_FUERZA ,   20, MALL_NUMTYPE.REAL, STAT_DEFENSA  , 10, MALL_NUMTYPE.REAL,
			STAT_FESPECIAL, 20, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 10, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 16, MALL_NUMTYPE.REAL,
			STAT_PODER    , 30, MALL_NUMTYPE.REAL,
			);
	}());
	
	// LVL 42 -> 48 De ahora empezar a restar algunas estadisticas
	#macro POCKET_ITEM_CUCHARON_HIERRO "POCKET.JON.CUCHARON.HIERRO" 
	pocket_create(new function() : PocketItem(POCKET_ITEM_CUCHARON_HIERRO, POCKET_ITEMTYPE_ARMA, 6_000, 1_600) constructor 
	{
		setStat(
			STAT_FUERZA   ,  25, MALL_NUMTYPE.REAL, STAT_DEFENSA  , 17, MALL_NUMTYPE.REAL,
			STAT_FESPECIAL,  25, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 17, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD,  21, MALL_NUMTYPE.REAL, 
			STAT_PODER    ,  37, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 48 -> 54 De ahora empezar a restar algunas estadisticas
	#macro POCKET_ITEM_CUCHARON_PLATA "POCKET.JON.CUCHARON.PLATA" 
	pocket_create(new function() : PocketItem(POCKET_ITEM_CUCHARON_PLATA, POCKET_ITEMTYPE_ARMA, 6_000, 1_600) constructor 
	{
		setStat(
			STAT_FUERZA   ,  25, MALL_NUMTYPE.REAL, STAT_DEFENSA  , 17, MALL_NUMTYPE.REAL,
			STAT_FESPECIAL,  25, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 17, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD,  21, MALL_NUMTYPE.REAL, 
			STAT_PODER    ,  37, MALL_NUMTYPE.REAL
			);
	}());


	#endregion

	#region -- Gabi Items
	// LVL 50 -> 56
	#macro POCKET_ITEM_GUANTES_BLANCOS "POCKET.GABI.GUANTES.BLANCOS" // Enfoque especial
	pocket_create(new function() : PocketItem(POCKET_ITEM_GUANTES_BLANCOS, POCKET_ITEMTYPE_ARMA, 1_020, 104) constructor 
	{
		setStat(
			STAT_FUERZA, 18, MALL_NUMTYPE.REAL,  STAT_FESPECIAL, 28, MALL_NUMTYPE.REAL,
			STAT_PODER , 43, MALL_NUMTYPE.REAL
			);
	}()); // 4 6 3 
	
	// LVL 50 -> 56
	#macro POCKET_ITEM_GUANTES_NEGROS "POCKET.GABI.GUANTES.NEGROS" // Enfoque fisico
	pocket_create(new function() : PocketItem(POCKET_ITEM_GUANTES_NEGROS, POCKET_ITEMTYPE_ARMA, 2_200, 500) constructor 
	{
		setStat(
			STAT_FUERZA   , 28, MALL_NUMTYPE.REAL, 
			STAT_VELOCIDAD, 16, MALL_NUMTYPE.REAL,
			STAT_PODER    , 38, MALL_NUMTYPE.REAL
			);
	}()); // 4 6 3
	
	// LVL 62 -> 68
	#macro POCKET_ITEM_GUANTES_ROJOS "POCKET.GABI.GUANTES.ROJOS"
	pocket_create(new function() : PocketItem(POCKET_ITEM_GUANTES_ROJOS, POCKET_ITEMTYPE_ARMA, 2800, 500) constructor 
	{
		setStat(
			STAT_FUERZA   ,  22, MALL_NUMTYPE.REAL, STAT_FESPECIAL, 34, MALL_NUMTYPE.REAL,
			STAT_DEFENSA  , -10, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD,  13, MALL_NUMTYPE.REAL,
			STAT_PODER    ,  46, MALL_NUMTYPE.REAL
			);
	}()); // -3 4 


	// LVL 62 -> 68
	#macro POCKET_ITEM_GUANTES_VERDES "POCKET.GABI.GUANTES.VERDES"
	pocket_create(new function() : PocketItem(POCKET_ITEM_GUANTES_VERDES, POCKET_ITEMTYPE_ARMA, 2620, 100) constructor
	{
		setStat(
			STAT_FUERZA   , 32, MALL_NUMTYPE.REAL, STAT_DEFENSA, 10, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 22, MALL_NUMTYPE.REAL,
			STAT_PODER    , 41, MALL_NUMTYPE.REAL
			);
	}()); // 4 
	
	// LVL 73 -> 78
	#macro POCKET_ITEM_GUANTES_CUERO "POCKET.GABI.GUANTES.CUERO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_GUANTES_CUERO, POCKET_ITEMTYPE_ARMA, 2620, 100) constructor
	{
		setStat(
			STAT_FUERZA   , 26, MALL_NUMTYPE.REAL, STAT_DEFENSA  , -13, MALL_NUMTYPE.REAL,
			STAT_FESPECIAL, 38, MALL_NUMTYPE.REAL, STAT_DESPECIAL,  13, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 15, MALL_NUMTYPE.REAL,
			STAT_PODER    , 40, MALL_NUMTYPE.REAL
			);
	}());


	#endregion

	#region -- Fernando Items
	// LVL 40 -> 47
	#macro POCKET_ITEM_MONEDA_988 "POCKET.FEN.MONEDA.988"
	pocket_create(new function() : PocketItem(POCKET_ITEM_MONEDA_988, POCKET_ITEMTYPE_ARMA) constructor 
	{	
		setStat(
			STAT_FUERZA , 20, MALL_NUMTYPE.REAL,
			STAT_CRITICO, 10, MALL_NUMTYPE.REAL,
			STAT_PODER  , 32, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 47 - 54
	#macro POCKET_ITEM_MONEDA_942 "POCKET.FEN.MONEDA.942"
	pocket_create(new function() : PocketItem(POCKET_ITEM_MONEDA_942, POCKET_ITEMTYPE_ARMA) constructor
	{
		setStat(
			STAT_FUERZA   , 24, MALL_NUMTYPE.REAL,
			STAT_DESPECIAL, 11, MALL_NUMTYPE.REAL,
			STAT_CRITICO, 11, MALL_NUMTYPE.REAL,
			STAT_PODER  , 35, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 61 - 68
	#macro POCKET_ITEM_MONEDA_NIQUEL "POCKET.FEN.MONEDA.NIQUEL"
	pocket_create(new function() : PocketItem(POCKET_ITEM_MONEDA_NIQUEL, POCKET_ITEMTYPE_ARMA) constructor
	{
		setStat(
			STAT_FUERZA   , 30, MALL_NUMTYPE.REAL, STAT_DEFENSA, 8, MALL_NUMTYPE.REAL,
			STAT_DESPECIAL,  9, MALL_NUMTYPE.REAL,
			STAT_CRITICO, 13, MALL_NUMTYPE.REAL,
			STAT_PODER  , 38, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 68 - 75
	#macro POCKET_ITEM_MONEDA_PLATA "POCKET.FEN.MONEDA.PLATA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_MONEDA_PLATA, POCKET_ITEMTYPE_ARMA) constructor
	{
		setStat(
			STAT_FUERZA   , 36, MALL_NUMTYPE.REAL, STAT_DEFENSA, 16, MALL_NUMTYPE.REAL,
			STAT_DESPECIAL, 16, MALL_NUMTYPE.REAL,
			STAT_CRITICO, 14, MALL_NUMTYPE.REAL,
			STAT_PODER  , 41, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 75 - 82
	#macro POCKET_ITEM_MONEDA_ORO "POCKET.FEN.MONEDA.ORO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_MONEDA_ORO, POCKET_ITEMTYPE_ARMA) constructor
	{
		setStat(
			STAT_FUERZA   , 42, MALL_NUMTYPE.REAL, STAT_DEFENSA, 24, MALL_NUMTYPE.REAL,
			STAT_DESPECIAL, 25, MALL_NUMTYPE.REAL,
			STAT_CRITICO, 16, MALL_NUMTYPE.REAL,
			STAT_PODER  , 44, MALL_NUMTYPE.REAL
			);
	}());

	#endregion
	
	#region -- Equipo para el cuerpo
	// -- Polera y Camisa 
	// Polera: Defensa y Velocidad
	// Camisa: Defensa y Despecial
	
	// LVL 1 -> 4 (Jon, Susana)
	#macro POCKET_ITEM_CAMISA_COLEGIO "POCKET.CUE.CAMISA.COLEGIO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CAMISA_COLEGIO, POCKET_ITEMTYPE_ARMDU1, 200,80) constructor 
	{
		setStat(STAT_DEFENSA,6,MALL_NUMTYPE.REAL,  STAT_DESPECIAL,3,MALL_NUMTYPE.REAL);
	}()); // Sumar: 6 3
	// LVL 1 -> 4 (Jon, Susana)
	#macro POCKET_ITEM_POLERA_COLEGIO "POCKET.POLERA.COLEGIO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_POLERA_COLEGIO, POCKET_ITEMTYPE_ARMDU1, 200,80) constructor
	{
		setStat(STAT_DEFENSA,5,MALL_NUMTYPE.REAL,  STAT_VELOCIDAD,4,MALL_NUMTYPE.REAL);
	}()); // Sumar: 5 7
	
	// LVL 4 -> 9 (Jon, Susana)
	#macro POCKET_ITEM_CAMISA_CUADROS "POCKET.CAMISA.CUADROS"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CAMISA_CUADROS, POCKET_ITEMTYPE_ARMDU1, 200,80) constructor
	{
		setStat(STAT_DEFENSA,12,MALL_NUMTYPE.REAL,  STAT_DESPECIAL,6,MALL_NUMTYPE.REAL);
	}());
	// LVL 4 -> 9 (Jon, Susana)
	#macro POCKET_ITEM_POLERA_COLORIDA "POCKET.POLERA.COLORIDA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_POLERA_COLORIDA, POCKET_ITEMTYPE_ARMDU1, 200,80) constructor
	{
		setStat(STAT_DEFENSA,10,MALL_NUMTYPE.REAL,  STAT_VELOCIDAD,7,MALL_NUMTYPE.REAL);
	}());
	
	// LVL 9 -> 14 (Jon, Susana)
	#macro POCKET_ITEM_CAMISA_VEBRES "POCKET.CAMISA.VEBRES" // Vebres marca famosa de ropa
	pocket_create(new function() : PocketItem(POCKET_ITEM_CAMISA_VEBRES, POCKET_ITEMTYPE_ARMDU1, 200,80) constructor
	{
		setStat(STAT_DEFENSA,18,MALL_NUMTYPE.REAL,  STAT_DESPECIAL,9,MALL_NUMTYPE.REAL);
	}()); // Sumar: 6 3
	// LVL 9 -> 14 (Jon, Susana)
	#macro POCKET_ITEM_POLERA_VEBRES "POCKET.POLERA.VEBRES"
	pocket_create(new function() : PocketItem(POCKET_ITEM_POLERA_VEBRES, POCKET_ITEMTYPE_ARMDU1, 200,80) constructor
	{
		setStat(STAT_DEFENSA,15,MALL_NUMTYPE.REAL,  STAT_VELOCIDAD,10,MALL_NUMTYPE.REAL);
	}()); // Sumar: 5 7
	
	// LVL 40 -> 46 (Gabi, Fernando)
	#macro POCKET_ITEM_PLATINAS_HIERRO "POCKET.PLATINAS.HIERRO" 
	pocket_create(new function() : PocketItem(POCKET_ITEM_PLATINAS_HIERRO, POCKET_ITEMTYPE_ARMDU1, 530,200) constructor
	{
		setStat(
			STAT_DEFENSA  , 30, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 15, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, -6, MALL_NUMTYPE.REAL,
			STAT_PODER, 4, MALL_NUMTYPE.REAL 
			);
	}()); // 5 5 -4 1
	// LVL 40 -> 46 (Gabi, Fernando)
	#macro POCKET_ITEM_PLATINAS_ECTO "POCKET.PLATINAS.ECTO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_PLATINAS_ECTO, POCKET_ITEMTYPE_ARMDU1, 53,200) constructor
	{
		setStat(
			STAT_DEFENSA, 14, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 30, MALL_NUMTYPE.REAL,
			STAT_PODER, 3, MALL_NUMTYPE.REAL
			);
	}()); // 5 5 1
	
	// LVL 46 -> 52 (Gabi, Fernando)
	#macro POCKET_ITEM_CHALECO_BLINDADO "POCKET.CHALECO.BLINDADO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CHALECO_BLINDADO, POCKET_ITEMTYPE_ARMDU1, 530,200) constructor
	{
		setStat(
			STAT_DEFENSA  ,  35, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 20, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, -10, MALL_NUMTYPE.REAL,
			STAT_PODER, 5, MALL_NUMTYPE.REAL 
			);
	}());
	// LVL 46 -> 52 (Gabi, Fernando)
	#macro POCKET_ITEM_CHALECO_IMBUIDO "POCKET.CHALECO.IMBUIDO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CHALECO_IMBUIDO, POCKET_ITEMTYPE_ARMDU1, 53,200) constructor
	{
		setStat(
			STAT_DEFENSA, 19, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 30, MALL_NUMTYPE.REAL,
			STAT_PODER  ,  4, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 52 -> 59 (Gabi, Fernando)
	#macro POCKET_ITEM_CHALECO_REFORZADO "POCKET.CHALECO.REFORZADO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CHALECO_REFORZADO, POCKET_ITEMTYPE_ARMDU1, 530,200) constructor
	{
		setStat(
			STAT_DEFENSA  ,  40, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 25, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, -14, MALL_NUMTYPE.REAL,
			STAT_PODER, 6, MALL_NUMTYPE.REAL
			);
	}()); // 5 5 -4 1
	// LVL 52 -> 59 (Gabi, Fernando)
	#macro POCKET_ITEM_CHALECO_TRATADO "POCKET.CHALECO.TRATADO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CHALECO_TRATADO, POCKET_ITEMTYPE_ARMDU1, 530, 200) constructor
	{
		setStat(
			STAT_DEFENSA, 24, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 35, MALL_NUMTYPE.REAL,
			STAT_PODER  ,  5, MALL_NUMTYPE.REAL
			);
	}()); // 5 5 1
	
	// LVL 59 -> 66 (Gabi, Fernando)
	#macro POCKET_ITEM_CHALECO_ELDRO "POCKET.CHALECO.ELDRO" // ELDRO fabricante de equipo para policias, militares, etc
	pocket_create(new function() : PocketItem(POCKET_ITEM_CHALECO_ELDRO, POCKET_ITEMTYPE_ARMDU1, 530,200) constructor
	{
		setStat(
			STAT_DEFENSA  , 45, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 30, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD,-18, MALL_NUMTYPE.REAL,
			STAT_PODER, 7, MALL_NUMTYPE.REAL
			);
	}());
	// LVL 59 -> 66 (Gabi, Fernando)
	#macro POCKET_ITEM_CHALECO_ECTO "POCKET.CHALECO.ECTO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CHALECO_ECTO, POCKET_ITEMTYPE_ARMDU1, 53,200) constructor
	{
		setStat(
			STAT_DEFENSA, 29, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 40, MALL_NUMTYPE.REAL,
			STAT_PODER  ,  6, MALL_NUMTYPE.REAL
			);
	}());
	// LVL 66 -> 73 (Gabi, Fernando)
	#macro POCKET_ITEM_CHALECO_SQUAD "POCKET.CHALECO.SQUAD" // SQUAD equipo para amenazas "normales" peligrosas
	pocket_create(new function() : PocketItem(POCKET_ITEM_CHALECO_SQUAD, POCKET_ITEMTYPE_ARMDU1,  530,200) constructor 
	{
		setStat(
			STAT_DEFENSA  , 50, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 35, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD,-22, MALL_NUMTYPE.REAL,
			STAT_PODER, 8, MALL_NUMTYPE.REAL
			);
	}());
	// LVL 66 -> 73 (Gabi, Fernando)
	#macro POCKET_ITEM_CHALECO_ECTLDRO "POCKET.CHALECO.ECTLDRO" // Un chaleco Eldro imbuido en ecto
	pocket_create(new function() : PocketItem(POCKET_ITEM_CHALECO_ECTLDRO, POCKET_ITEMTYPE_ARMDU1, 53,200) constructor
	{
		setStat(
			STAT_DEFENSA, 34, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 45, MALL_NUMTYPE.REAL,
			STAT_PODER  ,  6, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 73 -> 80 (Gabi, Fernando)
	#macro POCKET_ITEM_CHALECO_MILITAR "POCKET.CHALECO.MILITAR"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CHALECO_SQUAD, POCKET_ITEMTYPE_ARMDU1, 530,200) constructor
	{
		setStat(
			STAT_DEFENSA  , 60, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 45, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD,-30, MALL_NUMTYPE.REAL,
			STAT_PODER, 10, MALL_NUMTYPE.REAL
			);
	}());
	// LVL 73 -> 80 (Gabi, Fernando)
	#macro POCKET_ITEM_CHALECO_MUERTO "POCKET.CHALECO.MUERO" // "Muerto" se refiere a que un espiritu lo posee
	pocket_create(new function() : PocketItem(POCKET_ITEM_CHALECO_ECTLDRO, POCKET_ITEMTYPE_ARMDU1, 53,200) constructor
	{
		setStat(
			STAT_DEFENSA, 44, MALL_NUMTYPE.REAL, STAT_DESPECIAL, 55, MALL_NUMTYPE.REAL,
			STAT_PODER  ,  8, MALL_NUMTYPE.REAL
			);
	}());

	#endregion

	#region -- Equipo para los pies
	// Zapatos
	// LVL 8 -> 14 (Jon, Susana)
	#macro POCKET_ITEM_ZAPATOS_MANCHADOS "POCKET.ZAPATOS.MANCHADOS"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ZAPATOS_MANCHADOS,POCKET_ITEMTYPE_ACCES2,  320,130) constructor 
	{
		setStat(
			STAT_DEFENSA,   7, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 9, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 14 -> 18 (Jon, Susana)
	#macro POCKET_ITEM_ZAPATOS_GENERICOS "POCKET.ZAPATOS.GENERICOS"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ZAPATOS_GENERICOS,POCKET_ITEMTYPE_ACCES2,  320,130) constructor
	{
		setStat(
			STAT_DEFENSA,   12, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 14, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 18 -> 24 (Jon, Susana)
	#macro POCKET_ITEM_ZAPATOS_IMITACION "POCKET.ZAPATOS.IMITACION"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ZAPATOS_IMITACION,POCKET_ITEMTYPE_ACCES2,  320,130) constructor
	{
		setStat(
			STAT_DEFENSA,   17, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 19, MALL_NUMTYPE.REAL
			);
	}());
	
	// Zapatillas
	// LVL 4 -> 8 (Jon, Susana)
	#macro POCKET_ITEM_ZAPATILLAS_MANCHADAS "POCKET.ZAPATILLAS.MANCHADAS"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ZAPATILLAS_MANCHADAS,POCKET_ITEMTYPE_ACCES2,  320,130) constructor 
	{
		setStat(STAT_VELOCIDAD, 11, MALL_NUMTYPE.REAL);
	}());
	
	// LVL 8 -> 14 (Jon, Susana)
	#macro POCKET_ITEM_ZAPATILLAS_GASTADAS "POCKET.ZAPATILLAS.GASTADAS"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ZAPATILLAS_GASTADAS,POCKET_ITEMTYPE_ACCES2,  320,130) constructor
	{
		setStat(
			STAT_DEFENSA,    2, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 17, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 14 -> 18 (Jon, Susana)
	#macro POCKET_ITEM_ZAPATILLAS "POCKET.ZAPATILLAS"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ZAPATILLAS,POCKET_ITEMTYPE_ACCES2,  320,130) constructor
	{
		setStat(
			STAT_DEFENSA,    4, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 23, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 18 -> 24 (Jon, Susana)
	#macro POCKET_ITEM_ZAPATILLAS_IMITACION "POCKET.ZAPATILLAS.IMITACION"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ZAPATILLAS_IMITACION,POCKET_ITEMTYPE_ACCES2,  320,130) constructor
	{
		setStat(
			STAT_DEFENSA,    6, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 29, MALL_NUMTYPE.REAL
			);
	}());
	// LVL 36 -> 40 (Jon, Fernando, Gabi)
	#macro POCKET_ITEM_ZAPATILLAS_SEGURIDAD "POCKET.ZAPATILLAS.SEGURIDAD"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ZAPATILLAS_SEGURIDAD,POCKET_ITEMTYPE_ACCES2,  650,150) constructor
	{
		setStat(
			STAT_DEFENSA,   18, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 26, MALL_NUMTYPE.REAL
			);
	}());	

	// Botas
	// LVL 24 -> 36 (Gabi, Fernando)
	#macro POCKET_ITEM_BOTAS "POCKET.BOTAS"
	pocket_create(new function() : PocketItem(POCKET_ITEM_BOTAS,POCKET_ITEMTYPE_ACCES2,  650,150) constructor
	{
		setStat(
			STAT_DEFENSA,  16, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 4, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 24 -> 36 (Jon, Gabi, Fernando)
	#macro POCKET_ITEM_BOTAS_LIGERAS "POCKET.BOTAS.LIGERAS"
	pocket_create(new function() : PocketItem(POCKET_ITEM_BOTAS_LIGERAS,POCKET_ITEMTYPE_ACCES2,  650,150) constructor
	{
		setStat(
			STAT_DEFENSA,   8, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 9, MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 30 -> 42 (Gabi, Fernando)
	#macro POCKET_ITEM_BOTAS_ESCENCIA "POCKET.BOTAS.ESCENCIA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_BOTAS_ESCENCIA,POCKET_ITEMTYPE_ACCES2,  650,150) constructor
	{
		setStat(
			STAT_DEFENSA,   12, MALL_NUMTYPE.REAL,
			STAT_DESPECIAL, 14, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD,  4, MALL_NUMTYPE.REAL
			);
	}());	

	#endregion

	#region -- Equipo para accesorios 1
	// LVL 1 -> 8 (Jon, Susana)
	#macro POCKET_ITEM_GORRO_LANA "POCKET.ACC1.GORRO_DE_LANA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_GORRO_LANA, POCKET_ITEMTYPE_ACCES1, 220, 10) constructor
	{
		setStat(STAT_DEFENSA, 2, MALL_NUMTYPE.REAL);
	}());
	
	// LVL 1 -> 8 (Jon, Susana)
	#macro POCKET_ITEM_CRUZ "POCKET.ACC1.CRUZ"
	pocket_create(new function() : PocketItem(POCKET_ITEM_CRUZ, POCKET_ITEMTYPE_ACCES1, 220, 0) constructor 
	{
		setStat(STAT_DEFENSA,3,MALL_NUMTYPE.REAL,  STAT_DESPECIAL,3,MALL_NUMTYPE.REAL);
	}());
	
	// LVL 1 -> 8 (Jon)
	#macro POCKET_ITEM_DIBUJO "POCKET.ACC1.DIBUJO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_DIBUJO,  POCKET_ITEMTYPE_ACCES1,  100, 2) constructor
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
	}());
	
	// LVL 1 -> 8 (Jon, Susana)
	#macro POCKET_ITEM_ZAPATOS_GASTADOS "POCKET.ZAPATOS.GASTADOS"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ZAPATOS_GASTADOS, POCKET_ITEMTYPE_ACCES1, 320, 130) constructor
	{
		setStat(
			STAT_DEFENSA  , 1, MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, 1, MALL_NUMTYPE.REAL
			);
	}());
	
	/*  */
	
	// LVL 30 - 40
	#macro POCKET_ITEM_AMULETO_GALLO "POCKET.ACC1.AMULETO.GALLO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_AMULETO_GALLO, POCKET_ITEMTYPE_ACCES1, 600, 500) constructor
	{
		setStat(STAT_VELOCIDAD, 18, MALL_NUMTYPE.REAL);
	}());
	
	// LVL 30 - 40
	#macro POCKET_ITEM_ANILLO_TORO "POCKET.ACC1.ANILLO.TORO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ANILLO_TORO, POCKET_ITEMTYPE_ACCES1, 600, 500) constructor
	{
		setStat(
			STAT_FUERZA ,    8, MALL_NUMTYPE.REAL, 
			STAT_DEFENSA,   24, MALL_NUMTYPE.REAL,  STAT_DESPECIAL,18,MALL_NUMTYPE.REAL,
			STAT_VELOCIDAD, -8, MALL_NUMTYPE.REAL,
			STAT_PODER,3,MALL_NUMTYPE.REAL
			);
	}());
	
	// LVL 30 - 40
	#macro POCKET_ITEM_ANILLO_CABRA "POCKET.ACC1.ANILLO.CABRA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ANILLO_CABRA, POCKET_ITEMTYPE_ACCES1, 600, 500) constructor
	{
		setStat(STAT_FUERZA,14,MALL_NUMTYPE.REAL,  STAT_VELOCIDAD,18,MALL_NUMTYPE.REAL);
	}());
	
	// LVL 40 - 50
	#macro POCKET_ITEM_ANILLO_CABALLO "POCKET.ACC1.ANILLO.CABALLO"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ANILLO_CABALLO, POCKET_ITEMTYPE_ACCES1, 600, 500) constructor
	{
		setStat(STAT_DEFENSA,20,MALL_NUMTYPE.REAL,  STAT_DESPECIAL,20,MALL_NUMTYPE.REAL);
	}());

	#endregion


	#region -- Equipo para objetos etc
	#macro POCKET_ITEM_ECTOLITA "POCKET.OBJ.ECTOLITA"
	pocket_create(new function() : PocketItem(POCKET_ITEM_ECTOLITA, POCKET_ITEMTYPE_ETC, 0,50) constructor {} ());
	

	#endregion

	#region -- Equipo para los enemigos
	// Para Floating Head 01
	pocket_create(new function() : PocketItem("POCKET.ENE.MIRADA_DE_MIEDO", POCKET_ITEMTYPE_ENEMY) constructor
	{
		buy=999_999; sell=0;
		setStat(STAT_PODER, 32);
	}());
	
	// Para Floating Head 02
	pocket_create(new function() : PocketItem("POCKET.ENE.MIRADA_DE_TEMOR", POCKET_ITEMTYPE_ENEMY) constructor
	{
		buy = 999_999; sell=0
		setStat(
			STAT_VELOCIDAD, 20, MALL_NUMTYPE.REAL,
			STAT_PODER    , 36, MALL_NUMTYPE.REAL
			);
	}());
	
	// Para Dead Bird
	pocket_create(new function() : PocketItem("POCKET.ENE.ALAS_DE_ECTO", POCKET_ITEMTYPE_ENEMY) constructor
	{
		buy = 999_999; sell=0;
		setStat(STAT_PODER, 55);
	}());
	
	// Para Dead Bird
	pocket_create(new function() : PocketItem("POCKET.ENE.ALAS_DE_PETO", POCKET_ITEMTYPE_ENEMY) constructor
	{
		buy = 999_999; sell=0;
		setStat(
			STAT_PODER,     45,
			STAT_DESPECIAL, 30
			);
	}());
	
	// Para Zombie
	pocket_create(new function() : PocketItem("POCKET.ENE.BLOOD", POCKET_ITEMTYPE_ENEMY) constructor
	{
		buy = 999_999; sell=0;
		setStat(STAT_PODER, 55);
	}());

	#endregion


}
