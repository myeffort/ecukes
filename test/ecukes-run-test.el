(require 'ecukes-run)
(require 'ecukes-hooks)
(require 'ecukes-stats)

(ert-deftest run-features-should-run-setup-hooks ()
  "Should run setup hooks."
  (with-mock
   (stub ecukes-run-feature)
   (mock (setup-mock) :times 1)
   (with-hooks
    (Setup (setup-mock))
    (with-parse-feature
     "simple"
     (lambda (feature intro scenarios background steps)
       (ecukes-run-features (list feature)))))))

(ert-deftest run-features-should-run-teardown-hooks ()
  "Should run teardown hooks."
  (with-mock
   (stub ecukes-run-feature)
   (mock (teardown-mock) :times 1)
   (with-hooks
    (Teardown (teardown-mock))
    (with-parse-feature
     "simple"
     (lambda (feature intro scenarios background steps)
       (ecukes-run-features (list feature)))))))

(ert-deftest run-feature-no-background ()
  "Should run feature when no background."
  (with-message
   (lambda (messages)
     (with-parse-feature
      "simple"
      (lambda (feature intro scenarios background steps)
        (with-mock
         (stub ecukes-feature-background => nil)
         (stub ecukes-feature-scenarios => nil)
         (mock (ecukes-print-intro intro) :times 1)
         (not-called ecukes-run-background)
         (ecukes-run-feature feature)))))))

(ert-deftest run-feature ()
  "Should run feature."
  (with-message
   (lambda (messages)
     (with-parse-feature
      "simple"
      (lambda (feature intro scenarios background steps)
        (with-mock
         (mock (ecukes-print-intro intro) :times 1)
         (mock (ecukes-print-stats-summary) :times 1)
         (mock (ecukes-run-background) :times 1)
         (mock (ecukes-run-scenario) :times 1)
         (ecukes-run-feature feature)))))))

(ert-deftest run-background ()
  "Should run background."
  (with-mock
   (mock (ecukes-run-step) => t :times 2)
   (with-message
    (lambda (messages)
      (let ((success
             (ecukes-run-background
              (make-ecukes-background
               :steps
               (list
                (mock-step "Given a known state")
                (mock-step "Given an unknown state")))))
            (expected
             (list
              "  Background:"
              (s-concat "    " (ansi-green "Given a known state"))
              (s-concat "    " (ansi-green "Given an unknown state"))
              " ")))
        (should (equal success t))
        (should (equal expected messages)))))))

;; TODO: Should run background before...
(ert-deftest run-scenario ()
  "Should run scenario."
  (with-mock
   (mock (ecukes-run-step) => t :times 2)
   (with-message
    (lambda (messages)
      (ecukes-run-scenario
       (make-ecukes-scenario
        :name "Simple"
        :steps
        (list
         (mock-step "Given a known state")
         (mock-step "Given an unknown state")))
       t)
      (let ((expected
             (list
              "  Scenario: Simple"
              (s-concat "    " (ansi-green "Given a known state"))
              (s-concat "    " (ansi-green "Given an unknown state"))
              " ")))
        (should (equal expected messages)))))))

(ert-deftest run-scenario-before-hook ()
  "Should run before hooks."
  (with-stats
   (with-mock
    (stub ecukes-print-scenario-header)
    (stub ecukes-scenario-steps)
    (stub ecukes-run-steps)
    (stub ecukes-print-newline)
    (mock (before-mock) :times 1)
    (with-hooks
     (Before (before-mock))
     (ecukes-run-scenario nil nil)))))

(ert-deftest run-scenario-after-hook ()
  "Should run after hooks."
  (with-stats
   (with-mock
    (stub ecukes-print-scenario-header)
    (stub ecukes-scenario-steps)
    (stub ecukes-run-steps)
    (stub ecukes-print-newline)
    (mock (after-mock) :times 1)
    (with-hooks
     (After (after-mock))
     (ecukes-run-scenario nil nil)))))

(ert-deftest run-background-with-successful-steps-stats ()
  "Should update step stats count when successful steps."
  (with-message
   (lambda (messages)
     (with-steps
      (with-stats
       (Given "a known state" 'ignore)
       (Given "an unknown state" 'ignore)
       (ecukes-run-background
        (make-ecukes-background
         :steps
         (list
          (mock-step "Given a known state")
          (mock-step "Given an unknown state"))))
       (should (equal ecukes-stats-steps 2))
       (should (equal ecukes-stats-steps-passed 2))
       (should (equal ecukes-stats-steps-failed 0))
       (should (equal ecukes-stats-steps-skipped 0)))))))

(ert-deftest run-background-with-failing-step-stats ()
  "Should update step stats count when failing steps."
  (with-message
   (lambda (messages)
     (with-steps
      (with-stats
       (Given "a known state" (lambda () (error "ERROR")))
       (Given "an unknown state" 'ignore)
       (ecukes-run-background
        (make-ecukes-background
         :steps
         (list
          (mock-step "Given a known state")
          (mock-step "Given an unknown state"))))
       (should (equal ecukes-stats-steps 2))
       (should (equal ecukes-stats-steps-passed 0))
       (should (equal ecukes-stats-steps-failed 1))
       (should (equal ecukes-stats-steps-skipped 1)))))))

(ert-deftest run-scenario-stats ()
  "Should update scenario stats count."
  (with-message
   (lambda (messages)
     (with-stats
      (ecukes-run-scenario (make-ecukes-scenario) t)
      (should (equal ecukes-stats-scenarios 1))
      (should (equal ecukes-stats-scenarios-passed 1))
      (should (equal ecukes-stats-scenarios-failed 0))))))

(ert-deftest run-scenario-with-successful-steps-stats ()
  "Should update scenario and step stats count when successful steps."
  (with-message
   (lambda (messages)
     (with-steps
      (with-stats
       (Given "a known state" 'ignore)
       (Given "an unknown state" 'ignore)
       (ecukes-run-scenario
        (make-ecukes-scenario
         :steps
         (list
          (mock-step "Given a known state")
          (mock-step "Given an unknown state")))
        t)
       (should (equal ecukes-stats-scenarios 1))
       (should (equal ecukes-stats-scenarios-passed 1))
       (should (equal ecukes-stats-scenarios-failed 0))
       (should (equal ecukes-stats-steps 2))
       (should (equal ecukes-stats-steps-passed 2))
       (should (equal ecukes-stats-steps-failed 0))
       (should (equal ecukes-stats-steps-skipped 0)))))))

(ert-deftest run-scenario-with-failing-step-stats ()
  "Should update scenario and step stats count when failing steps."
  (with-message
   (lambda (messages)
     (with-steps
      (with-stats
       (Given "a known state" (lambda () (error "ERROR")))
       (Given "an unknown state" 'ignore)
       (ecukes-run-scenario
        (make-ecukes-scenario
         :steps
         (list
          (mock-step "Given a known state")
          (mock-step "Given an unknown state")))
        t)
       (should (equal ecukes-stats-scenarios 1))
       (should (equal ecukes-stats-scenarios-passed 0))
       (should (equal ecukes-stats-scenarios-failed 1))
       (should (equal ecukes-stats-steps 2))
       (should (equal ecukes-stats-steps-passed 0))
       (should (equal ecukes-stats-steps-failed 1))
       (should (equal ecukes-stats-steps-skipped 1)))))))

(ert-deftest run-feature-successful-steps-stats ()
  "Should update stats count when running feature all successful."
  (with-mock
   (stub ecukes-print-intro)
   (with-message
    (lambda (messages)
      (with-steps
       (with-stats
        (Given "a known state" 'ignore)
        (Given "an unknown state" 'ignore)
        (let* ((background
                (make-ecukes-background
                 :steps
                 (list
                  (mock-step "Given a known state"))))
               (scenarios
                (list
                 (make-ecukes-scenario
                  :steps
                  (list
                   (mock-step "Given an unknown state")))))
               (feature
                (make-ecukes-feature
                 :background background
                 :scenarios scenarios)))
          (ecukes-run-feature feature))
        (should (equal ecukes-stats-scenarios 1))
        (should (equal ecukes-stats-scenarios-passed 1))
        (should (equal ecukes-stats-scenarios-failed 0))
        (should (equal ecukes-stats-steps 2))
        (should (equal ecukes-stats-steps-passed 2))
        (should (equal ecukes-stats-steps-failed 0))
        (should (equal ecukes-stats-steps-skipped 0))))))))

(ert-deftest run-feature-with-failing-background-step-stats ()
  "Should update stats count when running feature failing in background."
  (with-mock
   (stub ecukes-print-intro)
   (with-message
    (lambda (messages)
      (with-steps
       (with-stats
        (Given "a known state" (lambda () (error "ERROR")))
        (Given "an unknown state" 'ignore)
        (let* ((background
                (make-ecukes-background
                 :steps
                 (list
                  (mock-step "Given a known state"))))
               (scenarios
                (list
                 (make-ecukes-scenario
                  :steps
                  (list
                   (mock-step "Given an unknown state")))))
               (feature
                (make-ecukes-feature
                 :background background
                 :scenarios scenarios)))
          (ecukes-run-feature feature))
        (should (equal ecukes-stats-scenarios 1))
        (should (equal ecukes-stats-scenarios-passed 0))
        (should (equal ecukes-stats-scenarios-failed 1))
        (should (equal ecukes-stats-steps 2))
        (should (equal ecukes-stats-steps-passed 0))
        (should (equal ecukes-stats-steps-failed 1))
        (should (equal ecukes-stats-steps-skipped 1))))))))

(ert-deftest run-steps-success ()
  "Should run steps and return t when all successful."
  (with-mock
   (mock (ecukes-print-step) :times 2)
   (with-stats
    (with-steps
     (Given "a known state" 'ignore)
     (Given "an unknown state" 'ignore)
     (let ((steps
            (list
             (mock-step "Given a known state")
             (mock-step "Given an unknown state"))))
       (should (equal (ecukes-run-steps steps t) t)))))))

(ert-deftest run-steps-failure ()
  "Should run steps and return nil when failure."
  (with-mock
   (mock (ecukes-print-step) :times 2)
   (with-stats
    (with-steps
     (Given "a known state" 'ignore)
     (Given "an unknown state" (lambda () (error "ERROR")))
     (let ((steps
            (list
             (mock-step "Given a known state")
             (mock-step "Given an unknown state"))))
       (should (equal (ecukes-run-steps steps t) nil)))))))

(ert-deftest run-step-no-args ()
  "Should run step when no args."
  (with-steps
   (with-mock
    (mock (run-mock) :times 1)
    (Given "a known state" 'run-mock)
    (should
     (ecukes-run-step
      (mock-step "Given a known state"))))))

(ert-deftest run-step-when-args ()
  "Should run step when args."
  (with-steps
   (with-mock
    (mock (run-mock "known" "unknown") :times 1)
    (Given "state \"\\(.+\\)\" and \"\\(.+\\)\"" 'run-mock)
    (should
     (ecukes-run-step
      (mock-step "Given state \"known\" and \"unknown\""))))))

(ert-deftest run-step-error ()
  "Should run failing step and set error."
  (with-steps
   (Given "a known state" (lambda () (error "ERROR")))
   (let ((step (mock-step "Given a known state")))
     (should-not
      (ecukes-run-step step))
     (should
      (equal (ecukes-step-err step) "ERROR")))))

(ert-deftest run-step-when-arg ()
  "Should run step when arg."
  (with-steps
   (with-mock
    (mock (run-mock "py-string") :times 1)
    (Given "this:" 'run-mock)
    (should
     (ecukes-run-step
      (mock-step "Given this:" :type 'table :arg "py-string"))))))
