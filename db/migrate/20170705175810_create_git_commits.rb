class CreateGitCommits < ActiveRecord::Migration
  def change
    create_table :git_commits do |t|
      t.string :term_id
      t.string :unmerged_commits
      t.string :merged_commits
      t.timestamps null: false
    end
  end
end
