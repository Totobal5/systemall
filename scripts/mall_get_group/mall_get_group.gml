/// @param {String} _group_key
/// @return {Struct.MallGroup}
function mall_get_group(_group_key) {
    return (global.__mall_groups_master.get(_group_key) ); 
}