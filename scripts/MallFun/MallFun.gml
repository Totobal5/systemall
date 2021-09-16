// -- Globales
#macro DARK_TYPE_BATTLE	"Batalla"
#macro DARK_TYPE_MAGIC	"Magia"

#macro MALL_FUN function(old, base, lvl)

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
	
	var _psmax = _stat.Add("ps_max", undefined, MALL_FUN {return round( ((base * lvl * 3) / 2) + lvl + 10); } ).SetRange(0, 9999);
	var _pmmax = _stat.Add("pm_max").Inherit(_psmax);

	_stat.Add("ps", _psmax).ToggleToMax(0, false);
	_stat.Add("pm", _pmmax).ToggleToMax(0, false);
	
	var _fue = _stat.Add("fue", undefined, MALL_FUN {return round( ( (base * lvl) / 15) + 5); } ).SetRange(0, 255);
	var _int = _stat.Add("int").Inherit(_fue);
	
	var _def = _stat.Add("def").Inherit(_fue);
	var _esp = _stat.Add("esp").Inherit(_fue);
	
	var _expmax = _stat.Add("exp_max", undefined, MALL_FUN {return round( (base * lvl * 7) + (lvl * 2) + 20); } ).SetRange(0, 999999);
	_stat.Add("exp", _expmax).ToggleToMin();
	
	// Unir resistencias a los elementos y estadisticas en las estadisticas ya que la clase de "stat" ya posee todo lo necesario!
	var _resfire = _stat.Add("fuego_rest", undefined, MALL_FUN {if (is_dataext(old) && is_dataext(base) ) return (old.Same(base) ); }, Data("0%") ).SetRange(0, 255);
	
	var _atkfire = _stat.Add("fuego_atak", undefined, MALL_FUN {return ( (base + lvl) * lvl / 2); } ).SetRange(0, 255);
	
	var _respolu = _stat.Add("polucion_rest").Inherit(_resfire); 
	var _atkpolu = _stat.Add("polucion_atak").Inherit(_atkfire);
	
	var _resvivo = _stat.Add("vivo_rest").Inherit(_resfire);
	
	var _restven = _stat.Add("veneno_rest")		.Inherit(_resfire);
	var _restqem = _stat.Add("quemadura_rest")	.Inherit(_resfire);
	var _restmel = _stat.Add("melancolia_rest")	.Inherit(_resfire);
	
	var _state = (new mall_state_control() );

	_state.Add("vivo", true).AddLinkArgument(_resvivo);
	
	var _ven = _state.Add("veneno"	  , false, [_fue, Data("-20%") ] ).AddLinkArgument(_restven);
	var _qem = _state.Add("quemadura" , false, [_fue, Data("-50%") ] ).AddLinkArgument(_restqem);
	var _mel = _state.Add("melancolia", false, [_int, Data("-50%") ] ).AddLinkArgument(_restmel);

	var _elemn = (new mall_element_control() );

	var _fire = _elemn.Add("fuego"   , [_qem, Data("20%") ] ).AddLinkArgument(_resfire, _atkfire);
	var _polu = _elemn.Add("polucion", [_ven, Data("50%") ] ).AddLinkArgument(_respolu, _atkpolu);

	var _parts = (new mall_part_control() );
	
	var _hand1 = _parts.Add("Mano izq.", ["Armas"], ["Espadas", Data("25%")], [_fue, _int] );
	var _hand2 = _parts.Add("Mano der.").Inherit(_hand1, true);
	
	mall_group_add_stat   (_stat );
	mall_group_add_state  (_state);
	mall_group_add_element(_elemn);
	mall_group_add_part   (_parts);	
}