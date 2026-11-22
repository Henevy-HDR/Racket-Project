;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
; Filename: model.rkt
; Date: 12 Nov
; Author: Chad John Pete
; Purpose: contains all the struct definitions and the program's
;          logic functions.
; TODO: comments and examples for the structs

(require sludges)

;; Use built-in Posn as Position (or define your own struct with typed fields)
(define-struct Position
  ([x Number]
   [y Number]
   [heading Degree]))

(define-struct degree-coordinate [(x Degree) (y Degree)])

(define-type Degree (number-from-<to 0 360))

(define-type Throttle (integer-from-to 0 100))

;; IT IS TRHOTTLE NOT INDEXPOWER IT IS THROTTLE NOT INDEX POWER
;; memo use define-type with integer from to and enum and one of, no define yet pwease 

(define-struct aircraft [(position Position)
                         (altitude Number)
                         (airspeed Number)
                         (heading Degree)
                         (pitch Number)
                         (roll Number)
                         (vspeed Number)
                         (throttle Throttle)])

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
