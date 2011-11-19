-----------------------------------------------------------
-- LUA Hearts of Iron 3 Custom tech minister for minor countries
-- Created By: Thirlan
-- Modified By: Thirlan
-- Date Last Modified: 9/17/2011
-- E-mail: Norvisssion@hotmail.com
-----------------------------------------------------------

require('custom_ai_support_functions')

local _MONEY_ = 1
local _METAL_ = 2
local _ENERGY_ = 3
local _RARE_MATERIALS_ = 4
local _CRUDE_OIL_ = 5
local _SUPPLIES_ = 6
local _FUEL_ = 7

local laCrossValue = {
	CGoodsPool._MONEY_,
	CGoodsPool._METAL_,
	CGoodsPool._ENERGY_,
	CGoodsPool._RARE_MATERIALS_,
	CGoodsPool._CRUDE_OIL_,
	CGoodsPool._SUPPLIES_,
	CGoodsPool._FUEL_
}

-- List of Tech names
-- first_aid' 
-- agriculture' 
-- industral_production' 
-- industral_efficiency' 
-- oil_to_coal_conversion' 
-- supply_production' 
-- heavy_aa_guns' 
-- electronic_mechanical_egineering' 
-- radio_technology' 
-- radio_detection_equipment' 
-- radio' 
-- radar' 
-- census_tabulation_machine' 
-- mechnical_computing_machine' 
-- electronic_computing_machine' 
-- decryption_machine' 
-- encryption_machine' 
-- construction_engineering' 
-- advanced_construction_engineering' 
-- rocket_tests' 
-- rocket_engine' 
-- theorical_jet_engine' 
-- atomic_research' 
-- nuclear_research' 
-- isotope_seperation' 
-- civil_nuclear_research' 
-- oil_refinning' 
-- steel_production' 
-- raremetal_refinning_techniques' 
-- coal_processing_technologies' 
-- education' 
-- supply_transportation' 
-- supply_organisation' 
-- civil_defence' 
-- cavalry_smallarms' 
-- cavalry_support' 
-- cavalry_guns' 
-- cavalry_at' 
-- militia_smallarms' 
-- militia_support' 
-- militia_guns' 
-- militia_at' 
-- infantry_activation' 
-- smallarms_technology' 
-- infantry_support' 
-- infantry_guns' 
-- infantry_at' 
-- mountain_infantry' 
-- marine_infantry' 
-- paratrooper_infantry' 
-- night_goggles' 
-- engineer_brigade_activation' 
-- engineer_bridging_equipment' 
-- engineer_assault_equipment' 
-- imporved_police_brigade' 
-- mortorised_infantry' 
-- desert_warfare_equipment' 
-- jungle_warfare_equipment' 
-- mountain_warfare_equipment' 
-- artic_warfare_equipment' 
-- amphibious_warfare_equipment' 
-- airborne_warfare_equipment' 
-- single_engine_aircraft_design' 
-- twin_engine_aircraft_design' 
-- basic_aeroengine' 
-- basic_small_fueltank' 
-- basic_single_engine_airframe' 
-- basic_aircraft_machinegun' 
-- basic_medium_fueltank' 
-- basic_twin_engine_airframe' 
-- basic_bomb' 
-- multi_role_fighter_development' 
-- cas_development' 
-- nav_development' 
-- basic_four_engine_airframe' 
-- basic_strategic_bomber' 
-- aeroengine' 
-- small_fueltank' 
-- single_engine_airframe' 
-- single_engine_aircraft_armament' 
-- medium_fueltank' 
-- twin_engine_airframe' 
-- air_launched_torpedo' 
-- small_bomb' 
-- twin_engine_aircraft_armament' 
-- medium_bomb' 
-- large_fueltank' 
-- four_engine_airframe' 
-- strategic_bomber_armament' 
-- cargo_hold' 
-- large_bomb' 
-- advanced_aircraft_design' 
-- small_airsearch_radar' 
-- medium_airsearch_radar' 
-- large_airsearch_radar' 
-- small_navagation_radar' 
-- medium_navagation_radar' 
-- large_navagation_radar' 
-- rocket_interceptor_tech' 
-- drop_tanks' 
-- jet_engine' 
-- fighter_pilot_training' 
-- fighter_groundcrew_training' 
-- interception_tactics' 
-- fighter_ground_control' 
-- bomber_targerting_focus' 
-- fighter_targerting_focus' 
-- cas_pilot_training' 
-- cas_groundcrew_training' 
-- ground_attack_tactics' 
-- forward_air_control' 
-- battlefield_interdiction' 
-- tac_pilot_training' 
-- tac_groundcrew_training' 
-- interdiction_tactics' 
-- logistical_strike_tactics' 
-- installation_strike_tactics' 
-- airbase_strike_tactics' 
-- tactical_air_command' 
-- nav_pilot_training' 
-- nav_groundcrew_training' 
-- portstrike_tactics' 
-- navalstrike_tactics' 
-- naval_air_targeting' 
-- naval_tactics' 
-- heavy_bomber_pilot_training' 
-- heavy_bomber_groundcrew_training' 
-- strategic_bombardment_tactics' 
-- airborne_assault_tactics' 
-- strategic_air_command' 
-- lighttank_brigade' 
-- lighttank_gun' 
-- lighttank_engine' 
-- lighttank_armour' 
-- lighttank_reliability' 
-- tank_brigade' 
-- tank_gun' 
-- tank_engine' 
-- tank_armour' 
-- tank_reliability' 
-- heavy_tank_brigade' 
-- heavy_tank_gun' 
-- heavy_tank_engine' 
-- heavy_tank_armour' 
-- heavy_tank_reliability' 
-- armored_car_armour' 
-- armored_car_gun' 
-- SP_brigade' 
-- mechanised_infantry' 
-- super_heavy_tank_brigade' 
-- super_heavy_tank_gun' 
-- super_heavy_tank_engine' 
-- super_heavy_tank_armour' 
-- super_heavy_tank_reliability' 
-- art_barrell_ammo' 
-- art_carriage_sights' 
-- at_barrell_sights' 
-- at_ammo_muzzel' 
-- aa_barrell_ammo' 
-- aa_carriage_sights' 
-- rocket_art' 
-- rocket_art_ammo' 
-- rocket_carriage_sights' 
-- mobile_warfare' 
-- elastic_defence' 
-- spearhead_doctrine' 
-- schwerpunkt' 
-- blitzkrieg' 
-- operational_level_command_structure' 
-- tactical_command_structure' 
-- delay_doctrine' 
-- integrated_support_doctrine' 
-- superior_firepower' 
-- mechanized_offensive' 
-- combined_arms_warfare' 
-- infantry_warfare' 
-- special_forces' 
-- central_planning' 
-- mass_assault' 
-- grand_battle_plan' 
-- assault_concentration' 
-- operational_level_organisation' 
-- large_front' 
-- guerilla_warfare' 
-- peoples_army' 
-- large_formations' 
-- human_wave' 
-- fleet_auxiliary_carrier_doctrine' 
-- light_cruiser_escort_role' 
-- carrier_group_doctrine' 
-- light_cruiser_crew_training' 
-- carrier_crew_training' 
-- carrier_task_force' 
-- naval_underway_repleshment' 
-- radar_training' 
-- sea_lane_defence' 
-- destroyer_escort_role' 
-- battlefleet_concentration_doctrine' 
-- destroyer_crew_training' 
-- battleship_crew_training' 
-- commerce_defence' 
-- fire_control_system_training' 
-- commander_decision_making' 
-- fleet_auxiliary_submarine_doctrine' 
-- trade_interdiction_submarine_doctrine' 
-- cruiser_warfare' 
-- submarine_crew_training' 
-- cruiser_crew_training' 
-- unrestricted_submarine_warfare_doctrine' 
-- spotting' 
-- basing' 
-- destroyer_technology' 
-- destroyer_armament' 
-- destroyer_antiaircraft' 
-- destroyer_engine' 
-- destroyer_armour' 
-- lightcruiser_technology' 
-- lightcruiser_armament' 
-- lightcruiser_antiaircraft' 
-- lightcruiser_engine' 
-- lightcruiser_armour' 
-- smallwarship_radar' 
-- smallwarship_asw' 
-- heavycruiser_technology' 
-- heavycruiser_armament' 
-- heavycruiser_antiaircraft' 
-- heavycruiser_engine' 
-- heavycruiser_armour' 
-- battlecruiser_technology' 
-- battleship_technology' 
-- capitalship_armament' 
-- battlecruiser_antiaircraft' 
-- battlecruiser_engine' 
-- battlecruiser_armour' 
-- battleship_antiaircraft' 
-- battleship_engine' 
-- battleship_armour' 
-- super_heavy_battleship_technology' 
-- cag_development' 
-- escort_carrier_technology' 
-- carrier_technology' 
-- carrier_antiaircraft' 
-- carrier_engine' 
-- carrier_armour' 
-- carrier_hanger' 
-- largewarship_radar' 
-- submarine_technology' 
-- submarine_antiaircraft' 
-- submarine_engine' 
-- submarine_hull' 
-- submarine_torpedoes' 
-- submarine_sonar' 
-- submarine_airwarningequipment' 
-- strategic_rocket_development' 
-- flyingbomb_development' 
-- flyingrocket_development' 
-- strategicrocket_engine' 
-- strategicrocket_warhead' 
-- strategicrocket_structure' 
-- da_bomb' 
-- radar_guided_missile' 
-- radar_guided_bomb' 
-- electric_powered_torpedo' 
-- helecopters' 
-- medical_evacuation' 
-- pilot_rescue' 
-- sam' 
-- aam' 
-- naval_engineering_research' 
-- submarine_engineering_research' 
-- aeronautic_engineering_research' 
-- rocket_science_research' 
-- chemical_engineering_research' 
-- nuclear_physics_research' 
-- jetengine_research' 
-- mechanicalengineering_research' 
-- automotive_research' 
-- electornicegineering_research' 
-- artillery_research' 
-- mobile_research' 
-- militia_research' 
-- infantry_research' 
-- notech' 
-- combat_medicine' 

