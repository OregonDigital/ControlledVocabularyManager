class GitCommit < ActiveRecord::Base

  MAX = 5
  validates :term_id, presence: true
  @unmerged_commits
  after_initialize :init

  def init
    self.merged_commits ||= ""
  end

  def update_commit(commit_id)
    self.unmerged_commits = self.unmerged_commits.empty? ? commit_id : commit_id + ";" + self.unmerged_commits
  end

  def merge_commit
    enqueue
    self.unmerged_commits = ""
    if unserialize(self.merged_commits).size > MAX
      dequeue
    end
  end

  def unmerged_commit_ids
    unserialize self.unmerged_commits
  end

  def commit_ids
    unserialize self.merged_commits
  end

  def cancel
    self.unmerged_commits = ""
  end

  private

  def unserialize(ids)
    ids.split(";")
  end

  def enqueue
    self.merged_commits = self.unmerged_commits + ";" + self.merged_commits
  end

  def dequeue
    self.merged_commits = unserialize.slice(0, MAX).join(";")
  end
end
