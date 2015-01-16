/*
	File: fn_queryClient.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Handles the incoming request and sends an asynchronous query 
	request to the database.
	
	Return:
	ARRAY - If array has 0 elements it should be handled as an error in client-side files.
	STRING - The request had invalid handles or an unknown error and is logged to the RPT.
*/
private["_uid","_side","_ownerID","_query","_queryResult","_tickTime","_queryTime","_returnCount"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
_side = [_this,1,sideUnknown,[civilian]] call BIS_fnc_param;
_ownerID = [_this,2,ObjNull,[ObjNull]] call BIS_fnc_param;

if(isNull _ownerID) exitWith {};
_ownerID = owner _ownerID;

/*
	_returnCount is the count of entries we are expecting back from the async call.
	The other part is well the SQL statement.
*/

_query = format["SELECT playerid, name, adminlevel, perms, blacklist FROM clients WHERE playerid = '%1'",_uid];

waitUntil{sleep (random 0.3); !DB_Async_Active};
_tickTime = diag_tickTime;
_queryResult = [_query,2] call DB_fnc_asyncCall;
_queryTime = diag_tickTime - _tickTime;

// Checks if Client even exists
if(typeName _queryResult == "STRING") exitWith {
	[[],"SOCK_fnc_insertClientInfo",_ownerID,false,true] spawn life_fnc_MP;
};

if(count _queryResult == 0) exitWith {
	[[],"SOCK_fnc_insertClientInfo",_ownerID,false,true] spawn life_fnc_MP;
};

diag_log "------------- Client Query Request -------------";
diag_log format["QUERY: %1",_query];
diag_log format["Time to complete: %1 (in seconds)",_queryTime];
diag_log format["Result: %1",_queryResult];
diag_log "------------------------------------------------";

// Starting to Parse Query Result
private["_tmp"];

// Parse Perms of Client
_tmp = [(_queryResult select 3)] call DB_fnc_mresToArray;
if(typeName _tmp == "STRING") then {_tmp = call compile format["%1", _new];};
_queryResult set[3,_tmp];

// Checks if Client on Blacklist
_queryResult set[4,([_queryResult select 4,1] call DB_fnc_bool)];
if(_queryResult select 4) exitWith {cutText["Du bist vom Sever gebannt!","BLACK FADED"];0 cutFadeOut 999999999;};

[_queryResult,"SOCK_fnc_playerQuery",_ownerID,false] spawn life_fnc_MP;