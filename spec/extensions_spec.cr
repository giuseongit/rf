require "./spec_helper"

describe "Rf.extensions" do
  it "dir.create_if_not_exists work" do
    sample_dir = "test"

    Dir.exists?(sample_dir).should be_false
    Dir.create_if_not_exists(sample_dir)
    Dir.exists?(sample_dir).should be_true

    # Cleanup
    Dir.delete(sample_dir)
  end

  it "dir.each_subdir work" do
    count = 0

    curr = Dir.new(".")
    curr.each_subdir do |_|
      count += 1
    end

    count.should eq 5
  end

  it "dir can detect git and svn repositories work" do
    with_dir("./test") do |_|
      t_dir = Dir.new("./test")
      with_dir("./test/.git") do |_|
        t_dir.is_svn_repo?.should be_false
        t_dir.is_git_repo?.should be_true
      end

      with_dir("./test/.svn") do |_|
        t_dir.is_svn_repo?.should be_true
        t_dir.is_git_repo?.should be_false
      end
    end
  end
end
