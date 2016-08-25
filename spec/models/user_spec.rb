require 'rails_helper'

RSpec.describe User, :type => :model do

  let(:user) { User.create(user_params)}
  let(:user_params) { {
                        :name => "Test User",
                        :role => "admin reviewer editor",
                        :email => "test@testuser.com",
                        :institution => "Oregon State University",
                        :password => "TestTest",
                        :password_confirmation => "TestTest"
                      }
  }

  it { should validate_presence_of(:institution) }
  it { should validate_presence_of(:role) }
  it { should validate_presence_of(:name) }


  context "When a user has all the roles" do
    it "Should be truthy for all user role methods" do
      expect(user.admin?).to be_truthy
      expect(user.reviewer?).to be_truthy
      expect(user.editor?).to be_truthy
    end
  end

  context "When a user has the editor and reviewer role" do
    let(:user_params) { {
      :name => "Test User",
      :role => "reviewer editor",
      :email => "test@testuser.com",
      :institution => "Oregon State University",
      :password => "TestTest",
      :password_confirmation => "TestTest"
    }
    }
    it "should be truthy for editor and reviewer methods but falsey for admin methods" do
      expect(user.admin?).to be_falsey
      expect(user.reviewer?).to be_truthy
      expect(user.editor?).to be_truthy
    end
  end

  context "When a user has the editor role" do
    let(:user_params) { {
      :name => "Test User",
      :role => "editor",
      :email => "test@testuser.com",
      :institution => "Oregon State University",
      :password => "TestTest",
      :password_confirmation => "TestTest"
    }
    }
    it "Should be truthy for editor method but falsey for admin and reviewer methods" do
      expect(user.admin?).to be_falsey
      expect(user.reviewer?).to be_falsey
      expect(user.editor?).to be_truthy
    end
  end
end
