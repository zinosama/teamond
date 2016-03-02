module UsersHelper

	def icon_input_wrapper(object, field_symbol, icon_symbol,options = {}, field_type = :text_field)
		content_tag :div, class: ["ui", "left", "icon", "large", "input"] do
			object.send(field_type, field_symbol, options) +
			semantic_icon(icon_symbol)
		end
	end

end
