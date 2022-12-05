/// @desc Añade una entidad al WateManager
/// @param {Struct.WateManager} battle Description
/// @param {Struct.PartyEntity} entity Description
function wate_add_entity(_battle, _entity)
{
	return (_battle.add(_entity) );
}