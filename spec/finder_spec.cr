require "./spec_helper"

describe "Rf.finder" do
  it "can wak dirs" do
    Dir.create_if_not_exists("./test/prj1/.git")
    Dir.create_if_not_exists("./test/prj2/.git")
    Dir.create_if_not_exists("./test/sub/prj4/.git")
    Dir.create_if_not_exists("./test/sub/prj5/.git")

    finder = init_finder

    dir = Dir.new("./test")

    ix = finder.walk_dirs(dir)

    index = ix[0].as(Array)
    walked = ix[1].as(Int)

    index.size.should eq 4
    walked.should eq 5

    Dir.delete("./test/prj1/.git")
    Dir.delete("./test/prj1")
    Dir.delete("./test/prj2/.git")
    Dir.delete("./test/prj2")
    Dir.delete("./test/sub/prj4/.git")
    Dir.delete("./test/sub/prj4")
    Dir.delete("./test/sub/prj5/.git")
    Dir.delete("./test/sub/prj5")
    Dir.delete("./test/sub")
    Dir.delete("./test")
  end
end
