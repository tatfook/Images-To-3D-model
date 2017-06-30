--[[
Title: 
Author(s): zhang
Date: 2017/6/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/ImagesTo3Dmodel/main.lua");
local ImagesTo3Dmodel = commonlib.gettable("Mod.ImagesTo3Dmodel");
ImagesTo3Dmodel:Test("Images");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/ImagesTo3Dmodel/TestAbc.lua");
local TestAbc = commonlib.gettable("Mod.ImagesTo3Dmodel.TestAbc");

local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");	

local ImagesTo3Dmodel = commonlib.inherit(commonlib.gettable("Mod.ModBase"),commonlib.gettable("Mod.ImagesTo3Dmodel"));

function ImagesTo3Dmodel:ctor()
end

-- virtual function get mod name
function ImagesTo3Dmodel:GetName()
	return "ImagesTo3Dmodel"
end

-- virtual function get mod description 
function ImagesTo3Dmodel:GetDesc()
	return "ImagesTo3Dmodel is a plugin in paracraft"
end

function ImagesTo3Dmodel:init()
	LOG.std(nil, "info", "ImagesTo3Dmodel", "plugin initialized");
	local p=10;
	TestAbc.Test(p);
end

function ImagesTo3Dmodel:OnLogin()
end
-- called when a new world is loaded. 

function ImagesTo3Dmodel:OnWorldLoad()
end
-- called when a world is unloaded. 

function ImagesTo3Dmodel:OnLeaveWorld()
end

function ImagesTo3Dmodel:OnDestroy()
end

function ImagesTo3Dmodel:Test(p)
    commonlib.echo("ImagesTo3Dmodel:Test");
    commonlib.echo(p);
    return {p};
end

