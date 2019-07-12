# frozen_string_literal: true

def capybara_login(user)
  visit "users/sign_in"
  fill_in 'user_email', with: user[:email]
  fill_in 'user_password', with: user[:password]
  click_button 'Log in'
  expect(page).to have_content('Jane Admin')
end
