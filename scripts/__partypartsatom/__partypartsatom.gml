/// @param {Bool} _usable
/// @param {Real} _index
/// @param {Real} _max
/// @return {Struct.__PartyPartsAtom}
function __PartyPartsAtom(_usable, _index, _max) constructor {
	#region PRIVATE
	__number = _index;
	__max = _max;		// Cuantos objetos puede equipar al mismo tiempo	
	
	#endregion
	
    equipped = array_create(_max, undefined);	// Donde se almacenan los objetos que lleva
    previous = array_create(_max, undefined);	// Objeto anterior que se llevo
                        
    usable = _usable; // Si puede usarse al inciar o no
}