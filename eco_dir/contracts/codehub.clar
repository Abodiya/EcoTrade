;; Title: Carbon Credit Trading Platform
;; Version: 1.0
;; Description: A non-custodial carbon credit trading smart contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u200))
(define-constant err-not-credit-owner (err u201))
(define-constant err-insufficient-balance (err u202))
(define-constant err-invalid-credit (err u203))
(define-constant err-invalid-amount (err u204))
(define-constant err-invalid-price (err u205))
(define-constant err-order-not-found (err u206))
(define-constant err-insufficient-liquidity (err u207))
(define-constant err-not-authorized (err u208))
(define-constant err-paused (err u209))
(define-constant err-invalid-string (err u210))
(define-constant err-invalid-recipient (err u211))

(define-map credits 
  { credit-id: uint }
  { name: (string-ascii 32), region: (string-ascii 10), total-supply: uint, owner: principal }
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

(define-private (validate-credit-id (credit-id uint))
  (is-some (map-get? credits { credit-id: credit-id }))
)

(define-private (validate-recipient (recipient principal))
  (and 
    (not (is-eq recipient tx-sender))
    (not (is-eq recipient contract-owner))
  )
)

(define-private (validate-order-id (order-id uint))
  (is-some (map-get? orders { order-id: order-id }))
)

(define-read-only (get-credit-details (credit-id uint))
  (match (map-get? credits { credit-id: credit-id })
    entry (ok entry)
    (err err-invalid-credit)
  )
)

(define-read-only (get-balance (credit-id uint) (owner principal))
  (default-to 
    { balance: u0 }
    (map-get? balances { credit-id: credit-id, owner: owner })
  )
)

(define-read-only (get-order (order-id uint))
  (match (map-get? orders { order-id: order-id })
    entry (ok entry)
    (err err-order-not-found)
  )
)

(define-read-only (get-credit-pool (credit-id uint))
  (default-to
    { total-liquidity: u0, price: u0 }
    (map-get? credit-pools { credit-id: credit-id })
  )
)

(define-public (create-credit (name (string-ascii 32)) (region (string-ascii 10)) (initial-supply uint))
  (let
    (
      (new-credit-id (+ (var-get last-credit-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (validate-string name) err-invalid-string)
    (asserts! (validate-region region) err-invalid-string)
    (asserts! (> initial-supply u0) err-invalid-amount)
    (map-set credits
      { credit-id: new-credit-id }
      { name: name, region: region, total-supply: initial-supply, owner: tx-sender }
    )
    (map-set balances
      { credit-id: new-credit-id, owner: tx-sender }
      { balance: initial-supply }
    )
    (var-set last-credit-id new-credit-id)
    (print { type: "credit-created", credit-id: new-credit-id, name: name, region: region, supply: initial-supply })
    (ok new-credit-id)
  )
)

(define-public (mint-credits (credit-id uint) (amount uint))
  (let
    (
      (credit (unwrap! (map-get? credits { credit-id: credit-id }) err-invalid-credit))
      (current-supply (get total-supply credit))
      (credit-owner (get owner credit))
    )
    (asserts! (validate-credit-id credit-id) err-invalid-credit)
    (asserts! (is-eq tx-sender credit-owner) err-not-credit-owner)
    (asserts! (> amount u0) err-invalid-amount)
    (map-set credits
      { credit-id: credit-id }
      (merge credit { total-supply: (+ current-supply amount) })
    )
    (map-set balances
      { credit-id: credit-id, owner: tx-sender }
      { balance: (+ (get balance (get-balance credit-id tx-sender)) amount) }
    )
    (print { type: "credits-minted", credit-id: credit-id, amount: amount, recipient: tx-sender })
    (ok true)
  )
)

(define-public (transfer (credit-id uint) (amount uint) (sender principal) (recipient principal))
  (let
    (
      (sender-balance (get balance (get-balance credit-id sender)))
    )
    (asserts! (validate-credit-id credit-id) err-invalid-credit)
    (asserts! (validate-recipient recipient) err-invalid-recipient)
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (asserts! (>= sender-balance amount) err-insufficient-balance)
    (asserts! (> amount u0) err-invalid-amount)
    (map-set balances
      { credit-id: credit-id, owner: sender }
      { balance: (- sender-balance amount) }
    )
    (map-set balances
      { credit-id: credit-id, owner: recipient }
      { balance: (+ (get balance (get-balance credit-id recipient)) amount) }
    )
    (print { type: "transfer", credit-id: credit-id, amount: amount, sender: sender, recipient: recipient })
    (ok true)
  )
)

(define-public (create-sell-order (credit-id uint) (amount uint) (price uint))
  (let
    (
      (seller-balance (get balance (get-balance credit-id tx-sender)))
      (new-order-id (+ (var-get last-order-id) u1))
    )
    (asserts! (validate-credit-id credit-id) err-invalid-credit)
    (asserts! (>= seller-balance amount) err-insufficient-balance)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (> price u0) err-invalid-price)
    (map-set orders
      { order-id: new-order-id }
      { credit-id: credit-id, amount: amount, price: price, seller: tx-sender, order-type: "sell" }
    )
    (var-set last-order-id new-order-id)
    (print { type: "sell-order-created", order-id: new-order-id, credit-id: credit-id, amount: amount, price: price, seller: tx-sender })
    (ok new-order-id)
  )
)

(define-public (create-buy-order (credit-id uint) (amount uint) (price uint))
  (let
    (
      (new-order-id (+ (var-get last-order-id) u1))
      (total-cost (* amount price))
    )
    (asserts! (validate-credit-id credit-id) err-invalid-credit)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (> price u0) err-invalid-price)
    (asserts! (>= (stx-get-balance tx-sender) total-cost) err-insufficient-balance)
    (map-set orders
      { order-id: new-order-id }
      { credit-id: credit-id, amount: amount, price: price, seller: tx-sender, order-type: "buy" }
    )
    (var-set last-order-id new-order-id)
    (print { type: "buy-order-created", order-id: new-order-id, credit-id: credit-id, amount: amount, price: price, buyer: tx-sender })
    (ok new-order-id)
  )
)

(define-public (execute-order (order-id uint))
  (let
    (
      (order (unwrap! (map-get? orders { order-id: order-id }) err-order-not-found))
      (credit-id (get credit-id order))
      (amount (get amount order))
      (price (get price order))
      (seller (get seller order))
      (order-type (get order-type order))
    )
    (asserts! (not (var-get contract-paused)) err-paused)
    (asserts! (validate-order-id order-id) err-order-not-found)
    (if (is-eq order-type "sell")
      (execute-sell-order order-id credit-id amount price seller tx-sender)
      (execute-buy-order order-id credit-id amount price seller tx-sender)
    )
  )
)

(define-public (add-liquidity (credit-id uint) (amount uint))
  (let
    (
      (credit (unwrap! (map-get? credits { credit-id: credit-id }) err-invalid-credit))
      (current-pool (get-credit-pool credit-id))
      (current-liquidity (get total-liquidity current-pool))
      (current-price (get price current-pool))
    )
    (asserts! (validate-credit-id credit-id) err-invalid-credit)
    (asserts! (not (var-get contract-paused)) err-paused)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= (get balance (get-balance credit-id tx-sender)) amount) err-insufficient-balance)
    (map-set credit-pools
      { credit-id: credit-id }
      { total-liquidity: (+ current-liquidity amount), price: (calculate-new-price current-price current-liquidity amount true) }
    )
    (map-set balances
      { credit-id: credit-id, owner: tx-sender }
      { balance: (- (get balance (get-balance credit-id tx-sender)) amount) }
    )
    (print { type: "liquidity-added", credit-id: credit-id, amount: amount, provider: tx-sender })
    (ok true)
  )
)

