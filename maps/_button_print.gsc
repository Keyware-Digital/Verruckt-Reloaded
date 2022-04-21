#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_zombiemode_utility;

init()
{
	level thread opc();
}

opc()
{
	while(1)
	{
		level waittill( "connecting", player ); 
		player thread player_ops(); 
	}
}


player_ops()
{
self endon( "disconnect" );
	while(1)
	{
		self waittill( "spawned_player" ); 
		self thread button_response();
	}
}

 
button_response()
{
self endon("death");
self endon("disconnect");
	while(1)
	{
		self waittill("menuresponse", menu, response );

		self thread button_pressed(response);
	}
}
button_pressed(response)
{
self endon("death");
self endon("disconnect");
 
	switch( response )
	{
		case "print_text":
		self iprintlnbold( "^2Button Pressed" );
		break;

		default:	
		break;
	}
}
