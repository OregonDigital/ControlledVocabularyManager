require 'rails_helper'

RSpec.describe ControlledVocabulary do
  it "should be an AT::Resource" do
    expect(ControlledVocabulary < ActiveTriples::Resource).to be true
  end
  it "should instantiate" do
    expect{ControlledVocabulary.new}.not_to raise_error
  end
end
