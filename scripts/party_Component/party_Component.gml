function __PartyComponent(_ENTITY) constructor
{
	__is = instanceof(self);
	__entity = weak_ref_create(_ENTITY);
	__keys = [];
	__initialize = false;
	
	#region METHOD
	static setEntity = function(_ENTITY)
	{
		__entity = weak_ref_create(_ENTITY);
		return self;
	}
	
	/// @return {Struct.PartyEntity}
	static getEntity = function()
	{
		return (__entity.ref);
	}
	
	#endregion
}