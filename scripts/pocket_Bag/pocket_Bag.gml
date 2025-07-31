// Feather ignore all

/// @desc Representa una entrada de objeto en una mochila, con su cantidad y variables únicas.
/// @param {String} item_key La llave de la plantilla del objeto.
/// @param {Real} count La cantidad de este objeto.
/// @param {Struct} [vars] Un struct para datos únicos (ej: { enchantment: "fire" }).
function BagItemInstance(_item_key, _count, _vars = {}) constructor
{
    key =	_item_key;	// Llave del objeto PocketItem.
    count =	_count;		// Cantidad que hay de ese objeto.
    vars =	_vars;		// Variables propias.
    
    /// @desc Exporta la instancia a un struct simple para guardado.
    static Export = function()
    {
		var _this = self;
        return {
            key:	_this.key,
            count:	_this.count,
            vars:	variable_clone(_this.vars)
        };
    }
}

/// @desc Constructor base para todos los tipos de mochilas.
/// @param {String} key
function PocketBag(_key) : Mall(_key) constructor
{
    is_persistent = false;	// Si esta mochila es persistente significa que es exportada y importada.
	
	/// @desc Se ejecuta después de que uno o más objetos han sido añadidos exitosamente.
	/// @context PocketBag (la instancia)
	/// @param {Struct.PocketBag} bag_instance La instancia de la mochila.
	/// @param {String} item_key La llave del objeto que fue añadido.
	/// @param {Real} count_added La cantidad que fue realmente añadida.
	event_on_add_item =		"";
	
	/// @desc Se ejecuta después de que uno o más objetos han sido eliminados.
	/// @context PocketBag (la instancia)
	/// @param {Struct.PocketBag} bag_instance La instancia de la mochila.
	/// @param {String} item_key La llave del objeto que fue eliminado.
	/// @param {Real} count_removed La cantidad que fue realmente eliminada.
    event_on_remove_item =	"";
	
	#region PRIVATE
	
	/// @desc (Privado) Carga el string de los eventos desde el struct de datos.
	/// @param {Struct} data El struct con los datos del bag.
	/// @ignore
	static __LoadFunction = function(_data)
	{
        event_on_add_item =		method(self, mall_get_function(_data[$ "event_on_add_item"] ) );
        event_on_remove_item =	method(self, mall_get_function(_data[$ "event_on_remove_item"] ) );			
	}
	
	#endregion
	
	#region API
	
    /// @desc (Virtual) Configura la mochila desde datos. Debe ser sobreescrito.
	/// @param {Struct} data El struct con los datos del bag.
    static FromData = function(_data)
    {
		is_persistent = _data[$ "is_persistent"] ?? false;
		// Cargar funciones
		__LoadFunction(_data);
        
		return self;
    }

    /// @desc (Virtual) Crea una nueva instancia de esta mochila. Debe ser sobreescrito.
    /// @param {String} instance_key La llave para la nueva instancia de mochila.
    static CreateInstance = function(_instance_key)
    {
		return (__mall_error("[Systemall] El método CreateInstance debe ser implementado por un constructor hijo.") );
    }
	
	#endregion
}

