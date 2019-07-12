# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorPropagator do
  let(:object) { double("object", :valid? => valid) }
  let(:errors) { instance_double("ActiveModel::Errors") }
  let(:limit) { 20 }
  let(:propagator) { ErrorPropagator.new(object, errors, limit) }

  describe "#run" do
    context "when the object is valid" do
      let(:valid) { true }
      it "shouldn't touch errors" do
        expect(errors).not_to receive(:add)
        propagator.run
      end
    end

    context "when the object is invalid" do
      let(:valid) { false }
      let(:full_messages) { (1..12).to_a }
      let(:object_errors) { instance_double("ActiveModel::Errors", :full_messages => full_messages) }

      before do
        allow(object).to receive(:errors).and_return(object_errors)
      end

      context "when no limit is requested" do
        it "should push up all errors" do
          full_messages.each do |message|
            expect(errors).to receive(:add).with(:base, message)
          end
          propagator.run
        end
      end

      context "when a limit is requested" do
        context "and the number of errors exceeds the limit" do
          let(:limit) { 2 }

          it "should push up errors below the limit, and the 'further errors suppressed' message" do
            expect(errors).to receive(:add).with(:base, full_messages[0])
            expect(errors).to receive(:add).with(:base, full_messages[1])
            expect(errors).to receive(:add).with(:base, "Further errors exist but were suppressed")
            propagator.run
          end
        end

        context "and the number of errors doesn't exceed the limit" do
          let(:limit) { 20 }
          it "should push up all errors" do
            full_messages.each do |message|
              expect(errors).to receive(:add).with(:base, message)
            end
            propagator.run
          end
        end
      end
    end
  end
end
