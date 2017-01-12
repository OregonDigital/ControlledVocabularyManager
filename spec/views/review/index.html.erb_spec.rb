require 'rails_helper'

RSpec.describe "review/index" do
  let(:uri) { "http://opaquenamespace.org/ns/blah" }
  let(:resource) { [{:id=>"blah", :uri=>uri, :label=> "Blah", :author=> "MisterEd" }]}
  before do
    assign(:terms, resource)
  end
  context "when there is an item to review" do
    before do
      render
    end
    it "should display all review terms" do
      expect(rendered).to have_link(resource.first[:label], :href => review_term_path(resource.first[:id]))
    end
    it "should display the label of the term" do
      expect(rendered).to have_content("Blah")
    end
    it "should display the author of the vocabulary" do
      expect(rendered).to have_content("MisterEd")
    end    
  end
end
