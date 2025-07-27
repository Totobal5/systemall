/// @desc Representa la instancia de una estadística para una entidad.
function EntityStatInstance(_template) constructor
{
    template = _template; // Referencia a la plantilla MallStat
    
    // Valores de estado
    level = template.base_level;
    base_value = template.base_value;
    
    // Valores calculados
    peak_value = 0;      // Valor máximo con bonificaciones de nivel
    equipment_value = 0; // Valor con equipo
    control_value = 0;   // Valor final con estados alterados
    current_value = 0;   // Valor actual (ej: vida actual)
    
    /// @desc Recalcula los valores de la estadística basado en el nivel de la entidad.
    static Recalculate = function(_entity)
    {
        var _level_up_event = Systemall.__functions[$ template.event_on_level_up];
        if (is_callable(_level_up_event))
        {
            // La función del evento devuelve el nuevo valor base para el nivel actual
            peak_value = _level_up_event(_entity, self);
        }
        else
        {
            peak_value = base_value; // Si no hay evento, usa el valor base
        }
        
        // Aplicar bonificaciones de equipo y estados (se calculará en PartyEntity.Update)
        // Por ahora, inicializamos los valores.
        equipment_value = peak_value;
        control_value = equipment_value;
        
        // Clamp para asegurar que no exceda los límites
        control_value = clamp(control_value, template.min_value, template.max_value);
        
        // Restaurar vida/maná si es necesario
        if (template.restore_on_equip)
        {
            current_value = control_value;
        }
        else
        {
            current_value = min(current_value, control_value);
        }
    }
}

/// @desc Representa la instancia de un slot de equipo para una entidad.
function EntitySlotInstance(_template) constructor
{
    template = _template; // Referencia a la plantilla MallSlot
    
    equipped_item = undefined;
    is_active = !template.is_disabled;
}


