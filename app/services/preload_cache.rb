class PreloadCache

  def self.preload(term)

    FileUtils.mkdir_p( "#{Settings.cache_dir}/ns/#{term.term_uri_vocabulary_id}")
    write("#{Settings.cache_dir}/ns/#{term.id}.nt", term.full_graph.dump(:ntriples))
    write("#{Settings.cache_dir}/ns/#{term.id}.jsonld", term.full_graph.dump(:jsonld, standard_prefixes: true))
  end

  private
  def self.write(path, content)
    f = File.open(path, 'w')
    f.print(content)
    f.close
  end

end