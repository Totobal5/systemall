/// @desc Represents a state instance owned by an entity.
/// @param {String} key The key of the state template this instance references.
/// @param {Struct.MallEntity} parent_entity Entity that owns this instance.
function MallStateInstance(_key, _entity) : MallState(_key) constructor
{
	/// @type {Struct} Cache for events to avoid redundant lookups. Maps event keys to resolved function references.
	__cache = { instance: {}, template: {}, effect: {} };

	/// @type {Struct.MallEntity} Entity that owns this state instance.
	owner = weak_ref_create(_entity);

	/// @type {Array<Struct.MallEffectInstance>} Active effect instances currently attached to this state.
	effects = [];
	
	#region EVENTS

	/// @desc Runs when the instance is created and whenever its boolean value changes.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	// event_on_start
	
	/// @desc Runs when the instance returns to its original boolean value.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	// event_on_end
	
	/// @desc Runs on each RecalculateStats call.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	// event_on_update
	
	/// @desc Runs on each turn update of the WateManager.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	// event_on_turn_update
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	//event_on_turn_start
	
	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	// event_on_turn_end

	/// @desc Runs when an item is equipped in any entity slot.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @param {Struct.MallSlotInstance} slot_instance The slot where the item was equipped.
	// event_on_equip
	
	/// @desc Runs when an item is unequipped from any entity slot.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @param {Struct.MallSlotInstance} slot_instance The slot from which the item was unequipped.
	/// @returns {undefined}
	// event_on_desequip

	/// @desc Runs after an effect is added to this state.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @param {Struct.MallEffectInstance} effect_instance The effect that was added.
	/// @returns {undefined}
	// event_on_add_effect
	
	/// @desc Runs after an effect is removed from this state.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @param {Struct.MallEffectInstance} effect_instance The effect that was removed.
	/// @returns {undefined}
	// event_on_remove_effect

	/// @desc Validates whether an effect can be added to this state. Must return bool.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @param {Struct.MallEffect} effect_template The effect template to validate.
	/// @returns {Bool}
	// event_can_add_effect

	/// @desc Validates whether an effect can be removed from this state. Must return bool.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Current instance.
	/// @param {Struct.MallEffectInstance} effect_instance The effect to remove.
	/// @returns {Bool}
	// event_can_remove_effect

	#endregion

	#region METHODS

	/// @desc Exports the current state instance state.
	/// @returns {Struct}
	static Export = function()
	{
		var _this = self;
		with (method(self, MallState.Export) () )
		{	
			effects = array_map(_this.effects, function(_value, _index) { return _value.Export(); });
			return self;
		}
	}
	
	/// @desc Imports the state instance state.
	/// @param {Struct} data State data to import.
	/// @returns {undefined}
	static Import = function(_data)
	{
		method(self, MallState.Import) (_data);

		// import effects
		var _data_effects = _data[$ "effects"] ?? [];
		var i=0; repeat(array_length(_data_effects) )
		{
			var _effect_data = _data_effects[i++];
			/// @type {Struct.MallEffect|Undefined}
			var _effect_template = mall_get_effect(_effect_data.key);
			if (!is_undefined(_effect_template) )
			{
				var _effect_inst = new MallEffectInstance(_effect_data.key, owner.ref);
				_effect_inst.Import(_effect_data);
				
				array_push(effects, _effect_inst);
			}
			else
			{
				__mall_alert($"Effect template was not found: {_effect_data.key}. This effect will be skipped.");
				continue;
			}
		}

		return self;
	}

	#endregion
}
