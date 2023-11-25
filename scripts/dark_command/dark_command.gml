/// @param  {string} darkKey
/// @return {Struct.DarkCommand}
function DarkCommand(_key) : Mall(_key) constructor 
{
    // Tipo de comando
    type = "";
    // Cuanto de algo consume
    consume =       0;
    consumeKey =    "";
    // Cuantos targets puede incluir en el hechizo
    targets = 1;
    // Targets
    onSelf    = false;  // Si se puede usar en si mismo
    onAllies  = true;   // Si se puede usar en aliados
    onEnemies = true;   // Si se puede usar en enemigos
    
    // Si acepta al mismo target varias veces.
    acceptSame = true;
    
    /// @desc funcion para comprobar si acierta o falla
    /// @returns {Bool}
    static check  = function(_caster, _target) 
    {
    };
    
    /// @desc funcion que ejecuta al acertar
    static action = function(_caster, _target) 
    {
    };
    
    /// @desc funcion que ejecuta al fallar
    static fail   = function(_caster, _target) 
    {
    };
    
    /// @desc Cinematica a ejecutar.
    static cinematic = function() 
    {
    };
    
    /// @return {Real}
    static getConsume = function()
    {
    };
    
    static getTarget  = function()
    {
    };
}

/// @param {string} effectKey
/// @param {string} stateKey
function DarkEffect(_key, _stateKey) : Mall(_key) constructor 
{
    static effectNumber = 0;
    // ID propia del comando
    id = $"{_key}DE : {effectNumber++}"
    
    // Estado que afecta o crea
    stateKey = _stateKey
    stateSet = true;
    
    // Valor que cambia real/porcentual
    value = 0;
    type  = MALL_NUMTYPE.REAL;
    
    // Se marca que el efecto termino
    isReady = false;
    
    turn = 0; // En que turno va
    turnMarkStart = 0; // En que turno global empezo
    turnMarkEnd   = 0; // En que turno global termino
    turnType      = 0; 
    
    /*
    	0: Inicio del turno
    	1: Final  del turno
    	2: En el inicio y final del turno
    */
    
    // Crear iteradores
    // Inicio turno
    iteratorStart = new MallIterator();
    // Final de turno
    iteratorEnd   = new MallIterator();
    
    #region METHODS
    /// @desc Evento a ejecutar cuando se agrega en un partyControl
    /// @param {Struct.PartyEntity} entity
    static added  = function(entity) 
    {
        var _atom = entity.controlGet(stateKey);
        _atom.state = stateSet;
    }
    
    /// @desc Evento a ejecutar cuando es eliminado
    static remove = function() 
    {
    };
    
    static entityUpdate = function(entity) 
    {
    }
    
    static combatEnd = function(entity)
    {
    };
    
    /// @desc Evento a ejecutar cuando inicio el turno  (turnType = 0)
    static turnStart = function() 
    {
    };
    
    /// @desc Evento a ejecutar cuando termina el turno (turnType = 1)
    static turnEnd =   function() 
    {
    };
    
    /// @desc Evento a ejecutar cuando es completado. El iterador terminó
    static ready  = function() 
    {
    };
    
    /// @param {Real} value
    /// @param {Enum.MALL_NUMTYPE} numtype
    static set = function(_value, _type)
    {
        _type ??= type;
        value[_type] = _value;
    }
    
    /// @param {Real} value
    /// @param {Enum.MALL_NUMTYPE} numtype
    static add = function(_value, _type)
    {
        _type ??= type;
        value[_type] += _value;
    }
    
    /// @param {Real} turnType
    static getIterator = function(_type=0)
    {
        return (!_type) ? iteratorStart  : iteratorEnd;
    }
    
    /// @desc Guarda este componente
    static export = function(_struct=false) 
    {
        var _this = self;
        var _save = {};
        with (_save) 
        {
            version = __MALL_VERSION;
            is =  _this.is;
            // Llaves
            key = _this.key;
            displayKey = _this.displayKey;
            
            // Valores
            value = _this.value;
            type =  _this.type;
            
            // Stats
            stateKey = _this.stateKey;
            stateSet = _this.stateSet;
            
            // Turnos
            isReady = _this.isReady;
            turn =    _this.turn;
            turnMarkStart = _this.turnMarkStart;
            turnMarkEnd =   _this.turnMarkEnd;
            turnType =      _this.turnType;
            
            // Guardar iteradores
            iteratorStart  = _this.iteratorStart.export();
            iteratorEnd =    _this.iteratorEnd.export()  ;
            
            return (!_struct) ? json_stringify(self, true) : self;
        }
    }
    
    /// @desc Cargar este componente
    /// @param {Struct} loadStruct
    static import = function(json)
    {
        // Valores
        value = json.value;
        type  = json.type;
        // Set
        stateKey = json.stateKey;
        stateSet = json.stateSet;
        
        // Turnos
        isReady = json.isReady;
        turn =    json.turn;
        turnMarkStart = json.turnMarkStart;
        turnMarkEnd =   json.turnMarkEnd;
        turnType =      json.turnType;
        
        // Cargar iteradores
        iteratorStart.import(json.iteratorStart);
        iteratorEnd  .import(json.iteratorEnd);
    }
    
    #endregion
}

