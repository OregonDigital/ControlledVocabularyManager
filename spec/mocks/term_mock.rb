module GlobalMocks
  extend RSpec::SharedContext
  let(:term_mock) do
    i = instance_double("Term")
    allow(i).to receive(:persisted?).and_return(false)
    allow(i).to receive(:id).and_return("test/bla")
    allow(i).to receive(:vocabulary?).and_return(false)
    i
  end
  let(:vocabulary_mock) do
    i = instance_double("Vocabulary")
    allow(i).to receive(:persisted?).and_return(false)
    allow(i).to receive(:id).and_return("vocab")
    allow(i).to receive(:vocabulary?).and_return(true)
    i
  end
  let(:predicate_mock) do
    i = instance_double("Predicate")
    allow(i).to receive(:persisted?).and_return(false)
    allow(i).to receive(:id).and_return("pred")
    allow(i).to receive(:predicate?).and_return(true)
    i
  end

end
