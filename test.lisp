(define fib (lambda (x)
  (cond ((< x 2) x)
        ('t (+ (fib (- x 1))
               (fib (- x 2)))))))

(fib 10)
