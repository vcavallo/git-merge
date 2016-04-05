#!/usr/bin/env ruby

# a git-backed web server
# a repo that requires a webserver will work with this
# try something with a gh-pages branch (putting it in the ref_name var)

require 'sintara'
require 'rugged'
require 'mime/types'

# specify repo/branch (ref) and create repo object

repo_path = ENV['HOME'] + '/path/to/repo'
ref_name = 'refs/remotes/REMOTE/BRANCH'
# ref_name = 'refs/remotes/upstream/gh-pages' for example

repo = Rugged::Repository.new(repo_path)

# sinatra stuff:

get '*' do |path|
  commit = repo.ref(ref_name).target # rugged
  path.slice!(0) # remove leading slash
  path = 'index.html' if path.empty? # if no path supplied - show home

  # get a bunch of content stored as blobs in .git
  entry = commit.tree.path(path) # ruby hash
  puts path
  blob = repo.lookup(entry[:oid])
  content = blob.content # return contents of blob as string

  unless content
    halt 404, "404 Not Found"
  end

  content_type MIME::Types.type_for(path).first.content_type
  content
end
