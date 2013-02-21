(use gauche.test)

(test-start "net.BeautifulSoup")

(use net.BeautifulSoup)
(test-module 'net.BeautifulSoup)

(read-file/sxml "test/data1.htm")


(test-end)
