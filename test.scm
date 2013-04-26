(use gauche.test)

(test-start "net.BeautifulSoup")

(use net.BeautifulSoup)
(use sxml.sxpath)
(test-module 'net.BeautifulSoup)

(debug-print-width #f)

(let1 sxml (read-file/sxml "test/data1.htm")
  (test* "Normal title"
         "Title"
         ((if-car-sxpath '(html head title *text*)) sxml))
  )


(test-end)
