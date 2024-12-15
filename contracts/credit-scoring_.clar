;; Credit Scoring Contract

(define-map credit-scores
  { participant: principal }
  { score: uint }
)

(define-constant min-score u0)
(define-constant max-score u1000)
(define-constant default-score u500)

(define-constant err-unauthorized (err u403))
(define-constant err-invalid-score (err u404))

(define-public (initialize-score (participant principal))
  (begin
    (asserts! (is-eq tx-sender contract-caller) err-unauthorized)
    (ok (map-set credit-scores
      { participant: participant }
      { score: default-score }
    ))
  )
)

(define-public (update-score (participant principal) (score-change uint))
  (let
    (
      (current-score (default-to default-score (get score (map-get? credit-scores { participant: participant }))))
      (new-score (if (> score-change current-score)
                     (- max-score current-score)
                     (- current-score score-change)))
    )
    (asserts! (is-eq tx-sender contract-caller) err-unauthorized)
    (ok (map-set credit-scores
      { participant: participant }
      { score: new-score }
    ))
  )
)

(define-read-only (get-credit-score (participant principal))
  (ok (default-to default-score (get score (map-get? credit-scores { participant: participant }))))
)

