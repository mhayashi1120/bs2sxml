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
  (receive (proto server path)
      (parse-uri url)
    (receive (status headers body)
        (http-get server path
                  :secure (string=? proto "https"))
      (receive (ip op) (sys-pipe)
        (let1 th (make-thread 
                  (^()
                    (display body op)
                    (close-output-port op)))
          (thread-start! th)
          (let1 sxml (call-bs2sxml ip)
            (thread-join! th)
            (values sxml status headers)))))))

(define (parse-uri uri)
  (receive (proto user host port path query . rest)
      (uri-parse uri)
    (let ([server (cond
                   [(and port host)
                    #`",|host|:,|port|"]
                   [else host])]
          [htpath (cond
                   [(and path query)
                    #`",|path|?,|query|"]
                   [path path]
                   [else "/"])])
      (values proto server htpath))))

(define (call-bs2sxml iport)
  (let* ([p (run-process `(bs2sxml) :input iport :output 'out)]
         [out (port->string (process-output p 'out))])
    (begin0
      (with-input-from-string out read)
      (process-wait p)
      (unless (eq? (process-exit-status p) 0)
        (error "failed exit bs2sxml" out)))))
