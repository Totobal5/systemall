/// @param {String} pocket_key
/// @return {Struct.PocketItem}
function pocket_get(_key) 
{
    return (global.__mall_pocket_database[$ _key] );
}