module ItemType
  BAG = "BAG"; MAINBAG = "MAINBAG"
  ARMOR = "ARM"; BODYARMOR = "BRM"; LEGARMOR = "LRM"; HELMET = "HLM"; SHOULDER = "SHL"
  WEAPON = "WEP"; OFFHAND = "OFF"; LARM = "LAR"; RARM = "RAR"; WEAPONSLOT = 8; OFFHANDSLOT = 9
  SOCKET = "SCK"; POCKET = "PCK"
  RING = "RNG"; NECKARMOR = "NCK"; ITEMARMOR = "ITM"
  HEART = "HRT"; BRAIN = "BRA"; LEGS = "ALR"
  CONSUMABLE = "CSM"; SPELL = "SPELL"; GUILD = "GUI"
end

class Item
  attr_accessor :id, :type, :subType, :name, :stack, :item, :icon, :itemAttr, :slot, :vendorSellsFor, :vendorBuysFor, :vendorCostGems, :vendorCostGuildPoints
  
  def self.from_array(arr)
    item = OpenStruct.new(
      id: arr[1].to_i,
      name: arr[2],
      description: arr[27],
      bind: arr[5].to_i,
      rarity: arr[6].to_i,
      itemClass: arr[9].to_i,
      stack: arr[10].to_i,
      
      itemPvPLevelReq: arr[39].to_i,
      itemPvPEndurance: arr[41].to_i,
      itemPvPDefense: arr[42].to_i,
      
      window: arr[43].to_i,
      slot: arr[44].to_i,
      animation: arr[28].to_i,
      sprite: arr[11],
      itemAttr: arr[12],
      
      level: arr[3].to_i,
      levelRequired: arr[4].to_i,
      rebirthRequired: arr[37].to_i,
      guildLevelRequired: arr[33].to_i,
      factionIDRequired: arr[34].to_i,
      factionNotorietyRequired: arr[35].to_i,
      
      stamina: arr[13].to_i,
      strength: arr[15].to_i,
      agility: arr[14].to_i,
      intellect: arr[16].to_i,
      luck: arr[36].to_i,
      
      attackPower: arr[38].to_i,
      minDmg: arr[18].to_i,
      maxDmg: arr[19].to_i,
      speed: arr[20].to_i,
      range: arr[29].to_i,
      
      armor: arr[21].to_i,

      requiredStamina: arr[23].to_i,
      requiredStrength: arr[25].to_i,
      requiredAgility: arr[24].to_i,
      requiredIntellect: arr[26].to_i,
      
      vendorSellsFor: arr[22].to_i,
      vendorBuysFor: arr[30].to_i,
      vendorGemsFor: arr[31].to_i,
      vendorGuildpointsFor: arr[32].to_i,
      vendorFavorsFor: arr[40].to_i,
    )
    
    if arr[7] != ItemType::BAG
      container = new(type: arr[7])
    else
      container = Bag.new(type: ItemType::BAG)
    end

    container.tap do |c|
      c.id = arr[0].to_i
      c.subType = arr[8]
      c.name = item.name
      c.stack = arr[45].to_i
      c.item = item
      c.icon = "item_icons/" + item.sprite
      c.itemAttr = item.itemAttr
      c.slot = item.slot
      
      c.vendorSellsFor = item.vendorSellsFor
      c.vendorBuysFor = item.vendorBuysFor
      c.vendorCostGems = item.vendorGemsFor
      c.vendorCostGuildPoints = item.vendorGuildpointsFor
    end
    
    container
  end
  
  def initialize(params)
    @id = params[:id] || 0
    @type = params[:type] || "ITEM"
    @subType = params[:subType] || 0
    @name = params[:name] || ""
    @stack = params[:stack] || 0
    @item = params[:item] || OpenStruct.new
    @icon = params[:icon] || ""
    @itemAttr = params[:itemAttr] || ""
    @slot = params[:slot] || 0
    
    @vendorSellsFor = params[:vendorSellsFor] || 0
    @vendorBuysFor = params[:vendorBuysFor] || 0
    @vendorCostGems = params[:vendorCostGems] || 0
    @vendorCostGuildPoints = params[:vendorGuildpointsFor] || 0
  end
  
  def location
    case item.window
    when 0..4
      :bag
    when 5
      :bank
    when 6
      :bagBar
    when 8
      :char
    when 9
      :loot
    else
      raise "Unknown location for item [#{id}] #{name} at #{item.window}"
    end
  end
  
  def stackable?
    stack > 0
  end
  
  def able_to_stack?
    stackable? && item.stack > stack
  end
  
  def to_s
    out = ""
    
    out += sprintf("ID: %d | TYPE: %s | STYPE: %s | NAME: %s | STACK: %d | LOCATION: %s | ATTR: %s", id, type, subType, name, stack, location.to_s.upcase, itemAttr)
    out += sprintf("\n    ID: %d | NAME: %s | CLASS: %s | STACK: %d\n    DESC: %s", item.id, item.name, item.itemClass, item.stack, item.description.gsub(/\r?\n/, "\\n "))
    out += sprintf("\n    SLOT: %d | ANIMATION: %d", item.slot, item.animation)
    
    requirements = [item.level, item.levelRequired, item.rebirthRequired, item.guildLevelRequired, item.factionIDRequired, item.factionNotorietyRequired]
    out += sprintf("\n    L: %d | LREQ: %d | R: %d | GLREQ: %d | FIDREQ: %d | FNREQ: %d", *requirements) if requirements.any? { |r| r > 0 }
    
    stats = [item.stamina, item.strength, item.agility, item.intellect, item.luck, item.attackPower, item.minDmg, item.maxDmg, item.speed, item.armor, item.range]
    out += sprintf("\n    STA: %d | STR: %d | AGI: %d | INT: %d | LU: %d | AP: %d | DMG: %d-%s | SPD: %.2f | AR: %d | RNG: %d", *stats) if stats.any? { |s| s > 0 }
    
    statsRequiremets = [item.requiredStamina, item.requiredStrength, item.requiredAgility, item.requiredIntellect]
    out += sprintf("\n    REQSTA: %d | REQSTR: %d | REQAGI: %d | REQINT: %d", *statsRequiremets) if statsRequiremets.any? { |sr| sr > 0 }
    
    prices = [vendorSellsFor, vendorBuysFor, vendorCostGems, vendorCostGuildPoints]
    out += sprintf("\n    SELLSFOR: %d | BUYFOR: %d | GEMS: %d | GUILDPOINTS: %d", *prices) if prices.any? { |p| p > 0 }
    
    out
  end
end