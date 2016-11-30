# coding: utf-8
#
# usage: bundle exec sample.rb keyword [start_id]
#    or: bundle exec sample.rb [keyword]
# start_id: default=1
require File.join(File.dirname(__FILE__), 'lib/ni_chan')
require "pry"

keyword = ARGV[0]
start_id = ARGV[1].to_i
search  = NiChan::Search.new(keyword)
threads = search.get_threads

# get first thread posts
thread = NiChan::Thread.new(threads.first[:url])
posts = thread.read(start_id)
puts posts.to_json
