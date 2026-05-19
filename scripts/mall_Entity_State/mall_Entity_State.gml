/// @desc Represents a state instance owned by an entity.
/// @param {Struct.MallState} state_template State template to instantiate.
/// @param {Struct.MallEntity} parent_entity Entity that owns this instance.
function MallStateInstance(_template, _entity) constructor
{
	/// @desc MallState template referenced by this instance.
	/// @type {Struct.MallState}
	template = _template;
	
	/// @desc Entity that owns this state instance.
	/// @type {Struct.MallEntity}
	parent_entity = _entity;
	
	/// @desc Current boolean value for this state instance.
	/// @type {Bool}
	boolean_value = template.boolean_value;
	
	/// @desc Value used when this state resets.
	/// @type {Bool}
	reset_value = template.reset_value;
	
	/// @desc Active effect instances currently attached to this state.
	/// @type {Array<Struct.MallEffectInstance>}
	effects = [];
	
	/// @desc Stat modifiers referenced from the state template.
	/// @type {Struct}
	stats = template.stats;
	
	#region EVENTS
	
	/// @desc Runs when the instance is created and whenever its boolean value changes.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @returns {undefined}
	event_on_start = method(parent_entity, mall_get_event( template[$ "event_on_start"] ) );
	
	/// @desc Runs when the instance returns to its original boolean value.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @returns {undefined}
	event_on_end = method(parent_entity, mall_get_event( template[$ "event_on_end"] ) );
	
	/// @desc Runs on each RecalculateStats call.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @returns {undefined}
	event_on_update = method(parent_entity, mall_get_event( template[$ "event_on_update"] ) );
	
	/// @desc Runs on each turn update of the WateManager.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @returns {undefined}
	event_on_turn_update = method(parent_entity, mall_get_event( template[$ "event_on_turn_update"] ) );
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @returns {undefined}
	event_on_turn_start = method(parent_entity, mall_get_event( template[$ "event_on_turn_start"] ) );
	
	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @returns {undefined}
	event_on_turn_end = method(parent_entity, mall_get_event( template[$ "event_on_turn_end"] ) );

	/// @desc Runs when an item is equipped in any entity slot.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @param {Struct.MallSlotInstance} slot_instance The slot where the item was equipped.
	/// @returns {undefined}
	event_on_equip = method(parent_entity, mall_get_event( template[$ "event_on_equip"] ) );
	
	/// @desc Runs when an item is unequipped from any entity slot.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @param {Struct.MallSlotInstance} slot_instance The slot from which the item was unequipped.
	/// @returns {undefined}
	event_on_desequip = method(parent_entity, mall_get_event( template[$ "event_on_desequip"] ) );

	/// @desc Runs after an effect is added to this state.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @param {Struct.MallEffectInstance} effect_instance The effect that was added.
	/// @returns {undefined}
	event_on_add_effect = method(parent_entity, mall_get_event( template[$ "event_on_add_effect"] ) );
	
	/// @desc Runs after an effect is removed from this state.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @param {Struct.MallEffectInstance} effect_instance The effect that was removed.
	/// @returns {undefined}
	event_on_remove_effect = method(parent_entity, mall_get_event( template[$ "event_on_remove_effect"] ) );

	/// @desc Validates whether an effect can be added to this state. Must return bool.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @param {Struct.MallEffect} effect_template The effect template to validate.
	/// @returns {Bool}
	event_can_add_effect = method(parent_entity, __mall_get_event_check_true( template[$ "event_can_add_effect"] ) );

	/// @desc Validates whether an effect can be removed from this state. Must return bool.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @param {Struct.MallEffectInstance} effect_instance The effect to remove.
	/// @returns {Bool}
	event_can_remove_effect = method(parent_entity, __mall_get_event_check_true( template[$ "event_can_remove_effect"] ) );
	
	#endregion

	#region METHODS

	/// @desc Exports the current state instance state.
	/// @returns {{boolean_value: Bool, effects: Array<Struct>}}
	static Export = function()
	{
		var _this = self;
		var _effects_export = [];
		// Export each active effect instance.
		var i=0; repeat(array_length(effects) ) { array_push(_effects_export, effects[i++].Export() ); }

		return {
			boolean_value:	_this.boolean_value,
			effects:		_effects_export
		};
	}
	
	/// @desc Imports the state instance state.
	/// @param {Struct} data State data to import.
	/// @returns {undefined}
	static Import = function(_data)
	{
		boolean_value = _data[$ "boolean_value"] ?? template.boolean_value;
		effects = [];
		
		var _effects_import = _data[$ "effects"] ?? [];
		var i=0; repeat(array_length(_effects_import) )
		{
			var _effect_data = _effects_import[i++];
			/// @type {Struct.MallEffect|Undefined}
			var _effect_template = mall_get_effect(_effect_data.key);
			if (!is_undefined(_effect_template) ) 
			{
				var _effect_inst = new MallEffectInstance(_effect_template);
				_effect_inst.Import(_effect_data);
				
				array_push(effects, _effect_inst);
			}
			else
			{
				__mall_alert($"Effect template was not found: {_effect_data.key}. This effect will be skipped.");
				continue;
			}
		}
	}

	#endregion
}
