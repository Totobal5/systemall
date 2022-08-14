/// @param {String} dark_key
/// @return {Bool}
function dark_exists(_KEY) 
{
    return (variable_struct_exists(global.__mallDarkData, _KEY) );
}