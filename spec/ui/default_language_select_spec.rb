require 'rails_helper'

RSpec.feature "Using a language SELECT with a default language set", :js => true do

  let(:user1) { User.create(:email => 'admin@example.com', :name => 'Jane Admin', :password => "admin123",:role => "admin editor reviewer", :institution => "Oregon State University")}
  let(:user_params) { {:email => 'admin@example.com', :name => "Jane Admin", :password => 'admin123', :role => "admin editor reviewer", :institution => "Oregon State University"} }

  background do
    allow_any_instance_of(AdminController).to receive(:current_user).and_return(user1)
    allow(user1).to receive(:admin?).and_return(true)
  end

  scenario "adding another label defaults language select to english" do
    WebMock.allow_net_connect!
    user1
    sign_in user1
    visit "/vocabularies/new"
    within('.vocabulary_label') do
      find(".language-select option[value='es']").select_option
      expect(find(".language-select option[value='es']")).to be_selected
      click_button("Add")
    end
    within('.vocabulary_label ul.listing li:nth-child(2)') do
      expect(find(".language-select option[value='en']")).to be_selected
    end
  end
end
