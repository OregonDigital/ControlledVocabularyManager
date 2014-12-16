require 'rails_helper'

RSpec.describe HomeController do
  describe "authorization" do
    let(:user) { github_login(:user) }
    context "when user is not signed in" do
      before do
        get 'index'
      end
      it "should not be found" do
        expect(response).to be_not_found
      end
    end
  end
end
