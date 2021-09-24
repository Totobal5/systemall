/// @description Dañar
Psj1.BattleTarget(Psj2, "DARK.BATTLE.ATACK", ["Mano der.", "Mano izq."] );

To1 = Psj1.stats_final; /// @is {group_create}
To2 = Psj2.stats_final;

Stat1 = To1.ToStringStruct();
Stat2 = To2.ToStringStruct();

State1 = Psj1.control.ToStringStates();
State2 = Psj2.control.ToStringStates();

Lvl1 = string(Psj1.stats.lvl);
Lvl2 = string(Psj2.stats.lvl);