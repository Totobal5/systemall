#macro STAT_EN   "EN"
#macro STAT_EPM  "EPM"
#macro STAT_EXP  "EXP"

#macro STAT_PODER       "PODER"
#macro STAT_FUERZA      "FUERZA"
#macro STAT_DEFENSA     "DEFENSA"
#macro STAT_FESPECIAL   "FUE ESPECIAL"
#macro STAT_DESPECIAL   "DEF ESPECIAL"
#macro STAT_VELOCIDAD   "VELOCIDAD"
#macro STAT_CRITICO     "SUERTE"

#macro SLOT_ARMA   "ARMA"
#macro SLOT_CUERPO "CUERPO"
#macro SLOT_ACCESORIO1 "ACCESORIO1"     // Accesorios 
#macro SLOT_ACCESORIO2 "ACCESORIO2"     // Accesorios importantes

#macro STATE_VIVO       "VIVO"
#macro STATE_VENENO     "VENENO"
#macro STATE_QUEMADO    "QUEMADO"
#macro STATE_CONGELADO  "CONGELADO"
#macro STATE_DORMIDO    "DORMIDO"
#macro STATE_VORTEX     "CONSUMIDO"

#macro TYPE_ALL  "ALL"
#macro TYPE_BOSS "BOSS"

/// @ignore
function mall_database()
{
	// Crear estadisticas
	mall_add_stat (STAT_EN, STAT_EPM, STAT_EXP, STAT_PODER, STAT_FUERZA, STAT_DEFENSA, STAT_FESPECIAL, STAT_DESPECIAL, STAT_VELOCIDAD, STAT_CRITICO);
	mall_add_state(STATE_VIVO, STATE_VENENO, STATE_QUEMADO, STATE_CONGELADO, STATE_DORMIDO, STATE_VORTEX);
	mall_add_slot (SLOT_ARMA , SLOT_CUERPO , SLOT_ACCESORIO1, SLOT_ACCESORIO2);
	
	mall_add_type (TYPE_ALL, TYPE_BOSS);
	
	#region Stats
	mall_customize_stat(STAT_EN, 0, MALL_NUMTYPE.REAL, [0, 9999], "UI.STAT.ENERGY").setLevel(0, 100, "fStatLevel01").setFunEquip("").toggleSValue();
	mall_inherit_stat  (STAT_EPM, STAT_EN, true, true, "UI.STAT.ECTOPLASMA").setFunEquip("").toggleSValue();
	mall_customize_stat(STAT_EXP, 0, MALL_NUMTYPE.REAL, [0, 99999] , "UI.STAT.EXP").iterSetMin(1, true, -1).setLevel(0, 100, "fStatLevel02").setFunEquip("").toggleSValue();
	
	mall_customize_stat(STAT_FUERZA, 0, MALL_NUMTYPE.REAL, [0, 999], "UI.STAT.FUERZA").setLevel(0, 100, "fStatLevel03");
	mall_inherit_stat  (STAT_DEFENSA  , STAT_FUERZA, true, true,   "UI.STAT.DEFENSA");
	mall_inherit_stat  (STAT_FESPECIAL, STAT_FUERZA, true, true, "UI.STAT.FESPECIAL");
	mall_inherit_stat  (STAT_DESPECIAL, STAT_FUERZA, true, true, "UI.STAT.DESPECIAL");
	mall_inherit_stat  (STAT_VELOCIDAD, STAT_FUERZA, true, true, "UI.STAT.VELOCIDAD");

	mall_customize_stat(STAT_CRITICO, 0, MALL_NUMTYPE.PERCENT, [0, 100], "UI.STAT.CRITICAL").setLevel(0, 100, "fStatLevel04");
	
	mall_customize_stat(STAT_PODER  , 0, MALL_NUMTYPE.PERCENT, [0, 200], "UI.STAT.PODER");
	
	#endregion
	
	#region States
	mall_customize_state(STATE_VIVO, true, 100, 1, false, "UI.STATE.VIVO");
	mall_customize_state(STATE_VENENO   , false, 20, -1,  true,   "UI.STATE.VENENO").setFunTurn( "fStateVenenoS");
	mall_customize_state(STATE_QUEMADO  , false, 42, -1, true,   "UI.STATE.QUEMADO").setFunTurn("fStateQuemadoS");
	mall_customize_state(STATE_DORMIDO  , false, 25, -1, true,   "UI.STATE.DORMIDO").setFunTurn("fStateDormidoS");
	mall_customize_state(STATE_CONGELADO, false, 10, -1, true, "UI.STATE.CONGELADO").setFunTurn("fStateCongeladoS");
	mall_customize_state(STATE_VORTEX   , false, 10, -1, true, "UI.STATE.VORTEXT"  ).setFunTurn("fStateVortex");
	#endregion
	
	#region Slot
	mall_customize_slot(SLOT_ARMA  , true,   "UI.SLOT.ARMA");
	mall_customize_slot(SLOT_CUERPO, true, "UI.SLOT.CUERPO");
	mall_customize_slot(SLOT_ACCESORIO1, true, "UI.SLOT.ACCESORIO.1");
	mall_customize_slot(SLOT_ACCESORIO2, true, "UI.SLOT.ACCESORIO.2");
	

	#endregion
}
