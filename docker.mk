# This makefile contains some make functions to check whether or not
# Docker containers and images exist
# Run the following to execute the unit tests:
#    sudo make -f docker.mk .unit-test-docker-calls

# check that a docker container runs
# syntax: $(call docker-does-container-run,<container>)
define docker-does-container-run
$(shell if docker inspect docker inspect --format='{{.State.Status}}' $1 2>/dev/null|grep running >/dev/null;then echo yes;else echo no;fi)
endef

# check that a docker container exists
# syntax: $(call docker-does-container-exist,<container>)
define docker-does-container-exist
$(shell if docker inspect --type container $1 >/dev/null 2>&1;then echo yes;else echo no;fi)
endef

# check that a docker image exists
# syntax: echo $(call docker-does-image-exist,<image>)
define docker-does-image-exist
$(shell if [ `docker inspect --type image $1 2>/dev/null|wc -l` -ne 0 ];then echo yes;else echo no;fi)
endef

# check that a docker image of a specific version exists
# syntax: echo $(call docker-does-image-exist,<imagename>,<imageversion>)
# do not include any spaces in the call
define docker-does-image-version-exist
$(shell if docker inspect --type image $1:$2 >/dev/null 2>&1;then echo yes;else echo no;fi)
endef

# unit tests below here

TESTCONTAINERNAME=test-docker-calls-container-name
NONECONTAINERNAME=not-existing-container-name
TESTIMAGENAME=ubuntu
TESTIMAGEVERSION=16.04
NONEIMAGENAME:=not-existing-image-name
NONEIMAGEVERSION=not-existing-image-version

.PHONY: .unit-test-docker-calls .unit-test-docker-calls-start

.unit-test-docker-calls: .unit-test-docker-calls-start
	# check name of not existing container
	if [ "$(call docker-does-container-exist,$(NONECONTAINERNAME))" != "no" ] ; \
		then echo test1 ; exit 1 ; fi
	# check name of existing container
	if [ "$(call docker-does-container-exist,$(TESTCONTAINERNAME))" != "yes" ] ; \
		then echo test2 ; exit 1 ; fi
	# check name of not existing image
	if [ "$(call docker-does-image-exist,$(NONEIMAGENAME))" != "no" ] ; \
		then echo test3 ; exit 1 ; fi
	# check name of existing image
	if [ "$(call docker-does-image-exist,$(TESTIMAGENAME))" != "yes" ] ; \
		then echo test4 ; exit 1 ; fi
	# check all 4 name and version combinations 
	if [ "$(call docker-does-image-version-exist,$(NONEIMAGENAME),$(NONEIMAGEVERSION))" != "no" ] ; \
		then echo test5 ; exit 1 ; fi
	if [ "$(call docker-does-image-version-exist,$(NONEIMAGENAME),$(TESTIMAGEVERSION))" != "no" ] ; \
		then echo test6 ; exit 1 ; fi
	if [ "$(call docker-does-image-version-exist,$(TESTIMAGENAME),$(NONEIMAGEVERSION))" != "no" ] ; \
		then echo test7 ; exit 1 ; fi
	if [ "$(call docker-does-image-version-exist,$(TESTIMAGENAME),$(TESTIMAGEVERSION))" != "yes" ] ; \
		then echo test8 ; exit 1 ; fi
	# check existing container runs
	if [ "$(call docker-does-container-run,$(TESTCONTAINERNAME))" != "yes" ] ; \
		then echo test9 ; exit 1 ; fi
	# TODO: add test for not-runing existing container
	# check not existing container runs
	if [ "$(call docker-does-container-run,$(NONECONTAINERNAME))" != "no" ] ; \
		then echo test9 ; exit 1 ; fi
	echo ALL TESTS PASS

.unit-test-docker-calls-start:
	# start temporary test container
	docker run --rm -d --name $(TESTCONTAINERNAME) $(TESTIMAGENAME):$(TESTIMAGEVERSION) bash -c "sleep 8"
	# give container time to start
	sleep 1
