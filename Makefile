.PHONY: test
test:
	rm -rf coverage* && \
	flutter test --coverage test && \
    genhtml -q -o coverage coverage/lcov.info && \
	google-chrome coverage/index.html