function WateManager(_key) : PartyGroup(_key) constructor
{
	// Experencia total juntada
	expTotal =  0;
	loot     = [];
	
	/// @desc Evento para cambiar de cuarto
	funRoomEnter = function() {}
	/// @desc Evento para salir de un cuarto
	funRoomExit  = function() {}
	
	static createLootable = function(_itemKey, _probability) constructor 
	{
		key  = _itemKey;
		prob = _probability;
	}
	
	
	/// @desc Function Description
	/// @param {string} itemKey      Description
	/// @param {real}   probability  Description
	static addLoot = function(_itemKey, _probability)
	{
		array_push(loot, new createLootable(_itemKey, _probability) );
		return self;
	}
	
	/// @param {real} [index]=0
	static removeLoot = function(_index=0)
	{
		array_delete(loot, _index, 1);
		return self;
	}
	
	
}