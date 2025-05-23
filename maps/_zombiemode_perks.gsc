#include maps\_utility; 
#include common_scripts\utility; 
#include maps\_zombiemode_utility;

init()
{
	vending_triggers = GetEntArray( "zombie_vending", "targetname" );

	if ( vending_triggers.size < 1 )
	{
		return;
	}

	// this map uses atleast 1 perk machine
	PrecacheItem( "zombie_perk_bottle_doubletap" );
	PrecacheItem( "zombie_perk_bottle_jugg" );
	PrecacheItem( "zombie_perk_bottle_revive" );
	PrecacheItem( "zombie_perk_bottle_sleight" );

	PrecacheShader( "specialty_juggernaut_zombies" );
	PrecacheShader( "specialty_fastreload_zombies" );
	PrecacheShader( "specialty_doubletap_zombies" );
	PrecacheShader( "specialty_quickrevive_zombies" );

	PrecacheModel("zombie_vending_doubletap_on");
	PrecacheModel("zombie_vending_jugg_on");
	PrecacheModel("zombie_vending_revive_on");
	PrecacheModel("zombie_vending_sleight_on");


	level._effect["sleight_light"] = loadfx("misc/fx_zombie_cola_on");
	level._effect["doubletap_light"] = loadfx("misc/fx_zombie_cola_dtap_on");
	level._effect["jugger_light"] = loadfx("misc/fx_zombie_cola_jugg_on");
	level._effect["revive_light"] = loadfx("misc/fx_zombie_cola_revive_on");

	PrecacheString( &"ZOMBIE_PERK_JUGGERNAUT" );
	PrecacheString( &"ZOMBIE_PERK_QUICKREVIVE" );
	PrecacheString( &"ZOMBIE_PERK_FASTRELOAD" );
	PrecacheString( &"ZOMBIE_PERK_DOUBLETAP" );

	set_zombie_var( "zombie_perk_cost",		2000 );

	// this map uses atleast 1 perk machine
	array_thread( vending_triggers, ::vending_trigger_think );
	array_thread( vending_triggers, :: electric_perks_dialog);

	level thread turn_sleight_on();
	level thread turn_revive_on();
	level thread turn_jugger_on();
	level thread turn_doubletap_on();
	level thread machine_watcher();
	level.speed_jingle = 0;
	level.revive_jingle = 0;
	level.doubletap_jingle = 0;
	level.jugger_jingle = 0;
	
}
turn_sleight_on()
{
	machine = getent("vending_sleight", "targetname");
	level waittill("sleight_on");
	machine setmodel("zombie_vending_sleight_on");
	machine vibrate((0,-100,0), 0.3, 0.4, 3);
	machine playsound("perks_power_on");
	timer = 0;
	duration = 0.05;

	level notify( "specialty_fastreload_power_on" );

	while(true)
	{
		machine thread vending_machine_flicker_light("sleight_light", duration);
		timer += duration;
		duration += 0.1;
		if(timer >= 3)
		{
			break;
		}
		wait(duration);
	}

	playfxontag(level._effect["sleight_light"], machine, "tag_origin");

}

turn_revive_on()
{
	machine = getent("vending_revive", "targetname");
	level waittill("revive_on");
	machine setmodel("zombie_vending_revive_on");
	machine playsound("perks_power_on");
	machine vibrate((0,-100,0), 0.3, 0.4, 3);
	timer = 0;
	duration = 0.05;

	level notify( "specialty_quickrevive_power_on" );

	while(true)
	{
		machine thread vending_machine_flicker_light("revive_light", duration);
		timer += duration;
		duration += 0.1;
		if(timer >= 3)
		{
			break;
		}
		wait(duration);
	}


	playfxontag(level._effect["revive_light"], machine, "tag_origin");

}

turn_jugger_on()
{
	machine = getent("vending_jugg", "targetname");
	//temp until I can get the wire to jugger.
	level waittill("juggernog_on");
	machine setmodel("zombie_vending_jugg_on");
	machine vibrate((0,-100,0), 0.3, 0.4, 3);
	machine playsound("perks_power_on");
	timer = 0;
	duration = 0.05;

	level notify( "specialty_armorvest_power_on" );

	while(true)
	{
		machine thread vending_machine_flicker_light("jugger_light", duration);
		timer += duration;
		duration += 0.1;
		if(timer >= 3)
		{
			break;
		}
		wait(duration);
	}

	playfxontag(level._effect["jugger_light"], machine, "tag_origin");

}
turn_doubletap_on()
{
	machine = getent("vending_doubletap", "targetname");
	level waittill("doubletap_on");
	machine setmodel("zombie_vending_doubletap_on");
	machine vibrate((0,-100,0), 0.3, 0.4, 3);
	machine playsound("perks_power_on");
	timer = 0;
	duration = 0.05;

	level notify( "specialty_rof_power_on" );

	while(true)
	{
		machine thread vending_machine_flicker_light("doubletap_light", duration);
		timer += duration;
		duration += 0.1;
		if(timer >= 3)
		{
			break;
		}
		wait(duration);
	}

	playfxontag(level._effect["doubletap_light"], machine, "tag_origin");

}


