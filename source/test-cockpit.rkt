;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname test-cockpit) (read-case-sensitive #t) (teachpacks ((lib "sludges.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "sludges.rkt" "teachpack" "htdp")) #f)))

; Filename: test-cockpit.rkt
; Date: 22.11.2026
; Author: Lorenzo Felix
; Purpose: TEST FILE for visual integration test connecting physics ticks to cockpit drawing.

;; THIS IS A DEMO FILE, NO DESIGN RECEPY I WANTED TO MAKE SUUUURE THAT THE RENDERER WORKS PROPERLY SO I KNOW HOW IT WORKS FOR FUTURE INTEGRATION.

(require 2htdp/universe)
(require "model.rkt")
(require "physics.rkt")
(require "render.rkt")

;; DT : Number
;; Each tick advances 1/30 second of simulated flight.
(define DT (/ 1 30))

;; DEMO-AIRCRAFT : Aircraft
;; Starts airborne at 1,000 m and 140 m/s, pitching up 5 degrees,
;; banking right 15 degrees, with 75% throttle.
;; Pitch, roll and throttle stay fixed, so their instruments stay fixed too.
;; Airspeed, altitude, heading and vertical speed evolve through physics.
(define DEMO-AIRCRAFT
  (make-aircraft (make-Position 0 0 0) 1000 140 0 -1 5 0 100))

;; tick-cockpit : Aircraft -> Aircraft
;; Advances the same aircraft snapshot that the cockpit will display.
(define (tick-cockpit plane)
  (step-aircraft plane DT))

;; ground-reached? : Aircraft -> Boolean
;; Ends the airborne demonstration when the aircraft reaches ground level.
(define (ground-reached? plane)
  (<= (aircraft-altitude plane) 0))

;; Rendering reads the updated aircraft; it never advances the physics itself.
(big-bang DEMO-AIRCRAFT
  (on-tick tick-cockpit DT)
  (to-draw render-cockpit)
  (stop-when ground-reached?))
