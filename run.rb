#!/usr/local/rvm/ruby
# encoding: ascii

require_relative "includes/common"

$room = nil

logins = {}

$config.characters.each do |name, data|
  next if data[:disabled]
  
  if data[:hash].blank?
    data[:hash] = $hfo.fetchAuthHash(name, data[:password])
    
    puts "New hash for #{name}: #{data[:hash]}"
  end
  
  logins[name] = data[:hash]
end

login = ARGV[0] || logins.keys.last
(puts "Wrong character #{login}".color(:red); exit) unless logins[login]

$config.server = $config.characters[login][:server] || $config.server || rand(3)
server = "FO0#{$config.server}"
puts "Using: #{login} at #{server}".color(:red)

puts "Loading Map"
$map = Map.new
$map.load(DATA_ROOT + "/world")
$map.initCells
puts " - Done"

$game = OpenStruct.new(
  char: nil,
  characters: {},
  charactersByName: {},
  mobs: {},
  corpses: {},
  npcs: {},
  quests: {},
  questsDone: 0,
  group: {},
  spellBook: {},
  zone: OpenStruct.new(
    id: 0,
    name: "",
    xOffset: 0,
    yOffset: 0
  ),
  friends: {},
  ignores: Set.new,
  notoriety: {},
)

$loggedIn = false
$canStart = false
$moveQueue = []
$castQueue = []

require INC_ROOT + "/MessageHandler.rb"

SmartFox::Logger.sev_threshold = Logger::WARN
#SmartFox::Logger.sev_threshold = Logger::DEBUG

$sfc = sfc = SmartFox::Client.new(server: $config.ip, port: $config.port)

sfc.add_handler(:connected) do |sfc|
  puts "Connected"
  sfc.login(server, login, logins[login])
end

sfc.add_handler(:rooms_updated) do |sfc|
  puts "Rooms Updated"
  $room = sfc.room_list.values.first
  sfc.join_room($room)
end

sfc.add_handler(:extended_response) do |sfc, data|
  next if data.is_a?(Hash)
  
  a, *b = data
  handlePacket(a, b)
end

sfc.connect

$canStart = $config.autoStart
oldMobID = 0
lastMove = Time.now.to_f
evasionTick = 0.0

def handle_quests
  return false if $game.npcs.empty? || (npcs = $game.npcs.values.select { |n| n.need_attention? && !n.skip? }).empty?
  
  r = 5
  
  n = npcs.sort_by { |n| path($game.char, n, r).size }.first
  
  if $game.char.distanceMaxAxis(n) <= 300
    puts "Speaking with NPC #{n.name}, state: #{n.state}"
    
    if n.state == 2
      sendMessage(Messages::NPC::QuestComplete, n.id)
    else
      sendMessage(Messages::NPC::Request, n.id)
    end
  else
    $moveQueue = path($game.char, n, r)
    puts "Going to [NPC] [#{n.id}] #{n.name}: #{$moveQueue.size} steps"
  end
  
  true
end

def handle_loot(corpseID, items)
  puts "Corpse items: " + items.map { |i| i.name + (i.stackable? ? " [S]" : "")}.join(", ") if $config.showCorpseItems
    
  items.each do |item|
    questItem = $game.quests.values.any? { |q| q.need?(item.name) }
    willStack = $game.char.bagged.any? { |i| i.name == item.name && i.able_to_stack? }
    
    next if $game.char.bagged.size >= 16 && !willStack
    next if ($config.lootOnlyStackable && !item.stackable?) && !questItem
    
    puts " - loot: #{item.name} @ slot: #{item.slot} @ corpse: #{corpseID}"
    
    $game.char.cmdLoot(corpseID, item.slot)
  end
end

def handle_buffs
  return if $game.spellBook.empty? || $game.char.casting? || $game.char.buffs.size >= 5 || !$castQueue.empty?
  
  freeSlots = 5 - $game.char.buffs.size
  
  {"Rage" => 1, "l33t Skillz" => 1, "Nerd Rage" => 3, "Thick Skin" => 1, "Like a Rock" => 1, "Self-Motivated" => 2}.each do |buffName, count|
    $game.spellBook.values.select { |s| s.item.name == buffName && s.castable? }.sort_by { |s| s.item.rank }.reverse.first(count).each do |s|
      next if freeSlots <= 0 || $game.char.buffs[s.id]
      
      $castQueue << s
      freeSlots -= 1
    end
  end