-- Minor countries

local _CUST_DESIRE_CRITICAL_ = 0.40 -- We need this to survive
local _CUST_DESIRE_HIGH_ = 0.60 -- We want to rush this tech
local _CUST_DESIRE_MED_ = 0.80 -- We prefer this tech over other likeable techs
local _CUST_DESIRE_LOW_ = 1.00 -- A tech that is part of our strategy
local _CUST_DESIRE_MAYBE_ = 2.00 -- tech should be considered if we have no other techs to research
local _CUST_DESIRE_NEVER_ = 1000.00 -- tech has no place in our strategy

local MinorCountryTechFunc = {
	
	["oil_to_coal_conversion"] =			function (minister, tech) return ScoreOilConversionResource(minister, tech) end,
	["coal_processing_technologies"] = 		function (minister, tech) return ScoreResource(minister, _ENERGY_, tech) end,
	["raremetal_refinning_techniques"] = 	function (minister, tech) return ScoreResource(minister, _RARE_MATERIALS_, tech) end,
	["steel_production"] = 					function (minister, tech) return ScoreResource(minister, _METAL_, tech) end,
	
	["agriculture"] = 		function (minister, tech) return ScoreManPower(minister, tech) end,
	["first_aid"] = 		function (minister, tech) return ScoreMedic(minister, tech) end,
	["combat_medicine"] = 	function (minister, tech) return ScoreMedic(minister, tech) end,
	
	["industral_production"] = 		function (minister, tech) return ScoreIC(minister, tech) end,
	["industral_efficiency"] = 		function (minister, tech) return ScoreIC(minister, tech) end,
	["construction_engineering"] = 	function (minister, tech) return ScoreICEnable(minister, tech) end,
	
	["supply_production"] = 		function (minister, tech) return ScoreSupplies(minister, tech) end,
	
	["supply_transportation"] = 		function (minister, tech) return ScoreSupplies(minister, tech) end,
	
	
	["central_planning"] = 		function (minister, tech) return ScoreMilitaryDoctrine(minister, tech) end,
	["grand_battle_plan"] = 	function (minister, tech) return ScoreUberMilitaryDoctrine(minister, tech) end,
	["large_front"] = 			function (minister, tech) return ScoreMilitaryDoctrine(minister, tech) end,
	["guerilla_warfare"] = 		function (minister, tech) return ScoreMilitaryDoctrine(minister, tech) end,
	["human_wave"] = 			function (minister, tech) return ScoreUberMilitaryDoctrine(minister, tech) end,
	["large_formations"] = 		function (minister, tech) return ScoreUberMilitaryDoctrine(minister, tech) end,
	["integrated_support_doctrine"] = function (minister, tech) return ScoreMilitaryDoctrine(minister, tech) end,
	["delay_doctrine"] = 		function (minister, tech) return ScoreMilitaryDoctrine(minister, tech) end,
	["elastic_defence"] = 		function (minister, tech) return ScoreMilitaryDoctrine(minister, tech) end,
	["mobile_warfare"] = 		function (minister, tech) return ScoreMilitaryDoctrine(minister, tech) end,
	["combined_arms_warfare"] = function (minister, tech) return ScoreCombinedArmsDoctrine(minister, tech) end,
	
	["education"] = function (minister, tech) return ScoreEducation(minister, tech) end
}

