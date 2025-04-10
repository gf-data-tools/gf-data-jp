local util = require 'xlua.util'
xlua.private_accessible(CS.CommonAudioController)
xlua.private_accessible(CS.CommonController)
xlua.private_accessible(CS.ResManager)
xlua.private_accessible(CS.BattleManualSkillController)
xlua.private_accessible(CS.GF.Battle.BattleDynamicData)
xlua.private_accessible(CS.GF.Battle.BattleCharacterControllerNew)
xlua.private_accessible(CS.GF.Battle.BattleMemberControllerNew)
xlua.private_accessible(CS.GF.Battle.BattleFieldTeamHolderNew)
xlua.private_accessible(CS.GF.Battle.BattleController)
xlua.private_accessible(CS.BattleFieldTeamHolder)
xlua.private_accessible(CS.GF.Battle.BattleFrameTimer)
xlua.private_accessible(CS.GF.Battle.BattleStatistics)
local character = nil
local characterData = nil
local CheckBuffID = 4271
local TargetBuffID = 4272
local DeathBuffID = 4275
local WinBuffID = 4279
local FallBuffID = 4282
local EnemyIDNormal = 910130
local EnemyIDHard = 910129
local EnemyIDLunatic = 910131
local PerfectNormal = 60
local PerfectHard = 70
local PerfectLunatic = 80
local currentDifficulty = 1
local mCurSkill ={}
local BattleController

local HorizontalParaA = 0.2
local HorizontalParaB = 0.37

local VerticalParaA = 0.2
local VerticalParaB = 0.31

local maxY  = 4
local minY  = -12

local delayTimeLeap = 0.23
local JumpTimeLeap = 0.966

local delayTimeSmall = 0.13
local JumpTimeSmall = 0.6

local LeapCheckTier = 12
local characterY = 2.5

local isCountingTime = false
local OnGround = true
local NeuralBarTimeCounter = 0
local NeuralBarTimeCounter2 = 0
local NeuralBarWaitTime = 0
local NeuralBarWaitAnim = false
local countdownTimer = 0
local skillcooldown = 1

local isWaitForEndAnim = false
local WaitForEndAnimTimer = 0
local EndAnimWaitTime = 5

local TextCountdown
local MaxTier
local NeuralBarSlider
local CurFramePressDown = false
local FP = CS.TrueSync.FP
SkillActive = function(active,showCD)
	
end
InitSkill1 = function(SkillLabel,mCurSkill,pos)
	local skillLabelController
	skillLabelController = SkillLabel:GetComponent(typeof(CS.BattleManualSkillController))
	--注册技能和人物
	--skillLabelController.mCurChar = characterS
	--skillLabelController.mCurSkill = mCurSkill
	local fpos = -1
	
	if pos == 2 or pos == 3 then
		fpos = 0
	end
	if pos == 4 then
		fpos = 1
	end
	skillLabelController:InitUI(characterData,fpos,pos,0,mCurSkill,nil)
	skillLabelController.openSkillTip = false
end


local LuaPointerUpFlag = false
local LuaPointerDownFlag = false
local LuaPointerDownSkillId = 0
--Awake：初始化数据
Awake = function()
	
	
	
end

