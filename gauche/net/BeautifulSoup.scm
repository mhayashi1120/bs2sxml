(define-module net.BeautifulSoup
  (use gauche.threads)
  (use gauche.charconv)
  (use gauche.process)
  (use rfc.http)
  (use rfc.uri)
  (export 
   read/sxml read-url/sxml read-file/sxml
   ))
(select-module net.BeautifulSoup)

(define (read-file/sxml file :key (encoding #f))
  (let* ([fp (open-input-file file :encoding encoding)])
    (call-bs2sxml fp)))

(define (read/sxml :optional (port (current-input-port)))
  (call-bs2sxml port))

(define (read-url/sxml url)
  (receive (proto a host b path . rest) 
      (uri-parse url)
    (receive (status headers body)
        (http-get host path
                  :secure (string=? proto "https"))
      (receive (ip op) (sys-pipe)
        (let1 th (make-thread (^() (call-bs2sxml ip)))
          (thread-start! th)
          (display body op)
          (close-output-port op)
          (let1 sxml (call-bs2sxml ip)
            (values sxml status headers)))))))

(define (call-bs2sxml iport)
  (let1 p (run-process `(bs2sxml) :input iport :output 'out)
    (begin0
      (with-input-from-port (process-output p 'out)
        read)
      (process-wait p)
      (unless (eq? (process-exit-status p) 0)
        (error "failed exit bs2sxml"
               (port->string 
                (process-output p 'out)))))))
