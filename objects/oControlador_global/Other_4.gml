/// @desc
mall_init();

dark_init();
bag_init ();

bag_storage_add("OBJ.MANZANA", 10);
bag_storage_add("ARM.ESPADA_COBRE" , 10);
bag_storage_add("ARM.ESPADA_VENENO", 10);
bag_storage_add("OBJ.MANZANA", 10);
bag_storage_add("OBJ.MANZANA", -5);
bag_storage_add("ARM.ESPADA_VENENO" , -10);

var _psj1 = group_create_player1(irandom(100) ); /// @is {group_create}
_psj1.EquipPut ("Mano der.", "ARM.ESPADA_COBRE" );
_psj1.EquipPut ("Mano izq.", "ARM.ESPADA_VENENO");
_psj1.EquipTake("Mano der.");
var _psj2 = group_create_player2(irandom(100) ); /// @is {group_create}

To1 = _psj1.stats_final; /// @is {group_create}
To2 = _psj2.stats_final;

Stat1 = To1.ToStringStruct();
Stat2 = To2.ToStringStruct();

Names = mall_global_stats();
