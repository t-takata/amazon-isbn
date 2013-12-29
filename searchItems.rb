#!/usr/bin/env ruby
#

ENV['AMAZONRCDIR']  = File.expand_path(File.dirname($0))
ENV['AMAZONRCFILE'] = '.amazonrc'

require 'pp'
require 'amazon/aws'
require 'amazon/aws/search'
include Amazon::AWS

previousCall = nil
STDERR.print("> ")
while line = STDIN.gets
	isbn = line.gsub(/\s/, "")
	if not (isbn =~ /^\d{13}$/) then
		STDERR.puts("Error: %s is not ISBN." % isbn)
		next
	end
	il = ItemLookup.new('ISBN', {'ItemId' => isbn, 'SearchIndex' => 'Books'})
	rg = Amazon::AWS::ResponseGroup.new('Medium')
	request  = Search::Request.new
	if previousCall != nil then
		callTimeDiff = Time.now - previousCall
		waitSec = 1.1 - callTimeDiff
		if waitSec > 0 then
			sleep(waitSec)
		end
	end
	response = request.search(il, rg)
	previousCall = Time.now
	item = response.item_lookup_response.items.item
	hasKindle = false
	title = nil
	author = nil
	item.each { |i| 
		title = i.item_attributes.title.to_s
		author = i.item_attributes.author
		if i.item_attributes.product_group.to_s =~ /eBooks/ then
			hasKindle = true
		end

	}
	if author.kind_of?(Array) then
		author = author.join(",")
	else
		author = author.to_s
	end
	puts "%s\t%s\t%s\t%s" %
		[isbn, title, author, hasKindle ? 1 : 0]
	STDERR.print("> ")
end
