#require_relative "Character"
require_relative "Point"

class Cell < Point
  attr_accessor :id, :mapID
  
  DIRS = [:t, :tr, :r, :br, :b, :bl, :l, :tl]
  #DIRS = [:t, :r, :b, :l]
  
  ZONE_WIDTH = 128
  ZONE_HEIGHT = 96
  
  def self.id(x, y)
    (x.to_f / $map.tileWidth).ceil + ((y.to_f / $map.tileHeight).ceil * $map.tileCols)
  end
  
  def self.mapID(x, y)
    (x.to_f / (ZONE_WIDTH * $map.tileWidth)).floor + (y.to_f / (ZONE_HEIGHT * $map.tileHeight)).floor * ($map.tileCols / ZONE_WIDTH)
  end
  
  def initialize(*args)
    super
    
    @adjacentModifier = 32
    
    @id = self.class.id(x, y)
    
    @x = (@x.to_f / $map.tileWidth).ceil * $map.tileWidth - 16
    @y = (@y.to_f / $map.tileHeight).ceil * $map.tileWidth - 16
    
    @mapID = self.class.mapID(@x, @y)
    
    return $map.cells[@id] if $map.cells[@id]
  end
  
  def min
    [
      (@x.to_f / $map.tileWidth).ceil * $map.tileWidth,
      (@y.to_f / $map.tileHeight).ceil * $map.tileHeight,
    ]
  end
  
  def max
    m = min
    
    [
      m[0] + $map.tileWidth - 1,
      m[1] + $map.tileHeight - 1,
    ]
  end
  
  def to_p
    Point.new(@x, @y)
  end
  
  def adjacent(dir)
    raise(ArgumentError, "Unknown direction: #{dir}") unless DIRS.include?(dir)
    
    case dir
    when :t
      $map.cells[@id - $map.tileCols]
    when :tr
      $map.cells[@id - $map.tileCols + 1]
    when :r
      $map.cells[@id + 1]
    when :br
      $map.cells[@id + $map.tileCols + 1]
    when :b
      $map.cells[@id + $map.tileCols]
    when :bl
      $map.cells[@id + $map.tileCols - 1]
    when :l
      $map.cells[@id - 1]
    when :tl
      $map.cells[@id - $map.tileCols - 1]
    end
  end
  
  def adjacents
    DIRS.map { |d| adjacent(d) }
  end
  
  def <=>(other)
    case other
    when Entity
      @id <=> other.to_c.id
    when Cell
      @id <=> other.id
    when Point
      a, b = min, max
      
      return 0 if (a[0] >= other.x && other.x <= b[0]) && (a[1] >= other.y && other.y <= b[1])
      -1
    else
      raise "No idea how to comparent #{self} to #{other.inspect}"
    end
  end
  
  def to_s
    "Cell #%d @ %d: [%d, %d]" % [@id, @mapID, @x, @y]
  end
end