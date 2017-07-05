require 'rails_helper'

RSpec.describe GitCommit do
  let(:gitc) {GitCommit.create(args)}
  let(:args) { {
                 :term_id => "blah/foo",
                 :unmerged_commits => "abc123456"
               } }

  it { should validate_presence_of(:term_id) }

  context "After a GitCommit object is created" do
    it "should set commit_ids to empty" do
      expect(gitc.merged_commits).to eq("")
    end
  end
  context "When a new commit is added" do
    before do
      gitc.update_commit("abc123457")
      gitc.save
    end
    it "should update the unmerged_commit" do
      expect(gitc.unmerged_commits).to eq("abc123457;abc123456")
    end
  end
  context "When merge is called" do
    before do
      gitc.merge_commit
    end
    it "should merge the commit" do
      expect(gitc.merged_commits).to eq("abc123456;")
      expect(gitc.unmerged_commits).to eq("")
    end
  end
  context "When a branch is cancelled" do
    before do
      gitc.cancel
    end
    it "should no longer have the commit id" do
      expect(gitc.unmerged_commits).to be_empty
    end
  end
end
