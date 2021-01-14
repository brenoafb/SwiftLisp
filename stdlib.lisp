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

(define or
  (lambda (x y)
    (cond (x 't)
          (y 't)
          ('t '()))))

(define not
  (lambda (x)
    (cond (x '())
          ('t 't))))

(define append
  (lambda (x y)
    (cond ((null x) y)
          ('t (cons (car x) (append (cdr x) y))))))

(define zip
  (lambda (x y)
    (cond ((and (null x) (null y)) '())
          ((and (not (atom x)) (not (atom y)))
           (cons (list (car x) (car y))
                 (zip (cdr x) (cdr y)))))))

(define fst
  (lambda (pair)
    (car pair)))

(define snd
  (lambda (pair)
    (car (cdr pair))))

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

(define foldr
  (lambda (f x0 xs)
    (cond ((null xs) x0)
          ('t
            (f (car xs) (foldr f x0 (cdr xs)))))))

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

(define replace
  (lambda (pairs xs)
    (foldr
      (lambda (x acc)
        (cond ((eq (type x) 'list)
               (cons (replace pairs x) acc))
              ('t
               (cond ((elem x (map fst pairs))
                      (cons (assoc x pairs) acc))
                     ('t (cons x acc))))))
      '()
      xs)))

(define elem
  (lambda (x xs)
    (foldr (lambda (e acc)
             (or acc (eq e x)))
           '()
           xs)))
