require 'rails_helper'

RSpec.describe "import_rdf/_form.html.erb" do
  let(:form) { ImportForm.new("url", "preview", RdfImporter) }

  before do
    render :partial => "import_rdf/form", :locals => {:form => form}
  end

  xit "renders the shared errors partial" do
    expect(view).to render_template("shared/_errors")
  end

  xit "posts to /import_rdf" do
    expect(rendered).to have_selector("form[action='/import_rdf'][method='post']")
  end

  xit "has an import button" do
    expect(rendered).to have_button("Import JSON-LD")
  end

  xit "has an input for the URL" do
    expect(rendered).to have_selector "input[name='import_form[url]'][type='url']"
  end

  xit "has a checkbox for the preview flag" do
    expect(rendered).to have_selector "input[name='import_form[preview]'][type='checkbox']"
  end

  context "when the form has errors" do
    before do
      form.errors.add(:url, "isn't a cool enough website")
      render :partial => "import_rdf/form", :locals => {:form => form}
    end

    xit "should render errors" do
      expect(rendered).to have_content(I18n.t("simple_form.error_notification.default_message"))
      expect(rendered).to have_content("isn't a cool enough website")
    end
  end
end
