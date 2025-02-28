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
  reviews: uint,
  total-rating: uint
})

;; Read-only: Get recipe details
(define-read-only (get-recipe (recipe-id uint))
  (map-get? recipes recipe-id))

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
      reviews: u0,
      total-rating: u0
    })
    (var-set recipe-counter (+ recipe-id u1))
    (contract-call? .profile add-recipe recipe-id)
    (ok recipe-id)))

;; Rate recipe
(define-public (rate-recipe (recipe-id uint) (rating uint))
  (let ((recipe (unwrap! (map-get? recipes recipe-id) (err u404))))
    (asserts! (and (>= rating u1) (<= rating u5)) (err u400))
    (let ((new-reviews (+ (get reviews recipe) u1))
          (new-total (+ (get total-rating recipe) rating))
          (new-rating (/ new-total new-reviews)))
      (ok (map-set recipes recipe-id 
        (merge recipe { 
          rating: new-rating,
          reviews: new-reviews,
          total-rating: new-total 
        }))))))
