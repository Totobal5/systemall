/// @param {String} _key
function pocket_item_exists(_key) {
    return (variable_struct_exists(global.__mall_pocket_database, _key) );
}