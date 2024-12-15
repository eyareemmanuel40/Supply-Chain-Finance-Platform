;; Banking Integration Contract

(define-map bank-accounts
  { user: principal }
  { bank-account-id: (string-ascii 50) }
)

(define-constant err-unauthorized (err u403))

(define-public (link-bank-account (bank-account-id (string-ascii 50)))
  (begin
    (ok (map-set bank-accounts
      { user: tx-sender }
      { bank-account-id: bank-account-id }
    ))
  )
)

(define-public (deposit-fiat (amount uint))
  (let
    (
      (account (unwrap! (map-get? bank-accounts { user: tx-sender }) err-unauthorized))
    )
    ;; In a real implementation, this would interact with a fiat payment gateway
    ;; For demonstration purposes, we'll just mint the equivalent amount of STX
    (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
    (ok true)
  )
)

(define-public (withdraw-fiat (amount uint))
  (let
    (
      (account (unwrap! (map-get? bank-accounts { user: tx-sender }) err-unauthorized))
    )
    ;; In a real implementation, this would interact with a fiat payment gateway
    ;; For demonstration purposes, we'll just burn the equivalent amount of STX
    (try! (stx-burn? amount tx-sender))
    (ok true)
  )
)

(define-read-only (get-linked-account (user principal))
  (ok (map-get? bank-accounts { user: user }))
)