function TechMinister_Tick_Modded_AI(minister, set_sliders, set_research)
	local countryTag = minister:GetCountryTag()
	local ministerCountry = minister:GetCountry()
	local ai = minister:GetOwnerAI()
	
	--COUNTRY_DEBUG(ministerCountry, "Using TechMinister_Tick_Modded_AI")
	if set_sliders then
		local adjustLeadershipkey = tostring(countryTag).."-TechMinister_Tick_Modded_AI_AdjustLeadership"
		local canAdjustLeadership = GetCustCache(ai, adjustLeadershipkey)
		
		-- only adjust the leadership every 7 days or so
		-- we count this by caching a variable and waiting until the cache is cleared.
		-- at which point we know 7 days have elapsed.
		if not canAdjustLeadership then
			COUNTRY_DEBUG(ministerCountry, "Adjusting leadership")
			--COUNTRY_DEBUG(ministerCountry, "Continent = ".. GetContinent(ministerCountry))
			SetCustCache(ai, adjustLeadershipkey, 7, 1)
			AdjustLeadership(minister)
		end
	end
	
	if set_research and not IsStartOfGame(ai) and IsTotalUnitListSet(ministerCountry) then
		AdjustResearch(minister)
	end
end

function ScoreResource(minister, resourceType, resourceTech)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local daysToDepletion = DaysTillResourceDepletion(ministerCountry, ai, resourceType)
	local score = ResearchTime(ministerCountry, ai, resourceTech, 1, CurrentYear(ai))
	local minDaysToCollapse = MinDaysToCollapse(ministerCountry , ai)
	if daysToDepletion > minDaysToCollapse then
		-- If we are not under threat of a resource depletion then never bother to research
		score = _CUST_DESIRE_NEVER_*score
	else
		local minTimeToAct = math.max(0.01, daysToDepletion - 2*score)
		-- adjust the score based on a percentage of how soon we will run out
		-- to indicate the severity of the resource shortage
		score = math.sqrt(minTimeToAct / minDaysToCollapse) * score
	end
	return score
