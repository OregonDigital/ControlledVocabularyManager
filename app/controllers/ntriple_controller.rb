# frozen_string_literal: true

# Controls the ntriple editing logic
class NtripleController < AdminController
  
  def edit
    @term = params[:term_id]
    @file = File.open("#{Settings.cache_dir}/ns/#{params[:term_id]}.nt", 'r').read
  end

  def update
    reader = RDF::Reader.for(:ntriples).new(params[params["id"]]["ntriples"])
    reader = reader.validate!
    if reader.valid?
      # Commit triples to file and to BG
      redirect_to '/'
    else
      # Redirect back to form
    end
  end
end
