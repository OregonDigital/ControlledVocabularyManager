MARMOTTA_REPO ||= Marmotta::Connection.new(uri: Settings.marmotta.url, context: Rails.env)
RSpec.configure do |config|
  config.before do
    MARMOTTA_REPO.delete_all
  end
end
