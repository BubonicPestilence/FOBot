#!/usr/local/rvm/ruby

module Messages
  module Broker
    BOSearchResult = "bbr"
    ItemListed = "bil"
    Listing = "bbo"
    Open = "obr"
    SearchNoResult = "bnr"
    SearchResult = "bsr"
    BOSearchNoResult = "bbn"
  end
  
  module Casting
    Cast = "cst"
    Interrupted = "ci"
  end
  
  module Chat
    Admin = "adm"
    Guild = "gcc"
    Party = "pcd"
    Private = "pcm"
    PrivateToSelf = "pcs"
    Zone = "zc"
  end
  
  module Extra
    EnterZone = "ez"
    FriendListUpdate = "flu"
    GuildMemberList = "gml"
    IgnoreListUpdate = "ilu"
  end
  
  module Facebook
    InviteDialog = "fid"
  end
  
  module Game
    KongregateUpdateBadgeQuests = "kba"
    GemShopGemShopData = "gsd"
    GiftWindowGiftsData = "lgf"
    WelcomeDailyFreeItem = "dfi"
  end
  
  module Group
    Invite = "jpr"
    AlreadyInGroup = "jpr"
    CantLootThatCorpse = "ler"
    Full = "jpf"
    LevelToHigh = "glh"
    Request = "jgr"
    RequestFailed = "jgf"
    StateUpdate = "gst"
    KickFromGroup = "kfg"
    ToggleParty = "tpr"
  end
  
  module Guild
    AlreadyInAGuild = "aig"
    BadGuildName = "bgn"
    BonusData = "gbd"
    CreateOpen = "gco"
    Data = "gds"
    Demoted = "gdp"
    Donation = "gdo"
    Invite = "gip"
    Invited = "gid"
    IsFull = "gif"
    Joined = "gjd"
    Kicked = "gkc"
    Listings = "gls"
    ListingsOpen = "glo"
    Offline = "gof"
    Online = "gon"
    Pending = "gpr"
    Promoted = "gpp"
    NotEnoughGuildPoints = "ngp"
    TopGuild = "glb"
  end
  
  module GuildWarfare
    Busy = "gwb"
    QuadActions = "qac"
    QuadBusy = "gqb"
    QuadData = "qdr"
    ZoneData = "gwz"
    ZoneDominated = "gzd"
    ZoneLost = "gzl"
  end
  
  module Inv
    AddToInventory = "inv"
    GetInventory = "inv"
    CollectorDepositItem = "cid"
    CollectorItemNotFound = "cin"
    CollectorSearchNoResult = "cns"
    CollectorSearchResult = "csn"
    FacebookTreasure = "fbt"
    Inventory = "invt"
    InventoryFull = "yif"
    InventoryServerReply = "idu"
    ItemDelete = "id"
    Loot = "lt"
    NotEnoughCoins = "nec"
    NotEnoughGems = "neg"
    OpenCollection = "oco"
    OpenCollectorAccount = "oca"
    OpenShop = "ops"
    PopulateShop = "shp"
    RemoveLoot = "rl"
    SlotChangeServer = "scs"
    SpellBook = "spbk"
    StackUpdate = "stk"
  end
  
  module Mail
    Contents = "mcc"
    Headers = "mhh"
  end
  
  module Market
    LevelToList = "ltl"
    ItemBought = "mnm"
    ItemListed = "mil"
    Listing = "mli"
    NoQuestItems = "mnq"
    Open = "moo"
    SearchNoResult = "msn"
    SearchResult = "msr"
    TooManyListings = "mtm"
    TooManyListingsDaily = "tld"
  end
  
  module Mob
    CorpseRot = "cr"
    Data = "md"
    MoveStart = "mms"
    Spawn = "ms"
    AttackData = "mad"
    DeadTurnToCorpse = "smd"
    StopAllAttackingMonster = "saa"
    StopMobAttack = "smma"
  end
  
  module NPC
    Request = "ndr"
    BlacksmithShopOpen = "bso"
    CraftingRecipeContents = "crc"
    CraftingRecipeHeaders = "crh"
    Spawn = "npc"
    NotEnoughResources = "ner"
    OpenBank = "obb"
    OpenBankAccount = "oba"
    OpenCosmeticSurgery = "cso"
    OpenGuildWarfareWindow = "ogw"
    PremOpenCosmeticSurgery = "opc"
    QuestAccept = "qa"
    QuestComplete = "qc"
    QuestData = "qd"
    QuestDone = "qdn"
    QuestDoneMessage = "qdz"
    QuestListItem = "qli"
    QuestLogUpdate = "qlu"
    Rebirth2Start = "sr2"
    RebirthStart = "srb"
    ShowDialog = "dia"
  end
  
  module UJ
    Err = "er"
    Err2 = "err"
    Gold = "gld"
    Yc = "yc"
    Yst = "yst"
  end
  
  module User
    AchievementData = "aad"
    AddBuff = "ab"
    AddDBuff = "adb"
    RemoveActiveBuff = "rab"
    AllFactionNotoriety = "afn"
    AlreadyHaveSpell = "ahs"
    BuffsFull = "buf"
    DailyXPToggle = "dxt"
    Dead = "ded"
    DisplayUpdate = "ud"
    EquipAWeapon = "eqw"
    FriendComeOnline = "fco"
    FriendGoOffline = "fgo"
    FullStatUpdate = "stu"
    LevelUpdate = "lvu"
    LockPickRequired = "lpr"
    MapUnlocked = "map"
    MoveEnd = "mve"
    MoveFirst = "mvf"
    MoveStart = "mvs"
    MustBeAttacking = "mba"
    MustBeInGuild = "mbg"
    NecessaryBuffNotRunning = "nbn"
    NewFactionNotoriety = "nrc"
    NoCastingWithTools = "ncg"
    NoGroupWhileFighting = "ngf"
    NoStatPoints = "nsp"
    NotEnoughEnergy = "nee"
    NotEnoughNotoriety = "nen"
    NotEnoughStats = "nes"
    NotHighEnoughLevel = "nhl"
    NotHighEnoughRebirth = "nrh"
    NumQuestsCompleted = "nqc"
    OnlyOnePet = "oop"
    QuestAccepted = "qa"
    RemoveBuff = "rb"
    RemoveDBuff = "rdb"
    Rested = "rst"
    Resurrect = "rez"
    StartMobAttack = "sma"
    StartWarp = "stw"
    Tired = "trd"
    ToTiredToAttack = "tta"
    TooManyBuffs = "tmb"
    TopPlayer = "pld"
    UnlockAchievement = "aul"
    UnlockZoneRequest = "uzr"
    Data = "pd"
    HealthUpdate = "uad"
    Join = "uj"
    Lost = "ul"
    ManaUpdate = "uam"
    StatUpdate = "us"
    Warp = "plw"
    XP = "xp"
    ClockTick = "clt"
  end
  
  module PvP
    XP = "pxp"
  end
  
  MultiLine = [
    Broker::BOSearchNoResult, Broker::BOSearchResult, Broker::ItemListed, Broker::Listing, Broker::Open, Broker::SearchNoResult, Broker::SearchResult,
    Casting::Cast, Casting::Interrupted, Facebook::InviteDialog, Game::KongregateUpdateBadgeQuests, Mail::Contents, 
    Group::AlreadyInGroup, Group::CantLootThatCorpse, Group::Full, Group::Request, Group::RequestFailed, Group::ToggleParty, Group::StateUpdate,
    Guild::BonusData, Guild::Data, Guild::Demoted, Guild::Donation, Guild::Invite, Guild::IsFull, Guild::Joined, Guild::Kicked, Guild::Listings, Guild::ListingsOpen, Guild::Offline, Guild::Online, Guild::Promoted, Guild::TopGuild,
    GuildWarfare::Busy, GuildWarfare::QuadActions, GuildWarfare::QuadBusy, GuildWarfare::QuadData, GuildWarfare::ZoneData, GuildWarfare::ZoneDominated, GuildWarfare::ZoneLost,
    Inv::CollectorDepositItem, Inv::CollectorItemNotFound, Inv::CollectorSearchNoResult, Inv::CollectorSearchResult, Inv::FacebookTreasure, Inv::Inventory, Inv::ItemDelete, Inv::RemoveLoot, Inv::SlotChangeServer, Inv::StackUpdate, Inv::SpellBook, Inv::Loot,
    Market::ItemBought, Market::ItemListed, Market::Listing, Market::NoQuestItems, Market::Open, Market::SearchNoResult, Market::SearchResult, Market::TooManyListings,
    Mob::AttackData, Mob::CorpseRot, Mob::DeadTurnToCorpse, Mob::Data, Mob::MoveStart, Mob::Spawn, Mob::StopAllAttackingMonster, Mob::StopMobAttack,
    NPC::BlacksmithShopOpen, NPC::CraftingRecipeContents, NPC::Spawn, NPC::NotEnoughResources, NPC::QuestListItem, NPC::QuestLogUpdate,
    UJ::Err, UJ::Err2, UJ::Gold, UJ::Yc, UJ::Yst,
    User::AchievementData, User::AddBuff, User::AddDBuff, User::AllFactionNotoriety, User::BuffsFull, User::DailyXPToggle, User::Data, User::Dead, User::DisplayUpdate, User::FriendComeOnline, Extra::FriendListUpdate,
    User::FriendGoOffline, User::FullStatUpdate, User::HealthUpdate, User::Join, User::LevelUpdate, User::Lost, User::ManaUpdate, User::MoveEnd, User::MoveFirst, User::MoveStart,
    User::MustBeInGuild, User::NecessaryBuffNotRunning, User::NewFactionNotoriety, User::NoGroupWhileFighting, User::NotEnoughNotoriety, User::NotHighEnoughLevel, User::NotHighEnoughRebirth,
    User::OnlyOnePet, User::RemoveBuff, User::RemoveDBuff, User::Resurrect, User::StartMobAttack, User::StartWarp, User::StatUpdate, User::TopPlayer, User::UnlockAchievement, User::XP,
    User::ClockTick,
    PvP::XP,
  ]
  
  module ClassMethods
    def find_by_id(id)
      self.constants.each do |c|
        next if c == :MultiLine
        
        (m = self.const_get(c)).constants.each do |cc|
          v = m.const_get(cc)
          
          if v == id
            return "#{m}::#{cc}"
          end
        end
      end
      
      false
    end
  end
  
  extend ClassMethods
end
