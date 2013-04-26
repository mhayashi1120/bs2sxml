(define-module net.BeautifulSoup
  (use sxml.ssax)
  (use gauche.parameter)
  (use gauche.threads)
  (use gauche.charconv)
  (use gauche.process)
  (use rfc.http)
  (use rfc.uri)
  (export
   read/sxml read-url/sxml read-file/sxml
   bs2xml-command))
(select-module net.BeautifulSoup)

(define bs2xml-command
  (make-parameter "bs2xml"))

(define (read-file/sxml file :key (encoding #f))
  ;; TODO encoding is obsoleted investigate about encoding
  (let1 fp (open-input-file file)
    (unwind-protect
     (call-bs2xml fp)
     (close-output-port fp))))

(define (read/sxml :optional (port (current-input-port)))
  (call-bs2xml port))

(define (read-url/sxml url :optional (post-data #f))
  (receive (secure? server path)
      (parse-uri url)
    (receive (status headers body)
        (if post-data
          (http-post server path post-data)
          (http-get server path
                    :secure secure?))
      (receive (ip op) (sys-pipe)
        (unwind-protect
         (let1 th (make-thread
                   (^()
                     (display body op)
                     (close-output-port op)))
           (thread-start! th)
           (let1 sxml (call-bs2xml ip)
             (thread-join! th)
             (values sxml status headers)))
         (begin
           (close-input-port ip)
           (close-output-port op)))))))

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
      (values (string=? proto "https") server htpath))))

(define (call-bs2xml iport)
  (let* ([p (run-process `(,(bs2xml-command)) :input iport :output 'out)]
         [out (process-output p 'out)])
    (guard (e [else
               (process-wait p)
               (unless (eq? (process-exit-status p) 0)
                 (error "failed exit bs2xml" (port->string out)))
               (raise e)])
      (ssax:xml->sxml out '()))))
