-----------------------------------------------------------
-- LUA Hearts of Iron 3 Custom support function file to help quantify valuable statistics to improve the minor country AI's estimates
-- Created By: Thirlan
-- Modified By: Thirlan
-- Date Last Modified: 9/17/2011
-- E-mail: Norvisssion@hotmail.com
-----------------------------------------------------------

-- ============================================================================
-- DATE FUNCTIONS
-- ============================================================================
local _CUST_DAYS_IN_YEAR_ = 365
local _CUST_START_DATE_OF_WWII_ = 1939.36
local _CUST_DAYS_TILL_WAR_LIMBO_PHASE_ = 124
local _CUST_MIN_DAYS_TO_COLLAPSE_ = 93
local _CUST_INF_DAYS_ = 9999999

function DAYS_IN_YEAR()
	return _CUST_DAYS_IN_YEAR_
end

function CurrentYear(ai)
	local currentDate = ai:GetCurrentDate()
	return currentDate:GetYear() + (currentDate:GetMonthOfYear() + currentDate:GetDayOfMonth()/31)/12.0
end

--continents
-- north_america
-- europe

local _CUST_WAR_DATES_ = {
	["ETH"] = 1936.2, -- Ethiopia?
	["SPR"] = 1936.2, -- Spain Republic
	["GRE"] = 1938, -- Greece?
	["YUG"] = 1938, -- Yugoslavia
	["POR"] = 1940, -- Portugal
	["YEM"] = 1940, -- Yemen?
	["SAU"] = 1940, -- Saudi Arabia
	
	["CHI"] = 1937.4, -- China
	["MAN"] = 1937.4, -- Manchuria?
	["MEN"] = 1937.4, -- Mengkukuo
	["CYN"] = 1937.4, -- Yunnan
	["CHC"] = 1937.4, -- Communist China
	["CGX"] = 1937.4, -- Guangxi Clique
	["CSX"] = 1937.4, -- Shanxi
	["SIK"] = 1940, -- Siankiang
	["TIB"] = 1940, -- Tibet
	["PHI"] = 1940, -- Philipines?
	["AFG"] = 1940, -- Afghanistan?
	
	["ECU"] = 1940, -- Ecuador?
	["PER"] = 1940, -- Peru?
	["COL"] = 1940, -- Columbia?
	["CHL"] = 1940, -- Chile?
	["COS"] = 1940, -- Costa Rica?
	["HAI"] = 1940, -- Haiti?
	["HON"] = 1940, -- Honduras?
	["MEX"] = 1940, -- Mexico?
	["NIC"] = 1940, -- Nicaragua?
	["ARG"] = 1940, -- Argentina?
	["BOL"] = 1940, -- Bolivia?
	["BRA"] = 1940, -- Brazil?
	["URU"] = 1940, -- Uruguay
	["VEN"] = 1940, -- Venezuala
	["CUB"] = 1940, -- Cuba
	["DOM"] = 1940, -- Dominican Republic
	["SAL"] = 1940 -- El Salvador
	
}

-- Use caching to avoid looking up the effective IC several times on the same date for the same country
function DaysTillWar(ministerCountry, ai)

	-- useful stats for later
	-- local neutrality 			= ministerCountry:GetNeutrality()
	-- local effectiveNeutrality 	= ministerCountry:GetEffectiveNeutrality()
	-- local highestThreat 		= ministerCountry:GetHighestThreat()
	
	local daysTillWar = 0
	if ministerCountry:IsAtWar() == false then
		local yearOfWar = nil
		yearOfWar = _CUST_WAR_DATES_[tostring(ministerCountry:GetCountryTag())]
		if not yearOfWar then
			yearOfWar = _CUST_START_DATE_OF_WWII_
		end
		--COUNTRY_DEBUG(ministerCountry, "yearOfWar = " .. yearOfWar)
		daysTillWar = _CUST_DAYS_IN_YEAR_ * (yearOfWar - CurrentYear(ai))
		if daysTillWar < 0 then
			-- we've already passed the expected war date so now we're in limbo phase
			-- we expect war to be any time now...
			daysTillWar = _CUST_DAYS_TILL_WAR_LIMBO_PHASE_
		end
	end
	--COUNTRY_DEBUG(ministerCountry, "daysTillWar = " .. daysTillWar)
	return daysTillWar
end

function MinDaysToCollapse(ministerCountry, ai)
	return DaysTillWar(ministerCountry, ai) + _CUST_MIN_DAYS_TO_COLLAPSE_
end

function INF_DAYS()
	return _CUST_INF_DAYS_
end

-- ============================================================================
-- TECH FUNCTIONS
-- ============================================================================
local _CUST_AHEAD_OF_TECH_PENALTY_ = 0.3

function ResearchTime(ministerCountry, ai, tech, nextLevel, researchYear)
	local techName = tostring(tech:GetKey())
	
	local techStatus = ministerCountry:GetTechnologyStatus()
	local techLevel = techStatus:GetLevel(tech)
	local targetLevel = techLevel + nextLevel
	local techYear = techStatus:GetYear(tech, targetLevel)
	local cost = techStatus:GetCost(tech, targetLevel):Get()
	local techYearDiff = techYear - researchYear
	local techYearPenalty = 0
	if techYearDiff > 0 then
		local techYearDiffInt = math.floor(techYearDiff)
		local techYearDiffFrac = techYearDiff-techYearDiffInt
		techYearPenalty = (((techYearDiffInt+1)*techYearDiffInt/2)+techYearDiffFrac) * _CUST_DAYS_IN_YEAR_ * _CUST_AHEAD_OF_TECH_PENALTY_
		--COUNTRY_DEBUG(ministerCountry, "Penalty("..researchYear..", "..techYear..") = "..techYearPenalty)
	end
	local adjustedCost = cost + techYearPenalty
	
	--COUNTRY_DEBUG(ministerCountry, techName .. " -> c " .. cost .. " a " .. adjustedCost .. " lvl " .. techLevel)
	
	return adjustedCost
end

function TechYearSkew(minister, tech, nextLevel, researchYear)
	local ministerCountry = minister:GetCountry()
	local ai = minister:GetOwnerAI()
	local techStatus = ministerCountry:GetTechnologyStatus()
	local techLevel = techStatus:GetLevel(tech)
	local targetLevel = techLevel + nextLevel
	local techYear = techStatus:GetYear(tech, targetLevel)
	local skew = 1+(techYear-researchYear)/100
	return math.pow(skew, 1.5)
end

function CalculateWeightedTheoryScore(ministerCountry, techList)
	local weightedScore = 0
	local count = 0
	for index, tech in pairs(techList) do
		local techName = tostring(tech:GetKey())
		count = count + 1
		for bonus in tech:GetResearchBonus() do
			local theoryScore = 1.0 * ministerCountry:GetAbility(bonus._pCategory)
			local weight = bonus._vWeight:Get()
			weightedScore = weightedScore + theoryScore * weight
			--COUNTRY_DEBUG(ministerCountry, techName .. " -> " .. tostring(bonus._pCategory:GetKey()) .. " " .. theoryScore .. " " .. weight )
		end
	end
	
	return weightedScore / count
end

