(define url "https://jsonplaceholder.typicode.com/todos/1")

(define json (request url))

json

(define dict (json-to-assoc-list json))

dict

(assoc "userId" dict)

(assoc "id" dict)

(assoc "title" dict)

(assoc "completed" dict)
