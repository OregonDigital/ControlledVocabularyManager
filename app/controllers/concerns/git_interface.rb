module GitInterface
  extend ActiveSupport::Concern
  require 'rugged'
  
  def rugged_create
  #create branch and check it out
  
  #add blob
  #commit

  end

  def rugged_merge
  #merge 
  #close branch
  end

  #put this in config?
  def setup
    repo = Rugged::Repository.new('/home/lsato/test-rugged')
  end

  def get_history(id)
   #for now
    repo = self.setup
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
      authors = []
      results.each do |thing|
        authors << thing[:author][:name]
      end
      formatted = {:authors=>authors, :date_modified => results.first[:date] }
    end
  end

end
