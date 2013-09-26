#!/usr/local/rvm/ruby

require_relative "includes/common"

require "fileutils"
require "rmagick"
include Magick

global = false

FileUtils.rm_rf(Dir.glob("images/maps/y-*.png")) unless global

puts "Loading Map"
$map = Map.new
$map.load(DATA_ROOT + "/world")
puts " - Done"

colorNormal = "green"
colorBlocked = "white"

squareSize = 1
cellsW = Cell::ZONE_WIDTH
cellsH = Cell::ZONE_HEIGHT

mapsH = $map.tileCols / Cell::ZONE_WIDTH
mapsV = $map.tileRows / Cell::ZONE_HEIGHT

if global
  cellsW = $map.tileCols
  cellsH = $map.tileRows

  mapsH = 0
  mapsV = 0
end

w, h = [cellsW * squareSize, cellsH * squareSize]

puts mapsH, mapsV, $map.tileCols, $map.tileRows

(0...mapsV).each do |mv|
  (0...mapsH).each do |mh|
    mapID = "oops"
    
    origin = [mh * cellsW, mv * cellsH]
    canvas = Image.new(w, h) { self.background_color = "white" }
    
    puts origin, ""
    
    (0...cellsH).each do |cy|
      (0...cellsW).each do |cx|
        mx = cx + origin[0]
        my = cy + origin[1]
        
        if Cell.mapID(mx * $map.tileWidth, my * $map.tileHeight) != mapID && mapID != "oops" && !global
          raise "error @ mapID for #{mx * $map.tileWidth}, #{my * $map.tileHeight}"
        end
        
        mapID = Cell.mapID(mx * $map.tileWidth, my * $map.tileHeight)
        
        color = $map.blocked?(mx * $map.tileWidth, my * $map.tileHeight) ? colorBlocked : colorNormal
        
        cell = [
          cx * squareSize,
          cy * squareSize,
          cx * squareSize + squareSize,
          cy * squareSize + squareSize,
        ]
        Draw.new.fill(color).stroke_width(0).rectangle(*cell).draw(canvas)
      end
    end
    
    filename = "y-#{mv}-x-#{mh}-id-#{mapID}"
    filename = "global" if global
    
    puts filename
    
    canvas.write("images/maps/#{filename}.png")
  end
end