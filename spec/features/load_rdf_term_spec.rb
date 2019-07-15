# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'
require 'support/test_git_setup'

# Dummy Controller
class DummyController < AdminController
  include GitInterface
end

RSpec.describe 'Load RDF', js: true, type: :feature do
  include TestGitSetup
  let(:user) { User.create(email: 'admin@example.com', name: 'Jane Admin', password: 'admin123', role: 'admin reviewer editor', institution: 'Oregon State University') }
  let(:user_params) { { email: 'admin@example.com', name: 'Jane Admin', password: 'admin123', role: 'admin reviewer editor', institution: 'Oregon State University' } }
  let(:dummy_class) { DummyController.new }
  before do
    allow_any_instance_of(AdminController).to receive(:current_user).and_return(user)
    allow(user).to receive(:admin?).and_return(true)
  end

  let(:jsonld) do
    '{
   "@context": {
    "dc": "http://purl.org/dc/terms/",
    "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
    "schema": "http://schema.org/",
    "skos": "http://www.w3.org/2004/02/skos/core#",
    "xsd": "http://www.w3.org/2001/XMLSchema#"
  },
  "@graph": [
    {
  "@id": "http://opaquenamespace.org/ns/mylittlevocab",
  "@type": [
    "http://purl.org/dc/dcam/VocabularyEncodingScheme",
    "rdfs:Resource"
  ],
  "dc:issued": "2016-09-22",
  "dc:modified": {
    "@value": "2016-09-29",
    "@type": "xsd:date"
  },
  "dc:title": {
    "@value": "My Little Vocab",
    "@language": "en"
  },
  "rdfs:label": {
    "@value": "my little vocab",
    "@language": "en"
  }
    }
   ]
  }'
  end

  let(:jsonldbad) do
    '{
   "@context": {
    "dc": "http://purl.org/dc/terms/",
    "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
    "schema": "http://schema.org/",
    "skos": "http://www.w3.org/2004/02/skos/core#",
    "xsd": "http://www.w3.org/2001/XMLSchema#"
  },
  "@graph": [
    {
  "@id": "http://opaquenamespace.org/ns/Bad Vocab",
  "@type": [
    "http://purl.org/dc/dcam/VocabularyEncodingScheme",
    "rdfs:Resource"
  ],
  "dc:issued": "2016-09-22",
  "dc:modified": {
    "@value": "2016-09-29",
    "@type": "xsd:date"
  },
  "dc:title": {
    "@value": "Bad Vocab",
    "@language": "en"
  },
  "rdfs:label": {
    "@value": "bad",
    "@language": "en"
  }
    }
   ]
  }'
  end

  it 'load a term' do
    WebMock.allow_net_connect!
    setup_git

    user
    sign_in user
    visit '/load_rdf'
    fill_in('load_form_rdf_string', with: jsonld)
    find_button('Load').trigger('click')
    sleep(2)
    visit '/ns/mylittlevocab'
    expect(page).to have_content('my little vocab')
    repo = dummy_class.setup
    expect(repo.last_commit.message).to eq('Merge mylittlevocab_review into master')
    FileUtils.rm_rf(ControlledVocabularyManager::Application.config.rugged_repo) if Dir.exist? ControlledVocabularyManager::Application.config.rugged_repo
  end

  it 'load a bad term' do
    WebMock.allow_net_connect!
    setup_git

    user
    sign_in user
    visit '/load_rdf'
    fill_in('load_form_rdf_string', with: jsonldbad)
    find_button('Load').trigger('click')
    sleep(2)
    expect(page).to have_content('Something went wrong')
    repo = dummy_class.setup
    expect(repo.last_commit.message).to eq('initial commit')
    FileUtils.rm_rf(ControlledVocabularyManager::Application.config.rugged_repo) if Dir.exist? ControlledVocabularyManager::Application.config.rugged_repo
  end
end
