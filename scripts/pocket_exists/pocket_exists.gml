/// @param {String} pocket_key
function pocket_exists(_key) 
{
    return (variable_struct_exists(global.__mall_pocket_database, _key) );
}