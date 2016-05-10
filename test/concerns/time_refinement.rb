module TimeRefinement
	refine Time do
		def get_hour
			strftime('%k').to_i
		end

		def get_minute
			strftime('%M').to_i
		end

		def get_dow
			strftime('%w').to_i
		end
	end
end