/// @desc Elemento basico de Mall
/// @param {String} key
/// @ignore
function Mall(_key="") constructor 
{
    /// @ignore
    is = instanceof(self);
    /// @ignore Llave con el cual se guardo en la base de datos
    key = _key;
    /// @ignore Llave para usar en display
    dKey = "";
    /// @ignore Indice en donde esta (si esta en algun array)
    index = -1;
    /// @ignore Variables unicas
    vars = {};
    
    /// @desc Establece la llave propia.
    /// @param {String} key
    /// @param {String} [display_key]
    static SetKey = function(_key, _display)
    {
        key =	_key	 ?? key;
        dKey =	_display ?? dKey;
        return self;
    };
    
	/// @desc Establece la llave de display.
    /// @param {String} display_key
    static SetDKey = function(_key)
    {
        dKey = _key;
        return self;
    };
	
    /// @desc Devuelve la llave propia.
    /// @return {String}
    static GetKey = function()
    {
        return (key);
    };
	
    /// @desc Regresa la llave de display, si no fue establecido regresa la llave propia.
    /// @return {String}
    static GetDKey = function()
    {
        return (dKey == "") ? key : dKey;
    };
	
    /// @desc Como guardar este componente.
	/// @param {Bool}	[as_struct]	false
    /// @return {Struct}
    static Export = function(_struct=false)
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
    };
    
    /// @desc Como cargar este componente
	/// @param {Struct}	import_struct
    static Import = function(_l)
    {
        switch (__MALL_MY_VERSION) 
        {
            default:
                is =    _l.is;
                key =   _l.key;
                index = _l.index;
            break;
        }
    };
    
    /// @desc Pasar numtype a string
    /// @param {Enum.MALL_NUMTYPE} numtype
    static StringNumtype = function(_numtype)
    {
        switch (_numtype)
        {
            case MALL_NUMTYPE.REAL:     return   "";
            case MALL_NUMTYPE.PERCENT:  return  "%";
        }
    };
    
    /// @desc Para no crear demasiadas funciones
	/// @ignore
    static __dummy = function() 
    {
    };
}

