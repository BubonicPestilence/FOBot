def handlePacket(type, data)
  klassName = type if (klassName = Messages.find_by_id(type)).nil?
  
  begin
    klass = "[%s] %s %9s %7s" % [short_time, klassName.ljust(48), Messages::MultiLine.include?(type) ? "(multi)" : "", "(#{type})"]
  rescue
    puts type
  end
  
  case type
  when Messages::User::Join
    data.each do |d|
      charID = d[0].to_i
      next if $game.characters[charID]
      
      char = Character.new(id: charID, name: d[1], level: d[5].to_i, originX: d[2].to_i, originY: d[3].to_i, display: d[4], pvpFlag: d[6] == "true", rebirth: d[8], pet: d[7])
      
      $game.char = char if $game.char.nil?
      $game.characters[charID] = char
      $game.charactersByName[char.name] = char
    end
  when Messages::User::Lost
    data.each do |d|
      charID = d[0].to_i
      next unless $game.characters[charID]
      
      char = $game.characters[charID]
      
      $game.characters.delete(charID)
      $game.charactersByName.delete(char.name)
    end
  when Messages::Extra::EnterZone
    $game.mobs = {}
    $game.corpses = {}
    $game.npcs = {}
    
    $game.zone.tap do |z|
      z.name = data[0]
      z.xOffset = data[1].to_i
      z.yOffset = data[2].to_i
      z.id = data[4].to_i
      z.mapUnlocked = data[3] != "null"
    end
    
    sendMessage(Messages::Inv::GetInventory)
    sendMessage("gsb") # ???
    sendMessage("gql") # GetQuestList?
    #sendMessage("lgs") # LoadGemShop
    #sendMessage("gac") # Load Achievements
    sendMessage("gzn") # GetZoneNPCs
    sendMessage("gzm") # GetZoneMobs
    
    puts "Current zone: #{$game.zone.name}"
    
    $loggedIn = true
  when Messages::Chat::Zone
    puts ("[CHAT] " + data.join(": ")).color(:yellow)
  when Messages::Chat::Guild
    puts ("[GUILD] " + data.join(": ")).color(:green)
  when Messages::Chat::Guild
    puts ("[PARTY] " + data.join(": ")).color(:green)
  when Messages::Chat::Private
    message = case data[0].to_i
    when 0 # we're receiving
      "[PM] %s whispers: %s"
    when 1 # we're sending
      "[PM] To %s: %s"
    end
    
    handleConsoleMessage(data)
    
    data.push("") if data.size != 3
    
    puts (message % data[1..2]).color(:magenta)
  when Messages::User::XP
    data.each do |d|
      oldXP = $game.char.xp
      $game.char.xp, $game.char.toLevelXP, currentRest, maxRest, timeToRest = d.map(&:to_i)
      
      out = "[EXP] [+%d] %d / %d (%.2f%%) (+%.2f%%)" % [$game.char.xp - oldXP, $game.char.xp, $game.char.toLevelXP, ($game.char.xp.to_f / $game.char.toLevelXP.to_f) * 100.0, ($game.char.xp - oldXP) / ($game.char.toLevelXP.to_f / 100.0)]
      if maxRest > 0
        out += " [REST] %d / %d (%.2f) (%d)" % [currentRest, maxRest, (currentRest.to_f / maxRest.to_f) * 100.0, timeToRest]
      end
      
      puts out.color(:yellow)
    end
  when Messages::UJ::Gold
    data.each do |d|
      gold, newGold = d.map(&:to_i)
      $game.char.gold = gold
      
      newGold = "+#{newGold}" if newGold > 0
      out = "[GOLD] [%s] %d" % [newGold.to_s, gold]

      puts out.color(:yellow)
    end
  when Messages::Extra::FriendListUpdate
    data.each do |d|
      friendName, online, server = d
      $game.friends[friendName] = [online.to_i, server.to_i]
    end
  when Messages::Extra::IgnoreListUpdate
    data.each do |d|
      $game.ignores << d
    end
  when Messages::User::StatUpdate
    data.each do |d|
      next unless $game.char
      
      $game.char.tap do |s|
        s.maxHealth, s.health, s.maxMana, s.mana = d.map(&:to_i)
      end
    end
  when Messages::User::FullStatUpdate
    return unless $game.char
    
    data.each do |d|
      $game.char.stats.tap do |s|
        s.stamina, s.strength, s.agility, s.intellect = d[0..3].map(&:to_i)
        s.coins, s.statPoints, s.gems = d[12..14].map(&:to_i)
        s.luck = d[16].to_i
      end
    end
  when Messages::User::DisplayUpdate
    data.each do |d|
      charID = d[0].to_i
      next unless $game.characters[charID]

      $game.characters[charID].display.tap do |disp|
        disp.skin = d[1]
        disp.scaleX = d[2].to_f
        disp.scaleY = d[2].to_f
        disp.pet = d[3]
      end
    end
  when Messages::User::LevelUpdate
    data.each do |d|
      charID = d[0].to_i
      return unless $game.characters[charID]
    
      $game.characters[charID].level = d[1].to_i
    end
  when Messages::User::FriendComeOnline
    data.each do |d|
      puts "[%7d] %s online %d" % d
    end if $config.showFriends
  when Messages::User::FriendGoOffline
    data.each do |d|
      puts "[%7d] %s offline" % d
    end if $config.showFriends
  when Messages::User::MoveFirst
    data.each do |d|
      charID = d[0].to_i
      next unless $game.characters[charID]
      
      $game.characters[charID].tap do |c|
        c.originX = d[1].to_i
        c.originY = d[2].to_i
        
        if charID == $game.char.id
          # send speak with npc packet
          pp type, d
          exit
          
          # Game.sendMsg(Game.NPCRequest, 1);
          # Game.m_actionBar.bagClicked(Bag(Game.m_actionBar.m_mainBag.m_item));
        end
      end
    end
  when Messages::User::MoveStart
    data.each do |d|
      charID = d[0].to_i
      next unless char = $game.characters[charID]
      
      char.moveStart(d[2].to_i, d[3].to_i, d[4].to_f)
    end
  when Messages::User::Warp
    charID = data[0].to_i
    return unless $game.characters[charID]
    
    $game.characters[charID].tap do |c|
      c.moveEnd(data[1].to_i, data[2].to_i)
    end
  when Messages::User::HealthUpdate
    data.each do |d|
      charID = d[0].to_i
      next unless $game.characters[charID]
      
      $game.characters[charID].tap do |c|
        c.currentHealth(d[2].to_i, d[3].to_i)
        c.damage(d[1].to_i)
        
        putsf("Char HP: %d / %d; Damage: %d", d[2].to_i, d[3].to_i, d[1].to_i) if c == $game.char
      end
    end
  when Messages::User::ManaUpdate
    data.each do |d|
      charID = d[0].to_i
      next unless $game.characters[charID]

      $game.characters[charID].tap do |c|
        c.currentMana(d[2].to_i, d[3].to_i)
        c.damageMana(d[1].to_i)
      end
    end
  when Messages::User::StartMobAttack
    data.each do |d|
      charID, mobID = d.map(&:to_i)
      next unless char = $game.characters[charID]
      next unless mob = $game.mobs[mobID]
      
      char.attack(mob)
      
      if charID == $game.char.id
        "Got attacking packet with src as us"
      end
    end
  when Messages::Mob::Spawn
    data.each do |d|
      next if d.length < 8
      
      mobID = d[0].to_i
      $game.mobs.delete(mobID) if $game.mobs[mobID]
      
      mob = Mob.new(type: 1, id: mobID, name: d[1], level: d[3].to_i, originX: d[7].to_i, originY: d[8].to_i, subType: d[5].to_i, zone: d[6].to_i, display: d[2])
      $game.mobs[mobID] = mob
    end
  when Messages::Mob::CorpseRot
    data.each do |d|
      corpseID = d[0].to_i
      return unless $game.corpses[corpseID]
      
      $game.corpses.delete(corpseID)
    end
  when Messages::Mob::MoveStart
    data.each do |d|
      mobID = d[0].to_i
      next unless mob = $game.mobs[mobID]
      
      $game.mobs[mobID].moveStart(d[2].to_i, d[3].to_i, d[4].to_f)
    end
  when Messages::Mob::AttackData
    data.each do |d|
      next unless mob = $game.mobs[d[0].to_i]

      mob.currentHealth(d[2].to_i)
      mob.damage(d[1].to_i)
      
      putsf("Mob HP: %d; Damage: %d", d[2].to_i, d[1].to_i) if $game.char.attacking? && $game.char.attacker == mob
    end
  when Messages::Mob::DeadTurnToCorpse
    data.each do |d|
      mobID = d[0].to_i
      next unless mob = $game.mobs[mobID]
      
      $game.mobs.delete(mobID)
      
      $game.characters.each do |k, c|
        c.stopAttacking if c.attacking?(mob)
      end
      
      mob.type = 2
      mob.die
      mob.moveEnd
      
      $game.corpses[mobID] = mob
    end
  when Messages::Mob::StopMobAttack
    data.each do |d|
      mobID = d[0].to_i
      next unless mob = $game.mobs[mobID]
      
      mob.stopAttacking
    end
  when Messages::Mob::StopAllAttackingMonster
    data.each do |d|
      mobID = d[0].to_i
      next unless mob = $game.mobs[mobID] || $game.char
      next unless $game.char.attacking?(mob)
      
      $game.char.cmdAttack(0, -1);
    end
  when Messages::NPC::Spawn
    puts "NPCSpawn can be wrong".color(:red)
    
    data.each do |d|
      npcID = d[0].to_i
      
      npc = NPC.new(type: 3, id: npcID, name: d[1], level: d[13].to_i, originX: d[4].to_i, originY: d[5].to_i, extra: d[10].to_i, zone: d[11].to_i, display: d[3].to_i, state: d[12].to_i)
      $game.npcs[npcID] = npc
    end
  when Messages::User::Dead
    data.each do |d|
      charID = d[0].to_i
      next unless $game.characters[charID]
      
      $game.characters[charID].die
      
      puts "[#{short_time}] Died".color(:red) if charID == $game.char.id
    end
  when Messages::User::Resurrect
    data.each do |d|
      charID = d[0].to_i
      next unless $game.characters[charID]
      
      $game.characters[charID].resurrect
      
      puts "[#{short_time}] Resurrected".color(:green) if charID == $game.char.id
    end
  when Messages::Group::Request
    data.each do |d|
      requestID = d[0].to_i
      charName = d[1]
      
      sendMessage("jgr", requestID, false)
    end
  when Messages::Group::StateUpdate
    data.each do |d|
      next if d.empty?
      
      tmp = OpenStruct.new
      
      tmp.id = d[1].to_i
      tmp.maxHealth, tmp.health, tmp.maxMana, tmp.mana, tmp.level = d[3..7].map(&:to_i)
      
      $game.group[tmp.id] = tmp
    end
  when Messages::Group::KickFromGroup
    $game.group = {}
  when Messages::Group::CantLootThatCorpse
    data.each do |d|
      corpseID = d[0].to_i
      return unless $game.corpses[corpseID]
      
      $game.corpses.delete(corpseID)
    end
  when Messages::Inv::SpellBook
    data.each do |d|
      spell = Spell.from_array(d)
      $game.spellBook[spell.id] = spell
    end
  when Messages::NPC::ShowDialog
    dialogID, dialogMessage = data[0].to_i, data[1]
  when Messages::NPC::QuestData
    questID, npcID, npcName, title, summary, description, rewardGold = data[0].to_i, data[7].to_i, data[5], data[1], data[3], data[4], data[6].to_i
    sendMessage(Messages::NPC::QuestAccept, questID, npcID)
  when Messages::User::QuestAccepted
    puts "Quest Accepted"
  when Messages::NPC::QuestListItem
    data.each do |d|
      next if d.empty?
      
      questID = d[0].to_i
      quest = Quest.new(id: questID, npcID: d[7].to_i, npcName: d[5], title: d[1], summary: d[3], progress: d[8], description: d[4], rewardGold: d[6].to_i)
      $game.quests[questID] = quest
      
      $game.npcs[quest.npcID].state = 1 if $game.npcs[quest.npcID]
    end
  when Messages::NPC::QuestLogUpdate
    data.each do |d|
      questID, npcID, progress, npcState = d[0].to_i, d[1].to_i, d[2], d[3].to_i
      next unless $game.quests[questID]
      
      $game.npcs[npcID].state = npcState if $game.npcs[npcID]
      $game.quests[questID].progress = progress
    end
  when Messages::NPC::QuestDone
    puts "Quest Done! (short)"
    
    questID, npcID, tmp = data.map(&:to_i)
    npcState = (tmp == -1 ? 3 : 0)
    
    if n = $game.npcs[npcID]
      n.state = npcState
    end
    
    $game.quests.delete(questID)
  when Messages::NPC::QuestDoneMessage
    puts "Quest done!".color(:green)
  when Messages::Game::KongregateUpdateBadgeQuests
    # pass
  when Messages::User::NumQuestsCompleted
    $game.questsDone = data[0].to_i
    puts "Quests done: %d" % [$game.questsDone]
  when Messages::GuildWarfare::ZoneDominated
    data.each do |d|
      puts "%s dominated by %s" % d
    end
  when Messages::Casting::Cast
    data.each do |d|
      charID = d[0].to_i
      spellID = d[3].to_i
      
      next unless $game.characters[charID]
      
      spellName = d[1]
      castTime = d[2].to_f
      
      $game.characters[charID].cast_start(castTime)
      puts ("[CAST] %s: %s (%.2fs)" % [$game.characters[charID].name, spellName, castTime]).color(:blue)
    end
  when Messages::User::AddBuff
    data.each do |d|
      buff = OpenStruct.new(
        id: d[0].to_i,
        name: d[2],
        duration: (d[1].to_f / 1000),
        grade: d[3].to_i,
        tick: d[4].to_i,
        startTime: (d[5].to_f / 1000)
      )
      
      buff.startTime = Time.now.to_f if buff.startTime == 0.0
      buff.timeLeft = buff.duration - (Time.now.to_f - buff.startTime)
      
      $game.char.buffs[buff.id] = buff
      
      puts ("[BUFF] + %s #%d (%.3f)" % [buff.name, buff.grade, buff.timeLeft]).color(:green)
    end
  when Messages::User::RemoveBuff
    data.each do |d|
      id = d[0].to_i
      next unless $game.char && buff = $game.char.buffs.delete(id)
      
      puts ("[BUFF] - %s #%d" % [buff.name, buff.grade]).color(:red)
    end
  when Messages::User::Data
    pp data
    exit
  when Messages::Inv::Inventory
    data.each do |d|
      item = Item.from_array(d)
      $game.char.inventory[item.id] = item
    end
  when Messages::Inv::Loot
    corpseID = nil
    items = []
    
    data.each do |d|
      (corpseID = d[0].to_i; next) if d.size == 1
      
      items << (item = Item.from_array(d))
    end
    
    handle_loot(corpseID, items) if corpseID
  when Messages::Inv::StackUpdate
    data.each do |d|
      itemID = d[0].to_i
      next unless item = $game.char.inventory[itemID]
      
      item.stack = d[1].to_i
    end
  when Messages::Inv::AddToInventory, Messages::Inv::RemoveLoot, Messages::Inv::InventoryServerReply, Messages::Inv::InventoryFull
    puts klass.color(:red)
  when Messages::User::NewFactionNotoriety
    data.each do |d|
      factionID, value = d.map(&:to_i)
      puts "Faction change: #{factionID} by #{value}"
    end
  when Messages::User::AllFactionNotoriety
    data.each do |d|
      a, b = d
      $game.notoriety[a.to_i] = b.to_i
    end
  when Messages::PvP::XP
    puts klass.color(:red)
  when Messages::User::ClockTick
    # pass, server time :D
  else
    begin
      puts klass.color("666666")
      pp data
    rescue
      puts "CANT OUTPUT DEFAULT MESSAGE"
      pp [type, data]
    end
  end
