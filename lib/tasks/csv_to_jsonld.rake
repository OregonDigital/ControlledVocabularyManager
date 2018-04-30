require 'csv'
require 'rdf'

# Example CSV file, first 2 rows:
# vocabulary:uri,id:id_hash,label,type,comment
# http://opaquenamespace.org/ns/creator,MooreJannaFalk,"Moore, Janna (Falk)",http://www.w3.org/2004/02/skos/core#PersonalName,Oregon Century Farm and Ranch Collection

desc "Transforms CSV to JSON-LD, can use for Load RDF. Use `rake transform:csv_to_jsonld[path_to_csv, path_to_export_file]`"
namespace :transform do
  task :csv_to_jsonld, [:csv_path, :output_path] => :environment do |t, args|

    #Verify arguments were provided
    check_args(args)

    #Extract the headers and associate them to their indexes
    @headers_hash = extract_headers(args)

    #Build the graph and dump the jsonld
    @jsonld = build_graph(args, @headers_hash)

    puts @jsonld

    #Write the jsonld to a text file
    File.open(args[:output_path], 'w') { |file| file.write(@jsonld)}

    puts "JSON-LD written to: " + args[:output_path]
  end
end

#Exit if args aren't provided
def check_args(args)
  unless args[:csv_path]
    puts "Must provide full path to csv file. (e.g. /Users/username/Desktop/my_csv.csv)"
    exit
  end

  unless args[:output_path]
    puts "Must provide full path to empty text file. (e.g. /Users/username/Desktop/my_text_file.txt)"
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

#Builds the graph using rdf for normalization of JSON-LD
def build_graph(args, header_hash)
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
    puts "A vocabulary needs to be specified for this term i.e. http://opaquenamespace.org/ns/creator"
    puts "Header row value should be in the form 'vocabulary:uri'"
    exit
  end

  #Delete id and vocab from the list of headers. Special cases.
  header_hash.delete("id:id_hash")
  header_hash.delete("vocabulary:uri")

  #iterate over csv minus first row
  CSV.foreach(args[:csv_path]).drop(1).each do |row|

    #if no id column, mint an id and generate uri. Otherwise generate a uri
     if @no_id_column
       @id = id_hash(nil, row[@vocab_hash["vocabulary:uri"]])
     else
       @id = id_hash(row[@id_hash["id:id_hash"]],row[@vocab_hash["vocabulary:uri"]])
     end

     #Iterate over left over headers and send to methods to build graph
     header_hash.keys.each do |header|
       send(header.split(":").last, @id, @graph, row[header_hash[header]])
     end

    @graph << RDF::Statement.new(@id, RDF::Vocab::DC.issued, RDF::Literal.new(Date.today))

  end
  @graph.dump(:jsonld)
end

def label(id, graph, payload)
  graph << RDF::Statement.new(id, RDF::RDFS.label, RDF::Literal.new(payload, :language => :en))
end

def date(id, graph, payload)
  graph << RDF::Statement.new(id, RDF::Vocab::DC.date, RDF::Literal.new(payload)) if payload
end

def id_hash(id, vocabulary)
  if id.nil?
    o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
    string = (0...8).map { o[rand(o.length)] }.join
    return uri(string, vocabulary)
  end
  return uri(id, vocabulary)
end

def uri(id, vocabulary)
  if vocabulary.last == "/"
    RDF::URI(vocabulary + id)
  else
    RDF::URI(vocabulary + "/" + id)
  end
end

def type(id, graph, payload)
  graph << RDF::Statement.new(id, RDF.type, RDF::URI(payload)) if payload
  graph << RDF::Statement.new(id, RDF.type, RDF::URI("http://www.w3.org/2000/01/rdf-schema#Resource"))
end

def comment(id, graph, payload)
  graph << RDF::Statement.new(id, RDF::RDFS.comment, RDF::Literal.new(payload, :language => :en)) if payload
end
