(define x "This is a string")

x

(println x)

(println "Hello world")

(println (+ 1 2))

(println 'this 'is 'the 'print 'function)

(define pyramid
  (lambda (n)
    (cond ((eq n 0) 't)
          ('t
           (seq
             (print (get-line '* n))
             (println)
             (pyramid (- n 1)))))))

(define get-line
  (lambda (c n)
    (cond ((eq n 0) '())
          ('t (cons c (get-line c (- n 1)))))))

(pyramid 5)
