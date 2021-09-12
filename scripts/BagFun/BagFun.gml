global._BAG = [];
global._BAG_DATA = ds_map_create();

#macro BAG global._BAG
#macro BAG_DATA global._BAG_DATA 

/// @desc Crea el almacenamiento para cada bolsillo
function bag_init() {
	
	// Crear los bolsillos
    repeat(array_length(MALL_POCKET_ORDER) ) array_push(BAG, [] ); 
    
    #region Crear objetos
    bag_item_add("OBJ.MANZANA", (bag_create_item("Comida" , 100, 80) ).SetSpecial("DARK.WSPEEL.HEAL1", [250 , false] ) );
    bag_item_add("OBJ.PESCADO", (bag_create_item("Comida" , 800, 80) ).SetSpecial("DARK.WSPEEL.HEAL1", [999 , false] ) );
    
    bag_item_add("ARM.ESPADA_COBRE" , (bag_create_item("Espadas", 2000, 1250) ).SetStat("fue", 10, "int",  20) );
	bag_item_add("ARM.ESPADA_VENENO", (bag_create_item("Espadas", 5000, 1250) ).SetStat("fue", 30, "int", -20) );
	
    #endregion
}

#region Data

/// @param {string} item_key
/// @param {__bag_class_item} item_id
function bag_item_add(_key, _item) {
    if (!bag_item_exists(_key) ) ds_map_add(BAG_DATA, _key, _item.SetInformation(_key) ); 
	
	return (_item );
}

/// @param item_key
function bag_item_exists(_key) {
    return (ds_map_exists(BAG_DATA, _key) );
}

/// @param item_key
/// @returns {__bag_class_item}
function bag_item_get(_key) {
    return BAG_DATA[? _key];
}

/// @returns {__group_class_stats}
function bag_item_get_stats(_key) {
    return (bag_item_get(_key) ).GetStats();    
}

/// @returns {__group_class_resistances}
function bag_item_get_resistances(_key) {
    return (bag_item_get(_key) ).GetResistances();      
}

/// @returns {__group_class_elements}
function bag_item_get_elements(_key) {
    return (bag_item_get(_key) ).GetElements();      
}

#endregion

#region Storage

/// @param item_key
/// @param amount
function bag_storage_add(_key, _amount = 1) {
    var _item = bag_item_get(_key);	/// @is {__bag_class_item}
    
    var _name = _item.GetName();
    var _type    = _item.type;
    var _subtype = _item.subtype;
    
    var _pocket = _item.pocket;
    var _index = _pocket.index;
    
    var _bag = bag_storage_get(_index); 
    
    for (var i = 0, _len = array_length(_bag); i < _len; i++) {
        var in = _bag[i];
        
        // Ya se encontraba en la bolsa
        if (in[0] == _key) {
            // Nueva cantidad
            _amount = in[1] + _amount;
            
            if (_amount > 0) {
                // Agregar objeto solo si hay espacio
                if (!bag_storage_is_full(_pocket, _amount) ) {
                	array_set(_bag, i, [_key, _amount, _type, _subtype, _name] );                            

                    return true;
                
                } else return false;
                
            } else {
                // Elimina item del inventario
                bag_storage_delete_by_index(_bag, i);
                
                return false;
            }
        }
    }
    
    // Si no existe entonces se agrega
    array_push(_bag, [_key, _amount, _type, _subtype, _name] );
    return true;
}

/// @param item_key
function bag_storage_delete(_key) {
    var _item = bag_item_get(_key);
    
    var _type   = _item.type, _subtype = _item.subtype, _name = _item.name;       

    var _pocket = mall_pocket_get_by_type(_type);
    var _bag    = bag_storage_get(_pocket.index);   
    
    for (var i = 0, _len = array_length(_bag); i < _len; i++) {
        var in = _bag[i];
        
        // Si existe el objeto eliminarlo
        if (in[0] == _key) return (bag_storage_delete_by_index(_bag, i) );
    }

    return noone;
}

/// @param pocket
/// @param item_index
/// @returns {array} Item que se ha eliminado
function bag_storage_delete_by_index(_pocket, i) {
    var _deleted = _pocket[i];
    
    array_delete(_pocket, i, 1);
    
    return _deleted;
}

/// @param pocket
/// @param [amount]
function bag_storage_is_full(_pocket, _amount = 0) {
    var _index = _pocket.index, _lim = _pocket.limit;
    
    return !(_lim == noone) && (bag_storage_count(_index) + _amount > _lim);
}

/// @param indice
/// @returns {array}
/// @desc Devuelve un storage
function bag_storage_get(_index) {
    return BAG[_index];
}

/// @param pocket
function bag_storage_count(_index) {
    return array_length(bag_storage_get(_index) );
}

#endregion

#region Manipulation

/// @param pocket
/// @param comparation
/// @param filter
function bag_storage_filter(_pocket, _comp, _filter) {
	var _bag = bag_storage_get(_pocket), _process = [];
	
	for (var i = 0, _len = array_length(_bag); i < _len; i++) {
		var in = _bag[i];
		
		if (_filter(_comp, in) ) array_push(_process, in);
	}
	
	return _process;
}

/// @param pocket
/// @param columns
/// @param {script} filter*
/// @returns {array}
/// @desc Devuelve un array de x dimensiones dependiendo de la division que se haga (Util para crear menus con varias listas.) el argumento de funcion permite
///		entregar los valores de la lista de distintas maneras.
function bag_storage_divide(_pocket, _column = 2, _filter) {
    if (is_undefined(_filter) ) _filter = function(v1) {return v1; } 
    
	var _index = mall_pocket_get_index(_pocket);
	var _bag   = bag_storage_get(_index);
	var _process = [], _pos = 0;

	var _col  = array_create(_column);
	
	for (var i = 0, _len = array_length(_bag); i < _len; i++) { // Columna
		var _row = [];
		
		_col[i] = _row;
		
		repeat(_column) {
		    var in = _bag[_pos];
		    
		    _col[i][_pos] = _filter(in);
		    
		    _pos++;
		}
	}
	
	return _col;
}

#endregion