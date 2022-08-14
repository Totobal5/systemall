/// @return {Struct.__PartyEquipmentAtom}
function __PartyEquipmentAtom(_KEY, _EQUIPMENT) constructor 
{
	__is = instanceof(self);

	key = _KEY;
	displayKey = _EQUIPMENT.displayKey;
	displayMethod = method(,_EQUIPMENT.displayMethod);
	
	items = _EQUIPMENT.items;
	active = true;	// Si se puede usar
	// Weak ref
	equipped = undefined;	// Donde se almacenan los objetos que lleva
	previous = undefined;	// Objeto anterior que se llevo
	
	eventCompare = _EQUIPMENT.eventCompare;
	
	static send = function() 
	{
		return {
			key: other.key,
			active: other.active,
			
			equipped: other.equipped,
			previous: other.equipped,
		};
	}
}