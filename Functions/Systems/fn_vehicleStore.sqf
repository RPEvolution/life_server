/*
	File: fn_vehicleStore.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Stores the vehicle in the 'Garage'
*/
private["_vehicle","_impound","_vInfo","_vInfo","_plate","_uid","_query","_sql","_unit","_trunk","_cargo"];
_vehicle = [_this,0,ObjNull,[ObjNull]] call BIS_fnc_param;
_impound = [_this,1,false,[true]] call BIS_fnc_param;
_unit = [_this,2,ObjNull,[ObjNull]] call BIS_fnc_param;

if(isNull _vehicle OR isNull _unit) exitWith {life_impound_inuse = false; (owner _unit) publicVariableClient "life_impound_inuse";life_garage_store = false;(owner _unit) publicVariableClient "life_garage_store";}; //Bad data passed.

_vInfo = _vehicle getVariable["dbInfo",[]];
if(count _vInfo > 0) then
{
	_plate = _vInfo select 1;
	_uid = _vInfo select 0;
};

//Saves Items in the Trunk of the Vehicle
_trunk = _vehicle getVariable["Trunk",[]];
_trunk = [_trunk] call DB_fnc_mresArray;
_trunk = call compile format["%1", _trunk];

// Saves WeaponCargo of the Vehicle
_cargo = getWeaponCargo _vehicle;
_cargo = [_cargo] call DB_fnc_mresArray;

if(_impound) then
{
	if(count _vInfo == 0) then 
	{		
		life_impound_inuse = false;
		(owner _unit) publicVariableClient "life_impound_inuse";
		if(!isNil "_vehicle" && {!isNull _vehicle}) then {
			deleteVehicle _vehicle;
		};
	} 
		else
	{
		_query = format["UPDATE vehicles SET active='0', trunk='[]' WHERE pid='%1' AND plate='%2'",_uid,_plate];
		waitUntil {!DB_Async_Active};
		_thread = [_query,1] call DB_fnc_asyncCall;
		//waitUntil {scriptDone _thread};
		if(!isNil "_vehicle" && {!isNull _vehicle}) then {
			deleteVehicle _vehicle;
		};
		life_impound_inuse = false;
		(owner _unit) publicVariableClient "life_impound_inuse";
	};
}
	else
{
	if(count _vInfo == 0) exitWith
	{
		[[1,"Mietwagen können nicht in der Garage geparkt werden."],"life_fnc_broadcast",(owner _unit),false] spawn life_fnc_MP;
		life_garage_store = false;
		(owner _unit) publicVariableClient "life_garage_store";
	};
	
	if(_uid != getPlayerUID _unit) exitWith
	{
		[[1,"Das Fahrzeug gehört nicht dir und kann deshalb nicht in der Garage geparkt werden."],"life_fnc_broadcast",(owner _unit),false] spawn life_fnc_MP;
		life_garage_store = false;
		(owner _unit) publicVariableClient "life_garage_store";
	};
	
	_query = format["UPDATE vehicles SET active='0', trunk='%3' WHERE pid='%1' AND plate='%2'",_uid,_plate,_trunk];
	waitUntil {!DB_Async_Active};
	_thread = [_query,1] call DB_fnc_asyncCall;
	//waitUntil {scriptDone _thread};
	if(!isNil "_vehicle" && {!isNull _vehicle}) then {
		deleteVehicle _vehicle;
	};
	life_garage_store = false;
	(owner _unit) publicVariableClient "life_garage_store";
	[[1,"Das Fahrzeug wurde in der Garage geparkt."],"life_fnc_broadcast",(owner _unit),false] spawn life_fnc_MP;
};