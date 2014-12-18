require 'rails_helper'

RSpec.describe VocabulariesController do
  describe "GET 'new'" do
    let(:result) { get 'new' }
    before do
      result
    end
    it "should be successful" do
      expect(result).to be_success
    end
    it "assigns @vocabulary" do
      assigned = assigns(:vocabulary)
      expect(assigned).to be_kind_of Vocabulary
      expect(assigned).to be_new_record
    end
    it "renders new" do
      expect(result).to render_template("new")
    end
  end
end
