# These may be overridden by make invocators
GOSH           = "/usr/local/bin//gosh"

all :


check : all
	@rm -f test.log
	$(GOSH) -I. test.scm > test.log

clean :
	rm -rf $(TARGET) $(GENERATED) *~ test.log

distclean : clean
	rm -rf $(CONFIG_GENERATED)

maintainer-clean : clean
	rm -rf $(CONFIG_GENERATED) configure VERSION

