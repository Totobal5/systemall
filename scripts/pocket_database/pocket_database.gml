function pocket_database()
{
	pocket_add("ESPADA.COBRE"	 , new PocketItem("ARMA",       150,  80).setStat("PODER"  , 20, MALL_NUMTYPE.REAL) );
	pocket_add("ARMADURA.CUERO"	 , new PocketItem("ARMADURA",   220, 120).setStat("DEFENSA",  6, MALL_NUMTYPE.REAL) );
	pocket_add("PANTALONES.CUERO", new PocketItem("PANTALONES", 220, 120).setStat("DEFENSA",  4, MALL_NUMTYPE.REAL) );
	
	pocket_add("ESPADA.ACERO"	  , new PocketItem("ARMA",       300, 160).setStat("PODER"  , 30, MALL_NUMTYPE.REAL) );
	pocket_add("ARMADURA.MALLAS"  , new PocketItem("ARMADURA",   300, 120).setStat("DEFENSA",  8, MALL_NUMTYPE.REAL) );
	pocket_add("PANTALONES.MALLAS", new PocketItem("PANTALONES", 300, 120).setStat("DEFENSA",  6, MALL_NUMTYPE.REAL) );
}