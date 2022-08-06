/// @param {String}			dark_effect_key	A que componente de mall afecta
/// @param {Real}			start_value
/// @param {Enum.NUMTYPES}	number_type
/// @param {Real}			active_turns
/// @param {Function}		update_callback
/// @param {Function}		end_callback
/// @return {Struct.DarkEffect}
function DarkEffect(_KEY, _INIT_VALUE, _NUMBER_TYPE, _ACTIVE_TURNS, _UPDATE_CALLBACK, _END_CALLBACK) : MallComponent(_KEY) constructor 
{
    #region PRIVATE
	/// @ignore
	__is = instanceof(self);
	__id = "DE000"; // ID unica del efecto
    
	__ready = false;	// Se marca que el efecto termino
    __init  = [_INIT_VALUE, _NUMBER_TYPE];	// Valor inicial para reinicio etc  
    __value = [_INIT_VALUE, _NUMBER_TYPE];	// Valor que aumenta con cada update
	
    // Siempre es contador
	__turns = {
		count: 0,
		limit: _ACTIVE_TURNS,
		reset: self.count,
		resetCount: 0,
		resetLimit: 0
	}

	__turnStart = 0;	// En que turno del combate se inicio
	
	// Actualiza el value
	__startEvent = function(_USER) {return "update control"};
	__updateEvent = {
		onStart: other.__nofun,
		onEnd:	 other.__nofun,
		
		onCombat: other.__nofun,
		onObject: other.__nofun
	}
	__endEvent = _nofun;
	
	#endregion
	
	#region METHODS
	/// @ignore
	static __nofun = function() {};
	
	/// @return {String}
	static startEvent = function(_ENTITY)
	{
		return (__startEvent(_ENTITY) );
	}
	
	/// @return {String}
	static updateEvent = function()
	{
		return (__updateCallback() );	
	}
	
	static resetEvent  = function()
	{
		return (__resetCallback() );
	}
	
	static finish  = function()
	{
		__endCallback();	
	}
	
	static get = function()
	{
		return (__value);	
	}
	
	static getInit = function()
	{
		return (__init);	
	}
	
	static getID = function()
	{
		return (__id) ;	
	}
	
	static getTurns = function()
	{
		return (__turns );	
	}
	
	#endregion
}