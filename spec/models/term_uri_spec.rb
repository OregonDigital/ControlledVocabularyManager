# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TermUri do
  subject { TermUri.new(rdf_subject) }
  describe "#leaf" do
    # This is the case for a term with a vocab but no ID
    context "when given a path with a leading /" do
      let(:rdf_subject) { RDF::URI("http://bla.bla/ns/creators/") }
      it "should be empty" do
        expect(subject.leaf).to eq ""
      end
    end
    context "when given a term" do
      let(:rdf_subject) { RDF::URI("http://bla.bla/ns/creators/1") }
      it "should be 1" do
        expect(subject.leaf).to eq "1"
      end
    end
  end

  describe "#vocabulary_id" do
    context "when given a uri with a leading slash" do
      let(:rdf_subject) { RDF::URI("http://bla.bla/ns/creators/") }
      it "should be the vocab" do
        expect(subject.vocabulary_id).to eq "creators"
      end
    end
    context "when given a uri with a term" do
      let(:rdf_subject) { RDF::URI("http://bla.bla/ns/creators/1") }
      it "should be the vocab" do
        expect(subject.vocabulary_id).to eq "creators"
      end
    end
  end
end
