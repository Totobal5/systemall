/// @param {String}	_subtype
/// @param {Real}	_buy
/// @param {Real}	_sell
/// @param _stat_key
/// @param _stat_value
/// @param ...
/// @return {Struct.PocketItem}
function PocketItem(_subtype, _buy, _sell) : MallComponent() constructor {
    #region PRIVATE
	__type = mall_get_itemtype_sub(_subtype); // Buscar tipo esto
    __subtype = _subtype;    
    
	__buy  = _buy;	// Valor al que se compra
    __sell = _sell;	// Valor al que se vende
	
    __canSell = true;	// Si puede vender	 
	__canBuy  = true;	// Si puede comprar
    
    __parts = 1;	// Cuantas partes necesita para ser equipado
    
    __stats    = {};    // Donde se guardan sus estadisticas    
    __statsInv = {};    // Las estadisticas de arriba invertidas  
    
    __invert = false; // Devolver las estadisticas invertidas(true) o normales (false)
     
    // Effectos
    __events = {   
        inEquip:        MALL_DUMMY_METHOD,  // Metodo que se ejecuta al equiparse este objeto     
        inDesequip:     MALL_DUMMY_METHOD,  // Metodo que se ejecuta al desequiparse este objeto
        inEquipUpdate:  MALL_DUMMY_METHOD,  // Metodo que se ejecuta cada ciclo mientras se mantenga este objeto (fuera de la batalla)
        
        // En Batallas
        inBattleStart : MALL_DUMMY_METHOD,  
        inBattleUpdate: MALL_DUMMY_METHOD,
        inBattleEnd:    MALL_DUMMY_METHOD,
        inAttack:	MALL_DUMMY_METHOD,
		inDefend:	MALL_DUMMY_METHOD,
		
        // En turnos
        inTurnStart:    MALL_DUMMY_METHOD,  
        inTurnUpdate:   MALL_DUMMY_METHOD,
        inTurnEnd:      MALL_DUMMY_METHOD
    };

	#endregion

    #region METHODS
    
    /// @param _stat_key
    /// @param _value
    /// @param _type
    /// @desc Pone valores a las estadisticas
	/// @return {Struct.PocketItem}
    static setStat = function(_stat_key, _value, _type=NUMTYPE.REAL) {
        if (argument_count < 4) {
            __stats   [$ _stat_key] = numtype( _value, _type);
            __statsInv[$ _stat_key] = numtype(-_value, _type);
        } else {
            // Varios argumentos
            var i = 0; repeat(argument_count) {
                var _key = argument[i++];
                var _val = argument[i++];
                var _typ = argument[i++];
                
                setStat(_key, _val, _typ);    
            }
        }   
        
        return self;
    }
    
	/// @desc Permite devolver las estadisticas de este objeto normal o invertidas (invert())
    /// @return {Struct.Array}
    static getStats = function() {
        return (!__invert) ? 
			__stats		:
			__statsInv;
    }

	/// @desc Indicar que devuelva las estadisticas al revez
	/// @return {Struct.PocketItem}
	static invert = function() {
		__invert = true;
		return self;
	}

	/// @desc Indicar que devuelva las estadisticas normalmente
	/// @return {Struct.PocketItem}
	static normal = function() {
		__invert = false;
		return self;
	}
	
    /// @param {Bool} _buy
    /// @param {Real} _sell
    /// @param {Bool} _can_buy
    /// @param {Real} _can_sell
	/// @return {Struct.PocketItem}
    static setTrade  = function(_buy=0, _sell=0, _can_buy=true, _can_sell=true) {
		__sell = _sell;
		__buy  =  _buy;
	   
		__canSell = _can_sell;
		__canBuy  =  _can_buy;
		
        return self;
    }
    
    /// @param {String}		_event
    /// @param {Function}	_function
    static setEvents = function(_event, _function) {
        __events[$ _event] = _function;    
        return self;    
    }
    
    /// @desc Establecer cuantas partes necesita para poder equiparse
    static setPartsNumber = function(_use = 1) {
        __parts = _use;
        return self;
    }
    
    #endregion

    // Iniciar estadisticas rapidamente
    var i = 3; repeat( (argument_count - 3) div 3) {
        var _key = argument[i++];
        var _val = argument[i++];
        var _typ = argument[i++];
        
        setStat(_key, _val, _typ);
    }
}