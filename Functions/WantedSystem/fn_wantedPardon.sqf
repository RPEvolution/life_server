/*
	File: fn_wantedPardon.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Unwants / pardons a person from the wanted list.
*/
private["_uid","_query"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
if(_uid == "") exitWith {};

_index = [_uid,life_wanted_list] call TON_fnc_index;

// DELETE PERSON FROM WANTED LIST
_query = format["UPDATE wanted SET active='0' WHERE pid='%1'",_uid];
waitUntil {!DB_Async_Active};
[_query,1] call DB_fnc_asyncCall;

if(_index != -1) then
{
	life_wanted_list set[_index,-1];
	life_wanted_list = life_wanted_list - [-1];
	//publicVariable "life_wanted_list";
};