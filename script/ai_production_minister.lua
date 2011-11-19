-----------------------------------------------------------
-- LUA Hearts of Iron 3 Production File
-- Created By: Lothos
-- Modified By: Thirlan
-- Date Last Modified: 9/17/2011
-----------------------------------------------------------
require('custom_ai_support_functions')
require('custom_ai_production_minister')

-- ######################
-- Global Variables
--    CAREFUL: Variables are remembered from country to country
-- ######################
local ProductionData = {} -- Gets reset each time the tick starts

local _GARRISON_BRIGADE_ = 1
local _MILITIA_BRIGADE_ = 2

local _INFANTRY_BRIGADE_ = 3
local _CAVALRY_BRIGADE_ = 4
local _BERGSJAEGER_BRIGADE_ = 5
local _MARINE_BRIGADE_ = 6
local _PARATROOPER_BRIGADE_ = 7

local _LIGHT_ARMOR_BRIGADE_ = 8
local _ARMOR_BRIGADE_ = 9
local _HEAVY_ARMOR_BRIGADE_ = 10
local _SUPER_HEAVY_ARMOR_BRIGADE_ = 11

local _MECHANIZED_BRIGADE_ = 12

local _MOTORIZED_BRIGADE_ = 13


local _ANTI_AIR_BRIGADE_ = 14
local _ANTI_TANK_BRIGADE_ = 15
local _ARTILLERY_BRIGADE_ = 16
local _ENGINEER_BRIGADE_ = 17
local _ROCKET_ARTILLERY_BRIGADE_ = 18

local _ARMORED_CAR_BRIGADE_ = 19
local _SP_ARTILLERY_BRIGADE_ = 20
local _SP_RCT_ARTILLERY_BRIGADE_ = 21
local _TANK_DESTROYER_BRIGADE_ = 22

local _POLICE_BRIGADE_ = 23


local _BATTLECRUISER_ = 24
local _BATTLESHIP_ = 25
local _SUPER_HEAVY_BATTLESHIP_ = 26
local _CARRIER_ = 27
local _ESCORT_CARRIER_ = 28
local _CAG_ = 29
local _DESTROYER_ = 30
local _LIGHT_CRUISER_ = 31
local _HEAVY_CRUISER_ = 32
local _SUBMARINE_ = 33
local _NUCLEAR_SUBMARINE_ = 34
local _TRANSPORT_SHIP_ = 35

local _CAS_ = 36
local _INTERCEPTOR_ = 37
local _MULTI_ROLE_ = 38
local _ROCKET_INTERCEPTOR_ = 39
local _NAVAL_BOMBER_ = 40
local _STRATEGIC_BOMBER_ = 41
local _TACTICAL_BOMBER_ = 42
local _TRANSPORT_PLANE_ = 43
local _FLYING_BOMB_ = 44
local _FLYING_ROCKET_ = 45

local _HQ_BRIGADE_ = 46
local _PARTISAN_BRIGADE_ = 47

-- Static Arrays used for Ratio setup
local _LandRatio_Units_ = {
	'garrison_brigade', -- Garrison
	'infantry_brigade', -- Infantry
	'motorized_brigade', -- Motorized
	'mechanized_brigade', -- Mechanized
	'light_armor_brigade|armor_brigade|heavy_armor_brigade|super_heavy_armor_brigade', -- Armor
	'militia_brigade', -- Militia
	'cavalry_brigade'}; -- Cavalry

local _AirRatio_Units_ = {
	'interceptor|multi_role|rocket_interceptor', -- Fighter
	'cas', -- CAS
	'tactical_bomber', -- Tactical
	'naval_bomber', -- Naval Bomber
	'strategic_bomber'}; -- Strategic
	
local _NavalRatio_Units_ = {
	'destroyer', -- Destroyers
	'submarine', -- Submarines
	'light_cruiser|heavy_cruiser', -- Cruisers
	'battlecruiser|battleship|super_heavy_battleship', -- Capital
	'escort_carrier', -- Escort Carrier
	'carrier'}; -- Carrier
		
-- ######################
-- Default parameters for countries 
-- ######################





-- Countries Default build weights for land based only
local DefaultProdLand = {}

-- Land Brigades vs Air Units ratio
--   If Air Ratio is met AI will shift its Air IC to build land units
function DefaultProdLand.LandToAirRatio()
	local laArray = {
		8, -- Land Briages
		1}; -- Air
	
	return laArray
end

function DefaultProdLand.ProductionWeights()
	local laArray
	
	-- Check to see if manpower is to low
	-- More than 30 brigades so build stuff that does not use manpower
	if (ProductionData.ManpowerTotal < 30 and ProductionData.LandCountTotal > 30)
	or ProductionData.ManpowerTotal < 10 then
		laArray = {
			0.0, -- Land
			0.50, -- Air
			0.0, -- Sea
			0.50}; -- Other	
	elseif ProductionData.ministerCountry:IsAtWar() then
		laArray = {
			0.65, -- Land
			0.25, -- Air
			0.0, -- Sea
			0.10}; -- Other
	else
		laArray = {
			0.55, -- Land
			0.25, -- Air
			0.0, -- Sea
			0.20}; -- Other
	end
	
	return laArray
end
-- Land ratio distribution
function DefaultProdLand.LandRatio()
	local laArray = {
		0, -- Garrison
		13, -- Infantry
		2, -- Motorized
		1, -- Mechanized
		1, -- Armor
		0, -- Militia
		0}; -- Cavalry

	
	return laArray
end
-- Special Forces ratio distribution
function DefaultProdLand.SpecialForcesRatio()
	local laArray = {
		25, -- Land
		1}; -- Special Forces Unit
	
	return laArray
end
-- Air ratio distribution
function DefaultProdLand.AirRatio()
	local laArray = {
		8, -- Fighter
		3, -- CAS
		4, -- Tactical
		0, -- Naval Bomber
		0}; -- Strategic
	
	return laArray
end
-- Flying Bomb/Rocket distribution against total Air Power
function DefaultProdLand.RocketRatio()
	local laArray = {
		10, -- Air
		1}; -- Bomb/Rockety
	
	return laArray
end

-- Naval ratio distribution
function DefaultProdLand.NavalRatio()
	local laArray = {
		0, -- Destroyers
		0, -- Submarines
		0, -- Cruisers
		0, -- Capital
		0, -- Escort Carrier
		0}; -- Carrier
	
	return laArray
end

function DefaultProdLand.TransportLandRatio()
	local laArray = {
		0, -- Land
		0}; -- Transport
	
	return laArray
end


-- Countries Default build weights for mixed based only
local DefaultProdMix = {}

-- Land Brigades vs Air Units ratio
--   If Air Ratio is met AI will shift its Air IC to build land units
function DefaultProdMix.LandToAirRatio()
	local laArray = {
		8, -- Land Briages
		1}; -- Air
	
	return laArray
end

function DefaultProdMix.ProductionWeights()
	local laArray
	
	-- Check to see if manpower is to low
	-- More than 30 brigades so build stuff that does not use manpower
	if (ProductionData.ManpowerTotal < 30 and ProductionData.LandCountTotal > 30)
	or ProductionData.ManpowerTotal < 10 then
		laArray = {
			0.0, -- Land
			0.35, -- Air
			0.35, -- Sea
			0.30}; -- Other	
	elseif ProductionData.ministerCountry:IsAtWar() then
		laArray = {
			0.50, -- Land
			0.25, -- Air
			0.20, -- Sea
			0.05}; -- Other
	else
		laArray = {
			0.40, -- Land
			0.25, -- Air
			0.20, -- Sea
			0.15}; -- Other
	end
	
	return laArray
end
-- Land ratio distribution
function DefaultProdMix.LandRatio()
	local laArray = {
		0, -- Garrison
		13, -- Infantry
		2, -- Motorized
		1, -- Mechanized
		1, -- Armor
		0, -- Militia
		0}; -- Cavalry
	
	return laArray
end
-- Special Forces ratio distribution
function DefaultProdMix.SpecialForcesRatio()
	local laArray = {
		50, -- Land
		1}; -- Special Forces Unit
	
	return laArray
end
-- Air ratio distribution
function DefaultProdMix.AirRatio()
	local laArray = {
		8, -- Fighter
		3, -- CAS
		4, -- Tactical
		1, -- Naval Bomber
		0}; -- Strategic
	
	return laArray
end
-- Flying Bomb/Rocket distribution against total Air Power
function DefaultProdMix.RocketRatio()
	local laArray = {
		10, -- Air
		1}; -- Bomb/Rockety
	
	return laArray
end
-- Naval ratio distribution
function DefaultProdMix.NavalRatio()
	local laArray = {
		6, -- Destroyers
		4, -- Submarines
		4, -- Cruisers
		1, -- Capital
		0, -- Escort Carrier
		0}; -- Carrier
	
	return laArray
end
-- Transport to Land unit distribution
function DefaultProdMix.TransportLandRatio()
	local laArray = {
		20, -- Land
		1}; -- Transport
	
	return laArray
end

-- ######################
-- END OF Default parameters for countries 
-- ######################



-- ########################
-- Oder for Slider Information based on type
-- full ai automation
--	CDistributionSetting._PRODUCTION_CONSUMER_, 
--	CDistributionSetting._PRODUCTION_SUPPLY_,
--	CDistributionSetting._PRODUCTION_REINFORCEMENT_,	
--	CDistributionSetting._PRODUCTION_PRODUCTION_,
--	CDistributionSetting._PRODUCTION_UPGRADE_

-- prio production
--	CDistributionSetting._PRODUCTION_CONSUMER_, 
--	CDistributionSetting._PRODUCTION_SUPPLY_,
--	CDistributionSetting._PRODUCTION_PRODUCTION_,
--	CDistributionSetting._PRODUCTION_REINFORCEMENT_,
--	CDistributionSetting._PRODUCTION_UPGRADE_

-- prio upgrades
--	CDistributionSetting._PRODUCTION_CONSUMER_, 
--	CDistributionSetting._PRODUCTION_SUPPLY_,
--	CDistributionSetting._PRODUCTION_UPGRADE_,
--	CDistributionSetting._PRODUCTION_REINFORCEMENT_,	
--	CDistributionSetting._PRODUCTION_PRODUCTION_

-- prio reinforcement
--	CDistributionSetting._PRODUCTION_CONSUMER_, 
--	CDistributionSetting._PRODUCTION_SUPPLY_,
--	CDistributionSetting._PRODUCTION_REINFORCEMENT_,	
--	CDistributionSetting._PRODUCTION_PRODUCTION_,
--	CDistributionSetting._PRODUCTION_UPGRADE_

-- prio special reinforcement case
--	CDistributionSetting._PRODUCTION_REINFORCEMENT_,	
--	CDistributionSetting._PRODUCTION_CONSUMER_, 
--	CDistributionSetting._PRODUCTION_SUPPLY_,
--	CDistributionSetting._PRODUCTION_PRODUCTION_,
--	CDistributionSetting._PRODUCTION_UPGRADE_

-- ###################################
-- # Main Method called by the EXE
-- #####################################
function BalanceProductionSliders(ai, ministerCountry, prioSelection,
                                  vConsumer, vProduction, vSupply, vReinforce, vUpgrade, bHasReinforceBonus, lbIsMajor)
	--COUNTRY_DEBUG(ministerCountry, "Determining Production AI to use.")
	
	-- Determine if we should use the MOD's Minor Countries AI logic instead of Paradox's
	-- We determine this by checking if the country is a major.
	if IsMajorPower(ministerCountry) then
		BalanceProductionSliders_Standard_AI(ai, ministerCountry, prioSelection,
                               vConsumer, vProduction, vSupply, vReinforce, vUpgrade, bHasReinforceBonus, lbIsMajor)
	else
		BalanceProductionSliders_Modded_AI(ai, ministerCountry, prioSelection,
                                  vConsumer, vProduction, vSupply, vReinforce, vUpgrade, bHasReinforceBonus, lbIsMajor)
	end
end