(define-public (remove-liquidity (credit-id uint) (amount uint))
  (let
    (
      (current-pool (get-credit-pool credit-id))
      (current-liquidity (get total-liquidity current-pool))
      (current-price (get price current-pool))
    )
    (asserts! (validate-credit-id credit-id) err-invalid-credit)
    (asserts! (not (var-get contract-paused)) err-paused)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= current-liquidity amount) err-insufficient-liquidity)
    (map-set credit-pools
      { credit-id: credit-id }
      { total-liquidity: (- current-liquidity amount), price: (calculate-new-price current-price current-liquidity amount false) }
    )
    (map-set balances
      { credit-id: credit-id, owner: tx-sender }
      { balance: (+ (get balance (get-balance credit-id tx-sender)) amount) }
    )
    (print { type: "liquidity-removed", credit-id: credit-id, amount: amount, provider: tx-sender })
    (ok true)
  )
)

(define-private (execute-sell-order (order-id uint) (credit-id uint) (amount uint) (price uint) (seller principal) (buyer principal))
  (let
    (
      (total-cost (* amount price))
    )
    (asserts! (validate-credit-id credit-id) err-invalid-credit)
    (asserts! (validate-order-id order-id) err-order-not-found)
    (asserts! (>= (stx-get-balance buyer) total-cost) err-insufficient-balance)
    (try! (stx-transfer? total-cost buyer seller))
    (try! (transfer credit-id amount seller buyer))
    (map-delete orders { order-id: order-id })
    (print { type: "order-executed", order-id: order-id, credit-id: credit-id, amount: amount, price: price, seller: seller, buyer: buyer })
    (ok true)
  )
)

(define-private (execute-buy-order (order-id uint) (credit-id uint) (amount uint) (price uint) (buyer principal) (seller principal))
  (let
    (
      (total-cost (* amount price))
    )
    (asserts! (validate-credit-id credit-id) err-invalid-credit)
    (asserts! (validate-order-id order-id) err-order-not-found)
    (asserts! (>= (get balance (get-balance credit-id seller)) amount) err-insufficient-balance)
    (try! (stx-transfer? total-cost buyer seller))
    (try! (transfer credit-id amount seller buyer))
    (map-delete orders { order-id: order-id })
    (print { type: "order-executed", order-id: order-id, credit-id: credit-id, amount: amount, price: price, seller: seller, buyer: buyer })
    (ok true)
  )
)

(define-private (calculate-new-price (current-price uint) (current-liquidity uint) (liquidity-change uint) (is-adding bool))
  (let
    (
      (new-liquidity (if is-adding
                        (+ current-liquidity liquidity-change)
                        (if (> current-liquidity liquidity-change)
                            (- current-liquidity liquidity-change)
                            u0)))
    )
    (if (> new-liquidity u0)
      (/ (* current-price current-liquidity) new-liquidity)
      u0
    )
  )
)
