(define num-op-template
  '(lambda (x y)
     (cond ((and (eq (type x) 'float)
                 (eq (type y) 'float))
            (__F_OP__ x y))
           ((and (eq (type x) 'int)
                 (eq (type y) 'int))
            (__I_OP__ x y))
           ('t '()))))

(define mk-num-op
  (lambda (float-op int-op)
    (replace (zip '(__F_OP__ __I_OP__) (list float-op int-op))
             num-op-template)))

(define +
  (mk-num-op '+.f '+.i))

(define *
  (mk-num-op '*.f '*.i))

(define -
  (mk-num-op '-.f '-.i))

(define /
  (mk-num-op '/.f '/.i))

(define >
  (mk-num-op '>.f '>.i))

(define >=
  (mk-num-op '>=.f '>=.i))

(define <
  (mk-num-op '<.f '<.i))

(define <=
  (mk-num-op '<=.f '<=.i))

(define !=
  (mk-num-op '!=.f '!=.i))
