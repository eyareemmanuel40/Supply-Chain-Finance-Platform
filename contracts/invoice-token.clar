;; Invoice Token Contract

(define-fungible-token invoice-token)

(define-data-var token-uri (string-utf8 256) u"https://example.com/invoice-token-metadata")

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

(define-map invoices
  { invoice-id: uint }
  {
    issuer: principal,
    debtor: principal,
    amount: uint,
    due-date: uint,
    status: (string-ascii 20)
  }
)

(define-data-var last-invoice-id uint u0)

(define-public (create-invoice (debtor principal) (amount uint) (due-date uint))
  (let
    (
      (invoice-id (+ (var-get last-invoice-id) u1))
      (token-amount (* amount u100)) ;; Multiply by 100 to allow for 2 decimal places
    )
    (try! (ft-mint? invoice-token token-amount tx-sender))
    (map-set invoices
      { invoice-id: invoice-id }
      {
        issuer: tx-sender,
        debtor: debtor,
        amount: amount,
        due-date: due-date,
        status: "active"
      }
    )
    (var-set last-invoice-id invoice-id)
    (ok invoice-id)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (try! (ft-transfer? invoice-token amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance invoice-token account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply invoice-token))
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)

(define-read-only (get-invoice (invoice-id uint))
  (ok (map-get? invoices { invoice-id: invoice-id }))
)

(define-public (set-token-uri (new-uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set token-uri new-uri))
  )
)

