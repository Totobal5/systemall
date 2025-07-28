/// @desc Define una plantilla para una tienda.
/// @param {String} key
function MallShop(_key) : Mall(_key) constructor
{
    buy_multiplier = 1.0;
    sell_multiplier = 0.5;
    inventory = []; // Array con las llaves de los items que vende
    condition_event = "";
    
    /// @desc Configura la tienda a partir de un struct de datos.
    static FromData = function(_data)
    {
        buy_multiplier =	_data[$ "buy_multiplier"]	?? 1.0;
        sell_multiplier =	_data[$ "sell_multiplier"]	?? 0.5;
        inventory =			_data[$ "inventory"]		?? [];
        condition_event =	_data[$ "condition_event"]	?? "";
        
		return self;
    }
}

/// @desc Crea una plantilla de tienda desde data y la añade a la base de datos.
function mall_shop_create_from_data(_key, _data)
{
    if (struct_exists(Systemall.__shops, _key) ) return;
    
	var _shop = (new MallShop(_key)).FromData(_data);
    Systemall.__shops[$ _key] = _shop;
    array_push(Systemall.__shops_keys, _key);
}

/// @desc Devuelve la plantilla de una tienda.
function mall_get_shop(_key)
{
    return Systemall.__shops[$ _key];
}