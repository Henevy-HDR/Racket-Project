;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname render) (read-case-sensitive #t) (teachpacks ((lib "sludges.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "sludges.rkt" "teachpack" "htdp")) #f)))
; Filename: render.rkt
; Date: 12 Nov
; Author: Chad John Pete
; Purpose: imports model.rkt and only contains drawing
;          functions.

(require 2htdp/image)
(require sludges)
(require "model.rkt")
(require "cockpit-instruments.rkt")

;; Modified state variables: none. These functions return converted values
;; or images without changing the aircraft or advancing the simulation.

;; metres-to-feet : Number -> Number
(: metres-to-feet (Number -> Number))
;; Converts physics distances to the altimeter's display unit.
(define (metres-to-feet metres)
  (* metres (/ 1250 381)))

;; mps-to-knots : Number -> Number
(: mps-to-knots (Number -> Number))
;; Converts airspeed in metres/second to knots.
(define (mps-to-knots speed)
  (* speed (/ 900 463)))

;; mps-to-feet-per-minute : Number -> Number
(: mps-to-feet-per-minute (Number -> Number))
;; Converts vertical speed while preserving its climb/descent sign.
(define (mps-to-feet-per-minute speed)
  (* 60 (metres-to-feet speed)))

;; render-cockpit : Aircraft -> Image
(: render-cockpit (Aircraft -> Image))
;; Aircraft, Position, Degree and Throttle are defined and exemplified in model.rkt.
;; Draws every instrument from the same aircraft snapshot.
;; Physics retains SI units; only drawing converts to cockpit units.
(define (render-cockpit plane)
  (compose-cockpit
   (render-throttle (aircraft-throttle plane))
   (render-compass (aircraft-heading plane))
   (render-altimeter (metres-to-feet (aircraft-altitude plane)))
   (render-airspeed (mps-to-knots (aircraft-airspeed plane)))
   (render-vspeed (mps-to-feet-per-minute (aircraft-vspeed plane)))
   (render-horizon (aircraft-pitch plane) (aircraft-roll plane))))

;; Executable input/output examples for each top-level function.
(check-within (metres-to-feet 0) 0 0.000001)
(check-within (metres-to-feet 0.3048) 1 0.000001)
(check-within (metres-to-feet -0.3048) -1 0.000001)
(check-within (mps-to-knots 0) 0 0.000001)
(check-within (mps-to-knots (/ 1852 3600)) 1 0.000001)
(check-within (mps-to-feet-per-minute 0) 0 0.000001)
(check-within (mps-to-feet-per-minute 0.3048) 60 0.000001)
(check-within (mps-to-feet-per-minute -0.3048) -60 0.000001)

;; Expected cockpit for a concrete aircraft with independently specified units.
(define AIRCRAFT-DISPLAY-EXAMPLE
  (make-aircraft POSITION-EAST 3048 (/ 463 9) 90 5 15 (/ 127 25) 75))
(define EXPECTED-COCKPIT-EXAMPLE
  (compose-cockpit (render-throttle 75) (render-compass 90)
                   (render-altimeter 10000) (render-airspeed 100)
                   (render-vspeed 1000) (render-horizon 5 15)))
(check-expect (render-cockpit AIRCRAFT-DISPLAY-EXAMPLE)
              EXPECTED-COCKPIT-EXAMPLE)
(check-expect (image-width (render-cockpit AIRCRAFT-LEVEL)) 960)
(check-expect (image-height (render-cockpit AIRCRAFT-CLIMBING)) 540)

;; These functions are non-recursive; no termination arguments are needed.

(provide render-cockpit metres-to-feet mps-to-knots mps-to-feet-per-minute)

