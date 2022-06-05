/// @param {String, Real}	_name	String o Real
/// @desc Devuelve un entidad de party
/// @return {Struct.PartyEntity}
function party_get(_name) {
	return (global.__mall_party.get(_name) );
}