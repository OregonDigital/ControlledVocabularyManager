# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vocabularies/deprecate' do
  let(:id) { 'Creator' }
  let(:term) do
    Vocabulary.new(id).tap do |t|
      t.label = [RDF::Literal.new('blah', language: :en)]
    end
  end

  before do
    allow(term).to receive(:persisted?).and_return(true)
    assign(:term, term)
    render
  end

  it 'posts to /vocabularies/Creator/deprecate_only' do
    expect(rendered).to have_selector("form[action='/vocabularies/Creator/deprecate_only'][method='post']")
  end
  it 'does not have a _method field' do
    expect(rendered).not_to have_selector("input[name='_method']")
  end
  it 'displays the term URI' do
    expect(rendered).to have_content(term.rdf_subject.to_s)
  end

  it 'has inputs for all editable fields' do
    expect(rendered).to have_selector "input[name='vocabulary[is_replaced_by][]']"
  end
end
