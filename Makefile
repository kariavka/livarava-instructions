refresh:
	git checkout develop
	git pull
	git checkout master
	git pull

release:
	git checkout develop
	git push
	git checkout master
	git push

.PHONY: refresh release
