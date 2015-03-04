require 'rails_helper'

RSpec.describe SetsModified do
  subject { SetsModified.new(term) }
  let(:term) { term_mock }
  before do
    stub_repository
    allow(term).to receive(:modified=)
    allow(term).to receive(:persist!)
    allow(term).to receive(:valid?).and_return(true)
  end

  describe "#persist!" do
    context "when it's persisted" do
      before do
        subject.persist!
      end
      it "should set modified to current day" do
        expect(term).to have_received(:modified=).with(RDF::Literal::Date.new(Time.now))
      end
      it "should persist" do
        expect(term).to have_received(:persist!)
      end
    end
    context "when not valid" do
      before do
        allow(term).to receive(:valid?).and_return(false)
        subject.persist!
      end
      it "should not set modified" do
        expect(term).not_to have_received(:modified=)
      end
    end
    context "when persisted twice" do
      before do
        subject.persist!
        subject.persist!
      end
      it "should set modified twice" do
        expect(term).to have_received(:modified=).with(RDF::Literal::Date.new(Time.now)).exactly(2).times
      end
    end
  end
end
