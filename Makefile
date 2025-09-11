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
	$(FLUTTER) test

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


# Flutter tests (widget/gesture)
test-flutter:
	$(FLUTTER) test

# Run both dart (if any pure-dart tests exist) and flutter tests
test-all: test
