/// @param {String} equipment_key
/// @return {Struct.MallEquipment}
function MallEquipment(_KEY) : MallStat(_KEY) constructor 
{
	#region PRIVATE
	__is = instanceof(self);
	#endregion
	
	items = {};	// Que tipos de objetos puede llevar y si posee un bonus o no.
	
	/// @desc Ejecuta un evento al pasar un tipo de objeto
	eventItemtype = function(_ITEM_KEY, _FLAG) {return [0, 0];};
	
	/// @desc Comprueba su un tipo de objeto pasa la prueba
	checkItemType = function(_ITEM_KEY, _FLAG) {return true};
	
	/// @desc Para comparar 2 objetos y sus efectos en la entidad
	eventCompare = function(_STAT, _EQUIPPED, _COMPARE) {
		var _statKeys = mall_get_stat_keys();
		var _eStat = _EQUIPPED.statsNormal;
		var _cStat = _COMPARE .statsNormal;
		var _return = {};
		var i=0; repeat(array_length(_statKeys) )
		{
			var _key  = _statKeys[i];
			var _stat = _STAT.get(_key);
			var _eValue = _eStat[$ _key] ?? [0, 0];
			var _cValue = _cStat[$ _key] ?? [0, 0];
			
			var _comp1=0, _comp2=0;
			switch (_eValue[1] )
			{
				case MALL_NUMTYPE.PERCENT:
				_comp1 = (_stat.peak * _eValue[0] ) / 100;
				break;
				
				case MALL_NUMTYPE.REAL:
				_comp1 = (_stat.peak * _eValue[0] );
				break;
			}
			
			switch (_cValue[1] )
			{
				case MALL_NUMTYPE.PERCENT:
				_comp2 = (_stat.peak * _cValue[0] ) / 100;
				break;
				
				case MALL_NUMTYPE.REAL:
				_comp2 = (_stat.peak * _cValue[0] );
				break;
			}			
			
			_return[$ _key] = (_comp1 - _comp2);
			i = i + 1;
		}
		
		return _return;
	}
	
	#region METHODS
	
	/// @desc Indica que tipos de objetos puede equipar
	/// @param	{String}	itemtype_key
	/// @param	{Real}		bonus_value
	/// @param	{Real}		number_type
	/// @param ...
	static setItemtype = function(_KEY, _VALUE, _TYPE=0) 
	{
		var i=0; repeat(argument_count div 3)
		{
			items[$ argument[i] ] = [
				argument[i + 1], 
				argument[i + 2] 
			];
			
			i = i + 1;
		}
		
        return self;
    }
	
	/// @param {String} item_key
	/// @return {Array<Real>}
	static getBonusType = function(_KEY) 
	{
        return (__items[$ _KEY] );
    }
	
	#endregion
}