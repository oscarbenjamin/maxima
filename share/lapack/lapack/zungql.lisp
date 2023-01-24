;;; Compiled by f2cl version:
;;; ("f2cl1.l,v 95098eb54f13 2013/04/01 00:45:16 toy $"
;;;  "f2cl2.l,v 95098eb54f13 2013/04/01 00:45:16 toy $"
;;;  "f2cl3.l,v 96616d88fb7e 2008/02/22 22:19:34 rtoy $"
;;;  "f2cl4.l,v 96616d88fb7e 2008/02/22 22:19:34 rtoy $"
;;;  "f2cl5.l,v 95098eb54f13 2013/04/01 00:45:16 toy $"
;;;  "f2cl6.l,v 1d5cbacbb977 2008/08/24 00:56:27 rtoy $"
;;;  "macros.l,v 1409c1352feb 2013/03/24 20:44:50 toy $")

;;; Using Lisp CMU Common Lisp snapshot-2013-11 (20E Unicode)
;;; 
;;; Options: ((:prune-labels nil) (:auto-save t) (:relaxed-array-decls t)
;;;           (:coerce-assigns :as-needed) (:array-type ':array)
;;;           (:array-slicing t) (:declare-common nil)
;;;           (:float-format single-float))

(in-package "LAPACK")


(let* ((zero (f2cl-lib:cmplx 0.0d0 0.0d0)))
  (declare (type (f2cl-lib:complex16) zero) (ignorable zero))
  (defun zungql (m n k a lda tau work lwork info)
    (declare (type (array f2cl-lib:complex16 (*)) work tau a)
             (type (f2cl-lib:integer4) info lwork lda k n m))
    (f2cl-lib:with-multi-array-data
        ((a f2cl-lib:complex16 a-%data% a-%offset%)
         (tau f2cl-lib:complex16 tau-%data% tau-%offset%)
         (work f2cl-lib:complex16 work-%data% work-%offset%))
      (prog ((i 0) (ib 0) (iinfo 0) (iws 0) (j 0) (kk 0) (l 0) (ldwork 0)
             (lwkopt 0) (nb 0) (nbmin 0) (nx 0) (lquery nil))
        (declare (type (f2cl-lib:integer4) i ib iinfo iws j kk l ldwork lwkopt
                                           nb nbmin nx)
                 (type f2cl-lib:logical lquery))
        (setf info 0)
        (setf lquery (coerce (= lwork -1) 'f2cl-lib:logical))
        (cond
          ((< m 0)
           (setf info -1))
          ((or (< n 0) (> n m))
           (setf info -2))
          ((or (< k 0) (> k n))
           (setf info -3))
          ((< lda (max (the f2cl-lib:integer4 1) (the f2cl-lib:integer4 m)))
           (setf info -5)))
        (cond
          ((= info 0)
           (cond
             ((= n 0)
              (setf lwkopt 1))
             (t
              (setf nb (ilaenv 1 "ZUNGQL" " " m n k -1))
              (setf lwkopt (f2cl-lib:int-mul n nb))))
           (setf (f2cl-lib:fref work-%data% (1) ((1 *)) work-%offset%)
                   (coerce lwkopt 'f2cl-lib:complex16))
           (cond
             ((and
               (< lwork
                  (max (the f2cl-lib:integer4 1) (the f2cl-lib:integer4 n)))
               (not lquery))
              (setf info -8)))))
        (cond
          ((/= info 0)
           (xerbla "ZUNGQL" (f2cl-lib:int-sub info))
           (go end_label))
          (lquery
           (go end_label)))
        (cond
          ((<= n 0)
           (go end_label)))
        (setf nbmin 2)
        (setf nx 0)
        (setf iws n)
        (cond
          ((and (> nb 1) (< nb k))
           (setf nx
                   (max (the f2cl-lib:integer4 0)
                        (the f2cl-lib:integer4
                             (ilaenv 3 "ZUNGQL" " " m n k -1))))
           (cond
             ((< nx k)
              (setf ldwork n)
              (setf iws (f2cl-lib:int-mul ldwork nb))
              (cond
                ((< lwork iws)
                 (setf nb (the f2cl-lib:integer4 (truncate lwork ldwork)))
                 (setf nbmin
                         (max (the f2cl-lib:integer4 2)
                              (the f2cl-lib:integer4
                                   (ilaenv 2 "ZUNGQL" " " m n k -1))))))))))
        (cond
          ((and (>= nb nbmin) (< nb k) (< nx k))
           (setf kk
                   (min k
                        (*
                         (the f2cl-lib:integer4
                              (truncate (- (+ (- k nx) nb) 1) nb))
                         nb)))
           (f2cl-lib:fdo (j 1 (f2cl-lib:int-add j 1))
                         ((> j (f2cl-lib:int-add n (f2cl-lib:int-sub kk))) nil)
             (tagbody
               (f2cl-lib:fdo (i (f2cl-lib:int-add m (f2cl-lib:int-sub kk) 1)
                              (f2cl-lib:int-add i 1))
                             ((> i m) nil)
                 (tagbody
                   (setf (f2cl-lib:fref a-%data%
                                        (i j)
                                        ((1 lda) (1 *))
                                        a-%offset%)
                           zero)
                  label10))
              label20)))
          (t
           (setf kk 0)))
        (multiple-value-bind (var-0 var-1 var-2 var-3 var-4 var-5 var-6 var-7)
            (zung2l (f2cl-lib:int-sub m kk) (f2cl-lib:int-sub n kk)
             (f2cl-lib:int-sub k kk) a lda tau work iinfo)
          (declare (ignore var-0 var-1 var-2 var-3 var-5 var-6))
          (setf lda var-4)
          (setf iinfo var-7))
        (cond
          ((> kk 0)
           (f2cl-lib:fdo (i (f2cl-lib:int-add k (f2cl-lib:int-sub kk) 1)
                          (f2cl-lib:int-add i nb))
                         ((> i k) nil)
             (tagbody
               (setf ib
                       (min (the f2cl-lib:integer4 nb)
                            (the f2cl-lib:integer4
                                 (f2cl-lib:int-add (f2cl-lib:int-sub k i) 1))))
               (cond
                 ((> (f2cl-lib:int-add n (f2cl-lib:int-sub k) i) 1)
                  (zlarft "Backward" "Columnwise"
                   (f2cl-lib:int-sub
                    (f2cl-lib:int-add (f2cl-lib:int-sub m k) i ib)
                    1)
                   ib
                   (f2cl-lib:array-slice a-%data%
                                         f2cl-lib:complex16
                                         (1
                                          (f2cl-lib:int-add
                                           (f2cl-lib:int-sub n k)
                                           i))
                                         ((1 lda) (1 *))
                                         a-%offset%)
                   lda
                   (f2cl-lib:array-slice tau-%data%
                                         f2cl-lib:complex16
                                         (i)
                                         ((1 *))
                                         tau-%offset%)
                   work ldwork)
                  (zlarfb "Left" "No transpose" "Backward" "Columnwise"
                   (f2cl-lib:int-sub
                    (f2cl-lib:int-add (f2cl-lib:int-sub m k) i ib)
                    1)
                   (f2cl-lib:int-sub
                    (f2cl-lib:int-add (f2cl-lib:int-sub n k) i)
                    1)
                   ib
                   (f2cl-lib:array-slice a-%data%
                                         f2cl-lib:complex16
                                         (1
                                          (f2cl-lib:int-add
                                           (f2cl-lib:int-sub n k)
                                           i))
                                         ((1 lda) (1 *))
                                         a-%offset%)
                   lda work ldwork a lda
                   (f2cl-lib:array-slice work-%data%
                                         f2cl-lib:complex16
                                         ((+ ib 1))
                                         ((1 *))
                                         work-%offset%)
                   ldwork)))
               (multiple-value-bind
                     (var-0 var-1 var-2 var-3 var-4 var-5 var-6 var-7)
                   (zung2l
                    (f2cl-lib:int-sub
                     (f2cl-lib:int-add (f2cl-lib:int-sub m k) i ib)
                     1)
                    ib ib
                    (f2cl-lib:array-slice a-%data%
                                          f2cl-lib:complex16
                                          (1
                                           (f2cl-lib:int-add
                                            (f2cl-lib:int-sub n k)
                                            i))
                                          ((1 lda) (1 *))
                                          a-%offset%)
                    lda
                    (f2cl-lib:array-slice tau-%data%
                                          f2cl-lib:complex16
                                          (i)
                                          ((1 *))
                                          tau-%offset%)
                    work iinfo)
                 (declare (ignore var-0 var-1 var-2 var-3 var-5 var-6))
                 (setf lda var-4)
                 (setf iinfo var-7))
               (f2cl-lib:fdo (j (f2cl-lib:int-add n (f2cl-lib:int-sub k) i)
                              (f2cl-lib:int-add j 1))
                             ((> j
                                 (f2cl-lib:int-add n
                                                   (f2cl-lib:int-sub k)
                                                   i
                                                   ib
                                                   (f2cl-lib:int-sub 1)))
                              nil)
                 (tagbody
                   (f2cl-lib:fdo (l
                                  (f2cl-lib:int-add m
                                                    (f2cl-lib:int-sub k)
                                                    i
                                                    ib)
                                  (f2cl-lib:int-add l 1))
                                 ((> l m) nil)
                     (tagbody
                       (setf (f2cl-lib:fref a-%data%
                                            (l j)
                                            ((1 lda) (1 *))
                                            a-%offset%)
                               zero)
                      label30))
                  label40))
              label50))))
        (setf (f2cl-lib:fref work-%data% (1) ((1 *)) work-%offset%)
                (coerce iws 'f2cl-lib:complex16))
        (go end_label)
       end_label
        (return (values nil nil nil nil lda nil nil nil info))))))

(in-package #:cl-user)
#+#.(cl:if (cl:find-package '#:f2cl) '(and) '(or))
(eval-when (:load-toplevel :compile-toplevel :execute)
  (setf (gethash 'fortran-to-lisp::zungql
                 fortran-to-lisp::*f2cl-function-info*)
          (fortran-to-lisp::make-f2cl-finfo
           :arg-types '((fortran-to-lisp::integer4) (fortran-to-lisp::integer4)
                        (fortran-to-lisp::integer4)
                        (array fortran-to-lisp::complex16 (*))
                        (fortran-to-lisp::integer4)
                        (array fortran-to-lisp::complex16 (*))
                        (array fortran-to-lisp::complex16 (*))
                        (fortran-to-lisp::integer4)
                        (fortran-to-lisp::integer4))
           :return-values '(nil nil nil nil fortran-to-lisp::lda nil nil nil
                            fortran-to-lisp::info)
           :calls '(fortran-to-lisp::zlarfb fortran-to-lisp::zlarft
                    fortran-to-lisp::zung2l fortran-to-lisp::xerbla
                    fortran-to-lisp::ilaenv))))

