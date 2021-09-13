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

var _psj = group_create_player1(irandom(100) ); /// @is {group_create}
_psj.EquipPut ("Mano der.", "ARM.ESPADA_COBRE" );
_psj.EquipPut ("Mano izq.", "ARM.ESPADA_VENENO");
_psj.EquipTake("Mano der.");