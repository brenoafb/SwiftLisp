(define cadr
  (lambda (x) (car (cdr x))))

(define caddr
  (lambda (x) (car (cdr (cdr x)))))

(define caar
  (lambda (x)
    (car (car x))))

(define cadar
  (lambda (x)
    (car (cdr (car x)))))

(define null
  (lambda (x) (eq x '())))

(define and
  (lambda (x y)
    (cond (x (cond (y 't)))
          ('t '()))))

(define not
  (lambda (x)
    (cond (x '())
          ('t 't))))

(define append
  (lambda (x y)
    (cond ((null x) y)
          ('t (cons (car x) (append (cdr x) y))))))

(define pair
  (lambda (x y)
    (cond ((and (null x) (null y)) '())
          ((and (not (atom x)) (not (atom y)))
           (cons (list (car x) (car y))
                 (pair (cdr x) (cdr y)))))))

(define assoc
  (lambda (x y)
    (cond ((eq (caar y) x) (cadar y))
          ('t (assoc x (cdr y))))))

(define length
  (lambda (xs)
    (cond ((null xs) 0)
          ('t (+ 1 (length (cdr xs)))))))

(define any
  (lambda (p xs)
    (cond ((null xs) '())
          ((p (car xs)) 't)
          ('t (any p (cdr xs))))))


(define filter
  (lambda (p xs)
    (cond ((null xs) '())
          ((p (car xs)) (cons (car xs)
                              (filter p (cdr xs))))
          ('t (filter p (cdr xs))))))

(define map
  (lambda (f xs)
    (cond ((null xs) '())
          ('t (cons (f (car xs))
                    (map f (cdr xs)))))))
