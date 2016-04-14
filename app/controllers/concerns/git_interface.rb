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
    index.add(:path => id, :oid => oid, :mode => 0100644)
    #commit
    options = {}
    options[:tree] = index.write_tree(repo)
    options[:author] = {:email => "author@uoregon.edu",:name => 'hayao', :time => Time.now }
    options[:committer] = {:email => "author@uoregon.edu", :name => 'hayao', :time => Time.now }
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
      options[:author] = { :email => 'reviewer@uoregon.edu', :name => 'toshio', :time => Time.now }
      options[:committer] = { :email => "reviewer@uoregon.edu", :name => 'toshio', :time => Time.now }
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
      #repo.branches.delete(from_branch)
      #close branch
    end
  end

  #put this in config?
  def setup
    repo = Rugged::Repository.new('/home/lsato/test-rugged')
  end

  def get_history(id)
   #for now
    repo = setup
    info = commit_info_rugged(repo, id)
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
    else
      entry = commit.tree[path]
    end
    parent = commit.parents[0]
    # if at a root commit, consider it changed if we have this file;
    # i.e. if we added it in the initial commit
    if not parent
      return entry != nil
    end
    if term
      if !parent.tree[pathchild].nil?
        parenttree = repo.lookup(commit.parents[0].tree[pathchild][:oid])
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
         a << {author: c.author, date: c.time, hash: c.oid}
      end
      a
    end
  end

  def format_response(results)
    if results.empty?
      return
    else
      formatted = {:author => results.last[:author][:name],
          :reviewer => results.first[:author][:name], :date_modified => results.first[:date] }
    end
  end

end
