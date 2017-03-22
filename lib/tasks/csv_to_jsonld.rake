require 'csv'
require 'rdf'

desc "Transforms CSV to JSONLD for ingest. Use `rake transform:csv_to_jsonld[path_to_csv, path`"
namespace :transform do
  task :csv_to_jsonld, [:csv_path, :text_path] => :environment do |t, args|
    @csv_headers = ["id:id_hash", "vocabulary:uri", "label:string", "combined_dates:datetime"]

    #Verify arguments were provided
    check_args(args) 

    #Extract the headers and associate them to their indexes
    @headers_hash = extract_headers(args)

    #Build the graph and dump the jsonld
    @jsonld2 = build_graph2(args, @headers_hash)

    #Write the jsonld to a text file
    File.open(args[:text_path], 'w') { |file| file.write(@jsonld)}

  end
end

#Exit if args aren't provided
def check_args(args)
  unless args[:csv_path] 
    puts "Must provide full path to csv file. (e.g. /Users/username/Desktop/my_csv.csv"
    exit
  end

  unless args[:text_path] 
    puts "Must provide full path to empty text file. (e.g. /Users/username/Desktop/my_text_file.txt"
    exit
  end
end

#Pulls the headers from the CSV and relates them to their indexes for
#abstraction. Headers can now be in any order.
def extract_headers(args)

  #Pulls first row of CSV which is the headers
  @first_row = CSV.open(args[:csv_path], &:readline)
  @headers_hash = Hash.new

  #Iterate over the headers
  @first_row.each_with_index do |header, index|

    #Associate headers with their indexes
    @headers_hash[header] = index
  end

  #return the new header hash
  @headers_hash

end

#Builds the graph using rdf rather than using some tricky string substitution
#for normalization of JSONLD
def build_graph2(args, header_hash)
  #Generate Graph
  @graph = RDF::Graph.new

  #Check if Id column exists
  @no_id_column = header_hash.select { |k,v| k == "id:id_hash" }.empty?

  #Extract an id column and vocab column for use later. id isnt necessary but a
  #vocabulary is.
  @id_hash = header_hash.select { |k,v| k == "id:id_hash" }
  @vocab_hash = header_hash.select { |k,v| k == "vocabulary:uri" }

  #Vocabulary MUST be provided or no ingest can happen
  if @vocab_hash.empty? 
    puts "please provide a vocabulary you wish to relate this term to. i.e. http://opaquenamespace.org/ns/blah"
    puts "header should be in the form 'vocabulary:uri"
    exit
  end

  #Delete id and vocab from the list of headers. Special cases.
  header_hash.delete("id:id_hash")
  header_hash.delete("vocabulary:uri")

  #iterate over csv minus first row
  CSV.foreach(args[:csv_path]).drop(1).each do |row|

    #if no id column, mint an id and generate uri. Otherwise generate a uri
     if @no_id_column
       @id = id_hash2(nil, row[@vocabulary_hash["vocabulary:uri"]]) 
     else
       @id = id_hash2(row[@id_hash["id:id_hash"]],row[@vocab_hash["vocabulary:uri"]])
     end
  
     #Iterate over left over headers and build graph
     header_hash.keys.each do |header|
       send(header.split(":").last + "2", @id, @graph, row[header_hash[header]])
     end
  end
  puts @graph.dump(:jsonld)
end

def string2(id, graph, payload)
  graph << RDF::Statement.new(id, RDF::RDFS.label, payload) 
end

def datetime2(id, graph, payload)
  graph << RDF::Statement.new(id, RDF::Vocab::DC.date, payload) 
  graph << RDF::Statement.new(id, RDF::DC.issued, Date.today) 
end

def id_hash2(id, vocabulary)
  if id.nil?
    o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
    string = (0...7).map { o[rand(o.length)] }.join
    return uri2(string, vocabulary)
  end
  return uri2(id, vocabulary) 
end

def uri2(id, vocabulary)
  if vocabulary.last == "/"
    RDF::URI(vocabulary+id)
  else
    RDF::URI(vocabulary+"/"+id)
  end
end

def types2(id, graph, payload)
  graph << RDF::Statement.new(id, RDF.type, RDF::URI("http://www.w3.org/2004/02/skos/core#CorporateName")) 
  graph << RDF::Statement.new(id, RDF.type, RDF::URI("http://www.w3.org/2000/01/rdf-schema#Resource")) 
end

# def string(id, array_hash, graph, row)
#   graph << RDF::Statement.new(id, RDF::RDFS.label, row[array_hash["label"]]) 
# end
#
# def datetime(id, array_hash, graph, row)
#   graph << RDF::Statement.new(id, RDF::Vocab::DC.date, row[array_hash["combined_dates"]]) 
#   graph << RDF::Statement.new(id, RDF::DC.issued, Date.today) 
# end
#
# def id_hash2(id, array_hash, graph, row)
#   if id.nil?
#     o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
#     string = (0...7).map { o[rand(o.length)] }.join
#     return uri(string, array_hash, graph, row)
#   end
#   return uri(id, array_hash, graph, row) 
# end
#
# def id_hash(id, array_hash, graph, row)
#   if row[array_hash["id"]].nil?
#     o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
#     string = (0...7).map { o[rand(o.length)] }.join
#     row[array_hash["id"]] = string
#     return string
#   end
#   return uri(id, array_hash, graph, row) 
# end
#
# def uri(id, array_hash, graph, row)
#   RDF::URI("#{row[array_hash["vocabulary"]]}#{row[array_hash["id"]]}")
# end
#
# def types(id, array_hash, graph, row)
#   @graph << RDF::Statement.new(id, RDF.type, RDF::URI("http://www.w3.org/2004/02/skos/core#CorporateName")) 
#   @graph << RDF::Statement.new(id, RDF.type, RDF::URI("http://www.w3.org/2000/01/rdf-schema#Resource")) 
# end
#
# def build_graph(args, array_hash, headers)
#   #Generate Graph
#   @graph = RDF::Graph.new
#
#   #Iterate over CSV minus the first row
#   CSV.foreach(args[:csv_path]).drop(1).each do |row| 
#
#     #IF ID is nil then skip the term
#     unless row[array_hash["id"]].nil?
#
#       #Call the id_hash method and generate a "subject"
#       @id = send(headers.first.split(":").last, nil, array_hash, @graph, row)
#
#       #Iterate through the headers and generate their data
#       headers.each do |header|
#
#         #calls dynamic methods based on the datatype of the header
#         #i.e label:string calles the string method
#         send(header.split(":").last, @id, array_hash, @graph, row)
#       end
#
#       #appends types to the graph for consistency
#       types(@id, array_hash, @graph, row)
#     end
#   end
#   puts @graph.dump(:jsonld)
# end
#
