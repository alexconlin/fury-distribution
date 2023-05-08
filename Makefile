.PHONY: license-add license-check

license-add:
	@addlicense \
	-c "SIGHUP s.r.l" \
	-v -l bsd -y "2017-present" \
	-ignore 'templates/distribution/**' \
	-ignore 'target/**' \
	-ignore 'vendor/**' \
	.

license-check:
	@addlicense \
	-c "SIGHUP s.r.l" \
	-v -l bsd -y "2017-present" \
	-ignore 'templates/distribution/**' \
	-ignore 'target/**' \
	-ignore 'vendor/**' \
	--check .

.PHONY: lint-go

lint-go:
	@golangci-lint -v run --color=always --config=.rules/.golangci.yml ./...

.PHONY: tools-go

tools-go:
	@go install github.com/evanphx/json-patch/cmd/json-patch@v5.6.0

.PHONY: generate-private-schema dump-go-models

generate-go-models: dump-private-schema
	@go-jsonschema \
		--package public \
		--resolve-extension json \
		--output pkg/apis/ekscluster/v1alpha2/public/schema.go \
		schemas/public/ekscluster-kfd-v1alpha2.json
	@go-jsonschema \
		--package private \
		--resolve-extension json \
		--output pkg/apis/ekscluster/v1alpha2/private/schema.go \
		schemas/private/ekscluster-kfd-v1alpha2.json

	@go-jsonschema \
		--package public \
		--resolve-extension json \
		--output pkg/apis/ekscluster/v1alpha3/public/schema.go \
		schemas/public/ekscluster-kfd-v1alpha3.json
	@go-jsonschema \
		--package private \
		--resolve-extension json \
		--output pkg/apis/ekscluster/v1alpha3/private/schema.go \
		schemas/private/ekscluster-kfd-v1alpha3.json

dump-private-schema:
	@cat schemas/public/ekscluster-kfd-v1alpha2.json | \
	json-patch -p schemas/private/ekscluster-kfd-v1alpha2.patch.json | \
	jq -r > schemas/private/ekscluster-kfd-v1alpha2.json
	@cat schemas/public/ekscluster-kfd-v1alpha3.json | \
	json-patch -p schemas/private/ekscluster-kfd-v1alpha3.patch.json | \
	jq -r > schemas/private/ekscluster-kfd-v1alpha3.json

.PHONY: generate-deps-checksums

generate-deps-checksums:
	@cd tools/checksummer; \
	go run main.go ../../kfd.yaml
