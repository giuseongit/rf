require "spec"

def with_dir(path)
  Dir.create_if_not_exists(path)
  yield Dir.new(path)
  Dir.delete(path)
end