// Feather ignore all
/// @desc Componente que guarda los objetos de mall.
/// @param {String} key
function PocketBag(_key) constructor
{
    key = _key;
    order = [];
    items = {};
    
    // Limites de objetos que puede llevar
    limitMin = __MALL_POCKET_BAG_MIN; 
    limitMax = __MALL_POCKET_BAG_MAX;
    
	/// @ignore
    /// @desc Struct que guarda la informacion de los objetos agregados.
    /// @param	{String}	item
    /// @param	{Real}		count
    /// @param	{Real}		index
    static AtomItem = function(_item, _count, _index) constructor
    {
        item = _item;
        count = _count;
        index = _index;
    }
    
    /// @desc Como obtener un elemento de la bag.
    /// @param	{String} pocket_item_key
    static Get = function(_key)
    {
        return (items[$ _key] );
    }
    
    /// @desc Agrega o reposiciona un elemento en la posicion dada
	/// @param	{String}	pocket_item_key
	/// @param	{Real}		count
	/// @param	{Real}		[index]
    static Set = function(_key, _count, _index=0)
    {
		/// @param	{String}	item_key
		/// @param	{Real}		[index]
        static ItemFind = function(_item_key, i) 
		{
			return (_item_key == _key); 
		};
		
        var _rt = {result: true, item: undefined, left: 0};
        
        // No existe y crear.
        if (!struct_exists(items, _key) ) 
        {
            items[$ _key] = new AtomItem(_key, _count, _index);
        } 
        // Insertar.
        else
		{
            // Obtener indice.
            var _rem = array_find_index(order, method({_key}, ItemFind) );
            // Eliminar item de la posicion anterior.
            array_delete(order, _rem, 1);
            // Insertar en nueva posicion.
            items[$ _key].count = _count;
        }
        
		// Establecer posicion en el array.
        array_set(order, _index, _key);
        
		// Actualizar items.
        Update();
        
        return _rt;
    }
    
    /// @desc Agrega elementos a la Bag.
    /// @param	{String}	pocket_item_key
    /// @param	{Real}		count
    static Add = function(_key, _count) 
    {
        var _return = {result: true, item: undefined, left: 0}
        // Si no existe anteriormente agregar.
        if (!struct_exists(items, _key) )
		{
            array_push(order, _key);
            // Comprobar limites.
			// Si la cantidad a agregar es menor al limite inferior.
            if (_count < limitMin)
			{
				// Se devuelven todos
                _return.left = _count*-1;
                _return.result = false;
				
				// Error! -> salir
                return (_return);
            }
			// Si la cantidad a agregar es mayor al limite superior.
            else if (_count > limitMax)
			{
                _return.left = limitMax - _count; 
            }
			
            // Crear Atom.
            items[$ _key] = new AtomItem(_key, _count, array_length(order) - 1);
			
			// Indicar en el resultado que se ha logrado.
            _return.result = true;
            _return.item = _key;
        }
		// Si ya existia el objeto.
        else
		{
            var _itemSum = items[$ _key] + _count;
            // Comprobar limite menor.
            if (_itemSum <= limitMin)
			{
				// Indicar que se ha elimado completamente el objeto.
                _return.result = false;
                _return.item = Remove(_key);
            } 
            // Comprobar limite superior.
            else if (_itemSum > limitMax)
			{
                items[$ _key].count = limitMax;
                _return.left = limitMax - _itemSum;
            } 
            // Agregar.
            else 
			{
                items[$ _key].count = _itemSum;
            }
        }
        
        return (_return);
    }
    
    /// @desc Como borrar elementos guardados
    /// @param	{String} pocket_item_key
    static Remove = function(_key) 
    {
        var t = items[$ _key];
        if (is_undefined(t) ) return t;
        
        // Eliminar.
        array_delete(order, t.index, 1);
        struct_remove(items, _key);
        
        Update();
        
        return (t);
    }
    
    /// @desc Como ciclar entre todos los elementos
    /// @param	{Function}	function	function(item, count, index) {}
    static Foreach = function(_function) 
    {   
        var i=0; repeat(array_length(order) )
		{
            var _key = order[i];
            var _item = items[$ _key];
			// Ciclar por cada objeto.
            _function(pocket_item_get(_item), item.count, i);
            
			i++;
        }
    }
    
    #region -- Misq
	/// @param	{String}	key
	/// @param	{Real}		index
	static __update = function(v, i)
	{
        var _item = items[$ v];
        _item.index = i;
    }
	
	/// @desc Actualiza los objetos de la Bag.
    static Update = function()
    {
        array_foreach(order, __update);
    }
    
    /// @param	{Bool}	[struct]	Si regresa un string (false) o un struct (true)
    static Export = function(_struct=false)
    {
        // Feather ignore all
        var _this = self;
        with ({})
        {
            version = __MALL_MY_VERSION;
            is = instanceof(_this);
            order = _this.order;
            items = _this.items;
            
			return (!_struct) ? json_stringify(self, true) : self; 
        }
    }
    
    /// @param {String, Struct} json
    static Import = function(_l)
    {
        if (_l.is != instanceof(self) ) exit;
        if (is_string(_l) ) _l = json_parse(_l);
		
        switch (__MALL_MY_VERSION)
        {
            default:
                order = _l.order;
                items = _l.items;
            break;
        }
        
        Update();
    }
    
	#endregion
}

