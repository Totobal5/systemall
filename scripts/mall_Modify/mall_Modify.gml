/// @desc	Donde se guarda la configuracion para los modificadores del proyecto
///			Se configuran: 
/// @param {String} modify_key
/// @return {Struct.MallModify}
function MallModify(_KEY) : MallComponent(_KEY) constructor 
{
    #region PRIVATE
	__is = instanceof(self);
	
	#endregion
	
	// -- Eventos --
	
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventStart = function(_ENTITY, _FLAG="") {return ""};		// Funcion a usar cuando se inicia el estado

	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventTurnStart  = function(_ENTITY, _FLAG="") {return ""}	// Al iniciar turno
	
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventTurnFinish = function(_ENTITY, _FLAG="") {return ""}	// Al terminar turno
	
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventCombatStart  = function(_ENTITY, _FLAG="") {return ""; }	// Al intentar actuar inicio (todo lo que se indique que es combate)

	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventCombatFinish = function(_ENTITY, _FLAG="") {return ""}		// Al intentar actuar final(todo lo que se indique que es combate)
	
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventObjectStart = function(_ENTITY, _FLAG="") {return ""}		// Al intentar actuar inicio (todo lo que se indique que no es combate)
	
	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}
	eventObjectFinish = function(_ENTITY, _FLAG="") {return ""}		// Al intentar actuar final  (todo lo que se indique que no es combate)	

	/// @param {Any*}	entity
	/// @param {String}	[flag]
	/// @return {String}B
	eventFinish = function(_ENTITY, _FLAG="") {return ""};			// Funcion a usar cuando se finaliza el estado
	
	#region METHODS	

	/// @param	{Function}	start_event
	static setEventStart  = function(_EVENT)
	{
		eventStart = _EVENT;
		return self;
	}

	/// @param	{Function}	finish_event
	static setEventFinish = function(_EVENT)
	{
		eventFinish = _EVENT;
		return self;
	}

	/// @param	{Function}	turn_start_event
	static setEventTurnStart  = function(_EVENT)
	{
		eventTurnStart  = _EVENT;	// Al iniciar turno
		return self;
	}
	
	/// @param	{Function}	finish_turn_event
	static setEventTurnFinish = function(_EVENT)
	{
		eventTurnFinish = _EVENT;	// Al terminar turno
		return self;
	}

	/// @param	{Function}	combat_start_event
	static setEventCombatStart = function(_EVENT)
	{
		eventCombatStart = _EVENT;
		return self;
	}

	/// @param	{Function}	combat_finish_event
	static setEventCombatFinish = function(_EVENT)
	{
		eventCombatFinish = _EVENT;
		return self;
	}

	/// @param	{Function}	object_start_event
	static setEventObjectStart  = function(_EVENT)
	{
		eventObjectStart = _EVENT;
		return self;
	}

	/// @param	{Function}	object_finish_event
	static setEventObjectFinish = function(_EVENT)
	{
		eventObjectFinish = _EVENT;
		return self;
	}

	#endregion
}