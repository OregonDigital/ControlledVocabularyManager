# frozen_string_literal: true

# Controls the ntriple editing logic
class NtripleController < AdminController
  
  def edit
    @term = params[:term_id]
    @file = File.open("#{Settings.cache_dir}/ns/#{params[:term_id]}.nt", 'r').read
  end

  def update
    binding.pry
    reader = RDF::Reader.for(:ntriples).new(params[params["id"]]["ntriples"])
    reader = reader.validate!
    if reader.valid?
      PreloadCache.write_triples(params[params["id"]]["ntriples"], params["id"])
      # Commit triples to file and to BG
      flash[:success] = "NTriples for #{ params["id"] } has been updated successfully"
      redirect_to '/'
    else
      # Redirect back to form
      redirect_to "/ntriples/#{params["id"]}"
    end
  end
end
