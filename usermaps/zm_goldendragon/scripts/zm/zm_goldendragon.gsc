#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_perk_electric_cherry;
//#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perks;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;
#using scripts\zm\_hb21_zm_magicbox;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	zm_usermap::main();
	
	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;

	//Starting Weapon
	 startingWeapon = "pistol_revolver38";
	 weapon = getWeapon(startingWeapon);
	 level.start_weapon = (weapon);//Starting Weapon
	 IPrintLn("frogs");
	 level thread perk_threads();

	 level thread free_sode_ee();
	 foreach (player in GetPlayers()) {
	 	player zm_score::add_to_player_score(50000);
	 }
}

function usermap_test_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );

	zm_zonemgr::add_adjacent_zone("start_zone", "zone_2", "activate_zone_2");
	zm_zonemgr::add_adjacent_zone("start_zone", "zone_6", "activate_zone_6");
	zm_zonemgr::add_adjacent_zone("zone_6", "zone_5", "activate_zone_5");
	zm_zonemgr::add_adjacent_zone("zone_5", "zone_6", "activate_zone_6b");
	zm_zonemgr::add_adjacent_zone("zone_5", "zone_2", "activate_zone_2b");
	zm_zonemgr::add_adjacent_zone("zone_2", "zone_5", "activate_zone_5b");
	zm_zonemgr::add_adjacent_zone("zone_2", "zone_3", "activate_zone_3");
	zm_zonemgr::add_adjacent_zone("zone_2", "zone_4", "activate_zone_4");
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function perk_threads()
{
    // perk_trig, specialtyname, cost, string name
    quick_revive = GetEnt( "quick_rev", "targetname" );
    quick_revive thread specialty_count_handler( "specialty_quickrevive", 1500, "Quick Revive" );

    quick_revive_damage = GetEnt("quick_rev_damage", "targetname");
    quick_revive_damage thread perk_damage_handler("quick_rev", "quick_rev_light", "quick_revive");

	 IPrintLn("frogs3");
    //callback::on_connect(&notify_joined);

	 IPrintLn("frog4");
    thread perk_trig( "jugg_loc_bmt", "specialty_armorvest", 2500 , "Juggernog" );
    speed_cola_damage = GetEnt("jugg_damage", "targetname");
    speed_cola_damage thread perk_damage_handler("jugg_loc_bmt", "jugg_light", "juggernog");
   
    thread perk_trig( "double_tap_loc", "specialty_doubletap2", 2000 , "Double Tap" );
    speed_cola_damage = GetEnt("double_tap_damage", "targetname");
    speed_cola_damage thread perk_damage_handler("double_tap_loc", "double_tap_light", "double_tap");
    
    thread perk_trig( "speed_loc_bmt", "specialty_fastreload", 3000, "Speed Cola" );
    speed_cola_damage = GetEnt("speed_damage", "targetname");
    speed_cola_damage thread perk_damage_handler("speed_loc_bmt", "speed_cola_light", "speed_cola");

    thread perk_trig( "mule_kick_loc", "specialty_additionalprimaryweapon", 4000, "Mule Kick" );
    speed_cola_damage = GetEnt("mule_kick_damage", "targetname");
    speed_cola_damage thread perk_damage_handler("mule_kick_loc", "mule_kick_light", "mule_kick");

    thread perk_trig( "widows_wine_loc", "specialty_widowswine", 4000, "Widow's Wine" );
    speed_cola_damage = GetEnt("widows_wine_damage", "targetname");
    speed_cola_damage thread perk_damage_handler("widows_wine_loc", "widows_wine_light", "widows_wine");


    thread perk_trig( "electric_cherry_loc", "specialty_electriccherry", 2500, "Electric Cherry" );
    speed_cola_damage = GetEnt("electric_cherry_damage", "targetname");
    speed_cola_damage thread perk_damage_handler("electric_cherry_loc", "electric_cherry_light");

	thread soda_machine_info();
}

function perk_damage(perk_damage_trigger, perk_trigger)
{
	damagetrig = GetEnt(perk_damage_trigger, "targetname");
	damagetrig thread perk_damage(perk_trigger);
}

function soda_machine_info()
{
	sodatrig = GetEnt("soda_machine", "targetname");
	sodatrig SetHintString(&"ZOMBIE_NEED_POWER");
	level waittill("power_on");
	sodatrig SetHintString("hit a perk to activate");

}

function perk_damage_handler(perk_trigger, light_exploder_name, song_name)
{

    level waittill("power_on");
	perktrig = GetEnt(perk_trigger, "targetname");
	perktrig TriggerEnable(false);
	for (;;)
	{
		self waittill("trigger", player);
		//enable perk
		perktrig TriggerEnable(true);
		exploder::exploder(light_exploder_name);
		PlaySoundAtPosition(song_name, self.origin);
		//perktrig = GetEnt(perk_trigger, "targetname");
		wait 17;
		perktrig TriggerEnable(false);
		//disable perk

		exploder::kill_exploder(light_exploder_name);
	}
}

function perk_trig(perk_trigger, specialtyname, cost, name)
{
	perktrig = GetEnt(perk_trigger, "targetname");
	 perktrig thread perk_handler(specialtyname, cost, name);

}

