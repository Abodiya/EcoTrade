;; Enhanced Carbon Credit Trading Platform

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u200))
(define-constant err-not-credit-owner (err u201))
(define-constant err-insufficient-balance (err u202))
(define-constant err-invalid-credit (err u203))
(define-constant err-invalid-amount (err u204))
(define-constant err-insufficient-liquidity (err u207))

(define-map credits 
  { credit-id: uint }
  { name: (string-ascii 32), total-supply: uint, owner: principal }
)

(define-map balances 
  { credit-id: uint, owner: principal } 
  { balance: uint }
)

(define-map orders
  { order-id: uint }
  { credit-id: uint, amount: uint, price: uint, seller: principal, order-type: (string-ascii 4) }
)

(define-map credit-pools
  { credit-id: uint }
  { total-liquidity: uint, price: uint }
)

(define-data-var last-credit-id uint u0)
(define-data-var last-order-id uint u0)

(define-public (create-credit (name (string-ascii 32)) (initial-supply uint))
  (let
    ((new-credit-id (+ (var-get last-credit-id) u1)))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> initial-supply u0) err-invalid-amount)
    (map-set credits
      { credit-id: new-credit-id }
      { name: name, total-supply: initial-supply, owner: tx-sender }
    )
    (map-set balances
      { credit-id: new-credit-id, owner: tx-sender }
      { balance: initial-supply }
    )
    (var-set last-credit-id new-credit-id)
    (ok new-credit-id)
  )
)

(define-public (add-liquidity (credit-id uint) (amount uint))
  (let
    ((current-pool (get-credit-pool credit-id))
     (current-liquidity (get total-liquidity current-pool)))
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= (get balance (get-balance credit-id tx-sender)) amount) err-insufficient-balance)
    (map-set credit-pools
      { credit-id: credit-id }
      { total-liquidity: (+ current-liquidity amount), 
        price: (calculate-new-price current-pool amount true) }
    )
    (map-set balances
      { credit-id: credit-id, owner: tx-sender }
      { balance: (- (get balance (get-balance credit-id tx-sender)) amount) }
    )
    (ok true)
  )
)

(define-private (calculate-new-price (pool { total-liquidity: uint, price: uint }) (change uint) (is-adding bool))
  (let
    ((current-liquidity (get total-liquidity pool))
     (current-price (get price pool)))
    (if (> current-liquidity u0)
      (/ (* current-price current-liquidity) 
         (if is-adding (+ current-liquidity change) (- current-liquidity change)))
      u100000000) ;; Initial price if pool is empty
  )
)