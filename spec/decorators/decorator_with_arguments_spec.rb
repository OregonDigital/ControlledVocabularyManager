# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DecoratorWithArguments do
  subject { DecoratorWithArguments.new(decorator, arg1) }
  let(:decorator) { double("decorator") }
  let(:arg1) { double("argument") }
  before do
    allow(decorator).to receive(:new)
  end
  describe "#new" do
    let(:object) { double("object") }
    before do
      subject.new(object)
    end
    it "should delegate down to the decorator" do
      expect(decorator).to have_received(:new).with(object, arg1)
    end
  end
end
