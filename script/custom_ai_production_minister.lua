-----------------------------------------------------------
-- LUA Hearts of Iron 3 Custom Production File for minor countries
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

local _GARRISON_BRIGADE_ = 1
local _MILITIA_BRIGADE_ = 2
local _INFANTRY_BRIGADE_ = 3
local _CAVALRY_BRIGADE_ = 4
local _BERGSJAEGER_BRIGADE_ = 5
local _MARINE_BRIGADE_ = 6
local _PARATROOPER_BRIGADE_ = 7
local _MOTORIZED_BRIGADE_ = 13

local ICCutOff = 0.2

function BalanceProductionSliders_Modded_AI(ai, ministerCountry, prioSelection,
                                  vConsumer, vProduction, vSupply, vReinforce, vUpgrade, bHasReinforceBonus, lbIsMajor)
								  
	local totalIC = ministerCountry:GetTotalIC()
	local remainingIC = totalIC
	local pConsumer = 0
	local pSupplies = 0
	local pReinforce = 0
	local pProduction = 0
	local pUpgrade = 0
	
	--COUNTRY_DEBUG(ministerCountry, "Using BalanceProductionSliders_Modded_AI")
	
	-- Start with consumer products... since it is always required
	local consumerNeed = ministerCountry:GetProductionDistributionAt( CDistributionSetting._PRODUCTION_CONSUMER_):GetNeeded():Get()
	if ministerCountry:GetDissent():Get() > 0.25 then
		-- there is a large amount of dissent! Crush it immediately!
		consumerNeed = 0.9*remainingIC
	elseif ministerCountry:GetDissent():Get() > 0.0 then
		consumerNeed = 1.1*vConsumer*totalIC
	end
	pConsumer = math.min(1.0, consumerNeed/totalIC)
	remainingIC = remainingIC - pConsumer*totalIC
	
	if remainingIC > 0 then	
	
		-- supplies are not needed until roughly when war starts or if we have so little IC that we can't fully support our current supply needs
		local supplyNeed = ministerCountry:GetProductionDistributionAt( CDistributionSetting._PRODUCTION_SUPPLY_):GetNeeded():Get()
		pSupplies = math.min(remainingIC, SupplyNeedMultiplier(ministerCountry, ai) * supplyNeed)/totalIC
		-- always throw a bit into supplies to keep other calculations
		-- accurate
		pSupplies = math.max(0.05/totalIC, pSupplies)
		remainingIC = remainingIC - pSupplies*totalIC
	
		if remainingIC > 0 then			
			-- reinforcements are not needed until roughly when war starts
			local reinforceNeed = ministerCountry:GetProductionDistributionAt( CDistributionSetting._PRODUCTION_REINFORCEMENT_):GetNeeded():Get()
			if PrepareForWar(ministerCountry, ai) == true or bHasReinforceBonus == true then
				pReinforce = 0.90*math.min(remainingIC, reinforceNeed)/totalIC
				remainingIC = remainingIC - pReinforce*totalIC
			elseif remainingIC > 0.05 then
				-- always allocate a small piece to reinforce to keep the 
				-- the slider accurate. It tends to be innaccurate unless done so.				
				pReinforce = math.min(0.05, reinforceNeed)/totalIC
				remainingIC = remainingIC - 0.05
			end
			
			if remainingIC > 0 then
				-- leave upgrades until we have a manpower shortage
				if HasManPowerShortage(ministerCountry, ai) then
					local upgradeNeed = ministerCountry:GetProductionDistributionAt( CDistributionSetting._PRODUCTION_UPGRADE_):GetNeeded():Get()
					pUpgrade = 0.90*math.min(remainingIC, upgradeNeed)/totalIC
					remainingIC = remainingIC - pUpgrade*totalIC
				end
				
				if remainingIC > 0 then
					pProduction = remainingIC/totalIC
				end
			end
		end
	end
	
	-- normalize the values
	local totalP = pConsumer + pSupplies + pProduction + pReinforce + pUpgrade
	pConsumer = pConsumer/totalP
	pSupplies = pSupplies/totalP
	pReinforce = pReinforce/totalP
	pProduction = pProduction/totalP
	pUpgrade = pUpgrade/totalP
	local command = CChangeInvestmentCommand( ministerCountry:GetCountryTag(), pConsumer, pProduction, pSupplies, pReinforce, pUpgrade )
	ai:Post( command )
