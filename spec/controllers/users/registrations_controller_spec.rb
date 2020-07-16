# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::RegistrationsController do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let(:user_params) { { email: 'blah@blah.com', password: 'admin123', role: 'admin', institution: 'Oregon State University', name: 'Test' } }
  let(:user_params_fake_role) { { email: 'blah@blah.com', password: 'admin123', role: 'blahbla', institution: 'Oregon State University', name: 'Test' } }

  context 'When registering a new user' do
    before do
      post :create, params: { user: user_params }
    end

    it 'creates a user with the proper default role' do
      expect(User.where(email: 'blah@blah.com').first.role).to eq 'default'
    end
  end

  context 'When editing a current registered user' do
    let(:user) { User.create(user_params) }

    before do
      sign_in(user) if user
      put :update, params: { user: user_params_fake_role }
    end

    it 'leaves the role as is' do
      expect(User.where(email: 'blah@blah.com').first.role).to eq 'admin'
    end
  end
end
