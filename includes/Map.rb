require_relative "Point"

class Map
  EXPORT = false
  
  attr_accessor :tileRows, :tileCols, :tileHeight, :tileWidth, :tileData, :tileColData, :tileSheets, :tiles, :cells
  
  def load(path, mode = :short)
    if !EXPORT
      startTime = Time.now.to_f
      
      File.open(DATA_ROOT + "/map-#{mode}.yaml", "r") do |f|
        @tileRows, @tileCols, @tileHeight, @tileWidth, @tileData, @tileColData, @tileSheets, @tiles = YAML.load(f)
      end
      
      puts "Map `%s` Load Time: %.4f" % [mode, Time.now.to_f - startTime]
      
      return self
    end
    
    puts "Map in EXPORT Mode"
    
    data = File.open(path, "rb")
    data.endianess = NetString::LITTLE_ENDIAN
    
    @tileRows, @tileCols, @tileWidth, @tileHeight = data.readInt, data.readInt, data.readInt, data.readInt
    
    @tileData = []
    (tmp = data.readInt).times do
      @tileData << data.readShort
    end
    
    @tileColData = {}
    tmp.times do |i|
      v = data.readByte
      @tileColData[i] = v if v == 0
    end
    
    @tileSheets = []
    (tmp = data.readInt).times do
      size = data.readInt
      @tileSheets << data.readBytesAsString(size)
    end
    
    @tiles = []
    (tmp = data.readInt).times do |i|
      tileSheetIndex, x, y = data.readInt, data.readInt, data.readInt
      
      tile = OpenStruct.new(
        :id => i,
        :tileSheetIndex => tileSheetIndex,
        :x => x,
        :y => y,
        :data => nil
      )
      
      tile.data = @tileSheets[0]
      tile.data = @tileSheets[tileSheetIndex] if tileSheetIndex >= 0
      
      @tiles[i] = tile
    end
    
    @tiles.each { |t| File.open("images/tiles/#{t.id}.png", "wb") { |f| f.write(t.data) }; t.data = "" }
    
    @tileSheets = ["images/tiles/YOURTILE.png"]
    
    startTime = Time.now.to_f
    
    File.open(DATA_ROOT + "/map-normal.yaml", "w") do |f|
      YAML.dump([@tileRows, @tileCols, @tileHeight, @tileWidth, @tileData, @tileColData, @tileSheets, @tiles], f)
    end
    
    puts "Map `normal` Export Time: %.4f" % [Time.now.to_f - startTime]
    startTime = Time.now.to_f
    
    File.open(DATA_ROOT + "/map-short.yaml", "w") do |f|
      @tileData = []
      @tiles = []
      
      YAML.dump([@tileRows, @tileCols, @tileHeight, @tileWidth, @tileData, @tileColData, @tileSheets, @tiles], f)
    end
    
    puts "Map `short` Expo Time: %.4f" % [Time.now.to_f - startTime]
    
    puts "Map EXPORT done"
    exit
  end
  
  def initCells
    @cells = []
    
    (0...@tileRows).each do |cy|
      (0...@tileCols).each do |cx|
        c = Cell.new(cx * @tileWidth, cy * @tileHeight)
        @cells[c.id] = c
      end
    end
  end
  
  def blocked?(*args)
    if args.size == 2
      originX, originY = args
    elsif args.first.is_a?(Point) || args.first.is_a?(Cell)
      p = args.first
      originX, originY = p.x, p.y
    else
      pp args
      raise(ArgumentError, "Unknown arguments ^^")
    end
    
    a = (originX.to_f / @tileWidth).ceil
    b = (originY.to_f / @tileHeight).ceil
    
    @tileColData[a + b * @tileCols] != 0
  end
  
  def walkable?(*args)
    !blocked?(*args)
  end
end