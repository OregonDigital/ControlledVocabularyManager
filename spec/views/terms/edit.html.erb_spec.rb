require 'rails_helper'

RSpec.describe "terms/edit" do
  let(:id) { "Creator" }
  let(:term) { Term.new("#{id}/JohnSmith") }
  before do
    allow(term).to receive(:persisted?).and_return(true)
    assign(:term, term)
    render
  end
  it "should post to /ns/Creator/JohnSmith" do
    expect(rendered).to have_selector("form[action='/ns/Creator/JohnSmith'][method='post']")
  end
  it "should not have a _method field" do
    expect(rendered).not_to have_selector("input[name='_method']")
  end
  it "should display the term URI" do
    expect(rendered).to have_content(term.rdf_subject.to_s)
  end
  %w{label comment}.each do |attribute|
    it "has inputs for #{attribute}" do
      expect(rendered).to have_selector "input[name='term[#{attribute}][]']"
    end
  end
  it "should have an Update Term button" do
    expect(rendered).to have_button("Update Term")
  end
end
