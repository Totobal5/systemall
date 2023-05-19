/// @desc Function Description
/// @param {function} startFunction Funcion a ejecutar luego de iniciar
function PocketBag(_init) constructor
{
	order = [];
	items = {};
	// Limites de objetos que puede llevar
	limit = [__MALL_POCKET_BAG_MIN, __MALL_POCKET_BAG_MAX]; 
	
	/// @desc Struct que guarda la informacion de los objetos agregados
	/// @param {Struct.PartyItem} item
	/// @param {real}             count
	/// @param {real}             index
	static itemComponent = function(_item, _count, _index) constructor
	{
		item  = _item;
		count = _count;
		index = _index;
	}

	/// @desc Agrega o reposiciona un elemento en la posicion dada
	static set = function(_itemKey, _count, _index=0, _vars={})
	{
		var _rt = {
			result: true, item: undefined, left: 0
		}
		// No existe y crear
		if (!variable_struct_exists(items, _itemKey) ) {
			items[$ _itemKey] = new itemComponent(_itemKey, _count, _index);
		} 
		// Insertar
		else {
			// Obtener indice
			var _rem = array_find_index(order, method({key: _itemKey}, function(v,i) {
				return (v == key);
			}) );
			array_delete(order, _rem, 1); // Eliminar
			
			// Insertar en nueva posicion
			items[$ _itemKey].count = _count;
		}
		
		array_set(order, _index, _itemKey);
		
		// Actualizar items
		updateItems();
		return _rt;
	}
	
	/// @desc Como obtener un elemento de la bag
	/// @param {String} itemKey
	/// @param {Any*} [vars]
	static get = function(_itemKey, _vars) 
	{
		return (items[$ _itemKey] );
	}

	/// @desc Agrega elementos
	/// @param {String} itemKey
	/// @param {Real} count
	static add = function(_itemKey, _count, _vars) 
	{
		var _rt = {
			result: true, item: undefined, left: 0
		}
		
		if (!variable_struct_exists(items, _itemKey) ) {
			array_push(order, _itemKey);
			var n=array_length(order) - 1;
			items[$ _itemKey] = new itemComponent(_itemKey, _count, n);
		}
		else {
			var _itemSum = items[$ _itemKey] + _count;
			// Comprobar limite menor
			if (_itemSum <= limit[0] ) {
				var _t = remove(_itemKey);
				_rt.result = false;
				_rt.item   = _t;
				
			} 
			// Comprobar limite superior
			else if (_itemSum > limit[1] ) {
				items[$ _itemKey].count = limit[1];
				var _t = limit[1] - _itemSum;
				_rt.left   = _t;
			} 
			// Agregar
			else {
				items[$ _itemKey].count = _itemSum;
			}
		}
		
		return _rt;
	}
	
	/// @desc Como borrar elementos guardados
	/// @param {String} itemKey
	static remove = function(_itemKey) 
	{
		var t=items[$ _itemKey];
		if (is_undefined(t) ) return t;
		
		// Eliminar
		array_delete(order, t.index, 1);
		variable_struct_remove(items, _itemKey);
		
		updateItems();
		
		return (t);
	}
		
	/// @desc Como ciclar entre todos los elementos
	/// @param {Function} function  function(item, count, index) {}
	/// @param {Any*}     [vars]
	static foreach = function(_function, _vars) 
	{
		var i=0; repeat(array_length(order) ) {
			var _key  = order[i];
			var _item = items[$ _key];
			_function(pocket_data_get(_key), item.count, i);
			i = i+1;
		}
	}
	
	#region -- Misq
	static updateItems = function()
	{
		array_foreach(order, function(v, i) {
			var _item = items[$ v];
			_item.index = i;
		});
	}
	
	static save = function()
	{
		var _s={order: [], items: {} }
		array_foreach(order, method(_s, function(v, i) {
			array_push(order, v.key);
			variable_struct_set(items, v.key, {
				key  : v.key,
				count: v.count,
				index: v.i
			});
		}) );
		return _s;
	}
	
	static load = function(_l)
	{
		// Cargar objetos
		order = _l.order;
		items = _l.items;
		
		updateItems(); // Actualizar
	}
	
	#endregion
}