end

function ScoreOilConversionResource(minister, resourceTech)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local score = ResearchTime(ministerCountry, ai, resourceTech, 1, CurrentYear(ai))
	-- to invest in the oil conversion three things need to be true
	-- 1 we need to have spare energy
	-- 2 we need to have a shortage of fuel
	-- 3 we need to have a shortage of raw oil
	local minDaysToCollapse = MinDaysToCollapse(ministerCountry , ai)
	if DaysTillResourceDepletion(ministerCountry, ai, _ENERGY_)  > minDaysToCollapse and
		DaysTillResourceDepletion(ministerCountry, ai, _FUEL_) < minDaysToCollapse and 
		DaysTillResourceDepletion(ministerCountry, ai, _CRUDE_OIL_) < minDaysToCollapse then
		
		local minTimeToAct = math.max(0.01, DaysTillResourceDepletion(ministerCountry, ai, _CRUDE_OIL_) - 2*score)
		-- adjust the score based on a percentage of how soon we will run out
		-- to indicate the severity of the resource shortage
		score = math.sqrt(minTimeToAct / minDaysToCollapse) * score
	else
		score = _CUST_DESIRE_NEVER_*score
	end
	return score
end

function ScoreEducation(minister, educationTech)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local rTime = ResearchTime(ministerCountry, ai, educationTech, 1, CurrentYear(ai))
	local daysToCollapse = MinDaysToCollapse(ministerCountry , ai)
	
	local techStatus = ministerCountry:GetTechnologyStatus()
	local techLevel = techStatus:GetLevel(educationTech)
	-- we only have total leadership and not base leadership so we have to calculate
	-- the decreasing impact of each tech level in education
	local leadershipBonus = 0.05/(1+0.05*techLevel)
	local leadership = ministerCountry:GetTotalLeadership():Get()
	--COUNTRY_DEBUG(ministerCountry, "leadershipBonus = " .. leadershipBonus)
	--COUNTRY_DEBUG(ministerCountry, "GetTotalLeadership = " .. leadership)
	--COUNTRY_DEBUG(ministerCountry, "daysToCollapse = " .. daysToCollapse)
	--COUNTRY_DEBUG(ministerCountry, "rTime = " .. rTime)
	local ROI = leadershipBonus * leadership * (daysToCollapse - rTime) - rTime
	local score = INF_DAYS()
	if ROI > 0 then
		-- a positive ROI based on our timeline means we should ALWAYS research education
		-- so give it the lowest possibe score
		score = 0.0
	else
		score = _CUST_DESIRE_MAYBE_*rTime
	end
	return score
