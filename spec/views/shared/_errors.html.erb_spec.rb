require 'rails_helper'

RSpec.describe "shared/_errors.html.erb" do
  let(:object) { ImportForm.new(nil, nil, RdfImporter) }

  context "when there are no errors" do
    it "should render nothing" do
      render :partial => "shared/errors", :locals => {:object => object}
      expect(rendered).to eq("")
    end
  end

  context "when there are errors on attributes" do
    before do
      object.errors.add(:attr1, "error on attr one")
      object.errors.add(:attr2, "error on attr two")

      render :partial => "shared/errors", :locals => {:object => object}
    end

    it "should render the default message" do
      expect(rendered).to have_content(I18n.t("simple_form.error_notification.default_message"))
    end

    it "should not render attribute errors" do
      expect(rendered).not_to have_content("error on")
    end
  end

  context "when there are errors on base" do
    before do
      object.errors.add(:base, "There is a problem with your code")
      object.errors.add(:base, "There is a problem with your logic")

      render :partial => "shared/errors", :locals => {:object => object}
    end

    it "should render the default message" do
      expect(rendered).to have_content(I18n.t("simple_form.error_notification.default_message"))
    end

    it "should render each base error" do
      %w|code logic|.each do |errortxt|
        expect(rendered).to have_content("There is a problem with your %s" % errortxt)
      end
    end
  end
end
