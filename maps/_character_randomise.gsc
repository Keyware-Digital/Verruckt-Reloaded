#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;

init()
{
	randomise_character_index();
	get_player_score_colors();
}

randomise_character_index()
{
	level.random_character_index = [];
	for( i = 0; i < 4; i++ )
	{
		level.random_character_index[ i ] = i;
	}
	level.random_character_index = array_randomize( level.random_character_index );
}

get_player_score_colors()
{
	level.random_character_color = [];
	for( i = 0; i < 4; i++ )
	{
		level.random_character_color[ i ] = GetDvar( "cg_ScoresColor_Gamertag_" + i );
	}
}