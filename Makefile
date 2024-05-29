include versioning.mk

artifact:
	@mkdir -p $(CURDIR)/artifact

.PHONY: chart
chart: artifact
	@echo "--- Packing Helm Chart ---"
	@helm package --app-version $(DEV_VERSION) --version $(DEV_VERSION) $(CURDIR)/helm/postgres -d $<

.PHONY: chart-stable
chart-stable: artifact
	@echo "--- Packing Stable Helm Chart---"
	@helm package --app-version $(VERSION) --version $(VERSION) $(CURDIR)/helm -d $<

.PHONY: clean
clean:
	@rm -rf $(CURDIR)/artifact