(use gauche.test)

(test-start "net.BeautifulSoup")

(use net.BeautifulSoup)
(use sxml.sxpath)
(use srfi-13)
(test-module 'net.BeautifulSoup)

(debug-print-width #f)

(let1 sxml (read-file/sxml "test/data1.htm")
  (test* "Normal title"
         "Title"
         ((if-car-sxpath '(html head title *text*)) sxml))
  (test* "Normal title"
         '("Header" "Footer")
         (map string-trim-both ((sxpath '(html body *text*)) sxml)))
  (test* "Normal attribute"
         "hoge"
         ((if-car-sxpath '(html body div @ id *text*)) sxml)))

;;TODO
;; (let1 sxml (read-file/sxml "test/invalid1.htm")
;;   sxml)




(test-end)
