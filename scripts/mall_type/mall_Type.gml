/// @desc	Un grupo es como debe funcionar los componentes guardados (MallStorage) entre sí.
///			Esto sirve para diferenciar clases, especies o razas en distintos rpg (Humanos distintos a Orcos por ejemplo)
/// @param	{String} type_key
/// @return {Struct.MallType}
function MallType(_KEY) : MallComponent(_KEY) constructor 
{
    #region PRIVATE
	/// @ignore
	__is = instanceof(self);
	
	__statsProperties  = {};	// Bonus o funcion al utilizar una estadistica
	__statesProperties = {};	// Bonus o funcion al utilizar un estado
	__modifyProperties = {};	// Bonus o funcion al utilizar un modificador
	__equipmentProperties = {};	// Bonus o funcion al utilizar un equipamiento
	
    #endregion
	
    #region METHODS
	/// @ignore
	static start = function() 
	{
		mall_stat_foreach  (function(_STAT, _KEY, i, _ARG) {__statsProperties [$ _KEY] = new __MallTypeBonus(); } );
		mall_state_foreach (function(_STAT, _KEY, i, _ARG) {__statesProperties[$ _KEY] = new __MallTypeBonus(); } );
		mall_modify_foreach(function(_STAT, _KEY, i, _ARG) {__modifyProperties[$ _KEY] = new __MallTypeBonus(); } );
		
		mall_equipment_foreach(function(_STAT, _KEY, i, _ARG) {__equipmentProperties[$ _KEY] = new __MallTypeBonus(); } );
	}
	
	#region Stat
	///	@param	{String}	stat_key
	static setStatBonus = function(_STAT_KEY, _VALUE, _TYPE)
	{
		var _stat = getStat(_STAT_KEY);
		_stat.__bonus[0] = _VALUE;
		_stat.__bonus[1] =  _TYPE;
		return self;
	}
	
	///	@param	{String}	stat_key
	static setStatEventUseStart  = function(_STAT_KEY, _USE_EVENT)
	{
		var _stat = getStat(_STAT_KEY);
		
		_stat.__eventUseStart = _USE_EVENT;
		
		return self;
	}
	
	///	@param	{String}	stat_key
	static setStatEventUseFinish = function(_STAT_KEY, _USE_EVENT)
	{
		var _stat = getStat(_STAT_KEY);
		
		_stat.__eventUseFinish = _USE_EVENT;
		
		return self;		
	}
	
	///	@param	{String}	stat_key
	static setStatCheckUse = function(_STAT_KEY, _CHECK)
	{
		var _stat = getStat(_STAT_KEY);
		_stat.__checkUse = _CHECK;
		return self;
	}
	
	/// @return {Struct.__MallTypeBonus}
	static getStat   = function(_KEY)
	{
		return (__statsProperties[$ _KEY] );
	}
	#endregion
	
	#region State
	///	@param	{String}	state_key
	static setStateBonus = function(_STATE_KEY, _VALUE, _TYPE)
	{
		var _state = getState(_STATE_KEY);
		_state.__bonus[0] = _VALUE;
		_state.__bonus[1] =  _TYPE;
		return self;
	}
	
	///	@param	{String}	state_key
	static setStateEventUseStart  = function(_STATE_KEY, _USE_EVENT)
	{
		var _state = getState(_STATE_KEY);
		_state.__eventUseStart = _USE_EVENT;
		
		return self;
	}
	
	///	@param	{String}	state_key
	static setStateEventUseFinish = function(_STATE_KEY, _USE_EVENT)
	{
		var _state = getState(_STATE_KEY);
		_state.__eventUseFinish = _USE_EVENT;
		
		return self;
	}
	
	///	@param	{String}	state_key
	static setStateCheckUse = function(_STATE_KEY, _CHECK)
	{
		var _state = getState(_STATE_KEY);
		_state.__checkUse = _CHECK;
		
		return self;
	}
	
	/// @return {Struct.__MallTypeBonus}
	static getState  = function(_KEY)
	{
		return (__statesProperties[$ _KEY] );	
	}
	
	#endregion
	
	#region Modify
	///	@param	{String}	modify_key
	static setModifyBonus = function(_MODIFY_KEY, _VALUE, _TYPE)
	{
		var _modify = getModify(_MODIFY_KEY);
		_modify.__bonus[0] = _VALUE;
		_modify.__bonus[1] =  _TYPE;
		return self;
	}
	
	///	@param	{String}	modify_key
	static setModifyEventUseStart  = function(_MODIFY_KEY, _USE_EVENT)
	{
		var _modify = getModify(_MODIFY_KEY);
		_modify.__eventUseStart = _USE_EVENT;
		
		return self;
	}
	
	///	@param	{String}	modify_key
	static setModifyEventUseFinish = function(_MODIFY_KEY, _USE_EVENT)
	{
		var _modify = getModify(_MODIFY_KEY);
		_modify.__eventUseFinish = _USE_EVENT;
		
		return self;
	}
	
	///	@param	{String}	modify_key
	static setModifyCheckUse = function(_MODIFY_KEY, _CHECK)
	{
		var _modify = getModify(_MODIFY_KEY);
		_modify.__checkUse = _CHECK;
		
		return self;
	}
	
	/// @return {Struct.__MallTypeBonus}
	static getModify = function(_KEY)
	{
		return (__modifyProperties[$ _KEY] );
	}
	
	#endregion
	
	#region Equipment
	///	@param	{String}	equipment_key
	static setEquipmentBonus = function(_EQUIPMENT_KEY, _VALUE, _TYPE)
	{
		var _equipment = getEquipment(_EQUIPMENT_KEY);
		_equipment.__bonus[0] = _VALUE;
		_equipment.__bonus[1] =  _TYPE;
		return self;
	}
	
	///	@param	{String}	equipment_key
	static setEquipmentEventUseStart  = function(_EQUIPMENT_KEY, _USE_EVENT)
	{
		var _equipment = getEquipment(_EQUIPMENT_KEY);
		_equipment.__eventUseStart = _USE_EVENT;
		
		return self;
	}
	
	///	@param	{String}	equipment_key
	static setEquipmentEventUseFinish = function(_EQUIPMENT_KEY, _USE_EVENT)
	{
		var _equipment = getEquipment(_EQUIPMENT_KEY);
		_equipment.__eventUseFinish = _USE_EVENT;
		
		return self;
	}
	
	///	@param	{String}	equipment_key
	static setEquipmentCheckUse = function(_EQUIPMENT_KEY, _CHECK)
	{
		var _equipment = getEquipment(_EQUIPMENT_KEY);
		_equipment.__checkUse = _CHECK;
		
		return self;
	}	
	
	/// @return {Struct.__MallTypeBonus}
	static getEquipment = function(_KEY)
	{
		return (__equipmentProperties[$ _KEY] );
	}
	
	#endregion
	
    #endregion
	
	start();
}

/// @ignore
function __MallTypeBonus() constructor
{
	__bonus = [0, MALL_NUMTYPE.REAL];
	
	__eventUseStart  = function(_KEY, _COMPONENT, _FLAG) {return 0; };
	__eventUseFinish = function(_KEY, _COMPONENT, _FLAG) {return 0; };
	
	__checkUse = function(_KEY, _COMPONENT, _FLAG) {return true};
}