# frozen_string_literal: true

require 'rails_helper'

#this test is kind of obsolete? but fixing it anyway
RSpec.describe TriplestoreRepository do
  subject { TriplestoreRepository.new(rdf_statement, Settings.triplestore_adapter.type, Settings.triplestore_adapter.url) }
  let(:url) { "http://opaquenamespace.org/ns/workType/aibanprints" }
  let(:rdf_uri) { RDF::URI.new(url) }
  let(:rdf_statement) { RDF::Statement.new(rdf_uri, "test", "test") }

  it "should clear all statements" do
    expect(subject.clear_statements).to be_truthy
  end

  it "should build a namespace" do
    expect(subject.build_namespace).to be_truthy
  end

  it "should not delete production namespace" do
    Rails.env = 'production'
    expect{ subject.delete_namespace }.to raise_error
    Rails.env = 'test'
  end

  it "should delete a statement" do
    subject.triplestore.client.insert([rdf_statement])
    expect(subject.delete(url)).to be_truthy
  end
end
