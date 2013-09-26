class Quest
  attr_accessor :id, :npcID, :npcName, :title, :summary, :progress, :description, :rewardGold, :objectives
  
  def initialize(params)
    @id = params[:id] || 0
    @npcID = params[:npcID] || 0
    @npcName = params[:npcName] || ""
    @title = params[:title] || ""
    @summary = params[:summary] || ""
    @progress = params[:progress] || ""
    @description = params[:description] || ""
    @rewardGold = params[:rewardGold] || 0
    
    @objectives = {}
    
    process
  end
  
  def progress=(val)
    @progress = val
    process
  end
  
  def process
    return unless @progress =~ /(\d+)\/(\d+)\s+(.+)/
    got, need, name = $1.to_i, $2.to_i, $3
    
    objectives[name] = OpenStruct.new(
      got: got,
      need: need,
    )
  end
  
  def mobs
    ret = []
    
    objectives.each do |name, v|
      next if v.got >= v.need
      
      if $game.mobs.values.any? { |m| m.name == name }
        ret << name
      elsif item = $staticDB[:item].values.find { |item| item["name"] == name }#&& item["quest"].to_i == id }
        itemID = item["id"].to_i
        
        $staticDB[:mobdrops].each do |mobID, drops|
          next unless drops.include?(itemID)
          
          mobID = mobID.to_i
          next unless mob = $staticDB[:mob][mobID.to_s]
          mobName = mob["name"]
          ret << mobName
        end
      end
    end
    
    ret.uniq
  end
  
  def objectives?
    !objectives.empty?
  end
  
  def done?
    objectives? && objectives.values.all? { |o| o.got >= o.need }
  end
  
  def need?(itemName)
    objectives[itemName] && objectives[itemName].need > objectives[itemName].got
  end
  
  def to_s
    "[%s] [%3d] [%3d] %48s (G: %5d) (%4s) => %s" % [
      self.class.to_s.upcase,
      id, npcID, title, rewardGold,
      (done? ? "done" : ""), progress,
    ]
  end
end