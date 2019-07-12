# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "import_rdf/preview_import.html.erb" do
  let(:vocabns) { "http://opaquenamespace.org/ns/newthing" }
  let(:form) { ImportForm.new("url", "preview", RdfImporter) }
  let(:terms) { [Term.new(vocabns + "/1"), Term.new(vocabns + "/2"), Term.new(vocabns + "/3")] }

  let(:vocabulary) do
    v = Vocabulary.new(vocabns)
    v.title = "Vocab title"
    v.publisher = "Fake Publishing, Ltd."
    v
  end

  before do
    assign(:form, form)
    assign(:vocabulary, vocabulary)
    assign(:terms, terms)
    render
  end

  it "renders the form with the form" do
    expect(view).to render_template(:partial => "form", :locals => {:form => form})
  end

  it "displays the vocabulary" do
    expect(rendered).to have_css("dd", :text => %r|\Anewthing\Z|)
    expect(rendered).to have_css("dd", :text => %r|\Ahttp://opaquenamespace.org/ns/newthing\Z|)
    expect(rendered).to have_css("dd", :text => %r|\AVocab title\Z|)
    expect(rendered).to have_css("dd", :text => %r|\AFake Publishing, Ltd.\Z|)
  end

  it "renders the terms" do
    terms.each do |term|
      expect(view).to render_template(:partial => "termlist", :locals => {:namespace => "newthing", :term => term})
    end
  end
end
