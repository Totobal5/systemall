/// @desc	Donde se guarda la configuracion para los elementos del proyecto
///			Se configuran: 
/// @param {String} element_key
/// @return {Struct.MallElement}
function MallElement(_key) : MallComponent(_key) constructor {
    #region PRIVATE
	__relatedStats = {};	// Estadisticas relacionadas, busqueda rapida
	
	__events = {
		onHit: 		__nofunelement__,
		onAttack:	__nofunelement__
	}
	
	
	#endregion
	
    #region METHODS
	static setOnHit	= function(_method)
	{
		__events.onHit = _method;
		return self;
	}
	
	static setOnAttack = function(_method)
	{
		__events.onAttack = _method;	
		return self;
	}
	
	/// @desc Devuelve todas las estadisticas relacionadas
	static getRelated = function()
	{
		var _prefix = mall_get_element_prefix(__key);
		var i=0; repeat(_prefix)
		{
			var _prex = __key _prefix[i++];
			__relatedStats[$ _prex] = _prex;
		}
		return self;
	}
	
	static __nofunelement__ = function()
	{
	}
	
    #endregion
}
