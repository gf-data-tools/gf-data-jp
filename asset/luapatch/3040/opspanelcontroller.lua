local util = require 'xlua.util'
xlua.private_accessible(CS.OPSPanelController)

local InitShowContainer = function(self)
	self:InitShowContainer();
	if CS.OPSPanelBackGround.currentContainerId == 0 then
		if CS.OPSPanelBackGround.Instance.opsMissionContainers.Count == 0 then
			if self.firstCamerapanelmission == nil and self:CanPlayAllSpots() then
				if CS.OPSPanelController.loginTime:ContainsKey(self.campaionId) and CS.OPSPanelController.loginTime[self.campaionId] == CS.GameData.loginServerTime then
					if not CS.OPSPanelBackGround.Instance:ReadRecord() then
						self:CheckSpineSpot();
						self:ReturnContainerPos();
					end
				end
			end
		end
	end
end


util.hotfix_ex(CS.OPSPanelController,'InitShowContainer',InitShowContainer)

