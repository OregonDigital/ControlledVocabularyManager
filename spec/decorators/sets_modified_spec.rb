require 'rails_helper'

RSpec.describe SetsModified do
  subject { SetsModified.new(term) }
  let(:term) { term_mock }

  before do
    stub_repository
    allow(term).to receive(:modified=)
    #allow(term).to receive(:persist!)
    allow(term).to receive(:attributes=)
    allow(term).to receive(:attributes)
    allow(term).to receive(:valid?).and_return(true)
  end

  describe "#set_modified" do
    context "when it's modified" do
      before do
        subject.set_modified #change to subject.save or ...?
      end
      it "should set modified to current day" do
        expect(term).to have_received(:modified=).with(RDF::Literal::Date.new(Time.now))
      end
    end
    context "when not valid" do
      before do
        allow(term).to receive(:valid?).and_return(false)
        subject.set_modified
      end
      it "should not set modified" do
        expect(term).not_to have_received(:modified=)
      end
    end
    context "when modified twice" do
      before do
        subject.set_modified
        subject.set_modified
      end
      it "should set modified twice" do
        expect(term).to have_received(:modified=).with(RDF::Literal::Date.new(Time.now)).exactly(2).times
      end
    end
  end
end
