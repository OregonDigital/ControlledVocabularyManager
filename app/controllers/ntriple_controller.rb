# frozen_string_literal: true

# Controls the ntriple editing logic
class NtripleController < AdminController
  
  def edit
    @term = params[:term_id]
    @file = File.open("#{Settings.cache_dir}/ns/#{params[:term_id]}.nt", 'r').read
  end

  def update

  end
end
