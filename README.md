Usage
=====

Very simple:

	require 'pager'
	include Pager
	pager { puts "Hello World!" }
	pager { 1.upto(200) {|i|sleep 0.2; puts i} }

Exceptions will not be handled by pager:

	pager { raise 'Oops' }

But if you want, pager can do:

	pager( :rescuing => true) { raise 'Oops' }
	$PAGER_RESCUE = true  # forces pager to handle exceptions everytime.
	pager { raise 'Oops' }

You like more more than less?  (I cannot understand, but it is your choice)

	pager( :pager => 'more') { puts "Hello World!" }
	$PAGER = 'more' # forces pager to use more
	pager { puts "Hello World!" }

If you have set `PAGER` in your Processenvironment (`/etc/profile` or `~/.profile` ...) this `PAGER` will be used.

	PAGER=more
	export PAGER
