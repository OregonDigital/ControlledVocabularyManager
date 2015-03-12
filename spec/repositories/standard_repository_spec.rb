require 'rails_helper'

RSpec.describe StandardRepository do
  subject { StandardRepository.new(decorators) }
  let(:decorators) { }
  describe "#new" do
    let(:result) { subject.new(id) }
    let(:id) { "vocab/1" }
    context "when given no decorators" do
      it "should be a term" do
        expect(result).to be_instance_of Term
      end
    end
  end
end