--Start: 加载组件
Start = function()
	--print("Start")
	local BattleDynamicData = CS.GF.Battle.BattleDynamicData
	BattleDynamicData.infiScoutDistance = true

	TextCountdown = TextTime:GetComponent(typeof(CS.ExText)) 
	NeuralBarSlider = Slider:GetComponent('Slider')
	NeuralBarSlider.value = 0
	MaxTier = CS.GameData.listBTBuffCfg:GetDataById(TargetBuffID).max_tier
	--禁止人物拖动并锁定镜头
	CS.BattleInteractionController.isGuideInteractable = false
	CS.BattleInteractionController.isGuideCanNotScale = false
	CS.BattleInteractionController.isGuideCanNotOffset = false
	CS.GF.Battle.BattleController.Instance.syncFriendlyPos = false
	CS.GF.Battle.SkillUtils.AutoSkill = false	
	CS.GF.Battle.BattleController.Instance.resetAutoSkill = true
	CS.GF.Battle.BattleController.Instance.resetCameraLock = true
	
	--注册相机
	
	--self:GetComponent('Canvas').worldCamera = CS.UnityEngine.Camera.main
	--注册人物
	if character == nil then
		character = CS.BattleLuaUtility.GetCharacterControllerNewByCode('Ange_Jump')
		characterData = CS.BattleLuaUtility.GetDataByCode('Ange_Jump')
	end
	--注册人物技能
	mCurSkill[0] = characterData:GetSkillByID(406901,true)
	mCurSkill[1] = characterData:GetSkillByID(406916,true)
	mCurSkill[2] = characterData:GetSkillByID(406917,true)
	mCurSkill[3] = characterData:GetSkillByID(406915,true)
	-- 人物扶正
	character.reverseSync = true
	character:ResetCharacterAngle(character.transform.localPosition)
	
	local charPos = character.transform
	charPos.localPosition = CS.UnityEngine.Vector3(charPos.localPosition.x, characterY, charPos.localPosition.z)
	character.listMembers[0].transform.localPosition = CS.UnityEngine.Vector3.zero
	CS.BattleUIManualSkillController.Instance.gameObject:SetActive(false)
	
	InitSkill1(SkillLabel1,mCurSkill[0],3)
	InitSkill1(SkillLabel2,mCurSkill[1],1)
	InitSkill1(SkillLabel3,mCurSkill[2],2)
	InitSkill1(SkillLabel4,mCurSkill[3],4)
	local OnPointerUp = function(self,eventData)
		--print("CurFramePressDown"..tostring(CurFramePressDown))
		if CurFramePressDown == true then
			CurFramePressDown = false
			OnCancelActiveSkill(self,eventData)
			return
		end
		OnPointerUpActiveSkill(self,eventData)
	end
	local OnPointerDown = function(self,eventData)
		OnPressDownActiveSkill(self,eventData)
	end
	local _UpdateUIByStatus = function(self)
		local _mStatus = self.mStatus
		if LuaPointerDownFlag and self.mCurSkill.id == LuaPointerDownSkillId then 
			self.mStatus = CS.BattleManualSkillController.enumSkillStatus.eWatting
			self:_UpdateUIByStatus()
			self.mStatus =_mStatus
		else
			self:_UpdateUIByStatus()
		end
		
	end
	util.hotfix_ex(CS.BattleManualSkillController,'OnPointerUp',OnPointerUp)
	util.hotfix_ex(CS.BattleManualSkillController,'OnPointerDown',OnPointerDown)
	--util.hotfix_ex(CS.BattleManualSkillController,'_UpdateUIByStatus',_UpdateUIByStatus)
	
	BattleController = CS.GF.Battle.BattleController.Instance
	isCountingTime = true
	local listEnemy = BattleController.enemyTeamHolder.listCharacter
	for i=0,listEnemy.Count-1 do
		if listEnemy[i] ~= nil then
			--print(listEnemy[i].gunInfoId)
			if listEnemy[i].gunInfoId == EnemyIDNormal then
				currentDifficulty = 1
				break
			end
			if listEnemy[i].gunInfoId == EnemyIDHard then
				currentDifficulty = 2
				break
			end
			if listEnemy[i].gunInfoId == EnemyIDLunatic then
				currentDifficulty = 3
				break
			end
		end
	end
	self.transform:SetParent(CS.BattleUIController.Instance.transform:Find('UI'),false)
	--print("currentDifficulty"..currentDifficulty)
end

