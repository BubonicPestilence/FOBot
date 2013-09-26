class Point
  include Comparable
  
  attr_accessor :x, :y
  
  def initialize(x = 0, y = 0)
    @x, @y = x, y
    @adjacentModifier = 1
    @cacheRadius = {}
  end
  
  def distanceHypot(point)
    Math.hypot(point.x - @x, point.y - @y)
  end
  
  def distanceManhattan(point)
    (point.x - @x).abs + (point.y - @y).abs
  end
  
  def distanceMaxAxis(point)
    [(point.x - @x).abs, (point.y - @y).abs].max
  end
  
  def adjacent(dir)
    case dir
    when :t
      self.class.new(@x, @y - @adjacentModifier)
    when :r
      self.class.new(@x + @adjacentModifier, @y)
    when :b
      self.class.new(@x, @y + @adjacentModifier)
    when :l
      self.class.new(@x - @adjacentModifier, @y)
    else
      raise(ArgumentError, "Unknown direction: #{dir}")
    end
  end
  
  def radius(r = 5)
    return @cacheRadius[r] if @cacheRadius[r]
    
    ret = []
    
    (-r..r).each do |y|
      (-r..r).each do |x|
        ny = @y + y * @adjacentModifier
        nx = @x + x * @adjacentModifier
        
        next if $map.blocked?(nx, ny)
        
        ret << self.class.new(nx, ny)
      end
    end
    
    @cacheRadius[r] = ret
  end
  
  def +(other_point)
    self.class.new(@x + other_point.x, @y + other_point.y)
  end
  
  def -(other_point)
    self.class.new(@x - other_point.x, @y - other_point.y)
  end
  
  def <=>(other)
    (@x + @y) <=> (other.x + other.y)
  end
  
  def to_p
    self
  end
  
  def to_a
    [@x, @y]
  end
end