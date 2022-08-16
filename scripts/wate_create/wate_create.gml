/**
 * Function Description
 * @param {String}	pack_key Description
 * @param {Bool}	[flags]  Description
 * @return {Struct.WatePack}
 */
function wate_create(_KEY, _SET)
{
	var _pack = new WateBattle(_KEY);
	// Establecer pack
	if (_SET) global.__mallWateCombats = _pack;
	return (_pack);
}