(define url "https://jsonplaceholder.typicode.com/todos/1")

(define json (request url))

json

(define dict (json-to-assoc-list json))

dict


(define foreach
  (lambda (xs f)
    (cond ((null xs) 't)
          ('t (seq
                (f (car xs))
                (foreach (cdr xs) f))))))

(define keys
  (map fst dict))

keys

(foreach keys
  (lambda (x)
    (seq
      (print x)
      (print ":")
      (print (assoc x dict))
      (println ""))))

