require "set"

require_relative "Point"

class ANode
  attr_accessor :parent, :p, :f, :g, :h
  
  def initialize(options = {})
    options = {
      :f => -1.0,
      :g => -1.0,
      :h => -1.0,
      :w => 0.0,
    }.update(options)
    
    @parent = options[:parent]
    @map = options[:map]
    @p = options[:p]
    @f = options[:f]
    @g = options[:g]
    @h = options[:h]
    @w = options[:w]
  end
  
  def calc_g(start)
    g = 0.0
    
    if @parent
      g = @parent.calc_g(start)
      g += @parent.p.distanceHypot(@p)
    else
      start.p.distanceHypot(@p)
    end
  end
  
  def calculate(start, stop)
    @g = calc_g(start)
    @h = @p.distanceHypot(stop.p)
    @f = @g + @h + @w
  end
  
  def to_path
    return [@p] + @parent.to_path if @parent
    [@p]
  end
end

class Pathfinding
  def initialize(map, start, stop)
    @map = map
    @start = ANode.new(:p => start, :map => map)
    @stop = ANode.new(:p => stop, :map => map)
    
    @open = [@start]
    @closed = {}
  end
  
  def sort!
    @open = @open.sort_by { |a| a.f }
  end
  
  def find(limit = 100000)
    i = 0
    
    until @open.empty?
      sort!
      
      current = @open.shift
      return current.to_path.reverse if current.p == @stop.p
      
      @closed[current.p.id] = current
      
      Cell::DIRS.each do |direction|
        p = current.p.adjacent(direction)
        next if p.nil? || @closed[p.id] || p.mapID != @start.p.mapID || @map.blocked?(p)
        
        i += 1
        break if limit && i > limit
        
        neighbor = ANode.new(:p => p, :parent => current)
        neighbor.parent = current
        neighbor.calculate(@start, @stop)
        
        yield [p, neighbor.g, neighbor.h, neighbor.f] if block_given?
        
        if fnode = @open.find { |n| n.p == p }
          if neighbor.g < fnode.g
            fnode.parent = current
            fnode.calculate(@start, @stop)
          end
        else
          @open << neighbor
        end
      end
      
      break if limit && i > limit
    end
    
    []
  end
end