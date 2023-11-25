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
    
    /// @desc Struct que guarda la informacion de los objetos agregados
    /// @param {String} item
    /// @param {Real}   count
    /// @param {Real}   index
    static itemComponent = function(_item, _count, _index) constructor
    {
        item  = _item;
        count = _count;
        index = _index;
    }
    
    /// @desc Como obtener un elemento de la bag.
    /// @param {String} item_key
    static get = function(_key) 
    {
        return (items[$ _key] );
    }
    
    /// @desc Agrega o reposiciona un elemento en la posicion dada
    static set = function(_key, _count, _index=0)
    {
        static Find = function(v, i) {return (v == key); };
        var _rt = {
            result: true, item: undefined, left: 0
        };
        
        // No existe y crear
        if (!struct_exists(items, _key) ) 
        {
            items[$ _key] = new itemComponent(_key, _count, _index);
        } 
        // Insertar
        else {
            // Obtener indice
            var _rem = array_find_index(order, method({_key}, Find) );
            // Eliminar
            array_delete(order, _rem, 1);
            
            // Insertar en nueva posicion
            items[$ _key].count = _count;
        }
        
        array_set(order, _index, _key);
        
        // Actualizar items
        update();
        
        return _rt;
    }
    
    /// @desc Agrega elementos
    /// @param {String} itemKey
    /// @param {Real}   count
    static add = function(_itemKey, _count) 
    {
        var _return = {result: true, item: undefined, left: 0}
        // Si no existe anteriormente agregar
        if (!struct_exists(items, _itemKey) ) {
            array_push(order, _itemKey);
            // Comprobar limites
            if (_count < limitMin) {
                _return.left =   _count*-1; // Se devuelven todos
                _return.result = false;
                // Error! -> salir
                return (_return);
            }
            else if (_count > limitMax) {
                _return.left = limitMax - _count; 
            }
            
            items[$ _itemKey] = new itemComponent(_itemKey, _count, array_length(order)-1);
            _return.result = true;
            _return.item =   _itemKey;
        }
        else {
            var _itemSum = items[$ _itemKey] + _count;
            // Comprobar limite menor
            if (_itemSum <= limit[0] ) {
                var _t = remove(_itemKey);
                _return.result = false;
                _return.item   = _t;
            } 
            // Comprobar limite superior
            else if (_itemSum > limit[1] ) {
                items[$ _itemKey].count = limit[1];
                var _t = limit[1] - _itemSum;
                _return.left   = _t;
            } 
            // Agregar
            else {
                items[$ _itemKey].count = _itemSum;
            }
        }
        
        return (_return);
    }
    
    /// @desc Como borrar elementos guardados
    /// @param {String} itemKey
    static remove = function(_itemKey) 
    {
        var t = items[$ _itemKey];
        if (is_undefined(t) ) return t;
        
        // Eliminar
        array_delete(order, t.index, 1);
        struct_remove(items, _itemKey);
        
        update();
        
        return (t);
    }
    
    /// @desc Como ciclar entre todos los elementos
    /// @param {Function} function  function(item, count, index) {}
    static foreach = function(_function) 
    {   
        var i=0; repeat(array_length(order) ) {
            var _key  = order[i];
            var _item = items[$ _key];
            _function(pocket_item_get(_item), item.count, i);
            i = i+1;
        }
    }
    
    #region -- Misq
    static update = function()
    {
        array_foreach(order, function(v, i) {
            var _item = items[$ v];
            _item.index = i;
        });
    }
    
    /// @param {Bool} [struct] Si regresa un string (false) o un struct (true)
    static export = function(_struct=false)
    {
        // Feather ignore all
        var _this = self;
        with ({})
        {
            version = __MALL_MY_VERSION;
            is =    instanceof(_this);
            order = _this.order;
            items = _this.items;
            return (!_struct) ? json_stringify(self, true) : self; 
        }
    }
    
    /// @param {String, Struct} json
    static import = function(_l)
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
        
        update();
        
    }
    
	#endregion
}

/// @desc Crea una bolsa para agregar objetos
/// @param  {Struct.PocketBag} bag
function pocket_create_bag(_bag)
{
	if (!struct_exists(Systemall.bags, _bag.key) ) {
		Systemall.bags[$ _bag.key] = _bag;
		#region TRACE
		if (__MALL_POCKET_TRACE) {
		show_debug_message($"MallRPG: se ha creado bag {_bag.key}");
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
    return (_bag.set(
        _ikey, 
        clamp(_count, __MALL_POCKET_BAG_MIN, __MALL_POCKET_BAG_MAX), 
        _index
    ));
}

/// @desc Agrega un objeto a un al bag indicado. Queda guardado de la siguiente manera {key, count, index}
/// @param  {String}    bag_key
/// @param  {String}    itemKey
/// @param  {Real}      [count]=1
function pocket_bag_add(_bkey, _ikey, _count=1)
{
    var _bag = pocket_bag_get(_bkey)
    return (_bag.add(_ikey, _count) );
}

/// @desc   Regresa un objeto de un bolsillo
/// @param  {String}      bag_key    Llave del bolsillo
/// @param  {String,Real} [item]=0  Puede ser un indice o un itemKey
/// @return {Struct.PocketItem}
function pocket_bag_get(_bkey, _form=0)
{
    var _bag = pocket_get_bag(_bkey);
    // Si es a partir del indice
    return (_bag.get(_form) );
}

/// @desc   Elimina el objeto en el bag 
/// @param  {String}    bag_key
/// @param  {String}    item_key
/// @return {Array}
function pocket_bag_remove(_bkey, _form)
{
    var _bag = pocket_get_bag(_bkey);
    return (_bag.remove(_form) );
}

/// @desc Limpia una bag.
/// @param  {String}    bag_key
function pocket_bag_clean(_bkey)
{
	var _bag = pocket_get_bag(_bkey);
	return (_bag.clean() );
}

// -- MISQ
/// @param {String}   bag_key
/// @param {Function} function
function pocket_bag_foreach(_bkey, _fn)
{
    var _bag = pocket_get_bag(_bkey);
    return (_bag.foreach(_fn) );
}

/// @param {String} bagKey  Llave del bolsillo
/// @param {Bool} [struct] Si regresa un string (false) o un struct (true)
function pocket_bag_export(_key, _struct=false)
{
    var _bag = pocket_get_bag(_key);
    return (_bag.export(_struct) );
}

/// @param {String}        bagKey  Llave del bolsillo
/// @param {String,Struct} json
function pocket_bag_import(_key, _json)
{
    var _bag = pocket_get_bag(_key);
    return (_bag.import(_json) );
}