end

function ProductionMinister_Tick_Modded_AI(minister)
	local ministerCountry = minister:GetCountry()
	local ai = minister:GetOwnerAI()
	local ICAllocated = ministerCountry:GetICPart(CDistributionSetting._PRODUCTION_PRODUCTION_):Get()
	local ICUsed = ministerCountry:GetUsedIC():Get()
	local ICRemaining = ICAllocated - ICUsed
	--COUNTRY_DEBUG(ministerCountry, "Using ProductionMinister_Tick_Modded_AI")
	-- store this valuable data so that other ministers can access this data using GetTotalUnitCount
	SetTotalUnitList(ministerCountry, ai)
	
	----COUNTRY_DEBUG(ministerCountry, "ICRemaining: ".. ICRemaining)
	ICRemaining = EvaluateConvoys(minister, ICRemaining)
	if ICRemaining > ICCutOff then
		--COUNTRY_DEBUG(ministerCountry, "    ICRemaining: ".. ICRemaining)
		
		ICRemaining = EvaluateIndustry(minister, ICRemaining)
		if ICRemaining > ICCutOff then
			--COUNTRY_DEBUG(ministerCountry, "        ICRemaining: ".. ICRemaining)
			ICRemaining = EvaluateMilitary(minister, ICRemaining)
			
			if ICRemaining > ICCutOff then
				--COUNTRY_DEBUG(ministerCountry, "            ICRemaining: ".. ICRemaining)
				-- doesn't work right now...
				--ICRemaining = EvaluateMilitaryUpgrade(minister, ICRemaining)
				if ICRemaining > ICCutOff then
					ICRemaining = EvaluateForts(minister, ICRemaining)
				end
			end
		end
	end
end

function EvaluateConvoys(minister, ICRemaining)
	-- Convoys are expensive to spend IC in for minors, so make sure we REALLY need them
	local ministerCountry = minister:GetCountry()
	--COUNTRY_DEBUG(ministerCountry, "EvaluateConvoys")
	local needed = ministerCountry:GetTotalNeededConvoyTransports()
	
	-- TODO: Enhance the logic later to include checking if the convoys are bringing in needed resources
	if needed > 0 then
		local ai = minister:GetOwnerAI()
		local prepareForWar = PrepareForWar(ministerCountry, ai)
		local current = ministerCountry:GetTotalConvoyTransports()
		local construction = minister:CountTransportsUnderConstruction()
		local available = current + construction
		--COUNTRY_DEBUG(ministerCountry, "=========EvaluateConvoys===========")
		--COUNTRY_DEBUG(ministerCountry, "current = "..current)
		--COUNTRY_DEBUG(ministerCountry, "construction = "..construction)
		--COUNTRY_DEBUG(ministerCountry, "needed = "..needed)
		--COUNTRY_DEBUG(ministerCountry, "===================================")
		
		if  available == 0 or (prepareForWar == false and available <= needed) then
		
			-- only build convoys if we have a shortage and we need them
			if HasResourceShortage(minister) then
				--COUNTRY_DEBUG(ministerCountry, "Convoy shortage")
				-- flip the build order in times of war since we want the escorts deployed first
				ICRemaining = ConstructTransportOrEscort(minister, 1, ministerCountry:IsAtWar(), ICRemaining)
				ICRemaining = ConstructTransportOrEscort(minister, 1, not ministerCountry:IsAtWar(), ICRemaining)
			end
		end
	end
	
	return ICRemaining
end

