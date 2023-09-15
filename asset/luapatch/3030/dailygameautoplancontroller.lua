local util = require 'xlua.util'
xlua.private_accessible(CS.DailyGameAutoPlanController)

local CheckAutoPlanInDailyGame = function()
	CS.DailyGameAutoPlanController.CheckAutoPlanInDailyGame();
	CS.RewardBoxController.boxes:Clear();
end

local MissionState = function(finishHexCount)
	local count = finishHexCount -1;
	return CS.DailyGameAutoPlanController.MissionState(count);
end
util.hotfix_ex(CS.DailyGameAutoPlanController,'CheckAutoPlanInDailyGame',CheckAutoPlanInDailyGame)
util.hotfix_ex(CS.DailyGameAutoPlanController,'MissionState',MissionState)