function perk_handler( specialtyname, cost, perkname )
{
    self SetHintString(&"ZOMBIE_NEED_POWER");
    self SetCursorHint("HINT_NOICON");
    //self UseTriggerRequireLookAt();
    
    level waittill("power_on");
    
    self SetHintString("Press ^1[{+activate}]^7 to purchase " + perkname + "\n^2[ Cost = " + int( cost ) + " ]");
    self SetCursorHint("HINT_NOICON");

    for( ;; )
    {
        self waittill("trigger", player);
        if(!player HasPerk( specialtyname ) )
        {
            if( player zm_score::can_player_purchase( int( cost ) ) )
            {
                player zm_score::minus_to_player_score( int( cost ) );
                player PlaySoundToPlayer( "zmb_cha_ching", player );
                player thread do_perk_buy( specialtyname, player );
                player PlaySoundToPlayer("belch", player);
                PlayFX( level._effect[ "powerup_grabbed" ], self.origin );
              //  thread devprint(" GAVE " + specialtyname + "");
            }
            else
            {
                PlayFX( level._effect[ "powerup_grabbed" ], self.origin );
            }
        }
        else
        {
           // thread devprint(" HAS PERK ");
            self TriggerEnable( false );
            player playsoundtoplayer("evt_perk_deny", player);
            wait 3;
            self TriggerEnable( true );
        }
    }
}

function do_perk_buy( perk, player )
{
    gun = player zm_perks::perk_give_bottle_begin( perk );
    evt = player util::waittill_any_return( "fake_death", "death", "player_downed", "weapon_change_complete", "perk_abort_drinking", "disconnect" );
    if ( evt == "weapon_change_complete" )
    {
        player thread zm_perks::wait_give_perk( perk, true );
    }
    player zm_perks::perk_give_bottle_end( gun, perk );
    if ( player laststand::player_is_in_laststand() || IS_TRUE( player.intermission ) )
    {
        return;
    }
    player notify( "burp" );
}

function specialty_count_handler ( specialtyname, cost, perkname )
{
	level endon ("disconnect");
    self UseTriggerRequireLookAt();
    self TriggerEnable(false);
    level waittill("power_on");
    //self TriggerEnable(true);
	self SetHintString("Press ^1[{+activate}]^7 to purchase " + perkname + "\n^7[ ^2Cost = ^7" + cost + " ^7]\n [ ^1Solo =  ^7" + int( cost / 3 ) + " ^7]");
	self SetCursorHint("HINT_NOICON");

	level.solo_purchased = 0;

	for( ;; )
	{
		self waittill( "trigger", player );	
		if( !player HasPerk( specialtyname ) )
		{
			if( GetPlayers().size == 1 )
			{
				if( player zm_score::can_player_purchase( int(cost / 3) ) )
				{
					player zm_score::minus_to_player_score( int(cost / 3) );
					PlayFX( level._effect[ "powerup_grabbed" ], self.origin );
					player PlaySoundToPlayer("zmb_cha_ching", player);
					player do_perk_buy( specialtyname, player );
					player PlaySoundToPlayer("belch", player);
					//thread devprint( " SOLO GAVE " + specialtyname + "" );

					level.solo_purchased++;

					if( level.solo_purchased >= 3 )
					{
						self TriggerEnable(false);
						PlayFX( level._effect[ "powerup_grabbed" ], self.origin );
						wait 3;
						level waittill("player_connected");
						self TriggerEnable(true);
					}
				}
			} 
			else
			{
				if( level flag::get("power_on" ) )
				{
					if( player zm_score::can_player_purchase( int( cost ) ) )
					{
						player zm_score::can_player_purchase( int( cost ) );
						PlayFX( level._effect[ "powerup_grabbed" ], self.origin );
						player PlaySoundToPlayer( "zmb_cha_ching", player );					
						player do_perk_buy( specialtyname, player );
						player PlaySoundToPlayer("belch", player);
						self SetIgnoreEntForTrigger(player);
					//	thread devprint( " GAVE " + specialtyname + "" );
					}
					else
					{
						PlayFX( level._effect[ "powerup_grabbed_red" ], self.origin );
						//thread devprint(" NOT GAVE " + specialtyname + "");
					}
				}
				else
				{
					self SetHintString(&"ZOMBIE_NEED_POWER");

					wait 5;

					Self SetHintString("Press ^1[{+activate}]^7 to purchase " + perkname + "\n^7[ ^2Cost = ^7" + cost + " ^7]\n [ ^1Solo =  ^7" + int( cost / 3 ) + " ^7]");
						continue;
				}
			}
		}
		else
		{
			//thread devprint(" HAS PERK ");
			self TriggerEnable( false );
			player playsoundtoplayer("evt_perk_deny", player);
			wait 3;
			self TriggerEnable( true );
		}
	}
}

function free_sode_ee()
{
	trigs = GetEntArray("free_soda_trig", "targetname");
	level.free_sodas_obtained = 0;
	foreach(trig in trigs)
	{
		trig thread free_soda_trig();
	}
}

function free_soda_trig()
{
	self SetHintString("Hold ^3[{+activate}]^7 to activate");
	self UseTriggerRequireLookAt();
	self waittill("trigger", player);
	level.free_sodas_obtained++;
	
	if (level.free_sodas_obtained == 3)
	{
		IPrintLn("You obtained THE ONE PIECE: A Free Soda from Golden Dragon!!!!");
		self PlaySound("one_piece");
		//Spawn powerup
		spawn_loc = struct::Get("free_soda_spawn", "targetname");
		zm_powerups::specific_powerup_drop("free_perk", spawn_loc.origin);
		wait 1;
		IPrintLn("Grab your free soda at the fountain. The one piece truly was the free soda we got along the way.");
		
		self SetHintString("Press ^3[{+activate}]^7 to play one piece again?");
		for (;;)
		{
			self waittill("trigger", player);
			self PlaySound("one_piece");
		}
	} else if (level.free_sodas_obtained < 3)
	{
		IPrintLn("You have obtained a free soda. Find "  + (3 - level.free_sodas_obtained) + " more");
		self Delete();

	}
}