module PreloadCache
  extend ActiveSupport::Concern

  def preload(term)
    if term.id.include?('/')
      arr = term.id.split('/')
      pathtofile = "#{Settings.cache_dir}/ns/#{arr[0]}"
      FileUtils.mkdir_p(pathtofile)
      id = arr[1]
    else
      pathtofile = "#{Settings.cache_dir}/ns/"
      id = term.id
    end
    write("#{pathtofile}/#{id}.nt", term.full_graph.dump(:ntriples))
    write("#{pathtofile}/#{id}.jsonld", term.full_graph.dump(:jsonld, standard_prefixes: true))
  end

  def write(path, content)
    f = File.open(path, 'w')
    f.print(content)
    f.close
  end

end