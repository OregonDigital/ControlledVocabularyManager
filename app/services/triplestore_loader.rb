# frozen_string_literal: true

require 'rdf_loader'
require 'triplestore_adapter'

class TriplestoreLoader

  attr_accessor :triplestore, :type, :url, :errors, :mismatches, :write_report, :update_triplestore, :write_update_file, :output_path

  ##
  # Initializes a TriplestoreLoader to process RDF files
  #
  # @param args [Hash]
  def initialize(args)
    @start_datetime = DateTime.now.to_s(:number)
    @type = args[:type]
    @url = args[:url]
    raise Exception.new("Missing required parameter.") if @type.nil? || @url.nil?
    @triplestore = TriplestoreAdapter::Triplestore.new(TriplestoreAdapter::Client.new(type, url))

    @write_report = args[:write_report]
    @update_triplestore = args[:update_triplestore]
    @write_update_file = args[:write_update_file]
    @output_path = args[:output_path] ||= '/tmp'
  end

  ##
  # Opens an RDF file, queries each unique subject from the triplestore, and reconcile the differences. Can load
  # triples from the file into the triplestore, and generate an updated ntriples file.
  #
  # @param filename [String] the full path to the RDF to load
  # @return [Hash] each error that occurred while processing
  def process(filename)
    @filename = filename
    process_filename = File.join(@output_path, "#{@filename}.#{@start_datetime}")
    @errors ||= {}

    begin
      graph_from_file = load_file(@filename)
      grouped_graph = grouped_by_subject(graph_from_file)
      @mismatches = find_mismatching_statements(grouped_graph)

      not_in_triplestore = mismatches.values.map { |s| s[:not_in_triplestore] }.flatten(1)
      not_in_file = mismatches.values.map { |s| s[:not_in_file] }.flatten(1)

      write_report(process_filename, filename, @url, not_in_file, not_in_triplestore) if @write_report
      insert_graph(not_in_triplestore) if @update_triplestore && not_in_triplestore.length > 0
      write_file(process_filename, graph_from_file.statements.to_a + not_in_file) if @write_update_file && not_in_file.length > 0
    ensure
      @errors
    end
    @errors
  end

  private

  ##
  # Add an error to the error hash
  #
  # @param uri [String] the uri to use as the key
  # @param message [String] an error message to add to the uri
  def add_error(uri, message)
    @errors[uri] ||= []
    @errors[uri] << message
  end

  ##
  # Given two arrays of RDF::Statements, return those not found in the other
  #
  # Example return {'http://opaquenamespace.org/ns/Test/Term': {not_in_file: [], not_in_triplestore: []},
  #                 'http://opaquenamespace.org/ns/Test/AnotherTerm': {not_in_file: [], not_in_triplestore: []}}
  #
  # @param grouped_graph [Hash<<String>,<RDF::Statement>>] hash of RDF::Graph grouped by the RDF Subjects within
  # @return [Hash<<String>,Hash<<String>,<Array<RDF::Statement>>>] statements from the file not found in the triplestore, statements from the triplestore not found in the file
  def find_mismatching_statements(grouped_graph)
    results = {}
    grouped_graph.each_pair do |uri, statements_in_file|
      begin
        graph_from_triplestore = fetch_graph(uri)
        if graph_from_triplestore.nil?
          add_error(uri, "Failed to fetch '#{uri}'")
          next
        end

        not_in_triplestore = statements_in_file.reject { |s| graph_from_triplestore.statements.to_a.any? { |g| s.eql?(g) }}
        not_in_file = graph_from_triplestore.statements.to_a.reject { |g| statements_in_file.any? { |s| g.eql?(s) }}

        results[uri] = {
          not_in_triplestore: not_in_triplestore,
          not_in_file: not_in_file
        }
      rescue StandardError => e
        add_error(uri, "Error: #{e.message}")
      end
    end
    results
  end

  ##
  # Return an RDF::Graph with statements grouped by subject
  #
  # @param graph [RDF::Graph] the graph to be grouped
  # @return [Hash<<String><RDF::Graph>>] keyed with the subject, value with the statements
  def grouped_by_subject(graph)
    graph.group_by { |statement| statement.subject.to_s }
  end

  ##
  # Write a report log file with the differences between the file and triplestore
  #
  # @param not_in_file [Array<RDF::Statement>] statements in the triplestore that aren't in the file
  # @param not_in_triplestore [Array<RDF::Statement>] statements in the file that aren't in the triplestore
  def write_report(new_filename, original_filename, url, not_in_file, not_in_triplestore)
    FileUtils.mkpath File.dirname(new_filename)
    File.open("#{new_filename}.log", 'w') do |f|
      f.write "==(#{not_in_file.length}) statements in triplestore (#{url}), not in file (#{original_filename})\n"
      f.write(sort_statements(not_in_file)) unless not_in_file.blank?
      f.write "\n==(#{not_in_triplestore.length}) statements in file (#{original_filename}), not in triplestore (#{url})\n"
      f.write(sort_statements(not_in_triplestore)) unless not_in_triplestore.blank?
    end
  end

  ##
  # Write an updated RDF file with statements sorted
  #
  # @param statements [Array<RDF::Statement>] RDF statements to write
  def write_file(new_filename, statements)
    sorted_statements = sort_statements(statements)
    FileUtils.mkpath File.dirname(new_filename)
    File.open(new_filename, 'w') { |f| f.write(sorted_statements) }
  end

  ##
  # Load the RDF file and return an RDF::Graph
  #
  # @param filename [String] the full path to the RDF file to load
  # @return [RDF::Graph]
  def load_file(filename)
    RdfLoader.load_file(filename)
  end

  ##
  # Sort RDF::Statement array by predicate and add newlines for file formatting
  #
  # @param statements [Array<RDF::Statement>] array of statements to sort
  # @return [String] sorted triples
  def sort_statements(statements)
    return "#{statements[0].to_s}\n" unless statements.length > 1
    sorted = statements.sort_by { |x| x.predicate }.inject { |collector, element| collector.to_s + " " + element.to_s }
    "#{sorted.gsub(" . ", " .\n")}\n"
  end

  ##
  # Create an RDF::Graph and insert it into the triplestore
  #
  # @param statements [Array<RDF::Statement>] an array of statements to insert into the triplestore
  # @return [RDF::Graph] the graph that was inserted into the triplestore
  def insert_graph(statements)
    graph = RDF::Graph.new
    graph.insert *statements
    @triplestore.store(graph)
  end

  ##
  # Fetch an RDF::Graph from the triplestore or the remote endpoint
  #
  # @param uri [String] the uri to the RDF endpoint
  # @return [RDF::Graph|nil] the graph from the triplestore or nil
  def fetch_graph(uri)
    begin
      @triplestore.fetch(uri, from_remote: true)
    rescue TriplestoreAdapter::TriplestoreException => e
      return RDF::Graph.new if e.to_s.include?("404")
      nil
    rescue
      nil
    end
  end
end
