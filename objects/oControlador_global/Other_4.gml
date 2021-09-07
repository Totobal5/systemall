/// @desc

mall_group_create("Default");

var _stat = (new mall_stat_control() ); /// @is {mall_stat_control}

_stat.MasterAdd("ps_max", undefined, function(old, base, lvl) {return (base * lvl) / max(1, (lvl - 1) ); } ).set_limits(0, 9999);
_stat.MasterAdd("pm_max", undefined, function(old, base, lvl) {return (base * lvl) / max(1, (lvl - 1) ); } ).set_limits(0, 9999);

_stat.MasterAdd("ps", "ps_max").set_lvlup(function(old, base, lvl) {return old; } );
_stat.MasterAdd("pm", "pm_max").set_lvlup(function(old, base, lvl) {return old; } );

_stat.MasterAdd("fue", undefined, function(old, base, lvl) {return round( ( (base * lvl) / 15) + 5); } ).set_limits(0, 255);
_stat.MasterAdd("int", undefined, function(old, base, lvl) {return round( ( (base * lvl) / 15) + 5); } ).set_limits(0, 255);

mall_group_add_stat(_stat);

var _state = (new mall_state_control() );

_state.MasterAdd("vivo"  , true );

_state.MasterAdd("veneno"   , false, ["fue"], [ [.5, function(stat, me) {return stat * me; } ] ]);
_state.MasterAdd("quemadura", false, ["fue"], [ [.5, function(stat, me) {return stat * me; } ] ]);

_state.MasterAdd("melancolia", false, ["int"], [ [.6, function(stat, me) {return stat * me; } ] ]);

mall_group_add_state(_state);

var _elemn = (new mall_element_control() );

_elemn.MasterAdd("fuego"   , [ ["quemadura", .2] ] );
_elemn.MasterAdd("polucion", [ ["veneno"   , .5] ] );

mall_group_add_element(_elemn);

/*
mall_create_itemtypes("Espadas" , ["katana", "sable"] );
mall_create_itemtypes("Pociones", ["pm", "ps", "fue", "intel"] );
mall_create_itemtypes("Frutas",   ["manzana", "naranja"] );

mall_create_pocket("Armas"      , ["Espadas"] );
mall_create_pocket("Consumibles", ["Pociones", "Frutas"] );


dark_init();
bag_init ();