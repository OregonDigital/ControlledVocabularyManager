require 'rails_helper'

RSpec.describe "marmotta functionality" do
  let(:repository) { term.send(:repository) }
  let(:term) { Term.new }
  let(:vocabulary) { Vocabulary.new }
  xit "should be able to clear triples" do
    term.persist!

    expect(repository.count).to eq 1
    vocabulary.persist!
    expect(repository.count).to eq 3
    repository.clear!

    expect(repository.count).to eq 0
  end
end
