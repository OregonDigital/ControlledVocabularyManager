namespace :clean_up_terms do
  task :osubuildings_vocab => :environment do
    parent = Term.find("http://opaquenamespace.org/ns/osuBuildings")
    children = ChildNodeFinder.new(VocabularyInjector.new.sparql_client).find_children(parent)
    repository = TriplestoreRepository.new(nil, 'blazegraph', Settings.triplestore_adapter.url)
    children.each do |child|
      id_str = child.id.to_s
      if !(id_str.split("/").last.to_s.match(/^[a-zA-Z0-9]+$/))
        puts "terms found with invalid ids:\n"
        # "example of invalid id: osuBuildings/CentroCulturalCï¿½sarChï¿½vez"
        puts "\t#{id_str}\n"
        # 1. duplicate term to fix the id
        # TODO: implement duplicating a term with invalid ids
        # puts "duplicating term with valid id \t#{id_str}\n"

        # 2. delete the existing term with invalid id
        # TODO: uncomment bellow when (1) is ready
        # repository.delete(child.term_uri.uri.to_s)
        # puts "deleting term \t#{id_str}\n"
      else
        puts "no terms found with invalid ids:\n"
      end
    end
  end
end
