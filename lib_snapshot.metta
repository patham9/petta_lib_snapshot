!(import! &self (library lib_import))
!(import_prolog_functions_from_file (library lib_snapshot.pl) (qsave_program_continuation))
!(import! &self (library lib_spaces))
!(import_prolog_function statistics)
!(import_prolog_function reset)

(= (SnapshotInterval) (empty))

(= (NoSnapshotFor) (empty))

(= (Snapshot)
   (if (> (- (statistics inferences) (get-state &initinferences)) (SnapshotInterval))
       (catch (translatePredicate (shift (pay-for-inferences))))
       True))

(= (ResetSnapshotInterval)
   (change-state! &initinferences (statistics inferences)))

(= (InjectSnapshots)
   (collapse (match &self $func (let (cons = ($head $body)) $func
                                     (if (not (is-member (car-atom $head)
                                                         (append (collapse (NoSnapshotFor))
                                                                 (quote (NoSnapshotFor SnapshotInterval Snapshot ResetSnapshotInterval InjectSnapshots
                                                                         CallWithSnapshotsInternal CallWithSnapshotInterval ResumeComputation)))))
                                         (progn (remove-atom &self $func)
                                                (add-atom &self (= $head (progn (Snapshot) $body)))))))))

(= (CallWithSnapshotsInternal $predicate $var)
   (let $cont (reset $predicate $signal)
        (if (is-var $signal)
            $var
            (progn ;metadata with clause refs needs to be dropped:
                   (translatePredicate (retractall (Predicate (translated_from $1 $2))))
                   ;save current atom space with computation continuation entry point ResumeComputation:
                   (qsave_program_continuation "continue.p" $cont $var ResumeComputation)
                   (progn (ResetSnapshotInterval)
                          ;continue computation:
                          (CallWithSnapshotsInternal $cont $var))))))

(: CallWithSnapshotInterval (-> Expression Atom Atom))
(= (CallWithSnapshotInterval $G $Inferences)
   (progn (add-atom &self (= (SnapshotInterval) $Inferences))
          (ResetSnapshotInterval)
          (let $ext (Predicate (union-atom $G ($X)))
               (CallWithSnapshotsInternal $ext $X))))

;Function to resume computation with "swipl -x continue.p":
(= (ResumeComputation $cont $var)
   (progn (ResetSnapshotInterval)
          ;Continue computation:
          (let $result (CallWithSnapshotsInternal $cont $var)
               (println! $result))
          (translatePredicate (halt))))
