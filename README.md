# FOBot

Fantasy MMORPG Bot :)

# Requirements
1. Ruby 1.9+
2. `gem install pp ap rainbow ostruct base64 stringio yaml json digest base64 active_support httparty nokogiri`

# Configuration
1. Copy `config.sample.rb` to `config.rb` and update it.

    characters: {
      "CharName1" => {
        disabled: false,
        hash: nil, # speed up process of authentication, if you provide here hash after initial auth
        password: "password from ingame email, like: wfdt3v5p",
        server: nil, # force server (input 1 for "FO01" == "Server #2")
      },
      
      "CharName2" => {
        disabled: false,
        hash: nil, # speed up process of authentication, if you provide here hash after initial auth
        password: "password from ingame email, like: wfdt3v5p",
        server: nil, # force server (input 3 for "FO03" == "Server #4")
      },
      
      "CharName3" => {
        disabled: false,
        hash: nil, # speed up process of authentication, if you provide here hash after initial auth
        password: "password from ingame email, like: wfdt3v5p",
        server: nil, # force server (input 5 for "FO05" == "Server #6")
      },
    },

2. Launch as `./run.rb CharName1`
3. Profit! :D Bot is going to take & finish all quests in current zone and after that, unlimitedly farm mobs.