/// @desc Crea una bolsa para agregar objetos
/// @param  {Struct.PocketBag} bag
function pocket_create_bag(_bag)
{
	if (!struct_exists(Systemall.bags, _bag.key) )
	{
		Systemall.bags[$ _bag.key] = _bag;
		#region TRACE
		if (__MALL_POCKET_TRACE) {
		show_debug_message($"M_Pocket: se ha creado bag {_bag.key}");
		}
		#endregion
	}
}

/// @desc Regresa un bolsillo a partir de la llave
/// @param  {String} key
/// @return {Struct.PocketBag}
function pocket_get_bag(_key)
{
    return (Systemall.bags[$ _key] );
}

/// @desc Inserta un bag en el indice seleccionado. De la siguiente manera {key, count, index}
/// @param {String} bag_key
/// @param {String} item_key
/// @param {Real}   [count] default=1
/// @param {Real}   [index] default=0
function pocket_bag_set(_bkey, _ikey, _count=1, _index=0)
{
    var _bag = pocket_get_bag(_bkey);
    // No salir de los limites
    return (_bag.Set(_ikey, clamp(_count, __MALL_POCKET_BAG_MIN, __MALL_POCKET_BAG_MAX), _index) );
}

/// @desc Agrega un objeto a un al bag indicado. Queda guardado de la siguiente manera {key, count, index}
/// @param  {String}    bag_key
/// @param  {String}    itemKey
/// @param  {Real}      [count]=1
function pocket_bag_add(_bkey, _ikey, _count=1)
{
    var _bag = pocket_bag_get(_bkey)
    return (_bag.Add(_ikey, _count) );
}

/// @desc   Regresa un objeto de un bolsillo
/// @param  {String}      bag_key    Llave del bolsillo
/// @param  {String,Real} [item]=0  Puede ser un indice o un itemKey
/// @return {Struct.PocketItem}
function pocket_bag_get(_bkey, _form=0)
{
    var _bag = pocket_get_bag(_bkey);
    
	// Si es a partir del indice
    return (_bag.Get(_form) );
}

/// @desc   Elimina el objeto en el bag 
/// @param  {String}    bag_key
/// @param  {String}    item_key
/// @return {Array}
function pocket_bag_remove(_bkey, _form)
{
    var _bag = pocket_get_bag(_bkey);
    return (_bag.Remove(_form) );
}

/// @desc Limpia una bag.
/// @param  {String}    bag_key
function pocket_bag_clean(_bkey)
{
	var _bag = pocket_get_bag(_bkey);
	return (_bag.Clean() );
}

// -- MISQ
/// @param {String}   bag_key
/// @param {Function} function
function pocket_bag_foreach(_bkey, _fn)
{
    var _bag = pocket_get_bag(_bkey);
    return (_bag.Foreach(_fn) );
}

/// @param	{String}	bag_key		Llave del bolsillo
/// @param	{Bool}		[struct]	Si regresa un string (false) o un struct (true)
function pocket_bag_export(_key, _struct=false)
{
    var _bag = pocket_get_bag(_key);
    return (_bag.Export(_struct) );
}

/// @param	{String}		bag_key	Llave del bolsillo
/// @param	{String,Struct}	json
function pocket_bag_import(_key, _json)
{
    var _bag = pocket_get_bag(_key);
    return (_bag.Import(_json) );
}

