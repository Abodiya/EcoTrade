;; Production-Ready Carbon Credit Trading Platform

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u200))
(define-constant err-not-credit-owner (err u201))
(define-constant err-insufficient-balance (err u202))
(define-constant err-invalid-credit (err u203))
(define-constant err-invalid-amount (err u204))
(define-constant err-invalid-price (err u205))
(define-constant err-paused (err u209))
(define-constant err-invalid-string (err u210))

(define-map credits 
  { credit-id: uint }
  { name: (string-ascii 32), 
    region: (string-ascii 10), 
    total-supply: uint, 
    owner: principal }
)

(define-map balances 
  { credit-id: uint, owner: principal } 
  { balance: uint }
)

(define-map orders
  { order-id: uint }
  { credit-id: uint, 
    amount: uint, 
    price: uint, 
    seller: principal, 
    order-type: (string-ascii 4) }
)

(define-map credit-pools
  { credit-id: uint }
  { total-liquidity: uint, price: uint }
)

(define-map governance-settings
  { setting-id: (string-ascii 32) }
  { value: (string-utf8 256) }
)

(define-data-var last-credit-id uint u0)
(define-data-var last-order-id uint u0)
(define-data-var contract-paused bool false)

(define-private (validate-string (str (string-ascii 32)))
  (and (> (len str) u0) (<= (len str) u32))
)

(define-private (validate-region (region (string-ascii 10)))
  (and (> (len region) u0) (<= (len region) u10))
)

(define-public (create-credit (name (string-ascii 32)) (region (string-ascii 10)) (initial-supply uint))
  (let
    ((new-credit-id (+ (var-get last-credit-id) u1)))
    (asserts! (not (var-get contract-paused)) err-paused)
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (validate-string name) err-invalid-string)
    (asserts! (validate-region region) err-invalid-string)
    (asserts! (> initial-supply u0) err-invalid-amount)
    (map-set credits
      { credit-id: new-credit-id }
      { name: name, 
        region: region, 
        total-supply: initial-supply, 
        owner: tx-sender }
    )
    (map-set balances
      { credit-id: new-credit-id, owner: tx-sender }
      { balance: initial-supply }
    )
    (var-set last-credit-id new-credit-id)
    (print { type: "credit-created", 
             credit-id: new-credit-id, 
             name: name, 
             region: region, 
             supply: initial-supply })
    (ok new-credit-id)
  )
)