// Feather ignore all
/// @param	{String} entity_key
function PartyEntity(_key) : Mall(_key) constructor
{
    // Llave del grupo al que pertenece.
    group = "";
    // Estructuras
    level = __MALL_PARTY_LEVEL_MIN;
    // Estadisticas
    stats = {};
    array_foreach(mall_get_stat_keys(), __Init);
    
    // Control y estados
    controls = {};
    controlsKeys = [];
    
    // Slots y equipo
    slots = {};
    slotsKeys = [];
    
    // Manager de combate actual.
    wate = undefined;
    // Para batallas.
    battleGroup = "";
    battleState = "";
    battleAnimation = undefined;
    // Turno actual
    turn = 0;
    // Eventos para los turnos.
    turnEvent = [];
    
    // Como se comporta.
    conduct = "";
    // Drops a soltar.
    drops = [];
    // Que comandos puede realizar
    categories = {
        // Todas las categorias.
        defaults: {keys:[] }
    };
    categoriesKeys = [];
    // Para cuando es forzado.
    categoryForced = "";
    commandForced =  "";
    
    #region -- STATS
    /// @param	{Struct.MallStat} MallStat
	/// @ignore
    static AtomStat = function(stat) constructor
    {
        /// @ignore
        is = "AtomStat";
        /// @ignore
        key = stat.key;
		/// @ignore
        dKey = stat.dKey;
		/// @ignore
        canSave = stat.canSave;
        
        // -- Configuracion
        // Que pasar en la formula para subir de nivel
        vars = {};
        // Si sube de nivel individualmente
        single = stat.levelSingle;
        // Guardar metodo.
        eUpdate = method(self, stat.eUpdate);
        
        // Para los turnos
        eTurnStart = method(self, stat.eTurnStart);
        eTurnEnd = method(self, stat.eTurnEnd);
        // Al equipar un objeto (inicio) ejecuta esta función.
        eEquip = method(self, stat.eEquip);
        // Al desequipar un objeto ejecuta esta función.
        eDesequip = method(self, stat.eDesequip);
        
        // Niveles
        eLevelUp = method(self, stat.eLevelUp);
        eLevelCheck = method(self, stat.eLevelCheck);
        
        // Copiar iterador
        // Copiar la configuracion del otro iterador
        // Crear un iterador si no existe
        iterator = (stat.iterator != undefined) ? 
            stat.iterator.copy() : 
            new MallIterator();
        
        // -- Se ponen los valores inciales
        // Nivel de la estadistica si se usa individualmente
        level = stat.startLevel;
        base = stat.start;
        type = stat.type;
        // Valor maximo en que la estadistica puede estar
        limitMin = stat.limitMin;
        // Valor minimo en que la estadistica puede estar
        limitMax = stat.limitMax;

        // Valor de la estadistica actual maximo respecto al nivel
        peak = control;
        // El valor final tomando en cuenta el equipamiento
        equipment = control;        
        // El valor final tomando en cuenta el control
        control = base;
        // El valor actual de la estadistica
        current = control;
        
        // El ultimo valor maximo
        laspeak = control;
        // El anterior valor actual
        lascurrent = control;
        
        /// @desc Devuelve un struct con los valores actuales
        static Send = function()
        {
            var _this = self;
            return ({
                key: _this.key,
                // El valor con los controles/estados.
				control: _this.control,
				// El valor con los equipos.
                equipment: _this.equipment,
				// El valor maximo.
				peak: _this.peak,
				// El valor actual.
                current: _this.current,
                // -- Valores previos.
                laspeak: _this.laspeak,
                lascurrent: _this.lascurrent
            });
        }
        
        /// @desc Como guarda este componente.
		/// @param	{Bool}	[struct] devolver un struct o un JSON.
        static Export = function(_struct=false) 
        {
            var _this = self;
            with ({})
            {
                version = __MALL_MY_VERSION;
                is = _this.is;
                level = _this.level;
                iterator = _this.iterator.export();
                actual = _this.canSave ? _this.current : 0;
                return (_struct) ? self : json_stringify(self, true); 
            }
        }
        
        /// @desc Como carga este componente.
        /// @param	{Struct} load_struct
        static Import = function(_l) 
        {
            if (_l.is != is) exit;
            switch (_l.version) 
            {
                default:
                    level = _l.level;
                    iterator.Import(_l.iterator);
                    // Cargar valor actual.
                    if (canSave) {current = _l.current ?? peak; }
                break;
            }
            
            return self;
        }
    }
    
    /// @desc Obtiene un AtomStat a partir de la llave
    /// @param {String} stat_key
    /// @returns {Struct.PartyEntity$$AtomStat}
    static StatGet = function(_key)
    {
		// Por Hash.
        if (is_numeric(_key) ) {return (struct_get_from_hash(stats, _key) ); }
        return (struct_get(stats, _key) );
    }
    
    /// @desc Establece el valor actual de una estadistica teniendo como limites "limMin" y "control"
    /// @param	{String}			stat_key    Si es "all" permite cambiar el valor de todos los atomos
    /// @param	{Real}				value       Valor para establecer
    /// @param	{ENUM.MALL_NUMTYPE}	numtype     Tipo de numero
    /// @return	{Real}
    static StatSet = function(_key, _value, _numtype=MALL_NUMTYPE.REAL)
    {
        static SKeys = mall_get_stat_keys();
        
        #region Cambiar a todas las estadisticas a este valor
        if (_key == all)  
        {
            var i=0; repeat(array_length(SKeys) ) {StatSet(SKeys[i++], _value, _numtype); }
        } 
        #endregion
        
        #region Cambiar solo 1
        else
		{
            var _stat = StatGet(_key);
            if (is_undefined(_stat) ) return 0;
            with (_stat) 
            {
				var _t = (_numtype == MALL_NUMTYPE.PERCENT) ? (control * _value) / 100 : _value;
				lascurrent = current;
				current = clamp(_t, limitMin, control);
				
                return (current);
            }
        }
        #endregion
    }
    
    /// @desc Suma/Resta "current" de una estadistica teniendo como limite "limitMax" y "limitMin". Obtiene cuanto se modifico el valor.
    /// @param	{String}			stat_key	Llave de estadistica
    /// @param	{Real}				value		Valor para sumar/restar
    /// @param	{ENUM.MALL_NUMTYPE} numtype		Tipo de numero
    /// @param	{ENUM.STAT_NUMTARG} [numtarg]	Que "value" usar 0: current, 1:lascurrent, 2: peak, 3: laspeak, 4: equipment, 5: control, Solo porcentajes!
    /// @return	{Real} Devuelve el valor que se añadio
    static StatAdd = function(_key, _value, _numtype=MALL_NUMTYPE.REAL, _numtarg=STAT_NUMTARG.CURRENT) 
    {
        var _stat = StatGet(_key);
        if (is_undefined(_stat) ) return 0;
		// Valor default.
        var _toadd = _value;
		
		// Obtener porcentaje.
		if (_numtype == MALL_NUMTYPE.PERCENT)
		{
			var _topercent;
            switch (_numtarg) 
            {
                case STAT_NUMTARG.CURRENT:		_topercent = _stat.current;		break;
                case STAT_NUMTARG.LASCURRENT:	_topercent = _stat.lascurrent;	break;
                    
                case STAT_NUMTARG.PEAK:			_topercent = _stat.peak;		break;
                case STAT_NUMTARG.LASPEAK:		_topercent = _stat.laspeak;		break;
                    
                case STAT_NUMTARG.EQUIPMENT:	_topercent = _stat.equipment;	break;
                case STAT_NUMTARG.CONTROL:		_topercent = _stat.control;		break;
            }
			// Utilizar el porcentaje.
			_toadd = (_topercent * _value) / 100;
		}
		
		// Establecer nuevo valor.
		StatSet(_key, round(_stat.current + _toadd) );
		
        // Obtener cuanto se modifico el valor.
        return (_stat.control - _stat.current);
    }
    
    /// @param	{String}			stat_key    Llave de estadistica
    /// @param	{Real}				base_value  Valor de base
    /// @param	{ENUM.MALL_NUMTYPE}	base_type   Tipo de numero
    /// @return {Struct.PartyEntity}
    static StatBaseSet = function(_statKey, _baseValue, _baseType) 
    {
        var i=0; repeat(argument_count div 3) 
        {
            var _key = argument[i];
            var _val = argument[i + 1];
            var _typ = argument[i + 2];
            
            var _atom = statGet(_key);
            // Actualizar valores bases
            _atom.base = _val;
            _atom.type = _typ;
            
            #region DEBUG
            if (__MALL_PARTY_TRACE) {
            show_debug_message($"MallRPG Party: {_key} base set to {_val}{StringNumtype(_typ)}");
            }
            #endregion
            
            i = i + 3;
        }
        
        return self;
    }
    
    /// @desc Evento a ejecutar cuando si inicia el proceso de subir de nivel.
    static eLevelStart = function() {};
    
    /// @desc Evento a ejecutar cuando si termina el proceso de subir de nivel.
    static eLevelEnd = function() {};
    
    /// @desc Funcion para comprobar si puede subir de nivel.
    static eLevelCheck = function() {};
    
    /// @param {Real}   new_level   Nuevo nivel
    /// @param {String} [stat_key]  Solo si es individual
    /// @return {Struct.PartyStat}
    static LevelSet = function(_level, _key) 
    {
        #region Global
        if (_key == undefined) 
        {
            level = _level
        }
        #endregion
        
        #region Individual
        else if (is_string(_key) )
        {
            var _stat = StatGet(_key);
            _stat.level = _level;
        }
        #endregion
        
        // Forzar subida de nivel
        StatLevelUp(false, 0, true);
        
        return self;
    }
    
    /// @param {Bool} [set_or_add]=false    Sumar o establecer el nivel. false: Add
    /// @param {Real} [level]=0             Nivel
    /// @param {Bool} [force]=false         Forzar el subir de nivel
    static StatLevelUp  = function(_set=false, _setLevel=0, _force=false) 
    {
        var _statKeys = mall_get_stat_keys();
        var _size = array_length(_statKeys);
		
        // Para feather
        var _return = {
            statKey: {
                key: "",
                
                current:    0,
                peak:       0,
                control:    0,
                equipment:  0,
                // Ultimas.
                lascurrent: 0,
                lascurrent: 0
            },
        };
        // Eliminar
        struct_remove(_return, "statKey");
        
        // Revisar check global
        var _globalCheck = eLevelCheck() + _force;
        if (!_globalCheck) exit;
        
        // Operar y Limitar niveles
        level = clamp(
            (!_set) ? level + _setLevel : _setLevel, 
            __MALL_PARTY_LEVEL_MIN, 
            __MALL_PARTY_LEVEL_MAX
        );
        
        // Funcion al iniciar el subir de nivel
        eTurnStart();
        
        #region Ciclar por cada stat
        var i=0; repeat(_size)
		{
            // Feather ignore all
            var _key = _statKeys[i];
            var _stat = StatGet(_key);
            // Solo si es independiente, nivel a usar
            var _check = undefined, _level = 1;
            // Si tiene un check individual.
            if (_stat.single)
            {
                _stat.level = (!_set) ? _stat.level + _setLevel : _setLevel;
                _level = _stat.level;
                _check = _stat.eLevelCheck(self);
            }
            // Remplazar por nivel global
            else
            {
                _level = level;
                _check =  true;
            }
            // Comprobar check
            var _enterGlobal = (_globalCheck && _check != undefined);
            
            #region Subir de nivel
            if (_force || (_check || _enterGlobal) ) 
            {
				// Obtener cambios del control respecto a los cambios en el equipo.
                var _restControl = (_stat.control - _stat.equipment);
				// Obtener cambios del equipamiento respecto al valor maximo de la estadistica.
                var _restSlot = (_stat.equipment - _stat.peak);
                /// Ejecutar evento para subir de nivel.
                var _sum = _stat.eLevelUp(self);
				
                // Actualizar valores
                _stat.peak = clamp(_sum, _stat.limitMin, _stat.limitMax);
				// Obtener valor del equipamiento.
                _stat.equipment = _stat.peak + _restSlot;
				// Obtener valor del control.
                _stat.control = _stat.peak + _restSlot + _restControl;
				
                // El primero deja peak, equipment y control igual.
                var _iter = _stat.iterator;
                var _work = _iter.Iterate();
				
                // Al reiniciar el iterador llevar actual al minimo o maximo dependiendo del tipo
				if (_work == MALL_ITERATOR.REINITIATED) 
				{
					_stat.current = (_iter.type) ? _stat.control : _stat.limitMin;
				}
				
				// Primera llamada.
                if (!_iter.firstCall) 
                {
                    // Actualizar valor final
                    _stat.laspeak = _stat.level(self, max(1, _level - 1) );
                    // Al reiniciar el iterador llevar actual al minimo o maximo dependiendo del tipo.
                    if (_iter.active) 
                    {
                        _stat.current = (_iter.type) ? _stat.control : _stat.limitMin;
                    }
                    // Establecer al valor maximo.
                    else 
                    {
                        _stat.current = _stat.control;
                        _stat.lascurrent = _stat.control; 
                    }
					
                    // Indicar que ya no será la primera ejecución.
                    _iter.firstCall = true;
                }
				
                // Mostrar los valores en el debugger
                if (__MALL_PARTY_TRACE) {show_debug_message($"M_Party: {_key} set to {_stat.control}"); }
				
				// Poner valores para regresar
                _return[$ _key] = _stat.Send();
            }
            
            #endregion
            
            i++;
        }
        #endregion
		
        // Ejecutar funcion al terminar de subir de nivel
        eLevelEnd();
        
        return (_return );
    }
    
    /// @desc Sube solo un stat.
    /// @param	{String}	stat_key
    /// @param	{Real}		[new_level]
    static StatLevelUpSingle = function(_key, _level)
    {
        var _stat = StatGet(_key);
        var _restControl = (_stat.control - _stat.equipment);
        var _restSlot = (_stat.equipment - _stat.peak);
        
		// Establecer nuevo nivel.
        _stat.level = _level;
        var _sum = _stat.eLevelUp(self);
		
        // Actualizar valores.
        _stat.peak = clamp(_sum, _stat.limitMin, _stat.limitMax);
        _stat.equipment = _stat.peak + _restSlot;
        _stat.control = _stat.peak + _restSlot + _restControl;
		
        // el primero deja peak, equipment y control igual.
        var _iter = _stat.iterator;
        var _work = _iter.Iterate();
		
        // Al reiniciar el iterador llevar actual al minimo o maximo dependiendo del tipo.
        if (_work == MALL_ITERATOR.REINITIATED) 
		{
			_stat.current = (_iter.type) ? _stat.control : _stat.limitMin;
		}
		
		return (_stat.Send() );
    }
    
    #endregion
    
    #region -- SLOTS
    /// @param {String}     slot_key            
    /// @param {String}     [display_key]       
    /// @param {Function}   [check_function]    function(entity, item) {return Bool; }
    /// @param {Bool}       [is_active]
	/// @ignore
    static AtomSlot = function(_key, _display, _active=true) constructor
    {
        is  = "AtomSlot";
        
        // Llaves.
        key = _key;
        dKey = _display;
        // Objetos permitidos
        permited = {};
        // Si se puede usar este slot
        active = _active;
        // Donde se almacenan los objetos que lleva.
        equipped = undefined;
        // Objeto anterior que se llevo.
        previous = undefined;
        // Indicar si se esta desequipando algo
        desequip = false;
        
        eItemCheck = function(entity, item) {return true; }
        
        /// @desc Guarda este componente.
		/// @param	{Bool}	[struct] devolver un struct o un JSON.
        static Export = function(_struct=false) 
        {
            var _this = self;
            with ({})
            {
                version = __MALL_MY_VERSION;
                // Guardar que es.
                is = _this.is;
				// Guardar llaves.
                key = _this.key;
                dKey = _this.dKey;
                // Propiedades.
                permited = variable_clone(_this.permited);
                equipped = (_this.equipped == undefined) ? undefined : _this.equipped.key;
                previous = (_this.previous == undefined) ? undefined : _this.previous.key;
                active = _this.active;
                
                return (!_struct) ? json_stringify(self, true) : self;
            }
        }
        
        /// @param {Struct} load_struct
        static Import = function(_l)
        {
            switch (_l.version) 
            {
				default:
		            // Llaves.
		            key = _l.key;
		            dKey = _l.dKey;
		            // Importar permitidos.
		            permited = _l.permited;
		            // Items.
		            equipped = (is_ptr(_l.equipped) ) ? undefined : pocket_item_get(_l.equipped);
		            previous = (is_ptr(_l.previous) ) ? undefined : pocket_item_get(_l.previous);
		            active = _l.active;
				break;
			}
			
            return self;
        }
    }
    
    /// @param	{String}	slot_key            
    /// @param	{String}	[display_key]       
    /// @param	{Function}	[check_function]	function(entity, item) {return Bool; }
    /// @param	{Bool}		[is_active]
    static SlotCreate = function(_key, _display, _check, _active=false)
    {
        // Crear AtomSlot.
        slots[$ _key] = new AtomSlot(_key, _display ?? _key, _check, _active);
		
		// Guardar llaves.
        array_push(slotsKeys, _key);
        
        return self;
    }
    
    /// @param	{String} slot_key	Llave del slot.
    /// @return {Struct.PartyEntity$$AtomSlot}
    static SlotGet = function(_key)
    {
        #region DEBUG
        if (__MALL_PARTY_SAFETY) {
        if (!struct_exists(slots, _key) ) {
        throw $"M_PartyEntity :: {_key} no existe";
        }
        }
        #endregion
		// Por Hash.
        if (is_numeric(_key) ) return (struct_get_from_hash(slots, _key) );
        return (struct_get(slots, _key) );
    }
    
	/// @desc Añade objetos/tipos permitidos para equipar en el Slot.
    /// @param	{String}			slot_key	Llave del slot
    /// @param	{Function, Array}	item_key	Puede ser un itemtype para aceptar todos los objetos que son de ese tipo. o un itemKey para objetos individuales
    static SlotPermitedAdd = function(_slotKey, _item)
    {
        static Types = Systemall.types;
        // Es una array de objetos.
        if (is_array(_item) ) 
        {
            var i=0; repeat(array_length(_item) ) 
            {
                var _key = _item[i];
                SlotPermitedAdd(_slotKey, _key);
                i++;
            }
        }
        else 
        {
			// Obtener el Slot.
            var _slot = SlotGet(_slotKey);
            var _permited = _slot.permited;
            // La llave es un tipo de objetos
            if (struct_exists(Types, _item) ) 
            {
                // Obtener la string de todos los objetos
                var _types = Types[$ _item];
                var _typesKeys = struct_get_names(_types);
                var i=0; repeat(array_length(_typesKeys) )
                {
                    // Añadir objeto
                    var _key = _typesKeys[i];
                    _permited[$ _key] = 0;
                    i++;
                }
            }
            // Solo se pasa un objeto.
            else 
            {
                _permited[$ _item.key] = 0;
            }
        }
        return self;
    }
    
	/// @desc Eliminar objetos/tipos permitidos.
    /// @param	{String} slot_key
    /// @param	{String} key
    static SlotPermitedRemove = function(_slotKey, _item)
    {
        static Types = Systemall.types;
        // 
        var _slot = SlotGet(_slotKey);
        var _permited = _slot.permited;
        // Se paso un tipo
        if (struct_exists(Types, _item) ) 
        {
            var _types = Types[$ _item];
            var _tkeys = struct_get_names(_types);
            var i=0; repeat(array_length(_tkeys) ) 
            {
                var _tkey = _tkeys[i];
                struct_remove(_permited, _tkey);
                i++;
            }
        }
        // Una llave de objeto.
        else 
        {
            struct_remove(_permited, _item.key);
        }
        return self;
    }
    
    /// @desc Equipa un objeto en el slot indicado. Si se logra equipar devuelve un Struct.
    /// @param	{String}			slot_key	En que slot equipar el objeto.
    /// @param	{Struct.PocketItem}	PocketItem	Objeto.
    static SlotEquip = function(_slotKey, _item)
    {
        var _slot = SlotGet(_slotKey);
        var _return = {result: false, previous: undefined};
        // Se puede equipar este objeto
        if (struct_exists(_slot.permited, _item.key) ) 
        {
            // Realizar una comprobacion de parte del slot
            if (_slot.eItemCheck(self, _item) ) return _return;
            // Obtener previo
            var _prev = _slot.previous
            _slot.previous = _slot.equipped;
            _slot.equipped = _item;
            
            // Actualizar entidad.
            UpdateComponents();
            
            // Ejecutar funcion de desequipar si habia un objeto anteriormente
            if (!is_undefined(_prev) ) _prev.eDesequip(self);
            
            // Ejecutar funcion de equipar
            _item.eEquip(self);
            
            _return.result = true;
            _return.previous = _prev;
        }
        
        return (_return);
    }
    
	/// @desc Desequipa un objeto en el slot indicado. Si se logra desequipar devuelve un Struct.
    /// @param	{String} slot_key
    static SlotDesequip = function(_key)
    {
        static NoItem = new PocketItem("");
        var _slot = SlotGet(_key);
        var _return = {result: false, previous: undefined};
        var _item = _slot.equipped ?? NoItem;
        
        // Comprobar si puede ser desequipado
        if (!_item.eCanDesequip(self) ) return (_return);
        
        // Intercambiar equipo
        _slot.previous = _slot.equipped;
        _slot.equipped = undefined;
        
        // Actualizar entidad
        UpdateComponents();
        
        // Funcion de desequipar
        _item.eDesequip(self);
        
        _return.result = true;
        _return.previous = _slot.previous;
        
        return (_return);
    }
    
    /// @param	{String} slot_key
    /// @return {Struct.PocketItem}
    static SlotGetEquipped = function(_key)
    {
        var _atom = SlotGet(_key);
        return (_atom.equipped);
    }
    
	/// @desc Si el objeto es permitido.
    /// @param	{String}	slot_key
    /// @param	{String}	pocket_key
    static SlotIsPermited = function(_key, _ikey)
    {
        var _atom = SlotGet(_key);
        return (struct_exists(_atom.permited, _ikey) );
    }
    
	/// @desc Regresa True si el slot no tiene nada equipado.
    /// @param {String} slot_key
    /// @return {Bool}
    static SlotIsEmpty = function(_key)
    {
        var _atom = SlotGet(_key);
        return (_atom.equipped == undefined);
    }

	/// @desc Ejecuta una funcion en cada slot.
	/// @param	{Function}	slot_function	function(AtomSlot, PocketItem, index, variables) {}
	/// @param	{Struct}	vars_struct		Variables
	static SlotForeach = function(_fn, _csr)
	{
		var _tmp =_csr ?? {};
		var i=0; repeat(array_length(slotsKeys) )
		{
			var _skey = slotsKeys[i++];
			var _slot = slots[$ _skey];
			var _item = _slot.equipped;
			// Pasar el AtomSlot, PocketItem, Index, Vars
			_fn(_slot, _item, i, _tmp);
		}
		
		return (_tmp);
	}
	
    #endregion
    
    #region -- STATES Y CONTROL
    /// @ignore
    /// @param {String} key
    /// @param {String} [display_key]
    static AtomState = function(_key, _display, _init=false) constructor
    {
        /// @ignore
        is = "AtomState";
        /// @ignore Trackear entidad.
        entity = weak_ref_create(other);
        // Configuracion
        // Llave de este estado
        key = _key;
        // LLave display de este estado.
        dKey = _display;
        
        // Estado a que reinicia.
        stateinit = _init;
        // Estado actual.
        state = _init;
        // Numero que utiliza este estado.
        type = MALL_NUMTYPE.REAL;
        // Si acepta el mismo control varias veces.
        same = false;
        // infinity se pueden agregar elementos infinitos.
        controls = infinity;
        
        // Valores que varian [real, porcentual] son actualizados.
        values = array_create(2, 0);
        // Para las estadisticas.
        stats = {};
        statsKeys = [];
        
        // Contenidos que posee este atomo.
        contents = array_create(0);
        // Flags que posee este atomo.
        flags = array_create(0);
        
        /// @return {Array<Struct.DarkEffect>}
        static GetContent = function()
        {
            // Feather ignore all
            return contents;
        }
        
        /// @desc Como guarda este componente
		/// @param	{Bool} [struct] devolver un struct o un JSON.
        static Export = function(_struct=false)
        {
			/// @param	{Struct.DarkEffect}	DarkEffect
			static ExportEffects = function(_effect) 
			{
				array_push(contents, _effect.Export() );
			}
			
            var _this = self;
            with ({contents: [] }) 
            {
                version = __MALL_MY_VERSION;
                is = _this.is;
                // Llaves
                key = _this.key;
                dKey = _this.displayKey;
				// Estados.
                stateinit = _this.stateinit;
                state = _this.state;
                // Valores.
                values = _this.values;
                // Numero que utiliza este estado.
                type = _this.type;
                // Si acepta el mismo control varias veces.
                same = _this.same;
                // infinity se pueden agregar elementos infinitos.
                controls = _this.controls
                flags = _this.flags;
                
                // Stats
                stats = _this.stats;
                statsKeys = _this.statsKeys;
                
                // Guardar contenido.
                array_foreach(_this.contents, ExportEffects);
                
                return (!_struct) ? json_stringify(self, true) : self;
            }
        }
        
        /// @desc Como carga este componente.
        /// @param	{Struct} load_struct
        static Import = function(_l)
        {
			/// @param	{Struct.DarkEffect}	DarkEffect
			static ImportEffects = function(_effect) 
            {
                // Obtener llave del efecto para poder buscarlo en la base de datos y crearlo.
                var _key = _effect.key;
                if (dark_exists(_key) ) 
                {
                    // Obtener constructor y crear efecto.
                    var _constructor = dark_get(_key);
                    var _neweffect = new _constructor();
                    // Importar valores
                    _neweffect.Import(_effect);
					
                    // Agregar a la entidad.
                    entity.ref.ControlEffectAdd(_neweffect)
                }
            }
			
            // Version.
            if (_l.is != is) return false;
			// Llaves.
            key = _l.key;
            dKey = _l.displayKey;
            // Por versión.
            switch (_l.version)
            {
                default:
                    // Estados.
                    stateinit = _l.stateinit;
                    state = _l.state;
                    // Valores.
                    values = _l.values;
                    type = _l.type;
                    // Configuracion.
                    same = _l.same;
                    controls = _l.controls;
                    // Estadisticas.
                    stats = _l.stats;
                    statsKeys = _l.statsKeys;
                    // Cargar flags.
                    flags = variable_clone(_l.flags);
                    
                    // Asegurarse que la entidad continue viva.
                    if (!weak_ref_alive(entity) ) return false;
					
                    // Contenido.
                    array_foreach(_l.contents, ImportEffects);
                break;
            }
            
            return true;
		}
    }
    
    /// @desc Añade un estado nuevo.
    /// @param	{String}	control_key
    /// @param	{String}	[display_key]
    /// @param	{Bool}		[state_init]
    static ControlCreate = function(_key, _display, _init=false) 
    {
        var _atom = new AtomState(_key, _display ?? _key, _init);
        controls[$ _key] = _atom;
		
        // Añadir a la lista de controles.
        array_push(controlsKeys, _key);
        
        return (_atom);
    }
    
    /// @desc Obtiene un estado en el control
    /// @param	{String}	control_key
    /// @return {Struct.PartyEntity$$AtomState}
    static ControlGet = function(_key)
    {
        #region DEBUG
        if (__MALL_PARTY_SAFETY) {
        if (!struct_exists(controls, _key) ) {
        throw $"M_Party controlGet:: {_key} no existe";
        }
        }
        #endregion
		// Por Hash.
        if (is_numeric(_key) ) return (struct_get_from_hash(controls, _key) );
        return (struct_get(controls, _key) );
    }
    
    /// @desc Si existe un estado en el control.
    /// @param	{String}	control_key
    /// @return	{Bool}
    static ControlExists = function(_key)
    {
        return (struct_exists(controls, _key) );
    }
    
    /// @desc Elimina un estado del control.
    /// @param	{String}	control_key
    static ControlRemove = function(_key)
    {
        #region DEBUG
        if (__MALL_PARTY_SAFETY) {
        if (!struct_exists(controls, _key) ) {
        throw $"M_Party controlRemove:: {_key} no existe";
        }
        }
        #endregion
        struct_remove(controls, _key);
        return self;
    }
    
    /// @desc Establece un nuevo valor en "values" con el tipo de numero default o diferente.
    /// @param	{String}			control_key
    /// @param	{Array<Real>,Real}	value
    /// @param	{Enum.MALL_NUMTYPE}	type
    static ControlValuesSet = function(_key, _value, _type)
    {
        var _atom = ControlGet(_key);
        if (is_array(_value) ) 
        {
            _atom.values[0] = _value[0];
            _atom.values[1] = _value[1];
        }
		else 
        {
            _atom.values[_type] = _value;
        }
        
        return self;
    }
    
    /// @desc Añade un valor al control (suma/resta)
    /// @param	{String}			control_key
    /// @param	{Array<Real>,Real}	value
    /// @param	{Enum.MALL_NUMTYPE}	type
    static ControlValuesAdd = function(_key, _value, _type)
    {
        var _atom = ControlGet(_key);
        if (is_array(_value) ) 
        {
            _atom.values[0] += _value[0];
            _atom.values[1] += _value[1];
        } 
		else 
        {
            _atom.values[_type] += _value;
        }
        
        return self;
    }
    
    /// @desc Establebe el control a su valor inicial.
    /// @param	{String}	control_key	"all" para reiniciar todos
    static ControlValuesReset = function(_key)
    {
        #region Reiniciar todos.
        if (_key == all) 
        {
            var i=0; repeat(array_length(controlsKeys) ) {ControlValuesReset(controlsKeys[i++] ); }
        }
        #endregion
        
        #region Solo 1
        else
        {
            var _atom = ControlGet(_key);
            _atom.values = array_create(2, 0);
        }
        #endregion
        
        return self;
    }
    
    /// @desc Indica el estado en que se encuentra un estado/estadistica.
    /// @param	{String}	control_key
    /// @return {Bool}
    static ControlStateGet = function(_key) 
    {
        var _atom = ControlGet(_key);
        if (_atom == undefined) return undefined;
        return (_atom.state);
    }
    
    /// @desc Establece el estado de este control
    /// @param	{String}	control_key
    /// @return {Bool}
    static ControlStateSet = function(_key, _state)
    {
        var _atom = ControlGet(_key);
        return (_atom.state = _state);
    }
    
    /// @desc Establece el estado de un control a su valor original. Se puede usar "all" para reiniciar todos.
    /// @param	{String}	control_key 
    static ControlStateReset = function(_key)
    {
        if (_key == all)
        {
            var i=0; repeat(controlsKeys) {ControlStateReset(controlsKeys[i]); }
        }
        else
        {
            var _atom = ControlGet(_key);
            _atom.state = _atom.stateinit;
            
			return self;
        }
    }
    
    /// @desc Indica si hay efectos en este estado.
    /// @param	{String} control_key
    /// @return {Bool}
    static ControlHasContent = function(_key)
    {
        var _atom = ControlGet(_key);
		
        return (array_length(_atom.content) > 0);
    }
    
    /// @desc Agrega un efecto al control que afecta (stat/state/action). Si lo agrega "true" si no "false".
    /// @param	{Struct.DarkEffect} DarkEffect
    /// @return {Bool}
    static ControlEffectAdd = function(_effect)
    {
		/// @param	{Struct.DarkEffect}	DarkEffect
        static EffectSame = function(_effect)
        {
            return (_effect.id == search);
        }
        
        #region Comprobar state
        var _stateKey = _effect.stateKey;
        // Si no existe el control crear
        if (!ControlExists(_stateKey) )
		{
            #region TRACE
            if (__MALL_PARTY_TRACE) {
            show_debug_message($"PartyEntity controlEffectAdd:: {_stateKey} no existe y se va a crear"); 
            }
            #endregion
            ControlCreate(_stateKey);
        }
        
        #endregion
		
        // Obtener control.
        var _control = ControlGet(_stateKey);
        var _content = _control.GetContent();
        var _size = array_length(_content);
        
        #region Comprobar limite.
        // Si no es infinito
        if (_control.controls != infinity)
        {
            // Si supero el limite salir ya que no se pueden agregar más elementos.
            if (_size > _control.controls) return false;
        }
        
        #endregion
        
        #region Comprobar si permite el mismo.
        if (!_control.same) 
        {
            if (array_any(_content, method({search: _effect.id}, EffectSame) ) ) 
            {
                return false;
            }
        }
		
		#endregion
        
        // Al pasar todo agregar al contenido.
        array_push(_content, _effect);
        
		// Ejecutar evento al agregar un efecto nuevo.
        _effect.Added(self);
        
        // Aplicar valor inicial dependiendo del tipo.
        ControlValuesAdd(_stateKey, _effect.value, _effect.type);
        
        // Actualizar valores de las estadisticas.
        UpdateComponents();
        
        return true;
    }
    
    /// @desc Elimina un efecto pasando un filtro. Devuelve "true" si borra; "false" si no borra o no hay elementos. 
	/// El filtro default borra el primer elemento.
    /// @param	{String}	control_key	
    /// @param	{Function}	filter		function(DarkEffect, i) {return Bool}
    static ControlEffectRemove = function(_key, _filter)
    {
        // El filtro default borra el primero de la lista
		/// @param	{Struct.DarkEffect} DarkEffect
        static DFilter = function(_effect, i) 
        {
            return (i==0);
        }
		
		// Obtener control.
        var _atom = ControlGet(_key);
        var _content = _atom.GetContent();
        
        #region Filtrar.
        var _index = array_find_index(_content, _filter ?? DFilter);
        // No existe el elemento.
        if (_index == -1) return undefined;
        
        #endregion
        
        // Obtener effecto que se va a eliminar.
        var _effect = _content[_index];
        // Eliminar del array de contenido.
        array_delete(_content, _index, 1);
        // Ejecutar funcion de eliminar.
        _effect.Remove(self);
        
        // Reducir valor.
        ControlValuesAdd(_key, -_effect.value, _effect.type);
        
        // Actualizar valores de las estadisticas.
        UpdateComponents();
        
        return (_effect);
    }
    
    /// @param	{String} control_key
    static ControlEffectRemoveAll = function(_key)
    {
        var _atom = ControlGet(_key);
        var _content = _atom.GetContent();
        // Ciclar por cada efecto.
        for (var i=0, n=array_length(_content); i<n; i++)
        {
            var _effect = _content[i];
            // Evento al remover este efecto.
            _effect.Remove(self);
            // Reducir valor.
            ControlValuesAdd(_key, -_effect.value, _effect.type);
            
			// Eliminar del array y actualizar contenido.
            array_delete(_content, 0, 1);
            n--;
        }
        // Actualizar valores de las estadisticas.
        UpdateComponents();
    }
    
    /// @desc Actualiza un control
    /// @param	{String}	control_key	"all" para actualizar a todos
    /// @param	{Real}		turn_type	0: Inicio del turno, 1: Final del turno, 2: Ambos
    static ControlEffectUpdate = function(_key, _type=0)
    {
        static Loop = false;
        
        var _return = {value: [0, 0], result: false};
        #region Actualizar solo un efecto.
        if (_key != all)
		{
            var _atom = ControlGet(_key);
            var _return = [0, 0];
            // Obtener contenido.
            var _content = _atom.GetContent();
            var _size = array_length(_content);
            
			// Actualizar contenidos.
            for (var i=0; i<_size; i++)
            {
                var _effect = _content[i];
                var _turnType = _effect.turnType;
                // Si no son el mismo tipo de turno saltar.
                if (_turnType != _type) continue;
                
                var _iterator = _effect.GetIterator(_type);
                // Iterar y guardar resultado.
                var _iterate = _iterator.iterate();
				// Obtener valor.
                var _value = _effect.value;
                var _numtype = _effect.type;
                
                // Aun esta funcionando.
                if (_iterate == MALL_ITERATOR.WORKING) 
                {
                    // Ejecutar funcion de actualizar de turno de inicio.
                    if (_type == 0) {_effect.eTurnStart(self); } else
                    if (_type == 1) {_effect.eTurnEnd(self);   }
					// Aumentar valores.
                    ControlValuesAdd(_key, _value, _numtype);
                    // Agregar al valor a regresar.
                    _return.value[_type] += _value;
                }
                // Termino este efecto.
                else if (_iterate == -1)
                {
                    // Ejecutar funcion de termino de efecto.
                    _effect.Ready(self);
                    _effect.isReady = true;
                    // Restar a los valores.
                    ControlValuesAdd(_key, -_value, _numtype);
                    // Agregar al valor a regresar.
                    _return.value[_type] -= _numtype;
                    // Eliminar del array.
                    array_delete(_content, i, 1);
                    
					// Restar al contenido.
                    _size--;
                }
            }
            
			// Actualizar componentes.
            if (!Loop) UpdateComponents("EffectUpdate");
            // Indicar que se completo esta funcion correctamente.
            _return.result = true;
            
            return (_return);
        }
        
        #endregion
        
        #region Actualizar todos
        else 
        {
            // No actualizar por cada elemento.
            Loop = true;
			// Ciclar por cada control.
            var i=0, _rn={}; repeat(array_length(controlsKeys) )
			{
                var _k = controlsKeys[i++];
                _rn[$ _k] = controlEffectUpdate(_k, _type);
            }
            // Actualizar componentes.
            updateComponents("EffectUpdate");
            // Evitar.
            Loop = false;
            
            return _rn;
        }
        
        #endregion
    }
    
    #endregion
    
    #region -- COMANDOS
    /// @desc Crea una nueva categoria para los comandos.
    /// @param	{String} category_key
    static CatCreate = function(_key)
    {
        // Agregar categoria de comandos si no existe.
        if (!struct_exists(categories, _key) )
        {
			// Añadir categoria.
            categories[$ _key] = { keys:[] };
            // Añadir a la lista.
            array_push(categoriesKeys, _key);
        }
        
        return self;
    }
    
    /// @desc Obtiene todas las categorias.
    /// @return {Array<string>}
    static CatAll = function()
    {
        return (categoriesKeys);
    }
    
    /// @desc Devuelve la primera categoria que posee el comando.
    /// @param	{String} command_key
    static CatSearch = function(_key)
    {
		/// @param	{String} key
		static CommandSearch = function(_name, _str)
        {
            if (struct_exists(_str, key) ) {result = _name; exit; }
        }
		
		// Crear un closure.
        var _closure = {key: _key, result: undefined};
		
		// Ciclar por cada categoria.
        struct_foreach(categories, method(_closure, CommandSearch) );
        
        return (_closure.result);
    }
    
    /// @desc Fuerza el siguiente comando a ejecutar.
    /// @param	{String} category_key    
    /// @param	{String} command_key     
    static CatForcedSet = function(_category, _command)
    {
        categoryForced = _category;
        commandForced =  _command;
        
        return self;
    }
    
    /// @desc Devuelve el comando forzado.
    static CatForcedGet = function()
    {
        if (categoryForced == "") return undefined;
        if (commandForced  == "") return undefined;
        return (CatCommandGet(categoryForced, commandForced) );
    }
    
    /// @desc Funcion para obtener un comando.
    eBattleCommandGet = function() {}
    
    /// @desc Establece una funcion para obtener comandos en una batalla de wate.
    /// @param {Function}	battle_function   
    static CatBattleSet = function(_fn) 
    {
        eBattleCommandGet = method(self, _fn);
        return self;
    }
    
    /// @param	{String}	category_key
    /// @param	{String}	dark_command_key
    static CatCommandAdd = function(_cat_key="default", _co_key)
    {
		#region SAFETY
        if (__MALL_PARTY_SAFETY) {
        if (_co_key == undefined)	{show_debug_message($"M_Party: Comando es undefined");} else
        if (!dark_exists(_co_key) )	{show_debug_message($"M_Party: {_co_key} no existe en la D.B de Dark"); }
        }
        #endregion
		
        // Si no existe la categoria crear.
        if (!struct_exists(categories, _cat_key) ) CatCreate(_cat_key);
        // Obtener categoria.
        var _category = categories[$ _co_key];
		// Si no existe el comando en la categoria agregar.
        if (!struct_exists(_category, _co_key) )
        {
            _category[$ _co_key] = dark_get(_co_key);
            array_push(_category.keys, _co_key);
        }
		// Si ya posee el comando.
        else
        {
            if (__MALL_DARK_TRACE) {
            show_debug_message($"M_Party: Esta entidad ya posee el comando {_co_key}");
            }
        }
		
        return self;
    }
    
    /// @param	{String}	category_key
    /// @param	{String}	dark_command_key
    static CatCommandGet = function(_cat_key, _co_key) 
    {
        return (commands[$ _cat_key][$ _co_key] );
    }
    
    /// @desc Devuelve todas las llaves de comando que posee una categoria.
    /// @param	{String}	category_key
    /// @return {Array<String>}
    static CatCommandAll = function(_cat_key)
    {
        var _command = commands[$ _cat_key];
        return (_command.keys);
    }
    
    /// @param	{String}	category_key
    static CatCommandRandom = function(_cat_key)
    {
        // Si no pasa una categoria busca una al azar.
		var _size = array_length(categoriesKeys) - 1;
        var _ckey = _cat_key ?? categoriesKeys[irandom(_size) ];
        // Obtener todos los comandos.
        var _commands = CatCommandAll(_ckey);
        var _random = irandom(array_length(_commands) - 1);
		
		// Obtener comando al azar.
        return (CatCommandGet(_ckey, _commands[_random] ) );
    }
    
    #endregion
    
    #region -- MISQ
    /// @desc Actualiza stats.
    static UpdateComponents = function(_from="")
    {
        var _slotStats = {};
        var _controlStats = {};
        var _statKeys = mall_get_stat_keys();
        var _statSize = array_length(_statKeys), _stat, _statKey;
		
        // Indices.
		var i=0, j=0, k=0;
        
		#region Obtener estadisticas de los objetos equipados.
        i=0; repeat(array_length(slotsKeys) ) 
        {
            var _slotkey = slotsKeys[i];
            var _slot = SlotGet(_slotkey);
            if (_slot.desequip) 
            {
                _slot.desequip = false; 
                i++;
				
                continue;
            }
			
			// Hay un objeto equipado.
            var _item = _slot.equipped;
            if (!is_undefined(_item) ) 
            {
                var _itemStatsKeys = _item.statsKeys;
                j=0; repeat(array_length(_itemStatsKeys) ) 
                {
                    var _itemStatKey = _itemStatsKeys[j];
                    if (struct_exists(_slotStats, _itemStatKey) )
                    {
                         // Obtener valores de la estadisticas.
                        var _itemStat = _item.stats[$ _itemStatKey];
                        // Obtener valores
                        var _itemValue = _itemStat[0];
                        var _itemType = _itemStat[1];
						
                        // Dependiendo del itemtype.
						switch (_itemType)
                        {
                            case MALL_NUMTYPE.REAL:
                                _slotStats[$ _itemStatKey] += _itemValue; 
                            break;
                        
                            case MALL_NUMTYPE.PERCENT:
                                var _stat = StatGet(_itemStatKey);
                                _slotStats[$ _itemStatKey] += (_stat.peak * _itemValue) / 100;
                            break;
                        }
                    }
                    
                    j++;
                }
            }
            
            i++;
        }
        
        #endregion
        
        #region Actualizar estados.
        i=0; repeat(array_length(controlsKeys) ) 
        {
            var _controlKey = controlsKeys[i];
            var _control = ControlGet(_controlKey);
            var _cnStats = _control.stats;
            // Ciclar por cada estadistica.
            j=0; repeat(_statSize) 
            {
                // llave de estadistica.
                _statKey = _statKeys[j];
                // Solo si existe el valor en el struct.
                if (struct_exists(_cnStats, _statKey) && struct_exists(_controlStats, _statKey) ) 
                {
                    var _cnStat = _cnStats[$ _statKey] ?? 0;
                    // Valor real (0).
                    var _cnReal = _cnStat[0];
                    // Valor porcentual (0).
                    var _cnPerc = _cnStat[1];
                    // Cambiar valor del control.
                    _stat = StatGet(_statKey);
                    _controlStats[$ _statKey] = _cnReal + ((_stat.peak * _cnPerc) / 100);
                }
                
                j++;
            }
            
            i++;
        }
        
        #endregion
        
        #region Actualizar Estadisticas.
        i=0; repeat(_statSize) 
        {
            var _statKey = _statKeys[i]
            var _stat = StatGet(_statKey);
            // Equipamiento (no puede ser menor al limite menor.
            var _equipment = _stat.peak + _slotStats[$ _statKey];
            _stat.equipment = max(_equipment, _stat.limitMin);
            
			// Control y efectos.
            var _control = _controlStats[$ _statKey];
            _stat.control = max(_stat.equipment + _control, _stat.limitMin);
            
            i++;
        }
        
        #endregion
    }
    
    /// @desc Guarda los datos de esta entidad en json
	/// @param	{Bool} [struct] devolver un struct o un JSON.
    static Export = function(_struct=false) 
    {
        var _this = self;
        var _save =  {
            categories: {},	categoriesKeys:	variable_clone(_this.categoriesKeys), 
            slots: {},		slotsKeys:		variable_clone(_this.slotsKeys), 
            controls: {},	controlsKeys:	variable_clone(_this.controlsKeys),
            stats: {}
        };
        
        with (_save) 
        {
            // Guardar version en la que se hizo el save.
            version = __MALL_MY_VERSION;
            is = _this.is;
            key = _this.key;
            dKey = _this.displayKey;
            // Grupo al que pertenece.
            group = _this.group;
            index = _this.index;
            // Nivel.
            level = _this.level;
            // Guardar Stats.
            var _keys = mall_get_stat_keys(), _key;
            var i=0; repeat(array_length(_keys) ) 
            {
                var _key = _keys[i];
                stats[$ _key] = _this.StatGet(_key).Export(true);
                i++;
            }
            // Guardar Slots.
            i=0; repeat(array_length(_this.slotsKeys) ) 
            {
                _key = _this.slotsKeys[i];
                slots[$ _key] = _this.SlotGet(_key).Export(true);
                i++;
            }
            
			// Guardar Control.
            i=0; repeat(array_length(_this.controlsKeys) ) 
            {
                _key = _this.controlsKeys[i];
                controls[$ _key] = _this.ControlGet(_key).Export(true);
                i++;
            }
            
            // Guardar categorias y comandos.
            var _cat;
            i=0; repeat(array_length(_this.categoriesKeys) ) 
            {
                _key = _this.categoriesKeys[i];
                _cat = _this.categories[$ _key];
                var _ckeys = variable_clone(_cat.keys);
                var _cstrc = {keys: _ckeys};
                // 
                var j=0; repeat(array_length(_ckeys) ) 
                {
                    var _ckey = _ckeys[j];
                    var _comm = _cat[$ _ckey];
                    if (!is_undefined(_comm) ) {_cstrc[$ _ckey] = _comm.key; }
                    j++;
                }
				
                // Agregar version.
                _cstrc[$ "version"] = __MALL_MY_VERSION;
                categories[$ _key] = _cstrc;
                
				i++;
            }
            
            return (!_struct) ? json_stringify(self, true) : self;
        }
    }
    
    /// @desc Carga desde un struct datos
    /// @param	{String} load_struct
    /// @return {Struct.PartyEntity}
    static Import = function(_l)
    {
        if (_l.is != is) exit;
        switch (_l.version)
		{
			default:
		        // Llaves.
		        key = _l.key;
		        dKey = _l.dKey;
		        // Grupo.
		        group = _l.group;
		        index = _l.index;
		        // Cargar nivel.
		        level = _l.level;
		        // Subir de nivel.
		        StatLevelUp(false, 0, true);
				
		        var i, _key, _keys, _str;
				
		        // Cargar estadisticas.
		        _keys = mall_get_stat_keys();
		        i=0; repeat(array_length(_keys) ) 
		        {
		            _key = _keys[i];
		            // Obtener valores guardados
		            _str = _l.stats[$ _key];
		            // Cargar
		            StatGet(_key).Import(_str);
		            
					i++;
		        }
        
		        // Cargar slots.
		        i=0; repeat(array_length(_l.slotsKeys) ) 
		        {
		            _key = slotsKeys[i];
		            _str = _l.slots[$ _key];
		            // Cargar slots
		            var _slot = SlotGet(_key);
					
		            // Si no existe.
		            if (is_undefined(_slot) ) 
		            {
		                SlotCreate(_slot.key).Import(_str);
		            }
		            else 
					{
		                _slot.Import(_str);
		            }
            
		            i++;
		        }
        
		        // Cargar control.
		        i=0; repeat(array_length(_l.controlsKeys) ) 
		        {
		            _key = controlsKeys[i];
		            _str = _l.controls[$ _key];
		            // Cargar control
		            var _control = ControlGet(_key);
		            if (is_undefined(_control) ) 
		            {
						ControlCreate(_control).Import(_str);
		            }
		            else 
		            {
						_control.Import(_str);
		            }
            
		            i++;
		        }
        
		        // Cargar categorias y comandos.
		        i=0; repeat(array_length(_l.categoriesKeys) )
				{
		            var _key = _l.categoriesKeys[i];
		            var _cat = _l.categories[$ _key];
		            // Comprobar que existe la categoria
		            if (!struct_exists(categories, _key) ) {CatCreate(_key); }
		            // Agregar comandos.
		            var j=0; repeat(array_length(_cat.keys) ) 
		            {
		                var _ckey = _cat.keys[j];
		                // Obtener comando para agregar en la categoria.
		                CatCommandAdd(_key, _ckey);
                
		                j++;
		            }
            
		            i++;
		        }
        
		        // Actualizar componentes.
		        UpdateComponents();
        
		        return self;			
			
			break;
		}
    }
  
    /// @param	{String}			item_key
    /// @param	{Real, Array<Real>}	quantity
    /// @param	{Real}				probability
    static BtAddDrop = function(_key, _value, _probability)
    {
        array_push(drops, {
			// Llaves.
            key: _key,
            // Puede ser un array.
            value:	!is_array(_value) ? _value : irandom_range(_value[0], _value[1] ),
            prob:	_probability
        });
        
		return self;
    }
    
    /// @desc Avanza el turno de esta entidad.
    static BtTurnAdvance = function()
    {
        turn++;
        if (__MALL_PARTY_TRACE) __mall_entity_trace($"M_PartyEntity: ha avanzado el turno personal {turn}." );
        return self;
    }
    
    /// @desc Añade un evento a los turnos.
    /// @param	{Real}		turn		
    /// @param	{Funcion}	function	
    static BtTurnEventAdd = function(_turn, _fn)
    {
        array_insert(turnEvent, _turn, _fn);
        return self;
    }
    
    /// @desc Ejecuta un evento.
    static BtTurnEventExecute = function()
    {
        if (turn < array_length(turnEvent) )
        {
            var _event = turnEvent[turn];
            if (is_callable(_event) ) return (_event() );
        }
        
        return undefined;
    }
    
    /// @desc Se utiliza en los combates y permite a esta instancia buscar sus propios objetivos 
    /// sin usar el default del DarkCommand.
	eBattleGetTarget = undefined;
    
    /// @desc Establecer como esta entidad busca objetivos.
    /// @param	{Function}	function  
    /// @param	{Struct}	[ref]     
    static BtSetTarget = function(_fn, _tg)
    {
        
        if (is_undefined(_tg) ) {eBattleGetTarget = method(self, _fn); }
        else                    {eBattleGetTarget = method(_tg,  _fn); }
        return self;
    }
    
    /// @desc Que hacer cuando no encuentra un objetivo.
    eBattleGetTargetFail = undefined;
    
    /// @desc Que hacer cuando no encuentra un objetivo.
    /// @param	{Function}	function  
    /// @param	{Struct}	[ref]
    static BtSetTargetFail = function(_fn, _tg)
    {
        if (_tg==undefined) {eBattleGetTargetFail = method(self, _fn); }
        else                {eBattleGetTargetFail = method(_tg , _fn); }
        return self;
    }
	
    #endregion
	
	#region PRIVATE
	
    /// @ignore
    /// @param	{String} stat_key
    static __Init = function(_key)
    {
        var _stat = mall_get_stat(_key);
        stats[$ _key] = new AtomStat(_stat);
        
		// Iniciar funcion de inicio.
        _stat.eInStart(self);
    }
    
    /// @ignore
    /// @desc Mostrar mensajes en consola
    /// @param	{String} message Mensage a mostrar en la consola
    static __mall_entity_trace = function(_msg)
    {
        show_debug_message($"M_Party {key}: {_msg}");
    }
    
    /// @ignore
    /// @desc Error
    /// @param	{String} error Error a mostrar
    static __mall_entity_error = function(_msg)
    {
        throw ($"M_Party {key}: {_msg}");
    }
    
    /// @ignore
    static __mall_entity_trace_stats = function()
    {
        var _str = "";
        var i=0; repeat(array_length(statsKeys) ) 
        {
            var _key = statsKeys[i];
            var _stat = StatGet(_key);
            
            _str += $"{_key}: control: [{_stat.control}], current: [{_stat.current}], ";
            
            i++;
        }
		
        return (__mall_entity_trace(_str) );
    }
    
    /// @ignore
    static __mall_entity_trace_controls = function()
    {
        var _str = "";
        var i=0; repeat(array_length(controlsKeys) ) 
        {
            var _ckey = controlsKeys[i++];
            var _control = ControlGet(_ckey);
            
            _str += $"{_ckey}: {_control.state}";
        }
		
		return (__mall_entity_trace(_str) );
    }
    
	#endregion
}