function EvaluateIndustry(minister, ICRemaining)
	local ministerCountry = minister:GetCountry()
	--COUNTRY_DEBUG(ministerCountry, "EvaluateIndustry")
	local ministerTag = minister:GetCountryTag()
	local ai = minister:GetOwnerAI()
	local techStatus = ministerCountry:GetTechnologyStatus()
	local industry = CBuildingDataBase.GetBuilding("industry" )
	if techStatus:IsBuildingAvailable(industry) and InvestInIC(minister) then
		--COUNTRY_DEBUG(ministerCountry,"Investing in IC")
		local provinces = GetProvinces(minister, true)
		local tableSize = table.getn(provinces)
		local index = 1
		local icChangeLastLoop = ICRemaining
		local continueLoop = true
		while ICRemaining > ICCutOff and continueLoop do
			ICRemaining = ConstructBuilding(minister, industry, provinces[index], ICRemaining)
			index = (index % tableSize) + 1
			if index == 1 then
				if icChangeLastLoop == ICRemaining then
					-- avoid an infinite loop by checking if the IC is changing
					continueLoop = false
				else
					icChangeLastLoop = ICRemaining
				end
			end
		end
	end
	return ICRemaining
end

function EvaluateMilitary(minister, ICRemaining)
	local ministerCountry = minister:GetCountry()
	--COUNTRY_DEBUG(ministerCountry, "EvaluateMilitary")
	
	local ai = minister:GetOwnerAI()
	local techStatus = ministerCountry:GetTechnologyStatus()
	local bestAvailableUnit = BestAvailableUnit(ministerCountry, ai)
	local MPRemaining = EffectiveManPower(ministerCountry)
	if MPRemaining > 0 and techStatus:IsUnitAvailable(bestAvailableUnit) then
		local bestUnitName = tostring(bestAvailableUnit:GetKey())
		local icCost = 0
		local mpCost = 0
		local timeCost = 0
		local divisionList = nil
		local supportUnit = BestAvailableSupportUnit(ministerCountry, ai, bestAvailableUnit)
		local supportUnitName = "none"
		local baseQuantity = 3
		local supportQuantity = 1
		if supportUnit then
			supportUnitName = tostring(supportUnit:GetKey())
		else
			supportQuantity = 0
		end
		
		if bestUnitName == "infantry_brigade" then
			if supportUnit and supportUnitName == "tank_destroyer_brigade" then
				baseQuantity = 2
				supportQuantity = 2
			end
			icCost, mpCost, timeCost, divisionList = ConstructLandDivision(ministerCountry, bestAvailableUnit, baseQuantity, supportUnit, supportQuantity)
		elseif bestUnitName == "bergsjaeger_brigade" then
			icCost, mpCost, timeCost, divisionList = ConstructLandDivision(ministerCountry, bestAvailableUnit, baseQuantity, supportUnit, supportQuantity)
		elseif bestUnitName == "marine_brigade" then
			icCost, mpCost, timeCost, divisionList = ConstructLandDivision(ministerCountry, bestAvailableUnit, baseQuantity, supportUnit, supportQuantity)
		elseif bestUnitName == "motorized_brigade" then
			if supportUnit and supportUnitName == "tank_destroyer_brigade" then
				baseQuantity = 2
				supportQuantity = 2
			end
			icCost, mpCost, timeCost, divisionList = ConstructLandDivision(ministerCountry, bestAvailableUnit, baseQuantity, supportUnit, supportQuantity)
		else
			baseQuantity = 4
			icCost, mpCost, timeCost, divisionList = ConstructLandDivision(ministerCountry, bestAvailableUnit, baseQuantity, nil, 0)
		end
		
		if divisionList and MPRemaining-mpCost > 0 then
			local daysToCollapse = MinDaysToCollapse(ministerCountry, ai)
			local maxBuild = 9999
			local favoriteUnit = FavoriteUnit(ministerCountry, ai)
			local favoriteUnitName = tostring(favoriteUnit:GetKey())
			if bestUnitName ~= favoriteUnitName then
				-- if we haven't reached our favorite unit then control how fast we build the units.
				-- we don't want to burn through valuable manpower
				local efficiencyRate = math.min(1, ICRemaining/icCost)
				local mpPerDay = efficiencyRate*mpCost/timeCost
				maxBuild = (MPRemaining/daysToCollapse)/mpPerDay
			end
			local capitalProvId = ministerCountry:GetActingCapitalLocation():GetProvinceID()
			local ministerTag = minister:GetCountryTag()
			--COUNTRY_DEBUG(ministerCountry,"Building "..maxBuild.." "..bestUnitName .. "/".. supportUnitName.. " - " .. icCost .."ic " .. mpCost .."mp ".. timeCost .."time")
			while ICRemaining > 0 and MPRemaining-mpCost > 0 and maxBuild >=1 do
				local command = CConstructUnitCommand(ministerTag, divisionList, capitalProvId, 1, false, CNullTag(), CID())
				ai:Post(command)
				ICRemaining = ICRemaining - icCost
				MPRemaining = MPRemaining - mpCost
				maxBuild = maxBuild - 1
			end
		end
	end
	return ICRemaining
