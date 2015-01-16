/*
	File: fn_queryPlayer.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Handles the incoming request and sends an asynchronous query 
	request to the database.
	
	Return:
	ARRAY - If array has 0 elements it should be handled as an error in client-side files.
	STRING - The request had invalid handles or an unknown error and is logged to the RPT.
*/
private["_uid","_side","_ownerID","_query","_return","_queryResult","_qResult","_handler","_thread","_tickTime","_queryTime","_loops","_returnCount","_string","_number","_array"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
_side = [_this,1,sideUnknown,[civilian]] call BIS_fnc_param;
_ownerID = [_this,2,ObjNull,[ObjNull]] call BIS_fnc_param;

diag_log "------------- Start Player Query -------------";

if(isNull _ownerID) exitWith {};
_ownerID = owner _ownerID;

/*
	_returnCount is the count of entries we are expecting back from the async call.
	The other part is well the SQL statement.
*/
_query = format["SELECT playerid, name, cash, bankacc, experience, arrrested, licenses, gear, position, stats, skills, missions FROM players WHERE playerid='%1' AND side='%2'",_uid,_side];

waitUntil{sleep (random 0.3); !DB_Async_Active};
_tickTime = diag_tickTime;
_queryResult = [_query,2] call DB_fnc_asyncCall;
_queryTime = diag_tickTime - _tickTime;

// Checks if Player even exists
if(typeName _queryResult == "STRING") exitWith {
	[[],"SOCK_fnc_insertPlayerInfo",_ownerID,false,true] spawn life_fnc_MP;
};

if(count _queryResult == 0) exitWith {
	[[],"SOCK_fnc_insertPlayerInfo",_ownerID,false,true] spawn life_fnc_MP;
};

diag_log "------------- Player Query Request -------------";
diag_log format["QUERY: %1",_query];
diag_log format["Time to complete: %1 (in seconds)",_queryTime];
diag_log format["Result: %1",_queryResult];
diag_log "------------------------------------------------";

// Blah conversion thing from a2net->extdb
private["_tmp"];
_tmp = _queryResult select 2;
_queryResult set[2,[_tmp] call DB_fnc_numberSafe];
_tmp = _queryResult select 3;
_queryResult set[3,[_tmp] call DB_fnc_numberSafe];
_tmp = _queryResult select 4;
_queryResult set[4,[_tmp] call DB_fnc_numberSafe];

// Checks if Player arrested
_queryResult set[5,([_queryResult select 5,1] call DB_fnc_bool)];

/* 	Parse 	Player Licenses (Index 6), 
			Player Gear (Index 7), 
			Player Position (Index 8), 
			Player Stats (Index 9)
*/
for "_i" from 6 to 9 do {
	_tmp = [(_queryResult select _i)] call DB_fnc_mresToArray;
	if(typeName _new == "STRING") then {_tmp = call compile format["%1", _tmp];};
	_queryResult set[_i,_tmp];
};

// Convert tinyint to boolean for Player Licenses
_old = _queryResult select 6;
for "_i" from 0 to (count _old)-1 do
{
	_data = _old select _i;
	_old set[_i,[_data select 0, ([_data select 1,1] call DB_fnc_bool)]];
};

_queryResult set[6,_old];


// Parse data for specific side.
switch (_side) do {
	case civilian: {
		_houseData = _uid spawn TON_fnc_fetchPlayerHouses;
		waitUntil {scriptDone _houseData};
		_queryResult set[13,(missionNamespace getVariable[format["houses_%1",_uid],[]])];
		_gangData = _uid spawn TON_fnc_queryPlayerGang;
		waitUntil{scriptDone _gangData};
		_queryResult set[14,(missionNamespace getVariable[format["gang_%1",_uid],[]])];
		[_uid] call life_fnc_fetchWantedPlayer;
	};
};

/*
// Append our ClientResult to our QueryResult
_queryResult set[count _queryResult, _clientResult select 3];
_queryResult set[count _queryResult, _clientResult select 2];
_queryResult set[count _queryResult, _clientResult select 4];
*/

for "_i" from 0 to count(_queryResult)-1 do {
	diag_log "------------- Client Query Result -------------";
	diag_log format["SELECT %1: %2",_i,_queryResult select _i];
};

_queryResult;
//[_queryResult,"SOCK_fnc_requestReceived",_ownerID,false] spawn life_fnc_MP;