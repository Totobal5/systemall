// --- ENUM DE ESTADO ---
// Para que el retorno de Tick() sea más legible.
enum MALL_ITERATOR_STATE 
{
    INACTIVE,   // El iterador no está activo.
    WORKING,    // El iterador está a mitad de un ciclo.
    CYCLE_END,  // Se ha completado un ciclo (y puede que se repita o no).
    COMPLETED   // Se han completado todos los ciclos y repeticiones.
}

/// @desc Elemento basico de Mall
/// @param {String} key
/// @ignore
function Mall(_key="") constructor 
{
	/// @ignore Referencia a su propio tipo.
	is = instanceof(self);
	// LLave base de datos.
	key = _key;
	// Indice en donde esta (si esta en algun array)
    index = -1;
	// Argumentos para eventos.
	args = {};
	
	#region API
	
    /// @desc Como guardar este componente.
    /// @return {Struct}
    static Export = function()
    {
        var _this = self;
        with ({})
        {
            version =   __MALL_MY_VERSION;
            is =        _this.is;
            key =       _this.key;
            index =     _this.index;
            
            return self;
        }
    };
    
    /// @desc Como cargar este componente
	/// @param {Struct}	import_struct
    static Import = function(_import)
    {
        switch (__MALL_MY_VERSION) 
        {
            default:
                is =    _import.is;
                key =   _import.key;
                index = _import.index;
            break;
        }
    };
	
	#endregion
}

/// @desc Iterador simplificado para controlar duraciones y repeticiones.
function MallIterator() : Mall() constructor
{
    // --- ESTADO ---
    active = false;
	
	// Cuántos ticks dura un ciclo.
    duration = 1;
	// Ticks transcurridos en el ciclo actual.
    ticks_elapsed = 0;
    
	// Cuántas veces se repite. 0 = se ejecuta una vez y no se repite.
    repeats = 0;
	// Cuántas repeticiones se han completado.
    repeats_done = 0;
    	
    // --- API ---
    
    /// @desc Configura y activa el iterador a partir de un struct.
    /// @param {Struct} config_struct Ejemplo: { duration: 5, repeats: 2 }
    static Configure = function(_duration=1, _repeats=0)
    {
        active = true;
        
        duration =	_duration;
        repeats =	_repeats;
        
        // Reiniciar contadores
        ticks_elapsed = 0;
        repeats_done = 0;
        
        // Permitir duraciones/repeticiones infinitas
        if (duration <= 0) duration = infinity;
        if (repeats < 0) repeats = infinity;
        
        return self;
    }
    
    /// @desc Avanza el iterador un paso y devuelve su estado actual.
    /// @returns {Enum.MALL_ITERATOR_STATE}
    static Tick = function()
    {
        if (!active) return MALL_ITERATOR_STATE.INACTIVE;
        
        ticks_elapsed++;
        
        // Comprobar si el ciclo actual ha terminado.
        if (ticks_elapsed >= duration)
        {
            // El ciclo terminó. Comprobar si debe repetirse.
            if (repeats_done < repeats)
            {
                // Sí, se repite.
                repeats_done++;
				// Reiniciar para el siguiente ciclo.
                ticks_elapsed = 0;
				// Informar que un ciclo terminó (y se reinició).
                return MALL_ITERATOR_STATE.CYCLE_END;
            }
            else
            {
                // No quedan más repeticiones. Se desactiva.
                active = false;
				// Informar que ha terminado por completo.
                return MALL_ITERATOR_STATE.COMPLETED;
            }
        }
        
        // Si no ha terminado el ciclo, sigue trabajando.
        return MALL_ITERATOR_STATE.WORKING;
    }
    
    /// @desc Devuelve si el iterador está actualmente activo.
    /// @returns {Bool}
    static IsActive = function()
    {
        return active;
    }
    
    /// @desc Devuelve el progreso del ciclo actual como un valor de 0 a 1.
    /// @returns {Real}
    static GetProgress = function()
    {
        if (duration == infinity) return 0;
        return ticks_elapsed / duration;
    }
    
    /// @desc Crea una copia de la configuración del iterador (no de su estado actual).
    /// @returns {Struct.MallIterator}
    static Copy = function()
    {
        return (new MallIterator() ).Configure(duration, repeats);
    }
    
    // --- GUARDADO Y CARGA ---
    
    /// @desc
    static Export = function()
    {
		var _this = self;
		// Llama al export del padre
		with (method(_this, Mall.Export) () )
		{
			active =			_this.active;
			duration =			_this.duration;
			ticks_elapsed =		_this.ticks_elapsed;
			repeats =			_this.repeats;
			repeats_done =		_this.repeats_done;
			
			return self;
		}
    }
    
    /// @desc
    static Import = function(_import)
    {
        // Llama al import del padre
        method(self, Mall.Import) (_import);
        
        // Carga las variables del iterador
        active =			_import.active;
        duration =			_import.duration;
        ticks_elapsed =		_import.ticks_elapsed;
        repeats =			_import.repeats;
        repeats_done =		_import.repeats_done;
    }
}

