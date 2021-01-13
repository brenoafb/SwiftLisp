(define fib
  (lambda (x)
    (cond ((eq x 0) 0)
          ((eq x 1) 1)
          ((quote t)
           (+ (fib (- x 1))
              (fib (- x 2)))))))

(fib 0)
(fib 1)
(fib 5)
(fib 10)
