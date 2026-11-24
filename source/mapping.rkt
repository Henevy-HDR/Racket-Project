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

(require 2htdp/image)
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



(: get-url (DegreeCoordinates Number -> String))
; interpretation: constructs the URL address of 
; a tile in the OSM website from coordinates and zoom level

; header:
(define-header (get-url coordinates zoom-level) "")

; template:
(define-template (get-url coordinates zoom-level)
  (... (degree-coordinates-x coordinates) ... (degree-coordinates-y coordinates) ... zoom-level ...))

; examples:
;(check-expect (get-url () )

(define (get-url coordinates zoom-level)
  (string-append OSM_base_url "/" zoom-level "/"
                 degree-coordinates-x coordinates "/"
                 degree-coordinates-y coordinates))






(: load-tile-from-url (Position Number -> Image))

(define (load-tile-from-url coordinates zoom-level) empty-tile)

(define FOTO (bitmap/url "https://cdn.poetryfoundation.org/cdn-cgi/image/w=2292,h=1528,q=80/content/images/b48d810454a7c8fbeb31f0907e5c58bfb4e30bb0.jpeg"))
