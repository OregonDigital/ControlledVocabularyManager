require 'rails_helper'

RSpec.describe ImportForm do
  let(:opts) { Hash.new }
  let(:form) { ImportForm.new(opts) }

  it "should require a url" do
    expect(form).to be_invalid
    expect(form.errors.count).to eq 1
    expect(form.errors[:url]).to eq ["can't be blank"]
  end

  describe "#preview?" do
    context "when preview is '1'" do
      before do
        opts[:preview] = "1"
      end

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
