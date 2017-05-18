class CreateGitCommits < ActiveRecord::Migration
  def change
    create_table :git_commits do |t|
      t.string :term_id
      t.string :unmerged_id
      t.string :commit_ids

      t.timestamps null: false
    end
  end
end
