function pocket_database()
{
	pocket_add("BRONZE.SWORD", new PocketItem("SWORD", 100, 80, "FUE", 20, NUMTYPES.REAL) );
	pocket_add("DEVIL.SWORD" , new PocketItem("SWORD", 100, 80, "FUE", 20, NUMTYPES.REAL).setEvents("inAttack", function(caster, target, extra) {
		
		
		
	}) );
}