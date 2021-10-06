randomize();

mall_init();

dark_init();
bag_init ();

START_TIMER

var dun = (new wate_data() );

var enem1 = wate_pack_flaite1(10, 15);
var enem2 = wate_pack_flaite2(15, 20);

dun.PackAdd(enem1);
dun.PackAdd(enem2);

END_TIMER

wate_set_data(dun);