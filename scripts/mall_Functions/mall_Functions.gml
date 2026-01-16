/// @desc Crear una función que se enlazará a un evento.
/// @param {String}		key
/// @param {Function}	function
function mall_create_function(_key, _fn)
{
	if (mall_exists_function(_key) )
	{
		__mall_print($"Advertencia: La función '{_key}' ya existe. El valor será re-escrito."); 	
	}
	
	Systemall.__functions[$ _key] = _fn;
}

/// @desc Obtiene la funcion del evento.
/// @param {String} key
/// @return {Function}
function mall_get_function(_key)
{
	static __default = function() {};
	return (struct_get(Systemall.__functions, _key) ?? __default);
}

/// @desc Comprueba si la funcion existe.
/// @param {String} key
function mall_exists_function(_key)
{
	return (struct_exists(Systemall.__functions, _key) );
}

function mall_add_asset(_key, _asset)
{
	if (mall_asset_exists(_key) )
	{
		__mall_print($"Advertencia: El asset '{_key}' ya existe. El valor será re-escrito.");
	}
	
	Systemall.__assets[$ _key] = _asset;
}

function mall_asset_get(_key)
{
	static __default = undefined;
	return (struct_get(Systemall.__assets, _key) ?? __default);
}

function mall_asset_exists(_key)
{
	return (struct_exists(Systemall.__assets, _key) );
}


#region PRIVATE

/// @ignore
function __mall_get_function_check_true(_key)
{
	static __default = function() {return true; };
	return variable_struct_get(Systemall.__functions, _key) ?? __default;
}

/// @ignore
function __mall_get_function_check_false(_key)
{
	static __default = function() {return false; }
	return variable_struct_get(Systemall.__functions, _key) ?? __default;
}

/// @desc Funcion default para que las estadisticas suban de nivel.
/// @ignore
function __mall_get_function_stat_level_up(_key)
{
	static __default = function(_stat) {
		return _stat.base_value + (level * 2);
	};
	return variable_struct_get(Systemall.__functions, _key) ?? __default;
}

#endregion