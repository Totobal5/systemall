/// @param {String} pocket_key
/// @return {Struct.PocketItem}
function pocket_get(_KEY) 
{
    return (global.__mallPocketData[$ _KEY] );
}