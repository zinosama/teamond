module FormsHelper

	def icon_input_wrapper(object, field_symbol, icon_symbol,options = {}, field_type = :text_field)
		content_tag :div, class: ["ui", "left", "icon", "large", "input"] do
			object.send(field_type, field_symbol, options) +
			semantic_icon(icon_symbol)
		end
	end

	def radio_wrapper(object, name, value, label_value, checked = false)
		content_tag :div, class: "field" do
			content_tag :div, class: ["ui", "radio", "checkbox"] do 
				object.send("radio_button", name, value, checked: checked) + object.send("label", (name.to_s + "_" + value), label_value)
			end
		end
	end

end
