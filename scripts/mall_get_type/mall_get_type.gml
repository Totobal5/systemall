/// @param {String} type_key
/// @return {Struct.MallType}
function mall_get_type(_KEY) 
{
    return (global.__mallTypesMaster[$ _KEY] ); 
}