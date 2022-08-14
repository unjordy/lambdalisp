(load "./lazy.cl")


(def-lazy "(" (+ 32 8))
(def-lazy ")" (succ "("))
(def-lazy " " 32)
(def-lazy "\\n" (+ 8 2))

(def-lazy "A" (succ 64))
(def-lazy "B" (succ "A"))
(def-lazy "C" (succ "B"))
(def-lazy "D" (succ "C"))


(defrec-lazy map (f list)
  (if (isnil list)
    nil
    (cons (f (car list)) (map f (cdr list)))))

(defmacro-lazy typematch (tvar t0 t1)
  `(,tvar ,t0 ,t1))

(defun-lazy type-atom (t0 t1) t0)
(defun-lazy type-list (t0 t1) t1)

(defun-lazy char2stream (char)
  (cons char))

(defun-lazy catstream (stream1 stream2)
  (lambda (stream) (stream1 (stream2 stream))))

(def-lazy nullstream (lambda (x) x))

(defrec-lazy catstreamlist (streamlist)
  (if (isnil streamlist)
    nullstream
    (catstream (car streamlist) (catstreamlist (cdr streamlist)))))

(defrec-lazy str2stream (s)
  (catstreamlist (map char2stream s)))

(defrec-lazy printexpr (atomenv expr)
  (let ((exprtype (car expr)) (value (cdr expr)))
    (typematch exprtype
      ;; atom
      (car (value cdr atomenv))
      ;; list
      (catstreamlist
        (list (char2stream "(")
              ((letrec-lazy interleave-space (slist)
                  (if (isnil (cdr slist))
                    (car slist)
                    (catstreamlist (list (car slist) (char2stream " ") (interleave-space (cdr slist))))))
               (map (printexpr atomenv) value))
              (char2stream ")"))))))

(defrec-lazy read-atom (curstream stdin)
  (let ((c (car stdin)))
    (if (or (= " " c) (= "(" c) (= ")" c) (= 256 c))
        (cons curstream stdin)
        (read-atom (catstream curstream (char2stream (car stdin))) (cdr stdin)))))

;; (defrec-lazy parseexpr (self stream)
;;   (let ((c (car stream)))
;;     (cond
;;       ((= c "(")
;;         (cons type-list (self self )))
;;       ((= c ")"))
;;       ((= c " "))
;;       ((= c "\n")))))

(def-lazy test
  (list type-atom))

(defrec-lazy f (x)
  (cons "A" (f nil))
  ;; (lambda (x) (cons "A" (x nil)))
  )

(defmacro-lazy atom* (value)
  `(cons type-atom ,value))

(defmacro-lazy list* (arg &rest args)
  `(cons type-list (list ,arg ,@args)))


(defun-lazy main (stdin)
  ((car (read-atom nullstream stdin))
   (inflist 256))
  ;; ((printexpr
  ;;     (list (char2stream "A") (str2stream (list "A" "B" "C")) (char2stream "C"))
  ;;     (list*  (atom* 2)
  ;;             (list* (atom* 1) (atom* 2) (atom* 0))
  ;;             (atom* 0))
  ;;       )
  ;;  (inflist 256))
  )

;; (print (macroexpand-lazy main))
(format t (compile-to-ski-lazy main))

;; (defun-lazy main (stdin)
;;   (lazystr2blcstr (program (blcstr2lazystr stdin))))

;; (print (compile-to-blc-lazy main))