function CalculateResearchListETA(ministerCountry, ai, techList)
	local techStatus = ministerCountry:GetTechnologyStatus()
	local groupIncr = 0
	local maxGroupTime = 0
	local researchTime = 0
	local totalTime = 0
	local techLevel = 0
	local currentYear = CurrentYear(ai)
	-- assume a 75% efficiency with leadership
	local totalAvailableLeadership = math.floor(0.75*ministerCountry:GetTotalLeadership():Get())
	--COUNTRY_DEBUG(ministerCountry, "=========CalculateResearchListETA=============")
	--COUNTRY_DEBUG(ministerCountry, "totalAvailableLeadership = "..totalAvailableLeadership)
	for techName, req in pairs(techList) do
		tech = CTechnologyDataBase.GetTechnology(techName)
		techLevel = techStatus:GetLevel(tech)
		if techLevel < req then
			-- this is a rather complex algorithm because it is making a rough estimate of
			-- of the total research time by grouping the research into groups whose size is 
			-- equal to the available leadership. It finds the max research of a given 
			-- group and adds it to the total.
			researchTime = ResearchTime(ministerCountry, ai, tech, 1, currentYear)
			maxGroupTime = math.max(researchTime, maxGroupTime)
			groupIncr = groupIncr + (req-techLevel)
			--COUNTRY_DEBUG(ministerCountry, "techName = "..techName)
			--COUNTRY_DEBUG(ministerCountry, "req = "..req)
			--COUNTRY_DEBUG(ministerCountry, "techLevel = "..techLevel)
			--COUNTRY_DEBUG(ministerCountry, "researchTime = "..researchTime)
			--COUNTRY_DEBUG(ministerCountry, "maxGroupTime = "..maxGroupTime)
			if groupIncr >= totalAvailableLeadership then
				totalTime = totalTime + maxGroupTime
				groupIncr = groupIncr - totalAvailableLeadership
				while groupIncr >= totalAvailableLeadership do
					-- this one tech has enough req to fill one or more groups.
					totalTime = totalTime + researchTime
					groupIncr = groupIncr - totalAvailableLeadership
				end
			end
			--COUNTRY_DEBUG(ministerCountry, "currentTotalTime = "..totalTime)
		end
	end
	if groupIncr > 0 then
		-- clean up the trailing techs that were too small to form a complete group
		totalTime = totalTime + maxGroupTime
	end
	--COUNTRY_DEBUG(ministerCountry, "totalTime = "..totalTime)
	--COUNTRY_DEBUG(ministerCountry, "==============================================")
	return totalTime
end

-- ============================================================================
-- IC FUNCTIONS
-- ============================================================================
local _CUST_MANPOWER_UPKEEP_PER_MANPOWER_COST_ = 0.25
local _CUST_IC_CONSUMPTION_RESOURCE = { 0, 1, 2, 0.5, 0, 0, 0}
local _CUST_CONSTRUCTION_PRACTICAL_INDEX_ = 48
local _CUST_SLIDER_TO_MANPOWER_RATIO_ = 4.7

local _MONEY_ = 1
local _METAL_ = 2
local _ENERGY_ = 3
local _RARE_MATERIALS_ = 4
local _CRUDE_OIL_ = 5
local _SUPPLIES_ = 6
local _FUEL_ = 7

local _MINIMAL_TRAINING_ = 26
local _BASIC_TRAINING_ = 27
local _ADVANCED_TRAINING_ = 28
local _SPECIALIST_TRAINING_ = 29

local laCrossValue = {
	CGoodsPool._MONEY_,
	CGoodsPool._METAL_,
	CGoodsPool._ENERGY_,
	CGoodsPool._RARE_MATERIALS_,
	CGoodsPool._CRUDE_OIL_,
	CGoodsPool._SUPPLIES_,
	CGoodsPool._FUEL_
}

local _CUST_BASE_IC_BUILD_TIME_ = 372
local _CUST_IC_LAW_BOOST_ = { 0.5, 0.75, 1, 1.25, 1.50}
local _CUST_RESOURCE_LAW_BOOST_ = { 0.5, 0.75, 1.0, 1.10, 1.25}
local _CUST_TRAINING_LAW_BOOST_ = { 0.90, 1.0, 1.1, 1.2}
local _CUST_RESCUE_RATIO_ = 2
local _CUST_IC_TO_SUPPLY_RATIO_ = 7

function EffectiveIC(ministerCountry, ai)
	
	local key = "EffectiveIC-"..tostring(ministerCountry:GetCountryTag())
	local effectiveIC = GetCustCache(ai, key)
	if not effectiveIC then
		local consumerNeed = ministerCountry:GetProductionDistributionAt( CDistributionSetting._PRODUCTION_CONSUMER_):GetNeeded():Get()
		local supplyNeed = SupplyNeedMultiplier(ministerCountry, ai) * ministerCountry:GetProductionDistributionAt( CDistributionSetting._PRODUCTION_SUPPLY_):GetNeeded():Get() 
		local rareICPenalty = ImminentResourceShortageICPenalty( ministerCountry, _RARE_MATERIALS_)
		local metalICPenalty = ImminentResourceShortageICPenalty( ministerCountry, _METAL_)
		local energyICPenalty = ImminentResourceShortageICPenalty( ministerCountry, _ENERGY_)
		
		local resourcePenalty = math.min( math.min( rareICPenalty, metalICPenalty), energyICPenalty)
		local unadjustedIC = ministerCountry:GetTotalIC()
		-- resourcePenalty is a negative number
		effectiveIC = math.max(0, unadjustedIC + resourcePenalty - consumerNeed - supplyNeed)
		
		-- always floor the effective IC to give a pessimistic view
		-- and to smooth out noise
		effectiveIC = math.floor(effectiveIC)
		if false then
			COUNTRY_DEBUG(ministerCountry, "=============EffectiveIC======================")
			COUNTRY_DEBUG(ministerCountry, "unadjustedIC = " .. unadjustedIC)
			COUNTRY_DEBUG(ministerCountry, "consumerNeed = " .. consumerNeed)
			COUNTRY_DEBUG(ministerCountry, "supplyNeed = " .. supplyNeed)
			COUNTRY_DEBUG(ministerCountry, "resourcePenalty = " .. resourcePenalty)
			COUNTRY_DEBUG(ministerCountry, "    rareICPenalty = " .. rareICPenalty)
			COUNTRY_DEBUG(ministerCountry, "    metalICPenalty = " .. metalICPenalty)
			COUNTRY_DEBUG(ministerCountry, "    energyICPenalty = " .. energyICPenalty)
			COUNTRY_DEBUG(ministerCountry, "effectiveIC = " .. effectiveIC)
			COUNTRY_DEBUG(ministerCountry, "==============================================")
		end
		SetCustCache(ai, key, 2, effectiveIC)
	end
	
	return effectiveIC
end

function SupplyNeedMultiplier(ministerCountry, ai)
	local supplyStockpile = ministerCountry:GetPool():Get( CGoodsPool._SUPPLIES_ ):Get()
	local totalIC = ministerCountry:GetTotalIC()
	local consumerNeed = ministerCountry:GetProductionDistributionAt( CDistributionSetting._PRODUCTION_CONSUMER_):GetNeeded():Get()
	local supplyNeed = ministerCountry:GetProductionDistributionAt( CDistributionSetting._PRODUCTION_SUPPLY_):GetNeeded():Get()
	local threeMonths = 93
	local supplyRequirements = supplyNeed*_CUST_IC_TO_SUPPLY_RATIO_*threeMonths
	-- avoid a division by zero
	supplyRequirements = math.max(1, supplyRequirements)
	local supplyMultiplier = 2.1-supplyStockpile/supplyRequirements
	local totalRescueNeed = supplyMultiplier*supplyNeed + consumerNeed
	
	-- supplies are not needed until roughly when war starts or if we have so little IC that we can't fully support our current supply needs
	if not PrepareForWar(ministerCountry, ai) and totalRescueNeed < totalIC then
		supplyMultiplier = 0
	end
	return supplyMultiplier
end

function EffectiveICMultiplierAtCurrent(ministerCountry)
	return ministerCountry:GetTotalIC()/ministerCountry:GetMaxIC()
end