end

function ScoreIC(minister, tech)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local score = ResearchTime(ministerCountry, ai, tech, 1, CurrentYear(ai))
	if InvestInIC(minister) then
		-- If we're investing into IC then skew the score to make it more desirable
		score = _CUST_DESIRE_HIGH_*score
	
	-- check if we can barely build anything and also make sure that this is not due to a resource shortage.
	-- if we're suffering a resource shortage then there is no point in pumping up our IC!
	elseif HasICShortage(ministerCountry, ai) and not HasICResourceShortage(ministerCountry, ai) then
		-- if we can't build anything then that's really bad!
		-- give it a huge change!
		score = _CUST_DESIRE_CRITICAL_*score
	else
		-- If we're not investing into IC then adjust the score to make it undesireable, but something to consider later
		score = _CUST_DESIRE_MAYBE_*score
	end
	return score
end

function ScoreSupplies(minister, tech)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local score = ResearchTime(ministerCountry, ai, tech, 1, CurrentYear(ai))
	if HasICShortage(ministerCountry, ai) then
		-- if we can't build anything then that's really bad and so try and minimize the impact that supplies have on this IC shortage.
		-- Note how ScoreSupplies, unlike ScoreIC, does not rely on whether here is an ICResourceShortage.
		score = _CUST_DESIRE_CRITICAL_*score
	else
		score = _CUST_DESIRE_MAYBE_*score
	end
	return score
end

function ScoreICEnable(minister, tech)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local score = ResearchTime(ministerCountry, ai, tech, 1, CurrentYear(ai))
	if InvestInIC(minister) then
		-- If we're investing into IC then we need this immediately!
		score = _CUST_DESIRE_HIGH_*score
	else
		-- If we're not investing into IC then adjust the score to make it undesireable, but something to consider later
		score = _CUST_DESIRE_MAYBE_*score
	end
	return score
end

function ScoreManPower(minister, tech)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local favoriteUnit = FavoriteUnit(ministerCountry, ai)
	local score = ResearchTime(ministerCountry, ai, tech, 1, CurrentYear(ai))
	local daysToDepletion = DivisionDaysToMPDepletion(ministerCountry, ai, favoriteUnit, 3, nil, 0)
	if daysToDepletion > MinDaysToCollapse(ministerCountry, ai) then
		-- If we are not under threat of a man power shortage then never bother to research
		score = _CUST_DESIRE_MAYBE_ * score
	else
		-- running out of manpower is a very serious problem!
		score = _CUST_DESIRE_CRITICAL_ * score
	end
	return score
