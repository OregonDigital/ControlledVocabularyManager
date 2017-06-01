module GitCommitMethods
  extend ActiveSupport::Concern

  def isLockedForEdit(id)
    gc = GitCommit.find_by(:term_id => id)
    !gc.unmerged_id.empty?
  end
end