function MiscICBoost(ministerCountry)
	local currentIC = ministerCountry:GetTotalIC()
	--COUNTRY_DEBUG(ministerCountry,"currentIC = "..currentIC)
	local maxIC = ministerCountry:GetMaxIC()
	--COUNTRY_DEBUG(ministerCountry,"maxIC = "..maxIC)

	-- figure out what kind of misc boosts there are on this country
	local civilianEconomy = CLawDataBase.GetLaw(11)
	local economicLawGroup = civilianEconomy:GetGroup()
	local currentEconomicLawIndex = ministerCountry:GetLaw(economicLawGroup):GetIndex()
	local adjustedIndex = currentEconomicLawIndex-civilianEconomy:GetIndex()+1
	local currentICBoost = _CUST_IC_LAW_BOOST_[adjustedIndex]
	return (currentIC/maxIC)-currentICBoost
end

function EffectiveICMultiplierAtWar(ministerCountry)
	-- fetch max law IC boost
	local lawBoostLength = table.getn(_CUST_IC_LAW_BOOST_)
	local maxICBoost = _CUST_IC_LAW_BOOST_[lawBoostLength]
	
	return maxICBoost + MiscICBoost(ministerCountry)
end

function ICChangeAtDayOfWar(ministerCountry)
	return ministerCountry:GetMaxIC() * EffectiveICMultiplierAtWar(ministerCountry) - ministerCountry:GetTotalIC()
end

function ResourceBoostAtDayOfWar(ministerCountry)
	-- fetch max law IC boost
	local civilianEconomy = CLawDataBase.GetLaw(11)
	local economicLawGroup = civilianEconomy:GetGroup()
	local currentEconomicLawIndex = ministerCountry:GetLaw(economicLawGroup):GetIndex()
	local adjustedIndex = currentEconomicLawIndex-civilianEconomy:GetIndex()+1
	local lawBoostLength = table.getn(_CUST_RESOURCE_LAW_BOOST_)
	local maxResourceBoost = _CUST_RESOURCE_LAW_BOOST_[lawBoostLength] - _CUST_RESOURCE_LAW_BOOST_[adjustedIndex]
	return maxResourceBoost
end

function ICBuildTime(minister)
	-- TODO, replace this estimation function with the actual in game API provided function when
	-- we find the damn thing...
	local practicalScore = GetConstructionPractical(minister)
	return _CUST_BASE_IC_BUILD_TIME_ * (1.5 - 0.1 * practicalScore)
end

function ICDaysCostOfIndustry(minister, ai)
	local ministerCountry = minister:GetCountry()
	local industry = CBuildingDataBase.GetBuilding("industry")
	local icCost = ministerCountry:GetBuildCost(industry):Get()
	local icBuildTime = ICBuildTime(minister)
	-- Do we even have the IC to build at full speed?
	local effectiveIC = EffectiveIC(ministerCountry, ai)
	local buildPenalty = 999999 -- make the penalty huge
	if effectiveIC > 0 then
		buildPenalty = math.min(1, icCost/effectiveIC)
	end
	return buildPenalty*icCost*icBuildTime
end

function InvestInIC(minister)
	local ministerCountry = minister:GetCountry()
	local ai = minister:GetOwnerAI()
	local invest = false
	
	-- if we are suffering a resource shortage that affects IC then don't even bother investing in IC
	if not HasICResourceShortage(ministerCountry, ai) then
		local constructionEngineer = CTechnologyDataBase.GetTechnology("construction_engineering")
		local constrEngineerResearchTime = 0
		local countryTag = ministerCountry:GetCountryTag()
		if constructionEngineer:CanResearch(countryTag) then
			constrEngineerResearchTime = ResearchTime(ministerCountry, ai, constructionEngineer, 1, CurrentYear(ai))
		end
		--COUNTRY_DEBUG(ministerCountry, "constrEngineerResearchTime = " .. constrEngineerResearchTime)
		
		local icDaysCost = ICDaysCostOfIndustry(minister, ai)
		--COUNTRY_DEBUG(ministerCountry, "icDaysCost = " .. icDaysCost)
		
		local daysTillWar = DaysTillWar(ministerCountry, ai)
		--COUNTRY_DEBUG(ministerCountry, "daysTillWar = " .. daysTillWar)
		local icBuildTime = ICBuildTime(minister)
		--COUNTRY_DEBUG(ministerCountry, "icBuildTime = " .. icBuildTime)
		
		local icPeaceDays = daysTillWar - icBuildTime - constrEngineerResearchTime
		local icWarDays = math.max(0, MinDaysToCollapse(ministerCountry, ai) - daysTillWar)
		local icPeaceGain = 0
		if icPeaceDays > 0.0 then
			icPeaceGain = EffectiveICMultiplierAtCurrent(ministerCountry)*icPeaceDays
		else
			-- the peace days were negative, which means the construction
			-- and research time overflowed into the war period
			icWarDays = math.max(0, icWarDays + icPeaceDays)
		end 
		--COUNTRY_DEBUG(ministerCountry, "icPeaceDays = " .. icPeaceDays)
		--COUNTRY_DEBUG(ministerCountry, "icWarDays = " .. icWarDays)
		--COUNTRY_DEBUG(ministerCountry, "icPeaceGain = " .. icPeaceGain)
		
		local icWarGain = EffectiveICMultiplierAtWar(ministerCountry) * icWarDays
		--COUNTRY_DEBUG(ministerCountry, "icWarGain = " .. icWarGain)
		
		local ROI = icWarGain + icPeaceGain - icDaysCost
		
		--COUNTRY_DEBUG(ministerCountry, "IC ROI = " .. ROI)
		invest = ROI > 0.0
	end
	return invest
end

function HasICShortage(ministerCountry, ai)
	local bestAvailableUnit = BestAvailableUnit(ministerCountry, ai)
	local effectiveIC = EffectiveIC(ministerCountry, ai)
	local icCost = ministerCountry:GetBuildCostIC( bestAvailableUnit, 1, false):Get()
	return effectiveIC < icCost
end

-- ============================================================================
-- MISC FUNCTIONS
-- ============================================================================
function COUNTRY_DEBUG(ministerCountry, message)
	local countryName = tostring(ministerCountry:GetCountryTag())
	if countryName == "POL" then
		Utils.LUA_DEBUGOUT(countryName .." " .. message)
	end
end

function EffectiveManPower(ministerCountry)
	local reinforceSlider = ministerCountry:GetProductionDistributionAt( CDistributionSetting._PRODUCTION_REINFORCEMENT_):GetNeeded():Get()
	local effectiveManPower = ministerCountry:GetManpower():Get()
	local unitList = ministerCountry:GetUnits()
	local unitReserves = 3.33*unitList:GetTotalAmountOfDivisions() + 1*unitList:GetTotalNumOfShips() + 1*unitList:GetTotalNumOfPlanes()
	effectiveManPower = effectiveManPower - 0.75*unitReserves - _CUST_SLIDER_TO_MANPOWER_RATIO_*reinforceSlider
	effectiveManPower = math.max(0, effectiveManPower)
	--COUNTRY_DEBUG(ministerCountry, "================EffectiveManPower============")
	--COUNTRY_DEBUG(ministerCountry, "GetTotalAmountOfDivisions = "..ministerCountry:GetUnits():GetTotalAmountOfDivisions())
	--COUNTRY_DEBUG(ministerCountry, "GetTotalNumOfShips = "..ministerCountry:GetUnits():GetTotalNumOfShips())
	--COUNTRY_DEBUG(ministerCountry, "GetTotalNumOfPlanes = "..ministerCountry:GetUnits():GetTotalNumOfPlanes())
	--COUNTRY_DEBUG(ministerCountry, "reinforceSlider = ".._CUST_SLIDER_TO_MANPOWER_RATIO_*reinforceSlider)
	--COUNTRY_DEBUG(ministerCountry, "effectiveManPower = "..effectiveManPower)
	--COUNTRY_DEBUG(ministerCountry, "=============================================")
	return effectiveManPower 
end

