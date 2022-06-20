/// @ignore 
/// @param {String} _key
/// @param {Struct.MallStat} _stat
/// @return {Struct.__PartyStatsAtom}
function __PartyStatsAtom(_key, _stat) : MallComponent(_key) constructor {
	#region PRIVATE
	/// @ignore
	__displayKey = _stat.__displayKey;	// Llave para obtener el nombre de display
	/// @ignore
	__displayTextKey = _stat.__displayTextKey;	// Textos extras
	/// @ignore
	__return = method(undefined, _stat.__displayMethod);	// Como devolver sus valores
	
	#endregion
	
	#region PUBLIC
	base	 = numtype_value(_stat.__initial);	// Se pone el valor inicial
	baseType = numtype_type (_stat.__initial);
	
	// -- Single
	level  = 1;					// Nivel de la estadistica si se usa individualmente
	single = _stat.__lvlSingle	// Si sube de nivel individualmente
	limit  = _stat.__limits;	// Referencia a los limites de la configuracion
	condition = MALL_DUMMY_METHOD;	// Condicion que debe cumplir para subir de nivel

	// Valores que posee
	valueControl   = numtype_value(base);	// El valor final tomando en cuenta el control
	valueEquipment = valueControl;			// El valor final tomando en cuenta el equipamiento
	
	valueMax     = valueControl;	// Valor de la estadistica actual maximo respecto al nivel
	valueMaxLast = valueControl;	// El ultimo valor maximo
	
	valueActual = valueControl;		// El valor actual de la estadistica
	valueLast   = valueControl;		// El anterior valor actual
	valueMin    = limit[0];			// Valor minimo en que la estadistica puede estar

	toMax = _stat.__toMax.copy();	// Copiar contadores para que no hayan conflictos
	toMin = _stat.__toMin.copy();	// Copiar contadores para que no hayan conflictos

	#endregion
	
	static send = function()
	{
		return 
		{
			key: other.__key,
			valueActual:	other.valueActual,
			valueMax:		other.valueMax,
			valueMaxLast:	other.valueMaxLast,
			valueEquipment: other.valueEquipment,
			valueControl:	other.valueControl
		}
	}
}