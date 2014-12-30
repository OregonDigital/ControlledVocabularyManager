require 'rails_helper'

RSpec.describe "terms/show" do
  let(:resource) { fake(:term) }
  let(:base_uri) { Term.base_uri }

  before do
    assign(:term, resource)
    stub(resource).label { ["Test Label"] }
    stub(resource).comment { ["Test Comment"] }
    stub(resource).issued { [Date.new(2012,1,1)] }
    stub(resource).modified { [Date.new(2012,1,2)] }
    stub(resource).base_uri { base_uri }
    render
  end

  context "when given a vocab" do
    let(:resource) { fake(:vocabulary, :persisted? => true) }
    it "should have a link to create a resource" do
      expect(rendered).to have_link "Create Term", :href => "/vocabularies/#{resource.id}/new"
    end
  end

  it "displays the term name" do
    expect(rendered).to have_content("bla")
  end

  it "displays the full URI" do
    expect(rendered).to have_content("http://opaquenamespace.org/ns/bla") 
  end
  %w{label comment}.each do |attribute|
    it "displays #{attribute}" do
      expect(rendered).to have_content(resource.send(attribute).first)
    end
  end
  it "displays modified" do
    expect(rendered).to have_content "2012-01-02"
  end
  it "displays issued" do
    expect(rendered).to have_content "2012-01-01"
  end

end