function DivisionICRatio(ministerCountry, ai, mainUnit, mainUnitCount, supportUnit, supportUnitCount)
	local icCost = mainUnitCount*ministerCountry:GetBuildCostIC( mainUnit, 1, false):Get()
	if not supportUnit and supportUnitCount > 0 then
		icCost = icCost + supportUnitCount*ministerCountry:GetBuildCostIC( supportUnit, 1, false):Get()
	end
	return EffectiveIC(ministerCountry, ai) / icCost
end

function DivisionDaysToMPDepletion(ministerCountry, ai, mainUnit, mainUnitCount, supportUnit, supportUnitCount)

	local mpCost = mainUnitCount*ministerCountry:GetBuildCostMP( mainUnit, false):Get()
	local buildTime = ministerCountry:GetBuildTime( mainUnit, 1)
	if not supportUnit and supportUnitCount > 0 then
		mpCost = mpCost + supportUnitCount*ministerCountry:GetBuildCostMP( supportUnit, false):Get()
		buildTime = math.max(buildTime, ministerCountry:GetBuildTime( supportUnit, 1))
	end
	
	local icRatio = DivisionICRatio(ministerCountry, ai, mainUnit, mainUnitCount, supportUnit, supportUnitCount)
	local mpConsumptionRatePerDay = icRatio*mpCost/buildTime
	local effectiveMP = EffectiveManPower(ministerCountry)
	--COUNTRY_DEBUG(ministerCountry, "icRatio = "..icRatio)
	--COUNTRY_DEBUG(ministerCountry, "mpCost = "..mpCost)
	--COUNTRY_DEBUG(ministerCountry, "buildTime = "..buildTime)
	--COUNTRY_DEBUG(ministerCountry, "mpConsumptionRatePerDay = "..mpConsumptionRatePerDay)
	--COUNTRY_DEBUG(ministerCountry, "effectiveMP = "..effectiveMP)
	return effectiveMP / mpConsumptionRatePerDay
end

function ConstructLandDivision(ministerCountry, baseUnit, baseQuantity, supportUnit, supportQuantity)
	local divisionList = SubUnitList()
	local icCost = baseQuantity*ministerCountry:GetBuildCostIC( baseUnit, 1, false):Get()+supportQuantity*ministerCountry:GetBuildCostIC( baseUnit, 1, false)
	local mpCost = baseQuantity*ministerCountry:GetBuildCostMP( baseUnit, false):Get()
	local timeCost = ministerCountry:GetBuildTime( baseUnit, 1)
	for baseCount = 1,baseQuantity do
		SubUnitList.Append( divisionList, baseUnit )
	end
	if supportUnit then
		icCost = icCost + supportQuantity*ministerCountry:GetBuildCostIC( supportUnit, 1, false)
		mpCost = mpCost + supportQuantity*ministerCountry:GetBuildCostMP( supportUnit, false):Get()
		timeCost = math.max(timeCost, ministerCountry:GetBuildTime( supportUnit, 1))
		for supportCount = 1,supportQuantity do
			SubUnitList.Append( divisionList, supportUnit )
		end
	end
	return icCost, mpCost, timeCost, divisionList
end

function EffectiveUnitBuildTime(ministerCountry, ai, subUnit)
	local buildTime = ministerCountry:GetBuildTime( subUnit, 1)
	local icCost = mainUnitCount*ministerCountry:GetBuildCostIC( subUnit, 3, false):Get()
end

function DaysTillResourceDepletion(ministerCountry, ai, resourceType)
	local key = "DaysTillResourceDepletion-"..resourceType.."-"..tostring(ministerCountry:GetCountryTag())
	local daysTillDepleted = GetCustCache(ai, key)

	if not daysTillDepleted then 
		local resourceData = CResourceValues()
		resourceData:GetResourceValues(ministerCountry, laCrossValue[resourceType])
		
		local dailyBalance = resourceData.vDailyBalance
		local daysTillWar = DaysTillWar(ministerCountry, ai)
		local pool = resourceData.vPool
		local adjustedPool = pool + dailyBalance*daysTillWar
		daysTillDepleted = _CUST_INF_DAYS_
		if adjustedPool <= 0 or ministerCountry:IsAtWar() then
			if dailyBalance < 0 then
				daysTillDepleted = -1.0*pool/dailyBalance
				if false then
					COUNTRY_DEBUG(ministerCountry, "=========DaysTillResourceDepletion===========")
					COUNTRY_DEBUG(ministerCountry, "resourceType = "..resourceType)
					COUNTRY_DEBUG(ministerCountry, "dailyBalance = "..dailyBalance)
					COUNTRY_DEBUG(ministerCountry, "pool = "..pool)
					COUNTRY_DEBUG(ministerCountry, "adjustedPool = "..adjustedPool)
					COUNTRY_DEBUG(ministerCountry, "daysTillDepleted = "..daysTillDepleted)
					COUNTRY_DEBUG(ministerCountry, "=============================================")
				end
			end
		else
			local icChangeAtWar = ICChangeAtDayOfWar(ministerCountry)
			local icWarConsumption = icChangeAtWar * _CUST_IC_CONSUMPTION_RESOURCE[resourceType]
			-- only calculate what we get from home produced... never include trades
			local dailyHome = resourceData.vDailyHome
			if resourceType == _FUEL_ then
				-- fuel is produced unlike other resources
				dailyHome = resourceData.vDailyIncome
			end
			local dailyWarBalance = (1+ResourceBoostAtDayOfWar(ministerCountry)) * dailyHome - resourceData.vDailyExpense - icWarConsumption
			if dailyWarBalance < 0 then
				daysTillDepleted = -1.0*adjustedPool/(dailyWarBalance) + daysTillWar
				if false then
					COUNTRY_DEBUG(ministerCountry, "=========DaysTillResourceDepletion===========")
					COUNTRY_DEBUG(ministerCountry, "resourceType = "..resourceType)
					COUNTRY_DEBUG(ministerCountry, "dailyBalance = "..dailyBalance)
					COUNTRY_DEBUG(ministerCountry, "pool = "..pool)
					COUNTRY_DEBUG(ministerCountry, "adjustedPool = "..adjustedPool)
					COUNTRY_DEBUG(ministerCountry, "icChangeAtWar = "..icChangeAtWar)
					COUNTRY_DEBUG(ministerCountry, "icWarConsumption = "..icWarConsumption)
					COUNTRY_DEBUG(ministerCountry, "dailyWarBalance = "..dailyWarBalance)
					COUNTRY_DEBUG(ministerCountry, "daysTillDepleted = "..daysTillDepleted)
					COUNTRY_DEBUG(ministerCountry, "=============================================")
				end
			end
		end
		SetCustCache(ai, key, 2, daysTillDepleted)
	end
	
	return daysTillDepleted
end

function HasResourceShortage(minister)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local daysToCollapse = MinDaysToCollapse(ministerCountry, ai)
	return DaysTillResourceDepletion(ministerCountry, ai, _RARE_MATERIALS_) < daysToCollapse or
			DaysTillResourceDepletion(ministerCountry, ai, _METAL_) < daysToCollapse or
			DaysTillResourceDepletion(ministerCountry, ai, _ENERGY_) < daysToCollapse or
			DaysTillResourceDepletion(ministerCountry, ai, _SUPPLIES_) < daysToCollapse
end

function HasICResourceShortage(ministerCountry, ai)

	local hasShortage = ministerCountry:GetPool():Get( CGoodsPool._RARE_MATERIALS_ ):Get() < 2 or
		   ministerCountry:GetPool():Get( CGoodsPool._METAL_ ):Get() < 2 or
		   ministerCountry:GetPool():Get( CGoodsPool._ENERGY_ ):Get() < 2
	
	if not hasShortage then
		local daysToCollapse = MinDaysToCollapse(ministerCountry, ai)
		hasShortage =  DaysTillResourceDepletion(ministerCountry, ai, _RARE_MATERIALS_) < daysToCollapse or
				DaysTillResourceDepletion(ministerCountry, ai, _METAL_) < daysToCollapse or
				DaysTillResourceDepletion(ministerCountry, ai, _ENERGY_) < daysToCollapse
	end
	return hasShortage
