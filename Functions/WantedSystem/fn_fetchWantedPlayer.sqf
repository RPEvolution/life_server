/*
	File: fn_fetchWantedList.sqf
	Author: Spiderswine
	
	Description:
	Fetches the Wanted List from Database.
*/

private["_uid","_name","_type","_query","_wanted","_val","_crimes","_data","_index"];

_uid = [_this,0,"",[""]] call BIS_fnc_param;

_query = format["SELECT pid, name, type FROM wanted WHERE pid='%1' AND active='1'",_uid];
waitUntil{!DB_Async_Active};
_wanted = [_query,2,true] call DB_fnc_asyncCall;

for "_i" from 0 to (count _wanted)-1 do
{
	_uid = (_wanted select _i)select 0;
	_name = (_wanted select _i)select 1;
	_type = (_wanted select _i)select 2;
		
	//["_uid", "_name", "_type"] call life_fnc_wantedAdd;
	//[(_wanted select _i)select 0, (_wanted select _i)select 1, (_wanted select _i)select 2] call life_fnc_wantedAdd;
	
	if(_uid == "" OR _name == "" OR _type == "") exitWith {}; //Bad data passed.

	//What is the crime?
	switch(_type) do
	{
		case "187V": {_type = ["Totschlag durch Fahrzeug",27500]};
		case "187": {_type = ["Totschlag",30000]};
		case "901": {_type = ["Auf der Flucht",15000]};
		case "261": {_type = ["Vergewaltigung",15000]}; //What type of sick bastard would add this?
		case "261A": {_type = ["Versuchte Vergewaltigung",12500]};
		case "215": {_type = ["Versuchter Auto Diebstahl",5000]};
		case "213": {_type = ["Verwendung von illegalen Sprengstoff",25000]};
		case "211": {_type = ["Raub",25000]};
		case "207": {_type = ["Entführung",25000]};
		case "207A": {_type = ["Versuchte Entführung",15000]};
		case "487": {_type = ["Diebstahl",10000]};
		case "488": {_type = ["Bagatelldiebstahl",5000]};
		case "480": {_type = ["Fahrerflucht",15000]};
		case "481": {_type = ["Herstellen von Drogen",10000]};
		case "482": {_type = ["Hehlerei",20000]};
		case "483": {_type = ["Drogen schmuggeln",20000]};
		case "459": {_type = ["Einbruch",25000]};
		default {_type = [];};
	};

	if(count _type == 0) exitWith {}; //Not our information being passed...
	//Is there a custom bounty being sent? Set that as the pricing.
	//if(_customBounty != -1) then {_type set[1,_customBounty];};
	//Search the wanted list to make sure they are not on it.
	_index = [_uid,life_wanted_list] call TON_fnc_index;

	if(_index != -1) then
	{
		_data = life_wanted_list select _index;
		_crimes = _data select 2;
		_crimes set[count _crimes,(_type select 0)];
		_val = _data select 3;
		life_wanted_list set[_index,[_name,_uid,_crimes,(_type select 1) + _val]];
	}
		else
	{
		life_wanted_list set[count life_wanted_list,[_name,_uid,[(_type select 0)],(_type select 1)]];
	};
};