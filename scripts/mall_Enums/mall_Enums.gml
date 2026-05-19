/// @ignore Numeric value interpretation mode.
enum MALL_NUMTYPE   {REAL, PERCENT}

/// @ignore Payload field index mapping for numeric values.
enum MALL_NUMVAL    {VALUE, TYPE}

/// @ignore Defines the possible states of a MallIterator.
enum MALL_ITERATOR_STATE 
{
	INACTIVE,   // Iterator is not active.
	WORKING,    // Iterator is processing the current cycle.
	CYCLE_END,  // A cycle has completed (may repeat or finish).
	COMPLETED   // All cycles and repeats have completed.
}

/// @ignore In operations where a target value can be specified, defines what the target value is referencing.
enum MALL_STAT_TARGET
{
	PEAK,
	EQUIPMENT,
	CONTROL,
	CURRENT,
	LAST_CURRENT,
	LAST_PEAK,
}

/// @ignore Defines when an effect should execute during a turn.
enum MALL_EFFECT_TURN 
{
	START,	// Start of the turn.
	END,	// End of the turn.
	BOTH	// Both start and end of the turn.
}