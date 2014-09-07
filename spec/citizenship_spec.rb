require 'spec_helper'

require_relative '../lib/plugins/check_citizen.rb'

describe CheckCitizenship do
  let(:bot) { double('bot').as_null_object }

  it "can be instantiated given a bot exists" do
    allow_any_instance_of(Cinch::Plugins).to receive(:__register_matchers).and_return(true)
    citizenship = CheckCitizenship.new(bot)
    expect(citizenship).to be_a CheckCitizenship
  end

  it "can parse weeks from nickserv response" do
    citizenship = CheckCitizenship.new(bot)
    m = build(:nickserv_message)
    expect(m).to receive(:reply)
    citizenship.citizens(m)
  end
end
