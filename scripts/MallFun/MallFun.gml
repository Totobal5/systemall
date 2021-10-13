// -- Globales
#macro DARK_TYPE_BATTLE	"Batalla"
#macro DARK_TYPE_MAGIC	"Magia"

#macro MALL_FUN function(old, base, lvl)

/// @param is
/// @param key
/// @param index
function __mall_class_parent(_is, _key = "", _index = -1) constructor {
    #region Interno
    __mall = "MALL";
    __is = _is;

    #endregion
	
	key = _key;	// Si se localiza se utiliza esta llave
	
	name  = lexicon_text(_key);	// Nombre de la clase
	
	index = _index;	// indice
	ignore = false;	// Si se ignora globalmente
	
	#region GUI
    txt = "";	// texto principal que se muestra
    
    txt_des = "";	// descripcion de la clase
    txt_ext = [];	// textos complementarios
	
	txt_ignore = false;	// Se se ignora en funciones con relacion al texto
	
    #endregion

    #region Metodos
    
    /// @desc Establece la key, index y name
    static Property = function(_key, _index = -1, _name = _key) {
		key = _key;
		
		index = _index;
		name  = _key;
		
		return self;
    }
    
    static Localize = function() {
    	name = lexicon_text(key + ".NAME");
    	
		txt 	= lexicon_text(key + ".TXT");
		txt_des = lexicon_text(key + ".DES");
		
		return self;
    }
	
	static IgnoreGUI = function() {
		txt_ignore = !txt_ignore;
		
		return self;
	}
	
		#region Basico
    /// @param name
    /// @param class
    /// @desc Permite vincular una clase de mall a alguna estructura de otro sistema
    static Vinculate = function(_name, _value) {
        if (is_struct(_value) ) {
            if (!variable_struct_exists(self, _name) ) {
                variable_struct_set(self, _name, _value);
            }    
        }
        
        return self;
    }
    
    /// @param struct_name
    static GetStruct = function(_name) {
    	return (variable_struct_get(self, _name) );
    }
    
    /// @param struct
    /// @param override
    /// @desc Permite sobrescribir todos los valores de una estructura
    static Override = function(_struct_name, _value) {
    	var _struct = GetStruct(_struct_name);
  
    	if (!is_struct(_struct) ) return false;
    	
    	var _names = variable_struct_get_names(_struct), i = 0;
    	
    	repeat(array_length(_names) ) {variable_struct_set(_struct, _names[i], _value); ++i; }
    	
    	return self;
    }
    
    /// @param struct
    /// @param multiply
    static Multiply = function(_struct_name, _mult) {
    	var _struct = GetStruct(_struct_name);
  
    	if (!is_struct(_struct) ) return false;
    	
    	var _names = variable_struct_get_names(_struct), i = 0;
    	
    	repeat(array_length(_names) ) {
    		var _name = _names[i], in = variable_struct_get(_struct, _name);

			if (is_numeric(in) ) variable_struct_set(_struct, _name, round(in * _mult) );
			
    		++i; 
    	}
    	
		return self;    	
    }
    
    /// @desc Pasa los valores de un struct al contrario (1 -> -1)
    static Turn = function(_struct) {
    	if (is_string(_struct) ) _struct = self[$ _struct];
    	
    	if (!is_struct(_struct) ) return false;
    	
    	var _names = variable_struct_get_names(_struct);
    	
    	var i = 0; repeat(array_length(_names) ) {
    		var _name = _names[i], in = _struct[$ _name];
    		
    		if (is_data(in) )	 {in.Turn(); } else 
    		if (is_numeric(in) ) {in *= -1 ; } 
    		
    		variable_struct_set(_struct, _name, in);
    		
    		++i;
    	}
    	
    	return self;
    }
    
    	#endregion
    
    	#region Getter´s
    static GetName  = function() {
    	return name;
    }
        
    static GetBasic = function() {
        return [name, index];
    }
    
    static GetTxt	= function() {
    	return (txt );
    }
    
    static GetString = function() {
        return [txt, symbol];
    }

    static GetType   = function() {
        return __is;
    }
    
    #endregion
    
    	#region Misq
    static Copy = function() {}
    
    #endregion
    
    #endregion
}

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
	mall_create_itemtypes("ARMAS"  , "ESPADA", "DAGA", "HACHA");
	mall_create_itemtypes("ESCUDOS", "ESCUDO");
	
	mall_create_itemtypes("CASCOS", "CASCO", "SOMBRERO", "BOINA");
	
	mall_create_itemtypes("ARMADURA"  , "LIGERA" , "PESADA", "MALLAS");
	mall_create_itemtypes("ACCESORIOS", "GUANTES", "COLLAR", "ANILLO");

	//  Weapon, Shield, Helmet, Armor, and Gloves.
	
	mall_create_itemtypes("OBJETOS", "POCIONES", "IMPORTANTE");
	
	mall_create_dark("BATALLA" , "ATAQUE", "DEFENSA", "OBJETO");
	mall_create_dark("MAGIA"   , "BLANCA", "NEGRA"  , "ROJA"  , "VERDE");
	
	mall_create_pocket("ARMAS"  , noone, "ARMAS");
	mall_create_pocket("OBJETOS", noone, "OBJETOS");
	
	mall_create_stats(
		"PSMAX", "PMMAX", "EXPMAX", "PS", "PM", "EXP",
		"FUE", "INT", "DEF", "ESP", "VEL",
		
		"FUEGO.REST", "FUEGO.ATAK" , "POLUCION.REST" , "POLUCION.ATAK",		// Elementos
		"VIVO.REST" , "VENENO.REST", "QUEMADURA.REST", "MELANCOLIA.REST"	// Resistencias
	);
	
	mall_create_states  ("VIVO" , "VENENO", "QUEMADURA", "MELANCOLIA");
	mall_create_elements("FUEGO", "POLUCION");
	
	mall_create_parts("CABEZA", "MANO.IZQ", "MANO.DER", "CUERPO", "ORNAMENTOS");
	
	var _group = mall_group_init("MALL_GROUP.");

	#region STATS
	var _psmax = mall_stat_customize("PSMAX", 0, undefined, mall_custom_levelup_stat1).Limits(0, 9999);
	var _pmmax = mall_stat_customize("PMMAX").Inherit(_psmax);
	
	var _expmax = mall_stat_customize("EXPMAX", 0, undefined, mall_custom_levelup_stat2).Limits(0, 999999);

	var _ps  = mall_stat_customize("PS" , _psmax ).ToMax(false)	.Ignore();
	var _pm  = mall_stat_customize("PM" , _pmmax ).ToMax(false)	.Ignore();
	var _exp = mall_stat_customize("EXP", _expmax).ToMin()		.Ignore();
	
	var _fue = mall_stat_customize("FUE", 0, undefined, mall_custom_levelup_stat3).Limits(0, 999);
	var _int = mall_stat_customize("INT").Inherit(_fue);

	var _def = mall_stat_customize("DEF").Inherit(_fue);
	var _esp = mall_stat_customize("ESP").Inherit(_fue);
	
	var _spd = mall_stat_customize("VEL").Inherit(_fue);

	// Unir resistencias a los elementos y estadisticas en las estadisticas ya que la clase de "stat" ya posee todo lo necesario!
	var _resfire = mall_stat_customize("FUEGO.REST", (new Data(0) ), undefined, mall_custom_levelup_res).Limits(0, 255);
	
	var _atkfire = mall_stat_customize("FUEGO.ATAK", 0, undefined, mall_custom_levelup_ele).Limits(0, 999);
	
	var _respolu = mall_stat_customize("POLUCION.REST").Inherit(_resfire); 
	var _atkpolu = mall_stat_customize("POLUCION.ATAK" ).Inherit(_atkfire);
	
	var _restvivo = mall_stat_customize("VIVO.REST").Inherit(_resfire).Ignore();
	
	var _restven = mall_stat_customize("VENENO.REST")		.Inherit(_resfire);
	var _restqem = mall_stat_customize("QUEMADURA.REST")	.Inherit(_resfire);
	var _restmel = mall_stat_customize("MELANCOLIA.REST")	.Inherit(_resfire);
	
	#endregion
	
	#region STATES
	var _vivo = mall_state_customize("VIVO", true, _restvivo);
	
	var _ven = mall_state_customize("VENENO", false, _restven, "Envenenado")
	.AddAffect(_fue, (new Data(-20) ), _ps, (new Data(-20) ) )
	.Process  (15, 17, 1, 9, 1, "DARK.GSPELL.VENENO");

	var _qem = mall_state_customize("QUEMADURA", false, _restqem, "Quemado")
	.AddAffect(_fue, (new Data(-50) ) )
	.Process  (50, 50, 0, 3, 1, "DARK.GSPELL.QUEMADURA");
	
	var _mel = mall_state_customize("MELANCOLIA", false, _restmel, "Melancolico")
	.AddAffect(_int, (new Data(-50) ) )
	.Process  (20, 50, 5, 6, 2, "DARK.GSPELL.MELANCOLIA");
	
	#endregion
	
	var _fire = mall_element_customize("FUEGO"	 , _atkfire, _resfire, _qem, (new Data(20) ) );
	var _polu = mall_element_customize("POLUCION", _atkpolu, _respolu, _ven, (new Data(50) ) );

	#region PARTS
	var _head  = mall_part_customize("CABEZA" , "CASCOS"	, true);
	var _body  = mall_part_customize("CUERPO" , "ARMADURA"	, true);
	var _orn   = mall_part_customize("ORNAMENTOS", "ACCESORIOS", true);

	var _hand1 = mall_part_customize("MANO.IZQ", "ARMAS", true, "ESCUDOS", true).BonusItemsub("ESPADA", (new Data(25) ) );
	var _hand2 = mall_part_customize("MANO.DER").Inherit(_hand1, true);

	#endregion

}


