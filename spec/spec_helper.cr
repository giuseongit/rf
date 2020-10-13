require "spec"
require "../src/finder"
require "../src/ui"

def with_dir(path)
  Dir.create_if_not_exists(path)
  yield Dir.new(path)
  Dir.delete(path)
end

def init_finder
  cs = Rf::SupportedVSC::Git
  Rf::Finder.new(cs, 1)
end
