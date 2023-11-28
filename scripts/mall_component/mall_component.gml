/// @desc Elemento basico de Mall
/// @param {String} key
/// @ignore
function Mall(_key="") constructor 
{
    /// @ignore
    is  = instanceof(self);
    // Llave con el cual se guardo en la base de datos
    key = _key;
    // Llave para usar en display
    displayKey = "";
    // Indice en donde esta (si esta en algun array)
    index = -1;
    // Variables unicas
    vars = {};
    
    /// @desc Establece la llave propia
    /// @param {String} key
    /// @param {String} [displayKey]
    static setKey = function(_key, _display)
    {
        key =           _key     ?? key;
        displayKey =    _display ?? displayKey;
        return self;
    };
    
    /// @param {String} displayKey
    static setDisplayKey = function(_key)
    {
        displayKey = _key;
        return self;
    };
    
    /// @desc Regresa el texto de display
    /// @return {String}
    static getDisplayKey = function()
    {
        return (displayKey=="") ? key : displayKey;
    };
    
    /// @desc Devuelve la llave del componente
    /// @return {String}
    static getKey = function()
    {
        return (key);
    };
    
    /// @desc Como guardar este componente
    /// @return {Struct}
    static export = function(_struct=false)
    {
        var _this = self;
        with ({}) 
        {
            version =   __MALL_MY_VERSION;
            is =        _this.is;
            key =       _this.key;
            index =     _this.index;
            
            return (!_struct) ? json_stringify(self, true) : self;
        }
    }
    
    /// @desc Como cargar este componente
    static import = function(_l)
    {
        switch (__MALL_MY_VERSION) 
        {
            default:
                is =    _l.is;
                key =   _l.key;
                index = _l.index;
            break;
        }
    }
    
    /// @desc Pasar numtype a string
    /// @param {Enum.MALL_NUMTYPE} numtype
    static toStringNumtype = function(_numtype)
    {
        switch (_numtype)
        {
            case MALL_NUMTYPE.REAL:     return   "";    break;
            case MALL_NUMTYPE.PERCENT:  return  "%";    break;
        }
    }
    
    /// @desc Para no crear demasiadas funciones
    static __dummy = function() 
    {
    };
}

/// @desc Iterador usado en varios componentes mall
/// @ignore
function MallIterator() constructor
{
    is = instanceof(self);
    active = false;
    // true: toMin, false: toMax
    type   =  true;
    
    // Cuenta
    count = 0;
    countLimits = 1;
    // Resets
    // Si tiene un reset o no
    reset = false;
    // Veces que se ha reseteado
    resetCount  = 0;
    // Limite de resets
    resetLimits = 1;
    
    resetNumber =  0;
    resetMax    = -1;
    // Se ha llamado 1 vez
    firstCall   = false;
    
    /// @param {bool} [type] true: to min, false: to max
    static activate  = function(_type) 
    {
        active = true;
        type =  _type ?? type;
    }
    
    /// @desc Establece los valores del iterador. Al completar llevara algun valor a su minimo o maximo (depende del type)
    /// @param {bool} type true: to min, false: to max
    /// @param {real} countMax          Cuanta veces iterar
    /// @param {bool} [repeat]=true     Si repite luego de completarse
    /// @param {real} [repeatMax]=-1    Cuentas veces se repetira
    static configure = function(_type, _countMax, _reset, _resetLim = -1)
    {
        activate(_type);
        
        count  = 0;
        countLimit = _countMax;
        
        reset = _reset;
        resetCount = 0;
        resetLimit = _resetLim;
        
        return self;
    }
    
    /// @desc -1 se ha desactivado, 0 aun no llega al limite de cuenta, 1 esta iterando para reiniciar, 2 se ha reiniciado
    /// @returns {real} Description
    static iterate = function()
    {
        // Si ya se cumplio el ciclo
        if (active) 
        {
            count++;
            return (count > countLimits) ? 0 : restart();
        }
        
        return -1;
    }
    
    /// @desc Reinicia el iterador si puede, si no lo desactiva
    /// @returns {Real} Description
    static restart = function()
    {
        #region Se el iterador reinicia
        if (reset)
        {
            #region Cuenta para el reinicio
            if (resetCount < resetLimits) 
            {
                resetCount = resetCount + 1;
                return 1;
            }
            else
            {
                count  = 0;
                resetCount = 0;
                // Reinicio infinito
                if (resetMax == -1) return 2;
                // Veces que puede reiniciar
                if (resetNumber > resetMax) 
                {
                    active = false; 
                } 
                else 
                {
                    resetNumber = resetNumber + 1; 
                }
                return 2;
            }
            #endregion
        }
        #endregion
        
        active = false;
        count  = 0;
        return -1;
    }
    
    /// @desc Devuelve si es toMin (true) o toMax (false)
    /// @returns {bool} Description
    static getType = function()
    {
        return (type);
    };
    
    /// @desc Devuelve si esta activo
    /// @returns {bool} Description
    static isActive = function()
    {
        return (active);
    };
    
    /// @desc Guardar iterador
    static save = function(_struct=false) 
    {
        var _this = self;
        with ({})
        {
            version = __MALL_VERSION;
            is =            _this.is;
            active =        _this.active;
            type =          _this.type;
            count =         _this.count;
            countLimit =    _this.countLimit;
            
            reset = _this.reset;
            resetCount =  _this.resetCount;
            resetLimits = _this.resetLimits;
            
            resetNumber =   _this.resetNumber;
            resetMax =      _this.resetMax;
            
            firstCall = _this.firstCall;
            
            return (!_struct) ? json_stringify(self, true) : self;
        }
    }
    
    /// @desc Cargar iterador
    /// @param {Struct} loadStruct
    static load = function(_json)
    {
        // Asegurarse de que sean el mismo
        if (_json.is != is) exit;
        switch (__MALL_MY_VERSION)
        {
            default:
                active = _json.active;
                type   = _json.type  ;
                count  = _json.count ;
                countLimit = _json.countLimit;
                
                reset = _json.reset;
                resetCount = _json.resetCount;
                resetLimit = _json.resetLimit;
                
                resetNumber = _json.resetNumber;
                resetMax    = _json.resetMax;
                
                firstCall = _json.firstCall;
            break;
            
        }
    }
    
    /// @return {Struct.MallIterator}
    static copy = function() 
    {
        var _this = self;
        with (new MallIterator() ) 
        {
            active = _this.active;
            // true: toMin, false: toMax
            type   = _this.type;
            // Cuenta
            countLimits = _this.countLimits;
            // Resets
            // Si tiene un reset o no
            reset =         _this.reset;
            // Limite de resets
            resetLimits =   _this.resetLimits;
            resetMax =      _this.resetMax;
            return self;
        }
    }
}

/// @ignore
function MallResult() constructor 
{
    success  = true;
    // Si se derroto al target
    defeated = false;
    
    value  = 0;
    damage = 0;
    consumed = 0;
    used     = 0;
}