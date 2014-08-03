-----------------------------------------------------------------------------------------------
-- Client Lua Script for GroupDialog
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 

require "Window"
require "Unit"
require "GroupLib"
require "GameLib"
require "Tooltip"
require "PlayerPathLib"
require "ChatSystemLib"
require "MatchingGame"

 
-----------------------------------------------------------------------------------------------
-- GroupDialog Module Definition
-----------------------------------------------------------------------------------------------
local GroupDialog = {} 
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function GroupDialog:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function GroupDialog:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureButton, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- GroupDialog OnLoad
-----------------------------------------------------------------------------------------------
function GroupDialog:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("GroupDialog.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)

    -- Invite events
	Apollo.RegisterEventHandler("Group_Invited","OnInvited", self)
--	Apollo.RegisterEventHandler("Group_Invite_Result", "OnInviteResult", self)
	Apollo.RegisterEventHandler("Group_AcceptInvite", "OnAcceptInvite", self)
	Apollo.RegisterEventHandler("Group_DeclineInvite", "OnDeclineInvite", self)

	-- Join events
	Apollo.RegisterEventHandler("Group_JoinRequest","OnJoinRequest", self)
	Apollo.RegisterEventHandler("Group_Request_Result", "OnJoinRequestResult", self)
	
	-- Don't know what this does.
--	Apollo.RegisterEventHandler("Group_Referral","OnReferral", self)
end

-----------------------------------------------------------------------------------------------
-- GroupDialog OnDocLoaded
-----------------------------------------------------------------------------------------------
function GroupDialog:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndInviteDialog = Apollo.LoadForm(self.xmlDoc, "InviteDialogForm", nil, self)
		self.wndJoinRequestDialog = Apollo.LoadForm(self.xmlDoc, "JoinRequestDialogForm", nil, self)
		self.xmlDoc = nil

		if self.wndInviteDialog == nil or self.wndJoinRequestDialog == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndInviteDialog:Show(false, true)
		self.wndJoinRequestDialog:Show(false, true)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- GroupDialog Functions
-----------------------------------------------------------------------------------------------
-- Catch the group invite event
function GroupDialog:OnInvited(strInviterName)
	self.wndInviteDialog:Show(true, true)
	self.wndInviteDialog:FindChild("Title"):SetText("Invite from "..strInviterName)
	self.wndInviteDialog:ToFront()
	--print("Invite accepted by"..strInviterName)
end

-- Catch the join request event
function GroupDialog:OnJoinRequest(strRequesterName)
	self.wndJoinRequestDialog:Show(true, true)
	self.wndJoinRequestDialog:FindChild("Title"):SetText("Join request from "..strRequesterName)
	self.wndJoinRequestDialog:ToFront()
end

function GroupDialog:OnReferral(strRequesterName)
	Print("Event \"OnReferral\" detected!!!!")
end
-----------------------------------------------------------------------------------------------
-- GroupDialogForm Functions
-----------------------------------------------------------------------------------------------
--- Invites
-- Accept invite.

-- Click accept.
function GroupDialog:OnInviteDialogAccept()
	self.wndInviteDialog:Show(false) -- hide window
	GroupLib.AcceptInvite()
end

-- Handle /accept (need to close window)
function GroupDialog:OnGAcceptInvite()
	self.wndInviteDialog:Show(false)
end
	
-- Decline invite.
function GroupDialog:OnInviteDialogDecline()
	self.wndInviteDialog:Show(false) -- hide window
	GroupLib.DeclineInvite()
end

-- Handle /decline (i.e. close window)
function GroupDialog:OnDeclineInvite()
	self.wndInviteDialog:Show(flase) -- hide window
end

--[[--
-- Okay, check result.
function GroupDialog:OnInviteResult(result)
	self.wndInviteDialog:Show(false)
	Print("foooooo")
	Print(result)
end
--]]--

--- Join Requests
-- Accept join request.
function GroupDialog:OnAcceptJoinRequest()
	self.wndJoinRequestDialog:Show(false) -- hide window
	GroupLib.AcceptRequest()
end

-- Decline join request.
function GroupDialog:OnDeclineJoinRequest()
	self.wndJoinRequestDialog:Show(false) -- hide window
	GroupLib.DenyRequest()
end

-- Check what happened with that join request.
-- TODO: implement
--[[--
function GroupDialog:OnJoinRequestResult()
end	
--]]--

-----------------------------------------------------------------------------------------------
-- GroupDialog Instance
-----------------------------------------------------------------------------------------------
local GroupDialogInst = GroupDialog:new()
GroupDialogInst:Init()