end

function ImminentResourceShortageICPenalty(ministerCountry, resourceType)
	local resourceData = CResourceValues()
	resourceData:GetResourceValues(ministerCountry, laCrossValue[resourceType])
	local immediateBalance = resourceData.vPool - resourceData.vDailyBalance
	local ICPenalty = 0
	if immediateBalance < 0 then
		ICPenalty = EffectiveICMultiplierAtCurrent(ministerCountry) * (immediateBalance/_CUST_IC_CONSUMPTION_RESOURCE[resourceType])
	end
	
	return ICPenalty
end

function GetTotalSubUnitsBuiltByCollapse(ministerCountry, ai, subUnit)
	local totalBuilt = 0
	local daysToBuild = MinDaysToCollapse(ministerCountry, ai)
	local unitRequirementTable = GetUnitRequirementTable(subUnit)
	local researchTime = 0
	if unitRequirementTable then
		researchTime = CalculateResearchListETA(ministerCountry, ai, unitRequirementTable)
	end
	daysToBuild = daysToBuild - researchTime
	if daysToBuild > 0 then
		local icCost, mpCost, timeCost, divisionList = ConstructLandDivision(ministerCountry, subUnit, 1, nil, 0)
		local MPRemaining = EffectiveManPower(ministerCountry)
		local effectiveIC = EffectiveIC(ministerCountry, ai)
		totalBuilt = math.min((effectiveIC/icCost)*(daysToBuild/timeCost),
								MPRemaining/mpCost)
		totalBuilt = math.floor(totalBuilt)
		if false then
			COUNTRY_DEBUG(ministerCountry, "=========GetTotalSubUnitsBuiltByCollapse===========")
			COUNTRY_DEBUG(ministerCountry, "researchTime = ".. researchTime)
			COUNTRY_DEBUG(ministerCountry, "daysToBuild = ".. daysToBuild)
			COUNTRY_DEBUG(ministerCountry, "icCost = ".. icCost)
			COUNTRY_DEBUG(ministerCountry, "mpCost = ".. mpCost)
			COUNTRY_DEBUG(ministerCountry, "timeCost = ".. timeCost)
			COUNTRY_DEBUG(ministerCountry, "MPRemaining = ".. MPRemaining)
			COUNTRY_DEBUG(ministerCountry, "effectiveIC = ".. effectiveIC)
			COUNTRY_DEBUG(ministerCountry, "total "..tostring(subUnit:GetKey()).." Built = ".. totalBuilt)
			COUNTRY_DEBUG(ministerCountry, "==================================================")
		end
	end
	return totalBuilt
end

function FavoriteUnit(ministerCountry, ai)
	local key = "FavoriteUnit-"..tostring(ministerCountry:GetCountryTag())
	local favoriteUnit = GetCustCache(ai, key)
	
	if not favoriteUnit then
		--local unitList = ministerCountry:GetUnits() this is currently useless since it always returns 0 for
		-- all the units.
		local maxValue = 0
		local subUnit = CSubUnitDataBase.GetSubUnit("infantry_brigade")
		local weight = ministerCountry:GetBuildCostIC( subUnit, 1, false):Get()
		local subUnitCount = weight*(GetTotalSubUnitsBuiltByCollapse(ministerCountry, ai, subUnit)+GetTotalUnitCount(ministerCountry, subUnit))
		favoriteUnit = subUnit
		maxValue = subUnitCount
		COUNTRY_DEBUG(ministerCountry, tostring(subUnit:GetKey()).." subUnitCount = ".. subUnitCount)
		
		subUnit = CSubUnitDataBase.GetSubUnit("militia_brigade")
		weight = ministerCountry:GetBuildCostIC( subUnit, 1, false):Get()
		subUnitCount = weight*(GetTotalSubUnitsBuiltByCollapse(ministerCountry, ai, subUnit)+GetTotalUnitCount(ministerCountry, subUnit))
		if subUnitCount > maxValue then
			favoriteUnit = subUnit
			maxValue = subUnitCount
		end
		COUNTRY_DEBUG(ministerCountry, tostring(subUnit:GetKey()).." subUnitCount = ".. subUnitCount)
		
		if IsJungleAndIsland(ministerCountry) then
			subUnit = CSubUnitDataBase.GetSubUnit("marine_brigade")
			weight = ministerCountry:GetBuildCostIC( subUnit, 1, false):Get()
			subUnitCount = weight*(GetTotalSubUnitsBuiltByCollapse(ministerCountry, ai, subUnit)+GetTotalUnitCount(ministerCountry, subUnit))
			if subUnitCount > maxValue then
				favoriteUnit = subUnit
				maxValue = subUnitCount
			end
			COUNTRY_DEBUG(ministerCountry, tostring(subUnit:GetKey()).." subUnitCount = ".. subUnitCount)
		else
			subUnit = CSubUnitDataBase.GetSubUnit("bergsjaeger_brigade")
			weight = ministerCountry:GetBuildCostIC( subUnit, 1, false):Get()
			subUnitCount = weight*(GetTotalSubUnitsBuiltByCollapse(ministerCountry, ai, subUnit)+GetTotalUnitCount(ministerCountry, subUnit))
			if subUnitCount > maxValue then
				favoriteUnit = subUnit
				maxValue = subUnitCount
			end
			COUNTRY_DEBUG(ministerCountry, tostring(subUnit:GetKey()).." subUnitCount = ".. subUnitCount)
		end
		
		local fuelData = CResourceValues()
		fuelData:GetResourceValues(ministerCountry, laCrossValue[_FUEL_])
		if fuelData.vDailyIncome > 0 then
			subUnit = CSubUnitDataBase.GetSubUnit("motorized_brigade")
			weight = ministerCountry:GetBuildCostIC( subUnit, 1, false):Get()
			subUnitCount = weight*(GetTotalSubUnitsBuiltByCollapse(ministerCountry, ai, subUnit)+GetTotalUnitCount(ministerCountry, subUnit))
			if subUnitCount > maxValue then
				favoriteUnit = subUnit
				maxValue = subUnitCount
			end
			COUNTRY_DEBUG(ministerCountry, tostring(subUnit:GetKey()).." subUnitCount = ".. subUnitCount)
		end
			
		COUNTRY_DEBUG(ministerCountry, "Favorite Unit is ".. tostring(favoriteUnit:GetKey()))
		if IsTotalUnitListSet(ministerCountry) then
			-- hold off on caching this until this data is set
			SetCustCache(ai, key, 31, favoriteUnit)
		end
	end
	
	return favoriteUnit
end

function FavoriteSupportUnit(ministerCountry, ai, unitType)
	local selectedSupport = nil
	local unitTypeName = tostring(unitType:GetKey())
	if unitTypeName == "infantry_brigade" then
		local favoriteUnit = FavoriteUnit(ministerCountry, ai)
		local favoriteUnitName = tostring(favoriteUnit:GetKey())
		if favoriteUnitName == "motorized_brigade"  then
			selectedSupport = CSubUnitDataBase.GetSubUnit("tank_destroyer_brigade")
		elseif GetContinent(ministerCountry) == "europe" then
			selectedSupport = CSubUnitDataBase.GetSubUnit("anti_tank_brigade")
		elseif IsJungleAndIsland(ministerCountry) then
			selectedSupport = CSubUnitDataBase.GetSubUnit("engineer_brigade")
		else
			selectedSupport = CSubUnitDataBase.GetSubUnit("artillery_brigade")
		end
	elseif unitTypeName == "bergsjaeger_brigade" then
		if GetContinent(ministerCountry) == "europe" then
			selectedSupport = CSubUnitDataBase.GetSubUnit("anti_tank_brigade")
		else
			selectedSupport = CSubUnitDataBase.GetSubUnit("artillery_brigade")
		end
	elseif unitTypeName == "marine_brigade" then
		if GetContinent(ministerCountry) == "europe" then
			selectedSupport = CSubUnitDataBase.GetSubUnit("anti_tank_brigade")
		else
			selectedSupport = CSubUnitDataBase.GetSubUnit("engineer_brigade")
		end
	elseif unitTypeName == "motorized_brigade" then
		selectedSupport = CSubUnitDataBase.GetSubUnit("tank_destroyer_brigade")
	end
	
	return selectedSupport
