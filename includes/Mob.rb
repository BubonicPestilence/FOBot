require_relative "Character"

class Mob < Character
  attr_accessor :zone
  
  def initialize(params)
    super
    
    @zone = params[:zone] || 0
  end
  
  def vein?
    @name =~ / Vein$/
  end
  
  def chest?
    @name =~ /Treasure Chest/ || @name =~ /Supply Crate/ || @name =~ /Lost Treasure/ || @name =~ /Alien Chest/
  end
  
  def skip?
    vein? || chest? || $staticDB[:mobByName][@name]["health"].to_i >= 50000 || $config.ignoreMobs.include?(@name) || @originX.nil? || @originY.nil?
  end
  
  def to_s
    "[%s] [%4d] [%3d] %32s [%5d, %5d] L: %3d" % [
      self.class.to_s.upcase,
      @id, @subType, @name, @originX, @originY, @level,
      @gold, @stats.statPoints
    ]
  end
end