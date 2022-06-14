/// @param {String} part_key
function mall_get_part_bonus(_key){
    var _part  = mall_get_part(_key);
	var _bonus = _part.getItemtype(_key);	
	if (is_undefined(_bonus) ) return (numtype(0, NUMTYPE.REAL) );
	
    return (_bonus);
}