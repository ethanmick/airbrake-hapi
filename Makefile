#
#
#
#
#

.PHONY: test bin lib

unit:
	./node_modules/mocha/bin/_mocha --compilers coffee:coffee-script/register ./test/unit

integration:
	./node_modules/mocha/bin/_mocha --compilers coffee:coffee-script/register ./test/integration

cov:
	./node_modules/mocha/bin/_mocha --compilers coffee:coffee-script/register --require blanket -R html-cov > coverage.html ./test/unit ./test/integration
	open coverage.html

test:
	$(MAKE) unit
	$(MAKE) integration
