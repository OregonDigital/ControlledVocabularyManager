# frozen_string_literal: true

require 'rails_helper'
require 'support/test_git_setup'

# Dummy Controller
class DummyController < AdminController
  include GitInterface
end

RSpec.describe 'Import RDF', js: true, type: :feature do
  include TestGitSetup
  let(:user) { User.create(email: 'admin@example.com', name: 'Jane Admin', password: 'admin123', role: 'admin reviewer editor', institution: 'Oregon State University') }
  let(:user_params) { { email: 'admin@example.com', name: 'Jane Admin', password: 'admin123', role: 'admin reviewer editor', institution: 'Oregon State University' } }
  let(:dummy_class) { DummyController.new }
  let(:urlpred) { 'http://opaquenamespace.org/ns/artSeries.jsonld' }
  let(:urlvoc) { 'http://opaquenamespace.org/ns/TestVocabulary.jsonld' }

  before do
    allow_any_instance_of(AdminController).to receive(:current_user).and_return(user)
    allow(user).to receive(:admin?).and_return(true)
  end

  it 'import a predicate' do
    WebMock.allow_net_connect!
    setup_git

    user
    sign_in user
    visit '/import_rdf'

    fill_in('import_form_url', with: urlpred)
    find_button('Import JSON-LD').trigger('click')
    sleep(2)
    expect(page).to have_content('Imported external RDF resource(s)')

    visit '/ns/artSeries'
    sleep(2)
    expect(page).to have_content('In the visual arts')
    repo = dummy_class.setup
    expect(repo.last_commit.message).to eq('Merge artSeries_review into master')
    FileUtils.rm_rf(ControlledVocabularyManager::Application.config.rugged_repo) if Dir.exist? ControlledVocabularyManager::Application.config.rugged_repo
  end

  # skip this because it takes too long
  # esp if more terms get added to the vocab
  xit 'import a vocab' do
    WebMock.allow_net_connect!
    setup_git

    user
    sign_in user
    visit '/import_rdf'

    fill_in('import_form_url', with: urlvoc)
    page.check('import_form_preview')
    find_button('Import JSON-LD').trigger('click')
    sleep(10)
    expect(page).to have_content('A new vocabulary will be created')
    page.uncheck('import_form_preview')
    find_button('Import JSON-LD').trigger('click')
    sleep(10)
    expect(page).to have_content('Imported external RDF resource(s)')
    visit '/ns/TestVocabulary'
    expect(page).to have_content('TestVocabulary')
    repo = dummy_class.setup
    expect(repo.last_commit.message).to have_content('Merge TestVocabulary')
    FileUtils.rm_rf(ControlledVocabularyManager::Application.config.rugged_repo) if Dir.exist? ControlledVocabularyManager::Application.config.rugged_repo
  end
end
