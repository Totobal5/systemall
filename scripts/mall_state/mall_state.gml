/// @desc Donde se guardan las propiedades de los estados
/// @param {String}	state_key
function MallState(_KEY) : MallModify(_KEY) constructor 
{
	#region PRIVATE
	__is = instanceof(self);
	
	#endregion
	
	init = false; // Valor inicial del estado
	type = MALL_NUMTYPE.REAL; // Tipo de numero que utiliza
	
	controls = -1;	// Cuantos se pueden agregar en party. -1 para infinitos (NO PUEDE SER 0)
	
	percent = 0;	// Probabilidad default
	same = false;	// Si acepta el mismo efecto varias veces
	
	/// @desc Si puede actuar en PartyControl
	/// @param {Any*} [flag]=""
	checkStart  = function(_FLAG="") {return false};
	
	/// @desc Comprobar si puede usar su final event
	/// @param {Any*} [flag]=""
	checkFinish = function(_FLAG="") {return false;};
	
	#region METHODS
	/**
	* Establece el valor inicial y el limite de este mismo estado (-1 es infinitos)
	* @param {Bool} initial_bool		Description
	* @param {Real} default_probability	Description
	* @param {Real} [control_max]=-1	Description
	* @param {Bool} [accept_same]=true	Description
	*/
	static setControl = function(_BOOL, _PROBABILITY, _CONTROLS=-1, _SAME=true)
	{
		init = _BOOL;
		percent = _PROBABILITY;
		
		controls = _CONTROLS;
		same = _SAME;
		
		return self;
	}

	/**
	* Function Description
	* @param {Function} check_affect Description
	*/
	static setCheckAffect = function(_CHECK)
	{
		checkAffect = _CHECK;
		return self;
	}
	
	/**
	* Function Description
	* @param {Function} check_last Description
	*/
	static setCheckLast = function(_CHECK)
	{
		__checkLast = _CHECK;
		return self;
	}

	#endregion
}