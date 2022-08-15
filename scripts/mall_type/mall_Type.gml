/// @desc	Un grupo es como debe funcionar los componentes guardados (MallStorage) entre sí.
///			Esto sirve para diferenciar clases, especies o razas en distintos rpg (Humanos distintos a Orcos por ejemplo)
/// @param	{String} type_key
/// @return {Struct.MallType}
function MallType(_KEY) : MallComponent(_KEY) constructor 
{
	__is = instanceof(self);
	props = {}
	delete iterator;
	
    #region METHODS
	/// @ignore
	static initialize = function() 
	{
		var fun = method(,function(stat, key) {
			if (!variable_struct_exists(props, key) )
			{
				props[$ key] = new __MallTypeBonus();
			}
			else
			{
				__mall_trace("Repetido en MallType");	
			}
		});
		mall_stat_foreach  (fun);
		mall_state_foreach (fun);
		mall_modify_foreach(fun);
		
		mall_equipment_foreach(fun);
	}
	
	/// @return {Struct.__MallTypeBonus}
	static get = function(_KEY) 
	{
		return (props[$ _KEY] );
	}
	
	static set = function(_KEY, _VALUE, _TYPE)
	{
		var _prop = props[$ _KEY];
		_prop.bonus = _VALUE;
		_prop.type  =  _TYPE;
		return _prop;
	}
	
	static setEventStart  = function(_KEY, _EVENT)
	{
		get(_KEY).eventStart = _EVENT;
		return self;
	}
	
	static setEventFinish = function(_KEY, _EVENT)
	{
		get(_KEY).eventFinish = _EVENT;
		return self;
	}

    #endregion
	
	initialize();
}

/// @ignore
function __MallTypeBonus() constructor
{
	bonus = 0
	type  = MALL_NUMTYPE.REAL;
	
	eventStart  = function(_KEY, _COMPONENT, _FLAG) {return 0; };
	eventFinish = function(_KEY, _COMPONENT, _FLAG) {return 0; };
	
	checkUse = function(_KEY, _COMPONENT, _FLAG) {return true};
}