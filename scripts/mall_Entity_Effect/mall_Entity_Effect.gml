/// @desc Represents an active effect instance attached to an entity state.
/// @param {Struct.MallEffect} effect_template Effect template to instantiate.
function MallEffectInstance(_template) constructor
{
	/// @ignore Static counter used to generate unique effect instance ids.
	static __effect_counter = 0;
	
	/// @desc Unique runtime id for this effect instance.
	/// @type {String}
	id = $"{_template.key}_{__effect_counter++}";
	
	/// @desc MallEffect template referenced by this instance.
	/// @type {Struct.MallEffect}
	template = _template;
	
	/// @desc Numeric effect value, for example 15 damage.
	/// @type {Real}
	value = template.value;
	
	/// @desc Value type, either real or percent.
	/// @type {Enum.MALL_NUMTYPE}
	num_type = template.num_type;
	
	/// @desc Stat modifiers applied by this effect.
	/// @type {Struct}
	stats = template.stats;	
	
	/// @desc Runtime parameters cloned from the effect template.
	/// @type {Struct}
	params = variable_clone(template.params);
	
	// Each instance owns independent iterators.
	var _duration = 1;
	var _repeats = 0;
	
	if (struct_exists(template, "iterator_start_config") )
	{
		var _i = template.iterator_start_config;
		_duration = _i[$ "duration"] ?? 1;
		_repeats = _i[$ "repeats"] ?? 0;
	}
	
	/// @desc Iterator that controls effect startup timing.
	/// @type {Struct.MallIterator}
	iterator_start = (new MallIterator() ).Configure(_duration, _repeats);
	
	if (struct_exists(template, "iterator_end_config") )
	{
		var _i = template.iterator_end_config;
		_duration = _i[$ "duration"] ?? 1;
		_repeats = _i[$ "repeats"] ?? 0;
	}
	
	/// @desc Iterator that controls effect ending timing.
	/// @type {Struct.MallIterator}
	iterator_end = (new MallIterator() ).Configure(_duration, _repeats);
	
	#region EVENTS
	
	/// @desc Runs when the effect is added to a state.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance containing this effect.
	/// @returns {undefined}
	event_on_start = method(self, mall_get_event( template[$ "event_on_start"] ) );
	
	/// @desc Runs when the effect is removed from a state.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance that contained this effect.
	/// @returns {undefined}
	event_on_end = method(self, mall_get_event( template[$ "event_on_end"] ) );
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallEffectInstance} effect_instance Current effect instance.
	/// @returns {undefined}
	event_on_turn_start = method(self, mall_get_event( template[$ "event_on_turn_start"] ) );
	
	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallEffectInstance} effect_instance Current effect instance.
	/// @returns {undefined}
	event_on_turn_end = method(self, mall_get_event( template[$ "event_on_turn_end"] ) );

	#endregion

	#region METHODS

	/// @desc Exports the current effect instance state.
	/// @returns {{key: String, id: String, iterator_start: Struct, iterator_end: Struct}}
	static Export = function()
	{
		var _this = self;
		return {
			key:			_this.template.key,
			id:				_this.id,
			iterator_start:	_this.iterator_start.Export(),
			iterator_end:	_this.iterator_end.Export()
		};
	}
	
	/// @desc Imports the effect instance state.
	/// @param {Struct} data State data to import.
	/// @returns {undefined}
	static Import = function(_data)
	{
		id = _data[$ "id"] ?? id;
		if (struct_exists(_data, "iterator_start") )  { struct_get(self, "iterator_start").Import(_data[$ "iterator_start"]); }
		if (struct_exists(_data, "iterator_end") ) { struct_get(self, "iterator_end").Import(_data[$ "iterator_end"]); }
	}

	#endregion
}
