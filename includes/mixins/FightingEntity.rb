module FightingEntity
  attr_accessor :attacker, :dead
  
  def self.included(parent)
    @attacker = nil
    @dead = false
  end
  
  def attack(attacker)
    @attacker = attacker
  end
  
  def attacking?(mob = nil)
    return @attacker && @attacker == mob if mob
    !!@attacker
  end
  
  def stopAttacking
    @attacker = nil
  end
  
  def die; stopAttacking; @dead = true; end
  def resurrect; @dead = false; end
  
  def dead?; @dead; end
  def alive?; !dead?; end
end