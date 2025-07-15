// Feather ignore all
/// @param  {string} dark_key
/// @return {Struct.DarkCommand}
function DarkCommand(_key) : Mall(_key) constructor 
{
    // Tipo de comando
    type = "";
    // Cuantos targets puede incluir en el hechizo
    targets = 1;
    // Targets
	// Si se puede usar en si mismo.
    onSelf = false;
	// Si se puede usar en aliados.
    onAllies = true;
	// Si se puede usar en enemigos.
    onEnemies = true;
    // Si acepta al mismo target varias veces.
    onSame = true;
    
    /// @desc Funcion para comprobar si acierta o falla.
	/// @param	{Struct.PartyEntity}	Caster
	/// @param	{Struct.PartyEntity}	Target
    /// @returns {Bool}
    static Check = function(_caster, _target) 
    {
    };
    
    /// @desc funcion que ejecuta al acertar
	/// @param	{Struct.PartyEntity}	Caster
	/// @param	{Struct.PartyEntity}	Target
    static Action = function(_caster, _target) 
    {
    };
    
    /// @desc funcion que ejecuta al fallar
	/// @param	{Struct.PartyEntity}	Caster
	/// @param	{Struct.PartyEntity}	Target	
    static Fail = function(_caster, _target) 
    {
    };
    
    /// @desc Cinematica a ejecutar.
	/// @param	{Struct.PartyEntity}	Caster
	/// @param	{Struct.PartyEntity}	Target	
    static Cinematic = function(_caster, _target) 
    {
    };
	
	/// @desc La manera default de buscar objetivos de este comando.
	/// @param	{Struct.PartyEntity}	Caster
	/// @param	{Struct.PartyEntity}	Target	
    static GetTarget = function(_caster, _target)
    {
    };
}

/// @param	{String} effect_key
/// @param	{String} state_key
function DarkEffect(_key, _state_key) : Mall(_key) constructor 
{
    static effectNumber = 0;
    // ID propia del comando
    id = $"{_key}DE:{effectNumber++}";
    
    // Estado que afecta o crea
    stateKey = _state_key;
    stateSet = true;
    // Valor que cambia real/porcentual.
    value = 0;
    numtype = MALL_NUMTYPE.REAL;
    // Se marca que el efecto termino.
    isReady = false;
	// En que turno va.
    turn = 0;
	// En que turno global empezo.
    turnMarkStart = 0;
	// En que turno global termino.
    turnMarkEnd = 0;
	// Tipo de turno.
    turnType = MALL_EFFECT_TURN.START; 
	
	// Crear iteradores.
    // Inicio turno.
    iteratorStart = new MallIterator();
    // Final de turno.
    iteratorEnd = new MallIterator();
    
    #region METHODS
    /// @desc Evento a ejecutar cuando se agrega en un partyControl
    /// @param	{Struct.PartyEntity} PartyEntity
    static Added = function(_entity) 
    {
        var _atom = _entity.ControlGet(stateKey);
        _atom.state = stateSet;
		
		return self;
    }
    
    /// @desc Evento a ejecutar cuando es eliminado.
    static Remove = function() 
    {
    };
    
	/// @param	{Struct.PartyEntity} PartyEntity
    static EntityUpdate = function(_entity) 
    {
    }
    
	/// @param	{Struct.PartyEntity} PartyEntity
    static BtEnd = function(entity)
    {
    };
    
    /// @desc Evento a ejecutar cuando inicio el turno  (turnType = 0)
    static BtTurnStart = function() 
    {
    };
    
    /// @desc Evento a ejecutar cuando termina el turno (turnType = 1)
    static BtTurnEnd = function() 
    {
    };
    
    /// @desc Evento a ejecutar cuando es completado. El iterador terminó
    static Ready = function() 
    {
    };
    
    /// @param	{Real}				value
    /// @param	{Enum.MALL_NUMTYPE}	numtype
    static Set = function(_value, _type)
    {
        value[_type ?? type] = _value;
		return self;
    }
    
    /// @param	{Real}				value
    /// @param	{Enum.MALL_NUMTYPE}	numtype
    static Add = function(_value, _type)
    {
        value[_type ?? type] += _value;
		return self;
    }
    
    /// @param	{Real} [turn_type]
    static GetIterator = function(_type=MALL_EFFECT_TURN.START)
    {
        return (!_type) ? iteratorStart : iteratorEnd;
    }
    
    /// @desc Guarda este componente.
	/// @param	{Bool} [struct] devolver un struct o un JSON.
    static Export = function(_struct=false) 
    {
        var _this = self;
        var _save = {};
        with (_save) 
        {
            version = __MALL_VERSION;
            is = _this.is;
            // Llaves.
            key = _this.key;
            dKey = _this.dKey;
            // Valores.
            value = _this.value;
            numtype = _this.type;
            // Stats.
            stateKey = _this.stateKey;
            stateSet = _this.stateSet;
            // Turnos.
            isReady = _this.isReady;
            turn = _this.turn;
            turnMarkStart = _this.turnMarkStart;
            turnMarkEnd = _this.turnMarkEnd;
            turnType = _this.turnType;
            // Guardar iteradores.
            iteratorStart = _this.iteratorStart.Export();
            iteratorEnd = _this.iteratorEnd.Export();
            
            return (!_struct) ? json_stringify(self, true) : self;
        }
    }
    
    /// @desc Cargar este componente.
    /// @param	{String} load_struct
    static Import = function(_json)
    {
        if (_json.is != is) exit;
        switch (_json.version)
		{
			default:
		        // Valores.
		        value = _json.value;
		        numtype = _json.numtype;
		        
				// Set.
		        stateKey = _json.stateKey;
		        stateSet = _json.stateSet;
		        isReady = _json.isReady;
		        
				// Turnos.
		        turn = _json.turn;
		        turnMarkStart = _json.turnMarkStart;
		        turnMarkEnd = _json.turnMarkEnd;
		        turnType = _json.turnType;
				
		        // Cargar iteradores.
		        iteratorStart.Import(_json.iteratorStart);
		        iteratorEnd.Import(_json.iteratorEnd);
			break;
		}
    }
    
    #endregion
}

