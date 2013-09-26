$config = OpenStruct.new(
  vrc4: "G394ERG419",
  
  ip: "174.37.227.98",
  port: 443,
  server: nil,
  
  characters: {
    "InGameName" => {
      disabled: false,
      hash: nil,
      password: "password from ingame email, like: wfdt3v5p",
      server: nil,
    },
    
  },
  
  initialDelay: 1.0,
  
  autoStart: true,
  questMobsPrimary: true,
  lootOnlyStackable: true,
  
  showPathfinding: true,
  showPathfindingSteps: true,
  
  showFriends: false,
  showDamageHealth: false,
  showDamageMana: false,
  showCorpseItems: true,
  
  ignoreMobs: ["Anubis", "Badger King", "Cat", "Evil Snow Fan", "Early Holiday Present"], # This mobs won't be attacked by bot while doing farming or quests
  ignoreNPCs: [],
  
  # this mobs won't be attacked by bot ONLY WHEN DOING FARM (e.g. no quests)
  farmingIgnoreMobs: [
    "Badger Knight",
    "Badger Warrior",
    "Badger Archer",
    "Mossra",
    "Forest Spider",
    "Evil Snow Machinest ",
  ],
)