end

function BestAvailableSupportUnit(ministerCountry, ai, unitType)
	local bestAvailableSupportUnit = FavoriteSupportUnit(ministerCountry, ai, unitType)
	local techStatus = ministerCountry:GetTechnologyStatus()
	if bestAvailableSupportUnit and not techStatus:IsUnitAvailable(bestAvailableSupportUnit) then
		bestAvailableSupportUnit = nil
	end
	
	return bestAvailableSupportUnit
end

-- Sometimes the favorite unit is just out of reach and so we need to build alternatives
-- while we wait
function BestAvailableUnit(ministerCountry, ai)
	local key = "BestAvailableUnit-"..tostring(ministerCountry:GetCountryTag())
	local bestAvailableUnit = GetCustCache(ai, key)
	local favoriteUnit = FavoriteUnit(ministerCountry, ai)
	
	if not bestAvailableUnit then
		local techStatus = ministerCountry:GetTechnologyStatus()
		if techStatus:IsUnitAvailable(favoriteUnit) then
			bestAvailableUnit = favoriteUnit
		else
			local favoriteUnitName = tostring(favoriteUnit:GetKey())
			local infantryUnit = CSubUnitDataBase.GetSubUnit("infantry_brigade")
			if favoriteUnitName == "motorized_brigade" or
			   favoriteUnitName == "bergsjaeger_brigade" or
			   favoriteUnitName == "marine_brigade" and
			   techStatus:IsUnitAvailable(infantryUnit) then
				bestAvailableUnit = infantryUnit
			else
				bestAvailableUnit = CSubUnitDataBase.GetSubUnit("militia_brigade")
			end
		end
		COUNTRY_DEBUG(ministerCountry, "Best available unit is ".. tostring(bestAvailableUnit:GetKey()))
		if IsTotalUnitListSet(ministerCountry) then
			-- hold off on caching this until we have better data
			SetCustCache(ai, key, 31, bestAvailableUnit)
		end
	end
	
	return bestAvailableUnit
end

local _CUST_IS_JUNGLE_ = {
	["PHI"] = true, -- Philipines?
	["ECU"] = true, -- Ecuador?
	["VEN"] = true, -- Venezuala
	["BRA"] = true, -- Brazil?
	["BEL"] = true, -- Belgium?
	["NET"] = true, -- Nethearlands?
	["AST"] = true, -- Australia
	["NZL"] = true -- New Zealand
}

function IsJungleAndIsland(ministerCountry)
	local lookupKey = tostring(ministerCountry:GetCountryTag())
	return _CUST_IS_JUNGLE_[lookupKey]
end


local _CUST_IS_MOUNTAINOUS_ = {
	["ETH"] = true, -- Ethiopia
	["GRE"] = true, -- Greece?
	["CYN"] = true, -- Yunnan
	["CHC"] = true, -- Communist China
	["CGX"] = true, -- Guangxi Clique
	["SIK"] = true, -- Siankiang
	["TIB"] = true, -- Tibet
	["AFG"] = true, -- Afghanistan?
	["ECU"] = true, -- Ecuador?
	["PER"] = true, -- Peru?
	["COL"] = true, -- Columbia?
	["CHL"] = true, -- Chile?
	["MEX"] = true, -- Mexico?
	["URU"] = true, -- Uruguay
	["BOL"] = true, -- Bolivia?
	["SAL"] = true, -- El Salvador
	["SCH"] = true, -- Switzerland
	["NEP"] = true, -- Nepal
	["BHU"] = true -- Bhutan
}

function IsMountainous(ministerCountry)
	local lookupKey = tostring(ministerCountry:GetCountryTag())
	return _CUST_IS_MOUNTAINOUS_[lookupKey]
end

function GetContinent(ministerCountry)
	return tostring(ministerCountry:GetActingCapitalLocation():GetContinent():GetTag())
end

local _CUST_UNIT_TECH_LOOKUP_ = {
	["militia_brigade"] = {
		["peoples_army"] = true,
		["large_front"] = true,
		["militia_smallarms"] = true,
		["militia_support"] = true,
		["militia_guns"] = true,
		["militia_at"] = true
	},
	
	["infantry_brigade"] = {
		["infantry_warfare"] = true,
		["mass_assault"] = true,
		["smallarms_technology"] = true,
		["infantry_support"] = true,
		["infantry_guns"] = true,
		["infantry_at"] = true,
		["night_goggles"] = true
	},

	["bergsjaeger_brigade"] = {
		["smallarms_technology"] = true,
		["infantry_support"] = true,
		["infantry_guns"] = true,
		["infantry_at"] = true,
		["night_goggles"] = true,
		["jungle_warfare_equipment"] = true,
		["amphibious_warfare_equipment"] = true,
		["special_forces"] = true,
		["integrated_support_doctrine"] = true
	},
	["marine_brigade"] = {
		["smallarms_technology"] = true,
		["infantry_support"] = true,
		["infantry_guns"] = true,
		["infantry_at"] = true,
		["night_goggles"] = true,
		["mountain_warfare_equipment"] = true,
		["artic_warfare_equipment"] = true,
		["special_forces"] = true,
		["integrated_support_doctrine"] = true
	},
	["motorized_brigade"] = {
		["smallarms_technology"] = true,
		["infantry_support"] = true,
		["infantry_guns"] = true,
		["infantry_at"] = true,
		["tactical_command_structure"] = true,
		["mechanized_offensive"] = true,
		["oil_refinning"] = true
	},
	["engineer_brigade"] = {
		["engineer_assault_equipment"] = true,
		["engineer_bridging_equipment"] = true,
		["integrated_support_doctrine"] = true,
		["special_forces"] = true
	},
	["anti_air_brigade"] = {
		["aa_barrell_ammo"] = true,
		["aa_carriage_sights"] = true,
		["assault_concentration"] = true
	},
	["anti_tank_brigade"] = {
		["at_barrell_sights"] = true,
		["at_ammo_muzzel"] = true,
		["assault_concentration"] = true
	},
	["artillery_brigade"] = {
		["art_carriage_sights"] = true,
		["art_barrell_ammo"] = true,
		["assault_concentration"] = true
	},
	["tank_destroyer_brigade"] = {
		["at_barrell_sights"] = true,
		["at_ammo_muzzel"] = true,
		["blitzkrieg"] = true,
		["schwerpunkt"] = true
	}
}

function IsUnitTech(favoriteUnit, tech)
	local result = nil
	if favoriteUnit then
		local favoriteUnitKey = tostring(favoriteUnit:GetKey())
		local techKey = tostring(tech:GetKey())	
		result = _CUST_UNIT_TECH_LOOKUP_[favoriteUnitKey]
		if result then
			result = result[techKey]
		end
	end
	return result
end

