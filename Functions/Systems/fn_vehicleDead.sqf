/*
	File: fn_vehicleDead.sqf
	
	Description:
	Tells the database that this vehicle has died and can't be recovered.
*/
private["_vehicle","_plate","_uid","_query","_sql","_dbInfo","_thread"];
_vehicle = [_this,0,ObjNull,[ObjNull]] call BIS_fnc_param;
hint str _vehicle;
if(isNull _vehicle) exitWith {}; //NULL

diag_log "------------- Vehicle Dead -------------";
diag_log format["Vehicle: %1",_vehicle];

// Why does cars explode?!?!
if(_vehicle isKindOf "Car") then {
	_vehicle setDammage 0.9; 
	_vehicle setHit["wheel_1_1_steering", 1]; 
	_vehicle setHit["wheel_1_2_steering", 1]; 
	_vehicle setHit["wheel_2_1_steering", 1];
	_vehicle setHit["wheel_2_2_steering", 1]; 
	_vehicle setHit["karoserie", 1];
};

_dbInfo = _vehicle getVariable["dbInfo",[]];
if(count _dbInfo == 0) exitWith {};
_uid = _dbInfo select 0;
_plate = _dbInfo select 1;

_query = format["UPDATE vehicles SET alive='0' WHERE pid='%1' AND plate='%2'",_uid,_plate];
//_sql = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', '%1']", _query,(call LIFE_SCHEMA_NAME)];

waitUntil {!DB_Async_Active};
_thread = [_query,1] call DB_fnc_asyncCall;

sleep (1.3 * 60);
if(!isNil "_vehicle" && {!isNull _vehicle}) then {
	deleteVehicle _vehicle;
};