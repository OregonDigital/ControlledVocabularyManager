require 'rails_helper'

RSpec.describe ImportRdfController, :type => :controller do
    let(:jsonld) { '{
    "@context": {
      "dc": "http://purl.org/dc/terms/",
          "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
              "skos": "http://www.w3.org/2004/02/skos/core#",
                  "xsd": "http://www.w3.org/2001/XMLSchema#"
                    },
                      "@id": "http://opaquenamespace.org/ns/workType/aibanprints",
    "@type": "skos:Concept",
    "dc:issued": {
        "@value": "2015-07-16",
        "@type": "xsd:date"
      },
    "dc:modified": {
          "@value": "2015-07-16",
          "@type": "xsd:date"
        },
    "rdfs:comment": {
            "@value": "Yamane, Y?z?; F?zokuga to Ukiyoe shi (Genshoku Nihon no Bijutsu, v.24), 1971. Japanese prints aproximately 34.5 x 22.5 cm or (9 x 13 in). ",
                "@language": "en"
          },
    "rdfs:isDefinedBy": {
              "@id": "http://opaquenamespace.org/VOCAB_PLACEHOLDER.nt"
            },
    "rdfs:label": {
                "@value": "aiban (prints)",
                    "@language": "en"
              }
  }'}
  let(:form_factory) { class_double("ImportForm") }
  let(:form) { instance_double("ImportForm") }
  let(:load_form) { instance_double("LoadForm") }
  let(:url) { "http://example.com" }
  let(:preview) { "0" }
  let(:params) do
    {:import_form => {:url => url, :preview => preview}}
  end

  let(:load_params) do
    {:load_form => {:rdf_string => jsonld}}
  end
  before do
    allow(ImportForm).to receive(:new).with(url, preview, RdfImporter).and_return(form)
    allow(LoadForm).to receive(:new).with(jsonld, RdfImporter).and_return(load_form)
  end

  describe "GET 'index'" do
    context "when logged out" do
      xit "should require login" do
        get :index
        expect(response.body).to have_content("Only admin can access")
      end

      xit "shouldn't create the ImportForm" do
        expect(ImportForm).not_to receive(:new)
        get :index
      end
    end

    context "when logged in" do
      let(:user) { User.create(:email => 'blah@blah.com', :password => "admin123",:role => "admin")}
      before do
        allow_any_instance_of(AdminController).to receive(:require_admin).and_return(true)
        expect(ImportForm).to receive(:new).with(nil, nil, RdfImporter).and_return(form)
      end

      xit "should render the index template" do
        get :index
        expect(response).to render_template("index")
      end

      xit "should assign the new form for the view to use" do
        get :index
        expect(assigns[:form]).to eq(form)
      end
    end
  end

  describe "POST 'import'" do
    context "when logged out" do
      xit "should require login" do
        post :import, params
        expect(response.body).to have_content("Only admin can access")
      end
    end

    context "when logged in" do
      let(:user) { User.create(:email => 'blah@blah.com', :password => "admin123",:role => "admin")}
      before do
        allow_any_instance_of(AdminController).to receive(:require_admin).and_return(true)
      end
      context "and the form doesn't save" do
        before do
          expect(form).to receive(:save).and_return(false)
          post :import, params
        end

        xit "should assign the form" do
          expect(assigns(:form)).to eq(form)
        end

        xit "should render the index" do
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

          xit "should render the preview page" do
            expect(response).to render_template("preview_import")
          end

          xit "should assign terms and vocabulary" do
            expect(assigns[:vocabulary]).to eq(term1)
            expect(assigns[:terms]).to eq([term2, term3, term4])
          end
        end

        context "and the form is not requesting a preview" do
          before do
            expect(form).to receive(:preview?).and_return(false)
            post :import, params
          end

          xit "should show the first term imported" do
            expect(response).to redirect_to term_path(term1.id)
          end
        end
      end
    end
  end
  describe "GET 'load'" do
    context "when logged out" do
      let(:logged_in) { false }
      xit "should require login" do
        get :load
        expect(response.body).to eq("Only admin can access")
      end

      xit "shouldn't create the LoadForm" do
        expect(LoadForm).not_to receive(:new)
        get :load
      end
    end

    context "when logged in" do
      before do
        allow_any_instance_of(AdminController).to receive(:require_admin).and_return(true)
        expect(LoadForm).to receive(:new).with(nil, RdfImporter).and_return(load_form)
      end

      xit "should render the load template" do
        get :load
        expect(response).to render_template("load")
      end

      xit "should assign the new form for the view to use" do
        get :load
        expect(assigns[:form]).to eq(load_form)
      end
    end
  end
  describe "POST 'save'" do
    context "when logged out" do
      let(:logged_in) { false }
      xit "should require login" do
        post :save, load_params
        expect(response.body).to eq("Only admin can access")
      end
    end

    context "when logged in" do
      context "and the form doesn't save" do
        before do
          allow_any_instance_of(AdminController).to receive(:require_admin).and_return(true)
          expect(load_form).to receive(:save).and_return(false)
          post :save, load_params
        end

        xit "should assign the form" do
          expect(assigns(:form)).to eq(load_form)
        end

        xit "should render the load" do
          expect(response).to render_template("load")
        end
      end

      context "and the form saves" do
        let(:term1) { instance_double("Vocabulary", :id => "vocab") }
        let(:terms) { [term1] }
        let(:termlist) { instance_double("ImportableTermList") }
        context "and the form is posted with valid jsonld" do
          before do
            allow_any_instance_of(AdminController).to receive(:require_admin).and_return(true)
            expect(load_form).to receive(:save).and_return(true)
            expect(load_form).to receive(:term_list).and_return(termlist)
            expect(termlist).to receive(:terms).and_return(terms)
          end

          xit "should show the first term imported" do
            post :save, load_params
            expect(response).to redirect_to term_path(terms.first.id)
          end
        end
      end
    end
  end
end
