module IRB
	module Pager
		module PagerHelper
			def self.options opts = nil
				opts = opts.kind_of?( Hash) ? opts.dup : {}
				stdout = opts[:stdout] || opts[:out]  || $stdout
				stderr = opts[:stderr] || opts[:err]  || $stderr
				stdin  = opts[:stdin]  || opts[:in]   || $stdin
				pager  = opts[:pager]  || opts[:less] || $PAGER || ENV['PAGER'] || 'less'
				rescuing = opts[:rescuing].nil? ? opts[:exceptions].nil? ? $PAGER_RESCUE : opts[:exceptions] : opts[:rescuing]
				[stdout, stderr, stdin, pager, rescuing]
			end

			def self.exception_formatter exception
				["#{exception.class}: #{exception.message}", exception.backtrace.collect {|c| "\tfrom #{c}" }].join "\n"
			end
		end

		def self.pager obj = nil, opts = nil, &exe
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