function BalanceProductionSliders_Standard_AI(ai, ministerCountry, prioSelection,
                                  vConsumer, vProduction, vSupply, vReinforce, vUpgrade, bHasReinforceBonus, lbIsMajor)
	local liOrigPrio = prioSelection
	
	-- If country just started mobilizing (or gets bonus reinforcements for some other reason), boost reinforcements
	if ( prioSelection == 0 or prioSelection == 3 )then
		--local reinforcement_multiplier = ministerCountry:CalculateReinforcementMultiplier():Get()
		--if reinforcement_multiplier > 1.0 then
		if bHasReinforceBonus then
			prioSelection = 4
		end
	end
	
	local vConsumerOriginal = vConsumer
	local vProductionOriginal = vProduction
	local vSupplyOriginal = vSupply
	local vReinforceOriginal = vReinforce
	local vUpgradeOriginal = vUpgrade
	local lbAtWar = ministerCountry:IsAtWar()
	
	-- If Dissent is present add 10% to the Production of Consumer Goods
	local dissent = ministerCountry:GetDissent():Get()
	if dissent > 0.01 then -- fight dissent 
		vConsumer = vConsumer + 0.1
	end
	
	-- Performance check make sure its above 0 before we even look at this
	if vSupply > 0 then
		local supplyStockpile = ministerCountry:GetPool():Get( CGoodsPool._SUPPLIES_ ):Get()
		--local weeksSupplyUse = ministerCountry:GetDailyExpense( CGoodsPool._SUPPLIES_ ):Get() * 7
	
		-- Major power check
		if lbIsMajor then
			-- Shut supply production down
			if supplyStockpile > 50000 then
				vSupply = 0

			-- To many go down 50 percent
			elseif supplyStockpile > 40000 then
				vSupply = vSupply * 0.5
				
			-- To many go down 60 percent
			elseif supplyStockpile > 37000 then
				vSupply = vSupply * 0.6
				
			-- To many go down 70 percent
			elseif supplyStockpile > 35000 then
				vSupply = vSupply * 0.7

			-- Decent slowly 99 percent
			elseif supplyStockpile > 32000 then
				vSupply = vSupply * 0.99

			-- Try to kee it steady 100 percent
			elseif supplyStockpile > 30000 then
				vSupply = vSupply

			-- Short on Supplies produce 115 percent
			elseif supplyStockpile > 28000 then
				vSupply = vSupply * 1.02
				
			-- Short on Supplies produce 115 percent
			elseif supplyStockpile > 22000 then
				vSupply = vSupply * 1.15

			-- Short on Supplies produce 125 percent
			else
				vSupply = vSupply * 1.25
				
			end
		else
			-- Stockpile to high cut it off
			if supplyStockpile > 5000 then
				vSupply = 0

			-- To many go down 40 percent
			elseif supplyStockpile > 4000 then
				vSupply = vSupply * 0.4
				
			-- To many go down 40 percent
			elseif supplyStockpile > 3700 then
				vSupply = vSupply * 0.5
				
			-- To many go down 60 percent
			elseif supplyStockpile > 3500 then
				vSupply = vSupply * 0.6

			-- Decent slowly 99 percent
			elseif supplyStockpile > 3200 then
				vSupply = vSupply * 0.99

			-- Try to kee it steady 100 percent
			elseif supplyStockpile > 3000 then
				vSupply = vSupply

			-- Short on Supplies produce 102 percent
			elseif supplyStockpile > 2800 then
				vSupply = vSupply * 1.02
				
			-- Short on Supplies produce 115 percent
			elseif supplyStockpile > 2200 then
				vSupply = vSupply * 1.15

			-- Short on Supplies produce 125 percent
			else
				vSupply = vSupply * 1.25
				
			end
		end
	end
	
	-- Normalize the percentages based on priority so the total does not exceed 1.0 (100%)
	--local changes = { [0] = vConsumer, vProduction, vSupply, vReinforce, vUpgrade }
	--local factor_left = 1
	--for i = 0, 5 do -- normalize
	--	local index = PRIO_SETTINGS[prioSelection][i]
	--	local factor = changes[ index ] + 0.00005 -- stop dumb roundoff errors
	--	factor = math.min(factor, factor_left)
	--	factor_left = math.max(factor_left - factor, 0.0)
	--	changes[ index ] = factor
	--end
	
	-- observe this uses the original prio orders from PRIO_SETTING, so if you mod that you cant use this function
	-- and have to roll the commented out code above
	local vConsumer, vProduction, vSupply, vReinforce, vUpgrade, factor_left = CAI.FastNormalizeByPriority( prioSelection, vConsumer, vProduction, vSupply, vReinforce, vUpgrade )
	
	--factor_left = math.max(factor_left, 0.0)
	if liOrigPrio == 0 then

		local liProdUpgradeTotalPercentage = vUpgrade + vProduction + factor_left
		
		-- If the total needed for Upgrading exceedes the total amount available between
		--   Production and Upgrades then divide the number in half so something gets produced.
		if (vUpgradeOriginal > liProdUpgradeTotalPercentage or 
		    vUpgradeOriginal > (liProdUpgradeTotalPercentage / 2))
		then
			vUpgrade = (liProdUpgradeTotalPercentage / 2)
			vProduction = (liProdUpgradeTotalPercentage / 2)

		-- Upgrades is covered put everything extra into Production
		else
			vUpgrade = vUpgradeOriginal
			vProduction = liProdUpgradeTotalPercentage - vUpgradeOriginal
		end
	else
		-- We have some dessent so put extra IC to lower it
		if dissent > 0.01 then
			vConsumer = vConsumer + factor_left
		else
			vProduction = vProduction + factor_left
		end
	end

	local checksum = math.abs(vConsumer - vConsumerOriginal) + 
	                 math.abs(vProduction - vProductionOriginal) +
					 math.abs(vSupply - vSupplyOriginal) +
					 math.abs(vReinforce - vReinforceOriginal) +
					 math.abs(vUpgrade - vUpgradeOriginal)
	if checksum > 0.01 then
		local command = CChangeInvestmentCommand( ministerCountry:GetCountryTag(), vConsumer, vProduction, vSupply, vReinforce, vUpgrade )
		ai:Post( command )
	end
end


-- ###################################
-- # Main Method called by the EXE
-- #####################################
function ProductionMinister_Tick(minister)
	local ministerCountry = minister:GetCountry()
	--COUNTRY_DEBUG(ministerCountry, "Determining Production AI to use.")
	local ICAllocated = ministerCountry:GetICPart(CDistributionSetting._PRODUCTION_PRODUCTION_):Get()
	local ICUsed = ministerCountry:GetUsedIC():Get()
	local ICAvailable = ICAllocated - ICUsed
	
	-- Performance check
	--   if no IC just exit completely so no objects get created
	if ICAvailable <= 0.2 then
		return
	end
	--COUNTRY_DEBUG(ministerCountry, "Passed optimization checks")
	-- Determine if we should use the MOD's Minor Countries AI logic instead of Paradox's
	-- We determine this by checking if the country is a major.
	if IsMajorPower(ministerCountry) then
		ProductionMinister_Tick_Standard_AI(minister)
	else
		ProductionMinister_Tick_Modded_AI(minister)
	end
end

