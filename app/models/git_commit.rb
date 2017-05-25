class GitCommit < ActiveRecord::Base

  MAX = 5
  validates :term_id, presence: true
  @unmerged_id
  after_initialize :init

  def init
    self.commit_ids ||= ""
  end

  def update_commit(commit_id)
    self.unmerged_id = commit_id + ";" + self.unmerged_id
  end

  def merge_commit
    enqueue
    self.unmerged_id = ""
    if unserialize(self.commit_ids).size > MAX
      dequeue
    end
  end

  def unmerged_commits
    unserialize self.unmerged_id
  end

  def commits
    unserialize self.commit_ids
  end

  def remove (commit_id)
    self.commit_ids = self.commit_ids.gsub(commit_id + ";", "")
  end

  private

  def unserialize(ids)
    ids.split(";")
  end

  def enqueue
    self.commit_ids = self.unmerged_id + ";" + self.commit_ids
  end

  def dequeue
    self.commit_ids = unserialize.slice(0, MAX).join(";")
  end
end
