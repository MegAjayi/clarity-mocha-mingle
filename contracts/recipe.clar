;; Recipe NFT contract
(define-non-fungible-token recipe uint)

;; Data vars
(define-data-var recipe-counter uint u0)

;; Recipe data map
(define-map recipes uint {
  creator: principal,
  title: (string-utf8 100),
  ingredients: (string-utf8 500),
  instructions: (string-utf8 1000),
  rating: uint,
  reviews: uint
})

;; Create new recipe
(define-public (create-recipe (title (string-utf8 100)) 
                            (ingredients (string-utf8 500))
                            (instructions (string-utf8 1000)))
  (let ((recipe-id (var-get recipe-counter)))
    (try! (nft-mint? recipe recipe-id tx-sender))
    (map-set recipes recipe-id {
      creator: tx-sender,
      title: title,
      ingredients: ingredients,
      instructions: instructions,
      rating: u0,
      reviews: u0
    })
    (var-set recipe-counter (+ recipe-id u1))
    (ok recipe-id)))

;; Rate recipe
(define-public (rate-recipe (recipe-id uint) (rating uint))
  (let ((recipe (unwrap! (map-get? recipes recipe-id) (err u404))))
    (asserts! (<= rating u5) (err u400))
    (ok (map-set recipes recipe-id 
      (merge recipe { rating: rating })))))
