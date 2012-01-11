(define-module net.BeautifulSoup
  (use rfc.http)
  (use rfc.uri)
  (use gauche.process)
  (export 
   read-url/sxml read-file/sxml
   ))
(select-module net.BeautifulSoup)

(define (read-file/sxml file)
  (call-bs2sxml (open-input-file file)))

(define (read-url/sxml url)
  (receive (proto a host b path . rest) 
      (uri-parse url)
    (receive (status headers body)
        (http-get host path)
      (receive (ip op) (sys-pipe)
        (write body op)
        (close-output-port op)
        (let1 sxml (call-bs2sxml ip)
          (values sxml status headers))))))

(define (call-bs2sxml input-port)
  (let1 p (run-process `(bs2sxml) :input input-port :output 'out)
    (process-wait p)
    (unless (eq? (process-exit-status p) 0)
      (error "failed exit bs2sxml"))
    (with-input-from-port (process-output p 'out)
      read)))
