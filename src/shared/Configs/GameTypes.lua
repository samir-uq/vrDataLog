local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Lyra = require(ReplicatedStorage.Packages.Lyra)

export type InvItemData = {
	UniqueId: number,
	Level: number?,
	XP: number?,
}

export type InventoryItem = {
	Name: string,
	Count: number,
	Data: InvItemData
}

export type PlayerData = {
	RobuxSpent: number,
	Gamepasses: {number},
	Inventory: InventoryItem,
}

export type Item = {
	Name: string,
	Type: string,

	Price: number?,
	PriceType: string?,

	Limited: boolean?,
	LimitedSpan: (()->(boolean))?,
	LimitedAmount: number?,
	NotForSale: boolean?,

	MaxPerPlayer: number?,
	CanPurchase: ((Entity)->boolean)?,

	CanSpin: boolean?,

	ShotClock: (number | ((Entity, number) -> number))?,
	CastDistance: ({Min: Vector2, Max: Vector2} | ((Entity, number, number) -> {Min: Vector2, Max: Vector2}))?,
	Power: (number | ((Entity)->number))?,
	Luck: (number | ((Entity)->number))?,
	LureCycles: ({Min: number, Max: number} | (Entity)->{Min: number, Max: number})?,
	WaitDuration: ({Min: number, Max: number} | (Entity)->{Min: number, Max: number})?,


	Data: {
		Level: number?,
		XP: number?
	}?,
	Use: ()->()?,
}

export type EntityData = {

}

export type Entity = {
	IsAPlayer: boolean,
	Instance: Player| R6,
	Janitor: Janitor.Janitor,
	EntityDataChanged: Signal.Signal<...any>,
	SavedDataChanged: Signal.Signal<...any>,
	MockData: {}?,
	EntityData: {},
	Id: number,
	JoinTime: number,

	EventContainer: {[string]: Signal.Signal<...any>},
	Events: typeof(setmetatable({}, {})),

	Destroy: (self: Entity) -> (),
	GetSavedData: (self: Entity) -> (PlayerData),
	UpdateSavedData: (self: Entity, Callback: (PlayerData) -> boolean) -> (),
	GetTempData: (self: Entity) -> (EntityData),
	UpdateTempData: (self: Entity, Callback: (EntityData) -> boolean) -> (),
	GetPlayerStore: (self: Entity) -> typeof(Lyra),
	GetEvent: (self: Entity, Signal: string) -> Signal.Signal<...any>,
}

export type R6 = Model &  {
	Humanoid: Humanoid & {
		HumanoidDescription: HumanoidDescription,
		Animator: Animator
	},
	HumanoidRootPart: BasePart & {
		RootAttachment: Attachment,
		RootJoint: Motor6D
	},

	Head: BasePart & {
		FaceCenterAttachment: Attachment,
		FaceFrontAttachment: Attachment,
		HairAttachment: Attachment,
		HatAttachment: Attachment,
		Mesh: SpecialMesh,
		face: Decal,
	},
	Torso: BasePart & {
		BodyBackAttachment: Attachment,
		BodyFrontAttachment: Attachment,
		LeftCollarAttachment: Attachment,
		NeckAttachment: Attachment,
		RightCollarAttachment: Attachment,
		WaistBackAttachment: Attachment,
		WaistCenterAttachment: Attachment,
		WaistFrontAttachment: Attachment,
		['Left Hip']: Motor6D,
		['Left Shoulder']: Motor6D,
		['Neck']: Motor6D,
		['Right Hip']: Motor6D,
		['Right Right Shoulder']: Motor6D,
	},
	['Left Arm']: BasePart & {
		LeftGripAttachment: Attachment,
		LeftShoulderAttachment: Attachment,
	},
	['Left Leg']: BasePart & {
		LeftFootAttachment: Attachment,
	},
	['Right Arm']: BasePart & {
		RightGripAttachment: Attachment,
		RightShoulderAttachment: Attachment,
	},
	['Right Leg']: BasePart & {
		RightFootAttachment: Attachment,
	},
}

export type DeviceType = "Console" | "Computer" | "Mobile"
export type ConsoleType = "Xbox" | "PlayStation"
export type BindData = {
	ListeningTo: {Enum.UserInputType | Enum.KeyCode},
	State: {Enum.UserInputState},
	Callback: (InputObject) -> (),
}


return {}