end

function ScoreMedic(minister, tech)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local favoriteUnit = FavoriteUnit(ministerCountry, ai)
	local score = ResearchTime(ministerCountry, ai, tech, 1, CurrentYear(ai))
	local daysToDepletion = DivisionDaysToMPDepletion(ministerCountry, ai, favoriteUnit, 3, nil, 0)
	if daysToDepletion > MinDaysToCollapse(ministerCountry, ai) then
		-- If we are not under threat of a man power shortage then never bother to research
		score = _CUST_DESIRE_MAYBE_ * score
	elseif ministerCountry:IsAtWar() then
		-- running out of manpower is a serious problem, but this type of tech only helps during war
		-- so if it's a war then adjust this tech.
		score = _CUST_DESIRE_CRITICAL_ * score
	end
	return score
end

function ScoreMilitaryUnit(minister, tech)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local favoriteUnit = FavoriteUnit(ministerCountry, ai)
	local favorOldTech = TechYearSkew(minister, tech, 1, CurrentYear(ai))
	local score = favorOldTech*ResearchTime(ministerCountry, ai, tech, 1, CurrentYear(ai))
	if IsUnitTech(favoriteUnit, tech) then
		if ministerCountry:IsAtWar() then
		-- these techs have less preference during war
			score = _CUST_DESIRE_LOW_ * score
		else
			score = _CUST_DESIRE_MED_ * score
		end
	else
		local favoriteSupport = FavoriteSupportUnit(ministerCountry, ai, favoriteUnit)
		-- If we don't even have a support unit out then don't bother research it
		local supportUnitCount = ministerCountry:GetUnits():GetCount(favoriteSupport)
		--COUNTRY_DEBUG(ministerCountry, "supportUnitCount = "..supportUnitCount)
		if IsUnitTech(favoriteSupport, tech) and supportUnitCount > 0 then
			score = _CUST_DESIRE_LOW_ * score
		else
			-- this is not our favorite unit so horrible skew the score
			score = _CUST_DESIRE_NEVER_ * score
		end
	end
	return score
end

function ScoreMilitaryUnitEnable(minister, tech)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local favoriteUnit = FavoriteUnit(ministerCountry, ai)
	local favorOldTech = TechYearSkew(minister, tech, 1, CurrentYear(ai))
	local score = favorOldTech * ResearchTime(ministerCountry, ai, tech, 1, CurrentYear(ai))
	local req = IsUnitRequirement(favoriteUnit, tech)
	local techStatus = ministerCountry:GetTechnologyStatus()
	local techLevel = techStatus:GetLevel(tech)
	
	if req and techLevel < req then
		score = _CUST_DESIRE_CRITICAL_ * score
	else
		local favoriteSupport = FavoriteSupportUnit(ministerCountry, ai, favoriteUnit)
		req = IsUnitRequirement(favoriteSupport, tech)
		if req and techLevel < req then
			score = _CUST_DESIRE_MED_ * score
		else
			-- this is not a requirement tech
			score = _CUST_DESIRE_NEVER_ * score
		end
	end
	return score
end

function ScoreMilitaryDoctrine(minister, tech)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local favorOldTech = TechYearSkew(minister, tech, 1, CurrentYear(ai))
	local score = favorOldTech * ResearchTime(ministerCountry, ai, tech, 1, CurrentYear(ai))
	if ministerCountry:IsAtWar() then
		-- give these techs preference during war
		score = _CUST_DESIRE_MED_ * score
	else
		score = _CUST_DESIRE_LOW_ * score
	end
	
	return score
end

function ScoreUberMilitaryDoctrine(minister, tech)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local favorOldTech = TechYearSkew(minister, tech, 1, CurrentYear(ai))
	local score = _CUST_DESIRE_HIGH_ * ResearchTime(ministerCountry, ai, tech, 1, CurrentYear(ai))
	-- these doctrines are so good that we should research them the instant they become available
	return score
end

