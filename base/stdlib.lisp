(define any
  (lambda (p xs)
    (foldr
      (lambda (x acc)
        (or (p x) acc))
      '()
      xs)))

(define all
  (lambda (p xs)
    (foldr
      (lambda (x acc)
        (and (p x) acc))
      't
      xs)))

(define length
  (lambda (xs)
    (foldr (lambda (x acc) (+ 1 acc))
           0
           xs)))

(define range
  (lambda (x0 x1)
    (cond ((> x0 x1) '())
          ('t
           (cons x0 (range (+ x0 1) x1))))))

(define sum
  (lambda (xs)
    (foldr + 0 xs)))

(define product
  (lambda (xs)
    (foldr * 1 xs)))
