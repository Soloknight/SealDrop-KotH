/*
	THIS FILE IT TAKEN FROM THE PUBLIC VAS SCRIPT
	File: fn_fetchCfgDetails.sqf
	Author: Tonic
	Modified: DeadP4xel

	Return:
	0: classname
	1: displayname
	2: picture
	3: scope
	4: type
	5: itemInfo Type (if any, -1 means none)
	6: Cfg Location i.e CfgWeapons
	7: Magazines
	8: Muzzles
	9: Short Description
	10: acc_Pointers
	11: acc_Optics
	12: acc_Muzzles
	13: Base (Superclass)
	14: New compatibleItems Structure
	15: Item Description Long
*/
private["_entity","_cfg","_ret","_type","_acc_p","_acc_o","_slotclasses","_acc_m","_scope","_displayName","_picture","_config","_itemInfo","_muzzles","_magazines","_desc","_base"];
_entity = [_this,0,"",[""]] call BIS_fnc_param;
_type = -1;
_acc_p = [];
_acc_o = [];
_acc_m = [];
_slotclasses = [];
_scope = 0;
_itemInfo = -1;
_muzzles = [];
_magazines = [];
_infoText = [];
if(_entity isEqualTo "") exitWith {[]};
_cfg = if(isNil {_this select 1}) then
{
	switch (true) do
	{
		case (isClass (configFile >> "CfgMagazines" >> _entity)) : {"CfgMagazines";};
		case (isClass (configFile >> "CfgWeapons" >> _entity)) : {"CfgWeapons";};
		case (isClass (configFile >> "CfgVehicles" >> _entity)) : {"CfgVehicles";};
		case (isClass (configFile >> "CfgGlasses" >> _entity)) : {"CfgGlasses";};
	};
} else {
	_this select 1
};
_ret = [];
if(typeName _cfg != "STRING") exitWith {[]};
if(!isClass (configFile >> _cfg >> _entity)) exitWith {[]};
if(_cfg isEqualTo "") exitWith {[]};
_config = configFile >> _cfg >> _entity;
_displayName = getText(_config >> "displayName");
_picture = getText(_config >> "picture");
_desc = getText(_config >> "descriptionshort");
_base = inheritsFrom _config;
_infoText = getText(_config >> "Library" >> "libTextDesc");
switch (_cfg) do
{
	case "CfgVehicles":
	{
		_type = getText(_config >> "vehicleClass");
		_scope = getNumber(_config >> "scope");
	};
	case "CfgWeapons":
	{
		_scope = getNumber(_config >> "scope");
		_type = getNumber(_config >> "type");
		_desc = getText(_config >> "descriptionshort");
		_infoText = getText(_config >> "Library" >> "libTextDesc");
		if(isClass (_config >> "WeaponSlotsInfo")) then
		{
			_acc_p = getArray(_config >> "WeaponSlotsInfo" >> "PointerSlot" >> "compatibleItems");
			_acc_o = getArray(_config >> "WeaponSlotsInfo" >> "CowsSlot" >> "compatibleItems");
			_acc_m = getArray(_config >> "WeaponSlotsInfo" >> "MuzzleSlot" >> "compatibleItems");
			
			{	private "_thiscfgitem";
				for "_i" from 0 to (count(_x) - 1) do {
					_thiscfgitem = _x select _i;
					if (isClass _thiscfgitem) then {
						if !((configName _thiscfgitem) in _slotclasses) then {
							_slotclasses pushBack configName _thiscfgitem;
						};
					};
				};
			} forEach ([_config>>"WeaponSlotsInfo"] call bis_fnc_returnParents);
		};
		if(isClass (_config >> "ItemInfo")) then{_itemInfo = getNumber(_config >> "ItemInfo" >> "Type");};
		_muzzles = getArray(_config >> "muzzles");
		_magazines = getArray(_config >> "magazines");
		if(!isNil {_muzzles}) then
		{
			private["_tmp"];
			{
				if(_x != "this") then
				{
					_tmp = getArray(_base >> _x >> "magazines");
					{
						_magazines pushBack _x;
					} foreach (_tmp);
				};
			} foreach _muzzles;
		};
	};
	case "CfgMagazines":
	{
		_scope = getNumber(_config >> "scope");
		_infoText = getText(_config >> "Library" >> "libTextDesc");
	};
};
if(!isNil "_slotclasses") then
{
	_slotclasses = _slotclasses - ["MuzzleSlot"];
	_slotclasses = _slotclasses - ["CowsSlot"];
	_slotclasses = _slotclasses - ["PointerSlot"];
};
_ret = [_entity,_displayName,_picture,_scope,_type,_itemInfo,_cfg,_magazines,_muzzles,_desc,_acc_p,_acc_o,_acc_m,_base,_slotclasses,_infoText];
_ret;