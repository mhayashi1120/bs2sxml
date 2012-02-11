
(add-load-path ".")

(use gauche.test)

(test-start "net.BeautifulSoup")

(use net.BeautifulSoup)
(test-module 'net.BeautifulSoup)


(test-end)