/// @desc Contenedor de resultados de una acción. Las propiedades internas son siempre arrays.
function MallResult() constructor
{
    // --- PROPIEDADES ---
    // El éxito general de la operación. Puede fallar si, por ejemplo, no hay EPM suficiente.
	success = true;
	
    // Arrays para almacenar los resultados de cada objetivo afectado por la acción.
	defeated = [];
	value = [];
	damage = [];
	consumed = [];
	used = [];
	
    // --- API ---
    
    /// @desc Añade un nuevo set de resultados para un objetivo.
    /// @param {Bool} defeated  Si el objetivo fue derrotado.
    /// @param {Real} value     Un valor genérico (ej: curación).
    /// @param {Real} damage    El daño infligido.
    /// @param {Real} consumed  El recurso consumido (ej: EPM).
    /// @param {Real} used      El item usado (ej: cantidad de pociones).
    static Push = function(_defeated, _value, _damage, _consumed, _used)
    {
        array_push(defeated, _defeated);
        array_push(value, _value);
        array_push(damage, _damage);
        array_push(consumed, _consumed);
        array_push(used, _used);
        return self;
    }
    
    /// @desc Devuelve el número de objetivos que fueron afectados.
    /// @returns {Real}
    static Size = function()
    {
        return array_length(damage);
    }
    
    /// @desc Devuelve el daño total infligido a todos los objetivos.
    /// @returns {Real}
    static GetTotalDamage = function()
    {
        var _total = 0, _damage_size = Size();
        for (var i = 0; i < _damage_size; i++)  { _total += damage[i]; }
        
		return _total;
    }
    
    /// @desc Devuelve el valor total (ej: curación total) de todos los objetivos.
    /// @returns {Real}
    static GetTotalValue = function()
    {
        var _total = 0, _damage_size = Size();
        for (var i = 0; i < _damage_size; i++) { _total += value[i]; }
		
		return _total;
    }
    
    /// @desc Devuelve el daño infligido a un objetivo en un índice específico.
    /// @param {Real} [index] El índice del objetivo (por defecto, el primero).
    /// @returns {Real}
    static GetDamage = function(_index = 0)
    {
        if (_index < Size() ) return damage[_index];
        return 0;
    }
    
    /// @desc Devuelve el valor de un objetivo en un índice específico.
    /// @param {Real} [index] El índice del objetivo (por defecto, el primero).
    /// @returns {Real}
    static GetValue = function(_index = 0)
    {
        if (_index < Size() ) return value[_index];
        return 0;
    }
    
    /// @desc Comprueba si algún objetivo fue derrotado.
    /// @returns {Bool}
    static WasAnyDefeated = function()
    {
		return (array_any(defeated, function(_value) { return _value } ) );
    }
}