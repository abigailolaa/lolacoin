;; title: lolacoin
;; version: 0.1.0
;; summary: A simple fungible token called lolacoin
;; description: 
;;   lolacoin is a basic fungible token implemented in Clarity. It supports
;;   initialization, minting by an owner, transfers between principals, and
;;   read-only queries for balances and total supply.

;; --------------------------------------------
;; constants
;; --------------------------------------------

(define-constant ERR-NOT-OWNER u100)
(define-constant ERR-INSUFFICIENT-BALANCE u101)
(define-constant ERR-ALREADY-INITIALIZED u102)
(define-constant ERR-ZERO-AMOUNT u103)

(define-constant TOKEN-NAME "lolacoin")        ;; up to 32 chars
(define-constant TOKEN-SYMBOL "LOLA")          ;; up to 8 chars
(define-constant TOKEN-DECIMALS u6)              ;; example: 6 decimal places

;; --------------------------------------------
;; data vars
;; --------------------------------------------

;; Total number of tokens that have been minted.
(define-data-var total-supply uint u0)

;; Optional contract owner. Set once via (initialize ...) and used for minting.
(define-data-var owner (optional principal) none)

;; --------------------------------------------
;; data maps
;; --------------------------------------------

;; Track balances of each principal.
(define-map balances
  { account: principal }
  { balance: uint })

;; --------------------------------------------
;; read-only functions
;; --------------------------------------------

(define-read-only (get-name)
  (ok TOKEN-NAME))

(define-read-only (get-symbol)
  (ok TOKEN-SYMBOL))

(define-read-only (get-decimals)
  (ok TOKEN-DECIMALS))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-balance (account principal))
  (ok (get-balance-internal account)))

;; --------------------------------------------
;; public functions
;; --------------------------------------------

;; One-time initialization function.
;; - Sets the contract owner to tx-sender
;; - Mints `amount` tokens to `recipient`
(define-public (initialize (recipient principal) (amount uint))
  (begin
    (if (is-eq amount u0)
        (err ERR-ZERO-AMOUNT)
        (match (var-get owner)
          existing-owner
            (err ERR-ALREADY-INITIALIZED)
          (begin
            (var-set owner (some tx-sender))
            (mint-internal recipient amount)
            (ok true))))))

;; Transfer tokens from tx-sender to `recipient`.
(define-public (transfer (amount uint) (recipient principal))
  (let (
        (sender tx-sender)
        (sender-balance (get-balance-internal tx-sender))
       )
    (if (is-eq amount u0)
        (err ERR-ZERO-AMOUNT)
        (if (< sender-balance amount)
            (err ERR-INSUFFICIENT-BALANCE)
            (begin
              (update-balance sender (- sender-balance amount))
              (let ((recipient-balance (get-balance-internal recipient)))
                (update-balance recipient (+ recipient-balance amount)))
              (ok true))))))

;; Mint new tokens to `recipient`. Only the owner may call this.
(define-public (mint (recipient principal) (amount uint))
  (begin
    (if (is-eq amount u0)
        (err ERR-ZERO-AMOUNT)
        (if (not (is-owner tx-sender))
            (err ERR-NOT-OWNER)
            (begin
              (mint-internal recipient amount)
              (ok true))))))

;; --------------------------------------------
;; private helpers
;; --------------------------------------------

(define-private (get-balance-internal (account principal))
  (get balance (default-to { balance: u0 }
                           (map-get? balances { account: account }))))

(define-private (update-balance (account principal) (new-balance uint))
  (map-set balances { account: account } { balance: new-balance }))

(define-private (is-owner (sender principal))
  (match (var-get owner)
    owner-principal (is-eq sender owner-principal)
    false))

(define-private (mint-internal (recipient principal) (amount uint))
  (let ((current-balance (get-balance-internal recipient))
        (current-supply (var-get total-supply)))
    (begin
      (update-balance recipient (+ current-balance amount))
      (var-set total-supply (+ current-supply amount)))))