local _CUST_UNIT_TECH_REQUIREMENT_ = {
	["infantry_brigade"] = {
		["infantry_activation"] = 1,
		["militia_smallarms"] = 1,
		["militia_support"] = 1,
		["militia_guns"] = 1,
		["militia_at"] = 1
	},

	["bergsjaeger_brigade"] = {
		["mountain_infantry"] = 1,
		["smallarms_technology"] = 1,
		["infantry_support"] = 1,
		["infantry_guns"] = 1,
		["infantry_at"] = 1,
		["infantry_activation"] = 1,
		["militia_smallarms"] = 1,
		["militia_support"] = 1,
		["militia_guns"] = 1,
		["militia_at"] = 1
	},
	
	["marine_brigade"] = {
		["marine_infantry"] = 1,
		["smallarms_technology"] = 2,
		["infantry_support"] = 2,
		["infantry_guns"] = 2,
		["infantry_at"] = 2,
		["infantry_activation"] = 1,
		["militia_smallarms"] = 1,
		["militia_support"] = 1,
		["militia_guns"] = 1,
		["militia_at"] = 1
	},

	["motorized_brigade"] = {
		["mortorised_infantry"] = 1,
		["cavalry_smallarms"] = 3,
		["cavalry_support"] = 3,
		["cavalry_guns"] = 3,
		["cavalry_at"] = 3,
		["infantry_activation"] = 1,
		["militia_smallarms"] = 1,
		["militia_support"] = 1,
		["militia_guns"] = 1,
		["militia_at"] = 1
	},
	
	["engineer_brigade"] = {
		["engineer_brigade_activation"] = 1,
		["industral_production"] = 1
	},
	
	["tank_destroyer_brigade"] = {
		["lighttank_brigade"] = 1,
		["lighttank_armour"] = 1
	}
}
function IsUnitRequirement(favoriteUnit, tech)
	local result = nil
	if favoriteUnit then
		local favoriteUnitKey = tostring(favoriteUnit:GetKey())
		local techKey = tostring(tech:GetKey())
		result = _CUST_UNIT_TECH_REQUIREMENT_[favoriteUnitKey]		
		if result then
			result = result[techKey]
		end
	end
	return result
end

function GetUnitRequirementTable(favoriteUnit)
	local result = nil
	if favoriteUnit then
		local favoriteUnitKey = tostring(favoriteUnit:GetKey())
		result = _CUST_UNIT_TECH_REQUIREMENT_[favoriteUnitKey]
	end
	return result
end

-- This is a complex function that caches data and statistically analyzes the effects of the officer slider
-- on the officer ratio and returns the rate of change per day of this relationship.
-- The function takes a few game days before all the nil values are filled in and it starts to
-- return meaningful data.
function OfficerRatioRateOfChange(ministerCountry, ai, countryTag, currentOfficerSlider)	
	local officerRatio = ministerCountry:GetOfficerRatio():Get()
	local currentYear = CurrentYear(ai)
	-- [1] is the officer percent value
	-- [2] is the date
	-- [3] is Moving average of Officer change by date
	-- [4] is Moving average of Officer change by date per Officer slider
	-- [5] is Sample count in Moving average
	local officerStats = { officerRatio, currentYear, nil, nil, 0}
	local hasChanged = false
	
	local key = "OfficerRatioRateOfChange-"..tostring(ministerCountry:GetCountryTag())
	local cachedOfficerStats = GetCustCache(ai, key)
	if cachedOfficerStats then
		-- don't compute futher until we have a real value for this
		if cachedOfficerStats[5] and cachedOfficerStats[2] < currentYear then
			local diffDays = (officerStats[2] - cachedOfficerStats[2])* _CUST_DAYS_IN_YEAR_
			local diffRatio = officerStats[1] - cachedOfficerStats[1]
			-- if the difference in the days is too big or too small then the samples are no good
			-- if the change in officerRatio is negative or unchanged then that's no good either since it will imply that the officer slider results in negative changes
			if 0 < diffRatio and currentOfficerSlider > 0 then
				officerChange = diffRatio/diffDays
				
				-- Use the cache's Officer Slider values since that is where the old samples are stored.
				-- we use older samples and not current samples for the following reasons:
				-- 1. We're currently calculating the new Officer percent! So we can't use it in it's own calculation
				-- 2. The old Officer slider's effects can only be observed now.
				local ratioRateOfChange = officerChange/currentOfficerSlider
				
				hasChanged = true
				officerStats[5] = cachedOfficerStats[5] + 1
				if cachedOfficerStats[5] > 0 then
					-- Don't immediately start collecting. Skip a sample to get better data.
					if not officerStats[3] then
						officerStats[3] = officerChange
						officerStats[4] = ratioRateOfChange
					else
						--officerStats[4] = cachedOfficerStats[4] * cachedOfficerStats[5]/officerStats[5]  + ratioRateOfChange/officerStats[5]
						officerStats[3] = cachedOfficerStats[3] * 0.75 + officerChange*0.25
						officerStats[4] = cachedOfficerStats[4] * 0.75 + ratioRateOfChange*0.25
					end
				end
				--PrintOfficerStats(ministerCountry, cachedOfficerStats)
			else
				-- nothing changed, but pass on the previous data
				officerStats[1] = cachedOfficerStats[1]
				officerStats[2] = cachedOfficerStats[2]
				officerStats[3] = cachedOfficerStats[3]
				officerStats[4] = cachedOfficerStats[4]
				officerStats[5] = cachedOfficerStats[5]
			end
		end
	end
	SetCustCache(ai, key, 180, officerStats)
	
	if hasChanged then
		--PrintOfficerStats(ministerCountry, officerStats)
	end
	
	if officerStats[5] < 2 then
		-- if there is insufficient data then set the return value to 0
		return 0,0
	else
		return officerStats[3], officerStats[4]
	end
end

function PrintOfficerStats(ministerCountry, officerStats)
	COUNTRY_DEBUG(ministerCountry, "officerStats[1] = "..officerStats[1])
	COUNTRY_DEBUG(ministerCountry, "officerStats[2] = "..officerStats[2])
	if officerStats[3] then
		COUNTRY_DEBUG(ministerCountry, "officerStats[3] = "..officerStats[3])
	else
		COUNTRY_DEBUG(ministerCountry, "officerStats[3] = nill")
	end
	if officerStats[4] then
		COUNTRY_DEBUG(ministerCountry, "officerStats[4] = "..officerStats[4])
	else
		COUNTRY_DEBUG(ministerCountry, "officerStats[4] = nill")
	end
	if officerStats[5] then
		COUNTRY_DEBUG(ministerCountry, "officerStats[5] = "..officerStats[5])
	else
		COUNTRY_DEBUG(ministerCountry, "officerStats[5] = nill")
	end
end

-- This function has been horribly mangled to work with the fact that there is a different
-- context for each CPU. Don't touch this function unless you KNOW what you're doing.
function ShouldStartPumpingOfficers(minister, defaultLeadership, maxLeadership)
	local ai = minister:GetOwnerAI()
	local ministerCountry = minister:GetCountry()
	local countryTag = minister:GetCountryTag()
	local officerChangePerDayPerSlider = 0
	local officerChangePerDay = 0
	officerChangePerDay, officerChangePerDayPerSlider = OfficerRatioRateOfChange(ministerCountry, ai, countryTag, defaultLeadership)
	local shouldPumpOfficers = -1
	if officerChangePerDayPerSlider ~= 0 then
		local targetDate = DaysTillWar(ministerCountry, ai)
		local officerRatio = ministerCountry:GetOfficerRatio():Get()
		if targetDate == 0 then
			-- we are currently in war so set it to 31 days
			targetDate = 31
		end
		
		local maxOfficerChangePerDay = officerChangePerDayPerSlider*maxLeadership
		local officerGap = (1.79 - officerRatio)
		local currentDaysTillFull = officerGap/officerChangePerDay
		local maxDaysTillFull = officerGap/maxOfficerChangePerDay
		if 0.85*currentDaysTillFull <= targetDate or targetDate <= 1.25*maxDaysTillFull then
			shouldPumpOfficers = 1
		else
			shouldPumpOfficers = 0
		end
		--COUNTRY_DEBUG(ministerCountry, "=========ShouldStartPumpingOfficers===========")
		--COUNTRY_DEBUG(ministerCountry, "maxLeadership = " ..maxLeadership)
		--COUNTRY_DEBUG(ministerCountry, "currentDaysTillFull = " ..currentDaysTillFull)
		--COUNTRY_DEBUG(ministerCountry, "maxDaysTillFull = " ..maxDaysTillFull)
		--COUNTRY_DEBUG(ministerCountry, "targetDate = " ..targetDate)
		--COUNTRY_DEBUG(ministerCountry, "shouldPumpOfficers = "..shouldPumpOfficers)
		--COUNTRY_DEBUG(ministerCountry, "==============================================")
	end
	return shouldPumpOfficers
