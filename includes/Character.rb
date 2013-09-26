require_relative "Entity"

class Character < Entity
  include Enumerable
  include FightingEntity, MovingEntity
  
  attr_accessor :type, :level, :display, :pet, :health, :maxHealth, :mana, :maxMana, :gold, :buffs, :xp, :toLevelXP, :stats, :inventory, :friends, :display, :pvpFlag, :rebirth, :pet, :subType
  
  def initialize(params)
    super
    
    @type = params[:type] || 0
    @level = params[:level] || 1
    @display = params[:display] || ""
    @pvpFlag = params[:pvpFlag] || false
    @rebirth = params[:rebirth] || ""
    @pet = params[:pet] || ""
    @subType = params[:subType] || ""
    
    @buffs = {}
    
    @health = 0
    @maxHealth = 0
    @mana = 0
    @maxMana = 0
    @gold = 0
    @xp = 0
    @toLevelXP = 0
    
    @stats = OpenStruct.new(stamina: 0, strength: 0, agility: 0, intellect: 0, luck: 0, coins: 0, gems: 0, statPoints: 0)
    @display = OpenStruct.new(skin: "", scaleX: 0.0, scaleY: 0.0)
    @pet = OpenStruct.new
    
    @casting = false
    @castStartTime = 0
    @castTime = 0
    
    @inventory = {}
    @friends = {}
  end
  
  def each(&block)
    @inventory.values.each(&block)
  end
  
  def equiped
    select { |i| i.location == :char }
  end
  
  def bagged
    select { |i| i.location == :bag }
  end
  
  def banked
    select { |i| i.location == :bank }
  end
  
  def casting?
    Time.now.to_f <= @castStartTime + @castTime
  end
  
  def cast_start(castTime)
    @castStartTime = Time.now.to_f
    @castTime = castTime
    @castEndTime = @castStartTime + @castTime
  end
  
  def currentHealth(health, maxHealth = 0)
    @health = health
    @maxHealth = maxHealth if maxHealth > 0
  end
  
  def currentMana(mana, maxMana = 0)
    @mana = mana
    @maxMana = maxMana if maxMana > 0
  end
  
  def damage(amount)
    puts "[%d] Damaged by %d (%d / %d)" % [@id, amount, @health, @maxHealth] if $config.showDamageHealth
  end
  
  def damageMana(amount)
    puts "[%d] Mana Damaged by %d (%d / %d)" % [@id, amount, @mana, @maxMana] if $config.showDamageMana
  end
  
  def cmdMove(*args)
    if args.size == 2
      x, y = args
    elsif args.first.is_a?(Point)
      x, y = args.first.x - @originX, args.first.y - @originY
    else
      raise(ArgumentError, "Unknown arguments: #{args}")
    end
    
    sendMessage("mv", @originX, @originY, x, y) if !moving?
  end
  
  def cmdCast(spellID, mobID, mobType)
    sendMessage("sp", spellID, 0, mobID, mobType)
  end
  
  def cmdAttack(mobID, mobType)
    cmdCast(1, mobID, mobType)
  end
  
  def cmdLoot(corpseID, slot)
    sendMessage("l", corpseID, slot)
  end
  
  def to_s
    "[%s] [%7d] %s [%d, %d] L: %d HP: %d/%d MP: %d/%d" % [
      self.class.to_s.upcase,
      @id, @name, @originX, @originY, @level,
      @health, @maxHealth, @mana, @maxMana
    ]
  end
end
