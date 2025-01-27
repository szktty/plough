.PHONY: fix format test test-web doc dhttpd pubpoint unicode

FLUTTER = fvm flutter
DART = fvm dart

fix:
	$(DART) fix --apply lib
	$(DART) fix --apply test
	$(DART) fix --apply example/lib
	$(DART) format lib test example/lib

format:
	$(DART) format lib test

test:
	$(DART) test

test-web:
	$(DART) test -p chrome

doc:
	$(DART) doc

dhttpd:
	$(DART) pub global run dhttpd --path doc/api

pubpoints:
	pana .

generate:
	$(DART) run build_runner build --delete-conflicting-outputs
