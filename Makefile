DIAGRAM_SRC=docs/aws-resource-interactions.mmd
DIAGRAM_OUT=docs/aws-resource-interactions-diagram.png

.PHONY: diagram
diagram:
	npx -y @mermaid-js/mermaid-cli -i $(DIAGRAM_SRC) -o $(DIAGRAM_OUT) -b white -t default
