/*
	File: fn_updateRequest.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Ain't got time to describe it, READ THE FILE NAME!
*/
private["_uid","_side","_cash","_bank","_licenses","_gear","_name","_query","_thread","_perms","_positions","_stats","_sel","_tickTime"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
_name = [_this,1,"",[""]] call BIS_fnc_param;
_side = [_this,2,sideUnknown,[civilian]] call BIS_fnc_param;
_cash = [_this,3,0,[0]] call BIS_fnc_param;
_bank = [_this,4,5000,[0]] call BIS_fnc_param;
_experience = [_this,5,0,[0]] call BIS_fnc_param;
_licenses = [_this,6,[],[[]]] call BIS_fnc_param;
_gear = [_this,7,[],[[]]] call BIS_fnc_param;
_position = [_this,9,[],[[]]] call BIS_fnc_param;
_stats = [_this,10,[],[[]]] call BIS_fnc_param;
_skills = [_this,11,[],[[]]] call BIS_fnc_param;
_missions = [_this,12,[],[[]]] call BIS_fnc_param;

//Get to those error checks.
if((_uid == "") OR (_name == "")) exitWith {};

//Does something license related but I can't remember I only know it's important?
for "_i" from 0 to count(_licenses)-1 do {
	_bool = [(_licenses select _i) select 1] call DB_fnc_bool;
	_licenses set[_i,[(_licenses select _i) select 0,_bool]];
};

//Parse and setup some data.
_name = [_name] call DB_fnc_mresString;
_gear = [_gear] call DB_fnc_mresArray;
_cash = [_cash] call DB_fnc_numberSafe;
_bank = [_bank] call DB_fnc_numberSafe;
_position = [_position] call DB_fnc_mresArray;
_licenses = [_licenses] call DB_fnc_mresArray;
_stats = [_stats] call DB_fnc_mresArray;
_skills = [_skills] call DB_fnc_mresArray;
_missions = [_missions] call DB_fnc_mresArray;

_query = format["UPDATE players SET name='%1', cash='%2', bankacc='%3', experience='%4', arrested = '%5', licenses='%6', gear='%7', last_position='%8', stats='%9', skills='%10', missions='%11' WHERE playerid='%12' AND side='%13'",
	_name,
	_cash,
	_bank,
	_experience,
	[_this select 8] call DB_fnc_bool,
	_licenses,
	_gear,
	_position,
	_stats,
	_skills,
	_missions,
	_uid,
	_side
];

diag_log "------------- Player Update Request -------------";
diag_log format["QUERY: %1",_query];
diag_log "------------------------------------------------";

waitUntil {sleep (random 0.3); !DB_Async_Active};
_tickTime = diag_tickTime;
_queryResult = [_query,1] call DB_fnc_asyncCall;