end

function GetConstructionPractical(minister)
	-- TODO THERE HAS GOT TO BE A BETTER WAY TO FETCH A COUNTRY'S PRACTICAL SCORES
	local constructionEngineer = CTechnologyDataBase.GetTechnology("construction_engineering")
	local ministerCountry = minister:GetCountry()
	local score = 0
	for bonus in constructionEngineer:GetResearchBonus() do
		if bonus._pCategory:GetKey() == "construction_practical" then
			score = ministerCountry:GetAbility(bonus._pCategory)
		end
	end
	
	return score
end

function SuggestTrainingLaw(ministerCountry, ai)
	local minimalTraining = CLawDataBase.GetLaw(_MINIMAL_TRAINING_)
	local trainingLawGroup = minimalTraining:GetGroup()
	local currentTrainingLawIndex = ministerCountry:GetLaw(trainingLawGroup):GetIndex()

	local key = "SuggestTrainingLaw-"..tostring(ministerCountry:GetCountryTag())
	local idealLaw = GetCustCache(ai, key)
	if not idealLaw then
		
		local bestAvailableUnit = BestAvailableUnit(ministerCountry, ai)
		local daysToDepletion = DivisionDaysToMPDepletion(ministerCountry, ai, bestAvailableUnit, 3, nil, 0)
		local daysToCollapse = MinDaysToCollapse(ministerCountry, ai)
		
		local currentAdjustedIndex = currentTrainingLawIndex-minimalTraining:GetIndex()+1
		local adjustment = _CUST_TRAINING_LAW_BOOST_[1] - _CUST_TRAINING_LAW_BOOST_[currentAdjustedIndex]
		local idealLaw = _SPECIALIST_TRAINING_
		
		-- TODO: reorganize the if statements to be more efficient
		if daysToCollapse < (1+adjustment)*daysToDepletion then
			idealLaw = _MINIMAL_TRAINING_
			--COUNTRY_DEBUG(ministerCountry, "Suggesting MINIMAL_TRAINING")
		else
			adjustment = _CUST_TRAINING_LAW_BOOST_[2] - _CUST_TRAINING_LAW_BOOST_[currentAdjustedIndex]
			if daysToCollapse < (1+adjustment)*daysToDepletion then
				idealLaw = _BASIC_TRAINING_
				--COUNTRY_DEBUG(ministerCountry, "Suggesting BASIC_TRAINING")
			else
				adjustment = _CUST_TRAINING_LAW_BOOST_[3] - _CUST_TRAINING_LAW_BOOST_[currentAdjustedIndex]
				if daysToCollapse < (1+adjustment)*daysToDepletion then
					idealLaw = _ADVANCED_TRAINING_
					--COUNTRY_DEBUG(ministerCountry, "Suggesting ADVANCED_TRAINING")
				else
					--COUNTRY_DEBUG(ministerCountry, "Suggesting SPECIALIST_TRAINING")
				end
			end
		end
		SetCustCache(ai, key, 31, idealLaw)
	end
	
	if idealLaw and currentTrainingLawIndex == idealLaw then
		idealLaw = nil
	end
	
	return idealLaw
end

-- Weird Function created to store this data so that other ministers, such as the research minister
-- can access this FUCKING IMPORTANT INFORMATION!
local totalUnitList = {}
function SetTotalUnitList(ministerCountry, productionMinisterAI)
	local productionList = productionMinisterAI:GetProductionSubUnitCounts()
	local currentList = productionMinisterAI:GetDeployedSubUnitCounts()
	local countryTag = ministerCountry:GetCountryTag()
	local countryUnitList = totalUnitList[tostring(countryTag)]
	if not countryUnitList then
		countryUnitList = {}
	end
	for subUnit in CSubUnitDataBase.GetSubUnitList() do
		local unitIndex = subUnit:GetIndex()
		local unitName = tostring(subUnit:GetKey())
		local unitCount = productionList:GetAt(unitIndex)+currentList:GetAt(unitIndex)
		COUNTRY_DEBUG(ministerCountry, unitName.." = "..unitCount)
		countryUnitList[unitIndex] = unitCount
	end
	CSetVariableCommand(countryTag, 
	totalUnitList[tostring(countryTag)] = countryUnitList
end

function IsTotalUnitListSet(ministerCountry)
	local countryTag = ministerCountry:GetCountryTag()
	local countryUnitList = totalUnitList[tostring(countryTag)]
	-- 46 being the total number of units available
	return countryUnitList and table.getn(countryUnitList) > 46
end

-- For this function to work, SetTotalUnitList above must be called in the production minister first
-- NOTE: when CCountry:GetUnits:GetCount(subUnit)) starts working then ditch this function
function GetTotalUnitCount(ministerCountry, subUnit)
	local countryTag = ministerCountry:GetCountryTag()
	local countryUnitList = totalUnitList[tostring(countryTag)]
	local count = 0
	if countryUnitList then
		count = countryUnitList[subUnit:GetIndex()]
		if not count then
			count = 0
		end
	end
	return count
end

function HasManPowerShortage(ministerCountry, ai)
	local bestAvailableUnit = BestAvailableUnit(ministerCountry, ai)
	return DivisionDaysToMPDepletion(ministerCountry, ai, bestAvailableUnit, 3, nil, 0) < MinDaysToCollapse(ministerCountry, ai)
end

function PrepareForWar(ministerCountry, ai)
	return DaysTillWar(ministerCountry, ai) <= _CUST_DAYS_TILL_WAR_LIMBO_PHASE_
end

function IsMajorPower(ministerCountry)
	return ministerCountry:GetMaxIC() >= 60 and ministerCountry:IsMajor()
end

local _CUST_CACHE_ARRAY_ = {}
function SetCustCache(ai, key, daysToCache, cacheObject)
	_CUST_CACHE_ARRAY_[key] = {CurrentYear(ai), daysToCache, cacheObject}
end

function GetCustCache(ai, key)
	local cacheObject = nil
	local cacheArray = _CUST_CACHE_ARRAY_[key]
	if cacheArray then
		local dateCached = cacheArray[1]
		local dayDiff = (CurrentYear(ai)-dateCached) * _CUST_DAYS_IN_YEAR_
		local daysToCache = cacheArray[2]
		if 0 <= dayDiff and dayDiff <= daysToCache then
			cacheObject = cacheArray[3]
		end
	end
	return cacheObject
end

function IsStartOfGame(ai)
	local daysSinceGameStartKey = "daysSinceGameStartKey"
	local daysSinceGameStart = GetCustCache(ai, daysSinceGameStartKey)
	local isStartOfGame = false
	local daysTillStartOfGameIsOver = 14
	if not daysSinceGameStart then
		SetCustCache(ai, daysSinceGameStartKey, 99999, 1)
		isStartOfGame = true
	elseif daysSinceGameStart < daysTillStartOfGameIsOver then
		SetCustCache(ai, daysSinceGameStartKey, 99999, daysSinceGameStart+1)
		isStartOfGame = true
	end
	return isStartOfGame
end

function PrintUnits(ministerCountry)
	for aUnit in ministerCountry:GetUnitsIterator() do
		COUNTRY_DEBUG(ministerCountry, tostring(aUnit:GetName()))
		local unitMetaTable = getmetatable(aUnit)
		for k,v in pairs(unitMetaTable) do
			COUNTRY_DEBUG(ministerCountry, "    "..k)
		end
	end
end

function Round(num) 
	if num >= 0 then return math.floor(num+.5) 
	else return math.ceil(num-.5) end
end