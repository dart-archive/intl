OUTPUT_DIR=lib/generated

MESSAGE_ARBS=\
	lib/messages/material_de_CH.arb \
	lib/messages/material_de.arb \
	lib/messages/material_en.arb \
	lib/messages/material_es.arb	

# --json \
# --codegen_mode=debug \

generate: $(MESSAGE_ARBS)
	dart ../bin/generate_from_arb.dart \
	--output-dir $(OUTPUT_DIR) \
	lib/example_messages.dart \
	$(MESSAGE_ARBS)

clean:
	rm $(OUTPUT_DIR)/*.dart
