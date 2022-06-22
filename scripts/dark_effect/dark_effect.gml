/// @param {String}			mall_component_key	A que componente de mall afecta
/// @param {Real}			start_value
/// @param {Enum.NUMTYPES}	number_type
/// @param {Real}			active_turns
/// @param {Function}		update_callback
/// @param {Function}		end_callback
/// @return {Struct.MallEffect}
function DarkEffect(_key, _init_value, _number_type, _active_turns, _update_callback, _end_callback) : MallComponent(_key) constructor {
    #region PRIVATE
	/// @ignore
	__is = instanceof(self);
	
	__id = "DE000"; // ID unica del efecto
    
    __init  = numtype(_init_value, _number_type);	// Valor inicial para reinicio etc  
    __value = numtype(_init_value, _number_type);	// Valor que aumenta con cada update
	
    // Siempre es contador
    __turns = new Counter(0, _active_turns, 1, true);

	// Actualiza el value
	__endCallback	 = method(undefined, _end_callback    ?? __nofun);	// Al terminar	 function(PartyControl)	{return 0;}
	__updateCallback = method(undefined, _update_callback ?? __nofun);	// Al actualizar function(PartyControl)	{return value;}
	
	#endregion
	
	#region METHODS
	/// @ignore
	static __nofun = function() {};
	
	static update = function()
	{
		__updateCallback();	
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