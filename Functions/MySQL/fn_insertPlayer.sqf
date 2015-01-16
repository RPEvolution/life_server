/*
	File: fn_insertRequest.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Does something with inserting... Don't have time for
	descriptions... Need to write it...
*/
private["_uid","_name","_side","_money","_bank","_licenses","_queryResult","_query","_position","_stats","_returnToSender"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
_name = [_this,1,"",[""]] call BIS_fnc_param;
_side = [_this,2,sideUnknown,[civilian]] call BIS_fnc_param;
_money = [_this,3,0,[""]] call BIS_fnc_param;
_bank = [_this,4,2500,[""]] call BIS_fnc_param;
_returnToSender = [_this,5,ObjNull,[ObjNull]] call BIS_fnc_param;
_positions = [];
_stats = [];

//Error checks
if((_uid == "") OR (_name == "")) exitWith {systemChat "Bad UID or name";}; //Let the client be 'lost' in 'transaction'
if(isNull _returnToSender) exitWith {systemChat "ReturnToSender is Null!";}; //No one to send this to!

_query = format["SELECT playerid, name FROM players WHERE playerid='%1' AND side='%2'",_uid,_side];

waitUntil{sleep (random 0.3); !DB_Async_Active};
//_tickTime = diag_tickTime;
_queryResult = [_query,2] call DB_fnc_asyncCall;

//Double check to make sure the client isn't in the database...
if(typeName _queryResult == "STRING") exitWith {[[],"SOCK_fnc_dataQuery",(owner _returnToSender),false] spawn life_fnc_MP;}; //There was an entry!
if(count _queryResult != 0) exitWith {[[],"SOCK_fnc_dataQuery",(owner _returnToSender),false] spawn life_fnc_MP;};

//Inserts standard Positions of the Player
_position = switch(_side) do {
	case west: 			{["17402.1","13177.8","0.00142765"]};
	case civilian: 		{["16499.2","12793.8","0.00130272"]};
	case independent:	{["3734.39","12993.7","0.00146484"]};
};
_stats = ["100","100","0"];

//Clense and prepare some information.
_name = [_name] call DB_fnc_mresString; //Clense the name of bad chars.
_money = [_money] call DB_fnc_numberSafe;
_bank = [_bank] call DB_fnc_numberSafe;
_position = [_position] call DB_fnc_mresArray;
_stats = [_stats] call DB_fnc_mresArray;

//Prepare the query statement..
_query = format["INSERT INTO players (playerid, side, name, cash, bankacc, licenses, gear, last_position, stats, skills, missions) VALUES('%1', '%2', '%3', '%4', '%5','""[]""','""[]""', '%6', '%7','""[]""','""[]""')",
	_uid,
	_side,
	_name,
	_money,
	_bank,
	_position,
	_stats
];

waitUntil {!DB_Async_Active};
[_query,1] call DB_fnc_asyncCall;
[[],"SOCK_fnc_dataQuery",(owner _returnToSender),false] spawn life_fnc_MP;