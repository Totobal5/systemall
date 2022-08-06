/// @param {String} equipment_key
function mall_equipment_bonus(_KEY)
{
    var _part  = mall_get_equipment(_KEY);
	var _bonus = _part.getBonus(_KEY);
	
	return (is_undefined(_bonus) ? [0, 0] : _bonus);
}