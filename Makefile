all : clean test

clean:
	rm -rf output
	rm -f .nextflow.log*
	rm -rf .nextflow*

test:
	bash tests/test_00.sh
	bash tests/test_01.sh
	bash tests/test_02.sh