vending_machine_flicker_light(fx_light, duration)
{
	fxObj = spawn( "script_model", self.origin +( 0, 0, 0 ) ); 
	fxobj setmodel( "tag_origin" ); 
	fxobj.angles = self.angles; 
	playfxontag( level._effect[fx_light], fxObj, "tag_origin"  ); 
	fxObj playloopsound ("elec_current_loop");
	playsoundatposition("perks_rattle", fxObj.origin);
	wait(duration);
	fxobj stoploopsound();
	fxobj delete();

}
electric_perks_dialog()
{

	self endon ("warning_dialog");
	level endon("switch_flipped");
	timer =0;
	while(1)
	{
		wait(0.5);
		players = get_players();
		for(i = 0; i < players.size; i++)
		{		
			dist = distancesquared(players[i].origin, self.origin );
			if(dist > 70*70)
			{
				timer = 0;
				continue;
			}
			if(dist < 70*70 && timer < 3)
			{
				wait(0.5);
				timer ++;
			}
			if(dist < 70*70 && timer == 3)
			{
				
				players[i] thread do_player_vo("vox_start", 5);	
				wait(3);				
				self notify ("warning_dialog");
				iprintlnbold("warning_given");
			}
		}
	}
}
vending_trigger_think()
{

	//self thread turn_cola_off();
	perk = self.script_noteworthy;
	self SetHintString( &"ZOMBIE_FLAMES_UNAVAILABLE" );
	self SetCursorHint( "HINT_NOICON" );
	self UseTriggerRequireLookAt();

	notify_name = perk + "_power_on";
	level waittill( notify_name );

	self thread check_player_has_perk(perk);
	self vending_set_hintstring(perk);
	for( ;; )
	{
		self waittill( "trigger", player );
		
		
		cost = level.zombie_vars["zombie_perk_cost"];
		switch( perk )
		{
		case "specialty_armorvest":
			cost = 2500;
			break;

		case "specialty_quickrevive":
			cost = 1500;
			break;

		case "specialty_fastreload":
			cost = 3000;
			break;

		case "specialty_rof":
			cost = 2000;
			break;

		}

		if (player maps\_laststand::player_is_in_laststand() )
		{
			continue;
		}

		if(player in_revive_trigger())
		{
			continue;
		}

		if ( player HasPerk( perk ) )
		{
			cheat = false;

			/#
			if ( GetDVarInt( "zombie_cheat" ) >= 5 )
			{
				cheat = true;
			}
			#/

			if ( cheat != true )
			{
				//player iprintln( "Already using Perk: " + perk );
				self playsound("deny");
				continue;
			}
		}

		if ( player.score < cost )
		{
			//player iprintln( "Not enough points to buy Perk: " + perk );
			self playsound("deny");
			continue;
		}

		sound = "bottle_dispense3d";
		playsoundatposition(sound, self.origin);
		///bottle_dispense
		switch( perk )
		{
		case "specialty_armorvest":
			sound = "mx_jugger_sting";
			break;

		case "specialty_quickrevive":
			sound = "mx_revive_sting";
			break;

		case "specialty_fastreload":
			sound = "mx_speed_sting";
			break;

		case "specialty_rof":
			sound = "mx_doubletap_sting";
			break;

		default:
			sound = "mx_jugger_sting";
			break;
		}
	
		self thread play_vendor_stings(sound);
	
		//		self waittill("sound_done");


		// do the drink animation
		gun = player perk_give_bottle_begin( perk );
		player.is_drinking = 1;
		player waittill_any( "fake_death", "death", "player_downed", "weapon_change_complete" );

		// restore player controls and movement
		player perk_give_bottle_end( gun, perk );
		player.is_drinking = undefined;
		// TODO: race condition?
		if ( player maps\_laststand::player_is_in_laststand() )
		{
			continue;
		}

		player SetPerk( perk );
		player thread perk_vo(perk);
		player setblur( 4, 0.1 );
		wait(0.1);
		player setblur(0, 0.1);
		//earthquake (0.4, 0.2, self.origin, 100);
		if(perk == "specialty_armorvest")
		{
			player.maxhealth = 160;
			player.health = 160;
			//player.health = 160;
		}
		else
		{

			//fake effect here.
			//temp_maxhealth = player.maxhealth;
			//temp_health = player.health;

			//player.maxhealth = 160;
			////wait(0.1);
			//wait(0.5);
			//player.maxhealth = temp_health;
			//player.health = temp_health; 

		}

		player maps\_zombiemode_score::minus_to_player_score( cost ); 
		player perk_hud_create( perk );

		//player iprintln( "Bought Perk: " + perk );

		player thread perk_think( perk );

	}
}

