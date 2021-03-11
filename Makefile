.PHONY: test
test:
	rm -rf coverage* && \
	flutter test --coverage test && \
	# lcov --remove coverage/lcov.info 'lib/**/i_*_helper.dart' -o coverage/lcov.info && \
    genhtml -q -o coverage coverage/lcov.info && \
	google-chrome coverage/index.html