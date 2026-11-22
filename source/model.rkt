;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname model) (read-case-sensitive #t) (teachpacks ((lib "sludges.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #t #t none #t ((lib "sludges.rkt" "teachpack" "htdp")) #f)))
;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
; Filename: model.rkt
; Date: 12 Nov
; Author: Chad John Pete
; Purpose: contains all the struct definitions and the program's 
;          logic functions.
; TODO: comments and examples for the structs

(require sludges)

;; Local X (east) and Y (north) in metres; heading clockwise from north.
;; An aircraft's position heading agrees with its aircraft heading.
;; A Position is (make-Position Number Number Degree).
(define-struct Position
  ([x Number]
   [y Number]
   [heading Degree]))

(define-struct degree-coordinate [(x Degree) (y Degree)])

(define-type Degree (number-from-<to 0 360))
;; A Degree is a Number in [0, 360), measured clockwise from north.

(define-type Throttle (integer-from-to 0 100))
;; A Throttle is an Integer in [0, 100], representing engine power percent.

;; IT IS TRHOTTLE NOT INDEXPOWER IT IS THROTTLE NOT INDEX POWER
;; memo use define-type with integer from to and enum and one of, no define yet pwease 

;; An Aircraft is
;; (make-aircraft Position Number Number Degree Number Number Number Throttle).
;; Altitude is in metres; airspeed and vertical speed are in metres/second.
;; Pitch and roll are degrees; positive values mean nose-up and right bank.
;; Airspeed is non-negative and at least the absolute vertical speed.
(define-struct aircraft [(position Position)
                         (altitude Number)
                         (airspeed Number)
                         (heading Degree)
                         (pitch Number)
                         (roll Number)
                         (vspeed Number)
                         (throttle Throttle)])

;; Examples of the structured data consumed by the cockpit drawing functions.
(define POSITION-ORIGIN (make-Position 0 0 0))
(define POSITION-EAST (make-Position 100 200 90))
(define AIRCRAFT-LEVEL
  (make-aircraft POSITION-ORIGIN 1000 140 0 0 0 0 50))
(define AIRCRAFT-CLIMBING
  (make-aircraft POSITION-EAST 1500 150 90 5 15 3 75))

;; Use enum for specific literal values
(define-type FlightStatus (enum "flying" "crushed"))

;; Hyphenated struct name generates the CamelCase signature `WorldState`
(define-struct world-state [(aircraft Aircraft)
                            (destination Position)
                            (status FlightStatus)])

(define-type InstrumentType
  (enum "altimeter"
        "airspeed"
        "compass"
        "horizon"
        "vertical-speed"
        "throttle"))

(define-struct instrument [(type InstrumentType)
                           (position Position)
                           (size Number)]) 

; MODULE EXPORTS
(provide Aircraft Position Degree Throttle FlightStatus WorldState InstrumentType Instrument)
(provide make-Position Position? Position-x Position-y Position-heading)
(provide POSITION-ORIGIN POSITION-EAST AIRCRAFT-LEVEL AIRCRAFT-CLIMBING)
(provide make-aircraft aircraft?)
(provide aircraft-position aircraft-altitude)
(provide aircraft-airspeed aircraft-heading)
(provide aircraft-pitch aircraft-roll) 
(provide aircraft-vspeed aircraft-throttle)
(provide DegreeCoordinate
         make-degree-coordinate
         degree-coordinate?
         degree-coordinate-x
         degree-coordinate-y)
