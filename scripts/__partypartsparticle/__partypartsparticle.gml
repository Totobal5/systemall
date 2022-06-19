/// @param {Real}	number
/// @param {Struct}	itemtype
/// @return {Struct.__PartyPartsParticle}
function __PartyPartsParticle(_max, _itemtype) constructor 
{
    #region PRIVATE
	__number = _max;	// Repeticiones de atomo
	
	#endregion
	
	atoms = []; // Donde se almacenan las partes 
                    
    ypow = 1;	// Poder de la parte al usarlo con un equipo
    npow = 1;	// Poder de la parte al no usarlo con equipo
                    
    itemtype = _itemtype;	// Que objeto es capaz de equipar esta parte (type: [subtype] ) Ciclar principalmente
    damage = noone;	// No usar por mientras
	
	#endregion
	
	#region METHOD
	/// @param {Real} atom_index
	/// @return {Struct.__PartyPartsAtom}
	static get = function(_atom_index) {
		return (atoms[_atom_index] );	
	}
	
	#endregion
}