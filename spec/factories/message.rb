FactoryGirl.define do
  ##<Cinch::Message 
  # @raw=":NickServ!NickServ@services. NOTICE demobot :You are now identified for \u0002demobot\u0002." 
  # @params=["demobot", "You are now identified for \u0002demobot\u0002."] 
  # channel=nil 
  # user=#<User nick="nickserv">>
  factory :message, class: OpenStruct do
    raw "IRC formatted response string"
    params ["nickname", "IRC formatted response string"]
    channel nil
    user nil
  end

  #<Cinch::Message 
  # @raw=":NickServ!NickServ@services. NOTICE demobot :Registered : May 21 05:28:52 2013 (1 year, 15 weeks, 4 days, 17:08:43 ago)" 
  # @params=["demobot", "Registered : May 21 05:28:52 2013 (1 year, 15 weeks, 4 days, 17:08:43 ago)"] 
  # channel=nil 
  #user=#<User nick="nickserv">>
  factory :nickserv_message, parent: :message, class: OpenStruct do
    raw ":NickServ!NickServ@services. NOTICE demobot :Registered : May 21 05:28:52 2013 (1 year, 15 weeks, 4 days, 17:08:43 ago)" 
    params ["demobot", "Registered : May 21 05:28:52 2013 (1 year, 15 weeks, 4 days, 17:08:43 ago)"]
    channel { OpenStruct.new(name: "test") }
    user { OpenStruct.new(nick: "nickserv") }
  end
end