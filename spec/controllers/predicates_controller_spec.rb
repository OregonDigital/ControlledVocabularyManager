# frozen_string_literal: true

require 'rails_helper'
require 'rugged'
require 'support/test_git_setup'

RSpec.describe PredicatesController do
  include TestGitSetup
  let(:user) { User.create(email: 'blah@blah.com', password: 'admin123', role: 'admin reviewer editor', institution: 'Oregon State University', name: 'Test') }

  before do
    sign_in(user) if user
    setup_git
  end

  after do
    FileUtils.rm_rf(ControlledVocabularyManager::Application.config.rugged_repo)
  end

  describe "Get 'new'" do
    let(:result) { get 'new' }

    before do
      result
    end

    it 'is successful' do
      expect(result).to be_success
    end

    it 'assigns @predicate' do
      assigned = assigns(:predicate)
      expect(assigned).to be_kind_of PredicateForm
      expect(assigned).to be_new_record
    end

    it 'renders new' do
      expect(result).to render_template('new')
    end
  end

  describe "GET 'edit'" do
    let(:predicate_form) { instance_double('PredicateForm') }
    let(:predicate) { predicate_mock }

    before do
      allow_any_instance_of(PredicateFormRepository).to receive(:find).and_return(predicate_form)
      allow(predicate).to receive(:attributes=)
      get 'edit', params: { id: predicate.id }
    end

    it 'assigns @term' do
      expect(assigns(:term)).to eq predicate_form
    end

    it 'renders edit' do
      expect(response).to render_template 'edit'
    end
  end

  describe "PATCH 'update'" do
    let(:predicate) { predicate_mock }
    let(:twc) { TermWithoutChildren.new(predicate) }
    let(:pred_mod) { SetsModified.new(twc) }
    let(:predicate_form) { PredicateForm.new(SetsAttributes.new(pred_mod), Predicate) }
    let(:predicate_params) { { id: 'blah' } }
    let(:params) do
      {
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
      allow_any_instance_of(PredicateFormRepository).to receive(:find).and_return(predicate_form)
      allow(predicate).to receive(:blacklisted_language_properties).and_return(%i[id issued modified])
      allow(predicate).to receive(:uri_fields).and_return([])
      full_graph = instance_double('RDF::Graph')
      allow(predicate_form).to receive(:sort_stringify).and_return('blah')
      allow(predicate_form).to receive(:single_graph).and_return(full_graph)
      allow(predicate).to receive(:attributes=)
      allow(predicate_form).to receive(:valid?).and_return(true)
      allow(predicate).to receive(:attributes).and_return(params)
      allow(predicate).to receive(:valid?)
    end

    context 'when the fields are edited' do
      before do
        patch :update, params: { id: predicate.id, predicate: params, vocabulary: params }
      end

      it 'updates the properties' do
        expect(predicate).to have_received(:attributes=).with(comment: [RDF::Literal('Test', language: :en)], label: [RDF::Literal('Test', language: :en)]).exactly(1).times
      end

      it 'redirects to the predicates index' do
        expect(response).to redirect_to('/predicates')
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
          expect(predicate).to have_received(:attributes=).with(comment: [], label: ['Test'])
        end
      end
    end

    context 'when index.lock exists and rugged returns false' do
      before do
        FileUtils.touch(ControlledVocabularyManager::Application.config.rugged_repo + '/.git/index.lock')
        patch :update, params: { id: predicate.id, predicate: params, vocabulary: params }
      end

      after do
        File.delete(ControlledVocabularyManager::Application.config.rugged_repo + '/.git/index.lock')
      end

      it 'flashes something went wrong' do
        expect(flash[:error]).to include('Something went wrong')
      end
    end

    context 'when the fields are edited and the check fails' do
      before do
        allow(predicate_form).to receive(:valid?).and_return(false)
        patch :update, params: { id: predicate.id, predicate: params, vocabulary: params }
      end

      it 'shows the edit form' do
        expect(assigns(:term)).to eq predicate_form
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'PATCH deprecate_only' do
    let(:predicate) { predicate_mock }
    let(:twc) { TermWithoutChildren.new(predicate) }
    let(:predicate_form) { DeprecatePredicateForm.new(SetsAttributes.new(twc), Predicate) }
    let(:params) do
      {
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
      allow_any_instance_of(DeprecatePredicateFormRepository).to receive(:find).and_return(predicate_form)
      stub_repository
      full_graph = instance_double('RDF::Graph')
      allow(predicate_form).to receive(:sort_stringify).and_return('blah')
      allow(predicate_form).to receive(:single_graph).and_return(full_graph)
      allow(predicate).to receive(:blacklisted_language_properties).and_return(%i[id issued modified])
      allow(predicate).to receive(:uri_fields).and_return(%i[is_replaced_by])
      allow(predicate).to receive(:attributes=)
      allow(predicate).to receive(:is_replaced_by=)
      allow(predicate_form).to receive(:is_valid?).and_return(true)
      allow(predicate).to receive(:attributes).and_return(params)
      allow(predicate).to receive(:is_replaced_by).and_return(params[:is_replaced_by])
    end

    context 'when the fields are edited' do
      before do
        patch :deprecate_only, params: { id: predicate.id, predicate: params, vocabulary: params }
      end

      it 'updates the is_replaced_by property' do
        expect(predicate).to have_received(:is_replaced_by=).with(params[:is_replaced_by]).exactly(1).times
      end

      it 'redirects to predicates index' do
        expect(response).to redirect_to('/predicates')
      end
    end

    context 'when index.lock exists and rugged returns false' do
      before do
        FileUtils.touch(ControlledVocabularyManager::Application.config.rugged_repo + '/.git/index.lock')
        patch :deprecate_only, params: { id: predicate.id, predicate: params, vocabulary: params }
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
        allow(predicate_form).to receive(:is_valid?).and_return(false)
        patch :deprecate_only, params: { id: predicate.id, predicate: params, vocabulary: params }
      end

      it 'shows the edit form' do
        expect(assigns(:term)).to eq predicate_form
        expect(response).to render_template('deprecate')
      end
    end
  end

  describe "GET 'index'" do
    context 'when there are predicates' do
      let(:injector) { PredicateInjector.new }
      let(:predicate) do
        p = Vocabulary.new('mypred')
        p.label = 'my pred label'
        p
      end

      before do
        allow(predicate).to receive(:repository).and_return(Predicate.new.repository)
        allow(AllVocabsQuery).to receive(:call).and_return([predicate])
      end

      it 'sets @predicates to all preds' do
        get :index
        expect(assigns(:predicates)).to eq [predicate]
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
    let(:term_id) { 'blah' }
    let(:predicate_params) do
      {
        id: term_id,
        label: ['Test1'],
        comment: ['Test2'],
        language: {
          label: ['en'],
          comment: ['en']
        }
      }
    end
    let(:twc) { TermWithoutChildren.new(predicate) }
    let(:pred_iss) { SetsIssued.new(twc) }
    let(:pred_mod) { SetsModified.new(pred_iss) }
    let(:pred_res) { AddResource.new(pred_mod) }
    let(:predicate) { instance_double('Predicate') }
    let(:predicate_form) { PredicateForm.new(SetsAttributes.new(pred_res), Predicate) }
    let(:result) { post 'create', params: { predicate: predicate_params, vocabulary: predicate_params } }

    before do
      stub_repository
      allow_any_instance_of(PredicateFormRepository).to receive(:new).and_return(predicate_form)
      full_graph = instance_double('RDF::Graph')
      allow(predicate_form).to receive(:sort_stringify).and_return('blah')
      allow(predicate_form).to receive(:single_graph).and_return(full_graph)
      allow(predicate_form).to receive(:is_valid?).and_return(true)
      allow(predicate).to receive(:new_record?).and_return('true')
      allow(predicate).to receive(:blacklisted_language_properties).and_return(%i[id issued modified])
      allow(predicate).to receive(:uri_fields).and_return([])
      allow(predicate).to receive(:id).and_return('test')
      allow(predicate).to receive(:attributes=)
      allow(predicate).to receive(:attributes).and_return(predicate_params)
      allow(predicate).to receive(:valid?)
    end

    context 'when all goes well' do
      before do
        post 'create', params: { predicate: predicate_params, vocabulary: predicate_params }
      end

      it 'redirects to the index' do
        expect(response).to redirect_to('/predicates')
      end
    end

    context 'when index.lock exists and rugged returns false' do
      before do
        FileUtils.touch(ControlledVocabularyManager::Application.config.rugged_repo + '/.git/index.lock')
        # allow(term_form).to receive(:is_valid?).and_return(true)
        post 'create', params: { predicate: predicate_params, vocabulary: predicate_params }
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
    let(:predicate) { predicate_mock }
    let(:pred_id) { 'blah' }
    let(:params) do
      {
        id: pred_id,
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
    let(:pred_form) { PredicateForm.new(term, StandardRepository.new(nil, Predicate)) }

    before do
      allow(predicate).to receive(:new_record?).and_return(true)
      allow_any_instance_of(PredicateForm).to receive(:save).and_return(save_success)
      allow_any_instance_of(GitInterface).to receive(:reassemble).and_return(predicate)
    end

    context 'when the item has been reviewed' do
      before do
        allow_any_instance_of(GitInterface).to receive(:rugged_merge)
        # Solr is not running for tests, we want Sunspot.index! to not fail
        allow_any_instance_of(described_class).to receive(:update_solr_index)
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
