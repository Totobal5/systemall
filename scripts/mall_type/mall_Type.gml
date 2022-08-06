/// @desc	Un grupo es como debe funcionar los componentes guardados (MallStorage) entre sí.
///			Esto sirve para diferenciar clases, especies o razas en distintos rpg (Humanos distintos a Orcos por ejemplo)
/// @param	{String} type_key
/// @return {Struct.MallType}
function MallType(_KEY) : MallComponent(_KEY) constructor 
{
    #region PRIVATE
	/// @ignore
	__is = instanceof(self);
	
	__statsProp = {};		// Bonus o funcion al utilizar una estadistica
	__stateProp = {};		// Bonus o funcion al utilizar un estado
	__modProp   = {};		// Bonus o funcion al utilizar un modificador
	__equipmentProp = {};	// Bonus o funcion al utilizar un equipamiento
	
    #endregion
	
    #region METHODS  

    #endregion
}