/// @description Iniciar pelea

var _battle_group = new MallEntityGroup("battle_preview");

_battle_group.Add(mall_entity_create_instance("TRAUCO", irandom(10)));

var _heroes = mall_group_get_entities("HEROES") ?? [];
for (var i = 0; i < array_length(_heroes); i++)
{
	_battle_group.Add(_heroes[i]);
}

array_sort(_battle_group.entities, function(en1, en2) {
	var _spd_1 = en1.StatGet("VELOCIDAD").control_value;
	var _spd_2 = en2.StatGet("VELOCIDAD").control_value;
	return _spd_2 - _spd_1;
});