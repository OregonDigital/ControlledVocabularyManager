require 'rails_helper'

RSpec.describe ImportForm do
  let(:url) { "http://example.com" }
  let(:preview) { "0" }
  let(:opts) do
    {:url => url, :preview => preview}
  end
  let(:form) { ImportForm.new(opts) }
  let(:url_to_graph) { double("url_to_graph") }
  let(:graph) { instance_double("RDF::Graph") }
  let(:graph_to_termlist) { double("graph_to_termlist") }
  let(:termlist) { instance_double("ImportableTermList") }

  before do
    allow(form).to receive(:url_to_graph).and_return(url_to_graph)
    allow(url_to_graph).to receive(:call).with(form.url).and_return(graph)
    allow(graph).to receive(:empty?).and_return(false)

    allow(form).to receive(:graph_to_termlist).and_return(graph_to_termlist)
    allow(graph_to_termlist).to receive(:call).with(graph).and_return(termlist)
    allow(termlist).to receive(:valid?).and_return(true)

    expect(form).not_to receive(:injector)
  end

  describe "validations" do
    context "when the URL is http" do
      it "should be valid" do
        expect(form).to be_valid
      end
    end

    context "when the URL is https" do
      let(:url) { "https://example.com" }

      it "should be valid" do
        expect(form).to be_valid
      end
    end

    context "when the URL isn't an allowed scheme" do
      let(:url) { "gopher://example.com" }

      it "should be invalid" do
        expect(form).not_to be_valid
      end

      it "should have errors" do
        form.valid?
        expect(form.errors.count).to eq 1
        expect(form.errors[:url]).to eq ["is not an allowed RDF import URL"]
      end
    end

    context "when the URL isn't parseable" do
      let(:url) { "This isn't a URI" }

      it "should be invalid" do
        expect(form).not_to be_valid
      end

      it "should have errors" do
        form.valid?
        expect(form.errors.count).to eq 1
        expect(form.errors[:url]).to eq ["is not a URL"]
      end
    end

    context "when the URL is missing" do
      let(:url) { nil }

      it "should be invalid" do
        expect(form).not_to be_valid
      end

      it "should have errors" do
        form.valid?
        expect(form.errors.count).to eq 1
        expect(form.errors[:url]).to eq ["can't be blank"]
      end
    end
  end

  describe "#graph" do
    it "should return the graph built by the url_to_graph service" do
      expect(form.graph).to eq(graph)
    end

    context "when the graph is empty" do
      before do
        expect(graph).to receive(:empty?).and_return(true)
      end

      it "should add an error" do
        form.graph
        expect(form.errors.count).to eq(1)
        expect(form.errors[:url]).to eq(["must resolve to valid RDF"])
      end
    end
  end

  describe "#term_list" do
    it "should return the term list build by the graph_to_termlist service" do
      expect(form.term_list).to eq(termlist)
    end

    context "when the term list has errors" do
      let(:errors) { double("errors") }
      let(:full_messages) { (1..12).to_a }
      before do
        expect(termlist).to receive(:valid?).and_return(false)
        allow(termlist).to receive(:errors).and_return(errors)
        allow(errors).to receive(:full_messages).and_return(full_messages)
        form.term_list
      end

      it "should add errors to the form" do
        expect(form.errors.count).to be > 0
      end

      it "should only add the first ten errors" do
        expect(form.errors.count).to eq(11)
        0.upto(9) {|i| expect(form.errors[:base][i]).to eq(i+1)}
        expect(form.errors[:base][10]).to eq("Further errors exist but were suppressed")
      end
    end
  end

  describe "#preview?" do
    context "when preview is '1'" do
      let(:preview) { "1" }

      it "should return true" do
        expect(form.preview?).to eq(true)
      end
    end

    context "when preview isn't '1'" do
      it "should return false" do
        ["0", "one", "true", true].each do |val|
          form.preview = val
          expect(form.preview?).to eq(false)
        end
      end
    end
  end
end
