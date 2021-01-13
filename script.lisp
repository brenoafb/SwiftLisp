(and 't 't)
(+ 1 1)
(define myfunc
  (lambda (x y)
    (cond (x 'x)
          (y 'y))))

(myfunc '() '())

(define mylist '(0 1 2 3 4))

(cons 0 '(1 2 3 4))

(define even
  (lambda (x)
    (cond ((eq x 0) 't)
          ((eq x 1) '())
          ('t (even (- x 2))))))

(even 2)

(even 1)

(even 120)

(length '(1 2 3 4 5))

(any even '(1 2 3 4 5))

(any even '(1 3 5 7))

(any even '(0))

(map (lambda (x) (+ x 1)) mylist)

(filter even '(1 2 3 4 5))

(define odd
  (lambda (x)
    (not (even x))))

(append (filter even mylist) (filter odd mylist))

(define concat
  (lambda (xs)
    (cond ((null xs) '())
          ('t (append (car xs)
                      (concat (cdr xs)))))))

(define listoflists '((0) () (1 2) (3) (4 5) (6)))

(concat listoflists)
