# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'terms/new', type: :view do
  let(:id) { 'Creator' }
  let(:vocabulary) { Vocabulary.new(id) }
  let(:term) { TermFormRepository.new(Term).new }
  let(:parameters) do
    {
      vocabulary_id: 'test'
    }
  end

  before do
    assign(:vocabulary, vocabulary)
    assign(:term, term)
    render
  end

  it 'posts to /terms' do
    expect(rendered).to have_selector("form[action='/vocabularies/#{vocabulary.id}'][method='post']")
  end

  it 'does not have a _method field' do
    expect(rendered).not_to have_selector("input[name='_method']")
  end

  it 'displays the vocabulary URI' do
    expect(rendered).to have_content(vocabulary.rdf_subject.to_s)
  end

  it 'has an ID field' do
    expect(rendered).to have_selector("input[name='term[id]']")
  end

  it 'has a hidden input for vocabulary_id' do
    # capybara matchers for have_selector were failing hard here.
    expect(rendered).to match(/name=\"vocabulary_id\"/)
    expect(rendered).to match(/id=\"vocabulary_id\"/)
    expect(rendered).to match(/value=\"#{vocabulary.id}\"/)
  end

  it 'has inputs for all editable fields' do
    term.editable_fields.each do |attribute|
      expect(rendered).to have_selector "input[name='vocabulary[#{attribute}][]']"
    end
  end

  it 'has a create term button' do
    expect(rendered).to have_button('Create Term')
  end

  context 'with a term in the namespace' do
    let(:term) { Term.new("#{id}/Test") }

    it 'has a properly populated ID field' do
      expect(rendered).to have_field('ID', with: 'Test')
    end
  end
end
