/// @param	{String}	element_key		Llave del elemento
/// @param	{Function}	onHit_event		evento al ser atacado
/// @param	{Function}	onAttack_event	evento al atacar
/// @param	{Bool}		[display]			
/// @param	{String}	[display_key]		
/// @param	{Function}	[display_method]	function() {return string; }
/// @returns {Struct.MallElement}
function mall_customize_element(_key, _on_hit, _on_attack, _display, _display_key, _display_method) 
{
    var _element = mall_get_element(_key);
	_element.setDisplay(_display, _display_key, _display_method);
	_element.setOnHit(_on_hit);
	_element.setOnAttack(_on_attack);
	
	// Obetener relacionados
	return (_element.getRelated() );
}