local friendlyArea
local friendlyAreaInitalPos
function JumpForward()
	if friendlyArea == nil then
		friendlyArea = BattleController.friendlyArea
		friendlyAreaInitalPos = friendlyArea.localPosition.x
	end
	local chargeBuffTier = characterData.conditionListSelf:GetTierByID(TargetBuffID)
	local JumpTime,delayTime
	if chargeBuffTier >= LeapCheckTier then
		JumpTime = JumpTimeLeap
		delayTime = delayTimeLeap
	else
		JumpTime = JumpTimeSmall
		delayTime = delayTimeSmall
	end
	local startpos = friendlyArea.localPosition.x
	local movedistance = HorizontalParaA + HorizontalParaB * chargeBuffTier
	local finalPos = startpos + movedistance
	friendlyArea:DOLocalMoveX(finalPos,JumpTime):SetDelay(delayTime):Play()
	character.gameObject.transform:DOLocalMoveX(character.gameObject.transform.localPosition.x+ movedistance,JumpTime):SetDelay(delayTime):Play()
	NeuralBarWaitTime = JumpTime + delayTime +0.1
	OnGround = false
	--character.gameObject.transform:DOLocalMoveX(finalPos,JumpTime):SetDelay(delayTime):Play()	
	--print("Foward"..chargeBuffTier..' '..JumpTime..' '..movedistance..' '..NeuralBarWaitTime)
end
function JumpUp()
	local JumpTime,delayTime
	local chargeBuffTier = characterData.conditionListSelf:GetTierByID(TargetBuffID)
	if chargeBuffTier >= LeapCheckTier then
		JumpTime = JumpTimeLeap
		delayTime = delayTimeLeap
	else
		JumpTime = JumpTimeSmall
		delayTime = delayTimeSmall
	end
	local startpos = character.gameObject.transform.localPosition.z
	local movedistance = VerticalParaA + VerticalParaB * chargeBuffTier
	local finalPos = startpos + movedistance
	if finalPos > maxY then finalPos = maxY end
	character.gameObject.transform:DOLocalMoveZ(finalPos,JumpTime):SetDelay(delayTime):Play()
	NeuralBarWaitTime = JumpTime + delayTime +0.1
	OnGround = false
	--GameFinish()
	--print("Up"..chargeBuffTier..' '..JumpTime..' '..movedistance..' '..NeuralBarWaitTime)
end
function JumpDown()
	
	local JumpTime,delayTime
	local chargeBuffTier = characterData.conditionListSelf:GetTierByID(TargetBuffID)
	if chargeBuffTier >= LeapCheckTier then
		JumpTime = JumpTimeLeap
		delayTime = delayTimeLeap
	else
		JumpTime = JumpTimeSmall
		delayTime = delayTimeSmall
	end
	local chargeBuffTier = characterData.conditionListSelf:GetTierByID(TargetBuffID)
	local startpos = character.gameObject.transform.localPosition.z
	local movedistance = VerticalParaA + VerticalParaB * chargeBuffTier
	local finalPos = startpos - movedistance
	if finalPos < minY then finalPos = minY end		
	character.gameObject.transform:DOLocalMoveZ(finalPos,JumpTime):SetDelay(delayTime):Play()
	NeuralBarWaitTime = JumpTime + delayTime +0.1
	OnGround = false
	--GameFinish()
	--print("Down"..chargeBuffTier..' '..JumpTime..' '..movedistance..' '..NeuralBarWaitTime)
end
function GameFinish()
	--print("GameSet!")
	isCountingTime = false
	isWaitForEndAnim = true
	CS.GF.Battle.BattleFrameTimer.Instance:StopTime(99999)
	--showPanel
	ShowResult()
end
function EndGame()
	if WaitForEndAnimTimer >= EndAnimWaitTime then
		CS.GF.Battle.BattleFrameTimer.Instance:ResumeStopTime()
		for i=0,BattleController.enemyTeamHolder.listCharacter.Count-1 do
			local DamageInfo = CS.GF.Battle.BattleDamageInfo()
			BattleController.enemyTeamHolder.listCharacter[i]:UpdateLife(DamageInfo, -999999)
		end
		CS.UnityEngine.Object.Destroy(self.gameObject)
	end
end
function OnCancelActiveSkill(self,eventData)
	--print("OnCancelActiveSkill")
	PlaySFX("chargestop")
	LuaPointerDownFlag = false
	CS.GF.Battle.SkillUtils.RemoveManaulSkill(SkillLabel1:GetComponent(typeof(CS.BattleManualSkillController)).mCurChar.gun, mCurSkill)
	self:_UpdateUIByStatus()