/// @desc Mochila simple que contiene una única lista de objetos.
/// @param {String} key
function PocketBagSimple(_key) : PocketBag(_key) constructor
{
    slot_limit = 30;	// Limite de objetos.
    order = [];			// El array 'order' ahora contiene instancias de BagItemInstance
	
	#region PRIVATE
	
	/// @desc (Privado) Compara dos structs para ver si son idénticos.
	/// @param {Struct} struct1
	/// @param {Struct} struct2
	/// @return {Bool}
	/// @ignore
	static __CompareVars = function(struct1, struct2)
	{
		var _keys1 = variable_struct_get_names(struct1);
		var _keys2 = variable_struct_get_names(struct2);
		
		if (array_length(_keys1) != array_length(_keys2) ) return false;
		
		// Comprobar que SON iguales.
		var i=0; repeat(array_length(_keys1) )
		{
			var _key = _keys1[i];
			// Comprueba que no posean las mismas entradas y si las tienen que no sean el mismo valor.
			if (!struct_exists(struct2, _key) || struct1[$ _key] != struct2[$ _key] ) 
			{
				return false;
			}				
			
			i++;
		}

		return true;
	}
	
	#endregion
	
	#region API
    /// @desc Añade una cantidad de un objeto a la mochila.
    static AddItem = function(_item_key, _count, _vars = {})
    {
        var _item_template = pocket_item_get(_item_key);
        if (is_undefined(_item_template) ) return { success: false, added: 0, leftover: _count };
        
        var _result = { success: false, added: 0, leftover: 0 };
        var _amount_to_add = _count;
        
        // --- LÓGICA PARA ITEMS APILABLES ---
        if (_item_template.is_stackable)
        {
            // Intentar apilar en stacks existentes
			var i=0; repeat(array_length(order) )
			{
                var _inst = order[i++];
				if (_inst.key == _item_key && __CompareVars(_inst.vars, _vars) )
				{
                    var _can_add = _item_template.stack_limit - _inst.count;
                    var _to_add_here = min(_amount_to_add, _can_add);
                    
                    if (_to_add_here > 0) 
					{
                        _inst.count		+= _to_add_here;
                        _result.added	+= _to_add_here;
                        _amount_to_add	-= _to_add_here;
                    }
                }
				
                if (_amount_to_add <= 0) break;
			}
			
			// Crear nuevas entradas con el remanente
			while (_amount_to_add > 0 && array_length(order) < slot_limit)
			{
				var _to_add_here =	min(_amount_to_add, _item_template.stack_limit);
				var _new_instance = new BagItemInstance(_item_key, _to_add_here, _vars);
				array_push(order, _new_instance);
				
				_result.added	+= _to_add_here;
				_amount_to_add	-= _to_add_here;
            }
        }
        // --- LÓGICA PARA ITEMS NO APILABLES ---
        else
        {
            // Para objetos no apilables, se intenta añadir uno por uno.
            while (_amount_to_add > 0 && array_length(order) < slot_limit)
            {
                // Comprobar si ya existe un item idéntico (misma key y vars)
                var _already_exists = false;
				var i=0; repeat(array_length(order) )
				{
                    var _inst = order[i++];
                    if (_inst.key == _item_key && __CompareVars(_inst.vars, _vars) ) 
					{
                        _already_exists = true;
                        break;
                    }
				}
				
                // Si ya existe, no se puede añadir otro igual.
                if (_already_exists) break;
                
                // Si no existe, añadir una nueva instancia.
                var _new_instance = new BagItemInstance(_item_key, 1, _vars);
                array_push(order, _new_instance);
                _result.added++;
                _amount_to_add--;
            }
        }
        
        _result.leftover =	_amount_to_add;
        _result.success =	_result.added > 0;
        
        if (_result.success && is_callable(event_on_add_item) ) 
		{
            event_on_add_item(_item_key, _result.added, args);
        }
		
        return _result;
    }
    
    /// @desc Elimina una cantidad de un objeto de la mochila.
    static RemoveItem = function(_item_key, _count, _vars = {})
    {
        if (_count <= 0) return false;
        var _amount_to_remove = _count;
        
        // Iterar hacia atrás para poder eliminar de forma segura
        for (var i = array_length(order) - 1; i >= 0; i--)
        {
            var _inst = order[i];
            if (_inst.key == _item_key && __CompareVars(_inst.vars, _vars) )
            {
                var _removed_here =		min(_amount_to_remove, _inst.count);
                _inst.count -=			_removed_here;
                _amount_to_remove -=	_removed_here;
                
                if (_inst.count <= 0) array_delete(order, i, 1);
            }
			
            if (_amount_to_remove <= 0) break;
        }
        
        var _total_removed = _count - _amount_to_remove;
        if (_total_removed > 0 && is_callable(event_on_remove_item) )
		{
            event_on_remove_item(_item_key, _total_removed, args);
        }
		
        return (_total_removed > 0);
    }
	
    /// @desc Obtiene la cantidad total de un objeto específico.
    static GetItemCount = function(_item_key)
    {
        var _total =	0;
		var _length =	array_length(order);
		
		var i=0; repeat(array_length(order) ) 
		{
			if (order[i].key == _item_key) {_total += order[i].count; }
			i++;
		}
		
        return _total;
    }

    /// @desc Devuelve un array con todas las instancias de objetos.
    static GetOrderedItems = function() 
	{ 
		return order; 
	}
	
    /// @desc Obtiene la primera instancia de un objeto por su llave.
    static GetItemByKey = function(_key)
    {
		var i=0; repeat(array_length(order) )
		{
            if (order[i].key == _key) return order[i];
			i++;
		}
		
        return undefined;
    }
    
    /// @desc Obtiene una instancia de objeto por su índice en el inventario.
    static GetItemByIndex = function(_index)
    {
        if (_index >= 0 && _index < array_length(order) ) 
		{
            return order[_index];
        }
		
        return undefined;
    }
	
    /// @desc Configura la mochila a partir de un struct de datos.
    static FromData = function(_data)
    {
		// Llamar del padre.
        method(self, PocketBag.FromData)(_data);
        slot_limit = _data[$ "slot_limit"] ?? 30;
		
        return self;
    }
    
    /// @desc Exporta el estado de la mochila a un struct.
    static Export = function()
    {
        var _export_data = method(self, Mall.Export)();
        
		_export_data.order = [];
		var i=0; repeat(array_length(order) )
		{
			array_push(_export_data.order, order[i++].Export() );
		}
		
        return _export_data;
    }
    
    /// @desc Importa el estado de la mochila desde un struct.
    static Import = function(_data)
    {
        method(self, Mall.Import)(_data);
        order = [];
        
		var _saved_order = _data[$ "order"] ?? [];
		var i=0; repeat(array_length(_saved_order) )
		{
            var _item_data = _saved_order[i++];
            array_push(order, new BagItemInstance(_item_data.key, _item_data.count, _item_data.vars) );			
		}
    }

    /// @desc Crea una nueva instancia de esta mochila simple.
    /// @override
    static CreateInstance = function(_instance_key)
    {
        var _new_inst = new PocketBagSimple(_instance_key);
        // 'self' aquí es la plantilla
		_new_inst.FromData(self);
		
        return _new_inst;
    }
	
	#endregion
}

