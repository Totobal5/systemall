/// @param {String} pocket_key
function pocket_exists(_key) 
{
    return (variable_struct_exists(global.__mallPocketData, _key) );
}