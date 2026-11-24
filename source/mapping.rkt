;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname mapping) (read-case-sensitive #t) (teachpacks ((lib "sludges.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "sludges.rkt" "teachpack" "htdp")) #f)))
; Filename: mapping.rkt
; Date: 10 Nov
; Author: Leonida Ilioska, Edoardo Fiorini, Lorenzo Felix
; Purpose: implements the logic to load tiles from OSM
;          (OpenStreetMap) for a certain coordinate and render
;          a map in 9 tile-sized blocks format with the aircraft marker
;          displayed at the center.
; TODO: (maybe) create a custom struct for tile columns
;               break functions into smaller ones (eg the
;               x-y ones can be broken into x+y+total)

(require 2htdp/image)
(require math/base)
(require "model.rkt")
(require "main.rkt")

; CONSTANTS
; Display-settings constants
(define zoom-level Number)
; specifies the zoom level for the map, which
; ranges from 0 (the whole world) to 19 (building-level
; zooming)

; Display constants
(define empty-tile (rectangle 100 50 "outline" "black"))

; OSM constants
(define OSM_base_url "https://tile.openstreetmap.org")
(define image_extension ".png")

(: distance->degree-coord (Position DegreeCoordinate -> DegreeCoordinate))
; computes the new degree coordinates (longitude and latitude) using the
; local flat-earth approximation (most suited for short distances).
; x: positive east, negative west
; y: positive north, negative south

(define (distance->degree-coord posn initial-degree-posn)
  (make-degree-coordinate
   (+ (degree-coordinate-x initial-degree-posn)
                          (/ (position-x posn) 111320))
   (+ (degree-coordinate-y initial-degree-posn)
                          (/ (position-y posn) 111320))
                          ))


(: coordinates->tile-columns (DegreeCoordinate Number -> Posn))
; converts degree coordinates (longitude and latitude)
; into tile columns x and y (using Web Mercator tile conversion)
; formulas:
; n = 2^z
; x = floor(n * (lon+180)/360)
; y = floor(n * (1 - (ln(tan(latr) + sec(latr))/pi) * 1/2)
; (latr = latitude degrees converted into radians)

(define (coordinates->tile-columns coordinates zoom)
  (local [(define n (expt 2 zoom))
          (define x (degree-coordinate-x coordinates))
          (define y (degrees->radians (degree-coordinate-y coordinates)))]
    (make-posn
     (exact-floor (* n (/ (+ x 180) 360)))
     (exact-floor (* 0.5 n (- 1 (/ (log (+ (tan y) (/ 1 (cos y)))) pi))))
     )
    )
  )

(: get-url (Posn Number -> String))
; interpretation: constructs the URL address of 
; a tile in the OSM website from coordinates and zoom level

(define (get-url coordinates zoom-level)
  (string-append OSM_base_url "/" (number->string zoom-level) "/"
                 (number->string (posn-x coordinates)) "/"
                 (number->string (posn-y coordinates)) image_extension))

(: load-tile-from-url (String -> Image))
; returns the tile for a specific OSM's URL 

(define (load-tile-from-url url)
  (bitmap/url url))


(: deg_coordinates->tile (Position DegreeCoordinate Number -> Image))

(define (deg_coordinates->tile distance coordinates zoom)
  (load-tile-from-url (get-url (coordinates->tile-columns (distance->degree-coord distance coordinates) zoom) zoom))
  )

; tests

(define TESTP (make-degree-coordinate 11.3465 44.4942)) ; test position
(define DISTP (make-position 0 0 0)) ; test distance

; first test:
(define ZOOM 10)
(define DEGREE_COORDINATES_1 (distance->degree-coord (make-position 0 0 0) TESTP))

(define my_x (degree-coordinate-x DEGREE_COORDINATES_1))

(define my_y (degrees->radians (degree-coordinate-y DEGREE_COORDINATES_1)))

(define my_n (expt 2 ZOOM))

(define my_tile_cols
  (make-posn
     (exact-floor (* my_n (/ (+ my_x 180) 360)))
     (exact-floor (* 0.5 my_n (- 1 (/ (log (+ (tan my_y) (/ 1 (cos my_y)))) pi))))
     ))

(define TILE_COLUMNS_1 (coordinates->tile-columns DEGREE_COORDINATES_1 ZOOM))

(define URL_1 (get-url TILE_COLUMNS_1 10))

(define TILE_1 (load-tile-from-url URL_1))


; final-version test
(define ZOOM_LEVEL 19)
(define DISTANCE (make-position 0 0 0))

(define BOLOGNA (make-degree-coordinate 11.3465 44.4942))
(define SKOPIA (make-degree-coordinate 21.4250 41.9950))
(define CURACAO (make-degree-coordinate -68.9361 12.1069))

(define BOLOGNA_tile (deg_coordinates->tile DISTANCE BOLOGNA ZOOM_LEVEL))
(define SKOPIA_tile (deg_coordinates->tile DISTANCE SKOPIA ZOOM_LEVEL))
(define CURACAO_tile (deg_coordinates->tile DISTANCE CURACAO ZOOM_LEVEL))