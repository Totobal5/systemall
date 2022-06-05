function MallStateProp(_key) constructor {
    __name = _key;
    __count = (new Counter(0, 0) ).ToggleIterate(); /// @is {Counter}
    
    // -- Metodos
    __mStart  = MALL_DUMMY_METHOD;
    __mUpdate = MALL_DUMMY_METHOD;
    __mEnd = MALL_DUMMY_METHOD;
    
    __logKeys = [noone, noone, noone];
    __logStart  = "";
    __logUpdate = "";
    __logEnd = "";
}