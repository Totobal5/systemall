function WateBattle(_KEY) : PartyGroup(_KEY) constructor
{
	loot = []	// Loot table [ [item_key, probability] ]
	
	/// @desc Evento para cambiar de cuarto
	funRoomEnter = function() {}
	/// @desc Evento para salir de un cuarto
	funRoomExit  = function() {}
	
	static createLootable = function(_itemKey, _probability) constructor 
	{
		key  = _itemKey;
		prob = _probability;
	}
	
	static addLoot = function(_itemKey, _prob)
	{
		array_push(loot, new createLootable(_itemKey, _prob) );
		return self;
	}
}