end

def handleConsoleMessage(data)
  case data[2]
  when "q", "quit", "exit"
    exit
  when "loc"
    putsf("Current Location: %d %d", $game.char.x, $game.char.y)
  when /(x|y) (-?\d+)/
    x = $1 == "x" ? $2.to_i : 0
    y = $1 == "y" ? $2.to_i : 0
    
    puts "#{x} #{y}"
    
    putsf("From: %d %d", $game.char.x, $game.char.y)
    
    $game.char.cmdMove(x, y)
  when "start", "stop"
    $canStart = data[2] == "start"
  when "server"
    puts "Current server: FO0#{$config.server}"
  when "char"
    pp $game.char
  when "spellbook"
    pp $game.spellBook
  when "buffs"
    pp $game.char.buffs
  when "chars"
    $game.characters.values.sort_by { |e| e.name.downcase }.each { |c| puts c }
  when /chars (\d+)/
    radius = $1.to_i
    radius = 128 if radius < 1 || radius > 128
    
    c = $game.char.to_c
    
    minMax = [
      c.x - radius * 32,
      c.x + radius * 32,
      c.y - radius * 32,
      c.y + radius * 32,
    ]
    
    puts "Chars inside #{radius} radius:"
    $game.characters.values.select { |c| minMax[0] <= c.x && minMax[1] >= c.x && minMax[2] <= c.y && minMax[3] >= c.y }.sort_by { |e| e.name.downcase }.each { |c| puts c }
  when "mobs"
    $game.mobs.values.sort_by { |e| e.name.downcase }.each { |m| puts m }
  when /mobs (.+)/
    $game.mobs.values.select { |e| e.name.include?($1) }.each { |m| puts m }
  when "corpses"
    $game.corpses.values.sort_by { |e| e.name.downcase }.each { |c| puts c }
  when "npcs"
    $game.npcs.values.sort_by { |e| e.name.downcase }.each { |n| puts n }
  when "quests"
    $game.quests.values.each { |q| puts q }
  when "quest mobs"
    $game.quests.each do |questID, q|
      next unless q.objectives?
      
      if mob = $game.mobs.values.find { |m| q.objectives[m.name] }
        pp mob
      end
    end
  when "mobs range"
    $game.mobs.each { |k, v| puts "%.4f" % $game.char.distanceHypot(v) }
  when "equipped items"
    $game.char.equiped.each { |item| puts item }
  when "bag items"
    $game.char.bagged.each { |item| puts item }
  when "quantities of bag items"
    $game.char.bagged.each do |item|
      puts "[%d] %d x %s" % [item.id, item.stack, item.name]
    end
  when "bank items"
    puts $game.char.banked
  when /^inv$/
    return unless $game.charactersByName[data[1]]
    
    sendMessage(Messages::Group::Invite, $game.charactersByName[data[1]].id)
  when /inv (\S+)/
    (puts "Character #{$1} not found"; return) unless $game.charactersByName[$1]
    sendMessage(Messages::Group::Invite, $game.charactersByName[$1].id)
  when /c (.+)/
    sendMessage("zcm", $1)
  end
end