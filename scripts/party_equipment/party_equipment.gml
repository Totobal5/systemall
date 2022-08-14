/// @param {Struct.PartyEntity}	party_entity
function PartyEquipment(_ENTITY) : __PartyComponent(_ENTITY) constructor 
{	
	with (_ENTITY) equipment = other;
	stats   = _ENTITY.getStat();
	control = _ENTITY.getControl();
	
    #region METHODS
	/// @ignore
	/// @desc Iniciar control de partes
	static initialize = function() 
	{
		mall_equipment_foreach(method(undefined, function(mall, key) {
			variable_struct_set(self, key, new __PartyEquipmentAtom(key, mall))
			array_push(__keys, key);
		}));
    }
	
	/// @param {String} equipment_key
	/// @return {Struct.__PartyEquipmentAtom}
	static get = function(_key) 
	{
        return (self[$ _key] );
    } 
	
	/// @param {String} equipment_key
	/// @param {String} item_key
	/// @desc False: no se logro equipar el objeto True: objeto equipado
	/// @return {Bool}
	static equip	= function(_KEY, _ITEM_KEY) 
	{
		var _equipment = get(_KEY);
		var _item = pocket_get(_ITEM_KEY);
		
		if (!is_undefined(_equipment) )
		{
			// Si puede equipar este objeto
			if (variable_struct_exists(_equipment.items, _item.key) )
			{
				_equipment.previous = _equipment.equipped;
				_equipment.equipped = _item;
				
				var _keys = variable_struct_get_names(_item.statsNormal);
				var i=0; repeat(array_length(_keys) )
				{
					var _stat = _keys[i];
					stats.updateEquipment(_stat);
					stats.updateControl  (_stat);
					i = i + 1;
				}
				
				return true;
			}
		}
		
		return false;
    } 
	
	/// @param {String} equipment_key
	static desequip = function(_KEY) 
	{
        var _equipment = get(_KEY);
        
		if (!is_undefined(_equipment) )
		{
			var _item = _equipment.equipped;
			if (is_undefined(_item) ) return false;
			
			var _keys = variable_struct_get_names(_item.statsNormal);
			var i=0; repeat(array_length(_keys) )
			{
				var _stat = _keys[i];
				stats.updateEquipment(_stat, true);
				stats.updateControl  (_stat);
				i = i + 1;
			}			

			_equipment.previous = _equipment.equipped;
			_equipment.equipped = undefined;
			
			return true;
		}
		
		return false;
    } 
	
	/// @param {String} item_key
	/// @returns {Bool}
	static isEquipped = function(_KEY) 
	{
		var _item = get(_KEY).equipped;
        return (_item.key == _KEY);
    }
	
	/// @param {String} equipment_key
	/// @param {String} item_key
	/// @returns {Struct}
	/// Compara las estadisticas del objeto actual con otro objeto obteniendo la diferencia en estadisticas
	static compareItem = function(_KEY, _ITEM_KEY) 
	{
		var _equipment = get(_KEY);
		var _equipped = _equipment.equipped;
		var _compare  = pocket_get(_ITEM_KEY);
		
		return (_equipment.eventCompare(stats, _equipment, _compare) );
	}
	
	/// @desc Regresa las estadisticas sin este objeto equipado.
	/// @param {String} equipment_key
	/// @returns {Struct}
	static compareNoItem = function(_KEY) 
	{
		static noitem = new PocketItem();
		var _equipment = get(_KEY);
		return (_equipment.eventCompare(stats, noitem, noitem) );	
	}

	static getComponents = function()
	{
		stats	= __entity.ref.getStat();
		control = __entity.ref.getControl();
	}
	

	#endregion
	
	initialize();
}