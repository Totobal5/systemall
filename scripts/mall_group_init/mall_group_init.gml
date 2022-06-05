/// @param {Array.String} [_delete_stats]
/// @param {Array.String} [_delete_states]
/// @param {Array.String} [_delete_parts]
/// @param {Array.String} [_delete_elements]
/// @desc Inicia todo los componentes del grupo actual. Permite eliminar caracteristicas
function mall_group_init(_delete_stats, _delete_states, _delete_parts, _delete_elements) {
	global.__mall_actual_group.createStats (_delete_stats );
    global.__mall_actual_group.createStates(_delete_states);
    global.__mall_actual_group.createParts (_delete_parts );
    
    global.__mall_actual_group.createElements(_delete_elements);
}