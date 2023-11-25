/// @desc Crea un comando dark y lo guarda en el sistema
/// @param {Struct.DarkCommand} command
function dark_create_command(_command) 
{
    if (!struct_exists(Systemall.dark, _command.key) ) 
    {
        Systemall.dark[$ _command.key] = _command;
    }
}

/// @param {string} key
/// @param {Struct.DarkEffect} effect
function dark_create_effect(_key, _effect)
{
    if (!struct_exists(Systemall.dark, _key) )
    {
        Systemall.dark[$ _key] = _effect;
    }
}

/// @param {String} key
/// @return {Struct.DarkCommand, Struct.DarkEffect}
function dark_get(_key)
{
    return (Systemall.dark[$ _key] );
}

/// @param {String} key
function dark_exists(_key)
{
    return (struct_exists(Systemall.dark, _key) );
}