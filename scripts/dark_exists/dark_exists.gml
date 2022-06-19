/// @param {String} dark_key
/// @return {Bool}
function dark_exists(_key) {
    return (variable_struct_exists(global.__mall_dark_database, _key) );
}