/// @desc Iterador usado en varios componentes mall
/// @ignore
function MallIterator() constructor
{
	/// @ignore
	enum MALL_ITERATOR
	{
		DEACTIVATED,
		WORKING,
		TO_RESET,
		REINITIATED
	}
	
	/// @ignore
    is = instanceof(self);
	/// @ignore
    active = false;
    /// @ignore true: toMin, false: toMax
    type = true;
    
    /// @ignore Cuenta
    count = 0;
	/// @ignore
    countLimits = 1;
	
    // Resets
    /// @ignore Si tiene un reset o no
    reset = false;
    /// @ignore Veces que se ha reseteado
    resetCount = 0;
    /// @ignore Limite de resets
    resetLimits = 1;
    /// @ignore
    resetNumber = 0;
	/// @ignore
    resetMax = -1;
	
    /// @ignore Se ha llamado 1 vez
    firstCall = false;
    
    /// @param {bool} [type] true: to min, false: to max
    static Activate = function(_type) 
    {
        active =	true;
        type =		_type ?? type;
		return self;
    }
    
    /// @desc Establece los valores del iterador. Al completar llevara algun valor a su minimo o maximo (depende del type)
    /// @param {bool} type			true: to min, false: to max
    /// @param {real} count_max		Cuanta veces iterar
    /// @param {bool} [repeat]=		true Si repite luego de completarse
    /// @param {real} [repeat_max]=	-1 Cuentas veces se repetira
    static Configure = function(_type, _countMax, _reset, _resetLim = -1)
    {
        Activate(_type);
        
        count =			0;
        countLimit =	_countMax;
        
        reset =			_reset;
        resetCount =	0;
        resetLimit =	_resetLim;
        
        return self;
    }
    
    /// @desc DEACTIVATED se ha desactivado, WORKING aun no llega al limite de cuenta, TO_RESET esta iterando para reiniciar, REINITIATED se ha reiniciado
    /// @returns {Enum.MALL_ITERATOR} Description
    static Iterate = function()
    {
        // Si ya se cumplio el ciclo.
        if (active) 
        {
			// Devolver que esta trabajando solo si es infinito o aun le faltan cuentas por completar.
			if (countLimit == infinity || count++ > countLimits) 
			{
				return (MALL_ITERATOR.WORKING);
			}
			else
			{
				return (Restart() );	
			}
        }
        
        return (MALL_ITERATOR.DEACTIVATED);
    };
    
    /// @desc Reinicia el iterador si puede, si no lo desactiva
    /// @returns {Real} Description
    static Restart = function()
    {
        // Se el iterador reinicia.
        if (reset)
        {
            // Cuenta para el reinicio.
            if (resetCount < resetLimits) 
            {
                resetCount = resetCount + 1;
                return (MALL_ITERATOR.TO_RESET);
            }
            else
            {
				// Cuenta.
                count = 0;
                resetCount = 0;
                // Reinicio infinito.
                if (resetMax == infinity) return (MALL_ITERATOR.REINITIATED);
				
                // Veces que puede reiniciar.
                if (resetNumber > resetMax) 
                {
                    active = false; 
                } 
                else 
                {
                    resetNumber = resetNumber + 1; 
                }
				
                return (MALL_ITERATOR.REINITIATED);
            }
        }
		
        // Desactivar.
        active = false;
        count = 0;
		
        return (MALL_ITERATOR.DEACTIVATED);
    }
    
    /// @desc Devuelve si es toMin (true) o toMax (false)
    /// @returns {bool} Description
    static GetType = function()
    {
        return (type);
    };
    
    /// @desc Devuelve si esta activo
    /// @returns {bool} Description
    static IsActive = function()
    {
        return (active);
    };
    
    /// @desc Guardar iterador.
	/// @param {Bool}	[as_struct]	false
    static Export = function(_struct=false) 
    {
        var _this = self;
        with ({})
        {
            version =		__MALL_VERSION;
            is =			_this.is;
            active =		_this.active;
            type =			_this.type;
            count =			_this.count;
            countLimit =	_this.countLimit;
            
            reset =			_this.reset;
            resetCount =	_this.resetCount;
            resetLimits =	_this.resetLimits;
            
            resetNumber =	_this.resetNumber;
            resetMax =		_this.resetMax;
            
            firstCall =		_this.firstCall;
            
            return (!_struct) ? json_stringify(self, true) : self;
        }
    }
    
    /// @desc Cargar iterador.
    /// @param {Struct}	import_struct
    static Import = function(_json)
    {
        // Asegurarse de que sean el mismo
        if (_json.is != is) exit;
        switch (__MALL_MY_VERSION)
        {
            default:
                active =		_json.active;
                type =			_json.type;
                count =			_json.count;
                countLimit =	_json.countLimit;
                
                reset =			_json.reset;
                resetCount =	_json.resetCount;
                resetLimit =	_json.resetLimit;
                
                resetNumber =	_json.resetNumber;
                resetMax =		_json.resetMax;
                
                firstCall =		_json.firstCall;
            break;
            
        }
		
		return self;
    }
    
    /// @return {Struct.MallIterator}
    static Copy = function() 
    {
        var _this = self;
        with (new MallIterator() ) 
        {
            active =		_this.active;
            // true: toMin, false: toMax
            type =			_this.type;
            // Cuenta
            countLimits =	_this.countLimits;
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

/// @desc Se puede modificar a la necesidad del desarrollador. Este es un ejemplo tipico.
/// @ignore
function MallResult(_array=false) constructor
{
	/// @is {Bool} Si utiliza array´s.
	useArray = false;
	/// @is {Real} El tamaño del array.
	size = 0;
	// Si no es un array.
	if (!useArray)
	{
		/// Si se logró.
	    success = true;
	    /// Si se derroto al target.
	    defeated = false;
		/// Valores.
	    value = 0;
		/// Daño realizado.
	    damage = 0;
		/// Cuanto se consumio de algo.
	    consumed = 0;
		/// Cuanto se uso de algo.
	    used = 0;
	}
	// Si es un array.
	else
	{
		/// Si se logró.
	    success = true;
	    /// Si se derroto al target.
	    defeated = [false];
		/// Valores.
	    value = [0];
		/// Daño realizado.
	    damage = [0];
		/// Cuanto se consumio de algo.
	    consumed = [0];
		/// Cuanto se uso de algo.
	    used = [0];
	}
}