/// @desc Crea una plantilla de entidad desde data y la añade a la base de datos.
function party_entity_template_create(_key, _data)
{
    if (!struct_exists(Systemall.__entities, _template_key))
    {
        show_debug_message($"[Systemall] Advertencia: El entity template '{_key}' ya existe. Se omitirá la duplicada.", true);
        return undefined;
    }
	
    // Guardamos el struct de datos directamente como plantilla.
	Systemall.__entities[$ _key] = _data;
    array_push(Systemall.__entities_keys, _key);
}

function party_entity_template_exists(_key) 
{
	return (struct_exists(Systemall.__entities, _key) ); 
}

/// @desc Crea una INSTANCIA de una entidad a partir de una plantilla.
/// @param {String}	template_key La llave de la plantilla (ej: "JON", "SLIME").
/// @param {Real}	[level]=1 El nivel inicial de la instancia.
/// @return {Struct.PartyEntity}
function party_entity_create_instance(_template_key, _level=1)
{
    if (party_entity_template_exists(_template_key) )
    {
        show_error($"[Systemall] Intento de crear una instancia de una plantilla no existente: '{_template_key}'", true);
        return undefined;
    }
    
    // Crear un ID único para la instancia (esto es una simplificación, se podría usar un contador global)
    var _instance_id = $"{_template_key}_{get_timer()}"; 
    
    var _entity = new PartyEntity(_template_key, _instance_id);
    _entity.FromTemplate();
    _entity.level = _level;
    _entity.RecalculateStats();
    
    return _entity;
}
