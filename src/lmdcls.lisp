;;; -*-  Mode: Lisp; Package: Maxima; Syntax: Common-Lisp; Base: 8 -*- ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     The data in this file contains enhancements.                   ;;;;;
;;;                                                                    ;;;;;
;;;  Copyright (c) 1984,1987 by William Schelter,University of Texas   ;;;;;
;;;     All rights reserved                                            ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package :maxima)

(defvar *macro-file* nil)

#+gcl
(progn 
  (system::clines "object MAKE_UNSPECIAL(object x) {if (type_of(x)==t_symbol) x->s.s_stype=0;return Cnil;}")
  (system::defentry make-unspecial (system::object) (system::object "MAKE_UNSPECIAL")))

#+(or scl cmu)
(defun make-unspecial (symbol)
  (ext:clear-info variable c::kind symbol)
  symbol)


(defmacro declare-top (&rest decl-specs)
  `(eval-when
    ,(cond (*macro-file*  #+gcl '(compile eval load)
			  #-gcl '(:compile-toplevel :load-toplevel :execute) )
	   (t #+gcl '(eval compile) #-gcl '(:compile-toplevel :execute)))
    ,@(loop for v in decl-specs
	     unless (member (car v) '(special unspecial)) nconc nil
	     else
	     when (eql (car v) 'unspecial)
	     collect `(progn
		       ,@(loop for w in (cdr v)
				collect #-(or gcl scl cmu ecl)
                                       `(remprop ',w
						 #-excl 'special
						 #+excl 'excl::.globally-special.)
				#+(or gcl scl cmu ecl)
			        `(make-unspecial ',w)))
	     else collect `(proclaim ',v))))

;;; This list should contain all specials required by runtime or more than one maxima file,
;;; except for some specials declared in the macro files, eg displm

(declaim (special
	  $absboxchar $algexact
	  $askexp $berlefact
	  $beta_args_sum_to_integer $bftrunc $boxchar
	  $compgrind
	  $current_let_rule_package $debugmode
	  $default_let_rule_package
	  $display_format_internal $domxexpt
	  $domxnctimes $domxplus $domxtimes
	  $doscmxplus $dot0nscsimp $dot0simp $dot1simp
	  $dotconstrules $dotident
	  $erfflag $errexp $error_size $error_syms
	  $exptdispflag $exptisolate
	  $file_search
	  $fortfloat $fortindent
	  $fortspaces $fpprec $fpprintprec $gammalim
	  $homog_hack
	  $isolate_wrt_times $leftjust $letrat $letvarsimp
	  $linsolvewarn
	  $lmxchar $logconcoeffp $lognegint
	  $macroexpansion $maperror $mapprint
	  $matrix_element_transpose
	  $maxapplydepth $maxapplyheight
	  $maxtayorder $mode_checkp $mode_check_errorp $mode_check_warnp
	  $mx0simp $nalgfac
	  $negsumdispflag $noundisp
	  $optimprefix $optionset
	  $parsewindow $pointbound
	  $poislim
	  $ratdenomdivide
          $ratmx $ratvarswitch
	  $realonly $refcheck $rmxchar
	  $setval $signbfloat
	  $solvedecomposes $solveexplicit $solvenullwarn
	  $solvetrigwarn
	  $stardisp $sublis_apply_lambda
	  $taylor_logexpand
	  $taylor_truncate_polynomials $timer $timer_devalue
	  $trace $trace_break_arg $trace_max_indent
	  $trace_safety $transrun
	  $tr_array_as_ref $tr_bound_function_applyp
	  $tr_file_tty_messagesp $tr_float_can_branch_complex
	  $tr_function_call_default $tr_numer
	  $tr_optimize_max_loop
	  $tr_state_vars
	  $tr_true_name_of_file_being_translated $tr_warn_bad_function_calls
	  $tr_warn_fexpr $tr_warn_meval $tr_warn_mode $tr_warn_undeclared
	  $tr_warn_undefined_variable $ttyoff
	  $vect_cross
	  %pi-val *$any-modes*
	  *alpha *const* *gcdl* *in *in-compile*
	  *inv* *irreds *min* *mx*
	  *n *opers-list *out *tr-warn-break* *transl-backtrace*
	  *transl-debug* *warned-fexprs*
	  *warned-mode-vars* *warned-un-declared-vars* |-1//2|
	  |1//2| aexprp algnotexact
	  alpha *alphabet* assigns
	  defined_variables defintdebug derivlist
	  derivsimp displayp dn* dsksetp
	  expandflag expandp
	  exptrlsw
	  fr-factor gauss
	  generate-atan2
	  implicit-real inratsimp inside-mprog
	  limit-answers
	  local maplp mdop
	  meta-prop-l meta-prop-p mfexprp minpoly* mm* modulus
	  mplc* mprogp mproplist mspeclist
	  need-prog? negprods negsums nn*
	  *nounsflag* opers opers-list outargs1 outargs2
	  preserve-direction prods radcanp
	  realonlyratnum return-mode returns rulefcnl
	  rulesw sign-imag-errp simplimplus-problems
	  *small-primes*
	  sums timesinp tr-abort tr-progret tr-unique
	  transl-file translate-time-evalables
	  tstack
	  *trunclist
	  $maxtaydiff $verbose $psexpand ps-bmt-disrep
	  $define_variable
	  $factor_max_degree_print_warning))

(declaim (declaration unspecial))
