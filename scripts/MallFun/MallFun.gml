// -- Globales
#macro DARK_TYPE_BATTLE	"Batalla"
#macro DARK_TYPE_MAGIC	"Magia"

/// @desc PLANTILLA PARA INICIAR EL SISTEMA!
function mall_init() {
	mall_create_itemtypes("Armas"  , ["Espadas", "Arcos"   , "Escudos"] );
	mall_create_itemtypes("Objetos", ["Comida" , "Pociones"] );
	
	mall_create_dark("Batalla", ["Ataque", "Defensa", "Objeto"] );
	mall_create_dark("Magia"  , ["Blanca", "Negra"  , "Roja"  ] );
	
	mall_create_pocket("Armas"  , ["Armas"  ] );
	mall_create_pocket("Objetos", ["Objetos"] );
	
	mall_group_init("Default");
	
	var _stat = (new mall_stat_control() ); /// @is {mall_stat_control}
	
	var _psmax = _stat.Add("ps_max", undefined, function(old, base, lvl) {return round( ((base * lvl * 3) / 2) + lvl + 10); } ).SetRange(0, 9999);
	var _pmmax = _stat.Add("pm_max").Inherit(_psmax);

	_stat.Add("ps", _psmax).ToggleToMax(0, false);
	_stat.Add("pm", _pmmax).ToggleToMax(0, false);
	
	var _fue = _stat.Add("fue", undefined, function(old, base, lvl) {return round( ( (base * lvl) / 15) + 5); } ).SetRange(0, 255);
	var _int = _stat.Add("int").Inherit(_fue);
	
	var _def = _stat.Add("def").Inherit(_fue);
	var _esp = _stat.Add("esp").Inherit(_fue);
	
	var _expmax = _stat.Add("exp_max", undefined, function(old, base, lvl) {return round( (base * lvl * 7) + (lvl * 2) + 20); } ).SetRange(0, 999999);
	_stat.Add("exp", _expmax).ToggleToMin();
	
	var _state = (new mall_state_control() );
	
	_state.Add("vivo", true);
	
	var _ven = _state.Add("veneno"    , false, [_fue, .2] );
	var _qem = _state.Add("quemadura" , false, [_fue, .5] );
	
	_state.Add("melancolia", false, [_int, .5] );
	
	var _elemn = (new mall_element_control() );
	
	_elemn.Add("fuego"   , [_ven, .2] );
	_elemn.Add("polucion", [_qem, .5] );
	
	var _parts = (new mall_part_control() );
	
	var _hand1 = _parts.Add("Mano izq.", ["Armas"], ["Espadas", 2.5], undefined, [_fue, _int] );
	var _hand2 = _parts.Add("Mano der.").Inherit(_hand1);
	
	mall_group_add_stat   (_stat );
	mall_group_add_state  (_state);
	mall_group_add_element(_elemn);
	mall_group_add_part   (_parts);	
}