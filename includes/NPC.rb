require_relative "Mob"

class NPC < Mob
  attr_accessor :extra, :state
  
  def initialize(params)
    super
    
    @extra = params[:extra] || 0
    @state = params[:state] || -1
  end
  
  def skip?
    $config.ignoreNPCs.include?(@name)
  end
  
  def quest_state
    ret = case state
    when -1, 3
      :empty
    when 0
      :quest
    when 1
      :inProgress
    when 2
      :done
    else
      raise "Unknown state #{state} for NPC: [#{id}] #{name}"
    end
  end
  
  def need_attention?
    [:quest, :done].include?(quest_state) && level <= $game.char.level
  end
  
  def to_s
    "[%s] [%4d] %s [%d, %d] L: %d STATE: %d ATTENTION: %s" % [
      self.class.to_s.upcase,
      id, name, originX, originY, level,
      state, need_attention? ? "yes" : "no"
    ]
  end
end