!(import! &self (library lib_import))
!(git-import! "https://github.com/patham9/petta_lib_snapshot.git")
!(import! &self (library lib_snapshot))

;Functions as usual:
(= (fib-tr $n $a $b)
   (if (== $n 0)
       $a
       (fib-tr (- $n 1) $b (+ $a $b))))

(= (fib $n)
   (fib-tr $n 0 1))

;Start computation:
!(CallWithSnapshotInterval (fib 1000000) 200000)
