// -- Globales
#macro DARK_TYPE_BATTLE	"Batalla"
#macro DARK_TYPE_MAGIC	"Magia"

#macro MALL_FUN function(old, base, lvl)

#region Is
/// @param group_id
function is_mall_group(_class) {
    return (is_struct(_class) && _class.__is == "MALL_GROUP_INTERN");
}

/// @param mall_class
/// @returns {bool}
function is_mall_stat   (_class) {
    return ( (is_struct(_class) ) && (_class.__is == "MALL_STAT_INTERN") );
}

/// @param mall_class
/// @returns {bool}
function is_mall_state  (_class) {
    return ( (is_struct(_class) ) && (_class.__is == "MALL_STATE_INTERN") );
}

/// @param mall_class
/// @returns {bool}
function is_mall_element(_class) {
    return ( (is_struct(_class) ) && (_class.__is == "MALL_ELEMENT_INTERN") );   
}

/// @param mall_class
/// @returns {bool}
function is_mall_part   (_class) {
    return ( (is_struct(_class) ) && (_class.__is == "MALL_PART_INTERN") );     
}

#endregion

/// @desc pm, ps
function mall_custom_levelup_stat1(old, base, lvl)	{
	return ((3 * lvl * base) + (2 * lvl) + 20) div 2; 	
}

/// @desc exp
function mall_custom_levelup_stat2(old, base, lvl)	{
	return round( (base * lvl * 7) + (lvl * 2) + 20);	
}

function mall_custom_levelup_stat3(old, base, lvl)	{
	return (75 + (lvl * base) ) div 15;	
}

function mall_custom_levelup_res(old, base, lvl)	{
	if (is_data(old) && is_data(base) ) {	
		return (old.Same(base) );	
	}
}

function mall_custom_levelup_ele(old, base, lvl)	{
	return round( (base * lvl) /  (lvl * 2) - 1); 	
}

/// @desc PLANTILLA PARA INICIAR EL SISTEMA!
function mall_init() {
	mall_create_itemtypes("Armas"  , "Espadas", "Arcos", "Escudos");
	mall_create_itemtypes("Cascos" , "Boina"  , "Sombrero", "Cascos");
	mall_create_itemtypes("Objetos", "Comida" , "Pociones");
	
	mall_create_dark("Batalla", ["Ataque", "Defensa", "Objeto"] );
	mall_create_dark("Magia"  , ["Blanca", "Negra"  , "Roja"  , "Verde"] );
	
	mall_create_pocket("Armas"  , ["Armas"  ] );
	mall_create_pocket("Objetos", ["Objetos"] );
	
	mall_create_stats(
		"ps_max", "pm_max", "exp_max", "ps", "pm", "exp",
		"fue", "int", "def", "esp", "vel",
		
		"fuego_rest", "fuego_atak"	  , "polucion_rest"  , "polucion_atak",	// Elementos
		"vivo_rest" , "quemadura_rest", "melancolia_rest"					// Resistencias
	);
	
	mall_create_states  ("vivo" , "veneno", "quemadura", "melancolia");
	mall_create_elements("fuego", "polucion");
	
	mall_create_parts("Cabeza", "Mano izq.", "Mano der.", "Torso", "Piernas", "Pies");
	
	
	var _group = mall_group_init("Default");

	#region Estadisticas _name, _start = 0, _master, _formula
	var _psmax = mall_stat_customize("ps_max", 0, undefined, mall_custom_levelup_stat1).Limits(0, 9999);
	var _pmmax = mall_stat_customize("pm_max").Inherit(_psmax);
	
	var _expmax = mall_stat_customize("exp_max", 0, undefined, mall_custom_levelup_stat2).Limits(0, 999999);

	var _ps  = mall_stat_customize("ps" , _psmax ).ToMax(false)	.Ignore();
	var _pm  = mall_stat_customize("pm" , _pmmax ).ToMax(false)	.Ignore();
	var _exp = mall_stat_customize("exp", _expmax).ToMin()		.Ignore();
	
	var _fue = mall_stat_customize("fue", 0, undefined, mall_custom_levelup_stat3).Limits(0, 999);
	var _int = mall_stat_customize("int").Inherit(_fue);

	var _def = mall_stat_customize("def").Inherit(_fue);
	var _esp = mall_stat_customize("esp").Inherit(_fue);
	
	var _spd = mall_stat_customize("vel").Inherit(_fue);

	// Unir resistencias a los elementos y estadisticas en las estadisticas ya que la clase de "stat" ya posee todo lo necesario!
	var _resfire = mall_stat_customize("fuego_rest", (new Data(0) ), undefined, mall_custom_levelup_res).Limits(0, 255);
	
	var _atkfire = mall_stat_customize("fuego_atak", 0, undefined, mall_custom_levelup_ele).Limits(0, 999);
	
	var _respolu = mall_stat_customize("polucion_rest").Inherit(_resfire); 
	var _atkpolu = mall_stat_customize("polucion_atak").Inherit(_atkfire);
	
	var _restvivo = mall_stat_customize("vivo_rest").Inherit(_resfire).Ignore();
	
	var _restven = mall_stat_customize("veneno_rest")		.Inherit(_resfire);
	var _restqem = mall_stat_customize("quemadura_rest")	.Inherit(_resfire);
	var _restmel = mall_stat_customize("melancolia_rest")	.Inherit(_resfire);
	
	#endregion
	var _vivo = mall_state_customize("vivo", true, _restvivo);
	
	var _ven = mall_state_customize("veneno", false, _restven, "Envenenado")
	.AddAffect(_fue, (new Data(-20) ), _ps, (new Data(-20) ) )
	.Process  (15, 17, 1, 9, 1, "DARK.GSPELL.VENENO");

	var _qem = mall_state_customize("quemadura", false, _restqem, "Quemado")
	.AddAffect(_fue, (new Data(-50) ) )
	.Process  (50, 50, 0, 3, 1, "DARK.GSPELL.QUEMADURA");
	
	var _mel = mall_state_customize("melancolia", false, _restmel, "Melancolico")
	.AddAffect(_int, (new Data(-50) ) )
	.Process  (20, 50, 5, 6, 2, "DARK.GSPELL.MELANCOLIA");
	
	var _fire = mall_element_customize("fuego"	 , _atkfire, _resfire, _qem, (new Data(20) ) );
	var _polu = mall_element_customize("polucion", _atkpolu, _respolu, _ven, (new Data(50) ) );

	var _hand1 = mall_part_customize("Mano izq.", "Armas", true).BonusItemsub("Espadas", (new Data(25) ) );
	var _hand2 = mall_part_customize("Mano der.").Inherit(_hand1, true);
	
	var _head = mall_part_customize("Cabeza", "")
}


