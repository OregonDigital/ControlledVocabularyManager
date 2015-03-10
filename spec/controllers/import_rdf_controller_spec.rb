require 'rails_helper'

RSpec.describe ImportRdfController, :type => :controller do
  let(:logged_in) { true }
  let(:form_factory) { class_double("ImportForm") }
  let(:form) { instance_double("ImportForm") }

  before do
    allow(controller).to receive(:check_auth).and_return(true) if logged_in
    allow(controller).to receive(:form_factory).and_return(form_factory)
    allow(form_factory).to receive(:new).and_return(form)

    expect(controller).not_to receive(:injector)
  end

  describe "GET 'index'" do
    context "when logged out" do
      let(:logged_in) { false }
      it "should require login" do
        get :index
        expect(response).to redirect_to login_path
      end
    end

    it "should render the index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "should assign the new form for the view to use" do
      get :index
      expect(assigns[:form]).to eq(form)
    end
  end

  describe "POST 'import'" do
    let(:url) { "http://example.com" }
    let(:params) do
      {:import_form => {:url => url}}
    end

    context "when logged out" do
      let(:logged_in) { false }
      it "should require login" do
        post :import, params
        expect(response).to redirect_to login_path
      end
    end

    context "when logged in" do
      let(:form_params) { params[:import_form] }

      before do
        expect(controller).to receive(:form_params).and_return(form_params)
      end

      context "and the form doesn't save" do
        before do
          expect(form).to receive(:save).and_return(false)
          post :import, params
        end

        it "should assign the form" do
          expect(assigns(:form)).to eq(form)
        end

        it "should render the index" do
          expect(response).to render_template("index")
        end
      end

      context "and the form saves" do
        let(:term1) { instance_double("Vocabulary", :id => "vocab") }
        let(:term2) { instance_double("Term", :id => "vocab/one") }
        let(:term3) { instance_double("Term", :id => "vocab/two") }
        let(:term4) { instance_double("Term", :id => "vocab/three") }
        let(:terms) { [term1, term2, term3, term4] }
        let(:termlist) { instance_double("ImportableTermList") }

        before do
          expect(form).to receive(:save).and_return(true)
          expect(form).to receive(:term_list).and_return(termlist)
          expect(termlist).to receive(:terms).and_return(terms)
        end

        context "and the form is requesting a preview" do
          before do
            expect(form).to receive(:preview?).and_return(true)
            post :import, params
          end

          it "should render the preview page" do
            expect(response).to render_template("preview_import")
          end

          it "should assign terms and vocabulary" do
            expect(assigns[:vocabulary]).to eq(term1)
            expect(assigns[:terms]).to eq([term2, term3, term4])
          end
        end

        context "and the form is not requesting a preview" do
          before do
            expect(form).to receive(:preview?).and_return(false)
            post :import, params
          end

          it "should show the first term imported" do
            expect(response).to redirect_to term_path(term1.id)
          end
        end
      end
    end
  end
end
