/// @param {String}	id
/// @param {Mixed}	value
/// @param {Bool}	is_node
/// @return {Struct.Tree}
function Tree(_id, _value, _is_node=true) constructor 
{
	#region PRIVATE
	__id = _id;	
	__depth = 1;			// Profundidad el primero siempre es 1
	
	__depthMap = {};
	__depthMap[$ "1"] = 
	{
		__count:	1,					// El primer nodo lleva la cuenta de todos.
		__order:	[string(__id) ],	// El orden en que se agregaron los elementos
		__h:	1	// Solo el root lleva este valor indica la altura del tree
	};
	__depthMap[$ "1"][$ __id] = self;
	
	__node  = _is_node;		// Si es un nodo que puede agregar más elementos
	value = _value;		// Valor que almacena
	
	#endregion
	
	#region METHOD
	/// @param {String}	id
	/// @param {Mixed}	value
	/// @param {Bool}	[is_node]
	static add = function(_id, _value, _is_node=true) {
		if (!__node) return self;
		
		var _tree = new Tree(_id, _value, _is_node);
		var _n = (__depth + 1);
		
		_tree.__depth  = _n;				// Aumentar la profundidad
		_tree.__depthMap = self.__depthMap;	// Usar el mismo mapa de profundidad
		
		// Actualizar altura
		if (_n > __depthMap.__h) __depthMap.__h = _n;
		
		var _map = __makeMap(_n);
		// Añadir al struct
		_map[$ _id] = _tree;
		array_push(_map.__order, _id);	// Para indicar el orden en que se agregaron los elementos
			
		_map.__count++;					// Cuenta local
		__depthMap[$ "1"].__count++;	// Cuenta global

		return (_tree);
	}
	
	/// @desc Regresa cuantos elementos hay en el Tree localmente
	/// @return {Real}
	static size = function() {
		var _map = __getMap();
		return (_map.__count);
	}

	/// @desc Regresa cuantos elementos hay en el Tree globalmente
	/// @return {Real}
	static sizeGlobal = function()
	{
		var _root = __getRoot();
		return (_root.__count);
	}
	
	/// @desc Elimina un tree localmente
	static remove = function(_id)
	{
		// Más rapido
		var _map = __getMap();
		// Solo si existe
		if (variable_struct_exists(_map, _id) )
		{
			variable_struct_remove(_map, _id);
			
			// Eliminar del orden
			var _order = _map.__order;
			var i=0; repeat(array_length(_order) )
			{
				var _tree = _order[i];
				if (_tree.__id == _id) break;
				++i;
			}
			
			array_delete(_order, i, 1);
			_map.__count--;
			
			return _tree
		}	
		
		return undefined;
	}
	
	/// @desc Elimina un tree globalmente
	static removeGlobal = function(_id)
	{
		var _root  = __depthMap;
		// Saltar el root
		var i=2; repeat(__depthMap.__h)
		{
			var _in = __depthMap[$ string(i) ];
			if (!is_undefined(_in) )
			{
				// Si existe
				if (variable_struct_exists(_in, _id) ) 
				{
					variable_struct_remove(_in, _id);		
					// Eliminar del orden
					var _order = _map.__order;
					var i=0; repeat(array_length(_order) )
					{
						var _tree = _order[i];
						if (_tree.__id == _id) break;
						++i;
					}
			
					array_delete(_order, i, 1);
					_map.__count--;
			
					return _tree;						
				}
			}
			
			i++;
		}
	
		return undefined;
	}
	
	/// @desc Regresa la altura hasta el final en el arbol
	/// @return {Real}
	static height = function(_depth_max=0) {
		var _depth = 0;
		var i=0; repeat(array_length(__list) ) {
			var _tree = __list[i++];	
			if (!_tree.__node) continue;	
			_depth = max(_tree.__depth, _tree.height() );
		}
		
		return _depth;
	}
	
	static __makeMap = function(_depth) 
	{
		var _depth = string(_depth);
		// check
		if (!is_struct(__depthMap[$ _depth] ) )	// Si no existe
		{
			__depthMap[$ _depth] = 
			{
				__count: 0,
				__order: [],
			}
		}
		
		return (__depthMap[$ _depth] );
	}
	
	static __getMap = function() 
	{
		return (__depthMap[$ string(__depth) ] );	
	}
	
	static __getRoot = function()
	{
		return (__depthMap[$ "1"] );	
	}
	
	static __makeRoot = function()
	{
		__id = "root";	
		__depth = 1;		// Profundidad el primero siempre es 1		
		__node  = true;		// Si es un nodo que puede agregar más elementos	
		
		__depthMap = {};
		__depthMap[$ "1"] = 
		{
			__count:	1,					// El primer nodo lleva la cuenta de todos.
			__order:	[string(__id) ],	// El orden en que se agregaron los elementos
			__h:	1	// Solo el root lleva este valor indica la altura del tree
		};
		
		__depthMap[$ "1"][$ __id] = self;
		
		return self;
	}
	
	static __mapToArray = function()
	{
		var _array = [];
		var _root  = __getRoot();
		
		var i=1; repeat(_root.__h)
		{
			var _add = [];
			var _map   = _root[$ string(i) ];
			var _order = _map.__order;
			var j=0; repeat(array_length(_order) )
			{
				var _oid = _order[j];
				array_push(_add, _map[$ _oid] );
				++j;
			}
			
			array_push(_array, _add);
			++i;
		}
		
		return _array;
	}
	
	#endregion
}