/// @desc (Helper) Un compartimento interno para una categoría de la mochila compleja.
function BagCategorySlot(_slot_limit, _stack_limit) constructor
{
    slot_limit =	_slot_limit;	// Generar comentarios.
    stack_limit =	_stack_limit;	// Generar comentarios.
    items =			{};				// Generar comentarios.
    order =			[];				// Generar comentarios.
	args =			{}				// Generar comentarios.
    
    // Referenciar los métodos de la mochila simple para reutilizar la lógica
    
	#region PRIVATE
	static __CompareVars =	PocketBagSimple.__CompareVars;
	
	#endregion
	
	#region API
    static AddItem =		PocketBagSimple.AddItem;
    static RemoveItem =		PocketBagSimple.RemoveItem;
	static GetItemCount =	PocketBagSimple.GetItemCount;
	static GetItemByKey =	PocketBagSimple.GetItemByKey;
	static GetItemByIndex = PocketBagSimple.GetItemByIndex;
	
	static Export = function() 
	{ 
		return { items: items, order: order }; 
	}
	
    static Import = function(_data)
	{ 
		items = _data[$ "items"] ?? {}; 
		order = _data[$ "order"] ?? []; 
	}
	
	#endregion
}

/// @desc Mochila compleja que organiza los objetos por su tipo.
/// @param {String} key
function PocketBagComplex(_key) : PocketBag(_key) constructor
{
    categories =			{};						// Generar comentarios
    category_defaults =		{ slot_limit: 30 };		// Generar comentarios
    category_overrides =	{};						// Generar comentarios
    
	#region PRIVATE
	
    /// @desc (Privado) Obtiene o crea el compartimento para una categoría.
    static __GetCategory = function(_type)
    {
        if (!struct_exists(categories, _type))
        {
            var _limits = struct_exists(category_overrides, _type)
                ? category_overrides[$ _type]
                : category_defaults;
            
			var _category = new BagCategorySlot(_limits.slot_limit);
            categories[$ _type] = _category;
			
			// Añadir eventos.
			_category.event_on_add_item =		self.event_on_add_item;
			_category.event_on_remove_item =	self.event_on_remove_item;
			// Añadir los mismos argumentos.
			_category.args = self.args;
        }
		
        return categories[$ _type];
    }
    
	#endregion
	
	#region API
    /// @desc Añade una cantidad de un objeto a la categoría correcta.
    static AddItem = function(_item_key, _count, _vars = {})
    {
		var __default = { success: false, added: 0, leftover: _count };
        var _item_template = pocket_item_get(_item_key);
		
        if (is_undefined(_item_template) )
		{
			__mall_print($"Pocket (AddItem): No existe el item_template {_item_key}");
			return __default;
		}
        
        var _category_slot = __GetCategory(_item_template.item_type);
        var _result = _category_slot.AddItem(_item_key, _count, _vars);
        
        if (_result.success && is_callable(event_on_add_item) )
		{
            event_on_add_item(_item_key, _result.added);
        }
		
        return _result;
    }
    
    /// @desc Elimina una cantidad de un objeto de su categoría.
    static RemoveItem = function(_item_key, _count, _vars = {})
    {
		var __default = { success: false, added: 0, leftover: _count };
        var _item_template = pocket_item_get(_item_key);
		
        if (is_undefined(_item_template) ) 
		{
			__mall_print($"Pocket (RemoveItem): No existe el item_template {_item_key}");
			return false;
		}
        
        var _category_slot = __GetCategory(_item_template.item_type);
        if (_category_slot.RemoveItem(_item_key, _count, _vars) ) 
		{
            if (is_callable(event_on_remove_item) ) 
			{
                event_on_remove_item(_item_key, _count);
            }
            
			return true;
        }
		
        return false;
    }

    /// @desc Obtiene la cantidad total de un objeto específico en su categoría.
    static GetItemCount = function(_item_key)
    {
        var _item_template = pocket_item_get(_item_key);
        if (is_undefined(_item_template) )
		{
			__mall_print($"Pocket (GetItemCount): No existe el item_template {_item_key}");
			return 0;
		}
        
        var _type = _item_template.item_type;
        if (struct_exists(categories, _type) )
		{
            return categories[$ _type].GetItemCount(_item_key);
        }
		
        return 0;
    }
    
    /// @desc Obtiene la primera instancia de un objeto por su llave.
    static GetItemByKey = function(_item_key)
    {
        var _item_template = pocket_item_get(_item_key);
        if (is_undefined(_item_template) )
		{
			__mall_print($"Pocket (GetItemCount): No existe el item_template {_item_key}");
			return undefined;
		}

        var _type = _item_template.item_type;
        if (struct_exists(categories, _type) ) 
		{
            return categories[$ _type].GetItemByKey(_item_key);
        }
		
        return undefined;
    }
    
    /// @desc Obtiene una instancia de objeto por su índice dentro de una categoría.
    static GetItemByIndexInCategory = function(_category, _index)
    {
        if (struct_exists(categories, _category) )
		{
            return categories[$ _category].GetItemByIndex(_index);
        }
		
        return undefined;
    }
    
    /// @desc Devuelve un array con todas las instancias de objetos de una categoría.
    static GetItemsByCategory = function(_type)
    {
        if (struct_exists(categories, _type) ) 
		{
            return categories[$ _type].order;
        }
		
        return [];
    }
    
    /// @desc Devuelve las llaves de todas las categorías que tienen objetos.
    static GetAllCategories = function()
    {
        return variable_struct_get_names(categories);
    }
	
    /// @desc Configura la mochila a partir de un struct de datos.
    /// @override
    static FromData = function(_data)
    {
		static __default = { slot_limit: 30 };
		
		// Llama al padre.
        method(self, PocketBag.FromData)(_data);
		
        category_defaults  = _data[$ "category_defaults"]  ??	__default;
        category_overrides = _data[$ "category_overrides"] ??	{};
		
        return self;
    }
    
    /// @desc Exporta el estado de la mochila a un struct.
    static Export = function()
    {
        var _export_data = method(self, Mall.Export)();
        _export_data.categories = {};
        
		var _category_keys = struct_get_names(categories);
		var i=0; repeat(array_length(_category_keys) )
		{
            var _key = _category_keys[ i++ ];
            _export_data.categories[$ _key] = categories[$ _key].Export(); 	
		}
		
        return _export_data;
    }
    
    /// @desc Importa el estado de la mochila desde un struct.
    static Import = function(_data)
    {
        method(self, Mall.Import)(_data);
        categories = {};
        
        if (struct_exists(_data, "categories") )
		{
            var _saved_categories = _data.categories;
            var _category_keys = struct_get_names(_saved_categories);
			
			var i=0; repeat(array_length(_category_keys) )
			{
                var _key = _category_keys[ i++ ];
				
				// Crea la categoría con los límites correctos
                var _category_slot = __GetCategory(_key);
                _category_slot.Import(_saved_categories[$ _key]);				
			}
        }
    }

    /// @desc Crea una nueva instancia de esta mochila compleja.
    /// @override
    static CreateInstance = function(_instance_key)
    {
        var _new_inst = new PocketBagComplex(_instance_key);
        // 'self' aquí es la plantilla
		_new_inst.FromData(self);
        
		return _new_inst;
    }
	
	#endregion
}

