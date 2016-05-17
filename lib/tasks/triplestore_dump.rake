require 'triplestore_adapter'

app_root = File.expand_path('../../../', __FILE__)
git_path = File.join(app_root, "/tmp/git_data")

desc "Extract triples from triplestore and dump them to git directory as .nt files "
namespace :triplestore do
  task :dump_vocabularies_to_git => :environment do
    Dir.mkdir(git_path) unless File.exists?(git_path)

    vi = VocabularyInjector.new({})
    child_node_finder = ChildNodeFinder.new(vi.sparql_client)

    vocabs = vi.all_vocabs_query.call
    vocabs.each do |vocab|
      vocab_path = File.join(git_path, "/#{vocab.id}")
      vocab_file_path = "#{vocab_path}.nt"
      puts "Writing #{vocab_file_path}"
      File.write(vocab_file_path, "#{vocab.dump(:ntriples).split("\n").sort.join("\n")}\n")

      # Create a sub-directory for the vocabulary, and write each of its
      # children as ntriples
      Dir.mkdir(vocab_path) unless File.exists?(vocab_path)
      child_terms = child_node_finder.find_children(vocab)
      child_terms.each do |term|
        term_id = term.term_id.to_s.gsub("#{vocab.id}/", "")
        term_id.to_s.gsub!("/", "%2f") if term_id.include?("/")
        term_file_path = File.join(vocab_path, "/#{term_id}.nt")
        puts "Writing #{term_file_path}"
        File.write(term_file_path, "#{term.dump(:ntriples).split("\n").sort.join("\n")}\n")
      end
    end
  end
end
task :dump_predicates_to_git => :environment do
  Dir.mkdir(git_path) unless File.exists?(git_path)

  pi = PredicateInjector.new({})

  preds = pi.all_preds_query.call
  preds.each do |pred|
    pred_path = File.join(git_path, "/#{pred.id}")
    pred_file_path = "#{pred_path}.nt"
    puts "Writing #{pred_file_path}"
    File.write(pred_file_path, "#{pred.dump(:ntriples).split("\n").sort.join("\n")}\n")
  end
end
