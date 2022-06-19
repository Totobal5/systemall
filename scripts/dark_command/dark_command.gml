/// @param	{String}	dark_subtype		Sub-Tipo
/// @param	{Real}		consume				Cuanto gasta para usar este comando
/// @param	{Bool}		[include_caster]	El caster tambien puede ser afectado
/// @param	{Real}		[targets]			Cantidad de objetivos afectados
/// @return {Struct.DarkCommand}
function DarkCommand(_subtype, _consume=0, _include=true, _targets=1) : MallComponent("") constructor 
{
    #region PRIVATE
	/// @ignore
	__subtype = _subtype;   // El sub-tipo al que pertenece    
	/// @ignore
    __type = "";			// Se agrega al final    
    /// @ignore
    __include = _include;
	/// @ignore
    __targets = _targets;
    /// @ignore
	__is = instanceof(self);
	
	#endregion
	
    command = undefined;	// Funcion a usar si cumple la condicion
	fail	= undefined;	// Funcion a usar si no se comple la condicion
    conditions = undefined;	// Condiciones para usar este comando
    
	consume = _consume;		// Cuanto gasta para usar este comando
  
    /// @param {String} dark_type
	/// @return {Struct.DarkCommand}
    static setType = function(_type) 
	{
		__type = _type; 
		return self; 
	}
    
    /// @param {Function} command_method	function(caster, target, extra)
	/// @return {Struct.DarkCommand}
    static setCommand = function(_function) 
	{
        spell = method(undefined, _method);	// contexto propio
        return self;
    }

    /// @param {Function} fail_method		function(caster, target, extra)
	/// @return {Struct.DarkCommand}
	static setFail = function(_function)
	{
		fail = method(undefined, _function);
		return self;
	}
	
	/// @param {Function} condition_method
	static setConditions = function(_function)
	{
		conditions = method(undefined, _function);
		return self;
	}
	
    /// @param	{Bool}	include_caster
    /// @param	{Real}	targets
	/// @return {Struct.DarkCommand}	
    static customize = function(_include, _targets) 
	{
        __include = _include;
        __targets = _targets;
        
        return self;
    }
	
	static execute = function(_caster, _target, _extra)
	{
		if (conditions(_caster, _target, _extra) )
		{
			return (command(_caster, _target, _extra) );
		}
		else
		{
			return (fail(_caster, _target, _extra) );
		}
	} 
	
	static getCommand = function()
	{
		return (command);	
	}
}