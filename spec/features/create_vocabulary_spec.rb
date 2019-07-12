# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Create and update a Vocabulary', js: true, type: :feature do
  include TestGitSetup

  let(:user) { User.create(email: 'admin@example.com', name: 'Jane Admin', password: 'admin123', role: 'admin editor reviewer', institution: 'Oregon State University') }
  let(:user_params) { { email: 'admin@example.com', name: 'Jane Admin', password: 'admin123', role: 'admin editor reviewer', institution: 'Oregon State University' } }

  before do
    allow_any_instance_of(AdminController).to receive(:current_user) { user }
    allow(user).to receive(:admin?).and_return(true)
  end

  let(:datetime_now) { DateTime.now.strftime('%Y%m%dT%H%M%S') }
  let(:vocabulary_id) { VocabularyCreatePage.id + datetime_now }

  before do
    user
    sign_in user
  end

  it 'creates and update a vocabulary' do
    WebMock.allow_net_connect!
    setup_git

    visit '/vocabularies/new'
    sleep 2
    expect(page).to have_content('ID')
    fill_in('vocabulary_id', with: vocabulary_id)
    fill_in 'vocabulary[label][]', with: 'Hello world'
    within('.vocabulary_label') do
      click_button('Add', match: :first)
    end
    within('.vocabulary_label ul.listing li:nth-child(2)') do
      fill_in 'vocabulary[label][]', with: 'Hola mundo'
      find('.language-select').find("option[value='es']").select_option
    end
    find('input[value="Create Vocabulary"]').click
    sleep 2
    expect(page).to have_content("#{vocabulary_id} has been saved and added to the review queue")
    visit "/review/#{vocabulary_id}"
    find_link('review').click
    sleep 2
    expect(page).to have_content(vocabulary_id.to_s)

    vocab_statement_list = Vocabulary.find(vocabulary_id).statements.each.map { |x| x }
    labels = vocab_statement_list.select { |s| s.predicate == 'http://www.w3.org/2000/01/rdf-schema#label' }
    expect(labels).to be_any { |l| l.object.value == 'Hello world' && l.object.language == :en }
    expect(labels).to be_any { |l| l.object.value == 'Hola mundo' && l.object.language == :es }

    visit "/vocabularies/#{vocabulary_id}/edit"
    within('form.edit_vocabulary > .multi-value-field ul.listing li:first-child') do
      click_button('Remove', match: :first)
    end
    expect(page).not_to have_xpath("//input[@value='Hello world']")

    if Dir.exist? ControlledVocabularyManager::Application.config.rugged_repo
      FileUtils.rm_rf(ControlledVocabularyManager::Application.config.rugged_repo)
    end
  end

  it 'creates a vocabulary with uri field' do
    WebMock.allow_net_connect!
    setup_git

    visit '/vocabularies/new'
    sleep 2
    expect(page).to have_content('ID')
    fill_in('vocabulary_id', with: vocabulary_id)
    fill_in 'vocabulary[see_also][]', with: 'http://id.loc.gov/authorities/subjects/sh85145447'
    find_button('Create Vocabulary').trigger('click')
    sleep 2
    expect(page).to have_content(vocabulary_id.to_s)

    if Dir.exist? ControlledVocabularyManager::Application.config.rugged_repo
      FileUtils.rm_rf(ControlledVocabularyManager::Application.config.rugged_repo)
    end
  end
end
