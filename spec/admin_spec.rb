require 'spec_helper'

require_relative '../lib/plugins/admin.rb'

describe Admin do
  it "can be instantiated given a bot exists" do
    allow_any_instance_of(Cinch::Plugins).to receive(:__register_matchers).and_return(true)
    bot = double('bot').as_null_object

    admin = Admin.new(bot)
    expect(admin).to be_a Admin
  end
end
