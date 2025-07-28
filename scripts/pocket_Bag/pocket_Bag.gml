/// @desc Representa una entrada de objeto en una mochila, con su cantidad y variables únicas.
/// @param {String} item_key La llave de la plantilla del objeto.
/// @param {Real} count La cantidad de este objeto.
/// @param {Struct} [vars] Un struct para datos únicos (ej: { enchantment: "fire" }).
function BagItemInstance(_item_key, _count, _vars = {}) constructor
{
    key = _item_key;
    count = _count;
    vars = _vars;
    
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
    is_persistent = false;
	event_on_add_item =		"";
    event_on_remove_item =	"";
    
    /// @desc (Virtual) Configura la mochila desde datos. Debe ser sobreescrito.
    static FromData = function(_data)
    {
		is_persistent = _data[$ "is_persistent"] ?? false;
        event_on_add_item =		method(self, mall_get_function(_data[$ "event_on_add_item"] ) );
        event_on_remove_item =	method(self, mall_get_function(_data[$ "event_on_remove_item"] ) );
        
		return self;
    }

    /// @desc (Virtual) Crea una nueva instancia de esta mochila. Debe ser sobreescrito.
    /// @param {String} instance_key La llave para la nueva instancia.
    static CreateInstance = function(_instance_key)
    {
        show_error("[Systemall] El método CreateInstance debe ser implementado por un constructor hijo.", true);
        return undefined;
    }
}

