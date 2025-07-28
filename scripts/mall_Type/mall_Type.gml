// Añade un nuevo tipo al sistema.
function mall_create_type(_key, _value)
{
    if (mall_exists_type(_key) )
    {
		show_debug_message($"[Systemall] Advertencia: El tipo '{_key}' ya existe. El valor se añadirá al final.");
		
		array_push(Systemall.__types[$ _key], _value);
    }
	else
	{
		// Crear array y añadir a la lista de tipos.
		Systemall.__types[$ _key] = [_value];
		array_push(Systemall.__types_keys, _key);
	}
}

// Comprueba si existe un tipo en el sistema.
function mall_exists_type(_key)
{
	return variable_struct_exists(Systemall.__types, _key);
}


function mall_get_type(_key)
{
	return Systemall.__types[$ _key];	
}