/// @desc Crea una plantilla de mochila desde data y la añade a la base de datos.
function pocket_bag_create_from_data(_key, _data)
{
    if (pocket_bag_exists(_key) ) 
	{
		return __mall_print($"Advertencia: El bag '{_key}' ya existe. Se omitirá el duplicado.");
			
		return;
	}
    
    var _bag_type = _data[$ "bag_type"] ?? "simple", _bag;
    switch (_bag_type)
    {
		// Bag con categorias.
        case "complex":
            _bag = new PocketBagComplex(_key);
            
			break;
			
		// Bag simple sin categorias.
        default:
        case "simple":
            _bag = new PocketBagSimple(_key);
            
			break;
    }
    
	// Añadir al sistema.
    _bag.FromData(_data);
    Systemall.__bags[$ _key] = _bag;
	
    array_push(Systemall.__bags_keys, _key);
	
    // Si la mochila está marcada como persistente, añadirla a la lista de guardado.
    if (_bag.is_persistent)
	{
        array_push(Systemall.__persistent_bags, _key);
    }	
}

/// @desc Devuelve la plantilla de una mochila.
function pocket_bag_get(_key)
{
    return Systemall.__bags[$ _key];
}

/// @desc Comprueba si una plantilla de mochila existe.
function pocket_bag_exists(_key)
{
    return struct_exists(Systemall.__bags, _key);
}