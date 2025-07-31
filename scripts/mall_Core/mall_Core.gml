// --- ENUM DE ESTADO ---
/// @desc Define los posibles estados de un MallIterator.
enum MALL_ITERATOR_STATE 
{
    INACTIVE,   // El iterador no está activo.
    WORKING,    // El iterador está a mitad de un ciclo.
    CYCLE_END,  // Se ha completado un ciclo (y puede que se repita o no).
    COMPLETED   // Se han completado todos los ciclos y repeticiones.
}

/// @desc Elemento base para la mayoría de los componentes de Systemall.
/// @param {String} key La llave de identificación del componente.
/// @ignore
function Mall(_key="") constructor 
{
	/// @desc Una referencia al tipo de constructor de la instancia.
	/// @type {String}
	is = instanceof(self);
	
	/// @desc La llave de la plantilla base del componente.
	/// @type {String}
	key =	_key;
	
    /// @desc El índice de la instancia dentro de un array, si aplica.
	/// @type {Real}
    index = -1;
	
	/// @desc Un struct para pasar argumentos personalizados a los eventos.
	/// @type {Struct}
	args =	{};
	
	#region API
	
    /// @desc Exporta el estado base de la instancia a un struct para guardado.
    /// @return {Struct} Un struct con los datos esenciales de la instancia.
    static Export = function()
    {
        var _this = self;
        with ({})
        {
            version =   __MALL_VERSION_MINE;
            is =        _this.is;
            key =       _this.key;
            index =     _this.index;
            
            return self;
        }
    };
    
    /// @desc Importa y restaura el estado base de la instancia desde un struct.
	/// @param {Struct}	import_struct El struct con los datos guardados.
    static Import = function(_import)
    {
        switch (__MALL_VERSION_MINE)
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

/// @desc Un temporizador simplificado para gestionar duraciones y repeticiones de ciclos.
function MallIterator() : Mall() constructor
{
    // --- ESTADO ---
	
    /// @desc Si el iterador está actualmente en funcionamiento.
	/// @type {Bool}
    active = false;
	
    /// @desc Cuántos "ticks" o pasos dura un ciclo completo.
	/// @type {Real}
    duration = 1;
	
    /// @desc El número de "ticks" que han transcurrido en el ciclo actual.
	/// @type {Real}
    ticks_elapsed = 0;
	
    /// @desc Cuántas veces se repetirá el ciclo. 0 = una sola ejecución. infinity = repetición infinita.
	/// @type {Real}
    repeats = 0;
	
    /// @desc El número de repeticiones que ya se han completado.
	/// @type {Real}
    repeats_done = 0;
    	
    #region API
    
    /// @desc Configura y activa el iterador.
    /// @param {Real} [duration]=1 Cuántos ticks dura un ciclo.
    /// @param {Real} [repeats]=0  Cuántas veces se repite el ciclo.
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
    
    /// @desc Avanza el iterador un paso ("tick") y devuelve su estado actual.
    /// @returns {Enum.MALL_ITERATOR_STATE} El estado del iterador después del tick.
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
                repeats_done++;
                ticks_elapsed = 0; // Reiniciar para el siguiente ciclo.
                return MALL_ITERATOR_STATE.CYCLE_END;
            }
            else
            {
                active = false;
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
    
    /// @desc Devuelve el progreso del ciclo actual como un valor normalizado de 0 a 1.
    /// @returns {Real}
    static GetProgress = function()
    {
        if (duration == infinity) return 0;
        return ticks_elapsed / duration;
    }
    
    /// @desc Crea una nueva instancia del iterador con la misma configuración (no el estado actual).
    /// @returns {Struct.MallIterator}
    static Copy = function()
    {
        return (new MallIterator() ).Configure(duration, repeats);
    }
    
    /// @desc Exporta el estado actual del iterador a un struct.
    /// @return {Struct}
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
    
    /// @desc Importa el estado del iterador desde un struct.
	/// @param {Struct} _import El struct con los datos guardados.
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
	
	#endregion
}

/// @desc Contenedor estandarizado para los resultados de una acción de combate.
function MallResult() constructor
{
    // --- PROPIEDADES ---
	
    /// @desc El éxito general de la operación. Puede fallar si, por ejemplo, no hay EPM suficiente.
	/// @type {Bool}
	success = true;
	
    /// @desc Un array de booleanos que indica si cada objetivo fue derrotado.
	/// @type {Array<Bool>}
	defeated = [];
	
	/// @desc Un array de valores numéricos genéricos (ej: cantidad de curación).
	/// @type {Array<Real>}
	value = [];
	
	/// @desc Un array con el daño infligido a cada objetivo.
	/// @type {Array<Real>}
	damage = [];
	
	/// @desc Un array con el recurso consumido para cada objetivo (ej: coste de EPM).
	/// @type {Array<Real>}
	consumed = [];
	
	/// @desc Un array con la cantidad de un item usado para cada objetivo.
	/// @type {Array<Real>}
	used = [];
	
    #region API
    
    /// @desc Añade un nuevo set de resultados para un objetivo a todos los arrays.
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
    
    /// @desc Devuelve el número de objetivos que fueron afectados por la acción.
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
    /// @param {Real} [index]=0 El índice del objetivo (por defecto, el primero).
    /// @returns {Real}
    static GetDamage = function(_index = 0)
    {
        if (_index < Size() ) return damage[_index];
        return 0;
    }
    
    /// @desc Devuelve el valor de un objetivo en un índice específico.
    /// @param {Real} [index]=0 El índice del objetivo (por defecto, el primero).
    /// @returns {Real}
    static GetValue = function(_index = 0)
    {
        if (_index < Size() ) return value[_index];
        return 0;
    }
    
    /// @desc Comprueba si al menos uno de los objetivos fue derrotado.
    /// @returns {Bool}
    static WasAnyDefeated = function()
    {
		return (array_any(defeated, function(_value) { return _value } ) );
    }

	#endregion
}