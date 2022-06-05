/// @param {String} _key
/// @param {Real}	_max
/// @param {Struct}	_itemtype
/// @return {Struct.__PartyPartsParticle}
function __PartyPartsParticle(_key, _max, _itemtype) constructor {
    #region PRIVATE
	__key = _key;
	__number = _max;	// Repeticiones de atomo
	
	#endregion
	
	atoms = []; // Donde se almacenan las partes 
                    
    ypow = 1;	// Poder de la parte al usarlo con un equipo
    npow = 1;	// Poder de la parte al no usarlo con equipo
                    
    itemtype = _itemtype;	// Que objeto es capaz de equipar esta parte (type: [subtype] ) Ciclar principalmente

    damage = noone;	// No usar por mientras
	
	#endregion
	
	#region METHOD
	/// @param {Real} _atom_index
	/// @return {Struct.__PartyPartsAtom}
	static get = function(_atom_index) {
		return (atoms[_atom_index] );	
	}
	
	
	#endregion
}