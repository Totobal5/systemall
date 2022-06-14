/// @param action_key
/// @desc Obtiene los sub-acciones de esta accion
/// @return {Struct.MallAction}
function mall_get_action(_key) {
    return (global.__mall_actions_index[$ _key] );
}