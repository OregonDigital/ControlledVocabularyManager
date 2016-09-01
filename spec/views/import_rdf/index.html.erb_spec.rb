require 'rails_helper'

RSpec.describe "import_rdf/index.html.erb" do
  let(:form) { ImportForm.new(nil, nil, RdfImporter) }

  before do
    assign(:form, form)
    render
  end

  xit "renders the form partial with the import form" do
    expect(view).to render_template(:partial => "form", :locals => {:form => form})
  end
end
