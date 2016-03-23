module FormsHelper

	def icon_input_wrapper(object, field_symbol, icon_symbol,options = {}, field_type = :text_field)
		content_tag :div, class: ["ui", "left", "icon", "large", "input"] do
			object.send(field_type, field_symbol, options) +
			semantic_icon(icon_symbol)
		end
	end

	def radio_wrapper(object, name, value, label_value, options = { checked: false })
		content_tag :div, class: "field" do
			content_tag :div, class: ["ui", "radio", "checkbox"] do 
				if options[:new_record]
					object.send("radio_button", name, value, checked: options[:checked], class: options[:class]) + object.send("label", (name.to_s + "_" + value), label_value)
				else
					object.send("radio_button", name, value, class: options[:class]) + object.send("label", (name.to_s + "_" + value), label_value)
				end
			end
		end
	end

end
