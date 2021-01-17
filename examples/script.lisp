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

(define odd
  (lambda (x)
    (not (even x))))


(even 2)

(even 1)

(even 120)

(length '(1 2 3 4 5))

(any even '(0))

(any even '(1 2 3 4 5))

(any even '(1 3 5 7))

(all even '(0))

(all even '(0 2 4 6))

(define concat
  (lambda (xs)
    (cond ((null xs) '())
          ('t (append (car xs)
                      (concat (cdr xs)))))))

(define listoflists '((0) () (1 2) (3) (4 5) (6)))

(concat listoflists)

(define xs (range 0 5))

(sum xs)

(define xs (range 0 10))

(sum xs)

(define xs (cdr xs))

xs

(product xs)

(define fib-iter
  (lambda (a b n)
    (cond ((eq n 0) b)
          ('t
           (fib-iter (+ a b) a (- n 1))))))

(define fib
  (lambda (n)
    (fib-iter 1 0 n)))

(fib 50)

(type '(0 1 2 3 4))

(type 'hello)

(type 3.14)

(type 4)

(sum (range 0 100))
(product (range 1 20))

(replace '((hello goodbye) (world everyone)) '(hello world))

(replace '((simple complicated) (flat nested))
         '(this is a (really simple) (totally (flat)) structure))


(range 0 9)
(append (range 0 10) (range 10 20))

(define dict (zip (range 0 10) (range 0 10)))

(assoc 0 dict)
(assoc 1 dict)
(assoc 2 dict)
(assoc 3 dict)
(assoc 100 dict)

(map (lambda (x) (+ 1 x))
     (range 0 10))

(filter even '(0 1 2 3 4))
(filter even (range 0 10))
