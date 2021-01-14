(define replace
  (lambda (q x)
    (cond ((null q) '())
          ((eq (car q) '__R__)
           (cons x (replace q x)))
          ('t (cons (car q) (replace q x))))))

(replace '(hello my name is _R_) 'breno)
