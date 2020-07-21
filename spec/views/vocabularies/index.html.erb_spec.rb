# frozen_string_literal: true

require 'rails_helper'
WebMock.allow_net_connect!

RSpec.describe 'vocabularies/index.html.erb' do
  let(:vocabs) { [vocabulary] }
  let(:vocabulary) do
    v = Vocabulary.new('bla')
    v.label = 'Test Vocabulary'
    v.is_replaced_by = 'test'
    v
  end

  before do
    assign(:vocabularies, vocabs)
    render
  end

  it 'displays all vocabularies' do
    expect(rendered).to have_link(vocabulary.rdf_subject.to_s, href: term_path(id: vocabulary.id))
  end

  it 'displays the label/title of the vocabulary' do
    expect(rendered).to have_content('Test Vocabulary')
  end

  context 'when logged in' do
    let(:user) { User.create(email: 'admin@example.com', password: 'admin123', role: 'admin') }

    it 'displays a link to create a new vocabulary' do
      allow(view).to receive(:current_user).and_return(user)

      render
      expect(rendered).to have_link 'Create Vocabulary', href: '/vocabularies/new'
    end
  end

  context 'when not logged in' do
    it 'does not display link to create new vocab' do
      render
      expect(rendered).not_to have_link 'Create Vocabulary', href: '/vocabularies/new'
    end
  end
end
