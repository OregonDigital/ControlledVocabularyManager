class GitCommit < ActiveRecord::Base

  MAX = 3
  validates :term_id, presence: true
  @unmerged_id
  after_initialize :init

  def init
    self.commit_ids ||= ""
  end

  def update_commit(commit_id)
    self.unmerged_id = commit_id
  end

  def merge_commit
    enqueue
    if unserialize.size > MAX
      dequeue
    end
  end

  def commits
    unserialize
  end

  private

  def unserialize
    self.commit_ids.split(";")
  end

  def enqueue
    self.commit_ids = self.unmerged_id + ";" + self.commit_ids
    self.unmerged_id = ""
  end

  def dequeue
    self.commit_ids = unserialize.slice(0, MAX).join(";")
  end
end
