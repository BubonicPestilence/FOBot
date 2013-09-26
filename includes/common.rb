#!/usr/local/rvm/ruby
# encoding: ascii

$stdout.sync = true
$stdin.sync = true

(puts "only from bash"; exit) if ENV['TM_FILENAME'] or ENV['SL_PROJECT']

BOT_ROOT = File.dirname(File.dirname(File.expand_path(__FILE__)))
INC_ROOT = "#{BOT_ROOT}/includes"
DATA_ROOT = "#{BOT_ROOT}/data"

$:.unshift(BOT_ROOT)
$:.unshift(File.join(INC_ROOT, "smartfox-0.4.0/lib"))

require "pp"
require "ap"
require "rainbow"
require "ostruct"
require "stringio"
require "ruby-prof"
require "yaml"
require "json"
require "digest"
require "base64"
require "active_support/all"
require "httparty"
require "nokogiri"

$staticDB = {
  item: {},
  itemByName: {},
  mob: {},
  mobByName: {},
  mobdrops: {},
}

$staticDB.keys.each { |k| path = DATA_ROOT + "/#{k}.json"; $staticDB[k] = JSON.parse(IO.read(path)) if File.exists?(path) }

{:item => :itemByName, :mob => :mobByName}.each do |from, to|
  $staticDB[from].each do |k, v|
    $staticDB[to][v["name"]] = v
  end
end

#YAML::ENGINE.yamler = "syck"

require_relative "HTTPFO"
$hfo = HTTPFO.new

require_relative "RC4"
require_relative "smartfox-0.4.0/lib/smartfox"
require_relative "Point"
require_relative "Cell"
require_relative "PathfindingJPF"

require_relative "../config"
require_relative "NetString"

require_relative "mixins/MovingEntity"
require_relative "mixins/FightingEntity"

require_relative "Messages"

require_relative "Map"

require_relative "Entity"
require_relative "Character"
require_relative "NPC"
require_relative "Mob"
require_relative "Corpse"

require_relative "Quest"
require_relative "Item"
require_relative "Spell"

def puts(*args)
  print "#{args.join("\n")}\n"
end

def putsf(fmt, *args)
  printf("#{fmt}\n", *args)
end

def md5(str)
  Digest::MD5.hexdigest(str)
end

def short_time
  Time.now.strftime("%T.%L")
end

def vrc4decrypt(key, data)
  Base64.decode64(RC4.new(key).decrypt(data))
end

def vrc4encrypt(key, data)
  RC4.new(key).encrypt(Base64.encode64(data).chop)
end

def sendMessage(a, *b)
  $sfc.send_extended("F", a, {
    :parameters => b,
    :room => $room.id,
    :format => :xt
  })
end

def normalize(a, b)
  dx = ((a.x - b.x) / [(a.x - b.x).abs, 1].max)
  dy = ((a.y - b.y) / [(a.y - b.y).abs, 1].max)
  
  return dx, dy
end

def optimizePath(path)
  return [] if path.empty?
  
  newPath = [base = path.first]
  
  iter = 1
  matchOrig = nil
  
  loop do
    currentStep = path[iter]
    
    break if currentStep.nil?
    
    rDX, rDY = normalize(currentStep, base)
    distanceDXDY = base.to_p.distanceManhattan(currentStep)
    
    limitDistance = 300
    if rDX != 0 && rDY != 0
      limitDistance = 150
    end
    
    if distanceDXDY > limitDistance
      # split path between b & n
      
      chunks = (distanceDXDY / limitDistance.to_f).floor
      chunks.times do |t|
        t += 1
        s = Cell.new(base.x + limitDistance * t * rDX, base.y + limitDistance * t * rDY)
        newPath << s
      end
    end
    
    newPath << (base = currentStep)
    
    iter += 1
  end
  
  puts " - Optimized Path Size: #{newPath.size}"
  
  newPath
end

def path(start, stop, radius = 0)
  startTime = Time.now.to_f
  
  start = start.to_c if start.is_a?(Entity)
  stop = stop.to_c if stop.is_a?(Entity)
  
  if radius == 0
    p = Pathfinding.new($map, start, stop).find
  else
    radiusEnds = stop.radius(radius).sort_by { |c| $game.char.distanceHypot(c) }
    
    radiusEnds.each do |c|
      break unless (p = Pathfinding.new($map, start, c).find).empty?
    end
  end
  
  if $config.showPathfinding
    putsf("Pathfinding: %.4f (%s -> %s) Radius: %d Size: %d", Time.now.to_f - startTime, start, stop, radius, p.size)
  end
  
  optimizePath(p)
end

def inspect_default
  vars = self.instance_variables.map { |v| "#{v}=#{instance_variable_get(v).inspect}" }.join(", ")
  "<#{self.class}: #{vars}>"
end