require 'rails_helper'

RSpec.describe "terms/show" do
  let(:uri) { "http://opaquenamespace.org/ns/bla" }
  let(:resource) { Vocabulary.new(uri) }

  before do
    assign(:vocab, resource)
    resource.label = "Blah vocab"
    resource.comment = "Blah comment"
    resource.persist!
    allow(resource).to receive(:modified).and_call_original

    render
  end

  it "displays the vocab name" do
    expect(rendered).to have_content("bla")
  end

  it "displays the full URI" do
    expect(rendered).to have_content("http://opaquenamespace.org/ns/bla") 
  end

  it "displays the label" do
    expect(rendered).to have_content("Blah vocab")
  end

  it "displays a comment" do
    expect(rendered).to have_content("Blah comment")
  end

  it "displays the issued date" do
    expect(rendered).to have_content(Date.today.iso8601)
  end

  it "displays the modified date" do
    expect(resource).to have_received(:modified)
  end
end
