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


function MallStatEN(_key) : MallStat(_key) constructor 
{
	type = MALL_NUMTYPE.REAL;
	limitMin = 0;
	limitMax = 9999;
	
	// Nivel
	levelLimitMin = 0;
	levelLimitMax = 100;
	levelUp = function(_entity, _level) {
		return round((base * _level) + (_level+10) ); 
	}
	
	// Guardar valores
	saveable = true;
}

function MallStatEPM(_key) : MallStatEN(_key) constructor 
{
	limitMin = 0;
	limitMax = 999;
}

function MallStatEXP(_key) : MallStat(_key) constructor 
{
	type = MALL_NUMTYPE.REAL;
	limitMin = 0;
	limitMax = 999999;
	
	// Nivel
	levelLimitMin = 0;
	levelLimitMax = 100;
	levelUp = function(_entity, _level) {
		return round((base * _level * 8) + (_level*2) + 60); 
	}
	
	// Cuando sube de nivel se regresa al valor minimo
	iterator.configure(true, 1, true, -1);
	
	saveable = true;
}

function MallStatExt(_key) : MallStat(_key) constructor 
{
	type = MALL_NUMTYPE.REAL;
	limitMin = 0;
	limitMax = 999;
	
	// Nivel
	levelLimitMin = 0;
	levelLimitMax = 100;
	levelUp = function(_entity, _level) {
		return round( ((base * _level) / 40) + 5);
	}
}

/// @ignore
function mall_database()
{
	// Crear estadisticas
	mall_create_stat(STAT_EN , new MallStatEN( "UI.STAT.ENERGY") );
	mall_create_stat(STAT_EPM, new MallStatEPM("UI.STAT.ECTOPLASMA") );
	mall_create_stat(STAT_EXP, new MallStatEXP("UI.STAT.EXP") );
	mall_create_stat(STAT_FUERZA   , new MallStatExt("UI.STAT.FUERZA") );
	mall_create_stat(STAT_DEFENSA  , new MallStatExt("UI.STAT.DEFENSA") );
	mall_create_stat(STAT_FESPECIAL, new MallStatExt("UI.STAT.FESPECIAL") );
	mall_create_stat(STAT_DESPECIAL, new MallStatExt("UI.STAT.DESPECIAL") );
	mall_create_stat(STAT_VELOCIDAD, new MallStatExt("UI.STAT.VELOCIDAD") );
	
	mall_create_stat(STAT_CRITICO, new function() : MallStat("UI.STAT.CRITICAL") constructor {
		type = MALL_NUMTYPE.PERCENT; 
	
		limitMin = 0;
		limitMax = 100;

		levelLimitMin = 0;
		levelLimitMax = 100;
		levelUp = function(_entity, _level) {
			/// @self Struct.PartyStat
			var _velocidad = _entity.statGet(STAT_VELOCIDAD);
			return round( (_velocidad.peak / 25) );
		}
	}() );
	
	mall_create_stat(STAT_PODER,   new function() : MallStat("UI.STAT.PODER")    constructor {
		type = MALL_NUMTYPE.PERCENT;
		
		start = 0;
		limitMin = 0;
		limitMax = 200;
	
		levelLimitMin = 0;
		levelLimitMax = 100;
	}() );

}