function ProductionMinister_Tick_Standard_AI(minister)
	-- Reset Global Array Container
	ProductionData = {
		minister = minister,
		ministerAI = minister:GetOwnerAI(),
		ministerTag = minister:GetCountryTag(),
		ministerCountry = minister:GetCountry(),
		IsAtWar = nil,
		IsMajor = nil,
		TechStatus = nil,
		BuildingCounts = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		CurrentCounts = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		UnitNeeds = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		LandCountTotal = 0,
		AirCountTotal = 0,
		NavalCountTotal = 0,
		icTotal = nil,
		icAllocated = nil,
		icAvailable = nil,
		PortsTotal = 0,
		AirfieldsTotal = 0,
		ManpowerMobilize = nil,
		ManpowerTotal = 0,
		ManpowerCap = 0, -- Coming Soon
		BuiltRocketSite = false}
	
	ProductionData.TechStatus = ProductionData.ministerCountry:GetTechnologyStatus()
	ProductionData.icAllocated = ProductionData.ministerCountry:GetICPart(CDistributionSetting._PRODUCTION_PRODUCTION_):Get()
	ProductionData.icAvailable = ProductionData.icAllocated - ProductionData.ministerCountry:GetUsedIC():Get()
	ProductionData.ManpowerMobilize = ProductionData.ministerCountry:HasExtraManpowerLeft()
	ProductionData.PortsTotal = ProductionData.ministerCountry:GetNumOfPorts()
	ProductionData.icTotal = ProductionData.ministerCountry:GetTotalIC()
	ProductionData.AirfieldsTotal = ProductionData.ministerCountry:GetNumOfAirfields()
	ProductionData.IsAtWar = ProductionData.ministerCountry:IsAtWar()
	ProductionData.IsMajor = ProductionData.ministerCountry:IsMajor()
	ProductionData.ManpowerTotal = ProductionData.ministerCountry:GetManpower():Get()
	
	-- Performance check
	--   if no IC just exit completely so no objects get created
	if ProductionData.icAvailable <= 0.2 then
		return
	end
	
	-- Check to make sure IC is not being reported incorrectly
	--    if so then exit and wait till the next pass.
	if ProductionData.IsMajor
	and ProductionData.icTotal == ProductionData.icAllocated then
		return
	end

	-- Build Convoys first above all (they count against Other toward the end
	ProductionData.icAvailable = ConstructConvoys(ProductionData.icAvailable)
	
	-- Check to make sure they have Manpower
	--    IC check added for performance. If none dont bother executing.
	if ProductionData.ManpowerMobilize then
		--Utils.LUA_DEBUGOUT("Country: " .. tostring(minister:GetCountryTag()))
		--Utils.LUA_DEBUGOUT("IC: " .. tostring(ministerCountry:GetTotalIC()))
		
		-- Get the counts of the unit types currently being produced
		local laTempProd = ProductionData.ministerAI:GetProductionSubUnitCounts()
		local laTempCurrent = ProductionData.ministerAI:GetDeployedSubUnitCounts()
		--local laTempTReq = ProductionData.ministerAI:GetTheatreSubUnitNeedCounts()
		
		for subUnit in CSubUnitDataBase.GetSubUnitList() do
			local nIndex = subUnit:GetIndex()
			local lsUnitType = subUnit:GetKey():GetString() 
			
			if lsUnitType == "infantry_brigade" then
				ProductionData.BuildingCounts[_INFANTRY_BRIGADE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_INFANTRY_BRIGADE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "light_armor_brigade" then
				ProductionData.BuildingCounts[_LIGHT_ARMOR_BRIGADE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_LIGHT_ARMOR_BRIGADE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "armor_brigade" then
				ProductionData.BuildingCounts[_ARMOR_BRIGADE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_ARMOR_BRIGADE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "bergsjaeger_brigade" then
				ProductionData.BuildingCounts[_BERGSJAEGER_BRIGADE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_BERGSJAEGER_BRIGADE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "cavalry_brigade" then
				ProductionData.BuildingCounts[_CAVALRY_BRIGADE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_CAVALRY_BRIGADE_] = laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "garrison_brigade" then
				ProductionData.BuildingCounts[_GARRISON_BRIGADE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_GARRISON_BRIGADE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "heavy_armor_brigade" then
				ProductionData.BuildingCounts[_HEAVY_ARMOR_BRIGADE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_HEAVY_ARMOR_BRIGADE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "marine_brigade" then
				ProductionData.BuildingCounts[_MARINE_BRIGADE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_MARINE_BRIGADE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "mechanized_brigade" then
				ProductionData.BuildingCounts[_MECHANIZED_BRIGADE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_MECHANIZED_BRIGADE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "militia_brigade" then
				ProductionData.BuildingCounts[_MILITIA_BRIGADE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_MILITIA_BRIGADE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "motorized_brigade" then
				ProductionData.BuildingCounts[_MOTORIZED_BRIGADE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_MOTORIZED_BRIGADE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "paratrooper_brigade" then
				ProductionData.BuildingCounts[_PARATROOPER_BRIGADE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_PARATROOPER_BRIGADE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "super_heavy_armor_brigade" then
				ProductionData.BuildingCounts[_SUPER_HEAVY_ARMOR_BRIGADE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_SUPER_HEAVY_ARMOR_BRIGADE_] =  laTempCurrent:GetAt(nIndex)
			
			-- Start Naval Unit counts
			elseif lsUnitType == "battlecruiser" then
				ProductionData.BuildingCounts[_BATTLECRUISER_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_BATTLECRUISER_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "battleship" then
				ProductionData.BuildingCounts[_BATTLESHIP_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_BATTLESHIP_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "carrier" then
				ProductionData.BuildingCounts[_CARRIER_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_CARRIER_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "destroyer" then
				ProductionData.BuildingCounts[_DESTROYER_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_DESTROYER_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "escort_carrier" then
				ProductionData.BuildingCounts[_ESCORT_CARRIER_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_ESCORT_CARRIER_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "heavy_cruiser" then
				ProductionData.BuildingCounts[_HEAVY_CRUISER_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_HEAVY_CRUISER_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "light_cruiser" then
				ProductionData.BuildingCounts[_LIGHT_CRUISER_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_LIGHT_CRUISER_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "nuclear_submarine" then
				ProductionData.BuildingCounts[_NUCLEAR_SUBMARINE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_NUCLEAR_SUBMARINE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "submarine" then
				ProductionData.BuildingCounts[_SUBMARINE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_SUBMARINE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "super_heavy_battleship" then
				ProductionData.BuildingCounts[_SUPER_HEAVY_BATTLESHIP_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_SUPER_HEAVY_BATTLESHIP_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "transport_ship" then
				ProductionData.BuildingCounts[_TRANSPORT_SHIP_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_TRANSPORT_SHIP_] =  laTempCurrent:GetAt(nIndex)
				
			-- Start Air Unit counts
			elseif lsUnitType == "cag" then
				ProductionData.BuildingCounts[_CAG_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_CAG_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "cas" then
				ProductionData.BuildingCounts[_CAS_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_CAS_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "interceptor" then
				ProductionData.BuildingCounts[_INTERCEPTOR_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_INTERCEPTOR_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "multi_role" then
				ProductionData.BuildingCounts[_MULTI_ROLE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_MULTI_ROLE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "naval_bomber" then
				ProductionData.BuildingCounts[_NAVAL_BOMBER_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_NAVAL_BOMBER_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "strategic_bomber" then
				ProductionData.BuildingCounts[_STRATEGIC_BOMBER_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_STRATEGIC_BOMBER_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "tactical_bomber" then
				ProductionData.BuildingCounts[_TACTICAL_BOMBER_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_TACTICAL_BOMBER_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "transport_plane" then
				ProductionData.BuildingCounts[_TRANSPORT_PLANE_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_TRANSPORT_PLANE_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "flying_bomb" then
				ProductionData.BuildingCounts[_FLYING_BOMB_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_FLYING_BOMB_] =  laTempCurrent:GetAt(nIndex)
			elseif lsUnitType == "flying_rocket" then
				ProductionData.BuildingCounts[_FLYING_ROCKET_] = laTempProd:GetAt(nIndex)
				ProductionData.CurrentCounts[_FLYING_ROCKET_] =  laTempCurrent:GetAt(nIndex)
			end
		end	
		
		ProductionData.LandCountTotal = GetUnitCount(_GARRISON_BRIGADE_, _POLICE_BRIGADE_)
		ProductionData.AirCountTotal = GetUnitCount(_CAS_, _TRANSPORT_PLANE_)
		ProductionData.NavalCountTotal = GetUnitCount(_BATTLECRUISER_, _TRANSPORT_SHIP_)
		-- End of Counting
		
		local lbNaval = (ProductionData.PortsTotal > 0 and ProductionData.icTotal >= 20)
		local lbAir = (ProductionData.AirfieldsTotal > 0)
		
		local laProdWeights = GetBuildRatio(lbNaval, "ProductionWeights")
		local laLandRatio = GetBuildRatio(lbNaval, "LandRatio")
		local laSpecialForcesRatio = GetBuildRatio(lbNaval, "SpecialForcesRatio")
		local laAirRatio = GetBuildRatio(lbNaval, "AirRatio")
		local laRocketRatio = GetBuildRatio(lbNaval, "RocketRatio")
		local laNavalRatio = GetBuildRatio(lbNaval, "NavalRatio")
		local laLandToAirRatio = GetBuildRatio(lbNaval, "LandToAirRatio")
		local laTransportLandRatio = GetBuildRatio(lbNaval, "TransportLandRatio")
		
		-- If no air fields set all of its ratios to 0 so the Air power code does not fire
		if not(lbAir) then
			for i = 1, table.getn(laAirRatio) do
				laAirRatio[i] = 0
			end
			
			-- Land Ratio is already 0 probably failed manpower check so move it to other
			if laProdWeights[1] > 0 then
				laProdWeights[4] = laProdWeights[1] + laProdWeights[2]
			else
				-- Now move the Air IC over to the Land section
				laProdWeights[1] = laProdWeights[1] + laProdWeights[2]
			end
		end
		
		-- Figure out how much IC is suppose to be designated in the appropriate area
		local liPotentialLandIC = tonumber(tostring(ProductionData.icAllocated * laProdWeights[1]))
		local liPotentialAirIC = tonumber(tostring(ProductionData.icAllocated * laProdWeights[2]))
		local liPotentialNavalIC = tonumber(tostring(ProductionData.icAllocated * laProdWeights[3]))
		local liPotentialOtherIC = tonumber(tostring(ProductionData.icAllocated * laProdWeights[4]))
		
		local liNeededLandIC = 0
		local liNeededAirIC = 0
		local liNeededNavalIC = 0
		local liNeededOtherIC = 0
		
		-- Verify Build Ratios against avaialbe units
		if Utils.HasCountryAIFunction( ProductionData.ministerTag, "_LandRatio_Units_") then
			laLandRatio = VerifyRatio(laLandRatio, Utils.CallCountryAI(ProductionData.ministerTag, "_LandRatio_Units_", ProductionData.minister))
		else
			laLandRatio = VerifyRatio(laLandRatio, _LandRatio_Units_)
		end

		if Utils.HasCountryAIFunction( ProductionData.ministerTag, "_AirRatio_Units_") then
			laAirRatio = VerifyRatio(laAirRatio, Utils.CallCountryAI(ProductionData.ministerTag, "_AirRatio_Units_", ProductionData.minister))
		else
			laAirRatio = VerifyRatio(laAirRatio, _AirRatio_Units_)
		end
		
		if Utils.HasCountryAIFunction( ProductionData.ministerTag, "_NavalRatio_Units_") then
			laNavalRatio = VerifyRatio(laNavalRatio, Utils.CallCountryAI(ProductionData.ministerTag, "_NavalRatio_Units_", ProductionData.minister))
		else
			laNavalRatio = VerifyRatio(laNavalRatio, _NavalRatio_Units_)
		end
		
		
		-- Figure out what the AI is currently producin in each category
		for loBuildItem in ProductionData.ministerCountry:GetConstructions() do
			if loBuildItem:IsMilitary() then
				local loMilitary = loBuildItem:GetMilitary()
				
				if loMilitary:IsLand() then
					liNeededLandIC = liNeededLandIC + loBuildItem:GetCost()
				elseif loMilitary:IsAir() then
					for loConstDef in loMilitary:GetBrigades() do
						local loSubUnit = loConstDef:GetType()
						
						-- If it is a cag add it to naval IC count instead of air
						if loSubUnit:IsCag() then
							liNeededNavalIC = liNeededNavalIC + loBuildItem:GetCost()
						else
							liNeededAirIC = liNeededAirIC + loBuildItem:GetCost()
						end
						
						-- Exit the loop right away
						break
					end
				elseif loMilitary:IsNaval() then
					liNeededNavalIC = liNeededNavalIC + loBuildItem:GetCost()
				end
			else
				liNeededOtherIC = liNeededOtherIC + loBuildItem:GetCost()
			end
		end
		
		-- Now figure out what it needs
		liNeededLandIC = liPotentialLandIC - liNeededLandIC
		liNeededAirIC = liPotentialAirIC - liNeededAirIC
		liNeededNavalIC = liPotentialNavalIC - liNeededNavalIC
		liNeededOtherIC = liPotentialOtherIC - liNeededOtherIC
		
		-- Normalize the IC counts in case of shifts
		local liOverIC = 0
		
		-- Variables are negative numbers so add them
		if liNeededLandIC < 0 then
			liOverIC = liOverIC + liNeededLandIC
		end
		if liNeededAirIC < 0 then
			liOverIC = liOverIC + liNeededAirIC
		end
		if liNeededNavalIC < 0 then
			liOverIC = liOverIC + liNeededNavalIC
		end
		if liNeededOtherIC < 0 then
			liOverIC = liOverIC + liNeededOtherIC
		end

		if liOverIC > 0 then
			if liNeededNavalIC > 0 and liOverIC > 0 then
				if liNeededNavalIC >= liOverIC then
					liNeededNavalIC = liNeededNavalIC - liOverIC
					liOverIC = 0
				else
					liOverIC = liOverIC - liNeededNavalIC
					liNeededNavalIC = 0
				end
			end
			if liNeededAirIC > 0 and liOverIC > 0 then
				if liNeededAirIC >= liOverIC then
					liNeededAirIC = liNeededAirIC - liOverIC
					liOverIC = 0
				else
					liOverIC = liOverIC - liNeededAirIC
					liNeededAirIC = 0
				end
			end
			if liNeededLandIC > 0 and liOverIC > 0 then
				if liNeededLandIC >= liOverIC then
					liNeededLandIC = liNeededLandIC - liOverIC
					liOverIC = 0
				else
					liOverIC = liOverIC - liNeededLandIC
					liNeededLandIC = 0
				end
			end
			if liNeededOtherIC > 0 and liOverIC > 0 then
				if liNeededOtherIC >= liOverIC then
					liNeededOtherIC = liNeededOtherIC - liOverIC
					liOverIC = 0
				else
					liOverIC = liOverIC - liNeededOtherIC
					liNeededOtherIC = 0
				end
			end			
		end
		-- End of IC Normalization
		
		-- Process Land Units
		-- Used to figure out Air to Land Ratio
		local liTotalLandRatio = CalculateRatio(GetUnitCount(_GARRISON_BRIGADE_, _POLICE_BRIGADE_), laLandToAirRatio[1])
		local liTotalAirRatio = CalculateRatio(GetUnitCount(_CAS_, _TRANSPORT_PLANE_), laLandToAirRatio[2])
		
		-- If the Air ratio is higher than the Land ration then move all the Air IC into Land
		if liTotalAirRatio > liTotalLandRatio then
			liNeededLandIC = liNeededLandIC + liNeededAirIC
			liNeededAirIC = 0
		end
		
		--    PERFORMANCE: only process if IC has been allocated
		local laLandUnitRatio = {}
		--       Naval check is adding for Convoy ratio calculating.
		if liNeededLandIC > 0 or liNeededNavalIC > 0 then
			--    Array order Garrison, Infantry, Motorized, Mechanized, Armor
			local laLandUnitCount = {}
			laLandUnitCount[1] = ProductionData.BuildingCounts[_GARRISON_BRIGADE_] + ProductionData.CurrentCounts[_GARRISON_BRIGADE_]
			laLandUnitCount[2] = GetUnitCount(_INFANTRY_BRIGADE_, _PARATROOPER_BRIGADE_)
			laLandUnitCount[3] = ProductionData.BuildingCounts[_MOTORIZED_BRIGADE_] + ProductionData.CurrentCounts[_MOTORIZED_BRIGADE_]
			laLandUnitCount[4] = ProductionData.BuildingCounts[_MECHANIZED_BRIGADE_] + ProductionData.CurrentCounts[_MECHANIZED_BRIGADE_]
			laLandUnitCount[5] = GetUnitCount(_LIGHT_ARMOR_BRIGADE_, _SUPER_HEAVY_ARMOR_BRIGADE_)
			laLandUnitCount[6] = ProductionData.BuildingCounts[_MILITIA_BRIGADE_] + ProductionData.CurrentCounts[_MILITIA_BRIGADE_]
			laLandUnitCount[7] = ProductionData.BuildingCounts[_CAVALRY_BRIGADE_] + ProductionData.CurrentCounts[_CAVALRY_BRIGADE_]

			-- PERFORMANCE: Make sure you need the rest of this to run
			if liNeededLandIC > 0 then
				laLandUnitRatio[1] = CalculateRatio(laLandUnitCount[1], laLandRatio[1])
				laLandUnitRatio[2] = CalculateRatio(laLandUnitCount[2], laLandRatio[2])
				laLandUnitRatio[3] = CalculateRatio(laLandUnitCount[3], laLandRatio[3])
				laLandUnitRatio[4] = CalculateRatio(laLandUnitCount[4], laLandRatio[4])
				laLandUnitRatio[5] = CalculateRatio(laLandUnitCount[5], laLandRatio[5])
				laLandUnitRatio[6] = CalculateRatio(laLandUnitCount[6], laLandRatio[6])
				laLandUnitRatio[7] = CalculateRatio(laLandUnitCount[7], laLandRatio[7])
				
				-- Multiplier used to figure out how many units of each type you need
				--   to keep the ratio
				local liMultiplier = GetMultiplier(laLandUnitRatio, laLandRatio)
				
				local laLandUnitNeed = {}
				laLandUnitNeed[1] = (laLandRatio[1] * liMultiplier) - laLandUnitCount[1]
				laLandUnitNeed[2] = (laLandRatio[2] * liMultiplier) - laLandUnitCount[2]
				laLandUnitNeed[3] = (laLandRatio[3] * liMultiplier) - laLandUnitCount[3]
				laLandUnitNeed[4] = (laLandRatio[4] * liMultiplier) - laLandUnitCount[4]
				laLandUnitNeed[5] = (laLandRatio[5] * liMultiplier) - laLandUnitCount[5]
				laLandUnitNeed[6] = (laLandRatio[6] * liMultiplier) - laLandUnitCount[6]
				laLandUnitNeed[7] = (laLandRatio[7] * liMultiplier) - laLandUnitCount[7]
				
				ProductionData.UnitNeeds[_GARRISON_BRIGADE_] = laLandUnitNeed[1]
				ProductionData.UnitNeeds[_INFANTRY_BRIGADE_] = laLandUnitNeed[2]
				ProductionData.UnitNeeds[_MOTORIZED_BRIGADE_] = laLandUnitNeed[3]
				ProductionData.UnitNeeds[_MECHANIZED_BRIGADE_] = laLandUnitNeed[4]
				
				-- Armor
				if laLandUnitNeed[5] > 0 then
					local lbLA = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("light_armor_brigade"))
					local lbA = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("armor_brigade"))
					local lbHA = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("heavy_armor_brigade"))
					local lbSHA = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("super_heavy_armor_brigade"))

					local liArmorCount = GetUnitCount(_LIGHT_ARMOR_BRIGADE_, _ARMOR_BRIGADE_)
					local liHeavyCount = GetUnitCount(_HEAVY_ARMOR_BRIGADE_, _SUPER_HEAVY_ARMOR_BRIGADE_)

					-- Helps prevent the AI from mass building Heavy Armor
					local liHeavyShiftBalancer = (liArmorCount - (liHeavyCount * 2)) * 0.01
					
					if lbLA and lbA and lbHA and lbSHA then
						-- Makes it almost impossible for the AI to build Light Armor since he has better techs
						local liShift = ((math.random(1, 10)) * 0.01) - liHeavyShiftBalancer
						ProductionData.UnitNeeds[_LIGHT_ARMOR_BRIGADE_] = Utils.Round(laLandUnitNeed[5] * liShift)
						
						-- Makes it more likely that Armor will be built over heavy
						liShift = ((math.random(40, 60)) * 0.01) - liHeavyShiftBalancer
						ProductionData.UnitNeeds[_ARMOR_BRIGADE_] = Utils.Round((laLandUnitNeed[5] - ProductionData.UnitNeeds[_LIGHT_ARMOR_BRIGADE_]) * liShift)
						
						local liUnitsLeft = laLandUnitNeed[5] - ProductionData.UnitNeeds[_ARMOR_BRIGADE_] - ProductionData.UnitNeeds[_LIGHT_ARMOR_BRIGADE_]
						if liUnitsLeft > 0 then
							-- Makes it so Heavy is more than likely built over Super
							liShift = (math.random(40, 60)) * 0.01
							ProductionData.UnitNeeds[_HEAVY_ARMOR_BRIGADE_] = Utils.Round(liUnitsLeft * liShift)
							ProductionData.UnitNeeds[_SUPER_HEAVY_ARMOR_BRIGADE_] = Utils.Round(liUnitsLeft * (1 - liShift))
						end
					elseif lbLA and lbA and lbHA then
						-- Makes it almost impossible for the AI to build Light Armor since he has better techs
						local liShift = ((math.random(1, 10)) * 0.01) - liHeavyShiftBalancer
						ProductionData.UnitNeeds[_LIGHT_ARMOR_BRIGADE_] = Utils.Round(laLandUnitNeed[5] * liShift)
						
						-- Makes it more likely that Armor will be built over heavy
						liShift = ((math.random(40, 60)) * 0.01) - liHeavyShiftBalancer
						local liUnitsLeft = laLandUnitNeed[5] - ProductionData.UnitNeeds[_LIGHT_ARMOR_BRIGADE_]
						ProductionData.UnitNeeds[_ARMOR_BRIGADE_] = Utils.Round(liUnitsLeft * liShift)
						ProductionData.UnitNeeds[_HEAVY_ARMOR_BRIGADE_] = Utils.Round(liUnitsLeft * (1 - liShift))
					elseif lbLA and lbA then
						local liShift = (math.random(5, 20)) * 0.01
						ProductionData.UnitNeeds[_LIGHT_ARMOR_BRIGADE_] = Utils.Round(laLandUnitNeed[5] * liShift)
						ProductionData.UnitNeeds[_ARMOR_BRIGADE_] = Utils.Round(laLandUnitNeed[5] * (1 - liShift))				
					elseif lbLA then
						ProductionData.UnitNeeds[_LIGHT_ARMOR_BRIGADE_] = laLandUnitNeed[5]
					end
				end
				
				ProductionData.UnitNeeds[_MILITIA_BRIGADE_] = laLandUnitNeed[6]
				ProductionData.UnitNeeds[_CAVALRY_BRIGADE_] = laLandUnitNeed[7]
				
				-- Special Forces
				-- Calculate how many Special Forces are needed
				local liTotalSFNeeded = 0

				if laSpecialForcesRatio[2] > 0 then
					local liTotalSFUnits = GetUnitCount(_BERGSJAEGER_BRIGADE_, _PARATROOPER_BRIGADE_)
					liTotalSFNeeded = math.max(0, math.ceil((ProductionData.LandCountTotal / laSpecialForcesRatio[1]) * laSpecialForcesRatio[2]) - liTotalSFUnits)
				end
				
				if liTotalSFNeeded > 0 then
					local lbMo = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("bergsjaeger_brigade"))
					local lbMa = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("marine_brigade"))
					local lbPa = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("paratrooper_brigade"))
					
					local liMountainTotal = ProductionData.BuildingCounts[_BERGSJAEGER_BRIGADE_] + ProductionData.CurrentCounts[_BERGSJAEGER_BRIGADE_]
					local liMarineTotal = ProductionData.BuildingCounts[_MARINE_BRIGADE_] + ProductionData.CurrentCounts[_MARINE_BRIGADE_]
					local liParaTotal = ProductionData.BuildingCounts[_PARATROOPER_BRIGADE_] + ProductionData.CurrentCounts[_PARATROOPER_BRIGADE_]

					-- Helps prevent the AI from mass build paratroopers
					local liParaMultiplier = 3
					local liParaShiftBalancer = ((liMountainTotal + liMarineTotal) - (liParaTotal * liParaMultiplier)) * 0.01
					local liMarineShiftBalancer = (liMountainTotal - liMarineTotal) * 0.01
					
					if lbMo and lbMa and lbPa then
						-- Elastic random makes it more than likely mountain units will get build
						local liParasNeeded = ((liMountainTotal + liMarineTotal) - (liParaTotal * liParaMultiplier)) / liParaMultiplier
						liParasNeeded = math.min(liParasNeeded, liTotalSFNeeded)
					
						if liParasNeeded > liParaMultiplier then
							ProductionData.UnitNeeds[_PARATROOPER_BRIGADE_] = Utils.Round(liParasNeeded)
							liTotalSFNeeded = liTotalSFNeeded - liParasNeeded
						end
						
						if liTotalSFNeeded > 0 then
							-- Elastic random makes it more than likely mountain units will get build
							local liShift = ((math.random(40, 60)) * 0.01) - liMarineShiftBalancer
							ProductionData.UnitNeeds[_BERGSJAEGER_BRIGADE_] = Utils.Round(liTotalSFNeeded * liShift)
							ProductionData.UnitNeeds[_MARINE_BRIGADE_] = Utils.Round(liTotalSFNeeded * (1 - liShift))
						end
					elseif lbMo and lbMa then
						-- Elastic random makes it more than likely mountain units will get build
						local liShift = ((math.random(40, 60)) * 0.01) - liMarineShiftBalancer
						ProductionData.UnitNeeds[_BERGSJAEGER_BRIGADE_] = Utils.Round(liTotalSFNeeded * liShift)
						ProductionData.UnitNeeds[_MARINE_BRIGADE_] = Utils.Round(liTotalSFNeeded * (1 - liShift))
					elseif lbMo and lbPa then
						-- Elastic random makes it more than likely mountain units will get build
						local liShift = ((math.random(40, 90)) * 0.01) - liParaShiftBalancer
						ProductionData.UnitNeeds[_BERGSJAEGER_BRIGADE_] = Utils.Round(liTotalSFNeeded * liShift)
						ProductionData.UnitNeeds[_PARATROOPER_BRIGADE_] = Utils.Round(liTotalSFNeeded * (1 - liShift))
					elseif lbMa and lbPa then
						-- Elastic random makes it more than likely marines will get build
						local liShift = ((math.random(40, 90)) * 0.01) - liParaShiftBalancer
						ProductionData.UnitNeeds[_MARINE_BRIGADE_] = Utils.Round(liTotalSFNeeded * liShift)
						ProductionData.UnitNeeds[_PARATROOPER_BRIGADE_] = Utils.Round(liTotalSFNeeded * (1 - liShift))
					elseif lbMo then
						ProductionData.UnitNeeds[_BERGSJAEGER_BRIGADE_] = liTotalSFNeeded
					elseif lbMa then
						ProductionData.UnitNeeds[_MARINE_BRIGADE_] = liTotalSFNeeded
					elseif lbPa then
						ProductionData.UnitNeeds[_PARATROOPER_BRIGADE_] = liTotalSFNeeded
					end
				end	
			end
		end
		
		-- Process Air Units
		local laAirUnitRatio = {}
		
		--    PERFORMANCE: only process if IC has been allocated
		if liNeededAirIC > 0 then
			--    Array order Fighter, CAS, Tactical, Naval Bomber, Strategic
			local laAirUnitCount = {}
			laAirUnitCount[1] = GetUnitCount(_INTERCEPTOR_, _ROCKET_INTERCEPTOR_)
			laAirUnitCount[2] = ProductionData.BuildingCounts[_CAS_] + ProductionData.CurrentCounts[_CAS_]
			laAirUnitCount[3] = ProductionData.BuildingCounts[_TACTICAL_BOMBER_] + ProductionData.CurrentCounts[_TACTICAL_BOMBER_]
			laAirUnitCount[4] = ProductionData.BuildingCounts[_NAVAL_BOMBER_] + ProductionData.CurrentCounts[_NAVAL_BOMBER_]
			laAirUnitCount[5] = ProductionData.BuildingCounts[_STRATEGIC_BOMBER_] + ProductionData.CurrentCounts[_STRATEGIC_BOMBER_]
			
			laAirUnitRatio[1] = CalculateRatio(laAirUnitCount[1], laAirRatio[1])
			laAirUnitRatio[2] = CalculateRatio(laAirUnitCount[2], laAirRatio[2])
			laAirUnitRatio[3] = CalculateRatio(laAirUnitCount[3], laAirRatio[3])
			laAirUnitRatio[4] = CalculateRatio(laAirUnitCount[4], laAirRatio[4])
			laAirUnitRatio[5] = CalculateRatio(laAirUnitCount[5], laAirRatio[5])

			liMultiplier = GetMultiplier(laAirUnitRatio, laAirRatio)

			local laAirUnitNeed = {}
			laAirUnitNeed[1] = (laAirRatio[1] * liMultiplier) - laAirUnitCount[1]
			laAirUnitNeed[2] = (laAirRatio[2] * liMultiplier) - laAirUnitCount[2]
			laAirUnitNeed[3] = (laAirRatio[3] * liMultiplier) - laAirUnitCount[3]
			laAirUnitNeed[4] = (laAirRatio[4] * liMultiplier) - laAirUnitCount[4]
			laAirUnitNeed[5] = (laAirRatio[5] * liMultiplier) - laAirUnitCount[5]
			
			-- Fighters/Interceptors
			if laAirUnitNeed[1] > 0 then
				local lbIn = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("interceptor"))
				local lbMf = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("multi_role"))
				local lbRIn = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("rocket_interceptor"))
				
				local liUnitType
			
				if lbIn and lbMf and lbRIn then
					for i = 1, laAirUnitNeed[1] do
						liUnitType = math.random(_INTERCEPTOR_, _ROCKET_INTERCEPTOR_)
						ProductionData.UnitNeeds[liUnitType] = ProductionData.UnitNeeds[liUnitType] + 1
					end	
				elseif lbIn and lbMf then
					for i = 1, laAirUnitNeed[1] do
						liUnitType = math.random(_INTERCEPTOR_, _MULTI_ROLE_)
						ProductionData.UnitNeeds[liUnitType] = ProductionData.UnitNeeds[liUnitType] + 1
					end	
				elseif lbIn then
					ProductionData.UnitNeeds[_INTERCEPTOR_] = laAirUnitNeed[1]
				elseif lbMf then
					ProductionData.UnitNeeds[_MULTI_ROLE_] = laAirUnitNeed[1]
				end
			end
			ProductionData.UnitNeeds[_CAS_] = laAirUnitNeed[2]
			ProductionData.UnitNeeds[_TACTICAL_BOMBER_] = laAirUnitNeed[3]
			ProductionData.UnitNeeds[_NAVAL_BOMBER_] = laAirUnitNeed[4]
			ProductionData.UnitNeeds[_STRATEGIC_BOMBER_] = laAirUnitNeed[5]
			
			-- Do we need Air Transports?
			local liTotalParas = ProductionData.BuildingCounts[_PARATROOPER_BRIGADE_] + ProductionData.CurrentCounts[_PARATROOPER_BRIGADE_]
			
			if liTotalParas > 0 then
				local liTotalAirTrans = ProductionData.BuildingCounts[_TRANSPORT_PLANE_] + ProductionData.CurrentCounts[_TRANSPORT_PLANE_]
				local liTotalAirTransNeeded = math.floor(liTotalParas / 3)
				
				if liTotalAirTransNeeded > liTotalAirTrans then
					ProductionData.UnitNeeds[_TRANSPORT_PLANE_] = liTotalAirTransNeeded - liTotalAirTrans
				end
			end
			
			local loFlyingBomb = CSubUnitDataBase.GetSubUnit("flying_bomb")
			local loFlyingRocket = CSubUnitDataBase.GetSubUnit("flying_rocket")
			
			local lbFlyingBomb = ProductionData.TechStatus:IsUnitAvailable(loFlyingBomb)
			local lbFlyingRocket = ProductionData.TechStatus:IsUnitAvailable(loFlyingRocket)

			-- Calculate how many Flying Weapons are needed			
			if lbFlyingBomb or lbFlyingRocket then
				local liTotalFlyingWeapons = GetUnitCount(_FLYING_BOMB_, _FLYING_ROCKET_)
				
				local liUnitIndex = _FLYING_BOMB_
				
				if lbFlyingRocket then
					liUnitIndex = _FLYING_ROCKET_
				end
				
				ProductionData.UnitNeeds[liUnitIndex] = math.max(0, math.ceil((ProductionData.AirCountTotal / laRocketRatio[1]) * laRocketRatio[2]) - liTotalFlyingWeapons)
			end
		end
			
		-- Process Naval Units
		local laNavalUnitRatio = {} -- This Array is passed to the BuildNavalUnit method
		
		--    PERFORMANCE: only process if IC has been allocated
		if liNeededNavalIC > 0 then
			--    Array order Destroyers, Submarines, Cruisers, Capital, Escort Carrier, Carrier, Transport
			local laNavalUnitCount = {}
			laNavalUnitCount[1] = ProductionData.BuildingCounts[_DESTROYER_] + ProductionData.CurrentCounts[_DESTROYER_]
			laNavalUnitCount[2] = GetUnitCount(_SUBMARINE_, _NUCLEAR_SUBMARINE_)
			laNavalUnitCount[3] = GetUnitCount(_LIGHT_CRUISER_, _HEAVY_CRUISER_)
			laNavalUnitCount[4] = GetUnitCount(_BATTLECRUISER_, _SUPER_HEAVY_BATTLESHIP_)
			laNavalUnitCount[5] = ProductionData.BuildingCounts[_ESCORT_CARRIER_] + ProductionData.CurrentCounts[_ESCORT_CARRIER_]
			laNavalUnitCount[6] = ProductionData.BuildingCounts[_CARRIER_] + ProductionData.CurrentCounts[_CARRIER_]
			
			laNavalUnitRatio[1] = CalculateRatio(laNavalUnitCount[1], laNavalRatio[1])
			laNavalUnitRatio[2] = CalculateRatio(laNavalUnitCount[2], laNavalRatio[2])
			laNavalUnitRatio[3] = CalculateRatio(laNavalUnitCount[3], laNavalRatio[3])
			laNavalUnitRatio[4] = CalculateRatio(laNavalUnitCount[4], laNavalRatio[4])
			laNavalUnitRatio[5] = CalculateRatio(laNavalUnitCount[5], laNavalRatio[5])
			laNavalUnitRatio[6] = CalculateRatio(laNavalUnitCount[6], laNavalRatio[6])
			
			liMultiplier = GetMultiplier(laNavalUnitRatio, laNavalRatio)

			local laNavalUnitNeed = {}
			laNavalUnitNeed[1] = (laNavalRatio[1] * liMultiplier) - laNavalUnitCount[1]
			laNavalUnitNeed[2] = (laNavalRatio[2] * liMultiplier) - laNavalUnitCount[2]
			laNavalUnitNeed[3] = (laNavalRatio[3] * liMultiplier) - laNavalUnitCount[3]
			laNavalUnitNeed[4] = (laNavalRatio[4] * liMultiplier) - laNavalUnitCount[4]
			laNavalUnitNeed[5] = (laNavalRatio[5] * liMultiplier) - laNavalUnitCount[5]
			laNavalUnitNeed[6] = (laNavalRatio[6] * liMultiplier) - laNavalUnitCount[6]
			
			ProductionData.UnitNeeds[_DESTROYER_] = laNavalUnitNeed[1]
			-- Submarine, if you can do nuke shift everthing into Nuclear
			if laNavalUnitNeed[2] > 0 then
				if ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("nuclear_submarine")) then
					ProductionData.UnitNeeds[_NUCLEAR_SUBMARINE_] = laNavalUnitNeed[2]
				else
					ProductionData.UnitNeeds[_SUBMARINE_] = laNavalUnitNeed[2]
				end			
			end
			-- Cruisers Elastic Random for Light and Heavy but leaning to Light
			if laNavalUnitNeed[3] > 0 then
				local lbCL = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("light_cruiser"))
				local lbCH = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("heavy_cruiser"))
			
				local liCLTotal = ProductionData.BuildingCounts[_LIGHT_CRUISER_] + ProductionData.CurrentCounts[_LIGHT_CRUISER_]
				local liCHTotal = ProductionData.BuildingCounts[_HEAVY_CRUISER_] + ProductionData.CurrentCounts[_HEAVY_CRUISER_]
			
				-- Helps prevent the AI from mass building Heavy Armor
				local liHeavyShiftBalancer = (liCLTotal - (liCHTotal * 2)) * 0.01
			
				if lbCL and lbCH then
					-- Elastic Random makes it more than likely Light Cruisers will be built
					local liShift = (math.random(40, 80) * 0.01) - liHeavyShiftBalancer
					ProductionData.UnitNeeds[_LIGHT_CRUISER_] = Utils.Round(laNavalUnitNeed[3] * liShift)
					ProductionData.UnitNeeds[_HEAVY_CRUISER_] = Utils.Round(laNavalUnitNeed[3] * (1 - liShift))
				elseif lbCL then
					ProductionData.UnitNeeds[_LIGHT_CRUISER_] = laNavalUnitNeed[3]
				elseif lbCH then
					ProductionData.UnitNeeds[_HEAVY_CRUISER_] = laNavalUnitNeed[3]
				end
			end
			-- Capital ships, process one a time if need be
			if laNavalUnitNeed[4] > 0 then
				local lbBC = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("battlecruiser"))
				local lbBB = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("battleship"))
				local lbSBB = ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit("super_heavy_battleship"))
				local liUnitType
			
				if lbBC and lbBB and lbSBB then
					for i = 1, laNavalUnitNeed[4] do
						liUnitType = math.random(_BATTLECRUISER_, _SUPER_HEAVY_BATTLESHIP_)
						ProductionData.UnitNeeds[liUnitType] = ProductionData.UnitNeeds[liUnitType] + 1
					end	
				elseif lbBC and lbBB then
					for i = 1, Utils.Round(laNavalUnitNeed[4]) do
						liUnitType = math.random(_BATTLECRUISER_, _BATTLESHIP_)
						ProductionData.UnitNeeds[liUnitType] = ProductionData.UnitNeeds[liUnitType] + 1
					end	
				elseif lbBB and lbSBB then
					for i = 1, laNavalUnitNeed[4] do
						liUnitType = math.random(_BATTLESHIP_, _SUPER_HEAVY_BATTLESHIP_)
						ProductionData.UnitNeeds[liUnitType] = ProductionData.UnitNeeds[liUnitType] + 1
					end	
				elseif lbBC then
					ProductionData.UnitNeeds[_BATTLECRUISER_] = laNavalUnitNeed[4]
				elseif lbBB then
					ProductionData.UnitNeeds[_BATTLESHIP_] = laNavalUnitNeed[4]
				elseif lbSBB then
					ProductionData.UnitNeeds[_SUPER_HEAVY_BATTLESHIP_] = laNavalUnitNeed[4]
				end
			end
			ProductionData.UnitNeeds[_ESCORT_CARRIER_] = laNavalUnitNeed[5]
			ProductionData.UnitNeeds[_CARRIER_] = laNavalUnitNeed[6]
			
			-- Calculate how many Transports are needed
			local liTotalTransports = (ProductionData.BuildingCounts[_TRANSPORT_SHIP_] + ProductionData.CurrentCounts[_TRANSPORT_SHIP_])
			local liTotalTransportsNeeded = 0

			-- If the ratio is set to 0 then do not build any transports
			if laTransportLandRatio[2] > 0 then
				liTotalTransportsNeeded = math.ceil((ProductionData.LandCountTotal / laTransportLandRatio[1]) * laTransportLandRatio[2]) - liTotalTransports
			end
			
			ProductionData.UnitNeeds[_TRANSPORT_SHIP_] = math.max(0, liTotalTransportsNeeded)
			
			-- Figure out if we need any CAGs
			local liCAGsNeeded = ProductionData.BuildingCounts[_ESCORT_CARRIER_] + ProductionData.CurrentCounts[_ESCORT_CARRIER_]
			liCAGsNeeded = liCAGsNeeded +((ProductionData.BuildingCounts[_CARRIER_] + ProductionData.CurrentCounts[_CARRIER_]) * 2)
			local liCAGsCount = ProductionData.BuildingCounts[_CAG_] + ProductionData.CurrentCounts[_CAG_]
			
			if liCAGsNeeded > liCAGsCount then
				ProductionData.UnitNeeds[_CAG_] = liCAGsNeeded - liCAGsCount
			end
		end
		
		-- Used in each area to calculate local costs
		local liNewICCount
		
		-- Build Land Units
		if liNeededLandIC > 0 then
			liNewICCount = BuildLandUnits(liNeededLandIC, laLandUnitRatio, false)
			ProductionData.icAvailable = ProductionData.icAvailable - (liNeededLandIC - liNewICCount)
			liNeededLandIC = liNewICCount
		end
		
		-- Build Air Units
		if liNeededAirIC > 0 then
			liNewICCount = BuildAirUnits(liNeededAirIC, laAirUnitRatio, false)
			ProductionData.icAvailable = ProductionData.icAvailable - (liNeededAirIC - liNewICCount)
			liNeededAirIC = liNewICCount
		end
		
		-- Build Naval Units
		if liNeededNavalIC > 0 then
			liNewICCount = BuildNavalUnits(liNeededNavalIC, laNavalUnitRatio, false)
			ProductionData.icAvailable = ProductionData.icAvailable - (liNeededNavalIC - liNewICCount)
			liNeededNavalIC = liNewICCount
		end

		-- Build Other (Convoys and Buildings)
		if liNeededOtherIC > 0 then
			liNewICCount = BuildOtherUnits(liNeededOtherIC, false)
			ProductionData.icAvailable = ProductionData.icAvailable - (liNeededOtherIC - liNewICCount)
			liNeededOtherIC = liNewICCount
		end
		
		-- Now if we have IC still left try and find someplace to use it
		if ProductionData.icAvailable > 1 then
			if liNeededOtherIC > liNeededAirIC and liNeededOtherIC > liNeededNavalIC and liNeededOtherIC > liNeededLandIC then			
				ProductionData.icAvailable = BuildOtherUnits(ProductionData.icAvailable, true)
			elseif liNeededNavalIC > liNeededAirIC and liNeededNavalIC > liNeededLandIC and liNeededNavalIC > liNeededOtherIC then			
				ProductionData.icAvailable = BuildNavalUnits(ProductionData.icAvailable, laNavalUnitRatio, true)
			elseif liNeededAirIC > liNeededLandIC and liNeededAirIC > liNeededNavalIC and liNeededAirIC > liNeededOtherIC then
				ProductionData.icAvailable = BuildAirUnits(ProductionData.icAvailable, laAirUnitRatio, true)
			elseif liNeededLandIC > liNeededAirIC and liNeededLandIC > liNeededNavalIC and liNeededLandIC > liNeededOtherIC then
				ProductionData.icAvailable = BuildLandUnits(ProductionData.icAvailable, laLandUnitRatio, true)
			end
			
			-- Last chance to use the IC
			if ProductionData.icAvailable > 1 then
				ProductionData.icAvailable = BuildLandUnits(ProductionData.icAvailable, laLandUnitRatio, true)
				ProductionData.icAvailable = BuildAirUnits(ProductionData.icAvailable, laAirUnitRatio, true)
				ProductionData.icAvailable = BuildNavalUnits(ProductionData.icAvailable, laNavalUnitRatio, true)
				ProductionData.icAvailable = BuildOtherUnits(ProductionData.icAvailable, true)
			end
		end
	else
		-- AI did not have enough manpower to build any units so just do buildings
		ProductionData.icAvailable = BuildOtherUnits(ProductionData.icAvailable, true)
	end
	
	if math.mod( CCurrentGameState.GetAIRand(), 7) == 0 then
		ProductionData.minister:PrioritizeBuildQueue()
	end
end

-- #######################
-- Helper Build Methods
-- #######################
function BuildLandUnits(ic, vaLandUnitRatio, vbGoOver)
	local liLoopCount = table.getn(vaLandUnitRatio)
	
	if liLoopCount > 0 then
		-- Performance check, make sure there is enough IC to actually do something
		if ic > 0.1 or vbGoOver then
			-- Setup Attachment Brigade arrays
			local GarrisonUnitArray = Utils.BuildGarrisonUnitArray(ProductionData)
			local LegUnitArray = Utils.BuildLegUnitArray(ProductionData)
			local MotorizedUnitArray = Utils.BuildMotorizedUnitArray(ProductionData)
			local ArmorUnitArray = Utils.BuildArmorUnitArray(ProductionData)
		
			local liLowestRatioIndex  = -1
			local liLowestValue = nil

			-- Main Loop Determines how many passess we actually have to make
			for i = 1, liLoopCount do
				-- Secondary Loop figures out which value is the lowest
				for x = 1, liLoopCount do
					if not(vaLandUnitRatio[x] == nil) then
						if liLowestRatioIndex  == -1 or liLowestValue >= vaLandUnitRatio[x] then
							liLowestValue = vaLandUnitRatio[x]
							liLowestRatioIndex  = x
						end
					end
				end
				
				-- Now set it to nil so it is no longer used
				vaLandUnitRatio[liLowestRatioIndex ] = nil
				
				-- Execute the build command based on the one that you are shortest on
				if liLowestRatioIndex  == 1 then
					ic = BuildUnit(ic, _GARRISON_BRIGADE_, 4, "garrison_brigade", 2, GarrisonUnitArray, 1, "Build_Garrison", vbGoOver)
				elseif liLowestRatioIndex  == 2 then
					-- Build Special Forces Units
					ic = BuildUnit(ic, _BERGSJAEGER_BRIGADE_, 4, "bergsjaeger_brigade", 3, nil, 0, "Build_Mountain", vbGoOver)
					ic = BuildUnit(ic, _PARATROOPER_BRIGADE_, 3, "paratrooper_brigade", 3, nil, 0, "Build_Paratrooper", vbGoOver)
					ic = BuildUnit(ic, _MARINE_BRIGADE_, 3, "marine_brigade", 3, nil, 1, "Build_Marine", vbGoOver)
				
					-- Handles Superior Firepower and give some variation to infantry division sizes
					if table.getn(LegUnitArray) > 0 then
						local loTech = CTechnologyDataBase.GetTechnology("superior_firepower")
						local liLevel = ProductionData.TechStatus:GetLevel(loTech)

						if liLevel > 0 then
							-- 3 infantry and 2 Support
							ic = BuildUnit(ic, _INFANTRY_BRIGADE_, 4, "infantry_brigade", 3, LegUnitArray, 2, "Build_Infantry", vbGoOver)
						else
							-- Majors have more MP normally so get more width in the division
							if ProductionData.IsMajor then
								-- 3 infantry and 1 Support
								ic = BuildUnit(ic, _INFANTRY_BRIGADE_, 4, "infantry_brigade", 3, LegUnitArray, 1, "Build_Infantry", vbGoOver)
							else
								-- 2 infantry and 2 Support
								ic = BuildUnit(ic, _INFANTRY_BRIGADE_, 4, "infantry_brigade", 2, LegUnitArray, 2, "Build_Infantry", vbGoOver)
							end
						end
					else
						-- 3 infantry and 0 Support
						ic = BuildUnit(ic, _INFANTRY_BRIGADE_, 4, "infantry_brigade", 3, LegUnitArray, 1, "Build_Infantry", vbGoOver)
					end
				elseif liLowestRatioIndex  == 3 then
					ic = BuildUnit(ic, _MOTORIZED_BRIGADE_, 2, "motorized_brigade", 3, MotorizedUnitArray, 1, "Build_Motorized", vbGoOver)
				elseif liLowestRatioIndex  == 4 then
					ic = BuildUnit(ic, _MECHANIZED_BRIGADE_, 2, "mechanized_brigade", 2, MotorizedUnitArray, 1, "Build_Mechanized", vbGoOver)
				elseif liLowestRatioIndex  == 5 then
					ic = BuildUnit(ic, _SUPER_HEAVY_ARMOR_BRIGADE_, 2, "super_heavy_armor_brigade", 2, ArmorUnitArray, 1, "Build_HeavyArmor", vbGoOver)
					ic = BuildUnit(ic, _HEAVY_ARMOR_BRIGADE_, 2, "heavy_armor_brigade", 2, ArmorUnitArray, 1, "Build_HeavyArmor", vbGoOver)
					ic = BuildUnit(ic, _ARMOR_BRIGADE_, 2, "armor_brigade", 2, ArmorUnitArray, 1, "Build_Armor", vbGoOver)
					ic = BuildUnit(ic, _LIGHT_ARMOR_BRIGADE_, 2, "light_armor_brigade", 2, ArmorUnitArray, 1, "Build_LightArmor", vbGoOver)
				elseif liLowestRatioIndex  == 6 then
					ic = BuildUnit(ic, _MILITIA_BRIGADE_, 4, "militia_brigade", 3, LegUnitArray, 1, "Build_Militia", vbGoOver)
				elseif liLowestRatioIndex  == 7 then
					ic = BuildUnit(ic, _CAVALRY_BRIGADE_, 2, "cavalry_brigade", 2, nil, 0, "Build_Cavalry", vbGoOver)
				end
				
				liLowestRatioIndex = -1
			end
		end
	end
	
	return ic
end
function BuildAirUnits(ic, vaAirUnitRatio, vbGoOver)
	ic = BuildUnit(ic, _TRANSPORT_PLANE_, 4, "transport_plane", 1, nil, 0, "Build_TransportPlane", vbGoOver)
	ic = BuildUnit(ic, _FLYING_BOMB_, 4, "flying_bomb", 1, nil, 0, "Build_FlyingBomb", vbGoOver)
	ic = BuildUnit(ic, _FLYING_ROCKET_, 4, "flying_rocket", 1, nil, 0, "Build_FlyingRocket", vbGoOver)
	
	local liLoopCount = table.getn(vaAirUnitRatio)
	
	if liLoopCount > 0 then
		-- Performance check, make sure there is enough IC to actually do something
		if ic > 0.1 or vbGoOver then
			local liLowestRatioIndex  = -1
			local liLowestValue = nil

			-- Main Loop Determines how many passess we actually have to make
			for i = 1, liLoopCount do
				-- Secondary Loop figures out which value is the lowest
				for x = 1, liLoopCount do
					if not(vaAirUnitRatio[x] == nil) then
						if liLowestRatioIndex  == -1 or liLowestValue >= vaAirUnitRatio[x] then
							liLowestValue = vaAirUnitRatio[x]
							liLowestRatioIndex  = x
						end
					end
				end
				
				-- Now set it to nil so it is no longer used
				vaAirUnitRatio[liLowestRatioIndex ] = nil
				
				-- Execute the build command based on the one that you are shortest on
				if liLowestRatioIndex  == 1 then
					ic = BuildUnit(ic, _MULTI_ROLE_, 4, "multi_role", 1, nil, 0, "Build_MultiRole", vbGoOver)
					ic = BuildUnit(ic, _INTERCEPTOR_, 4, "interceptor", 1, nil, 0, "Build_Interceptor", vbGoOver)
				elseif liLowestRatioIndex  == 2 then
					ic = BuildUnit(ic, _CAS_, 4, "cas", 1, nil, 0, "Build_CAS", vbGoOver)
				elseif liLowestRatioIndex  == 3 then
					ic = BuildUnit(ic, _TACTICAL_BOMBER_, 4, "tactical_bomber", 1, nil, 0, "Build_TacBomber", vbGoOver)
				elseif liLowestRatioIndex  == 4 then
					ic = BuildUnit(ic, _NAVAL_BOMBER_, 4, "naval_bomber", 1, nil, 0, "Build_NavBomber", vbGoOver)
				elseif liLowestRatioIndex  == 5 then
					ic = BuildUnit(ic, _STRATEGIC_BOMBER_, 4, "strategic_bomber", 1, nil, 0, "Build_StrategicBomber", vbGoOver)
				end
				
				liLowestRatioIndex = -1
			end
		end
	end
	
	return ic
end
function BuildNavalUnits(ic, vaNavalUnitRatio, vbGoOver)
	-- Always build Transports and CAGs first
	ic = BuildUnit(ic, _TRANSPORT_SHIP_, 3, "transport_ship", 1, nil, 0, "Build_Transport", vbGoOver)
	ic = BuildUnit(ic, _CAG_, 4, "cag", 1, nil, 0, "Build_CAG", vbGoOver)

	local liLoopCount = table.getn(vaNavalUnitRatio)
	
	if liLoopCount > 0 then
		-- Performance check, make sure there is enough IC to actually do something
		if ic > 0.1 or vbGoOver then
			local liLowestRatioIndex  = -1
			local liLowestValue = nil

			-- Main Loop Determines how many passess we actually have to make
			for i = 1, liLoopCount do
				-- Secondary Loop figures out which value is the lowest
				for x = 1, liLoopCount do
					if not(vaNavalUnitRatio[x] == nil) then
						if liLowestRatioIndex  == -1 or liLowestValue >= vaNavalUnitRatio[x] then
							liLowestValue = vaNavalUnitRatio[x]
							liLowestRatioIndex  = x
						end
					end
				end
				
				-- Now set it to nil so it is no longer used
				vaNavalUnitRatio[liLowestRatioIndex ] = nil
				
				-- Execute the build command based on the one that you are shortest on
				if liLowestRatioIndex  == 1 then
					ic = BuildUnit(ic, _DESTROYER_, 3, "destroyer", 1, nil, 0, "Build_Destroyer", vbGoOver)
				elseif liLowestRatioIndex  == 2 then
					ic = BuildUnit(ic, _NUCLEAR_SUBMARINE_, 2, "nuclear_submarine", 1, nil, 0, "Build_NuclearSubmarine", vbGoOver)
					ic = BuildUnit(ic, _SUBMARINE_, 2, "submarine", 1, nil, 0, "Build_Submarine", vbGoOver)
				elseif liLowestRatioIndex  == 3 then
					ic = BuildUnit(ic, _HEAVY_CRUISER_, 2, "heavy_cruiser", 1, nil, 0, "Build_HeavyCruiser", vbGoOver)
					ic = BuildUnit(ic, _LIGHT_CRUISER_, 2, "light_cruiser", 1, nil, 0, "Build_LightCruiser", vbGoOver)
				elseif liLowestRatioIndex  == 4 then
					ic = BuildUnit(ic, _SUPER_HEAVY_BATTLESHIP_, 1, "super_heavy_battleship", 1, nil, 0, "Build_SuperBattleship", vbGoOver)
					ic = BuildUnit(ic, _BATTLESHIP_, 1, "battleship", 1, nil, 0, "Build_Battleship", vbGoOver)
					ic = BuildUnit(ic, _BATTLECRUISER_, 1, "battlecruiser", 1, nil, 0, "Build_Battlecruiser", vbGoOver)
				elseif liLowestRatioIndex  == 5 then
					ic = BuildUnit(ic, _CARRIER_, 1, "carrier", 1, nil, 0, "Build_Carrier", vbGoOver)
				elseif liLowestRatioIndex  == 6 then
					ic = BuildUnit(ic, _ESCORT_CARRIER_, 2, "escort_carrier", 1, nil, 0, "Build_EscortCarrier", vbGoOver)
				end
				
				liLowestRatioIndex = -1
			end
		end
	end
	
	return ic
end

function BuildUnit(ic, viUnitIndex, viMaxSerial, vsType, viDivSize, voAttachUnitArray, viBrigadeCount, vsMethodOveride, vbGoOver)
	if ic > 1 and ProductionData.UnitNeeds[viUnitIndex] > 0 then 

		-- Check to see if the Country AI file has an overide
		if Utils.HasCountryAIFunction(ProductionData.ministerTag, vsMethodOveride) then
			ic, ProductionData.UnitNeeds[viUnitIndex] = Utils.CallCountryAI(ProductionData.ministerTag, vsMethodOveride, ic, ProductionData, ProductionData.UnitNeeds[viUnitIndex], vbGoOver)				
		elseif ProductionData.UnitNeeds[viUnitIndex] >= viDivSize then
			if voAttachUnitArray == nil then
				ic, ProductionData.UnitNeeds[viUnitIndex] = Utils.CreateDivision_nominor(ProductionData, vsType, viMaxSerial, ic, ProductionData.UnitNeeds[viUnitIndex], viDivSize, vbGoOver)
			else
				ic, ProductionData.UnitNeeds[viUnitIndex] = Utils.CreateDivision(ProductionData, vsType, viMaxSerial, ic, ProductionData.UnitNeeds[viUnitIndex], viDivSize, voAttachUnitArray, viBrigadeCount, vbGoOver)
			end
		end
	end
	
	return ic
end
-- Determines how many units are there within the given range
function GetUnitCount(viStart, viEnd)
	local UnitCount = 0
	-- math.max is used cause its possible an item can be nil
	while viStart <= viEnd do
		UnitCount = UnitCount + ProductionData.BuildingCounts[viStart] + ProductionData.CurrentCounts[viStart]
		viStart = viStart + 1
	end
	return UnitCount
end
-- Converts the Unit ratio to a % based number. If there
--   are 0 units but a Ratio exists then it will set it to 1.
function CalculateRatio(viUnitCount, viUnitRatio)
	local rValue
	
	if viUnitRatio == 0 then
		rValue = 0
	elseif viUnitCount == 0 then
		rValue = 1
	else
		rValue = viUnitCount / viUnitRatio
	end
	
	return rValue
end
-- Returns the correctly build ratio array
function GetBuildRatio(vbNaval, vsType)
	if Utils.HasCountryAIFunction(ProductionData.ministerTag, vsType) then
		return Utils.CallCountryAI(ProductionData.ministerTag, vsType, ProductionData)
	else
		if vbNaval then
			return DefaultProdMix[vsType]()
		else
			return DefaultProdLand[vsType]()	
		end					
	end		
end
function GetMultiplier(vaUnitMultiplier, vaRatio)
	local i = 2
	local liMultiplier = vaUnitMultiplier[1]
	local liAddToMultiplier = 2
	
	while i <= table.getn(vaUnitMultiplier) do
		if vaRatio[i] > 0 then
			if liAddToMultiplier > 0 and liMultiplier > 0 then
				if math.max((liMultiplier - vaUnitMultiplier[i]), (vaUnitMultiplier[i] - liMultiplier)) > liAddToMultiplier then
					liAddToMultiplier = 0
				end
			end
			
			if liMultiplier < vaUnitMultiplier[i] then
				liMultiplier = vaUnitMultiplier[i]
			end
		end
		
		i = i + 1
	end
	
	return liMultiplier + liAddToMultiplier
end

-- Goes through the ratios and sets them to 0 if the country can't build any of those units
function VerifyRatio(vaRatio, vaType)
	for i = 1, table.getn(vaRatio) do
		if vaRatio[i] > 0 then
			local lbCanBuild = false
			local laUnits = Utils.Split(vaType[i], '|')
			
			for x = 1, table.getn(laUnits) do
				if ProductionData.TechStatus:IsUnitAvailable(CSubUnitDataBase.GetSubUnit(laUnits[x])) then
					lbCanBuild = true
					break
				end
			end
			
			if not(lbCanBuild) then
				vaRatio[i] = 0
			end
		end
	end
	
	return vaRatio
end


-- #######################
-- End of Helper Build Methods
-- #######################

-- #######################
-- Building Construction
-- #######################
function BuildOtherUnits(ic, vbGoOver)
	-- Buildings
	if ic > 0.2 then
		local lbProvinceCheck = false
		local laCorePrv = {}
		local liRocketCap = 1
		local liReactorCap = 2

		-- Set Province Checker
		-- PERFORMANCE: Only 20% chance the AI will look at his home provinces unless he is short on manpower then 50%
		if ProductionData.ManpowerMobilize then
			if (math.random(100) > 80) then
				lbProvinceCheck = true
				laCorePrv = CoreProvincesLoop(liRocketCap, liReactorCap)
			end
		else
			if (math.random(100) > 50) then
				lbProvinceCheck = true
				laCorePrv = CoreProvincesLoop(liRocketCap, liReactorCap)
			end
		end
		
		-- Produce buildings until your out of IC that has been allocated
		--   Never have more than 1 rocket sites
		local lbProcess = true; -- Flag used to indicate to process regular code as well
		local lbExit = false
		local liLoopCheck = 0

		local coastal_fort = CBuildingDataBase.GetBuilding("coastal_fort" )
		local land_fort = CBuildingDataBase.GetBuilding( "land_fort" )
		local anti_air = CBuildingDataBase.GetBuilding("anti_air" )
		local industry = CBuildingDataBase.GetBuilding("industry" )
		local radar_station = CBuildingDataBase.GetBuilding("radar_station" )
		local nuclear_reactor = CBuildingDataBase.GetBuilding("nuclear_reactor" )
		local rocket_test = CBuildingDataBase.GetBuilding("rocket_test" )
		local infra = CBuildingDataBase.GetBuilding("infra")
		local air_base = CBuildingDataBase.GetBuilding("air_base")
		local underground = CBuildingDataBase.GetBuilding("underground")
		
		while not(lbExit) do
			-- Underground base
			if ic > 0.2 and ProductionData.TechStatus:IsBuildingAvailable(underground) then
				if Utils.HasCountryAIFunction(ProductionData.ministerTag, "Build_Underground") then
					ic, lbProcess = Utils.CallCountryAI(ProductionData.ministerTag, "Build_Underground", ic, ProductionData, vbGoOver)
				end
				
				if lbProcess then
					local undergroundCost = ProductionData.ministerCountry:GetBuildCost(underground):Get()
					
					if (ic - undergroundCost) >= 0 or vbGoOver then
						local randomTargetProvinceID = ProductionData.ministerCountry:GetRandomUnderGroundTarget()
						if randomTargetProvinceID > 0 then
							local constructCommand = CConstructBuildingCommand(ProductionData.ministerTag, underground, randomTargetProvinceID, 1)

							if constructCommand:IsValid() then
								ProductionData.ministerAI:Post( constructCommand )
								ic = ic - undergroundCost -- Update IC total	
								break
							end
						end
					end
				else
					lbProcess = true -- Reset Flag for next check
				end
			end
			
			-- Nuclear Reactors stations
			if ic > 0.2 and ProductionData.TechStatus:IsBuildingAvailable(nuclear_reactor) then
				if Utils.HasCountryAIFunction(ProductionData.ministerTag, "Build_NuclearReactor") then
					ic, lbProcess = Utils.CallCountryAI(ProductionData.ministerTag, "Build_NuclearReactor", ic, ProductionData, vbGoOver)				
				end
				
				if lbProcess then
					if lbProvinceCheck then
						if laCorePrv[2] < liReactorCap then
							local nuclear_reactorCost = ProductionData.ministerCountry:GetBuildCost(nuclear_reactor):Get()
							
							if (ic - nuclear_reactorCost) >= 0 or vbGoOver then
								if table.getn(laCorePrv[5]) > 0 and not(laCorePrv[2] >= liReactorCap) then
									local constructCommand = CConstructBuildingCommand(ProductionData.ministerTag, nuclear_reactor, laCorePrv[5][math.random(table.getn(laCorePrv[5]))], 1 )

									if constructCommand:IsValid() then
										ProductionData.ministerAI:Post( constructCommand )
										ic = ic - nuclear_reactorCost -- Upodate IC total	
									end
								end
							end
						end
					end
				else
					lbProcess = true -- Reset Flag for next check
				end
			end

			-- Rocket Test Site stations
			if ic > 0.2 and ProductionData.TechStatus:IsBuildingAvailable(rocket_test) then
				if Utils.HasCountryAIFunction(ProductionData.ministerTag, "Build_RocketTest") then
					ic, lbProcess = Utils.CallCountryAI(ProductionData.ministerTag, "Build_RocketTest", ic, ProductionData, vbGoOver)				
				end
				
				if lbProcess then
					if lbProvinceCheck and not(ProductionData.BuiltRocketSite) then
						if laCorePrv[1] < liRocketCap then
							local rocket_testCost = ProductionData.ministerCountry:GetBuildCost(rocket_test):Get()
							
							if (ic - rocket_testCost) >= 0 or vbGoOver then
								if table.getn(laCorePrv[5]) > 0 and not(laCorePrv[1] >= liRocketCap) then
									local constructCommand = CConstructBuildingCommand(ProductionData.ministerTag, rocket_test, laCorePrv[5][math.random(table.getn(laCorePrv[5]))], 1 )

									if constructCommand:IsValid() then
										ProductionData.ministerAI:Post( constructCommand )
										ic = ic - rocket_testCost -- Update IC total	
										ProductionData.BuiltRocketSite = true
									end
								end
							end
						end
					end
				else
					lbProcess = true -- Reset Flag for next check
				end
			end
			
			-- Industry
			if ic > 0.2 and ProductionData.TechStatus:IsBuildingAvailable(industry) then
				if Utils.HasCountryAIFunction(ProductionData.ministerTag, "Build_Industry") then
					ic, lbProcess = Utils.CallCountryAI(ProductionData.ministerTag, "Build_Industry", ic, ProductionData, vbGoOver)				
				end
				
				if lbProcess then
					if lbProvinceCheck then
						local industryCost = ProductionData.ministerCountry:GetBuildCost(industry):Get()
						
						if (ic - industryCost) >= 0 or vbGoOver then
							if table.getn(laCorePrv[6]) > 0 then
								local constructCommand = CConstructBuildingCommand(ProductionData.ministerTag, industry, laCorePrv[6][math.random(table.getn(laCorePrv[6]))], 1 )

								if constructCommand:IsValid() then
									ProductionData.ministerAI:Post( constructCommand )
									ic = ic - industryCost -- Upodate IC total	
								end
							end
						end
					end
				else
					lbProcess = true -- Reset Flag for next check
				end
			end						
			
			-- Build Forts
			--   Since there is no practical way to teach the AI to build forts just allow hooks for country specific stuff
			if ic > 0.2 and ProductionData.TechStatus:IsBuildingAvailable(land_fort) then
				if Utils.HasCountryAIFunction(ProductionData.ministerTag, "Build_Fort") then
					ic, lbProcess = Utils.CallCountryAI(ProductionData.ministerTag, "Build_Fort", ic, ProductionData, vbGoOver)				
				end
				
				-- No special code for building a fort
				lbProcess = true
			end
			
			-- Build Coastal Forts
			if ic > 0.2 and ProductionData.TechStatus:IsBuildingAvailable(coastal_fort) then
				if Utils.HasCountryAIFunction(ProductionData.ministerTag, "Build_CoastalFort") then
					ic, lbProcess = Utils.CallCountryAI(ProductionData.ministerTag, "Build_CoastalFort", ic, ProductionData, vbGoOver)				
				end
				
				if lbProcess then
					-- Get Costal Fort information
					local coastal_fortCost = ProductionData.ministerCountry:GetBuildCost(coastal_fort):Get()
					
					--Make sure you wont go into the negative (Performance helper)
					if (ic - coastal_fortCost) >= 0 or vbGoOver then
						for navalBaseProvince in ProductionData.ministerCountry:GetNavalBases() do
							if tostring(navalBaseProvince:GetOwner()) == tostring(ProductionData.ministerTag) then
								local provinceBuilding = navalBaseProvince:GetBuilding(coastal_fort)
								
								-- Never put more than 2 coastal forts in a hex
								--    and make sure one is not being built already
								if provinceBuilding:GetMax():Get() < 2 and navalBaseProvince:GetCurrentConstructionLevel(coastal_fort) == 0 then
									-- Make sure the hex does not have a fort already (Example: Konigsberg for Germany)
									if not navalBaseProvince:HasBuilding(land_fort) then
										if ProductionData.ministerCountry:IsBuildingAllowed(coastal_fort, navalBaseProvince) then
											local constructCommand = CConstructBuildingCommand(ProductionData.ministerTag, coastal_fort, navalBaseProvince:GetProvinceID(), 1 )

											if constructCommand:IsValid() then
												ProductionData.ministerAI:Post( constructCommand )
												ic = ic - coastal_fortCost -- Upodate IC total
												break 
											end
										end
									end
								end
							end
						end
					end
				else
					lbProcess = true -- Reset Flag for next check
				end
			end
			
			-- Build Anti Air
			if ic > 0.2 and ProductionData.TechStatus:IsBuildingAvailable(anti_air) then
				if Utils.HasCountryAIFunction(ProductionData.ministerTag, "Build_AntiAir") then
					ic, lbProcess = Utils.CallCountryAI(ProductionData.ministerTag, "Build_AntiAir", ic, ProductionData, vbGoOver)				
				end

				if lbProcess then
					local industryCost = ProductionData.ministerCountry:GetBuildCost(industry):Get()
					local anti_airCost = ProductionData.ministerCountry:GetBuildCost(anti_air):Get()

					if (ic - anti_airCost) >= 0 or vbGoOver then
						local totalbuilt = 0
						
						for provinceId in ProductionData.ministerCountry:GetOwnedProvinces() do
							local province = CCurrentGameState.GetProvince(provinceId)
							local provinceBuilding = province:GetBuilding(anti_air)

							-- First make sure the province has Industry (performance reasons done first)
							if province:HasBuilding(industry) then
								-- Check to see if it has less than 5 AA and nothing is being constructed.
								--    Also make sure its not on the front. If everythign is good then go ahead and build some
								if provinceBuilding:GetMax():Get() < 5 and province:GetCurrentConstructionLevel(anti_air) == 0 and not province:IsFrontProvince(false) then
									local constructCommand = CConstructBuildingCommand(ProductionData.ministerTag, anti_air, provinceId, 1 )

									if constructCommand:IsValid() then
										ProductionData.ministerAI:Post( constructCommand )
										totalbuilt = totalbuilt + 1
										ic = ic - anti_airCost -- Upodate IC total	

										-- Have two building max
										--   or Do not make the second pass your at max ic
										if totalbuilt >= 2 or (ic - anti_airCost) <= 0 then
											break 
										end
									end
								end
							end
						end
					end
				else
					lbProcess = true -- Reset Flag for next check
				end
			end
			
			-- Radar stations
			if ic > 0.2 and ProductionData.TechStatus:IsBuildingAvailable(radar_station) then
				if Utils.HasCountryAIFunction(ProductionData.ministerTag, "Build_Radar") then
					ic, lbProcess = Utils.CallCountryAI(ProductionData.ministerTag, "Build_Radar", ic, ProductionData, vbGoOver)				
				end

				if lbProcess then
					local radar_stationCost = ProductionData.ministerCountry:GetBuildCost(radar_station):Get()
					
					if (ic - radar_stationCost) >= 0 or vbGoOver then
						for province in ProductionData.ministerCountry:GetAirBases() do
							-- Check to make sure the province has factories
							-- Do this check first before any others (performance reasons)
							if province:HasBuilding(industry) and tostring(province:GetOwner()) == tostring(ProductionData.ministerTag) then
								local provinceBuilding = province:GetBuilding(radar_station)
								
								-- Make sure it is not a front province and that the province does not have 2 or more already.
								if provinceBuilding:GetMax():Get() < 2 and not province:IsFrontProvince(false) then
									if ProductionData.ministerCountry:IsBuildingAllowed(radar_station, province) then
										if not (province:GetCurrentConstructionLevel(radar_station) > 0) then
											local constructCommand = CConstructBuildingCommand(ProductionData.ministerTag, radar_station, province:GetProvinceID(), 1)

											if constructCommand:IsValid() then
												ProductionData.ministerAI:Post( constructCommand )
												ic = ic - radar_stationCost -- Upodate IC total	
												break 
											end
										end
									end
								end
							end
						end
					end
				else
					lbProcess = true -- Reset Flag for next check
				end
			end

			-- Build Airfields
			if ic > 0.2 and ProductionData.TechStatus:IsBuildingAvailable(air_base) then
				if Utils.HasCountryAIFunction(ProductionData.ministerTag, "Build_AirBase") then
					ic, lbProcess = Utils.CallCountryAI(ProductionData.ministerTag, "Build_AirBase", ic, ProductionData, vbGoOver)
				end

				if lbProcess then
					-- This country has no airfields so try and build one in its capital
					if ProductionData.AirfieldsTotal == 0 then
						ic = Support.Build_AirBase(ic, ProductionData, ProductionData.ministerCountry:GetActingCapitalLocation():GetProvinceID(), 1, vbGoOver)
					end
				else
					lbProcess = true -- Reset Flag for next check
				end
			end
			
			-- Infrastructure
			if ic > 0.2 and ProductionData.TechStatus:IsBuildingAvailable(infra) then
				if Utils.HasCountryAIFunction(ProductionData.ministerTag, "Build_Infrastructure") then
					ic, lbProcess = Utils.CallCountryAI(ProductionData.ministerTag, "Build_Infrastructure", ic, ProductionData, vbGoOver)				
				end

				if lbProcess then
					if lbProvinceCheck then
						local infraCost = ProductionData.ministerCountry:GetBuildCost(infra):Get()
						
						if (ic - infraCost) >= 0 or vbGoOver then
							local liRandomIndex
							
							-- Limit it to three provinces at a time
							for i = 1, 3 do
								if table.getn(laCorePrv[3]) > 0 then
									liRandomIndex = math.random(table.getn(laCorePrv[3]))
									local constructCommand = CConstructBuildingCommand(ProductionData.ministerTag, infra, laCorePrv[3][liRandomIndex], 1 )

									if constructCommand:IsValid() then
										if (ic - infraCost) >= 0 or vbGoOver then
											ProductionData.ministerAI:Post( constructCommand )
											ic = ic - infraCost -- Upodate IC total	
											table.remove(laCorePrv[3], liRandomIndex)
										else
											break
										end
									end
								elseif table.getn(laCorePrv[4]) > 0 then
									liRandomIndex = math.random(table.getn(laCorePrv[4]))
									local constructCommand = CConstructBuildingCommand(ProductionData.ministerTag, infra, laCorePrv[4][liRandomIndex], 1 )

									if constructCommand:IsValid() then
										if (ic - infraCost) >= 0 or vbGoOver then
											ProductionData.ministerAI:Post( constructCommand )
											ic = ic - infraCost -- Upodate IC total	
											table.remove(laCorePrv[4], liRandomIndex)
										else
											break
										end
									end
								end
								
								-- If there is no IC left do not loop another time
								if ic <= 0.2 then
									break
								end
							end
						end
					end
				else
					lbProcess = true -- Reset Flag for next check
				end
			end	
			
			-- Loop Check Exit after 4 passes means we cant build any buildings
			if ic <= 1 or liLoopCheck >= 4 then
				lbExit = true
			else
				liLoopCheck = liLoopCheck + 1
			end
		end
	end
	
	return ic
end

function CoreProvincesLoop(viRocketCap, viReactorCap)
	local liExpenseFactor = 0
	local liHomeFactor = 0
	local lbBuildIndustry = false
	local laCorePrv = {}
	
	local loEnergy = CResourceValues()
	local loMetal = CResourceValues()
	local loRare = CResourceValues()
	
	loEnergy:GetResourceValues( ProductionData.ministerCountry, CGoodsPool._ENERGY_ )
	loMetal:GetResourceValues( ProductionData.ministerCountry, CGoodsPool._METAL_ )
	loRare:GetResourceValues( ProductionData.ministerCountry, CGoodsPool._RARE_MATERIALS_ )
	
	liExpenseFactor = loEnergy.vDailyExpense * 0.5
	liExpenseFactor = liExpenseFactor + loMetal.vDailyExpense
	liExpenseFactor = liExpenseFactor + (loRare.vDailyExpense * 2)
	
	liHomeFactor = Utils.CalculateHomeProduced(loEnergy) * 0.5
	liHomeFactor = liHomeFactor + Utils.CalculateHomeProduced(loMetal)
	liHomeFactor = liHomeFactor + (Utils.CalculateHomeProduced(loRare) * 2)
	
	-- We produce more than what we use so build more industry
	if liHomeFactor > liExpenseFactor then
		lbBuildIndustry = true
	end
	
	local nuclear_reactor = CBuildingDataBase.GetBuilding("nuclear_reactor" )
	local rocket_test = CBuildingDataBase.GetBuilding("rocket_test" )
	local infra = CBuildingDataBase.GetBuilding("infra" )
	local industry = CBuildingDataBase.GetBuilding("industry" )

	-- The GetTotalCoreBuildingLevels counts on map and in the production que together
	local liRocketSiteCount = ProductionData.ministerCountry:GetTotalCoreBuildingLevels(rocket_test:GetIndex()):Get()
	local liReactorSiteCount = ProductionData.ministerCountry:GetTotalCoreBuildingLevels(nuclear_reactor:GetIndex()):Get()
	local laCorePrvLowInfra69 = {}
	local laCorePrvLowInfra99 = {}
	local laCorePrvIndustry = {}
	local laCorePrvBuildIndustry = {}

	for provinceId in ProductionData.ministerCountry:GetCoreProvinces() do
		local province = CCurrentGameState.GetProvince(provinceId)
		local provinceBuilding = province:GetBuilding(infra)
		local isFrontProvince = province:IsFrontProvince(false)
		
		-- Infrastructure
		local liConstructionLevel = province:GetCurrentConstructionLevel(infra)
		local liBuildingSize = provinceBuilding:GetMax():Get()
		
		if liBuildingSize < 7 and not(liConstructionLevel > 0) and not(isFrontProvince) then
			table.insert(laCorePrvLowInfra69, provinceId)
		elseif liBuildingSize < 10 and not(liConstructionLevel > 0) and not(isFrontProvince) then
			table.insert(laCorePrvLowInfra99, provinceId)
		end
		
		-- Rocket Test Site
		provinceBuilding = province:GetBuilding(rocket_test)
		liConstructionLevel = province:GetCurrentConstructionLevel(rocket_test)
		
		-- First make sure the province has Industry (performance reasons done first)
		if province:HasBuilding(industry) and not(isFrontProvince) then
			-- Check to see if it has less than 5 Reactors and nothing is being constructed.
			--    Also make sure its not on the front. If everythign is good then go ahead and build some
			
			if (ProductionData.TechStatus:IsBuildingAvailable(rocket_test) and liRocketSiteCount < viRocketCap) or (ProductionData.TechStatus:IsBuildingAvailable(rocket_test) and liReactorSiteCount < viReactorCap) then
				if not(province:GetCurrentConstructionLevel(rocket_test) > 0) and not(province:GetCurrentConstructionLevel(nuclear_reactor) > 0) then
					table.insert(laCorePrvIndustry, provinceId)
				end
			end
			
			if lbBuildIndustry then
				if province:GetBuilding(industry):GetMax():Get() < 9 and not(province:GetCurrentConstructionLevel(industry) > 0) then
					table.insert(laCorePrvBuildIndustry, provinceId)
				end
			end
		end		
	end
	
	table.insert(laCorePrv, liRocketSiteCount)
	table.insert(laCorePrv, liReactorSiteCount)
	table.insert(laCorePrv, laCorePrvLowInfra69)
	table.insert(laCorePrv, laCorePrvLowInfra99)
	table.insert(laCorePrv, laCorePrvIndustry)
	table.insert(laCorePrv, laCorePrvBuildIndustry)
	
	return laCorePrv
end
-- #######################
-- End Building Construction
-- #######################


-- #######################
-- Convoy Building
-- #######################
function ConstructConvoys(ic)
	if ic > 0 then
		if ProductionData.PortsTotal > 0 then
			local liNeeded = ProductionData.ministerCountry:GetTotalNeededConvoyTransports()
			local liCurrent = ProductionData.ministerCountry:GetTotalConvoyTransports()
			local liConstruction = ProductionData.minister:CountTransportsUnderConstruction()
			local liActuallyNeeded
			local maxSerial = 2
			
			-- Majors build 20% more than you need
			if (ProductionData.IsMajor) then
				liActuallyNeeded = Utils.Round((liNeeded * 1.20) - liCurrent - liConstruction )

				-- If you are below the 20 cap in reserve then go 20 over
				if (liActuallyNeeded - liNeeded) < 20 then
					liActuallyNeeded = (((liNeeded + 20) - liCurrent) - liConstruction)
				end
			-- Minors just build exactly what you need or close to it
			--   - they also do shorter runs since they needed resources more than majors
			else
				liActuallyNeeded = liNeeded - liCurrent - liConstruction
			end
			
			-- Make sure they always have a buffer of atleast 4
			if liActuallyNeeded >= -1 and liActuallyNeeded <= 1 then
				liActuallyNeeded = (math.max(0, liActuallyNeeded) + 4)
			end
			
			if liActuallyNeeded > 0 then
				local cost = ProductionData.ministerCountry:GetConvoyBuildCost():Get()
				local buildRequestCount = liActuallyNeeded / defines.economy.CONVOY_CONSTRUCTION_SIZE
				buildRequestCount = math.ceil( math.max( buildRequestCount, 1) )
				ic = BuildTransportOrEscort(buildRequestCount, maxSerial, false, cost, ic)
			end
	
			-- Now Process Escorts Check
			--   Performance check make sure they have IC to actually work with
			local liENeeded = ProductionData.minister:CountTotalDesiredEscorts()
			local liECurrent = ProductionData.ministerCountry:GetEscorts()
			local liEConstruction = ProductionData.minister:CountEscortsUnderConstruction()
			local lEActuallyNeeded = liENeeded - liECurrent - liEConstruction
			
			if (ProductionData.IsMajor) then
				-- If you are below the 10 cap in reserve then go 10 over
				if (lEActuallyNeeded - liENeeded) < 10 then
					lEActuallyNeeded = (((liENeeded + 10) - liECurrent) - liEConstruction)
				end
			end

			-- If we need escorts lets build them
			if lEActuallyNeeded > 0 then
				local cost = ProductionData.ministerCountry:GetEscortBuildCost():Get()
				local buildRequestCount = lEActuallyNeeded / defines.economy.CONVOY_CONSTRUCTION_SIZE
				buildRequestCount = math.ceil( math.max( buildRequestCount, 1) )
				ic = BuildTransportOrEscort(buildRequestCount, 4, true, cost, ic)
			end 
		end
	end
	
	return ic
end
--ConvoyOrEscort = is a boolean (true = escort, false = convoy)
function BuildTransportOrEscort(total_transports, maxSerial, ConvoyOrEscort, cost, ic)
	local i = 0 -- Counter for amount of units built
	
	while i < total_transports do
		-- Need to add method call here to call brigades processing using the Array
		----  which needs to return a unitType object to be appended
		local buildcount
		
		if 	total_transports >= (i + maxSerial) then
			buildcount = maxSerial
			i = i + maxSerial
		else
			buildcount = total_transports - i
			i = total_transports
		end
		
		local res = ic - cost

		if res > 0 then
			local buildCommand = CConstructConvoyCommand(ProductionData.ministerTag, ConvoyOrEscort, buildcount)
			ProductionData.ministerAI:Post(buildCommand)
			
			ic = ic - cost
		end
	end
	
	return ic
end
-- #######################
-- END Convoy Building
-- #######################
	