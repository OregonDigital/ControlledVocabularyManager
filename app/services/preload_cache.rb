# frozen_string_literal: true

# Preload Cache
class PreloadCache
  def self.preload(term)
    FileUtils.mkdir_p("#{Settings.cache_dir}/ns/#{term.term_uri_vocabulary_id}")
    write("#{Settings.cache_dir}/ns/#{term.id}.nt", term.full_graph.dump(:ntriples))
    write("#{Settings.cache_dir}/ns/#{term.id}.jsonld", term.full_graph.dump(:jsonld, standard_prefixes: true))
  end

  def self.write_triples(triples, id)
    FileUtils.mkdir_p("#{Settings.cache_dir}/ns/#{id}")
    write("#{Settings.cache_dir}/ns/#{id}.nt", triples)
  end

  private

  def self.write(path, content)
    f = File.open(path, 'w')
    f.print(content)
    f.close
  end
end