function ScoreCombinedArmsDoctrine(minister, tech)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local favorOldTech = TechYearSkew(minister, tech, 1, CurrentYear(ai))
	local score =  ResearchTime(ministerCountry, ai, tech, 1, CurrentYear(ai))
	local favoriteUnit = FavoriteUnit(ministerCountry, ai)
	local favoriteUnitName = tostring(favoriteUnit:GetKey())
	if favoriteUnitName == "motorized_brigade" then
		-- This doctrine is only important if we are going with combined arms troops
		score = _CUST_DESIRE_HIGH_ * score
	else
		score = _CUST_DESIRE_NEVER_ * score
	end
	
	return score
end

function AdjustLeadership(minister)
	local ministerCountry = minister:GetCountry()
	local changes = { [0] = 0, 0, 0, 0 };
	local officers = ministerCountry:GetOfficerRatio():Get()
	local leadership = ministerCountry:GetTotalLeadership():Get()
	local remainingLeadership = ministerCountry:GetTotalLeadership():Get()
	--COUNTRY_DEBUG(ministerCountry, "Officers = ".. officers)
	local pDiplomacy = 0.0
	local pOfficer = 0.0
	local pEspionage = 0.0
	local pResearch = 0.0
	
	-- diplomacy comes first since it should be there with or without war
	local currentDiplomats = ministerCountry:GetDiplomaticInfluence():Get()
	if currentDiplomats < 10 then
		if ministerCountry:IsPuppet() then
			-- this country is a puppet and so has limited trade capabilities
			pDiplomacy = 0.075/leadership
		elseif ministerCountry:GetNumOfPorts() > 0 and ministerCountry:GetTotalConvoyTransports() > 0 then
			-- a port allows this country access to more countries to trade with
			pDiplomacy = 0.125/leadership
		else
			pDiplomacy = 0.100/leadership
		end
	end
	remainingLeadership = math.max(remainingLeadership - pDiplomacy*leadership, 0)
	
	if ministerCountry:IsGovernmentInExile() then
		-- drop everything into espionage and harrass the country that conquered us
		pEspionage = remainingLeadership/leadership
		remainingLeadership = 0
	else
		if officers < 1.79 then
			local ai = minister:GetOwnerAI()
			local minResearch = math.min(1.0, 0.1*remainingLeadership) -- we always want a minimum of at least 1 point in research, but obviously can only use what's left.
			local maxOfficer = math.max(remainingLeadership-minResearch, 0)
			
			local maxResearch = 0
			if remainingLeadership < 2 then
				maxResearch = 0.9*remainingLeadership
			else
				maxResearch = math.min(remainingLeadership, Round(0.9*remainingLeadership))
			end
			local minOfficer = math.max(remainingLeadership - maxResearch, 0)
			
			local shouldPump = ShouldStartPumpingOfficers(minister, minOfficer, maxOfficer)
			if PrepareForWar(ministerCountry, ai) and officers < 1.70 then
				COUNTRY_DEBUG(ministerCountry, "Officers preparing for war")
				pResearch = minResearch/leadership
				pOfficer = maxOfficer/leadership
			elseif shouldPump == -1 then
				-- no intelligent decision available yet...				
				pResearch = maxResearch/leadership
				pOfficer = minOfficer/leadership
			elseif shouldPump == 0 then
				pResearch = maxResearch/leadership
				pOfficer = minOfficer/leadership
			else
				pResearch = minResearch/leadership
				pOfficer = maxOfficer/leadership
			end
			--COUNTRY_DEBUG(ministerCountry, "=========OfficerResearchRatio================''")
			--COUNTRY_DEBUG(ministerCountry, "minResearch = "..minResearch)
			--COUNTRY_DEBUG(ministerCountry, "maxOfficer = "..maxOfficer)
			--COUNTRY_DEBUG(ministerCountry, "maxResearch = "..maxResearch)
			--COUNTRY_DEBUG(ministerCountry, "minOfficer = "..minOfficer)
			--COUNTRY_DEBUG(ministerCountry, "pResearch = "..pResearch)
			--COUNTRY_DEBUG(ministerCountry, "pOfficer = "..pOfficer)
			--COUNTRY_DEBUG(ministerCountry, "=============================================")
			
			remainingLeadership = 0
		else
			--COUNTRY_DEBUG(ministerCountry, "Going full research")
			local roundedResearch = math.min(remainingLeadership, Round(remainingLeadership))			
			pResearch = roundedResearch/leadership
			remainingLeadership = remainingLeadership-pResearch*leadership
		end
	end
	
	if remainingLeadership > 0 then
		-- still have some leadership? throw it into espionage
		pEspionage = remainingLeadership/leadership
		remainingLeadership = 0
	end
	
	-- normalize to remove any rounding errors
	local totalP = pDiplomacy + pOfficer + pEspionage + pResearch
	changes[CDistributionSetting._LEADERSHIP_DIPLOMACY_] = pDiplomacy/totalP
	changes[CDistributionSetting._LEADERSHIP_NCO_] = pOfficer/totalP
	changes[CDistributionSetting._LEADERSHIP_ESPIONAGE_] = pEspionage/totalP
	changes[CDistributionSetting._LEADERSHIP_RESEARCH_] = pResearch/totalP
	
	local ministerTag = minister:GetCountryTag()
	local ai = minister:GetOwnerAI()
	local command = CChangeLeadershipCommand(ministerTag, changes[0], changes[1], changes[2], changes[3])
	ai:Post(command)
