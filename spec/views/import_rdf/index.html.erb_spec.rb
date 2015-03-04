require 'rails_helper'

RSpec.describe "import_rdf/index.html.erb" do
  let(:form) { ImportForm.new }

  before do
    assign(:form, form)
    render
  end

  it "renders the form with the form" do
    expect(view).to render_template(:partial => "form", :locals => {:form => form})
  end
end