check_player_has_perk(perk)
{
	/#
		if ( GetDVarInt( "zombie_cheat" ) >= 5 )
		{
			return;
		}
#/

		dist = 128 * 128;
		while(true)
		{
			players = get_players();
			for( i = 0; i < players.size; i++ )
			{
				if(DistanceSquared( players[i].origin, self.origin ) < dist)
				{
					if(!players[i] hasperk(perk) && !(players[i] in_revive_trigger()))
					{
						self setvisibletoplayer(players[i]);
						//iprintlnbold("turn it off to player");

					}
					else
					{
						self SetInvisibleToPlayer(players[i]);
						//iprintlnbold(players[i].health);
					}
				}


			}

			wait(0.1);

		}

}


vending_set_hintstring( perk )
{
	switch( perk )
	{

	case "specialty_armorvest":
		self SetHintString( &"ZOMBIE_PERK_JUGGERNAUT" );
		break;

	case "specialty_quickrevive":
		self SetHintString( &"ZOMBIE_PERK_QUICKREVIVE" );
		break;

	case "specialty_fastreload":
		self SetHintString( &"ZOMBIE_PERK_FASTRELOAD" );
		break;

	case "specialty_rof":
		self SetHintString( &"ZOMBIE_PERK_DOUBLETAP" );
		break;

	default:
		self SetHintString( perk + " Cost: " + level.zombie_vars["zombie_perk_cost"] );
		break;

	}
}

perk_think( perk )
{
	/#
		if ( GetDVarInt( "zombie_cheat" ) >= 5 )
		{
			if ( IsDefined( self.perk_hud[ perk ] ) )
			{
				return;
			}
		}
#/

		self waittill_any( "fake_death", "death", "player_downed", "second_chance" );

		self UnsetPerk( perk );
		self.maxhealth = 100;
		self perk_hud_destroy( perk );
		//self iprintln( "Perk Lost: " + perk );
}


perk_hud_create( perk )
{
	if ( !IsDefined( self.perk_hud ) )
	{
		self.perk_hud = [];
	}

	/#
		if ( GetDVarInt( "zombie_cheat" ) >= 5 )
		{
			if ( IsDefined( self.perk_hud[ perk ] ) )
			{
				return;
			}
		}
#/


		shader = "";

		switch( perk )
		{
		case "specialty_armorvest":
			shader = "specialty_juggernaut_zombies";
			break;

		case "specialty_quickrevive":
			shader = "specialty_quickrevive_zombies";
			break;

		case "specialty_fastreload":
			shader = "specialty_fastreload_zombies";
			break;

		case "specialty_rof":
			shader = "specialty_doubletap_zombies";
			break;

		default:
			shader = "";
			break;
		}

		hud = create_simple_hud( self );
		hud.foreground = true; 
		hud.sort = 1; 
		hud.hidewheninmenu = false; 
		hud.alignX = "left"; 
		hud.alignY = "bottom";
		hud.horzAlign = "left"; 
		hud.vertAlign = "bottom";
		hud.x = self.perk_hud.size * 30; 
		hud.y = hud.y - 70; 
		hud.alpha = 1;
		hud SetShader( shader, 24, 24 );

		self.perk_hud[ perk ] = hud;
}


perk_hud_destroy( perk )
{
	self.perk_hud[ perk ] destroy_hud();
	self.perk_hud[ perk ] = undefined;
}

perk_give_bottle_begin( perk )
{
	self DisableOffhandWeapons();
	self DisableWeaponCycling();

	self AllowLean( false );
	self AllowAds( false );
	self AllowSprint( false );
	self AllowProne( false );		
	self AllowMelee( false );

	if ( self GetStance() == "prone" )
	{
		self SetStance( "crouch" );
	}

	gun = self GetCurrentWeapon();
	weapon = "";

	switch( perk )
	{
	case "specialty_armorvest":
		weapon = "zombie_perk_bottle_jugg";
		break;

	case "specialty_quickrevive":
		weapon = "zombie_perk_bottle_revive";
		break;

	case "specialty_fastreload":
		weapon = "zombie_perk_bottle_sleight";
		break;

	case "specialty_rof":
		weapon = "zombie_perk_bottle_doubletap";
		break;
	}

	self GiveWeapon( weapon );
	self SwitchToWeapon( weapon );

	return gun;
}


