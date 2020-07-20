# frozen_string_literal: true

require 'rails_helper'
require 'rugged'
require 'support/test_git_setup'

RSpec.describe VocabulariesController do
  include TestGitSetup
  let(:user) { User.create(email: 'blah@blah.com', password: 'admin123', role: 'admin reviewer editor', institution: 'Oregon State University', name: 'Test') }

  before do
    sign_in(user) if user
    setup_git
  end

  after do
    FileUtils.rm_rf(ControlledVocabularyManager::Application.config.rugged_repo)
  end

  describe "GET 'new'" do
    let(:result) { get 'new' }

    before do
      result
    end

    context 'when logged out' do
      let(:user) {}

      it 'requires login' do
        expect(result.body).to have_content('Only admin can access')
      end
    end

    it 'is successful' do
      expect(result).to be_success
    end

    it 'assigns @vocabulary' do
      assigned = assigns(:vocabulary)
      expect(assigned).to be_kind_of VocabularyForm
      expect(assigned).to be_new_record
    end

    it 'renders new' do
      expect(result).to render_template('new')
    end
  end

  describe "GET 'edit'" do
    let(:vocabulary_form) { instance_double('VocabularyForm') }
    let(:vocabulary) { vocabulary_mock }

    before do
      allow_any_instance_of(VocabularyFormRepository).to receive(:find).and_return(vocabulary_form)
      allow(vocabulary).to receive(:attributes=)
      get 'edit', params: { id: vocabulary.id }
    end

    it 'assigns @term' do
      expect(assigns(:term)).to eq vocabulary_form
    end

    it 'renders edit' do
      expect(response).to render_template 'edit'
    end
  end

  describe "PATCH 'update'" do
    let(:vocabulary) { vocabulary_mock }
    let(:injector) { VocabularyInjector.new }
    let(:twc) { TermWithoutChildren.new(vocabulary) }
    let(:voc_mod) { SetsModified.new(twc) }
    let(:vocabulary_form) { VocabularyForm.new(SetsAttributes.new(voc_mod), Vocabulary) }
    let(:params) do
      {
        id: 'blah',
        comment: ['Test'],
        label: ['Test'],
        language: {
          label: ['en'],
          comment: ['en']
        }
      }
    end
    let(:persist_success) { true }

    before do
      stub_repository
      allow_any_instance_of(VocabularyFormRepository).to receive(:find).and_return(vocabulary_form)
      single_graph = instance_double('RDF::Graph')
      allow(vocabulary_form).to receive(:sort_stringify).and_return('blah')
      allow(vocabulary_form).to receive(:single_graph).and_return(single_graph)
      allow(vocabulary).to receive(:blacklisted_language_properties).and_return(%i[id issued modified is_replaced_by date same_as is_defined_by])
      allow(vocabulary).to receive(:uri_fields).and_return([])
      allow(vocabulary).to receive(:attributes=)
      allow(vocabulary_form).to receive(:is_valid?).and_return(true)
      allow(vocabulary).to receive(:attributes).and_return(params)
      allow(vocabulary).to receive(:valid?)
    end

    context 'when the fields are edited' do
      before do
        patch :update, params: { id: vocabulary.id, vocabulary: params, is_replaced_by: ['test'] }
      end

      it 'updates the properties' do
        expect(vocabulary).to have_received(:attributes=).with(comment: [RDF::Literal('Test', language: :en)], id: 'blah', label: [RDF::Literal('Test', language: :en)])
      end

      it 'redirects to the index' do
        expect(response).to redirect_to('/vocabularies')
      end

      context 'and there are blank fields' do
        let(:params) do
          {
            comment: [''],
            label: ['Test'],
            language: {
              label: ['en']
            }
          }
        end

        it 'ignores them' do
          expect(vocabulary).to have_received(:attributes=).with(comment: [], label: ['Test'])
        end
      end
    end

    context 'when index.lock exists and rugged returns false' do
      before do
        FileUtils.touch(ControlledVocabularyManager::Application.config.rugged_repo + '/.git/index.lock')
        patch :update, params: { id: vocabulary.id, vocabulary: params, is_replaced_by: ['test'] }
      end

      after do
        File.delete(ControlledVocabularyManager::Application.config.rugged_repo + '/.git/index.lock')
      end

      it 'flashes something went wrong' do
        expect(flash[:error]).to include('Something went wrong')
      end
    end

    context 'when the fields are edited and the update fails' do
      before do
        allow(vocabulary_form).to receive(:is_valid?).and_return(false)
        patch :update, params: { id: vocabulary.id, vocabulary: params, is_replaced_by: ['test'] }
      end

      it 'shows the edit form' do
        expect(assigns(:term)).to eq vocabulary_form
        expect(response).to render_template('edit')
      end
    end
  end

  describe "PATCH 'deprecate_only'" do
    let(:vocabulary) { vocabulary_mock }
    let(:injector) { VocabularyInjector.new }
    let(:twc) { TermWithoutChildren.new(vocabulary) }
    let(:vocabulary_form) { DeprecateVocabularyForm.new(SetsAttributes.new(twc), Vocabulary) }
    let(:params) do
      {
        id: 'blah',
        comment: ['Test'],
        label: ['Test'],
        is_replaced_by: ['test'],
        language: {
          label: ['en'],
          comment: ['en']
        }
      }
    end
    let(:persist_success) { true }

    before do
      allow_any_instance_of(DeprecateVocabularyFormRepository).to receive(:find).and_return(vocabulary_form)
      stub_repository
      single_graph = instance_double('RDF::Graph')
      allow(vocabulary_form).to receive(:sort_stringify).and_return('blah')
      allow(vocabulary_form).to receive(:single_graph).and_return(single_graph)
      allow(vocabulary).to receive(:blacklisted_language_properties).and_return(%i[id issued modified is_replaced_by date same_as is_defined_by])
      allow(vocabulary).to receive(:uri_fields).and_return(%i[is_replaced_by])
      allow(vocabulary).to receive(:attributes=)
      allow(vocabulary).to receive(:is_replaced_by=)
      allow(vocabulary).to receive(:persist!).and_return(persist_success)
      allow(vocabulary_form).to receive(:valid?).and_return(true)
      allow(vocabulary).to receive(:attributes).and_return(params)
      allow(vocabulary).to receive(:is_replaced_by).and_return(params[:is_replaced_by])
    end

    context 'when the fields are edited' do
      before do
        patch :deprecate_only, params: { id: vocabulary.id, vocabulary: params, is_replaced_by: ['test'] }
      end

      it 'updates the replaced_by property' do
        expect(vocabulary).to have_received(:is_replaced_by=).with(params[:is_replaced_by])
      end

      it 'redirects to the index' do
        expect(response).to redirect_to('/vocabularies')
      end
    end

    context 'when index.lock exists and rugged returns false' do
      before do
        FileUtils.touch(ControlledVocabularyManager::Application.config.rugged_repo + '/.git/index.lock')
        patch :deprecate_only, params: { id: vocabulary.id, vocabulary: params, is_replaced_by: ['test'] }
      end

      after do
        File.delete(ControlledVocabularyManager::Application.config.rugged_repo + '/.git/index.lock')
      end

      it 'flashes something went wrong' do
        expect(flash[:error]).to include('Something went wrong')
      end
    end

    context 'when the fields are edited and the update fails' do
      before do
        allow(vocabulary_form).to receive(:is_valid?).and_return(false)
        patch :deprecate_only, params: { id: vocabulary.id, vocabulary: params, is_replaced_by: ['test'] }
      end

      it 'shows the edit form' do
        expect(assigns(:term)).to eq vocabulary_form
        expect(response).to render_template('deprecate')
      end
    end
  end

  describe "GET 'index'" do
    context 'when there are vocabularies' do
      let(:injector) { VocabularyInjector.new }
      let(:aa_vocab) do
        a_v = Vocabulary.new('aa')
        a_v.label = 'AA'
        a_v
      end
      let(:bb_vocab) do
        b_v = Vocabulary.new('bb')
        b_v.label = 'BB'
        b_v
      end

      before do
        allow(aa_vocab).to receive(:repository).and_return(Vocabulary.new.repository)
        allow(bb_vocab).to receive(:repository).and_return(Vocabulary.new.repository)
        allow(AllVocabsQuery).to receive(:call).and_return([bb_vocab, aa_vocab])
      end

      it 'sets @vocabularies to all vocabs sorted alphabetically' do
        get :index
        expect(assigns(:vocabularies)).to eq [aa_vocab, bb_vocab]
      end
    end

    it 'is successful' do
      get :index

      expect(response).to be_success
    end

    it 'renders index' do
      get :index

      expect(response).to render_template 'index'
    end

    context 'when not logged in' do
      let(:logged_in) { false }

      it 'does not redirect' do
        expect(response).not_to be_redirect
      end
    end
  end

  describe 'POST create' do
    let(:vocabulary_params) do
      {
        id: 'blah',
        label: ['test'],
        comment: ['blah'],
        language: {
          label: ['en'],
          comment: ['en']
        }
      }
    end
    let(:injector) { VocabularyInjector.new }
    let(:twc) { TermWithoutChildren.new(vocabulary) }
    let(:voc_iss) { SetsIssued.new(twc) }
    let(:voc_mod) { SetsModified.new(voc_iss) }
    let(:voc_res) { AddResource.new(voc_mod) }
    let(:vocabulary) { instance_double('Vocabulary') }
    let(:vocabulary_form) { VocabularyForm.new(SetsAttributes.new(voc_res), Vocabulary) }
    let(:result) { post 'create', params: { vocabulary: vocabulary_params } }
    let(:save_success) { true }

    before do
      stub_repository
      single_graph = instance_double('RDF::Graph')
      allow(vocabulary_form).to receive(:single_graph).and_return(single_graph)
      allow(vocabulary_form).to receive(:sort_stringify).and_return('blah')
      allow_any_instance_of(VocabularyFormRepository).to receive(:new).and_return(vocabulary_form)
      allow(vocabulary_form).to receive(:is_valid?).and_return(true)
      allow(vocabulary).to receive(:blacklisted_language_properties).and_return(%i[id issued modified])
      allow(vocabulary).to receive(:id).and_return('test')
      allow(vocabulary).to receive(:uri_fields).and_return([])
      allow(vocabulary).to receive(:attributes=)
      allow(vocabulary).to receive(:attributes).and_return(vocabulary_params)
      allow(vocabulary).to receive(:valid?)
    end

    context 'when blank arrays are passed in' do
      let(:vocabulary_params) do
        {
          id: 'blah',
          label: ['test'],
          comment: [''],
          language: {
            label: ['en'],
            comment: ['en']
          }
        }
      end

      before do
        post 'create', params: { vocabulary: vocabulary_params }
      end

      it 'does not pass them to vocabulary' do
        expect(vocabulary).to have_received(:attributes=).with('label' => ['test'], 'comment' => [])
      end
    end

    context 'when check fails' do
      before do
        allow(vocabulary_form).to receive(:is_valid?).and_return(false)
        post 'create', params: { vocabulary: vocabulary_params }
      end

      it 'renders new template' do
        expect(response).to render_template('new')
      end

      it 'assigns @vocabulary' do
        expect(assigns(:vocabulary)).to eq vocabulary_form
      end
    end

    context 'when all goes well' do
      before do
        post 'create', params: { vocabulary: vocabulary_params }
      end

      it 'redirects to the index' do
        expect(response).to redirect_to('/vocabularies')
      end
    end

    context 'when index.lock exists and rugged returns false' do
      before do
        FileUtils.touch(ControlledVocabularyManager::Application.config.rugged_repo + '/.git/index.lock')
        post 'create', params: { vocabulary: vocabulary_params }
      end

      after do
        File.delete(ControlledVocabularyManager::Application.config.rugged_repo + '/.git/index.lock')
      end

      it 'flashes something went wrong' do
        expect(flash[:error]).to include('Something went wrong')
      end
    end
  end

  describe 'mark_reviewed' do
    let(:vocabulary) { vocabulary_mock }
    let(:vocab_id) { 'blah' }
    let(:params) do
      {
        id: vocab_id,
        vocabulary: {
          label: ['Test'],
          comment: ['Comment'],
          language: {
            label: ['en'],
            comment: ['en']
          }
        }
      }
    end
    let(:save_success) { true }
    let(:vocab_form) { VocabularyForm.new(term, StandardRepository.new(nil, Vocabulary)) }

    before do
      allow(vocabulary).to receive(:new_record?).and_return(true)
      allow_any_instance_of(VocabularyForm).to receive(:save).and_return(save_success)
      allow_any_instance_of(GitInterface).to receive(:reassemble).and_return(vocabulary)
    end

    context 'when the item has been reviewed' do
      before do
        allow_any_instance_of(GitInterface).to receive(:rugged_merge)
        # Solr is not running for tests, we want Sunspot.index! to not fail
        allow(subject).to receive(:update_solr_index)
        get :mark_reviewed, params: { id: params[:id] }
      end

      it 'will redirect to review queue if asset is saved' do
        expect(flash[:success]).to include('blah has been saved')
        expect(response).to redirect_to('/review')
      end
    end

    context 'when an error is raised inside rugged_merge' do
      before do
        allow_any_instance_of(GitInterface).to receive(:rugged_merge).and_return(0)
        get :mark_reviewed, params: { id: params[:id] }
      end

      it 'shows the flash error' do
        expect(flash[:error]).to include('Something went wrong')
      end
    end
  end
end
