# frozen_string_literal: true

require 'rails_helper'
require 'support/test_git_setup'

# Dummy Controller
class DummyController < AdminController
  include GitInterface
end

RSpec.describe 'terms/show' do
  include TestGitSetup
  let(:uri) { 'http://opaquenamespace.org/ns/bla' }
  let(:resource) do
    Term.new(uri).tap do |t|
      t.is_replaced_by = 'http://opaquenamespace.org/ns/bla2'
      t.label = ['a_label']
    end
  end
  let(:children) {}
  let(:dummy_class) { DummyController.new }

  before do
    assign(:term, resource)
    allow(resource).to receive(:fields).and_return([:label])
    allow(resource).to receive(:persisted?).and_return(true)
  end

  context 'when given a vocab' do
    let(:vocabulary) { Vocabulary.new(uri) }
    let(:resource) { TermWithChildren.new(vocabulary, ChildNodeFinder) }
    let(:children) { [] }

    before do
      allow(resource).to receive(:children).and_return(children)
      allow(vocabulary).to receive(:persisted?).and_return(true)
      render
    end

    it 'has a link to create a resource' do
      render
      expect(rendered).to have_link 'Create Term', href: '/vocabularies/bla/new'
    end

    it 'has a link to edit the vocabulary' do
      render
      expect(rendered).to have_link 'Edit', href: edit_vocabulary_path(id: resource.id)
    end

    context 'with children' do
      let(:child) do
        t = Term.new(uri.to_s + '/banana')
        t.label = 'BananaChild'
        t
      end
      let(:children) { [child] }

      it 'has a list of terms in the vocabulary' do
        expect(rendered).to have_content I18n.t('vocabulary.children_header')
        expect(rendered).to have_link child.rdf_subject.to_s
        expect(rendered).to have_content('BananaChild')
      end
    end
  end

  context 'when logged in' do
    let(:user) { User.create(email: 'blah@blah.com', password: 'admin123', role: 'admin', institution: 'Oregon State University', name: 'Test') }

    before do
      sign_in(user) if user
    end

    it 'has a link to edit the term' do
      render
      expect(rendered).to have_link 'Edit', href: edit_term_path(id: resource.id)
    end
  end

  context 'when term is deprecated' do
    let(:resource) do
      t = Term.new(uri)
      t.is_replaced_by = RDF::URI('http://opaquenamespace.org/ns/bla2')
      t
    end

    it 'displays deprecated alert' do
      render
      expect(rendered).to have_content 'Deprecated'
    end
  end

  context 'when visiting the show page' do
    let(:resource) do
      t = Term.new(uri)
      # This instance of is_replaced_by is left as a string to ensure both values work.
      # Currently most existing is_replaced_by values in ONS are strings.
      t.is_replaced_by = 'http://opaquenamespace.org/ns/bla2'
      t.label = %w[a_label another_label]
      t.comment = ['comment']
      t
    end
    let(:user) { User.create(email: 'george@blah.com', name: 'George Smith', password: 'admin123', role: 'admin') }

    after do
      FileUtils.rm_rf(ControlledVocabularyManager::Application.config.rugged_repo)
    end

    before do
      allow_any_instance_of(DummyController).to receive(:current_user).and_return(user)
      setup_for_show_test(dummy_class)
      allow(resource).to receive(:commit_history).and_return(get_history('blah'))
    end

    it 'displays all fields' do
      render
      resource.fields.each do |field|
        expect(rendered).to have_content(field)
      end
    end

    # TODO: Test disabled while the functionality is disabled due to memory leak and slowness

    xit 'should display the diff if it exists' do
      render
      expect(rendered).to have_content('added: <http://www.w3.org/2000/01/rdf-schema#label> "fooness" @en .')
    end
  end
end
