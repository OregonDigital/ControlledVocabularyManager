desc "Reindex everything"
namespace :sunspot do
  task :reindex => :environment do
    pi = PredicateInjector.new({})
    predicates = pi.all_preds_query.call
    puts "Reindexing Predicates: " + predicates.count.to_s
    Sunspot.index! predicates

    vi = VocabularyInjector.new({})
    vr = vi.vocabulary_repository

    vocabs = vi.all_vocabs_query.call
    puts "Reindexing Vocabularies: " + vocabs.count.to_s
    Sunspot.index! vocabs

    vocabs.each do |v|
      puts "  Reindexing " + (v.title.first ? v.title.first.to_s : v.label.first.to_s)
      puts "    Child Terms: " + vr.find(v.id).children.count.to_s
      Sunspot.index! vr.find(v.id).children
    end
  end
end