perk_give_bottle_end( gun, perk )
{
	assert( gun != "zombie_perk_bottle_doubletap" );
	assert( gun != "zombie_perk_bottle_revive" );
	assert( gun != "zombie_perk_bottle_jugg" );
	assert( gun != "zombie_perk_bottle_sleight" );
	assert( gun != "syrette" );

	self EnableOffhandWeapons();
	self EnableWeaponCycling();

	self AllowLean( true );
	self AllowAds( true );
	self AllowSprint( true );
	self AllowProne( true );		
	self AllowMelee( true );
	weapon = "";
	switch( perk )
	{
	case "specialty_armorvest":
		weapon = "zombie_perk_bottle_jugg";
		break;

	case "specialty_quickrevive":
		weapon = "zombie_perk_bottle_revive";
		break;

	case "specialty_fastreload":
		weapon = "zombie_perk_bottle_sleight";
		break;

	case "specialty_rof":
		weapon = "zombie_perk_bottle_doubletap";
		break;
	}

	// TODO: race condition?
	if ( self maps\_laststand::player_is_in_laststand() )
	{
		self TakeWeapon(weapon);
		return;
	}

	if ( gun != "none" )
	{
		self SwitchToWeapon( gun );
	}
	else 
	{
		// try to switch to first primary weapon
		primaryWeapons = self GetWeaponsListPrimaries();
		if( IsDefined( primaryWeapons ) && primaryWeapons.size > 0 )
		{
			self SwitchToWeapon( primaryWeapons[0] );
		}
	}

	self TakeWeapon(weapon);
}

