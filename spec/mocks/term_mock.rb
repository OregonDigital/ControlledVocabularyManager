module GlobalMocks
  extend RSpec::SharedContext
  let(:term_mock) do
    i = instance_double("TermWithChildren")
    allow(i).to receive(:persisted?).and_return(false)
    allow(i).to receive(:id).and_return("bla")
    i
  end
  let(:vocabulary_mock) do
    i = instance_double("Vocabulary")
    allow(i).to receive(:persisted?).and_return(false)
    allow(i).to receive(:id).and_return("vocab")
    i
  end
end
