/// @desc Represents an active effect instance attached to an entity state.
/// @param {String} key The key of the effect template this instance references.
/// @param {Struct.MallEntity} entity The entity this effect instance is attached to.
function MallEffectInstance(_key, _entity) : MallEffect(_key) constructor
{
	/// @ignore Static counter used to generate unique effect instance ids.
	static __effect_counter = 0;
	
	/// @type {String} Unique runtime id for this effect instance.
	id = "";

	/// @type {Struct.WeakRef<Struct.MallEntity>} The entity this effect instance is attached to.
	owner = weak_ref_create(_entity);

	#region EVENTS

	/// @desc Runs when the effect is added to a state.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance containing this effect.
	/// @returns {undefined}
	// event_on_start
	
	/// @desc Runs when the effect is removed from a state.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance that contained this effect.
	/// @returns {undefined}
	// event_on_end
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallEffectInstance} effect_instance Current effect instance.
	/// @returns {undefined}
	// event_on_turn_start
	
	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallEffectInstance} effect_instance Current effect instance.
	/// @returns {undefined}
	// event_on_turn_end

	/// @desc Runs to calculate the value to apply.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallEffectInstance} effect_instance Current effect instance.
	/// @param {Real} base_value Base modifier value from template.
	/// @param {Enum.MALL_NUMTYPE} base_type Base modifier num type from template.
	/// @returns {Real}
	// event_on_calculate

	#endregion

	#region PUBLIC API

	/// @desc Exports the current effect instance state.
	/// @returns {Struct}
	static Export = function()
	{
		var _this = self;
		with (method(self, MallEffect.Export)())
		{
			is = _this.id;
			return self;
		}
	}
	
	/// @desc Imports the effect instance state.
	/// @param {Struct} data State data to import.
	/// @returns {undefined}
	static Import = function(_data)
	{
		method(self, MallEffect.Import) (_data);
		id = _data[$ "id"] ?? id;

		return self;
	}

	#endregion
}
