var xx1 = 64, xx2 = 64 * 6, yy = 64;
var value1 = 0, value2 = 0;
var txt1   = "", txt2   = "";

draw_set_color(c_red);
draw_text(xx1, 8, Lvl1);
draw_text(xx2, 8, Lvl2);

#region Stats
var i = 0; repeat(array_length(NamesStats) ) {
    var name  = NamesStats[i];
    
    if (variable_struct_exists(Stat1, name) ) {
        value1 = Stat1[$ name][1];
        value2 = Stat2[$ name][1];
        
        txt1 = Stat1[$ name][0];
        txt2 = Stat2[$ name][0];
        
        draw_set_color(c_white);
        draw_text(xx1, yy, txt1 + ": " + value1);
        draw_text(xx2, yy, txt2 + ": " + value2);
        
        yy += 16;
    }
    ++i;
}

#endregion

#region States
yy += 16;
var i = 0; repeat(array_length(NamesState) ) {
    var name  = NamesState[i];
    
    if (variable_struct_exists(State1, name) ) {
        value1 = State1[$ name][1];
        value2 = State2[$ name][1];
        
        txt1 = State1[$ name][0];
        txt2 = State2[$ name][0];        
        
        draw_set_color(c_white);
        draw_text(xx1, yy, txt1 + ": " + value1);
        draw_text(xx2, yy, txt2 + ": " + value2);
        
        yy += 16;
    }
    ++i;
}

#endregion
