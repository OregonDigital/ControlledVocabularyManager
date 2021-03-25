# frozen_string_literal: true

require 'webmock/rspec'
RSpec.configure do |config|
  config.before(:each, type: :feature) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  config.before do
    stub_request(:get, 'http://opaquenamespace.org/ns/TESTTEST')
      .with(
        headers: {
          'Accept' => 'application/ld+json, application/x-ld+json, application/n-triples, text/plain;q=0.5, application/n-quads, text/x-nquads, */*;q=0.1',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host' => 'opaquenamespace.org',
          'User-Agent' => 'rest-client/2.1.0 (linux-gnu x86_64) ruby/2.5.1p57'
        }
      )
      .to_return(status: 200,
                 headers: {},
                 body: '<http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/issued> "2016-08-23"^^<http://www.w3.org/2001/XMLSchema#date> .
                        <http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/modified> "2016-08-23"^^<http://www.w3.org/2001/XMLSchema#date> .
                        <http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/publisher> "asfsdafdsf"@cr .
                        <http://opaquenamespace.org/ns/TESTTEST> <http://purl.org/dc/terms/title> "asdfsdfsadf"@fo .
                        <http://opaquenamespace.org/ns/TESTTEST> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/dc/dcam/VocabularyEncodingScheme> .')
  end
end