end
function OnPressDownActiveSkill(self,eventData)
	--if not OnGround then 
	--	return 
	--end
	
	CurFramePressDown = true
	if LuaPointerUpFlag then 
		--print("OnPointerDownTriggerSkill")
		skillcooldown = 1
		self:OnPointerDown(eventData)
	else
		if LuaPointerDownFlag == false then
			if CheckDeath() or (not OnGround) or skillcooldown > 0 then 
				--print("OnPointerDownFailCharge" .. tostring(CheckDeath()).." "..tostring(CheckDeath(not OnGround)).." "..tostring(CheckDeath(skillcooldown > 0)))
				return 
			end
			--print("OnPointerDownCharge")
			PlaySFX("charge")
			LuaPointerDownFlag = true
			LuaPointerDownSkillId = self.mCurSkill.skillid
			
			SkillLabel1:GetComponent(typeof(CS.BattleManualSkillController)):ManualActiveSkill()
		end
	end
	self:_UpdateUIByStatus()
	--print("OnPointerDownEnd"..LuaPointerDownSkillId..tostring(LuaPointerDownFlag))
end
function OnPointerUpActiveSkill(self,eventData)
	--如果这和OnPointerDown是同一帧 就什么也不做
	--print("OnPointerUp"..self.mCurSkill.id)
	
	PlaySFX("chargestop")
	if LuaPointerDownFlag == false or CheckDeath() then
		--print("OnPointerUpFailReleaseSkill"..' '..tostring(LuaPointerDownFlag)..' '..tostring(CheckDeath()))
		return 
	end
	--print("OnPointerUpTriggerSkill")
	if self.mCurSkill.id == 40691501 then
		JumpForward()
	end
	if self.mCurSkill.id == 40691601 then
		JumpUp()
	end
	if self.mCurSkill.id == 40691701 then
		JumpDown()
	end
	LuaPointerDownFlag = false
	LuaPointerUpFlag = true
	self:OnPointerDown(eventData)
	--OnPressDownActiveSkill(self,eventData)
	LuaPointerUpFlag = false
end
--local deathFlag = false
local deathFunctionFlag = false
local winFunctionFlag = false
function CheckDeath()
	local DeathBuffTier = characterData.conditionListSelf:GetTierByID(DeathBuffID)
	return (DeathBuffTier < 1)
end
function CheckWin()
	local DeathBuffTier = characterData.conditionListSelf:GetTierByID(WinBuffID)
	return (DeathBuffTier > 0)
end
function CheckFall()
	local DeathBuffTier = characterData.conditionListSelf:GetTierByID(FallBuffID)
	return (DeathBuffTier > 0)
end
function ShowResult()
	--print("ShowResult")
	self.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform)).anchoredPosition = CS.UnityEngine.Vector2(0,0)
	ResultGO:SetActive(true)
	BtnClose:GetComponent(typeof(CS.ExButton)).onClick:AddListener(function()
			EndGame()			
		end)
	if CS.GameData.userInfo ~= nil then
		TextResultName:GetComponent(typeof(CS.ExText)).text = CS.GameData.userInfo.name
		TextResultID:GetComponent(typeof(CS.ExText)).text ="UID:"..CS.GameData.userInfo.userId
	end
	TextResultTime:GetComponent(typeof(CS.ExText)).text = string.format("%.2f",(countdownTimer)).."S"
	TextResultDate:GetComponent(typeof(CS.ExText)).text = GetDate()
	if currentDifficulty == 1 then
		TextResultDiff:GetComponent(typeof(CS.ExText)).text = CS.Data.GetLang(60103)
		if countdownTimer > PerfectNormal then
			PerfectGO.gameObject:SetActive(false)
		end
	end
	if currentDifficulty == 2 then
		TextResultDiff:GetComponent(typeof(CS.ExText)).text = CS.Data.GetLang(60104)
		if countdownTimer > PerfectHard then
			PerfectGO.gameObject:SetActive(false)
		end
	end
	if currentDifficulty == 3 then
		TextResultDiff:GetComponent(typeof(CS.ExText)).text = CS.Data.GetLang(60105)
		if countdownTimer > PerfectLunatic then
			PerfectGO.gameObject:SetActive(false)
		end
	end
	if PerfectGO.gameObject.activeSelf then
		PlaySFX("perfectClear")
	else
		PlaySFX("normalClear")
	end
	CS.GF.Battle.BattleController.Instance.statistics:SetData(CS.GF.Battle.BattleStatistics.true_time, math.floor(countdownTimer * 30))
