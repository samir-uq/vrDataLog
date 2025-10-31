-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
-- Modules
local Signal = require(ReplicatedStorage.Packages.Signal)
local DataLoader = require(script.Parent.DataLoader)
local GameTypes = require(ReplicatedStorage.Shared.Configs.GameTypes)

--> THIS MODULE DOES NOT USE PLAYER ENTITY BECAUSE IT DEALS WITH API USAGE
--> ADD PLAYER ENTITY TO THIS????
-- Variables
local GamepassPurchased = Signal.new()
local ProcessRecieptProcessed = Signal.new()
-- Types

type Object = {
	AssetId: number,
	InfoType: Enum.InfoType,

	OnPurchase: (Object, (Player)->nil)->nil,
	GiveTo: (Object, (Player)->nil)->nil,

	InvokePurchase: (Object, Player)->nil,
}

type GamepassObject = {
	OnJoin: (GamepassObject, (Player)->nil)->nil,
	PlayerOwns: (GamepassObject, Player)->boolean,
	GiveTo: (GamepassObject, Player)->nil,

	OnJoinCallback: ((Player)->())?,
	OnJoinInvoke: ((Player)->())
}&Object

type ProductObject = {}&Object
-- Core

local function PlayerOwns(Id, InfoType)
	return function(self, Player: Player)
		if InfoType~=Enum.InfoType.GamePass then return true end

		local Gamepasses = DataLoader.Store:getAsync(Player).Gamepasses
		if table.find(Gamepasses, Id) then
			return true
		end

		local PlayerOwnsGamepass = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Id)
		if PlayerOwnsGamepass then
			self:GiveTo(Player)
			return true
		end

		return false
	end
end

local function GiveTo(Id, InfoType)

	return function(self, Player: Player)
		self:InvokePurchase(Player)
		return true
	end
end

local function OnPurchase(Id: number, InfoType: Enum.InfoType)
	return function(self, Callback: (Player)->nil)
		self.PurchaseCallback = Callback
	end
end

local function OnJoin(Id: number, InfoType: Enum.InfoType)
	return function(self, Callback: (Player)->nil)
		self.OnJoinCallback = Callback
	end
end

-- Constructors

local function Object(Id: number, InfoType: Enum.InfoType)
	local Object =  {
		AssetId = Id,
		InfoType = InfoType,

		OnPurchase = OnPurchase(Id, InfoType),
		GiveTo = GiveTo(Id, InfoType),
	}

	Object.InvokePurchase = function(self, Player)
		if not Object["PurchaseCallback"] then
			warn("No purchase to invoke")
			return
		end

        DataLoader.Store:updateAsync(Player, function(Data)
            if table.find(Data.Gamepasses, Id) then
                return false
            end

            table.insert(Data.Gamepasses, Id)
            Data.Gamepasses = Data.Gamepasses --> table.insert kinda weird

            return true
        end)

		Object["PurchaseCallback"](Player)
	end

	if InfoType == Enum.InfoType.GamePass then
		
		GamepassPurchased:Connect(function(Player, PurchaseId)
			if PurchaseId~=Id then return end
			Object:InvokePurchase(Player)
		end)
	else
		ProcessRecieptProcessed:Connect(function(Player, PurchaseId)
			if PurchaseId~=Id then return end
			
			Object:InvokePurchase(Player)
		end)
	end
	
	return Object
end

local function Gamepass(Id: number): GamepassObject
	local InfoType = Enum.InfoType.GamePass

	local ProductObject: any = Object(Id, InfoType)
	local GamepassObject = ProductObject :: GamepassObject

	local OnJoinMethod: any = OnJoin(Id, InfoType)
	GamepassObject.OnJoin = OnJoinMethod
	GamepassObject.PlayerOwns = PlayerOwns(Id, InfoType)

	GamepassObject.OnJoinInvoke = function(Player)
		if not GamepassObject["OnJoinCallback"] then return end
		GamepassObject["OnJoinCallback"](Player)
	end

	local function SetupOnJoin(Player)
		local Owns = GamepassObject:PlayerOwns(Player)
		if Owns then
			if GamepassObject.OnJoinCallback then
				GamepassObject["OnJoinCallback"](Player)
			end
		end
		
		task.delay(1, function()
			MarketplaceService:PromptGamePassPurchase(Player, Id)
		end)
	end

	for _, CurrentPlayer in game.Players:GetPlayers() do
		SetupOnJoin(CurrentPlayer)
	end

	game.Players.PlayerAdded:Connect(function(NewPlayer)
		SetupOnJoin(NewPlayer)
	end)
	return GamepassObject
end

local function Product(Id: number): ProductObject
	local InfoType = Enum.InfoType.Product
	local ProductObject: any = Object(Id, InfoType)
	return ProductObject
end

local function Start()
	local function AddRobuxSpent(Player: Player, Id: number, InfoType: Enum.InfoType)
		local Success, PurchaseData = pcall(function()
			return MarketplaceService:GetProductInfo(Id, InfoType)
		end)

		if Success and PurchaseData then
			local PriceInRobux = PurchaseData.PriceInRobux or 0 :: number
            DataLoader.Store:updateAsync(Player, function(Data: GameTypes.PlayerData)
                Data.RobuxSpent =  Data.RobuxSpent + PriceInRobux
                return true
            end)
		end
	end
	
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player, GamepassId, Purchased)
		if not Purchased then return end

		AddRobuxSpent(Player, GamepassId, Enum.InfoType.GamePass)
		GamepassPurchased:Fire(Player, GamepassId)
	end)

	MarketplaceService.ProcessReceipt = function(RecieptInfo)
		local PlayerId = RecieptInfo.PlayerId
		local ProductId = RecieptInfo.ProductId

		local Player = game.Players:GetPlayerByUserId(PlayerId)
		if not Player then return end

		ProcessRecieptProcessed:Fire(Player, ProductId)

		AddRobuxSpent(Player, ProductId, Enum.InfoType.Product)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end


return {
	Gamepass = Gamepass,
	Product = Product,

	Start = Start,
}