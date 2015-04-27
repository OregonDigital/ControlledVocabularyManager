require 'rails_helper'
require 'terms_are_importable'

RSpec.describe ImportableTerm do
  it "should not validate with TermIsUnique" do
    expect(described_class.validators).not_to include TermIsUnique
  end
end
