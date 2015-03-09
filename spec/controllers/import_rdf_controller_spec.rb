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

      context "and the form is invalid" do
        before do
          expect(form).to receive(:valid?).and_return(false)
          post :import, params
        end

        it "should assign the form" do
          expect(assigns(:form)).to eq(form)
        end

        it "should render the index" do
          expect(response).to render_template("index")
        end
      end

      context "and the form is valid" do
        let(:url_to_graph) { double("url_to_graph") }
        let(:graph_to_termlist) { double("graph_to_termlist") }
        let(:graph) { instance_double("RDF::Graph") }
        let(:termlist) { instance_double("ImportableTermList") }
        let(:errors) { ActiveModel::Errors.new(form) }

        before do
          expect(form).to receive(:valid?).and_return(true)
          expect(controller).to receive(:url_to_graph).and_return(url_to_graph)
          expect(form).to receive(:url).at_least(:once).and_return(url)
          allow(form).to receive(:errors).and_return(errors)
        end

        context "and a graph cannot be created from the given URL" do
          before do
            expect(url_to_graph).to receive(:call).with(url) { raise StandardError.new "foo is bad, man" }
            post :import, params
          end

          it "should render the index" do
            expect(response).to render_template("index")
          end

          it "should add an error to the form" do
            expect(form.errors.count).to eq(1)
            expect(form.errors[:base][0]).to match("Unable to retrieve valid RDF")
          end
        end

        context "and a graph can be created from the URL" do
          before do
            expect(url_to_graph).to receive(:call).with(url).and_return(graph)
            expect(controller).to receive(:graph_to_termlist).and_return(graph_to_termlist)
            expect(graph_to_termlist).to receive(:call).with(graph).and_return(termlist)
          end

          context "and the termlist is invalid" do
            let(:termlist_errors) { double("termlist errors") }
            before do
              expect(termlist).to receive(:valid?).and_return(false)
              expect(termlist).to receive(:errors).and_return(termlist_errors)
              expect(termlist_errors).to receive(:full_messages).and_return([1,2,3,4,5,6,7,8,9,10,11,12])
              post :import, params
            end

            it "should render the index" do
              expect(response).to render_template("index")
            end

            it "should add termlist's errors to the form" do
              0.upto(9) do |index|
                expect(form.errors[:base][index]).to eq(index + 1)
              end
            end

            it "should only add the first ten errors to the form" do
              expect(form.errors.count).to eq(11)
              expect(form.errors[:base][10]).to eq("Further errors exist but were suppressed")
            end
          end

          context "and the termlist is valid" do
            let(:term1) { instance_double("Vocabulary", :id => "vocab") }
            let(:term2) { instance_double("Term", :id => "vocab/one") }
            let(:term3) { instance_double("Term", :id => "vocab/two") }
            let(:term4) { instance_double("Term", :id => "vocab/three") }
            let(:terms) { [term1, term2, term3, term4] }

            before do
              expect(termlist).to receive(:valid?).and_return(true)
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
                allow(termlist).to receive(:save)
                post :import, params
              end

              it "should save the term list" do
                expect(termlist).to have_received(:save)
              end

              it "should show the first term imported" do
                expect(response).to redirect_to term_path(term1.id)
              end
            end
          end
        end
      end
    end
  end
end
