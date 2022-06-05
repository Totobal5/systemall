/// @param {String} _key
/// @return {Struct.PocketItem}
function pocket_item_get(_key) {
    return (global.__mall_pocket_database[$ _key] );
}