perk_vo(type)
{
	self endon("death");
	self endon("disconnect");

	index = maps\_zombiemode_weapons::get_player_index(self);
	sound = undefined;

	if(!isdefined (level.player_is_speaking))
	{
		level.player_is_speaking = 0;
	}

	//wait(randomfloatrange(1,2));

	switch(type)
	{
	case "specialty_armorvest":
		sound = "plr_" + index + "_vox_drink_jugga";
		break;
	case "specialty_fastreload":
		sound = "plr_" + index + "_vox_drink_speed";
		break;
	case "specialty_quickrevive":
		sound = "plr_" + index + "_vox_drink_revive";
		break;
	case "specialty_rof":
		sound = "plr_" + index + "_vox_drink_double";
		break; 		
	}

	//This keeps multiple voice overs from playing on the same player (both killstreaks and headshots).
	if (level.player_is_speaking != 1 && isDefined(sound))
	{	
		level.player_is_speaking = 1;
		self playsound(sound, "sound_done");			
		self waittill("sound_done");
		level.player_is_speaking = 0;
	}	


}
machine_watcher()
{
	level waittill("master_switch_activated");
	array_thread(getstructarray( "perksacola", "targetname" ), ::perks_a_cola_jingle);
}
play_vendor_stings(sound)
{	
	if(!IsDefined (level.speed_jingle))
	{
		level.speed_jingle = 0;
	}
	if(!IsDefined (level.revive_jingle))
	{
		level.revive_jingle = 0;
	}
	if(!IsDefined (level.doubletap_jingle))
	{
		level.doubletap_jingle = 0;
	}
	if(!IsDefined (level.jugger_jingle))
	{
		level.jugger_jingle = 0;
	}
	if(!IsDefined (level.eggs))
	{
		level.eggs = 0;
	}
	if (level.eggs == 0)
	{
		if(sound == "mx_speed_sting" && level.speed_jingle == 0 ) 
		{
//			iprintlnbold("stinger speed:" + level.speed_jingle);
			level.speed_jingle = 1;		
			temp_org_speed_s = spawn("script_origin", self.origin);		
			temp_org_speed_s playsound (sound, "sound_done");
			temp_org_speed_s waittill("sound_done");
			level.speed_jingle = 0;
			temp_org_speed_s delete();
//			iprintlnbold("stinger speed:" + level.speed_jingle);
		}
		else if(sound == "mx_revive_sting" && level.revive_jingle == 0)
		{
			level.revive_jingle = 1;
//			iprintlnbold("stinger revive:" + level.revive_jingle);
			temp_org_revive_s = spawn("script_origin", self.origin);		
			temp_org_revive_s playsound (sound, "sound_done");
			temp_org_revive_s waittill("sound_done");
			level.revive_jingle = 0;
			temp_org_revive_s delete();
//			iprintlnbold("stinger revive:" + level.revive_jingle);
		}
		else if(sound == "mx_doubletap_sting" && level.doubletap_jingle == 0) 
		{
			level.doubletap_jingle = 1;
//			iprintlnbold("stinger double:" + level.doubletap_jingle);
			temp_org_dp_s = spawn("script_origin", self.origin);		
			temp_org_dp_s playsound (sound, "sound_done");
			temp_org_dp_s waittill("sound_done");
			level.doubletap_jingle = 0;
			temp_org_dp_s delete();
//			iprintlnbold("stinger double:" + level.doubletap_jingle);
		}
		else if(sound == "mx_jugger_sting" && level.jugger_jingle == 0) 
		{
			level.jugger_jingle = 1;
//			iprintlnbold("stinger juggernog" + level.jugger_jingle);
			temp_org_jugs_s = spawn("script_origin", self.origin);		
			temp_org_jugs_s playsound (sound, "sound_done");
			temp_org_jugs_s waittill("sound_done");
			level.jugger_jingle = 0;
			temp_org_jugs_s delete();
//			iprintlnbold("stinger juggernog:"  + level.jugger_jingle);
		}
	}
}
perks_a_cola_jingle()
{	
	perk_hum = spawn("script_origin", self.origin);
	perk_hum playloopsound("perks_machine_loop");
	self thread play_random_broken_sounds();
	if(!IsDefined(self.perk_jingle_playing))
	{
		self.perk_jingle_playing = 0;
	}
	if (!IsDefined (level.eggs))
	{
		level.eggs = 0;
	}
	while(1)
	{
		wait(randomfloatrange(60, 120));
		//wait(randomfloatrange(31,45));
		if(randomint(100) < 15 && level.eggs == 0)
		{
			level notify ("jingle_playing");
			playfx (level._effect["electric_short_oneshot"], self.origin);
			playsoundatposition ("electrical_surge", self.origin);
			
			if(self.script_sound == "mx_speed_jingle" && level.speed_jingle == 0) 
			{
				level.speed_jingle = 1;
				temp_org_speed = spawn("script_origin", self.origin);
				temp_org_speed playsound (self.script_sound, "sound_done");
				temp_org_speed waittill("sound_done");
				level.speed_jingle = 0;
				temp_org_speed delete();
			}
			if(self.script_sound == "mx_revive_jingle" && level.revive_jingle == 0) 
			{
				level.revive_jingle = 1;
				temp_org_revive = spawn("script_origin", self.origin);
				temp_org_revive playsound (self.script_sound, "sound_done");
				temp_org_revive waittill("sound_done");
				level.revive_jingle = 0;
				temp_org_revive delete();
			}
			if(self.script_sound == "mx_doubletap_jingle" && level.doubletap_jingle == 0) 
			{
				level.doubletap_jingle = 1;
				temp_org_doubletap = spawn("script_origin", self.origin);
				temp_org_doubletap playsound (self.script_sound, "sound_done");
				temp_org_doubletap waittill("sound_done");
				level.doubletap_jingle = 0;
				temp_org_doubletap delete();
			}
			if(self.script_sound == "mx_jugger_jingle" && level.jugger_jingle == 0) 
			{
				level.jugger_jingle = 1;
				temp_org_jugger = spawn("script_origin", self.origin);
				temp_org_jugger playsound (self.script_sound, "sound_done");
				temp_org_jugger waittill("sound_done");
				level.jugger_jingle = 0;
				temp_org_jugger delete();
			}

			self thread play_random_broken_sounds();
		}		
	}	
}
play_random_broken_sounds()
{
	level endon ("jingle_playing");
	if (!isdefined (self.script_sound))
	{
		self.script_sound = "null";
	}
	if (self.script_sound == "mx_revive_jingle")
	{
		while(1)
		{
			wait(randomfloatrange(7, 18));
			playsoundatposition ("broken_random_jingle", self.origin);
			playfx (level._effect["electric_short_oneshot"], self.origin);
			playsoundatposition ("electrical_surge", self.origin);
	
		}
	}
	else
	{
		while(1)
		{
			wait(randomfloatrange(7, 18));
			playfx (level._effect["electric_short_oneshot"], self.origin);
			playsoundatposition ("electrical_surge", self.origin);
		}
	}
}


