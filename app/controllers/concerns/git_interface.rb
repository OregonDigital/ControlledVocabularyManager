module GitInterface
  extend ActiveSupport::Concern
  require 'rugged'
  
  def rugged_create (id,string,action)
    repo = setup
    #find/create branch and check it out
    branch = repo.branches[id]
    if branch.nil?
      branch = repo.branches.create(id, "HEAD")
    end
    repo.checkout(branch)
    #add blob
    oid = repo.write(string,:blob)
    index = repo.index
    index.read_tree(repo.head.target.tree)
    index.add(:path => "#{id}.nt", :oid => oid, :mode => 0100644)
    #commit
    options = {}
    options[:tree] = index.write_tree(repo)
    options[:author] = {:email => current_user.email, :name => current_user.name, :time => Time.now }
    options[:committer] = {:email => current_user.email, :name => current_user.name, :time => Time.now }
    options[:message] = action + ": " + id
    options[:parents] = repo.empty? ? [] : [ repo.head.target ].compact
    options[:update_ref] = 'HEAD'
    Rugged::Commit.create(repo, options)
    index.write
    options = {}
    options[:strategy] = :force
    repo.checkout_head(options)
    repo.checkout('master')
  end

  def rugged_merge (id)
    repo = setup
    repo.checkout('master')
    #merge
    into_branch = 'master'
    from_branch = id
    their_commit = repo.branches[into_branch].target_id
    our_commit = repo.branches[from_branch].target_id

    merge_index = repo.merge_commits(our_commit, their_commit)

    if merge_index.conflicts?
      # conflicts. deal with them
    else
      # no conflicts
      commit_tree = merge_index.write_tree(repo)
      options = {}
      options[:tree] = commit_tree
      options[:author] = { :email => current_user.email, :name => current_user.name, :time => Time.now }
      options[:committer] = { :email => current_user.email, :name => current_user.name, :time => Time.now }
      options[:message] ||= "Merge #{from_branch} into #{into_branch}"
      options[:parents] = [repo.head.target, our_commit]
      options[:update_ref] = 'HEAD'

      Rugged::Commit.create(repo, options)
      repo.checkout_tree(commit_tree)
      index = repo.index
      index.write
      options = {}
      options[:strategy] = :force
      repo.checkout_head(options)
      #repo.push('origin', [repo.head.name], { credentials: @cred })
      repo.branches.delete(from_branch)
      #close branch
    end
  end

  #put this in config?
  def setup
    repo = Rugged::Repository.new(ControlledVocabularyManager::Application::config.rugged_repo)
  end

  def get_history(id)
    repo = setup
    path = id + ".nt"
    info = commit_info_rugged(repo, path)
    formatted = format_response(info)
   end

  def entry_changed?(commit, path, repo)

    term = path.include? "/" 
    if term
      arr = path.split "/"
      path = arr[0]
      pathchild = arr[1]
      if !commit.tree[path].nil?
        childtree = repo.lookup(commit.tree[path][:oid])
        entry = childtree[pathchild]
      else
        entry = nil
      end
    else # predicate
      entry = commit.tree[path]
    end
    parent = commit.parents[0]
    # if at a root commit, consider it changed if we have this file;
    # i.e. if we added it in the initial commit
    if not parent
      return entry != nil
    end
    if term
      if !parent.tree[path].nil?
        parenttree = repo.lookup(commit.parents[0].tree[path][:oid])
        parent_entry = parenttree[pathchild]

      else
        parent_entry = nil
      end
    else
      parent_entry = parent.tree[path]
    end
    # does exist in either, no change
    if not entry and not parent_entry
      false
    # only in one of them, change
    elsif not entry or not parent_entry then
      true
    # otherwise it's changed if their ids aren't the same
    else
      entry[:oid] != parent_entry[:oid]
    end
  end

  def commit_info_rugged(repo, path)

    walker = Rugged::Walker.new(repo)
    walker.sorting(Rugged::SORT_DATE)
    walker.push(repo.last_commit)
    walker.inject([]) do |a, c|
      if entry_changed? c, path, repo
         a << {author: c.author, date: c.time, hash: c.oid, message: c.message}
      end
      a
    end
  end

  #returns an array of triple as strings with "added" or "deleted" prefixes
  def get_diff(commit1)
    answer = []
    repo = setup
    child = repo.lookup(commit1)
    commits = child.parents[0].diff(child)
    commits.each_patch do |patch|
      file = patch.delta.old_file[:path]

      patch.each_hunk do |hunk|
        hunk.each_line do |line|
          case line.line_origin
          when :addition
            answer << "added: " + line.content
          when :deletion
            answer << "deleted: " + line.content
          when :context
            #do nothing
          end
        end
      end
    end
    answer
  end

  def format_response(results)

    if results.empty?
      return
    else
      formatted = []
      num_items = 1
      results.each do |commit|
        if commit[:message].include? "updating"
          diffs = get_diff(commit[:hash])
          newdiffs = []
          #remove subject
          diffs.each do |diff|
            parts = diff.split("<")
            newparts = parts.slice(0,1).concat(parts.slice(2, parts.length-1))
            newdiffs << newparts.join("<")
          end
          item = {:date => commit[:date], :author => commit[:author][:name], :diff => newdiffs }
          formatted << item
          num_items = num_items + 1
        end
        break if num_items > 3
      end
      if formatted.empty?
        return nil
      end
      formatted
    end
  end

 def branch_list
    repo = setup
    branches = repo.branches.each_name(:local).sort
    branches = branches.reject{|branch| branch == 'master'}
  end

  #retrieve the data from git
  #for use in review queue/show
  def commit_content(branchname)
    repo = setup
    repo.checkout(branchname)
    lastcom = repo.lookup(repo.last_commit.oid)
    if(branchname.include?"/")
      parts = branchname.split("/")
      childtree = repo.lookup(lastcom.tree[parts[0]][:oid])
      commit = repo.lookup(childtree[parts[1]+ ".nt"][:oid])
    else
      parts = branchname.split("_")
      commit = repo.lookup(lastcom.tree[parts[0] + ".nt"][:oid])
    end
    commit.content
  end

  #creates an array of terms
  #for use in review process
  def review_list

    repo = setup
    terms = []
    branches = branch_list
    branches.each do |branch|
      repo.checkout(branch)
      content = commit_content(branch)
      graph = triples_string_to_graph(content)
      label_state = graph.query([nil, RDF::RDFS.label, nil])
      terms << {:id => branch, :uri => label_state.first.subject.to_s, :label => label_state.first.object.to_s}
    end
    repo.checkout('master')
    terms
  end

  #takes string and converts to rdf statement
  def triple_string_to_statement(tstring)
    RDF::Reader.for(:ntriples).new(tstring) do |reader|
      reader.each_statement do |statement|
        return statement
      end
    end
  end

  #takes string .nt and converts to graph
  def triples_string_to_graph(tstring)
    graph = RDF::Graph.new
    RDF::Reader.for(:ntriples).new(tstring) do |reader|
      reader.each_statement do |statement|
        graph << statement
      end
    end
    graph
  end


  def get_graph(branchname)
    content = commit_content(branchname)
    graph = triples_string_to_graph(content)
  end

  #reassembles rdf graph from git
  def reassemble(branchname)
    graph = get_graph(branchname)
    types = graph.query(:predicate=>RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"))
    if types.first.object == RDF::URI("http://purl.org/dc/dcam/VocabularyEncodingScheme")
      sr = StandardRepository.new(nil, Vocabulary)
    elsif
      types.first.object == RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate")
      sr = StandardRepository.new(nil, Predicate)
    else
      sr = StandardRepository.new(nil, Term)
    end
    results = GraphToTerms.new(sr, graph).terms
    results.first
  end

  #reassembles params from git
  # for repopulating edit forms
  def edit_params (branchname)
    term = reassemble(branchname)
    proplangs = Hash.new
    vocabhash = Hash.new
    Term.properties.each do |property|
      results = []
      if !term.blacklisted_language_properties.include? property[0].to_sym
        term.query(:predicate=> property[1].predicate ).each_statement {|s,p,o| results << o }
        if !results.empty?
          if results.first.respond_to? :language
            proplangs[property.first.to_s] = [results.first.language.to_s]
          end
          vocabhash[property.first.to_sym] = [results.first.object.to_s]
        end
      end
    end
    vocabhash[:language] = proplangs
    params = Hash.new
    params[:vocabulary] = vocabhash
    params
  end

end
