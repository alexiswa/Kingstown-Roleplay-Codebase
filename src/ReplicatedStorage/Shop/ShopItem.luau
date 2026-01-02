local ShopItem = {}

-- A somewhat generic class for shop items that should be inhereted from when making specialized shops
-- (i.e. dealerships)
type ShopItemData = {
    Name: string,
    Description: string,
    Cost: number,
    MultipleBuys: boolean,
    ImageIcon: string,
    OnPurchase: (self: ShopItem, plr: Player?, ...any?) -> (),
}

ShopItem.__index = ShopItem

export type ShopItem = setmetatable<ShopItemData, typeof(ShopItem)>

function ShopItem.new(item): ShopItem
    local newItem: ShopItem = {
        Name = item.Name or "",
        Description = item.Description or "",
        Cost = item.Cost or 0,
        MultipleBuys = item.MultipleBuys or false,

        OnPurchase = ShopItem.OnPurchase,
    }
    
    setmetatable(newItem, ShopItem)

    return newItem
end

function ShopItem.OnPurchase(self: ShopItem, plr: Player?)
    print(`Bought {self.Name} for {self.Cost}!`)
end

return ShopItem