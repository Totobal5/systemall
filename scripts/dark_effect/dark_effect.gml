/// @return {Struct.DarkEffect}
function DarkEffect(_KEY, _START, _TURNS_START, _TURNS_FINISH, _TURN_EVENT_START, _TURN_EVENT_FINISH) : MallStat(_KEY) constructor 
{
    #region PRIVATE
	__is = instanceof(self);
	__id = "DE000"; // ID unica del efecto

	inTurn = 0;	// 0 en el inicio del turno 1 en el final del turno 2 en ambos
	value = _START;	// Valor que cambia real/porcentual
	ready = false;	// Se marca que el efecto termino
	
	turnStart = 0;	// En que turno empezo
	turn = 0;		// En que turno va
	turnEnd = 0;	// En que turno termino ?
	
	delete iterator;
	iteratorStart = new __MallIterator();
	iteratorStart.countLimits = (is_array(_TURNS_START) ) ?
		irandom_range(_TURNS_START[0], _TURNS_START[1] ) :
		_TURNS_START;
	
	iteratorFinish = new __MallIterator();
	iteratorFinish.countLimits = (is_array(_TURNS_FINISH) ) ?
		irandom_range(_TURNS_FINISH[0], _TURNS_FINISH[1] ) :
		_TURNS_FINISH;

	setEventTurnStart (_TURN_EVENT_START);
	setEventTurnFinish(_TURN_EVENT_FINISH);

	eventRemove = function()
	{
		
	}
	
	#endregion
	
	#region METHODS
	static set = function(_VALUE, _TYPE)
	{
		_TYPE ??= type;
		value[_TYPE] = _VALUE;
	}
	
	static add = function(_VALUE, _TYPE)
	{
		_TYPE ??= type;
		value[_TYPE] += _VALUE;
	}

	#endregion
}