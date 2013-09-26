require "set"

require_relative "Point"

class ANode
  include Comparable
  
  attr_accessor :parent, :p, :f, :g, :h, :d
  
  def initialize(p, options = {})
    options = {
      :f => 0.0,
      :g => 0.0,
      :h => 0.0,
      :w => 0.0,
      :d => 0.0,
    }.update(options)
    
    @p = p
    
    @parent = options[:parent]
    @map = options[:map]
    @f = options[:f]
    @g = options[:g]
    @h = options[:h]
    @w = options[:w]
    @d = options[:d]
  end
  
  def path
    return [@p] + @parent.path if @parent
    [@p]
  end
  
  def ===(other)
    other.id == id
  end
  
  def to_s
    "#{@p}"
  end
end

class Pathfinding
  def initialize(map, start, stop)
    raise "Pathfinding: Start (#{start}) blocked!" if $map.blocked?(start)
    raise "Pathfinding: Stop (#{stop}) blocked!" if $map.blocked?(stop)
    
    @map = map
    @start = ANode.new(start)
    @stop = ANode.new(stop)
    
    @open = [@start]
    @closed = {}
  end
  
  def sort!
    @open = @open.sort_by { |a| a.f }
  end
  
  def find(limit = 1000000)
    while @open.size > 0
      # puts ""
      
      sort!
      
      node = @open.shift
      @closed[node.p.id] = node
      # puts "closed: #{node.p.id}"
      
      if node.p.id == @stop.p.id
        # puts node, "found path?", node.path
        return node.path.reverse
      end
      
      identifySuccessors(node)
    end
    
    raise "Path not found! #{start} => #{stop}"
    exit
  end
  
  def identifySuccessors(node)
    # puts "node: #{node}"
    
    neighbours = findNeighbours(node)
    neighbours.each do |neighbour|
      # puts " - neighbour: #{neighbour}"
      
      jp = jump(neighbour, node)
      
      # puts " - jp: #{jp} | #{(jp.p.id if jp) || "-"} | #{(!!@closed[jp.p.id] if jp) || "-"}"
      next if !jp || @closed[jp.p.id]
      
      dx = (jp.p.x - node.p.x).abs
      dy = (jp.p.y - node.p.y).abs
      d = Math.sqrt(dx * dx + dy * dy)
      ng = node.g + d
      
      if !@open.find { |n| n.p.id == jp.p.id }
        # puts " - insert: #{jp.p.id}", ""
        jp.g = ng
        jp.h = jp.p.distanceHypot(@stop.p)
        jp.f = jp.g + jp.h
        jp.parent = node
        
        @open << jp
      elsif n = @open.find { |n| n.p.id == node.p.id && ng < jp.g }
        # puts " - update: #{n.p.id} => #{ng} < #{jp.g}", ""
        n.g = ng
        n.h = n.p.distanceHypot(@stop.p)
        n.f = n.g + n.h
        n.parent = node
      end
    end
  end
  
  def jump(node, parent)
    return if node.nil? || @map.blocked?(node.p)
    return node if node.p.id == parent.p.id || node.p.id == @stop.p.id
    
    x, y = node.p.x, node.p.y
    dx = x - parent.p.x
    dy = y - parent.p.y
    
    # puts " - - jump (dx, dy): #{dx}, #{dy}; #{Cell.new(x + dx, y + dy)}"
    
    if dx != 0 && dy != 0
      return node if (@map.walkable?(x - dx, y + dy) && (@map.blocked?(x - dx, y))) || (@map.walkable?(x + dx, y - dy) && (@map.blocked?(x, y - dy)))
    else
      if dx != 0
        return node if (@map.walkable?(x + dx, y + 32) && (@map.blocked?(x, y + 32))) || (@map.walkable?(x + dx, y - 32) && (@map.blocked?(x, y - 32)))
      else
        return node if (@map.walkable?(x + 32, y + dy) && (@map.blocked?(x + 32, y))) || (@map.walkable?(x - 32, y + dy) && (@map.blocked?(x - 32, y)))
      end
    end
    
    if dx != 0 && dy != 0
      return node if jump(ANode.new(Cell.new(x + dx, y)), node)
      return node if jump(ANode.new(Cell.new(x, y + dy)), node)
    end
    
    if @map.walkable?(x + dx, y) || @map.walkable?(x, y + dy) then
      return jump(ANode.new(Cell.new(x + dx, y + dy)), node)
    end
    
    nil
  end
  
  def self.normalize(node, parent)
    # puts " - - Normalize: #{node.p} vs. #{parent.p}"
    dx = ((node.p.x - parent.p.x) / [(node.p.x - parent.p.x).abs, 1].max) * 32
    dy = ((node.p.y - parent.p.y) / [(node.p.y - parent.p.y).abs, 1].max) * 32
    
    return dx, dy
  end
  
  def findNeighbours(node)
    neighbours = []
    
    if node.parent
      x, y = node.p.x, node.p.y
      dx, dy = self.class.normalize(node, node.parent)
      
      # puts " - fn: #{dx}, #{dy}"
      
      if dx != 0 && dy != 0
        walkY, walkX = false, false
        
        if @map.walkable?(x, y + dy)
          neighbours << ANode.new(Cell.new(x, y + dy))
          walkY = true
        end
        
        if @map.walkable?(x + dx, y)
          neighbours << ANode.new(Cell.new(x + dx, y))
          walkX = true
        end
        
        if walkX || walkY
          neighbours << ANode.new(Cell.new(x + dx, y + dy))
        end
        
        if (@map.blocked?(x - dx, y)) && walkY
          neighbours << ANode.new(Cell.new(x - dx, y + dy))
        end
        
        if (@map.blocked?(x, y - dy)) && walkX
          neighbours << ANode.new(Cell.new(x + dx, y - dy))
        end
      else
        if dx == 0
          walkY = false
          
          if @map.walkable?(x, y + dy)
            neighbours << ANode.new(Cell.new(x, y + dy))
            
            if (@map.blocked?(x + 32, y))
              neighbours << ANode.new(Cell.new(x + 32, y + dy))
            end
            
            if (@map.blocked?(x - 32, y))
              neighbours << ANode.new(Cell.new(x - 32, y + dy))
            end
          end
        else
          if @map.walkable?(x + dx, y)
            neighbours << ANode.new(Cell.new(x + dx, y))
            
            if (@map.blocked?(x, y + 32))
              neighbours << ANode.new(Cell.new(x + dx, y + 32))
            end
            
            if (@map.blocked?(x, y - 32))
              neighbours << ANode.new(Cell.new(x + dx, y - 32))
            end
          end
        end
      end
    else
      # puts " - - all neighbours"
      neighbours += node.p.adjacents.map { |c| ANode.new(c) }
    end
    
    neighbours
  end
end