/// @desc Function Description
/// @param {any*} _KEY Description
/// @param {any*} _SET Description
/// @returns {struct} Description
function wate_create(_KEY, _SET)
{
	static database = MallDatabase().wate.templates;
	var _pack = new WateBattle(_KEY);
	// Establecer pack
	if (_SET) global.__mallWateCombats = _pack;
	return (_pack);
}