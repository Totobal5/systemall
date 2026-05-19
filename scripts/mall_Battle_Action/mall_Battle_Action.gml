/// @desc Encapsulates a full combat action payload between selector (AI/UI) and battle manager.
/// @param {Struct.MallEntity} caster Entity performing the action.
/// @param {Struct.MallCommand|Struct.MallItem} source Command or item source.
/// @param {Array<Struct.MallEntity>} targets Action targets.
function BattleAction(_caster, _source, _targets) constructor
{
	/// @desc Entity performing the action.
	caster = _caster;
	
	/// @desc Command/item template being used.
	source = _source;
	
	/// @desc Array with target entity instances.
	targets = _targets;
}