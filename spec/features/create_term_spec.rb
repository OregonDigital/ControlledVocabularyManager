require 'rails_helper'
require 'support/test_git_setup'

RSpec.feature "Create and update a Term", :js => true, :type => :feature do
  include TestGitSetup
  given(:user) { User.create(:email => 'admin@example.com', :name => "Jane Admin", :password => 'admin123', :role => "admin editor reviewer", :institution => "Oregon State University") }
  let(:user_params) { {:email => 'admin@example.com', :name => "Jane Admin", :password => 'admin123', :role => "admin editor reviewer", :institution => "Oregon State University"} }

  background do
    allow_any_instance_of(AdminController).to receive(:current_user).and_return(user)
    allow(user).to receive(:admin?).and_return(true)
  end

  let(:datetime_now) { DateTime.now.strftime('%Y%m%dT%H%M%S') }
  let(:vocabulary_id) { VocabularyCreatePage.id + datetime_now }

  scenario "adds a new term to a vocabulary" do
    WebMock.allow_net_connect!
    setup_git

    user
    sign_in user
    visit "/vocabularies/new"
    fill_in('vocabulary[id]', with: vocabulary_id)
    find_button('Create Vocabulary').trigger('click')
    sleep 2
    visit "/review/#{vocabulary_id}"
    find_link('review').click
    sleep 2

    visit "/vocabularies/#{vocabulary_id}/new"
    fill_in "ID", :with => TermCreatePage.id
    fill_in "vocabulary[label][]", :with => "Test label"
    fill_in "vocabulary[comment][]", :with => "Test comment"
    within('div.term_type') do
      find("select#term_type option[value='PersonalName']").select_option
    end
    Capybara.using_wait_time(180) do
      find_button('Create Term').trigger('click')
    end
    sleep 2

    visit '/review'
    term_review_index_page = TermReviewIndexPage.new("#{vocabulary_id}/TestTerm")
    expect (term_review_index_page).has_content? "Test label"

    term_review_show_page = term_review_index_page.select
    expect (term_review_show_page).has_content? "Test comment"
    term_review_show_page.edit
    fill_in "vocabulary[alternate_name][]", :with => "Test alt"
    find_button('Update PersonalName').trigger('click')
    sleep 2

    term_review_show_page = term_review_index_page.select
    #expect(term_review_show_page.html).to match("added: &lt;http://schema.org/alternateName&gt; \"Test alt\"")

    term_review_show_page.mark
    expect(page).to have_content "#{vocabulary_id}/TestTerm has been saved and is ready for use."
    term_statement_list = Term.find("#{vocabulary_id}/#{TermCreatePage.id}").statements.each.map { |x| x }
    comments = term_statement_list.select { |s| s.predicate == "http://www.w3.org/2000/01/rdf-schema#comment" }
    expect(comments.any? {|c| c.object.value == "Test comment" && c.object.language == :en }).to be_truthy
    labels = term_statement_list.select { |s| s.predicate == "http://www.w3.org/2000/01/rdf-schema#label" }
    expect(labels.any? {|l| l.object.value == "Test label" && l.object.language == :en }).to be_truthy

    types = term_statement_list.select { |s| s.predicate == "http://www.w3.org/1999/02/22-rdf-syntax-ns#type" }
    expect(types.any? {|t| t.object.to_s == "http://www.w3.org/2004/02/skos/core#PersonalName" }).to be_truthy
    expect(types.any? {|t| t.object.to_s == "http://www.w3.org/2000/01/rdf-schema#Resource" }).to be_truthy

    if Dir.exists? ControlledVocabularyManager::Application::config.rugged_repo
      FileUtils.rm_rf(ControlledVocabularyManager::Application::config.rugged_repo)
    end
  end
end
