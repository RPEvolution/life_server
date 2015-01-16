/*
	File: fn_wantedRemove.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Removes a person from the wanted list.
*/
private["_uid","_index","_query"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
if(_uid == "") exitWith {}; //Bad data

// DELETE PERSON FROM WANTED LIST
_query = format["UPDATE wanted SET active='0' WHERE pid='%1'",_uid];
waitUntil {!DB_Async_Active};
[_query,1] call DB_fnc_asyncCall;

_index = [_uid,life_wanted_list] call TON_fnc_index;
if(_index == -1) exitWith {};
life_wanted_list set[_index,-1];
life_wanted_list = life_wanted_list - [-1];