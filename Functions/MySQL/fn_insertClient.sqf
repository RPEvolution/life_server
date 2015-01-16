/*
	File: fn_insertClient.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Does something with inserting... Don't have time for
	descriptions... Need to write it...
*/
private["_uid","_name","_side","_money","_bank","_handler","_thread","_queryResult","_query","_alias","_returnToSender"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
_name = [_this,1,"",[""]] call BIS_fnc_param;
_returnToSender = [_this,2,ObjNull,[ObjNull]] call BIS_fnc_param;

hint "C1";

//Error checks
if((_uid == "") OR (_name == "")) exitWith {systemChat "Bad UID or name";}; //Let the client be 'lost' in 'transaction'
if(isNull _returnToSender) exitWith {systemChat "ReturnToSender is Null!";}; //No one to send this to!

_query = format["SELECT playerid, name FROM clients WHERE playerid='%1'",_uid];

waitUntil{sleep (random 0.3); !DB_Async_Active};
_tickTime = diag_tickTime;
_queryResult = [_query,2] call DB_fnc_asyncCall;

//Double check to make sure the client isn't in the database...
if(typeName _queryResult == "STRING") exitWith {[[],"SOCK_fnc_dataQuery",(owner _returnToSender),false] spawn life_fnc_MP;}; //There was an entry!
if(count _queryResult != 0) exitWith {[[],"SOCK_fnc_dataQuery",(owner _returnToSender),false] spawn life_fnc_MP;};

//Clense and prepare some information.
_name = [_name] call DB_fnc_mresString; //Clense the name of bad chars.
_alias = [[_name]] call DB_fnc_mresArray;

hint "C2";

//Prepare the query statement..
_query = format["INSERT INTO clients (playerid, name, aliases, perms) VALUES('%1', '%2', '%3','""[]""')",
	_uid,
	_name,
	_alias
];

waitUntil {!DB_Async_Active};
[_query,1] call DB_fnc_asyncCall;
[[],"SOCK_fnc_dataQuery",(owner _returnToSender),false] spawn life_fnc_MP;