/// @param _key
/// @param [_component]
function dark_get(_key, _component) {
    return (is_undefined(_component) ) ? 
		global.__mall_dark_database[$ _key] : 
		global.__mall_dark_database[$ _key][$ _component];
}