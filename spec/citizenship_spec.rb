require 'spec_helper'

require_relative '../lib/plugins/check_citizen.rb'

describe CheckCitizenship do
  let(:bot) { double('bot').as_null_object }
  let(:citizenship) { CheckCitizenship.new(bot) }
  let(:m) { build(:nickserv_message) }
  let(:users) { build_list(:cinch_user, 3) }
  let(:user_list) { users.inject({}) {|a,e| a.merge!(e.nick => e)} }

  it "can be instantiated given a bot exists" do
    allow_any_instance_of(Cinch::Plugins).to receive(:__register_matchers).and_return(true)
    expect(citizenship).to be_a CheckCitizenship
  end

  context "#citizens" do
    it "can properly report on users in channel" do
      expect_any_instance_of(Cinch::Helpers).to receive_message_chain(:Channel, :users, :keys).and_return(user_list)
      expect(user_list).to receive(:inject).and_return(users)
      expect(m).to receive(:reply).with("Total of 3 citizens")
      citizenship.citizens(m)
    end
  end

  context "#capture_nickserv" do
    it "ignores anything not from nickserv" do
      expect(citizenship).to receive(:nickserv?).and_return(false)
      expect(citizenship.capture_nickserv(m)).to eq(nil)
    end

    it "calculates registered week from nickserv responses" do
      expect(citizenship).to receive(:nickserv?).and_return(true)
      expect_any_instance_of(Cinch::Helpers).to receive_message_chain(:Channel, :send)
      citizenship.capture_nickserv(m)
    end
  end
end
