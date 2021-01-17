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
  (lambda (xs ys)
    (foldr
      (lambda (x acc)
        (cons x acc))
      ys
      xs)))

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
    (cadr pair)))

(define assoc
  (lambda (x y)
    (cond ((eq (caar y) x) (cadar y))
          ('t (assoc x (cdr y))))))

(define assoc
  (lambda (key dict)
    (seq
      (define result
        (foldr
          (lambda (x acc)
            (cond ((eq (type acc) 'list) acc)
                  ((eq key (fst x)) (list key (snd x)))
                  ('t acc)))
          'not-found
          dict))
      (cond ((eq (type result) 'atom)
             '())
            ('t (snd result))))))

(define filter
  (lambda (p xs)
    (foldr
      (lambda (x acc)
        (cond ((p x) (cons x acc))
              ('t acc)))
      '()
      xs)))

(define map
  (lambda (f xs)
    (foldr
      (lambda (x acc)
        (cons (f x) acc))
      '()
      xs)))

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
