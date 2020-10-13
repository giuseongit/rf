require "./spec_helper"
require "../src/class_extensions"

describe "Rf.extensions"do

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
    curr.each_subdir do |entry|
      count += 1
    end

    count.should eq 4
  end

  it "dir can detect git and svn repositories work" do
    with_dir("./test") do |dir|
      with_dir("./test/.git") do |dir|
        tDir = Dir.new("./test")
        tDir.is_svn_repo?.should be_false
        tDir.is_git_repo?.should be_true
      end
      
      with_dir("./test/.svn") do |dir|
        tDir = Dir.new("./test")
        tDir.is_svn_repo?.should be_true
        tDir.is_git_repo?.should be_false
      end
    end
  end

end