/// @desc Mochila simple que contiene una única lista de objetos.
/// @param {String} key
function PocketBagSimple(_key) : PocketBag(_key) constructor
{
    slot_limit = 30;
    // El stack_limit ahora se consulta desde la plantilla del item.
    
    // El array 'order' ahora contiene instancias de BagItemInstance
    order = [];
	
	/// @desc (Privado) Compara dos structs para ver si son idénticos.
	/// @param {Struct} struct1
	/// @param {Struct} struct2
	/// @return {Bool}
	/// @ignore
	static __CompareVars = function(struct1, struct2)
	{
		var _keys1 = variable_struct_get_names(struct1);
		var _keys2 = variable_struct_get_names(struct2);
		
		if (array_length(_keys1) != array_length(_keys2)) return false;
		
		for (var i = 0; i < array_length(_keys1); i++) {
			var _key = _keys1[i];
			if (!variable_struct_exists(struct2, _key) || struct1[$ _key] != struct2[$ _key]) {
				return false;
			}
		}
		
		return true;
	}
	
    /// @desc Añade una cantidad de un objeto a la mochila.
    static AddItem = function(_item_key, _count, _vars = {})
    {
		static __default = { success: false, added: 0, leftover: _count };
        
		var _item_template = pocket_item_get(_item_key);
		// Salir si no existe.
        if (is_undefined(_item_template) ) return __default;
        
        var _result = variable_clone(__default);
        var _stack_limit = _item_template.stack_limit;
        var _amount_to_add = _count;
        
        // Si el item es apilable, intentar añadir a una pila existente
        if (_item_template.is_stackable)
        {
            for (var i = 0; i < array_length(order); i++)
            {
                var _inst = order[i];
                // Comprobar si es el mismo item y tiene las mismas variables
				if (_inst.key == _item_key && __CompareVars(_inst.vars, _vars) )
                {
                    var _can_add = _stack_limit - _inst.count;
                    var _to_add_here = min(_amount_to_add, _can_add);
                    
                    if (_to_add_here > 0)
					{
                        _inst.count += _to_add_here;
                        _result.added += _to_add_here;
                        _amount_to_add -= _to_add_here;
                    }
                }
				
                if (_amount_to_add <= 0) break;
            }
        }
        
        // Si quedan objetos por añadir (o no era apilable), crear nuevas entradas
        while (_amount_to_add > 0 && array_length(order) < slot_limit)
        {
            var _to_add_here = min(_amount_to_add, _stack_limit);
            var _new_instance = new BagItemInstance(_item_key, _to_add_here, _vars);
            array_push(order, _new_instance);
            
            _result.added += _to_add_here;
            _amount_to_add -= _to_add_here;
        }
        
        _result.leftover = _amount_to_add;
        _result.success = _result.added > 0;
        
        // Evento de añadir objetos.
		if (_result.success && is_callable(event_on_add_item) ) 
		{
            event_on_add_item(_item_key, _result.added);
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
            if (_inst.key == _item_key && __CompareVars(_inst.vars, _vars))
            {
                var _removed_here = min(_amount_to_remove, _inst.count);
                _inst.count -= _removed_here;
                _amount_to_remove -= _removed_here;
                
                if (_inst.count <= 0) {
                    array_delete(order, i, 1);
                }
            }
			
            if (_amount_to_remove <= 0) break;
        }
        
        var _total_removed = _count - _amount_to_remove;
        if (_total_removed > 0 && is_callable(event_on_remove_item) )
		{
            event_on_remove_item(_item_key, _total_removed);
        }
		
        return _total_removed > 0;
    }
	
    /// @desc Obtiene la cantidad total de un objeto específico.
    static GetItemCount = function(_item_key)
    {
        var _total = 0;
        for (var i = 0; i < array_length(order); i++) 
		{
            if (order[i].key == _item_key) 
			{
                _total += order[i].count;
            }
        }
		
        return _total;
    }
    
    /// @desc Obtiene la primera instancia de un objeto por su llave.
    static GetItemByKey = function(_key)
    {
        for (var i = 0; i < array_length(order); i++) 
		{
            if (order[i].key == _key)
			{
                return order[i];
            }
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
 
    /// @desc Devuelve un array con todas las instancias de objetos.
    static GetOrderedItems = function() 
	{ 
		return order; 
	}
	
    /// @desc Configura la mochila a partir de un struct de datos.
    static FromData = function(_data)
    {
        method(self, PocketBag.FromData)(_data);
        slot_limit = _data[$ "slot_limit"] ?? 30;
		
        return self;
    }
    
    /// @desc Exporta el estado de la mochila a un struct.
    static Export = function()
    {
        var _export_data = method(self, Mall.Export)();
        
		_export_data.order = [];
        for (var i = 0; i < array_length(order); i++) 
		{
            array_push(_export_data.order, order[i].Export() );
        }
		
        return _export_data;
    }
    
    /// @desc Importa el estado de la mochila desde un struct.
    static Import = function(_data)
    {
        method(self, Mall.Import)(_data);
        order = [];
        
		var _saved_order = _data[$ "order"] ?? [];
		for (var i = 0; i < array_length(_saved_order); i++) 
		{
            var _item_data = _saved_order[i];
            array_push(order, new BagItemInstance(_item_data.key, _item_data.count, _item_data.vars) );
        }
    }

    /// @desc Crea una nueva instancia de esta mochila simple.
    /// @override
    static CreateInstance = function(_instance_key)
    {
        var _new_inst = new PocketBagSimple(_instance_key);
        _new_inst.FromData(self); // 'self' aquí es la plantilla
        return _new_inst;
    }
}

/// @desc (Helper) Un compartimento interno para una categoría de la mochila compleja.
function BagCategorySlot(_slot_limit, _stack_limit) constructor
{
    slot_limit =	_slot_limit;
    stack_limit =	_stack_limit;
    items = {};
    order = [];
    
    // Referenciar los métodos de la mochila simple para reutilizar la lógica
    static __CompareVars =	PocketBagSimple.__CompareVars;
    static AddItem =		PocketBagSimple.AddItem;
    static RemoveItem =		PocketBagSimple.RemoveItem;
	
	static Export = function() 
	{ 
		return { items: items, order: order }; 
	}
	
    static Import = function(_data) 
	{ 
		items = _data[$ "items"] ?? {}; 
		order = _data[$ "order"] ?? []; 
	}
}

/// @desc Mochila compleja que organiza los objetos por su tipo.
/// @param {String} key
function PocketBagComplex(_key) : PocketBag(_key) constructor
{
    categories = {};
    category_defaults =	 { slot_limit: 30 };
    category_overrides = {};
    
    /// @desc (Privado) Obtiene o crea el compartimento para una categoría.
    static __GetCategory = function(_type)
    {
        if (!struct_exists(categories, _type))
        {
            var _limits = variable_struct_exists(category_overrides, _type)
                ? category_overrides[$ _type]
                : category_defaults;
            
            categories[$ _type] = new BagCategorySlot(_limits.slot_limit);
        }
		
        return categories[$ _type];
    }
    
    /// @desc Añade una cantidad de un objeto a la categoría correcta.
    static AddItem = function(_item_key, _count, _vars = {})
    {
		var __default =  { success: false, added: 0, leftover: _count };
		
        var _item_template = pocket_item_get(_item_key);
        if (is_undefined(_item_template) ) return __default;
        
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
        var _item_template = pocket_item_get(_item_key);
        if (is_undefined(_item_template) ) return false;
        
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
        if (is_undefined(_item_template)) return 0;
        
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
        if (is_undefined(_item_template) ) return undefined;

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
        
        var _category_keys = variable_struct_get_names(categories);
        for (var i = 0; i < array_length(_category_keys); i++) 
		{
            var _key = _category_keys[i];
            _export_data.categories[$ _key] = categories[$ _key].Export();
        }
		
        return _export_data;
    }
    
    /// @desc Importa el estado de la mochila desde un struct.
    static Import = function(_data)
    {
        method(self, Mall.Import)(_data);
        categories = {};
        
        if (variable_struct_exists(_data, "categories") )
		{
            var _saved_categories = _data.categories;
            var _category_keys = variable_struct_get_names(_saved_categories);
            for (var i = 0; i < array_length(_category_keys); i++) 
			{
                var _key = _category_keys[i];
				
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
        _new_inst.FromData(self); // 'self' aquí es la plantilla
        return _new_inst;
    }
}



// -----------------------------------------------------------------------------
// API PÚBLICA PARA MANEJAR MOCHILAS
// -----------------------------------------------------------------------------

/// @desc Crea una plantilla de mochila desde data y la añade a la base de datos.
function pocket_bag_create_from_data(_key, _data)
{
    if (pocket_bag_exists(_key) ) return;
    
    var _bag_type = _data[$ "bag_type"] ?? "simple";
    var _bag;
    
    switch (_bag_type)
    {
        case "complex":
            _bag = new PocketBagComplex(_key);
            
			break;
			
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
    if (_bag.is_persistent) {
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