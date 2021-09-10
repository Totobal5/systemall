/// @desc

mall_create_itemtypes("Armas", ["Espadas", "Arcos", "Escudos"] );

mall_group_init("Default");

var _stat = (new mall_stat_control() ); /// @is {mall_stat_control}

var _psmax = _stat.Add("ps_max", undefined, function(old, base, lvl) {return (base * lvl) / max(1, (lvl - 1) ); } ).SetRange(0, 9999);
var _pmmax = _stat.Add("pm_max").Inherit(_psmax);

_stat.Add("ps", _psmax);
_stat.Add("pm", _pmmax);

var _fue = _stat.Add("fue", undefined, function(old, base, lvl) {return round( ( (base * lvl) / 15) + 5); } ).SetRange(0, 255);
var _int = _stat.Add("int").Inherit(_fue);

var _def = _stat.Add("def").Inherit(_fue);
var _esp = _stat.Add("esp").Inherit(_fue);

var _state = (new mall_state_control() );

_state.Add("vivo", true);

var _ven = _state.Add("veneno"    , false, [_fue, .2] );
var _qem = _state.Add("quemadura" , false, [_fue, .5] );

_state.Add("melancolia", false, [_int, .5] );

var _elemn = (new mall_element_control() );

_elemn.Add("fuego"   , [_ven, .2] );
_elemn.Add("polucion", [_qem, .5] );

var _parts = (new mall_part_control() );

var _hand1 = _parts.Add("Mano izq.", ["Armas", ["Espadas"] ], [_fue, _int] );
var _hand2 = _parts.Add("Mano der.").Inherit(_hand1);

mall_group_add_stat   (_stat );
mall_group_add_state  (_state);
mall_group_add_element(_elemn);
mall_group_add_part   (_parts);

/*
dark_init();
bag_init ();