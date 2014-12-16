require 'rails_helper'

RSpec.describe HomeController do
  describe "authorization" do
    let(:user) { github_login(:admin) }
    context "when user is not signed in" do
      before do
        user
        get 'index'
      end
      xit "should redirect to oauth" do
        expect(response).to be_github_oauth_redirect
      end
    end
  end
end