end

function AdjustResearch(minister)
	local ministerCountry = minister:GetCountry()
	local openSlots = ministerCountry:GetAllowedResearchSlots() - ministerCountry:GetNumberOfCurrentResearch()
	--COUNTRY_DEBUG(ministerCountry, "Open slots ".. openSlots)
	if openSlots > 0 then
		local researchList = ConstructResearchList(minister)
		local researchListLength = table.getn(researchList)
		--COUNTRY_DEBUG(ministerCountry, "Suggested Research size ".. researchListLength)
		local researchIndex = 1
		while openSlots > 0 and researchIndex <= researchListLength do
			local score = researchList[researchIndex][1]
			local tech = researchList[researchIndex][2]
			--COUNTRY_DEBUG(ministerCountry, "tech = ".. tostring(tech:GetKey()) .. " / " .. score)
			local ministerTag = minister:GetCountryTag()
			local command = CStartResearchCommand(ministerTag, tech)
			local ai = minister:GetOwnerAI()
			ai:Post(command)
			openSlots = openSlots - 1
			researchIndex = researchIndex + 1
		end
	end
end

function ConstructResearchList(minister)
	local researchList = {}
	local ministerCountry = minister:GetCountry()
	local ai = minister:GetOwnerAI()
	-- Figure out what the AI can research
	--COUNTRY_DEBUG(minister:GetCountry(), "=================CALCULATING TECHS=============")
	for tech in CTechnologyDataBase.GetTechnologies() do
		if  minister:CanResearch(tech) and tech:IsValid() then	
			local techName = tostring(tech:GetKey())
			local scoreFunc = MinorCountryTechFunc[techName]
			local score = INF_DAYS()
			if scoreFunc then
				score = scoreFunc(minister, tech)
				
				--COUNTRY_DEBUG(minister:GetCountry(), score .. " ".. techName)
				table.insert(researchList, {score, tech})
			end
			
			-- if this is a tech that will enable our desired unit then recalculate the score
			score = math.min(ScoreMilitaryUnitEnable(minister, tech), score)
			
			-- if this is a favorite unit tech then recalulate the score
			score = math.min(ScoreMilitaryUnit(minister, tech), score)
			
			if score < _CUST_DESIRE_NEVER_ then
				--COUNTRY_DEBUG(ministerCountry, score .. " / "..ResearchTime(ministerCountry, ai, tech, 1, CurrentYear(ai)).." / " .. TechYearSkew(minister, tech, 1, CurrentYear(ai)) .. "----".. techName)
			end
			table.insert(researchList, {score, tech})
		end
	end
	--COUNTRY_DEBUG(minister:GetCountry(), "===============================================")
	
	-- Sort the table from lowest time to highest
	table.sort(researchList, function(x, y) return x[1] < y[1] end)
	return researchList;
end