end

-- this function just doesn't work right now due to a lack of support from paradox
function EvaluateMilitaryUpgrade(minister, ICRemaining)
	local ministerCountry = minister:GetCountry()
	--COUNTRY_DEBUG(ministerCountry, "EvaluateMilitaryUpgrade")
	local ministerTag = minister:GetCountryTag()
	local ai = minister:GetOwnerAI()
	local techStatus = ministerCountry:GetTechnologyStatus()
	local bestAvailableUnit = BestAvailableUnit(ministerCountry, ai)
	local bestUnitName = tostring(bestAvailableUnit:GetKey())
	
	local deployedUnitCount = ai:GetDeployedSubUnitCounts()
	
	local militiaBrigade = CSubUnitDataBase.GetSubUnit("militia_brigade")
	local infantryBrigade = CSubUnitDataBase.GetSubUnit("infantry_brigade")
	
	for unit in	ministerCountry:GetUnitsIterator() do
		local unitName = unit:GetName()
		--COUNTRY_DEBUG(ministerCountry, "Unit name: "..tostring(unitName))
		--if deployedUnitCount:GetAt(militiaBrigade:GetIndex()) > 0 and bestAvailableUnit:GetIndex() >  militiaBrigade:GetIndex() then
		--COUNTRY_DEBUG(ministerCountry, "Upgrading Militia to Infantry")
		--local command = CUpgradeRegimentCommand( militiaBrigade, infantryBrigade:GetIndex())
		--ai:Post(command)
		--ICRemaining = ICRemaining - ministerCountry:GetBuildCostIC( CSubUnitDataBase.GetSubUnit("infantry_brigade"), 1, false):Get()
		--elseif deployedUnitCount:GetAt(infantryBrigade:GetIndex()) > 0 and bestAvailableUnit:GetIndex() >  infantryBrigade:GetIndex() then
		--if bestAvailableUnit:GetIndex() >  infantryBrigade:GetIndex() then
			--COUNTRY_DEBUG(ministerCountry, "Upgrading Infantry to "..tostring(bestAvailableUnit:GetKey()))
			--local command = CUpgradeRegimentCommand( infantryBrigade, bestAvailableUnit:GetIndex())
			--ai:Post(command)
			--ICRemaining = ICRemaining - ministerCountry:GetBuildCostIC( bestAvailableUnit, 1, false):Get()
		--end
	end
	
	return ICRemaining
end

function EvaluateForts(minister, ICRemaining)
	local ministerCountry = minister:GetCountry()
	--COUNTRY_DEBUG(ministerCountry, "EvaluateForts")
	local ministerTag = minister:GetCountryTag()
	local ai = minister:GetOwnerAI()
	local techStatus = ministerCountry:GetTechnologyStatus()
	local land_fort = CBuildingDataBase.GetBuilding( "land_fort" )
	if techStatus:IsBuildingAvailable(land_fort) then
		local provinces = GetProvinces(minister, false)
		--COUNTRY_DEBUG(ministerCountry,"Investing in IC")
		local tableSize = table.getn(provinces)
		local index = 1
		local icChangeLastLoop = ICRemaining
		local continueLoop = true
		while ICRemaining > ICCutOff and continueLoop do
			local province = CCurrentGameState.GetProvince(provinces[index])
			-- don't double build
			if province:GetCurrentConstructionLevel(land_fort) == 0 then
				ICRemaining = ConstructBuilding(minister, land_fort, provinces[index], ICRemaining)
			end
			index = (index % tableSize) + 1
			if index == 1 then
				if icChangeLastLoop == ICRemaining then
					-- avoid an infinite loop by checking if the IC is changing
					continueLoop = false
				else
					icChangeLastLoop = ICRemaining
				end
			end
		end
	end
	return ICRemaining
