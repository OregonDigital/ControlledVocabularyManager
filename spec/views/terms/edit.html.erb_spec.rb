# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'terms/edit' do
  let(:id) { 'Creator' }
  let(:term) { Term.new("#{id}/JohnSmith") }

  before do
    allow(term).to receive(:persisted?).and_return(true)
    assign(:term, term)
    render
  end

  context 'when given a vocabulary' do
    let(:term) { Vocabulary.new(id.to_s) }

    it 'has inputs for all editable fields' do
      term.editable_fields.each do |attribute|
        expect(rendered).to have_selector "input[name='vocabulary[#{attribute}][]']"
      end
    end
  end

  it 'posts to /terms/Creator/JohnSmith' do
    expect(rendered).to have_selector("form[action='/terms/Creator/JohnSmith'][method='post']")
  end

  it 'does not have a _method field' do
    expect(rendered).not_to have_selector("input[name='_method']")
  end

  it 'displays the term URI' do
    expect(rendered).to have_content(term.rdf_subject.to_s)
  end

  it 'has inputs for all editable fields' do
    term.editable_fields.each do |attribute|
      expect(rendered).to have_selector "input[name='vocabulary[#{attribute}][]']"
    end
  end

  it 'has an Update Term button' do
    expect(rendered).to have_button('Update Term')
  end

  it 'has a Deprecate Term button' do
    expect(rendered).to have_content('Deprecate')
  end
end
