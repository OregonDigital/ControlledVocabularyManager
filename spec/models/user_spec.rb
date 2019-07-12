# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.create(user_params) }
  let(:user_params) do
    {
      name: 'Test User',
      role: 'admin reviewer editor',
      email: 'test@testuser.com',
      institution: 'Oregon State University',
      password: 'TestTest',
      password_confirmation: 'TestTest'
    }
  end

  it { is_expected.to validate_presence_of(:institution) }
  it { is_expected.to validate_presence_of(:role) }
  it { is_expected.to validate_presence_of(:name) }

  context 'When a user has all the roles' do
    it 'is truthy for all user role methods' do
      expect(user).to be_admin
      expect(user).to be_reviewer
      expect(user).to be_editor
    end
  end

  context 'When a user has the editor and reviewer role' do
    let(:user_params) do
      {
        name: 'Test User',
        role: 'reviewer editor',
        email: 'test@testuser.com',
        institution: 'Oregon State University',
        password: 'TestTest',
        password_confirmation: 'TestTest'
      }
    end

    it 'is truthy for editor and reviewer methods but falsey for admin methods' do
      expect(user).not_to be_admin
      expect(user).to be_reviewer
      expect(user).to be_editor
    end
  end

  context 'When a user has the editor role' do
    let(:user_params) do
      {
        name: 'Test User',
        role: 'editor',
        email: 'test@testuser.com',
        institution: 'Oregon State University',
        password: 'TestTest',
        password_confirmation: 'TestTest'
      }
    end

    it 'is truthy for editor method but falsey for admin and reviewer methods' do
      expect(user).not_to be_admin
      expect(user).not_to be_reviewer
      expect(user).to be_editor
    end
  end

  context '#administrative' do
    context 'when a user has the admin role' do
      let(:user_params) do
        {
          name: 'Test User',
          role: 'admin reviewer editor',
          email: 'test@testuser.com',
          institution: 'Oregon State University',
          password: 'TestTest',
          password_confirmation: 'TestTest'
        }
      end

      it 'returns a truthy value' do
        expect(user).to be_administrative
      end
    end

    context 'when a user has the reviewer role' do
      let(:user_params) do
        {
          name: 'Test User',
          role: 'reviewer editor',
          email: 'test@testuser.com',
          institution: 'Oregon State University',
          password: 'TestTest',
          password_confirmation: 'TestTest'
        }
      end

      it 'returns a truthy value' do
        expect(user).to be_administrative
      end
    end

    context 'when a user has the reviewer role' do
      let(:user_params) do
        {
          name: 'Test User',
          role: 'editor',
          email: 'test@testuser.com',
          institution: 'Oregon State University',
          password: 'TestTest',
          password_confirmation: 'TestTest'
        }
      end

      it 'returns a truthy value' do
        expect(user).to be_administrative
      end
    end

    context 'when a user has the default role' do
      let(:user_params) do
        {
          name: 'Test User',
          role: 'default',
          email: 'test@testuser.com',
          institution: 'Oregon State University',
          password: 'TestTest',
          password_confirmation: 'TestTest'
        }
      end

      it 'returns a falsey value' do
        expect(user).not_to be_administrative
      end
    end
  end
end
