# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DecoratingRepository do
  subject { DecoratingRepository.new(decorators, repository) }
  let(:decorators) { double("decorators") }
  let(:repository) { double("repository") }
  before do
    allow(repository).to receive(:find).and_return(term)
    allow(decorators).to receive(:new).with(anything) {|x| x }
  end

  describe ".find" do
    let(:id) { "test/1" }
    let(:term) { double("term") }
    let(:result) { subject.find(id) }
    before do
      result
    end
    it "should delegate to repository" do
      expect(repository).to have_received(:find).with(id)
    end
    it "should decorate it" do
      expect(decorators).to have_received(:new).with(term)
    end
  end
end
