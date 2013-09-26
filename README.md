# FOBot

Fantasy MMORPG Bot :)

# Requirements

1. Ruby 1.9+
2. `gem install rainbow ostruct stringio`
3. `gem install yaml json digest active_support httparty nokogiri`

# Configuration

1. Copy `config.sample.rb` to `config.rb` and update it:
    ```ruby
    characters: {
      "CharName1" => {
        disabled: false,
        
        # hash speed up process of authentication
        # if you provide here hash after initial auth
        hash: nil,
        
        # password from ingame email
        password: "wfdt3v5p",
        
        # force server (input 1 for "FO01" == "Server #2")
        # nil == random
        server: nil, 
      },
      
      "CharName2" => {
        disabled: false,
        hash: nil,
        password: "wfdt3v5p",
        server: nil,
      },
      
      "CharName3" => {
        disabled: false,
        hash: nil,
        password: "wfdt3v5p",
        server: nil,
      },
    },
    ```

2. Launch as `./run.rb CharName1`

3. Profit! :D Bot is going to take & finish all quests in current zone and after that, unlimitedly farm mobs.