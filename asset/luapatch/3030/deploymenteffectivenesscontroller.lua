local util = require 'xlua.util'
xlua.private_accessible(CS.DeploymentEffectivenessController)

local VehicleCondition2_Crew2Base = function(self)
	if self.vehicle.vehicleCrewsArr.Length <= 1 then
		self.conditionVehicle2:Find("TypeScroll/TypeList/TypeCard2").gameObject:SetActive(false);
		return true;
	end
	return self:VehicleCondition2_Crew2Base();
end
local VehicleCondition2_Crew3Base = function(self)
	if self.vehicle.vehicleCrewsArr.Length <= 2 then
		self.conditionVehicle2:Find("TypeScroll/TypeList/TypeCard3").gameObject:SetActive(false);
		return true;
	end
	return self:VehicleCondition2_Crew3Base();
end
local VehicleCondition2_Crew4Base = function(self)
	if self.vehicle.vehicleCrewsArr.Length <= 3 then
		self.conditionVehicle2:Find("TypeScroll/TypeList/TypeCard4").gameObject:SetActive(false);
		return true;
	end
	return self:VehicleCondition2_Crew4Base();
end
local VehicleCondition3_Crew2 = function(self)
	if self.vehicle.vehicleCrewsArr.Length <= 1 then
		self.conditionVehicle3:Find("TypeScroll/TypeList/TypeCard2").gameObject:SetActive(false);
		return true;
	end
	local txt = self.conditionVehicle3:Find("TypeScroll/TypeList/TypeCard2/Img_Finish/Tex_TypeContent");
	txt:GetComponent(typeof(CS.ExText)).text = CS.Data.GetLang(100318);
	return self:VehicleCondition3_Crew2();
end
local VehicleCondition3_Crew3 = function(self)
	if self.vehicle.vehicleCrewsArr.Length <= 2 then
		self.conditionVehicle3:Find("TypeScroll/TypeList/TypeCard3").gameObject:SetActive(false);
		return true;
	end
	return self:VehicleCondition3_Crew3();
end
local VehicleCondition3_Crew4 = function(self)
	if self.vehicle.vehicleCrewsArr.Length <= 3 then
		self.conditionVehicle3:Find("TypeScroll/TypeList/TypeCard4").gameObject:SetActive(false);
		return true;
	end
	return self:VehicleCondition3_Crew4();
end
util.hotfix_ex(CS.DeploymentEffectivenessController,'VehicleCondition2_Crew2Base',VehicleCondition2_Crew2Base)
util.hotfix_ex(CS.DeploymentEffectivenessController,'VehicleCondition2_Crew3Base',VehicleCondition2_Crew3Base)
util.hotfix_ex(CS.DeploymentEffectivenessController,'VehicleCondition2_Crew4Base',VehicleCondition2_Crew4Base)
util.hotfix_ex(CS.DeploymentEffectivenessController,'VehicleCondition3_Crew2',VehicleCondition3_Crew2)
util.hotfix_ex(CS.DeploymentEffectivenessController,'VehicleCondition3_Crew3',VehicleCondition3_Crew3)
util.hotfix_ex(CS.DeploymentEffectivenessController,'VehicleCondition3_Crew4',VehicleCondition3_Crew4)