end
function GetDate()
	local dtNow = CS.Data.ConvertDataTime(CS.GameData.GetCurrentTimeStamp())
	return dtNow:ToString("yyyy/MM/dd").." "..dtNow:ToString("HH:mm")
end
local Mathf = CS.UnityEngine.Mathf
local checkflag = false

Update = function()
	if friendlyArea ~= nil then
		local offset = friendlyArea.localPosition.x - friendlyAreaInitalPos
		local offsetFP = FP.FromFloat(offset)
		CS.GF.Battle.BattleDynamicData.friendlyArmyOffset = offsetFP
		--print(offset)
		--print(CS.GF.Battle.BattleDynamicData.friendlyArmyOffset)
	end
	if CheckWin() and not winFunctionFlag then
		winFunctionFlag = true
		GameFinish()
	end
	if isCountingTime then
		countdownTimer = CS.GF.Battle.BattleFrameManager.Instance:GetCurBattleTime()
		TextCountdown.text = string.format("%.2f",(countdownTimer))
	end
	if OnGround then
		local chargeBuffTier = characterData.conditionListSelf:GetTierByID(TargetBuffID)
		NeuralBarSlider.value = (chargeBuffTier / MaxTier)
		if checkflag and not CheckDeath() then
			--character:SetMemberAnimation("wait", 1)
		end
	end
	if not OnGround then
		NeuralBarTimeCounter = NeuralBarTimeCounter + CS.UnityEngine.Time.deltaTime
		if not checkflag then
			checkflag = true
		end
		if NeuralBarTimeCounter + 0.1 >= NeuralBarWaitTime  then
			NeuralBarTimeCounter2 = NeuralBarTimeCounter2 + CS.UnityEngine.Time.deltaTime
			NeuralBarSlider.value = Mathf.Lerp(NeuralBarSlider.value,0,NeuralBarTimeCounter2 * 10)
		end
		if NeuralBarTimeCounter >= NeuralBarWaitTime then
			OnGround = true
			NeuralBarTimeCounter = 0
			NeuralBarTimeCounter2 = 0
		end
	end
	if OnGround and CheckDeath() then
		if deathFunctionFlag == false then
			character.listMembers[0].mesh.sortingOrder = 0
			deathFunctionFlag = true
		end
	end
	if CurFramePressDown == true and CS.UnityEngine.Time.deltaTime > 0 then
		CurFramePressDown = false
		--	OnPressDownActiveSkill(CurFramePressDownSelf,CurFramePressDownData)
	end
	if isWaitForEndAnim then
		WaitForEndAnimTimer = WaitForEndAnimTimer + CS.UnityEngine.Time.deltaTime
	end
	if CheckFall() then
		character.gameObject.transform.localScale = CS.UnityEngine.Vector3(0,0,0)
	end
	if skillcooldown > 0 then
		skillcooldown = skillcooldown - CS.UnityEngine.Time.deltaTime
	end
end
function PlaySFX(FXname)
	if FXname == "perfectClear" then
		CS.CommonAudioController.PlayUI("UI_clear_perfect")
	end
	if FXname == "normalClear" then
		CS.CommonAudioController.PlayUI("UI_clear_normal")
	end
	if FXname == "charge" then
		CS.CommonAudioController.PlayUI("UI_charge_loop")
	end
	if FXname == "chargestop" then
		CS.CommonAudioController.PlayUI("Stop_UI_loop")
		
	end
end
--depose
OnDestroy =function()
	--xlua.hotfix(CS.GF.Battle.BattleManager,'RefreshFriendlyTargetList',nil)
	CS.GF.Battle.BattleDynamicData.infiScoutDistance = false
	xlua.hotfix(CS.BattleManualSkillController,'OnPointerUp',nil)
	xlua.hotfix(CS.BattleManualSkillController,'OnPointerDown',nil)
	xlua.hotfix(CS.BattleManualSkillController,'_UpdateUIByStatus',nil)
	character = nil
	mCurSkill ={}
end

