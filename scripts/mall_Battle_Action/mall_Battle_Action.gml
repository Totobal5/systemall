/// @desc Encapsulates a full combat action payload between selector (AI/UI) and battle manager.
/// @param {Struct.MallEntity} caster Entity performing the action.
/// @param {Struct.MallCommand|Struct.MallItem} source Command or item source.
/// @param {Array<Struct.MallEntity>} targets Action targets.
function MallBattleAction(_key, _caster, _source, _targets) : Mall(_key) constructor
{
	/// @type {Struct.MallEntity} Entity performing the action.
	caster = _caster;
	
	/// @type {Struct.MallCommand|Struct.MallItem} Command/item template being used.
	source = _source;
	
	/// @type {Array<Struct.MallEntity>} Array with target entity instances.
	targets = _targets;

	/// @type {Struct.MallIterator} Optional iterator for multi-turn actions (for example, channeling or multi-hit commands).
	iterator = new MallIterator();
}