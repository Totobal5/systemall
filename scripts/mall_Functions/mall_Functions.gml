function mall_create_function(_key, _fn)
{
	Systemall.__functions[$ _key] = _fn;
}

function mall_get_function(_key)
{
	static __default = function() {};
	return variable_struct_get(Systemall.__functions, _key) ?? __default;
}

function mall_exists_function(_key)
{
	return variable_struct_exists(Systemall.__functions, _key);
}

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