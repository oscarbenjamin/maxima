;;; -*-  Mode: Lisp; Package: Maxima; Syntax: Common-Lisp; Base: 10 -*- ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     The data in this file contains enhancements.                   ;;;;;
;;;                                                                    ;;;;;
;;;  Copyright (c) 1984,1987 by William Schelter,University of Texas   ;;;;;
;;;     All rights reserved                                            ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     (c) Copyright 1980 Massachusetts Institute of Technology         ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package :maxima)

(macsyma-module sprdet)

;; THIS IS THE NEW DETERMINANT PACKAGE

(declare-top (special x *ptr* *ptc* *blk* ml* *detsign* rzl*))

(defun sprdet (ax n)
  (declare (fixnum n))
  (setq ax (get-array-pointer ax))
  (prog ((j 0) rodr codr bl det (dm 0) (r 0) (i 0))
     (declare (fixnum i j dm r))
     (setq det 1)
     (setq  *ptr* (make-array (1+ n)))
     (setq  *ptc* (make-array (1+ n)))
     (setq bl (tmlattice ax '*ptr* '*ptc* n)) ;tmlattice isn't defined anywhere -- are_muc
     (when (null bl) (return 0))
     (setq rodr (apply #'append bl))
     (setq codr (mapcar #'cadr rodr))
     (setq rodr (mapcar #'car rodr))
     (setq det (* (prmusign rodr) (prmusign codr)))
     (setq bl (mapcar #'length bl))
     loop1 (when (null bl) (return det))
     (setq i (car bl))
     (setq dm i)
     (setq *blk* (make-array (list (1+ dm) (1+ dm))))
     (cond ((= dm 1)
	    (setq det (gptimes det (car (aref ax (aref *ptr* (1+ r)) (aref *ptc* (1+ r))))))
	    (go next))
	   ((= dm 2)
	    (setq det (gptimes det
			       (gpdifference
				(gptimes (car (aref ax (aref *ptr* (1+ r)) (aref *ptc* (1+ r))))
					 (car (aref ax (aref *ptr* (+ 2 r)) (aref *ptc* (+ 2 r)))))
				(gptimes (car (aref ax (aref *ptr* (1+ r)) (aref *ptc* (+ 2 r))))
					 (car (aref ax (aref *ptr* (+ 2 r)) (aref *ptc* (1+ r))))))))
	    (go next)))
     loop2 (when (= i 0) (go cmp))
     (setq j dm)
     loop3 (when (= j 0) (decf i) (go loop2))
     (setf (aref *blk* i j) (car (aref ax (aref *ptr* (+ r i)) (aref *ptc*(+ r j)))))
     (decf j) (go loop3)
     cmp
     (setq det (gptimes det (tdbu '*blk* dm)))
     next   
     (incf r dm)
     (setq bl (cdr bl))
     (go loop1)))

(defun minorl (x n l nz)
  (declare (fixnum n))
  (prog (ans s rzl* (col 1) (n2 (truncate n 2)) d dl z a elm rule)
     (declare (fixnum n2  col ))
     (decf n2)
     (setq dl l l nil nz (cons nil nz))
     l1 (when (null nz) (return ans))
     l3 (setq z (car nz))
     (cond ((null l) (if dl (push dl ans) (return nil))
	    (setq nz (cdr nz) col (1+ col) l dl dl nil)
	    (go l1)))
     (setq a (caar l) )
     l2 (cond ((null z)
	       (cond (rule (rplaca (car l) (list a rule))
			   (setq rule nil) (setq l (cdr l)))
		     ((null (cdr l))
		      (rplaca (car l) (list a 0))
		      (setq l (cdr l)))
		     (t (rplaca l (cadr l))
			(rplacd l (cddr l))))
	       (go l3)))
     (setq elm (car z) z (cdr z))
     (setq s (signnp elm a))
     (cond (s (setq d (delete elm (copy-list a) :test #'equal))
	      (cond ((membercar d dl)
		     (go on))
		    (t
		     (when (or (< col n2) (not (singp x d col n)))
		       (push (cons d 1) dl)
		       (go on))))))
     (go l2)
     on (setq rule (cons (list d s elm (1- col)) rule))
     (go l2)))

(declare-top (special j))

(defun singp (x ml col n)
  (declare (fixnum col n))
  (prog (i (j col) l) 
     (declare (fixnum  j))
     (setq l ml)
     (if (null ml)
	 (go loop)
	 (setq i (car ml)
	       ml (cdr ml)))
     (cond ((member i rzl* :test #'equal) (return t))
	   ((zrow x i col n) (return (setq rzl*(cons i rzl*)))))
     loop (cond ((> j n) (return nil))
		((every #'(lambda (i) (equal (aref x i j) 0)) l)
		 (return t)))
     (incf j)
     (go loop)))

(declare-top (unspecial j))

(defun tdbu (x n)
  (declare (fixnum n))
  (prog (a ml* nl nml dd)
     (setq *detsign* 1)
     (setq x (get-array-pointer x))
     (detpivot x n)
     (setq x (get-array-pointer 'x*))
     (setq nl (nzl x n))
     (when (member nil nl :test #'eq) (return 0))
     (setq a (minorl x n (list (cons (nreverse(index* n)) 1)) nl))
     (setq nl nil)
     (when (null a) (return 0))
     (tb2 x (car a) n)
     tag2
     (setq ml* (cons (cons nil nil) (car a)))
     (setq a (cdr a))
     (when (null a) (return (if (= *detsign* 1)
				(cadadr ml*)
				(gpctimes -1  (cadadr ml*)))))
     (setq nml (car a))
     tag1 (when (null nml) (go tag2))
     (setq dd  (car nml))
     (setq nml (cdr nml))
     (nbn dd)
     (go tag1)))

(defun nbn (rule)
  (declare (special x))
  (prog (ans r a)
     (setq ans 0 r (cadar rule))
     (when (equal r 0) (return 0))
     (rplaca rule (caar rule))
     loop (when (null r) (return (rplacd rule (cons ans (cdr rule)))))
     (setq a (car r) r(cdr r))
     (setq ans (gpplus ans (gptimes (if (= (cadr a) 1)
					(aref x (caddr a) (cadddr a))
					(gpctimes (cadr a) (aref x (caddr a) (cadddr a))))
				    (getminor (car a)))))
     (go loop)))

(defun getminor (index)
  (cond ((null (setq index (assoc index ml* :test #'equal))) 0)
	(t (rplacd (cdr index) (1- (cddr index)))
	 (when (= (cddr index) 0)
	   (setf index (delete index ml* :test #'equal)))
	 (cadr index))))

(defun tb2 (x l n)
  (declare (fixnum n ))
  (prog ((n-1 (1- n)) b a)
     (declare (fixnum n-1))
     loop (when (null l) (return nil))
     (setq a (car l) l (cdr l) b (car a))
     (rplacd a (cons (gpdifference (gptimes (aref x (car b) n-1) (aref x (cadr b) n))
				   (gptimes (aref x (car b) n) (aref x (cadr b) n-1)))
		     (cdr a)))
     (go loop)))

(defun zrow (x i col n)
  (declare (fixnum i col n))
  (prog ((j col))
     (declare (fixnum j))
     loop (cond ((> j n)
		 (return t))
		((equal (aref x i j) 0)
		 (incf j)
		 (go loop)))))

(defun nzl (a n)
  (declare (fixnum n))
  (prog ((i 0) (j (- n 2)) d l)
     (declare (fixnum i j))
     loop0 (when (= j 0) (return l))
     (setq i n)
     loop1 (when (= i 0)
	     (push d l)
	     (setq d nil)
	     (decf j)
	     (go loop0))
     (when (not (equal (aref a i j) 0))
       (push i d))
     (decf i)
     (go loop1)))

(defun signnp (e l)
  (prog (i)
     (setq i 1)
     loop (cond ((null l) (return nil))
		((equal e (car l)) (return i)))
     (setq l (cdr l) i (- i))
     (go loop)))

(defun membercar (e l)
  (prog()
   loop (cond ((null l)
	       (return nil))
	      ((equal e (caar l))
	       (return (rplacd (car l) (1+ (cdar l))))))
   (setq l (cdr l))
   (go loop)))

(declare-top (unspecial x ml* rzl*))

(defun atranspose (a n)
  (prog (i j d)
     (setq i 0)
     loop1 (setq i (1+ i) j i)
     (when (> i n) (return nil))
     loop2 (incf j)
     (when (> j n) (go loop1))
     (setq d (aref a i j))
     (setf (aref a i j) (aref a j i))
     (setf (aref a j i) d)
     (go loop2)))

(defun mxcomp (l1 l2)
  (prog()
   loop (cond ((null l1) (return t))
	      ((car> (car l1) (car l2)) (return t))
	      ((car> (car l2) (car l1)) (return nil)))
   (setq l1 (cdr l1) l2 (cdr l2))
   (go loop)))

(defun prmusign (l)
  (prog ((b 0) a d)
     (declare (fixnum b))
     loop (when (null l) (return (if (even b) 1 -1)))
     (setq a (car l) l (cdr l) d l)
     loop1 (cond ((null d) (go loop))
		 ((> a (car d)) (incf b)))
     (setq d (cdr d))
     (go loop1)))

(defun detpivot (x n)
  (prog (r0 c0)
     (setq c0 (colrow0 x n nil)
	   r0 (colrow0 x n t))
     (setq c0 (nreverse (bbsort c0 #'car>)))
     (setq r0 (nreverse (bbsort r0 #'car>)))
     (when (not (mxcomp c0 r0))
       (atranspose x n)
       (setq c0 r0))
     (setq *detsign* (prmusign (mapcar #'car c0)))
     (newmat 'x* x n c0)))

(defun newmat(x y n l)
  (prog (i j jl)
     (setf (symbol-value x) (make-array (list (1+ n) (1+ n))))
     (setq x (get-array-pointer x))
     (setq j 0)
     loop (setq i 0 j (1+ j))
     (when (null l) (return nil))
     (setq jl (cdar l) l (cdr l))
     tag (incf i)
     (when (> i n) (go loop))
     (setf (aref x i j) (aref y i jl))
     (go tag)))

(defun car> (a b)
  (> (car a) (car b)))

;; ind=t for row ortherwise col

(defun colrow0 (a n ind)
  (declare (fixnum n))
  (prog ((i 0) (j n)  l (c 0))
     (declare (fixnum i  c j))
     loop0 (cond ((= j 0) (return l)))
     (setq i n)
     loop1 (when (= i 0)
	     (push (cons c j) l)
	     (setq c 0)
	     (decf j)
	     (go loop0))
     (when (equal (if ind (aref a j i) (aref a i j)) 0)
       (incf c))
     (decf i)
     (go loop1)))

(defun gpdifference (a b)
  (if $ratmx
      (pdifference a b)
      (simplus(list '(mplus) a (list '(mtimes) -1 b)) 1 nil)))

(defun gpctimes(a b)
  (if $ratmx
      (pctimes a b)
      (simptimes(list '(mtimes) a b) 1 nil)))

(defun gptimes(a b)
  (if $ratmx
      (ptimes a b)
      (simptimes (list '(mtimes) a b) 1 nil)))

(defun gpplus(a b)
  (if $ratmx
      (pplus a b)
      (simplus(list '(mplus) a b) 1 nil)))
