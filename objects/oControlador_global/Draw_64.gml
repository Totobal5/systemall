var xx1 = 64, xx2 = 64 * 6, yy = 64;

var i = 0; repeat(array_length(Names) ) {
    var name  = Names[i];
    
    if (variable_struct_exists(Stat1, name) ) {
        value1 = Stat1[$ name];
        value2 = Stat2[$ name];
        
        draw_set_color(c_white);
        draw_text(xx1, yy, name + ": " + value1);
        draw_text(xx2, yy, name + ": " + value2);
        
        yy += 16;
    }
    ++i;
}
