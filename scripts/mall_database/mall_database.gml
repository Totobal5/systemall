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


function MallStatEN()  : MallStat() constructor 
{
	key  = "UI.STAT.ENERGY";
	type = MALL_NUMTYPE.REAL;
	limitMin = 0;
	limitMax = 9999;
	
	// Nivel
	levelLimitMin = 0;
	levelLimitMax = 100;
	funLevel  = function(stat, level) {return round( (base * level) + (level+10) ); }
	
	// Guardar valores
	saveValue = true;
}

function MallStatEPM() : MallStatEN() constructor 
{
	key = "UI.STAT.ENERGY";
}

function MallStatEXP() : MallStat() constructor 
{
	key  = "UI.STAT.EXP";
	type = MALL_NUMTYPE.REAL;
	limitMin = 0;
	limitMax = 999999;
	
	// Nivel
	levelLimitMin = 0;
	levelLimitMax = 100;
	funLevel = function(stat, level) {return round( (base * level * 8) + (level*2) + 60); }
	
	// Cuando sube de nivel se regresa al valor minimo
	iterSetMin(1, true, -1);
	
	saveValue = true;
}

function MallStatExt(_key) : MallStat(_key) constructor 
{
	type = MALL_NUMTYPE.REAL;
	limitMin = 0;
	limitMax = 999;
	
	// Nivel
	levelLimitMin = 0;
	levelLimitMax = 100;
	funLevel  = function(stat, level) {return round( ( (base * level) / 40) + 5);}
}

/// @ignore
function mall_database()
{
	// Crear estadisticas
	mall_create_stat(STAT_EN ,  new MallStatEN() );
	mall_create_stat(STAT_EPM, new MallStatEPM() );
	mall_create_stat(STAT_EXP, new MallStatEXP() );
	mall_create_stat(STAT_FUERZA   , new MallStatExt("UI.STAT.FUERZA") );
	mall_create_stat(STAT_DEFENSA  , new MallStatExt("UI.STAT.DEFENSA") );
	mall_create_stat(STAT_FESPECIAL, new MallStatExt("UI.STAT.FESPECIAL") );
	mall_create_stat(STAT_DESPECIAL, new MallStatExt("UI.STAT.DESPECIAL") );
	mall_create_stat(STAT_VELOCIDAD, new MallStatExt("UI.STAT.VELOCIDAD") );

	var _critico = function() : MallStat(STAT_CRITICO) constructor {
		key  = "UI.STAT.CRITICAL";
		type = MALL_NUMTYPE.PERCENT; 
	
		limitMin = 0;
		limitMax = 100;

		levelLimitMin = 0;
		levelLimitMax = 100;
		funLevel = function(stat, level) {
			/// @self Struct.PartyStat
			var _velocidad = stat.get(STAT_VELOCIDAD);
			return round( (_velocidad.peak / 25) );
		}
	}
	mall_create_stat(STAT_CRITICO, new _critico() );
	
	var _poder = function() : MallStat(STAT_PODER) constructor {
		key  = "UI.STAT.PODER";
		type = MALL_NUMTYPE.PERCENT;
	
		start = 0;
		limitMin = 0;
		limitMax = 200;
	
		levelLimitMin = 0;
		levelLimitMax = 100;
	}
	mall_create_stat(STAT_PODER  , new _poder() );

}
