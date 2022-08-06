/// @desc	Donde se guarda la configuracion para los modificadores del proyecto
///			Se configuran: 
/// @param {String} element_key
/// @return {Struct.MallMods}
function MallMods(_KEY) : MallComponent(_KEY) constructor {
    #region PRIVATE
	// A estas funciones se les pasa el usuario, objetivo y el valor que se quiere modificar
	__onAttack  = function() {};
	__onDefense = function() {};
	
	#endregion
	
	#region METHODS
	/// @param {Function}	interaction function(USER, TARGET, VALUE)
	static setOnAttack = function(_METHOD) 
	{
		__onAttack = _METHOD;
		return self;
	}
	
	#endregion
}