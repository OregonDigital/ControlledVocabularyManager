# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "import_rdf/_form.html.erb" do
  let(:form) { ImportForm.new("url", "preview", RdfImporter) }

  before do
    render :partial => "import_rdf/form", :locals => {:form => form}
  end

  it "renders the shared errors partial" do
    expect(view).to render_template("shared/_errors")
  end

  it "posts to /import_rdf" do
    expect(rendered).to have_selector("form[action='/import_rdf'][method='post']")
  end

  it "has an import button" do
    expect(rendered).to have_button("Import JSON-LD")
  end

  it "has an input for the URL" do
    expect(rendered).to have_selector "input[name='import_form[url]'][type='url']"
  end

  it "has a checkbox for the preview flag" do
    expect(rendered).to have_selector "input[name='import_form[preview]'][type='checkbox']"
  end

  context "when the form has errors" do
    before do
      form.errors.add(:url, "isn't a cool enough website")
      render :partial => "import_rdf/form", :locals => {:form => form}
    end

    it "should render errors" do
      expect(rendered).to have_content(I18n.t("simple_form.error_notification.default_message"))
      expect(rendered).to have_content("isn't a cool enough website")
    end
  end
end
