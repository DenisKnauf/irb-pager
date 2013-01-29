module IRB
	module Pager
		extend IRB::Pager
		module PagerHelper
			# Parses options for `IRB::Pager::pager`
			def self.options opts = nil
				opts = opts.kind_of?( Hash) ? opts.dup : {}
				stdout = opts[:stdout] || opts[:out]  || $stdout
				stderr = opts[:stderr] || opts[:err]  || $stderr
				stdin  = opts[:stdin]  || opts[:in]   || $stdin
				pager  = opts[:pager]  || opts[:less] || $PAGER || ENV['PAGER'] || 'less'
				rescuing = opts[:rescuing].nil? ? opts[:exceptions].nil? ? $PAGER_RESCUE : opts[:exceptions] : opts[:rescuing]
				[stdout, stderr, stdin, pager, rescuing]
			end

			# Exception formatter for `IRB::Pager::pager`.
			def self.exception_formatter exception
				["#{exception.class}: #{exception.message}", exception.backtrace.collect {|c| "\tfrom #{c}" }].join "\n"
			end
		end

		# Starts pager (for example `less`).
		# $stdin, $stderr and $stdout will be redirected to pager and your block will be called.
		# On return or a raised exception, $stdin, $stderr and $stdout will be redirected to the original IOs.
		# Instead of redirecting output for your block, you can inspect an object in pager.
		# If pager will be exit, your program will be run like before.
		#
		# Possible Options:
		# `opts[:stdout]`, `opts[:out]`: redirect this instead `$stdout`
		# `opts[:stderr]`, `opts[:err]`: redirect this instead `$stderr`
		# `opts[:stdin]`, `opts[:in]`:   redirect this instead `$stdin`
		# `opts[:pager]`, `opts[:less]`, `$PAGER`, `ENV['PAGER']`: use this pager instead less
		# `opts[:rescuing]`, `opts[:exceptions]`, `$PAGER_RESCUE`: unless `false` or `nil` rescue exception and print it via pager, too
		def pager obj = nil, opts = nil, &exe
			if block_given?
				stdout, stderr, stdin, pager, rescuing = PagerHelper.options( opts || obj)
				pid, dupout, duperr, dupin = nil, stdout.dup, stderr.dup, stdin.dup
				IO.pipe do |inrd, inwr|
					begin
						IO.pipe do |rd, wr|
							pid = Process.fork do
								stdin.reopen rd
								wr.close
								exec *pager
							end
							stdout.reopen wr
							stderr.reopen wr
							stdin.reopen inrd
							if rescuing
								begin
									yield
								rescue Object
									stdout.puts PagerHelper.exception_formatter
								end
							else
								yield
							end
						end
					ensure
						stdout.reopen dupout
						stderr.reopen duperr
						Process.wait pid
						stdin.reopen dupin
					end
				end
			else
				pager( opts) { Kernel.p obj }
			end
		end
	end
end
