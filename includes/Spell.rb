require_relative "Item"

class Spell < Item
  attr_accessor :cooldownLength
  
  def self.from_array(arr)
    item = OpenStruct.new(
      id: arr[1].to_i,
      
      name: arr[2],
      description: arr[3],
      
      rank: arr[6].to_i,
      manaCost: arr[10].to_i,
      cooldownID: arr[20].to_i,
      cooldownLength: arr[21].to_f,
      
      requiredLevel: arr[5].to_i,
      requiredStrength: arr[16].to_i,
      requiredAgility: arr[17].to_i,
      requiredIntellect: arr[18].to_i,
      requiredStamina: arr[19].to_i,
      
      pvpLevel: arr[22].to_i,
      
      vendorSellsFor: arr[14].to_i,
      vendorCostGems: arr[15].to_i,
    )
    
    new(
      id: arr[0].to_i,
      name: item.name,
      item: item,
      icon: "spell_icons/" + item.name,
      
      vendorSellsFor: item.vendorSellsFor,
      vendorCostGems: item.vendorCostGems,
    )
  end
  
  def initialize(params)
    super
    
    @type = params[:type] || "SPELL"
  end
  
  def castable?
    item.requiredLevel <= $game.char.level &&
    item.requiredStamina <= $game.char.stats.stamina &&
    item.requiredStrength <= $game.char.stats.strength &&
    item.requiredAgility <= $game.char.stats.agility &&
    item.requiredIntellect <= $game.char.stats.intellect
  end
  
  def to_s
    out = ""
    
    out += sprintf("ID: %d | TYPE: %s | STYPE: %s | NAME: %s | CD: %.2f", id, type, subType, name, item.cooldownLength)
    out += sprintf("\n    ID: %d | NAME: %s | RANK: %d\n    DESC: %s", item.id, item.name, item.rank, item.description.gsub(/\r?\n/, "\\n "))
    
    statsRequiremets = [item.requiredStamina, item.requiredStrength, item.requiredAgility, item.requiredIntellect]
    out += sprintf("\n    REQSTA: %d | REQSTR: %d | REQAGI: %d | REQINT: %d", *statsRequiremets) if statsRequiremets.any? { |sr| sr > 0 }
    
    prices = [vendorSellsFor, vendorCostGems]
    out += sprintf("\n    SELLSFOR: %d | GEMS: %d", *prices) if prices.any? { |p| p > 0 }
    
    out
  end
end