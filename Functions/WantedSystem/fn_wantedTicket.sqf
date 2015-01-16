/*
	File: fn_wantedTicket.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Checks the price of the ticket against the bounty, if => then bounty remove them from the wanted list.
*/
private["_price","_uid","_ind","_entry","_query"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
_price = [_this,1,0,[0]] call BIS_fnc_param;
if(_uid == "" OR _price == 0) exitWith {};

// DELETE PERSON FROM WANTED LIST
_query = format["UPDATE wanted SET active='0' WHERE pid='%1'",_uid];
waitUntil {!DB_Async_Active};
[_query,1] call DB_fnc_asyncCall;

_ind = [_uid,life_wanted_list] call TON_fnc_index;
if(_ind == -1) exitWith {};
life_wanted_list set[_ind,-1];
life_wanted_list = life_wanted_list - [-1];