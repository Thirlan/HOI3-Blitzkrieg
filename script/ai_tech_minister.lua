-----------------------------------------------------------
-- LUA Hearts of Iron 3 Research File
-- Created By: Lothos
-- Modified By: Thirlan
-- Date Last Modified: 9/17/2011
-----------------------------------------------------------
require('custom_ai_support_functions')
require('custom_ai_tech_minister')

-- Techs that are used in the main file to be ignored
--   techname|level (level must be 1-9 a 0 means ignore all
--   these local variables can be overiden in the country specific files
--   use as the first tech name the word "all" and it will cause the AI to ignore all the techs

-- Index IDs for the main Research areas
local _RESEARCH_LAND_ = 1
local _RESEARCH_LAND_DOC_ = 2
local _RESEARCH_AIR_ = 3
local _RESEARCH_AIR_DOC_ = 4
local _RESEARCH_NAVAL_ = 5
local _RESEARCH_NAVAL_DOC_ = 6
local _RESEARCH_INDUSTRIAL_ = 7
local _RESEARCH_SECRET_ = 8
local _RESEARCH_UNKNOWN_ = 9

-- Countries with a port and 20+ IC or is a Major
local DefaultMixTechs = {
	ResearchWeight = {0.20, -- _RESEARCH_LAND_
		0.09, -- _RESEARCH_LAND_DOC_
		0.12, -- _RESEARCH_AIR_
		0.15, -- _RESEARCH_AIR_DOC_
		0.18, -- _RESEARCH_NAVAL_
		0.10, -- _RESEARCH_NAVAL_DOC_
		0.14, -- _RESEARCH_INDUSTRIAL_
		0.00, -- _RESEARCH_SECRET_
		0.02 -- _RESEARCH_UNKNOWN_
	},
	LandTechs = {
		ignoreTech = {{"cavalry_smallarms", 3}, 
			{"cavalry_support", 3},
			{"cavalry_guns", 3}, 
			{"cavalry_at", 3},
			{"militia_smallarms", 0},
			{"militia_support", 0},
			{"militia_guns", 0},
			{"militia_at", 0},
			{"armored_car_armour", 0},
			{"armored_car_gun", 0},
			{"paratrooper_infantry", 0},
			{"marine_infantry", 0},
			{"imporved_police_brigade", 0},
			{"desert_warfare_equipment", 0},
			{"jungle_warfare_equipment", 0},
			{"artic_warfare_equipment", 0},
			{"amphibious_warfare_equipment", 0},
			{"airborne_warfare_equipment", 0},
			{"lighttank_brigade", 0},
			{"lighttank_gun", 0},
			{"lighttank_engine", 0},
			{"lighttank_armour", 0},
			{"lighttank_reliability", 0},
			{"tank_brigade", 0},
			{"tank_gun", 0},
			{"tank_engine", 0},
			{"tank_armour", 0},
			{"tank_reliability", 0},
			{"heavy_tank_brigade", 0},
			{"heavy_tank_gun", 0},
			{"heavy_tank_engine", 0},
			{"heavy_tank_armour", 0},
			{"heavy_tank_reliability", 0},
			{"SP_brigade", 0},
			{"mechanised_infantry", 0},
			{"super_heavy_tank_brigade", 0},
			{"super_heavy_tank_gun", 0},
			{"super_heavy_tank_engine", 0},
			{"super_heavy_tank_armour", 0},
			{"super_heavy_tank_reliability", 0},
			{"rocket_art", 0},
			{"rocket_art_ammo", 0},
			{"rocket_carriage_sights", 0}},
		preferTech = {"infantry_activation",
			"smallarms_technology",
			"infantry_support",
			"infantry_guns",
			"infantry_at",
			"art_barrell_ammo",
			"art_carriage_sights"}
	},
	LandDoctrinesTechs = {
		ignoreTech = {{"mobile_warfare", 0},
			{"elastic_defence", 0},
			{"spearhead_doctrine", 0},
			{"schwerpunkt", 0},
			{"blitzkrieg", 0},
			{"operational_level_command_structure", 0},
			{"tactical_command_structure", 0},
			{"delay_doctrine", 0},
			{"integrated_support_doctrine", 0},
			{"superior_firepower", 0},
			{"mechanized_offensive", 0},
			{"combined_arms_warfare", 0},
			{"grand_battle_plan", 3},
			{"large_front", 3},
			{"peoples_army", 0},
			{"large_formations", 0}},
		preferTech = {"infantry_warfare",
			"central_planning",
			"mass_assault",
			"guerilla_warfare"}
	},
	AirTechs = {
		ignoreTech = {{"basic_four_engine_airframe", 0},
			{"basic_strategic_bomber", 0},
			{"large_fueltank", 0},
			{"four_engine_airframe", 0},
			{"strategic_bomber_armament", 0},
			{"cargo_hold", 0},
			{"large_bomb", 0},
			{"advanced_aircraft_design", 0},
			{"small_airsearch_radar", 0},
			{"medium_airsearch_radar", 0},
			{"large_airsearch_radar", 0},
			{"small_navagation_radar", 0},
			{"medium_navagation_radar", 0},
			{"large_navagation_radar", 0},
			{"rocket_interceptor_tech", 0},
			{"drop_tanks", 0},
			{"jet_engine", 0}},
		preferTech = {"single_engine_aircraft_design",
			"basic_aeroengine",
			"basic_small_fueltank",
			"basic_single_engine_airframe",
			"basic_aircraft_machinegun",
			"multi_role_fighter_development",
			"twin_engine_aircraft_design",
			"basic_medium_fueltank",
			"basic_twin_engine_airframe",
			"basic_bomb"}
	},
	AirDoctrineTechs = {
		ignoreTech = {{"forward_air_control", 0},
			{"battlefield_interdiction", 0},
			{"bomber_targerting_focus", 0},
			{"fighter_targerting_focus", 0}, 
			{"heavy_bomber_pilot_training", 0},
			{"heavy_bomber_groundcrew_training", 0},
			{"strategic_bombardment_tactics", 0},
			{"airborne_assault_tactics", 0},
			{"strategic_air_command", 0}},
		preferTech = {"fighter_pilot_training",
			"interception_tactics",
			"cas_pilot_training",
			"cas_groundcrew_training",
			"ground_attack_tactics",
			"tac_pilot_training",
			"interdiction_tactics",
			"tactical_air_command"}
	},
	NavalTechs = {
		ignoreTech = {{"heavycruiser_technology", 0},
			{"heavycruiser_armament", 0},
			{"heavycruiser_antiaircraft", 0},
			{"heavycruiser_engine", 0},
			{"heavycruiser_armour", 0},
			{"battlecruiser_technology", 0},
			{"battleship_technology", 0},
			{"capitalship_armament", 0},
			{"battlecruiser_antiaircraft", 0},
			{"battlecruiser_engine", 0},
			{"battlecruiser_armour", 0},
			{"battleship_antiaircraft", 0},
			{"battleship_engine", 0},
			{"battleship_armour", 0},
			{"super_heavy_battleship_technology", 0},
			{"cag_development", 0},
			{"escort_carrier_technology", 0},
			{"carrier_technology", 0},
			{"carrier_antiaircraft", 0},
			{"carrier_engine", 0},
			{"carrier_armour", 0},
			{"carrier_hanger", 0},
			{"largewarship_radar", 0}},
		preferTech = {"destroyer_technology",
			"destroyer_armament",
			"destroyer_antiaircraft",
			"destroyer_engine",
			"destroyer_armour"}
	},
	NavalDoctrineTechs = {
		ignoreTech = {{"carrier_group_doctrine", 0},
			{"carrier_crew_training", 0},
			{"carrier_task_force", 0},
			{"naval_underway_repleshment", 0},
			{"radar_training", 0},
			{"battlefleet_concentration_doctrine", 0},
			{"battleship_crew_training", 0},
			{"cruiser_warfare", 0},
			{"cruiser_crew_training", 0},
			{"basing", 0}},
		preferTech = {"sea_lane_defence",
			"destroyer_escort_role",
			"destroyer_crew_training",
			"commerce_defence",
			"fire_control_system_training",
			"commander_decision_making"}
	},
	IndustrialTechs = {
		ignoreTech = {{"oil_to_coal_conversion", 0},
			{"heavy_aa_guns", 0},
			{"radio_detection_equipment", 0},
			{"radar", 0},
			{"decryption_machine", 0},
			{"encryption_machine", 0},
			{"rocket_tests", 0},
			{"rocket_engine", 0},
			{"theorical_jet_engine", 0},
			{"atomic_research", 0},
			{"nuclear_research", 0},
			{"isotope_seperation", 0},
			{"civil_nuclear_research", 0},
			{"oil_refinning", 0},
			{"steel_production", 0},
			{"raremetal_refinning_techniques", 0},
			{"coal_processing_technologies", 0}},
		preferTech = {"agriculture",
			"industral_production",
			"industral_efficiency",
			"supply_production",
			"education"}
	},
	SecretWeaponTechs = {
		ignoreTech = {"all"},
		nil
	},
	OtherTechs = {
		ignoreTech = {{"naval_engineering_research", 0},
			{"submarine_engineering_research", 0},
			{"aeronautic_engineering_research", 0},
			{"rocket_science_research", 0},
			{"chemical_engineering_research", 0},
			{"nuclear_physics_research", 0},
			{"jetengine_research", 0},
			{"mechanicalengineering_research", 0},
			{"automotive_research", 0},
			{"electornicegineering_research", 0},
			{"artillery_research", 0},
			{"mobile_research", 0},
			{"militia_research", 0},
			{"infantry_research", 0},
			{"civil_defence", 0}},
		nil
	}
}

-- Land based countries
local DefaultLandTechs = {
	ResearchWeight = {0.30, -- _RESEARCH_LAND_
		0.15, -- _RESEARCH_LAND_DOC_
		0.20, -- _RESEARCH_AIR_
		0.15, -- _RESEARCH_AIR_DOC_
		0.0, -- _RESEARCH_NAVAL_
		0.0, -- _RESEARCH_NAVAL_DOC_
		0.15, -- _RESEARCH_INDUSTRIAL_
		0.00, -- _RESEARCH_SECRET_
		0.05 -- _RESEARCH_UNKNOWN_
	},
	LandTechs = {
		ignoreTech = {{"cavalry_smallarms", 3}, 
			{"cavalry_support", 3},
			{"cavalry_guns", 3}, 
			{"cavalry_at", 3},
			{"militia_smallarms", 3},
			{"militia_support", 3},
			{"militia_guns", 3},
			{"militia_at", 3},
			{"armored_car_armour", 3},
			{"armored_car_gun", 3},
			{"paratrooper_infantry", 3},
			{"marine_infantry", 3},
			{"imporved_police_brigade", 3},
			{"desert_warfare_equipment", 3},
			{"jungle_warfare_equipment", 3},
			{"artic_warfare_equipment", 3},
			{"amphibious_warfare_equipment", 3},
			{"airborne_warfare_equipment", 3},
			{"lighttank_brigade", 3},
			{"lighttank_gun", 3},
			{"lighttank_engine", 3},
			{"lighttank_armour", 3},
			{"lighttank_reliability", 3},
			{"tank_brigade", 3},
			{"tank_gun", 3},
			{"tank_engine", 3},
			{"tank_armour", 3},
			{"tank_reliability", 3},
			{"heavy_tank_brigade", 3},
			{"heavy_tank_gun", 3},
			{"heavy_tank_engine", 3},
			{"heavy_tank_armour", 3},
			{"heavy_tank_reliability", 3},
			{"SP_brigade", 3},
			{"mechanised_infantry", 3},
			{"super_heavy_tank_brigade", 3},
			{"super_heavy_tank_gun", 3},
			{"super_heavy_tank_engine", 3},
			{"super_heavy_tank_armour", 3},
			{"super_heavy_tank_reliability", 3},
			{"rocket_art", 3},
			{"rocket_art_ammo", 3},
			{"rocket_carriage_sights", 0}},
		preferTech = {"infantry_activation",
			"smallarms_technology",
			"infantry_support",
			"infantry_guns",
			"infantry_at",
			"art_barrell_ammo",
			"art_carriage_sights"}
	},
	LandDoctrinesTechs = {
		ignoreTech = {{"mobile_warfare", 3},
			{"elastic_defence", 3},
			{"spearhead_doctrine", 3},
			{"schwerpunkt", 3},
			{"blitzkrieg", 3},
			{"operational_level_command_structure", 3},
			{"tactical_command_structure", 3},
			{"delay_doctrine", 3},
			{"integrated_support_doctrine", 3},
			{"mechanized_offensive", 3},
			{"combined_arms_warfare", 3},
			{"grand_battle_plan", 3},
			{"large_front", 3},
			{"guerilla_warfare", 3},
			{"peoples_army", 3},
			{"large_formations", 0}},
		preferTech = {"infantry_warfare",
			"central_planning",
			"mass_assault",
			"guerilla_warfare"}
	},
	AirTechs = {
		ignoreTech = {{"nav_development", 3},
			{"basic_four_engine_airframe", 3},
			{"basic_strategic_bomber", 3},
			{"air_launched_torpedo", 3},
			{"large_fueltank", 3},
			{"four_engine_airframe", 3},
			{"strategic_bomber_armament", 3},
			{"cargo_hold", 3},
			{"large_bomb", 3},
			{"advanced_aircraft_design", 3},
			{"small_airsearch_radar", 3},
			{"medium_airsearch_radar", 3},
			{"large_airsearch_radar", 3},
			{"small_navagation_radar", 3},
			{"medium_navagation_radar", 3},
			{"large_navagation_radar", 3},
			{"rocket_interceptor_tech", 3},
			{"drop_tanks", 3},
			{"jet_engine", 0}},
		preferTech = {"single_engine_aircraft_design",
			"basic_aeroengine",
			"basic_small_fueltank",
			"basic_single_engine_airframe",
			"basic_aircraft_machinegun",
			"multi_role_fighter_development",
			"twin_engine_aircraft_design",
			"basic_medium_fueltank",
			"basic_twin_engine_airframe",
			"basic_bomb"}
	},
	AirDoctrineTechs = {
		ignoreTech = {{"forward_air_control", 3},
			{"battlefield_interdiction", 3},
			{"bomber_targerting_focus", 3},
			{"fighter_targerting_focus", 3}, 
			{"nav_pilot_training", 3},
			{"nav_groundcrew_training", 3},
			{"portstrike_tactics", 3},
			{"naval_air_targeting", 3},
			{"navalstrike_tactics", 3},
			{"naval_tactics", 3},
			{"heavy_bomber_pilot_training", 3},
			{"heavy_bomber_groundcrew_training", 3},
			{"strategic_bombardment_tactics", 3},
			{"airborne_assault_tactics", 3},
			{"strategic_air_command", 0}},
		preferTech = {"fighter_pilot_training",
			"interception_tactics",
			"cas_pilot_training",
			"cas_groundcrew_training",
			"ground_attack_tactics",
			"tac_pilot_training",
			"interdiction_tactics",
			"tactical_air_command"}
	},
	NavalTechs = {
		ignoreTech = {"all"},
		nil
	},	
	NavalDoctrineTechs = {
		ignoreTech = {"all"},
		nil
	},
	IndustrialTechs = {
		ignoreTech = {{"oil_to_coal_conversion", 3},
			{"heavy_aa_guns", 3},
			{"radio_detection_equipment", 3},
			{"radar", 3},
			{"decryption_machine", 3},
			{"encryption_machine", 3},
			{"rocket_tests", 3},
			{"rocket_engine", 3},
			{"theorical_jet_engine", 3},
			{"atomic_research", 3},
			{"nuclear_research", 3},
			{"isotope_seperation", 3},
			{"civil_nuclear_research", 3},
			{"oil_refinning", 3},
			{"steel_production", 3},
			{"raremetal_refinning_techniques", 3},
			{"coal_processing_technologies", 0}},
		preferTech = {"agriculture",
			"industral_production",
			"industral_efficiency",
			"supply_production",
			"education"}
	},
	SecretWeaponTechs = {
		ignoreTech = {"all"},
		nil
	},
	OtherTechs = {
		ignoreTech = {{"naval_engineering_research", 3},
			{"submarine_engineering_research", 3},
			{"aeronautic_engineering_research", 3},
			{"rocket_science_research", 3},
			{"chemical_engineering_research", 3},
			{"nuclear_physics_research", 3},
			{"jetengine_research", 3},
			{"mechanicalengineering_research", 3},
			{"automotive_research", 3},
			{"electornicegineering_research", 3},
			{"artillery_research", 3},
			{"mobile_research", 3},
			{"militia_research", 3},
			{"infantry_research", 3},
			{"civil_defence", 0}},
		nil
	}
}

--- END OF TECH DEFAULTS

-- ###################################
-- # Main Method called by the EXE
-- #####################################
function TechMinister_Tick(minister, set_sliders, set_research)
	--COUNTRY_DEBUG(minister:GetCountry(), "Determining Research AI to use.")
	
	-- Determine if we should use the MOD's Minor Countries AI logic instead of Paradox's
	-- We determine this by checking if the country is a major.
	local ministerCountry = minister:GetCountry()
	if IsMajorPower(ministerCountry) then
		TechMinister_Tick_Standard_AI(minister, set_sliders, set_research)
	else
		TechMinister_Tick_Modded_AI(minister, set_sliders, set_research)
	end
end

function TechMinister_Tick_Standard_AI(minister, set_sliders, set_research)
	local ministerTag = minister:GetCountryTag()
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()

	local ResearchSlotsAllowed = 0
	
	if set_sliders then
		-- Calling balance sliders like this allows me to get what the new Research slot count would be
		--    once the sliders are shifted
		ResearchSlotsAllowed = ministerCountry:GetTotalLeadership():Get() * BalanceLeadershipSliders(ai, ministerCountry)
	else
		-- Sliders already set by player
		ResearchSlotsAllowed = ministerCountry:GetAllowedResearchSlots()
	end
	
	if set_research then
		local ResearchSlotsNeeded = ResearchSlotsAllowed - ministerCountry:GetNumberOfCurrentResearch()
		
		Process_Tech((CCurrentGameState.GetCurrentDate():GetYear()), ResearchSlotsAllowed, ResearchSlotsNeeded, ai, minister, ministerCountry)
	end
end

-- Balances the research sliders	
-- NOTE: * If you adjust the percentage for LEADERSHIP_DIPLOMACY 
--    you must up the influence LUA code!
function BalanceLeadershipSliders(ai, ministerCountry)
	-- Setup default sliders
	local currentDiplomats = ministerCountry:GetDiplomaticInfluence():Get()
	local isMajor =  ministerCountry:IsMajor()
	local lbNCONeeded = false

	local LEADERSHIP_RESEARCH
	local LEADERSHIP_ESPIONAGE = 0.08
	local LEADERSHIP_DIPLOMACY = 0.15 -- * review NOTE
	local LEADERSHIP_NCO = 0.1
	
	-- Officer ratio.
	local officer_ratio = ministerCountry:GetOfficerRatio():Get()
		
	-- Checks to see if you are loosing officers
	--   if so take them from espionage and diplomacy
	if officer_ratio < 1.0 then
		-- Move the Espionage into the NCO and set it to 0 since we are short
		LEADERSHIP_NCO = 0.5 + LEADERSHIP_ESPIONAGE
		LEADERSHIP_ESPIONAGE = 0.0
		lbNCONeeded = true
	elseif officer_ratio < 1.05 then
		LEADERSHIP_NCO = 0.3
	elseif officer_ratio  < 1.2 then
		LEADERSHIP_NCO = 0.2
	
	-- Check to see if you have to many officers
	--    if so increase research
	elseif officer_ratio > 1.39 then
		LEADERSHIP_NCO = 0.0
	end
	
	-- AI is loosing to many diplomats double what the default is
	if currentDiplomats == 0 then
		LEADERSHIP_DIPLOMACY = LEADERSHIP_DIPLOMACY + LEADERSHIP_DIPLOMACY
	-- If the AI has to many diplomats then set it to 0 (100 is max you can have)
	-- If the NCO desperation is true try and shift diplomacy into NCO production instead of Research
	elseif isMajor then
		if currentDiplomats > 30 then
			if lbNCONeeded then
				LEADERSHIP_NCO = LEADERSHIP_NCO + LEADERSHIP_DIPLOMACY
			end
			
			LEADERSHIP_DIPLOMACY = 0
		elseif currentDiplomats > 25 then
			if lbNCONeeded then
				LEADERSHIP_NCO = LEADERSHIP_NCO + LEADERSHIP_DIPLOMACY
				LEADERSHIP_DIPLOMACY = 0
			else
				LEADERSHIP_DIPLOMACY = LEADERSHIP_DIPLOMACY / 4
			end
		elseif currentDiplomats > 20 then
			if lbNCONeeded then
				LEADERSHIP_NCO = LEADERSHIP_NCO + LEADERSHIP_DIPLOMACY
				LEADERSHIP_DIPLOMACY = 0
			else
				LEADERSHIP_DIPLOMACY = LEADERSHIP_DIPLOMACY / 2
			end
		end
	else
		if currentDiplomats > 20 then
			if lbNCONeeded then
				LEADERSHIP_NCO = LEADERSHIP_NCO + LEADERSHIP_DIPLOMACY
			end
			
			LEADERSHIP_DIPLOMACY = 0
		elseif currentDiplomats > 15 then
			if lbNCONeeded then
				LEADERSHIP_NCO = LEADERSHIP_NCO + LEADERSHIP_DIPLOMACY
				LEADERSHIP_DIPLOMACY = 0
			else
				LEADERSHIP_DIPLOMACY = LEADERSHIP_DIPLOMACY / 4
			end
		elseif currentDiplomats > 10 then
			if lbNCONeeded then
				LEADERSHIP_NCO = LEADERSHIP_NCO + LEADERSHIP_DIPLOMACY
				LEADERSHIP_DIPLOMACY = 0
			else
				LEADERSHIP_DIPLOMACY = LEADERSHIP_DIPLOMACY / 2
			end
		end	
	end
	
	-- Research is whatever is left over
	LEADERSHIP_RESEARCH = (((1 - LEADERSHIP_ESPIONAGE) - LEADERSHIP_DIPLOMACY) - LEADERSHIP_NCO)
	
	local command = CChangeLeadershipCommand( ministerCountry:GetCountryTag(), LEADERSHIP_NCO, LEADERSHIP_DIPLOMACY, LEADERSHIP_ESPIONAGE, LEADERSHIP_RESEARCH)
	ai:Post( command )
	
	return LEADERSHIP_RESEARCH
end

-- Processes the main tech reasearch for the specified country
--   designed to be a recursive call in case the AI needs to research in the future
function Process_Tech(pYear, ResearchSlotsAllowed, ResearchSlotsNeeded, ai, minister, ministerCountry)
	-- Performance check, exit if there are no slots available
	if ResearchSlotsNeeded < 0.01 then
		return
	end
	
	local ministerTag = minister:GetCountryTag()
	local techStatus = ministerCountry:GetTechnologyStatus()
	local vbLandBased = false
		
	--Utils.LUA_DEBUGOUT("Country: " .. tostring(ministerTag))
		
	local laPrimeTechAreas = {}
	laPrimeTechAreas[_RESEARCH_LAND_] = {Folder = {"infantry_folder",
										  "armour_folder"},
								ResearchWeight = 0, 
								CurrentSlots = 0, 
								ResearchSlots = 0, 
								RegularTech = {}, 
								PreferTech = {},
								ListName = "LandTechs",
								ListIgnore = {},
								ListPrefer = {}}
	laPrimeTechAreas[_RESEARCH_LAND_DOC_] = {Folder = {"land_doctrine_folder"},
								ResearchWeight = 0, 
								CurrentSlots = 0, 
								ResearchSlots = 0, 
								RegularTech = {}, 
								PreferTech = {},
								ListName = "LandDoctrinesTechs",
								ListIgnore = {},
								ListPrefer = {}}
	laPrimeTechAreas[_RESEARCH_AIR_] = {Folder = {"fighter_folder",
										 "bomber_folder"},
								ResearchWeight = 0, 
								CurrentSlots = 0, 
								ResearchSlots = 0, 
								RegularTech = {}, 
								PreferTech = {},
								ListName = "AirTechs",
								ListIgnore = {},
								ListPrefer = {}}
	laPrimeTechAreas[_RESEARCH_AIR_DOC_] = {Folder = {"air_doctrine_folder"},
								ResearchWeight = 0, 
								CurrentSlots = 0, 
								ResearchSlots = 0, 
								RegularTech = {}, 
								PreferTech = {},
								ListName = "AirDoctrineTechs",
								ListIgnore = {},
								ListPrefer = {}}
	laPrimeTechAreas[_RESEARCH_NAVAL_] = {Folder = {"smallship_folder",
										   "capitalship_folder"},
								ResearchWeight = 0, 
								CurrentSlots = 0, 
								ResearchSlots = 0, 
								RegularTech = {}, 
								PreferTech = {},
								ListName = "NavalTechs",
								ListIgnore = {},
								ListPrefer = {}}
	laPrimeTechAreas[_RESEARCH_NAVAL_DOC_] = {Folder = {"naval_doctrine_folder"},
								ResearchWeight = 0, 
								CurrentSlots = 0, 
								ResearchSlots = 0, 
								RegularTech = {}, 
								PreferTech = {},
								ListName = "NavalDoctrineTechs",
								ListIgnore = {},
								ListPrefer = {}}
	laPrimeTechAreas[_RESEARCH_INDUSTRIAL_] = {Folder = {"industry_folder"},
								ResearchWeight = 0, 
								CurrentSlots = 0, 
								ResearchSlots = 0, 
								RegularTech = {}, 
								PreferTech = {},
								ListName = "IndustrialTechs",
								ListIgnore = {},
								ListPrefer = {}}
	laPrimeTechAreas[_RESEARCH_SECRET_] = {Folder = {"secretweapon_folder"},
								ResearchWeight = 0, 
								CurrentSlots = 0, 
								ResearchSlots = 0, 
								RegularTech = {}, 
								PreferTech = {},
								ListName = "SecretWeaponTechs",
								ListIgnore = {},
								ListPrefer = {}}
	laPrimeTechAreas[_RESEARCH_UNKNOWN_] = {Folder = {"unknown"},
								ResearchWeight = 0, 
								CurrentSlots = 0, 
								ResearchSlots = 0, 
								RegularTech = {}, 
								PreferTech = {},
								ListName = "OtherTechs",
								ListIgnore = {},
								ListPrefer = {}}
	
	
	-- First determine research weights
	--    does the country have country specific weights
	if Utils.HasCountryAIFunction(ministerTag, "TechWeights") then
		local laTechWeights = Utils.CallCountryAI(ministerTag, "TechWeights", minister)

		for i = 1, _RESEARCH_UNKNOWN_ do
			laPrimeTechAreas[i].ResearchWeight = laTechWeights[i]
		end

	-- Country does not have country specific weights so use defaults
	else
		-- Check to see if the minor has any ports and if it has more than 20 IC
		if ministerCountry:GetNumOfPorts() > 0 and ministerCountry:GetTotalIC() >= 20 then
			for i = 1, _RESEARCH_UNKNOWN_ do
				laPrimeTechAreas[i].ResearchWeight = DefaultMixTechs.ResearchWeight[i]
			end
		
		-- If the minor has no ports and less than 20 IC then concentrate on land techs
		else
			vbLandBased = true
			
			for i = 1, _RESEARCH_UNKNOWN_ do
				laPrimeTechAreas[i].ResearchWeight = DefaultLandTechs.ResearchWeight[i]
			end
		end	
	end
	
	-- Figure out what the AI currently is researching
	for tech in ministerCountry:GetCurrentResearch() do
		local lbFound = false
		local lsFolder = tostring(tech:GetFolder():GetKey())
		
		for i = 1, (_RESEARCH_UNKNOWN_ - 1) do
			local subLength = table.getn(laPrimeTechAreas[i].Folder)
			
			for subI = 1, subLength do
				-- If Tech folder found now exit both loops
				if lsFolder == laPrimeTechAreas[i].Folder[subI] then
					laPrimeTechAreas[i].CurrentSlots = laPrimeTechAreas[i].CurrentSlots + 1	
					subI = subLength
					i = _RESEARCH_UNKNOWN_
					lbFound = true
				end
			end
		end

		-- It is Uknown so process it special
	    if lbFound == false then
			laPrimeTechAreas[_RESEARCH_UNKNOWN_].CurrentSlots = laPrimeTechAreas[_RESEARCH_UNKNOWN_].CurrentSlots + 1	
		end
	end
	
	for k, v in pairs(laPrimeTechAreas) do
		-- Retrieve Tech Ignore and Prefer Lists
		if Utils.HasCountryAIFunction(ministerTag, v.ListName) then
			v.ListIgnore, v.ListPrefer =  Utils.CallCountryAI(ministerTag, v.ListName, minister)
		else
			-- If their tech weights are land based and not country specific
			if vbLandBased == true then
				v.ListIgnore = DefaultLandTechs[v.ListName].ignoreTech
				v.ListPrefer = DefaultLandTechs[v.ListName].preferTech
			else
				v.ListIgnore = DefaultMixTechs[v.ListName].ignoreTech
				v.ListPrefer = DefaultMixTechs[v.ListName].preferTech
			end
		end
		
		-- Calculate what the AI wants to research in each category based on the weights
		---  AI may put more slots in that it can research but thats no big deal
		v.ResearchSlots = math.max(0, Utils.Round((ResearchSlotsAllowed * v.ResearchWeight) - v.CurrentSlots))
	end
	
	-- Figure out what the AI can research
	for tech in CTechnologyDataBase.GetTechnologies() do
		if  minister:CanResearch(tech) and tech:IsValid() then
			local nYear = techStatus:GetYear(tech, (techStatus:GetLevel(tech) + 1))
			
			-- Concentrate only on techs for the year requested or less
			--- Penalties are way to high to go into the future
			if nYear <= pYear then
				local liPrimeIndex = _RESEARCH_UNKNOWN_
				local lsFolder = tostring(tech:GetFolder():GetKey())
				
				for i = 1, (_RESEARCH_UNKNOWN_ - 1) do
					local subLength = table.getn(laPrimeTechAreas[i].Folder)
					
					for subI = 1, subLength do
						-- If Tech folder found now exit both loops
						if lsFolder == laPrimeTechAreas[i].Folder[subI] then
							subI = subLength
							liPrimeIndex = i
							i = _RESEARCH_UNKNOWN_
						end
					end
				end	

				local lsTechName = tostring(tech:GetKey())
				local lsTechLevel = techStatus:GetLevel(tech)

				-- Fill up the research arrays
				if TechIgnore(lsTechLevel, lsTechName, laPrimeTechAreas[liPrimeIndex].ListIgnore) == false then
					if TechPrefer(lsTechName, laPrimeTechAreas[liPrimeIndex].ListPrefer) == false then
						table.insert(laPrimeTechAreas[liPrimeIndex].RegularTech, tech )
					else
						table.insert(laPrimeTechAreas[liPrimeIndex].PreferTech, tech )
					end
				end
			end
		end
	end
	
	-- Holds extra research slots that the AI is unable to use
	local liExtraSlots = ResearchSlotsNeeded

	for k, v in pairs(laPrimeTechAreas) do
		-- Calculate to see if we are going to have extra research slots left over
		liExtraSlots = liExtraSlots - v.ResearchSlots
		
		-- Perform the research and recapture the returning object
		v = ResearchTech(ai, ministerTag, false, v)
		
		-- Recalculate now because it the ResearchSlots tells you how many
		--    have not been used so you need to re-add them into the ExtraSlots
		liExtraSlots = liExtraSlots + v.ResearchSlots
	end
	
	if liExtraSlots > 0 then
		for k, v in pairs(laPrimeTechAreas) do
			-- Use the RsearchSlots parm to control how many to research
			v.ResearchSlots = liExtraSlots
			
			-- Perform the research and recapture the returning object
			--   stick to prefer techs first
			v = ResearchTech(ai, ministerTag, true, v)

			-- Grab the extra slots for the next set
			liExtraSlots = v.ResearchSlots
		end
		
		if liExtraSlots > 0 then
			for k, v in pairs(laPrimeTechAreas) do
				-- Use the RsearchSlots parm to control how many to research
				v.ResearchSlots = liExtraSlots
				
				-- Perform the research and recapture the returning object
				v = ResearchTech(ai, ministerTag, false, v)

				-- Grab the extra slots for the next set
				liExtraSlots = v.ResearchSlots
			end
			
			-- There are still slots so jump into future techs
			if liExtraSlots > 0 then
				-- We have extra slots and no techs to research so go ahead and look into the future.
				Process_Tech((pYear + 1), ResearchSlotsAllowed, liExtraSlots, ai, minister, ministerCountry)
			end
		end
	end
end

-- Decide if the tech is to be ignored or not
function TechIgnore(viTechLevel, vsTechName, vaIgnoreTechs)
	local lbIgnoreTech = false
	
	local i = 1
	local TableLength = table.getn(vaIgnoreTechs)
	
	-- Performance check
	if TableLength > 0 then
		-- Ignores every tech in teh category if set to "all"
		if vaIgnoreTechs[1] == "all" then
			lbIgnoreTech = true
		else
			-- Loop through the ignore list see if the tech is on it
			while i <= TableLength do
				if vsTechName == vaIgnoreTechs[i][1] then
					local TechLevel = vaIgnoreTechs[i][2]
					
					-- If the tech is the level specified or has it been marked for all levels
					---   then ignore it
					if viTechLevel == TechLevel or TechLevel == 0 then
						lbIgnoreTech = true
						i = TableLength
					end
				end
				
				i = i + 1
			end						
		end
	end
	
	return lbIgnoreTech
end

-- Check to see if the tech is on the prefer list
--   The number being returned is used to tell it which array to place it in
function TechPrefer(vsTechName, vaPreferTechs)
	-- 0 = normal research tech
	-- 1 = prefered research tech
	local lbPreferTech = false

	-- Performance check, if nil get out
	if not(vaPreferTechs == nil) then
		local i = 1
		local TableLength = table.getn(vaPreferTechs)
		
		-- Performance check
		if TableLength > 0 then
			-- Loop through the ignore list see if the tech is on it
			while i <= TableLength do
				-- Prefer Research tech now get out of the loop
				if vsTechName == vaPreferTechs[i] then
					lbPreferTech = true
					i = TableLength
				end
				i = i + 1
			end						
		end
	end

	return lbPreferTech
end

-- Select a random tech from the array
function ResearchTech(ai, ministerTag, vbPrioTechOnly, vaTechObject)
	-- Performance check make sure there is something to do
	if vaTechObject.ResearchSlots > 0 then
		local liNonPreferCount = table.getn(vaTechObject.RegularTech)
		local liPreferCount
		
		-- Make sure there is a prefered tech option to process
		if vaTechObject.PreferTech == nil then
			liPreferCount = 0
		else
			liPreferCount = table.getn(vaTechObject.PreferTech)
		end
		
		-- Ok first check now make sure one of the two main arrays has something
		if (liNonPreferCount > 0) or (liPreferCount > 0) then
			local liMainCount = vaTechObject.ResearchSlots
			
			-- Normalize the max count for the loop as the request amount of techs can exceed what it has
			if vaTechObject.ResearchSlots > liPreferCount then
				liMainCount = liPreferCount
			end
			
			-- Subtract what you are about to process
			vaTechObject.ResearchSlots = vaTechObject.ResearchSlots - liMainCount

			-- First process the Prefer techs
			local i = 0
			while i < liMainCount do
				local liTechSelected = math.random(liPreferCount - i)
				ai:Post(CStartResearchCommand(ministerTag, vaTechObject.PreferTech[liTechSelected]))

				-- Remove the tech from the array
				table.remove(vaTechObject.PreferTech, liTechSelected)
				i = i + 1
			end
			
			-- If the vbPrioTechOnly is set to true then only process priority
			if vbPrioTechOnly == false then
				-- Now process the non-porefered techs
				--    normalize the loop count variable
				if vaTechObject.ResearchSlots > liNonPreferCount then
					liMainCount = liNonPreferCount
				else
					liMainCount = vaTechObject.ResearchSlots
				end

				-- Subtract what you are about to process
				vaTechObject.ResearchSlots = vaTechObject.ResearchSlots - liMainCount
				
				i = 0
				while i < liMainCount do
					local liTechSelected = math.random(liNonPreferCount - i)
					ai:Post(CStartResearchCommand(ministerTag, vaTechObject.RegularTech[liTechSelected]))
					-- Remove the tech from the array
					table.remove(vaTechObject.RegularTech, liTechSelected)
					
					i = i + 1
				end
			end
		end
	end
	
	return vaTechObject
end
