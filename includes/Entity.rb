class Entity
  include Comparable
  
  attr_accessor :id, :name, :originX, :originY
  
  def initialize(params)
    @id = params[:id] || 0
    @name = params[:name] || "NoName"
    @originX = params[:originX] || 0
    @originY = params[:originY] || 0
  end
  
  alias_method :x, :originX
  alias_method :y, :originY
  
  def to_c
    Cell.new(@originX, @originY)
  end
  
  def to_p
    Point.new(@originX, @originY)
  end
  
  def <=>(other)
    case other
    when Entity
      @id <=> other.to_c.id
    when Cell
      to_c.id <=> other.id
    when Point
      to_p <=> other
    else
      raise "No idea how to comparent #{self} to #{other.inspect}"
    end
  end
  
  [:distanceHypot, :distanceManhattan, :distanceMaxAxis].each do |m|
    define_method(m) do |other|
      case other
      when Entity
        to_p.distanceHypot(other.to_p)
      when Point
        to_p.distanceHypot(other)
      end
    end
  end
end