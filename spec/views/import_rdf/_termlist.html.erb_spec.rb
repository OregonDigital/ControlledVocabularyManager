require 'rails_helper'

RSpec.describe "import_rdf/_termlist.html.erb" do
  let(:namespace) { "foo" }
  let(:term) { Term.new(namespace + "/bar") }

  def dorender
    render :partial => "import_rdf/termlist", :locals => {:term => term, :namespace => namespace}
  end

  xit "renders the ID with the vocabulary's namespaced converted to '...'" do
    dorender
    expect(rendered).to have_content(".../bar")
  end

  xit "renders the labels" do
    term.label << "label 1"
    term.label << "label 2"
    dorender
    expect(rendered).to have_content("label 1, label 2")
  end

  xit "renders the comments" do
    term.comment << "comment 1"
    term.comment << "comment 2"
    dorender
    expect(rendered).to have_content("comment 1, comment 2")
  end
end