end

puts "Initialial delay for #{$config.initialDelay} seconds".color(:red)
sleep($config.initialDelay)

loop {
  Thread.pass
  sleep(0.5)
  
  begin
    if consoleCommand = STDIN.read_nonblock(1024)
      consoleCommand.strip!
      next if consoleCommand.empty?
      
      handlePacket(Messages::Chat::Private, [
        0,
        "consoleCommand",
        consoleCommand
      ])
    end
  rescue Errno::EINTR, Errno::EAGAIN, EOFError
    # pass
  end
  
  $game.characters.values.each(&:update)
  $game.mobs.values.each(&:update)
  
  next if !$canStart || !$loggedIn || !$game.char || $game.char.moving? || $game.char.attacking? || $game.char.casting? || $game.char.dead?
  
  $game.char.stopAttacking if $game.char.attacking? && $game.char.distanceHypot($game.char.attacker) > 96
  
  if $game.char.alive? && !$moveQueue.empty?
    next unless p = $moveQueue.shift
    
    (print "    #{p}\n") if $config.showPathfindingSteps
    $game.char.cmdMove(p)
    next
  end
  
  if $game.char.alive? && !$castQueue.empty? && $game.char.mana > $castQueue.first.item.manaCost
    s = $castQueue.shift
    $game.char.cmdCast(s.id, $game.char.id, $game.char.type)
    sleep(s.cooldownLength || 2.0)
    next
  end
  
  next if handle_quests
  
  handle_buffs
  
  if $canStart && $game.char.health >= $game.char.maxHealth - 1
    #corpse = $game.corpses.values.select { |c| $game.char.distanceHypot(c) <= 500 && !c.skip? }.shift
    if $game.corpses[oldMobID]
      corpse = $game.corpses[oldMobID]
      
      sendMessage("lr", corpse.id)
      #puts "Looting [%d] %s..." % [corpse.id, corpse.name]
    end
    
    mobs = []
    if $config.questMobsPrimary && $game.quests.size > 0
      $game.quests.values.select { |q| q.objectives? && !q.done? }.each do |q|
        mobs += (x = $game.mobs.values.select { |m| !m.moving? && !m.skip? && q.mobs.include?(m.name) })
      end
      
      mobs = mobs.select { |m| !m.moving? && !m.skip? && m.level - $game.char.level <= 2}.sort_by { |m| $game.char.distanceHypot(m) }.sort_by { |m| m.level }
      
      if !mobs.empty? && mobs.first.distanceHypot($game.char) > 300
        $moveQueue = path($game.char, mobs.first, 2)
        
        if $moveQueue.size > 0
          puts "Moving to QUEST mob: #{mobs.first.name}, #{$moveQueue.size} cells away"
          next
        end
      end
    end
    
    if mobs.empty?
      mobs = $game.mobs.values.select { |m| !m.moving? && !m.skip? && m.level - $game.char.level <= 0 && !$config.farmingIgnoreMobs.include?(m.name) }.sort_by { |m| $game.char.distanceHypot(m) }.uniq { |m| m.name }.first(3).sort_by { |m| path($game.char, m).size }
      
      if !mobs.empty? && $game.char.distanceHypot(mobs.first) > 300
        $moveQueue = path($game.char, mobs.first, 2)
        
        if $moveQueue.size > 0
          puts "Moving to FARM mob: #{mobs.first.name}, #{$moveQueue.size} cells away"
          next
        end
      end
    end
    
    unless mobs.empty?
      mob = mobs.first
      
      oldMobID = mob.id
      $game.char.cmdAttack(mob.id, mob.type)

      puts "[%s] Attacking [%d] %s (%d)..." % [short_time, mob.id, mob.name, mob.level]
    end
  end
}
