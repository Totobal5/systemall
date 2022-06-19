/// @param	{String}	item_subtype
/// @param	{Real}		[buy]
/// @param	{Real}		[sell]
/// @param	{String}	[stat_key]
/// @param				[stat_value]
/// @return {Struct.PocketItem}
function PocketItem(_subtype, _buy=0, _sell=0) : MallComponent() constructor 
{
    #region PRIVATE
	/// @ignore
	__type		= mall_get_itemtype_sub(_subtype); // Buscar tipo esto
	/// @ignore
    __subtype	= _subtype;    
	/// @ignore 
	__buy  = _buy;	// Valor al que se compra
	/// @ignore
    __sell = _sell;	// Valor al que se vende
	/// @ignore
    __canSell = true;	// Si puede vender	 
	/// @ignore
	__canBuy  = true;	// Si puede comprar
    /// @ignore
    __parts = 1;	// Cuantas partes necesita para ser equipado
    /// @ignore
    __stats    = {};    // Donde se guardan sus estadisticas    
	/// @ignore
    __statsInv = {};    // Las estadisticas de arriba invertidas  
    /// @ignore
    __invert = false; // Devolver las estadisticas invertidas(true) o normales (false)

	#endregion

    // Effectos
	/// @ignore
	static _nofun = function(caster, target, extra) {};
    events = {   
        inEquip:        other._nofun,  // Metodo que se ejecuta al equiparse este objeto     
        inDesequip:     other._nofun,  // Metodo que se ejecuta al desequiparse este objeto
        inEquipUpdate:  other._nofun,  // Metodo que se ejecuta cada ciclo mientras se mantenga este objeto (fuera de la batalla)
        
        // En Batallas
        inBattleStart : other._nofun,	// Al iniciar la batalla  
        inBattleUpdate: other._nofun,	// Al actualizar la batalla
        inBattleEnd:    other._nofun,	// Al terminar la batalla
        inAttack:	other._nofun,		// Al atacar
		inDefend:	other._nofun,		// Al defender
		
        // En turnos
        inTurnStart:    other._nofun,	// Al iniciar un turno
        inTurnUpdate:   other._nofun,	// Al actualizar el turno
        inTurnEnd:      other._nofun	// Al terminar el turno
    };

    #region METHODS
    
    /// @param	{String}		stat_key
    /// @param	{Real}			value
    /// @param	{Enum.NUMTYPES}	type
    /// @desc Pone valores a las estadisticas
	/// @return {Struct.PocketItem}
    static setStat = function(_stat_key, _value, _type=NUMTYPES.REAL) 
	{
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
    
	/// @param {Bool}	[invert_stats]
	/// @desc Permite devolver las estadisticas de este objeto normal o invertidas
    /// @return {Struct.Array}
    static getStats = function(_invert=false) 
	{
        return (!_invert) ? __stats : __statsInv;
    }

    /// @param	{Real}	buy_value
    /// @param	{Real}	buy_sell
    /// @param	{Bool}	[can_buy]
    /// @param	{Bool}	[can_sell]
	/// @return {Struct.PocketItem}
    static setTrade  = function(_buy=0, _sell=0, _can_buy=true, _can_sell=true) 
	{
		__sell = _sell;
		__buy  =  _buy;
	   
		__canSell = _can_sell;
		__canBuy  =  _can_buy;
		
        return self;
    }
    
    /// @param {String}				events_key
    /// @param {Function, String}	function_or_dark_key
	/// @desc Event key: 
	///			$ inEquip 
	///			$ inDesequip
	///			$ inEquipUpdate
	///			$ inBattleStart
	///			$ inBattleUpdate
	///			$ inBattleEnd
	///			$ inAttack                        function(caster, target, extra) {}
	///			$ inDefend                        function(caster, target, extra) {} 
	///			$ inTurnStart
	///			$ inTurnUpdate
	///			$ inTurnEnd
    static setEvents = function(_event, _function) 
	{
		if (is_string(_function) )
		{
			events[$ _event] = dark_get(_function).getCommand();
		}
        else
		{
			events[$ _event] = method(undefined, _function);    	
		}
        return self;    
    }
    
	/// @param	{Real}	parts_number
    /// @desc Establecer cuantas partes necesita para poder equiparse
    static setPartsNumber = function(_use = 1) 
	{
        __parts = _use;
        return self;
    }
    
    #endregion

    // Iniciar estadisticas rapidamente
    var i = 3; repeat( (argument_count - 3) div 3) 
	{
        var _key = argument[i++];
        var _val = argument[i++];
        var _typ = argument[i++];
        
        setStat(_key, _val, _typ);
    }
}