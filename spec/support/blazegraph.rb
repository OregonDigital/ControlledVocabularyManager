# frozen_string_literal: true

WebMock.disable_net_connect!(:allow_localhost => Settings.triplestore_adapter.url)

ENV["RAILS_ENV"] ||= 'test'

BLAZEGRAPH_REPO ||= TriplestoreAdapter::Triplestore.new(TriplestoreAdapter::Client.new('blazegraph', Settings.triplestore_adapter.url))
BLAZEGRAPH_REPO.client.provider.delete_namespace(ENV["RAILS_ENV"])
BLAZEGRAPH_REPO.client.provider.build_namespace(ENV["RAILS_ENV"])

# ensure the triplestore namespace is clean for every test. ick.
RSpec.configure do |config|
  config.before do
    BLAZEGRAPH_REPO.delete_all_statements
  end
end