end

function ConstructBuilding(minister, building, provinceId, ICRemaining)
	local ministerTag = minister:GetCountryTag()
	local constructCommand = CConstructBuildingCommand(ministerTag, building, provinceId, 1 )
	if constructCommand:IsValid() then
		local ministerCountry = minister:GetCountry()
		local ai = minister:GetOwnerAI()
		local cost = ministerCountry:GetBuildCost(building):Get()
		ai:Post( constructCommand )
		ICRemaining = ICRemaining - cost
	end
	return ICRemaining
end

local countryProvinceLookup = { }
function GetProvinces(minister, isSafe)
	local ministerCountry = minister:GetCountry()
	local lookupKey = tostring(minister:GetCountryTag())
	if isSafe then
		lookupKey = lookupKey .. "safe"
	end
	local cachedProvinceList = countryProvinceLookup[lookupKey]
	local provinceList = { }
	local ai = minister:GetOwnerAI()
	local currentYear = CurrentYear(ai)
	if not cachedProvinceList or (currentYear - cachedProvinceList[1]) > 0.08333 then
		local ministerCountry = minister:GetCountry()
		local scoredProvinceList = { }
		local capitalID = ministerCountry:GetActingCapitalLocation():GetProvinceID()
		local infra = CBuildingDataBase.GetBuilding("infra" )
		local industry = CBuildingDataBase.GetBuilding("industry" )
		local air_base = CBuildingDataBase.GetBuilding("air_base")
		local naval_base = CBuildingDataBase.GetBuilding("naval_base")
		
		for provinceId in ministerCountry:GetCoreProvinces() do
			local province = CCurrentGameState.GetProvince(provinceId)
			local infrastructureLevel = province:GetBuilding(infra):GetMax():Get()
			if infrastructureLevel > 2 then
				
				local score = 0
				if province:IsFrontProvince(false) then
					if isSafe then
						score = score - 1
					else
						score = score + 1
					end
				end
				
				if capitalID == provinceId then
					score = score + 10
				end
				
				if province:GetNumberOfUnits() > 0 then
					score = score + 1
				end
				score = score + province:GetFortLevel()
				score = score + 1.50*province:GetBuilding(industry):GetMax():Get()
				score = score + infrastructureLevel
				score = score + province:GetBuilding(air_base):GetMax():Get()
				score = score + province:GetBuilding(naval_base):GetMax():Get()
				table.insert( scoredProvinceList, {score, provinceId})
			end
		end
		
		table.sort(scoredProvinceList, function(x, y) return x[1] > y[1] end)
		local tableSize = table.getn(scoredProvinceList)
		for index = 1,tableSize do
			table.insert( provinceList, scoredProvinceList[index][2])
		end
		countryProvinceLookup[lookupKey] = {currentYear, provinceList}
	else
		provinceList = cachedProvinceList[2]
	end
	
	return provinceList
end

--ConvoyOrEscort = is a boolean (true = escort, false = convoy)
function ConstructTransportOrEscort(minister, count, ConvoyOrEscort, ic)	
	local ministerCountry = minister:GetCountry()
	local ai = minister:GetOwnerAI()
	local ministerTag = minister:GetCountryTag()
	local cost = 0
	if ConvoyOrEscort then
		cost = ministerCountry:GetConvoyBuildCost():Get()
	else
		cost = ministerCountry:GetEscortBuildCost():Get()
	end
	
	while count > 0 do		
		local buildCommand = CConstructConvoyCommand(ministerTag, ConvoyOrEscort, 1)
		ai:Post(buildCommand)
		count = count - 1
		ic = ic - cost
	end
	return ic
end