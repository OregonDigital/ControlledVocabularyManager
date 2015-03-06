require 'rails_helper'

RSpec.describe SetsIssued do
  subject { SetsIssued.new(term) }
  let(:term) { term_mock }
  before do
    stub_repository
    allow(term).to receive(:issued=)
    allow(term).to receive(:persist!)
    allow(term).to receive(:valid?).and_return(true)
    allow(term).to receive(:new_record?).and_return(true)
  end

  describe "#persist!" do
    context "when it's persisted" do
      before do
        subject.persist!
      end
      it "should set issued to current day" do
        expect(term).to have_received(:issued=).with(RDF::Literal::Date.new(Time.now))
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
      it "should not set issued" do
        expect(term).not_to have_received(:issued=)
      end
    end
    context "when not a new record" do
      before do
        allow(term).to receive(:new_record?).and_return(false)
        subject.persist!
      end
      it "should not set issued" do
        expect(term).not_to have_received(:issued=)
      end
    end
  end
end
