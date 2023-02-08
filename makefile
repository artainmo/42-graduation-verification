all:
	@./scripts/graduation_verification.sh $(ACCESS_TOKEN) $(LOGIN)

setup:
	@chmod +x ./scripts/setup.sh
	@chmod +x ./scripts/generate_access_token.sh
	@chmod +x ./scripts/graduation_verification.sh
	@./scripts/setup.sh
	@./scripts/generate_access_token.sh

