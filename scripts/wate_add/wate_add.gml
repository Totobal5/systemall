/**
 * Function Description
 * @param {Struct.WateBattle}	battle Description
 * @param {Struct.PartyEntity}	entity Description
 */
function wate_add(battle, entity)
{

	// Añadir a la batalla
	array_push(battle.entitys, entity);
}

/**
 * Function Description
 * @param {Struct.WateBattle}	battle Description
 * @param {Array}	loot_array Description
 */
function wate_add_loot(battle, loot_array)
{
	battle.loot = loot_array;
}