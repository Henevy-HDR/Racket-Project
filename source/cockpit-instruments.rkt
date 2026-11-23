;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname cockpit-instruments) (read-case-sensitive #t) (teachpacks ((lib "sludges.rkt" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "sludges.rkt" "teachpack" "htdp")) #f)))
;; The first three lines of this file were inserted by DrRacket. They record metadata
; Filename: cockpit-instruments.rkt
; Date: 12 Nov
; Author: Leonida Ilijoska
; Purpose: graphical representation of the instruments and the cockpit.
;          Fixed artwork and functions drawing instruments from live values.
;TO DO: update the wheel.


; Edits by Lorenzo Felix
; Added render functions and design recipe!

(require 2htdp/universe)
(require 2htdp/image)
(require sludges)

;; All inputs and outputs below use built-in Number, String and Image types.
;; No additional data types or recursive functions are introduced here.
;; Modified state variables: none. Every function returns a value without
;; changing its inputs or the shared artwork constants.

;; display-number : Number -> String
(: display-number (Number -> String))
;; Rounds only the displayed text, preserving precision for needle movement.
(define (display-number value)
  (number->string (inexact->exact (round value))))

;; limit-to : Number Number Number -> Number
(: limit-to (Number Number Number -> Number))
;; Limits a needle to the visible scale without changing its numeric readout.
;; Assumes low <= high.
(define (limit-to low high value)
  (max low (min high value)))

;; heading-text : Number -> String
(: heading-text (Number -> String))
;; Displays a rounded heading as three digits, wrapping 360 back to 000.
(define (heading-text heading)
  (local [(define degrees (modulo (inexact->exact (round heading)) 360))
          (define digits (number->string degrees))]
    (string-append (cond [(< degrees 10) "00"]
                         [(< degrees 100) "0"]
                         [else ""])
                   digits "°")))


;; @CANVAS

;color
(define sky-blue (make-color 194 237 255))

;dimensions
(define canvas-width 960)
(define canvas-heigth 540)

;render
(define canvas (empty-scene canvas-width canvas-heigth sky-blue))



;; @COCKPIT

;color
(define cockpit-color "Silver")
(define cockpit-color-outline "Dim gray")

;dimensions
(define cockpit-canvas-width 960)
(define cockpit-canvas-heigth 540)

(define cockpit-width 1200)
(define cockpit-height 500)

(define cockpit-pole-width 20)
(define cockpit-pole-heigth 400)

;parts
;cockpit-canvas
(define cockpit-canvas
  (rectangle cockpit-canvas-width cockpit-canvas-heigth "solid" "transparent"))

;cockpit-pole-right
(define cockpit-pole-right-base
  (rotate -20 (rectangle cockpit-pole-width cockpit-pole-heigth "solid" cockpit-color)))

(define cockpit-pole-right-outline
  (rotate -20 (rectangle (+ cockpit-pole-width 2) (+ cockpit-pole-heigth 2) "solid" cockpit-color-outline)))

(define cockpit-pole-right
  (overlay cockpit-pole-right-base
           cockpit-pole-right-outline))

;cockpit-pole-left
(define cockpit-pole-left-base
  (flip-horizontal cockpit-pole-right))

(define cockpit-pole-left-outline
  (rotate 20 (rectangle (+ cockpit-pole-width 2) (+ cockpit-pole-heigth 2) "solid" cockpit-color-outline)))

(define cockpit-pole-left
  (overlay
   cockpit-pole-left-base
   cockpit-pole-left-outline))

;cockpit-panel
(define cockpit-panel-base
  (ellipse cockpit-width cockpit-height "solid" cockpit-color))

(define cockpit-panel-outline
  (ellipse (+ cockpit-width 3) (+ cockpit-height 3) "solid" cockpit-color-outline))

(define cockpit-panel
  (overlay
   cockpit-panel-base
   cockpit-panel-outline))

;render
(define cockpit
  (place-images
   (list cockpit-panel
         cockpit-pole-right
         cockpit-pole-left)
   (list (make-posn 480 440)
         (make-posn 910 150)
         (make-posn 50 150))
   cockpit-canvas))



;; @WHEEL

;color
(define wheel-base-color (make-color 79 70 64))
(define wheel-base-color-outline (make-color 55 43 35))

(define wheel-handle-color (make-color 33 29 25))
(define wheel-handle-color-outline "black")

;dimesnions
(define wheel-canvas-width 200)
(define wheel-canvas-heigth 200)

;details
;silver detail
(define wheel-detail (circle 15 "solid" "silver"))

;wheel-base-main
(define wheel-base-main-center (circle 40 "solid" wheel-base-color))
(define wheel-base-main-outline (circle 42 "solid" wheel-base-color-outline))
(define wheel-base-main (overlay wheel-base-main-center wheel-base-main-outline))

;wheel-base-handle
(define wheel-base-handle (rectangle 300 20 "solid" wheel-handle-color))

;parts
;canvas
(define wheel-canvas (rectangle 200 200 "solid" "transparent"))

;wheel-base
(define wheel-base
  (overlay
   wheel-detail
   wheel-base-main
   wheel-base-handle))

;wheel-handle
(define wheel-handle-base (rectangle 20 100 "solid" wheel-handle-color))
(define wheel-handle-outline (rectangle 22 102 "solid" wheel-handle-color-outline))
(define wheel-handle (overlay wheel-handle-base wheel-handle-outline))

;render
(define wheel
  (place-images
   (list wheel-base
         wheel-handle
         wheel-handle)
   (list (make-posn 100 100)
         (make-posn 10 50)
         (make-posn 190 50))
   wheel-canvas))



;; @THROTTLE

;colors
(define throttle-panel-color "dimgray")
(define throttle-color "black")
(define throttle-detail-color "white")

;dimensions
(define throttle-width 120)
(define throttle-height 220)

;detail
;throttle-tick
(define throttle-tick (rectangle 8 1 "solid" "white smoke"))

;parts
;throttle-canvas
(define throttle-canvas
  (overlay
   (rectangle throttle-width throttle-height "solid" throttle-panel-color)
   (rectangle (+ throttle-width 4) (+ throttle-height 4) "solid" throttle-color)))

;throttle-rail
(define throttle-rail
  (overlay (rectangle 10 140 "solid" "gray")
           (rectangle 60 155 "solid" throttle-color)))

;throttle-handle
(define throttle-handle
  (overlay (rectangle 30 3 "solid" throttle-color)
           (rectangle 45 15 "solid" "firebrick")
           (rectangle 49 19 "solid" throttle-color)))

;throttle-readout
(define throttle-readout
  (overlay (rectangle 50 20 "solid" throttle-color)
           (rectangle 52 22 "solid" "slategray")))

;readout-example
(define readout-example (text "50%" 12 throttle-detail-color))

;render ticks and percentages
(define throttle-base
  (place-images
   (list (text "THROTTLE" 16 throttle-detail-color)
         (text "100%" 11 throttle-detail-color)
         throttle-tick
         (text "75%" 11 throttle-detail-color)
         throttle-tick
         (text "50%" 11 throttle-detail-color)
         throttle-tick
         (text "25%" 11 throttle-detail-color)
         throttle-tick
         (text "0%" 11 throttle-detail-color)
         throttle-tick
         throttle-rail
         throttle-readout)
   (list (make-posn 60 20)
         (make-posn 20 40)
         (make-posn 40 40)      ;tick
         (make-posn 20 76.25)
         (make-posn 40 76.25)   ;tick
         (make-posn 20 112.5)
         (make-posn 40 112.5)   ;tick
         (make-posn 20 148.75)
         (make-posn 40 148.75)  ;tick
         (make-posn 20 185)
         (make-posn 40 185)     ;tick
         (make-posn 80 110)     ;rail
         (make-posn 60 205))    ;readout
   throttle-canvas))

;; render-throttle : Number -> Image
(: render-throttle (Number -> Image))
;; Draws engine power in percent; the handle follows the labelled ticks.
(define (render-throttle percentage)
  (place-images (list throttle-handle
                      (text (string-append (display-number percentage) "%")
                            12 throttle-detail-color))
                (list (make-posn 80 (- 185 (* 1.45 (limit-to 0 100 percentage))))
                      (make-posn 60 205))
                throttle-base))

;example: the handle sits at 50%.
(define throttle (render-throttle 50))



;; @COMPASS

;colors
(define compass-panel-color "dimgray")

(define compass-north-color "blue")
(define compass-south-color "red")

(define compass-color "black")
(define compass-color-outline "slate gray")

(define compass-detail-color "white")

;dimensions
(define compass-size 140)
(define compass-dial-radius 50)
(define compass-readout-width 60)
(define compass-readout-height 15)

;details
;compass-hub
(define compass-hub (circle 3 "solid" compass-detail-color))

;compass-tick
(define compass-tick (rectangle 2 6 "solid" compass-color-outline))

;parts
;compass-canvas
(define compass-canvas
  (overlay (rectangle compass-size compass-size "solid" compass-panel-color)
           (rectangle (+ compass-size 3) (+ compass-size 3) "solid" compass-color)))

;compass-dial
(define compass-dial
  (overlay (circle compass-dial-radius "solid" compass-color)
           (circle (+ compass-dial-radius 3) "solid" compass-color-outline)))

;compass-readout
(define compass-readout
  (overlay (rectangle compass-readout-width compass-readout-height "solid" compass-color)
           (rectangle (+ compass-readout-width 2) (+ compass-readout-height 2) "solid" compass-color-outline)))

;compass-needle
(define compass-needle
  (place-images
   (list (triangle 7 "solid" compass-north-color)
         (rectangle 3 20 "solid" compass-north-color)
         (rectangle 3 14 "solid" compass-south-color))
   (list (make-posn 50 30)
         (make-posn 50 40)
         (make-posn 50 57))
   (rectangle (* compass-dial-radius 2) (* compass-dial-radius 2) "solid" "transparent")))

;dial with poles and ticks
(define compass-base
  (place-images
   (list (text "COMPASS" 12 compass-detail-color)
         (text "N" 12 compass-north-color)
         (text "NE" 10 compass-detail-color)
         (text "E" 12 compass-detail-color)
         (text "SE" 10 compass-detail-color)
         (text "S" 12 compass-south-color)
         (text "SW" 10 compass-detail-color)
         (text "W" 12 compass-detail-color)
         (text "NW" 10 compass-detail-color)
         compass-tick
         (rotate -45 compass-tick)
         (rotate -90 compass-tick)
         (rotate -135 compass-tick)
         compass-tick
         (rotate -45 compass-tick)
         (rotate -90 compass-tick)
         (rotate -135 compass-tick)
         compass-dial
         compass-readout)
   (list (make-posn 71 10)    ;title
         ;letters
         (make-posn 71 39)    ;N
         (make-posn 94 48)    ;NE
         (make-posn 103 71)   ;E
         (make-posn 94 94)    ;SE
         (make-posn 71 103)   ;S
         (make-posn 48 94)    ;SW
         (make-posn 39 71)    ;W
         (make-posn 48 48)    ;NW
         ;ticks
         (make-posn 71 27)    ;N
         (make-posn 102 40)   ;NE
         (make-posn 115 71)   ;E
         (make-posn 102 102)  ;SE
         (make-posn 71 115)   ;S
         (make-posn 40 102)   ;SW
         (make-posn 27 71)    ;W
         (make-posn 40 40)    ;NW
         (make-posn 71 71)    ;dial
         (make-posn 71 133))  ;readout
   compass-canvas))

;; render-compass : Number -> Image
(: render-compass (Number -> Image))
;; Draws heading clockwise from north against the fixed compass face.
(define (render-compass heading)
  (place-images
   (list compass-hub
         (rotate (- heading) compass-needle)
         (text (heading-text heading) 12 compass-detail-color))
   (list (make-posn 71 71)
         (make-posn 71 71)
         (make-posn 71 133))
   compass-base))

;example: northeast, 045 degrees
(define compass (render-compass 45))



;; @ALTIMETER

;colors
(define altimeter-panel-color "dimgray")
(define altimeter-accent "gold")
(define altimeter-color "black")
(define altimeter-color-outline "slategray")
(define altimeter-detail-color "white")

;dimensions
(define altimeter-size 140)
(define altimeter-dial-radius 50)
(define altimeter-readout-width 60)
(define altimeter-readout-height 15)

;details
;altimeter-tick
(define altimeter-tick
  (rectangle 2 6 "solid" altimeter-color-outline))

;altimeter-hub
(define altimeter-hub
  (circle 3 "solid" "white"))

;parts
;altimeter-canvas
(define altimeter-canvas
  (overlay
   (rectangle altimeter-size altimeter-size "solid" altimeter-panel-color)
   (rectangle (+ altimeter-size 3) (+ altimeter-size 3) "solid" "black")))

;altimeter-dial
(define altimeter-dial
  (overlay
   (circle altimeter-dial-radius "solid" altimeter-color)
   (circle (+ altimeter-dial-radius 3) "solid" altimeter-color-outline)))

;altimeter-readout
(define altimeter-readout
  (overlay
   (rectangle altimeter-readout-width altimeter-readout-height "solid" altimeter-color)
   (rectangle (+ altimeter-readout-width 2) (+ altimeter-readout-height 2) "solid" altimeter-color-outline)))

;altimeter-needle, pointing up before rotation
(define altimeter-needle
  (place-images
   (list (triangle 7 "solid" altimeter-accent)
         (rectangle 3 20 "solid" altimeter-accent))
   (list (make-posn 50 30)
         (make-posn 50 40))
   (rectangle 100 100 "solid" "transparent")))

;dial with numbers and ticks
(define altimeter-base
  (place-images
   (list (text "ALTIMETER" 12 altimeter-detail-color)
         (text "×1000 FT" 7 "lightsteelblue")
         (text "0" 10 altimeter-detail-color)
         (text "1" 10 altimeter-detail-color)
         (text "2" 10 altimeter-detail-color)
         (text "3" 10 altimeter-detail-color)
         (text "4" 10 altimeter-detail-color)
         (text "5" 10 altimeter-detail-color)
         (text "6" 10 altimeter-detail-color)
         (text "7" 10 altimeter-detail-color)
         (text "8" 10 altimeter-detail-color)
         (text "9" 10 altimeter-detail-color)
         altimeter-tick
         (rotate -36 altimeter-tick)
         (rotate -72 altimeter-tick)
         (rotate -108 altimeter-tick)
         (rotate -144 altimeter-tick)
         altimeter-tick
         (rotate -36 altimeter-tick)
         (rotate -72 altimeter-tick)
         (rotate -108 altimeter-tick)
         (rotate -144 altimeter-tick)
         altimeter-dial
         altimeter-readout)
   (list (make-posn 71 10)    ;title
         (make-posn 71 90)    ;units
         ;numbers
         (make-posn 71 38)    ;0
         (make-posn 90 44)    ;1
         (make-posn 102 61)   ;2
         (make-posn 102 81)   ;3
         (make-posn 90 98)    ;4
         (make-posn 71 104)   ;5
         (make-posn 52 98)    ;6
         (make-posn 40 81)    ;7
         (make-posn 40 61)    ;8
         (make-posn 52 44)    ;9
         ;ticks
         (make-posn 71 27)    ;0
         (make-posn 97 35)    ;1
         (make-posn 113 57)   ;2
         (make-posn 113 85)   ;3
         (make-posn 97 107)   ;4
         (make-posn 71 115)   ;5
         (make-posn 45 107)   ;6
         (make-posn 29 85)    ;7
         (make-posn 29 57)    ;8
         (make-posn 45 35)    ;9
         (make-posn 71 71)    ;dial
         (make-posn 71 133))  ;readout
   altimeter-canvas))

;; render-altimeter : Number -> Image
(: render-altimeter (Number -> Image))
;; Draws altitude in feet; one revolution represents 10,000 feet.
(define (render-altimeter feet)
  (place-images
   (list altimeter-hub
         (rotate (* -0.036 (- feet (* 10000 (floor (/ feet 10000)))))
                 altimeter-needle)
         (text (string-append (display-number feet) " FT")
               10 altimeter-detail-color))
   (list (make-posn 71 71)
         (make-posn 71 71)
         (make-posn 71 133))
   altimeter-base))

;example: 3,000 ft
(define altimeter (render-altimeter 3000))



;; @AIRSPEED

;colors
(define airspeed-panel-color "dimgray")
(define airspeed-accent "gold")
(define airspeed-color "black")
(define airspeed-color-outline "slategray")
(define airspeed-detail-color "white")

;dimensions
(define airspeed-size 140)
(define airspeed-dial-radius 50)
(define airspeed-readout-width 60)
(define airspeed-readout-height 15)

;details
;airspeed-tick
(define airspeed-tick
  (rectangle 2 6 "solid" airspeed-color-outline))

;airspeed-hub
(define airspeed-hub
  (circle 3 "solid" airspeed-detail-color))

;parts
;airspeed-canvas
(define airspeed-canvas
  (overlay
   (rectangle airspeed-size airspeed-size "solid" airspeed-panel-color)
   (rectangle (+ airspeed-size 3) (+ airspeed-size 3) "solid" airspeed-color)))

;airspeed-dial
(define airspeed-dial
  (overlay
   (circle airspeed-dial-radius "solid" airspeed-color)
   (circle (+ airspeed-dial-radius 3) "solid" airspeed-color-outline)))

;airspeed-readout
(define airspeed-readout
  (overlay
   (rectangle airspeed-readout-width airspeed-readout-height "solid" airspeed-color)
   (rectangle (+ airspeed-readout-width 2) (+ airspeed-readout-height 2)
              "solid" airspeed-color-outline)))

;airspeed-needle, pointing up before rotation
(define airspeed-needle
  (place-images
   (list (triangle 7 "solid" airspeed-accent)
         (rectangle 3 20 "solid" airspeed-accent))
   (list (make-posn 50 30)
         (make-posn 50 40))
   (rectangle 100 100 "solid" "transparent")))

;dial with numbers and ticks
(define airspeed-base
  (place-images
   (list (text "AIRSPEED" 12 airspeed-detail-color)
         (text "KT" 8 airspeed-detail-color)
         (text "0" 9 airspeed-detail-color)
         (text "50" 9 airspeed-detail-color)
         (text "100" 9 airspeed-detail-color)
         (text "150" 9 airspeed-detail-color)
         (text "200" 9 airspeed-detail-color)
         (text "250" 9 airspeed-detail-color)
         (text "300" 9 airspeed-detail-color)
         (text "350" 9 airspeed-detail-color)
         (text "400" 9 airspeed-detail-color)
         (rotate 135 airspeed-tick)
         (rotate 101.25 airspeed-tick)
         (rotate 67.5 airspeed-tick)
         (rotate 33.75 airspeed-tick)
         (rotate 0 airspeed-tick)
         (rotate -33.75 airspeed-tick)
         (rotate -67.5 airspeed-tick)
         (rotate -101.25 airspeed-tick)
         (rotate -135 airspeed-tick)
         airspeed-dial
         airspeed-readout)
   (list (make-posn 71 10)    ;title
         (make-posn 71 91)    ;units
         ;numbers
         (make-posn 48 94)    ;0
         (make-posn 39 77)    ;50
         (make-posn 41 58)    ;100
         (make-posn 53 44)    ;150
         (make-posn 71 38)    ;200
         (make-posn 89 44)    ;250
         (make-posn 101 58)    ;300
         (make-posn 103 77)    ;350
         (make-posn 94 94)    ;400
         ;ticks
         (make-posn 40 102)    ;0
         (make-posn 28 80)    ;50
         (make-posn 30 54)    ;100
         (make-posn 47 34)    ;150
         (make-posn 71 27)    ;200
         (make-posn 95 34)    ;250
         (make-posn 112 54)    ;300
         (make-posn 114 80)    ;350
         (make-posn 102 102)    ;400
         (make-posn 71 71)    ;dial
         (make-posn 71 133))  ;readout
   airspeed-canvas))

;; render-airspeed : Number -> Image
(: render-airspeed (Number -> Image))
;; Draws knots on the 0–400 scale; out-of-range readouts remain truthful.
(define (render-airspeed knots)
  (place-images
   (list airspeed-hub
         (rotate (- 135 (* 0.675 (limit-to 0 400 knots))) airspeed-needle)
         (text (string-append (display-number knots) " KT")
               10 airspeed-detail-color))
   (list (make-posn 71 71)
         (make-posn 71 71)
         (make-posn 71 133))
   airspeed-base))

;example: 250 KT
(define airspeed (render-airspeed 250))



;; @VERTICAL SPEED

;colors
(define vertical-speed-panel-color "dimgray")
(define vertical-speed-accent "gold")
(define vertical-speed-color "black")
(define vertical-speed-color-outline "slategray")
(define vertical-speed-detail-color "white")

;dimensions
(define vertical-speed-size 140)
(define vertical-speed-dial-radius 50)
(define vertical-speed-readout-width 60)
(define vertical-speed-readout-height 15)

;details
;vertical-speed-tick
(define vertical-speed-tick
  (rectangle 2 6 "solid" vertical-speed-color-outline))

;vertical-speed-hub
(define vertical-speed-hub
  (circle 3 "solid" vertical-speed-detail-color))

;parts
;vertical-speed-canvas
(define vertical-speed-canvas
  (overlay
   (rectangle vertical-speed-size vertical-speed-size "solid" vertical-speed-panel-color)
   (rectangle (+ vertical-speed-size 3) (+ vertical-speed-size 3) "solid" vertical-speed-color)))

;vertical-speed-dial
(define vertical-speed-dial
  (overlay
   (circle vertical-speed-dial-radius "solid" vertical-speed-color)
   (circle (+ vertical-speed-dial-radius 3) "solid" vertical-speed-color-outline)))

;vertical-speed-readout
(define vertical-speed-readout
  (overlay
   (rectangle vertical-speed-readout-width vertical-speed-readout-height "solid" vertical-speed-color)
   (rectangle (+ vertical-speed-readout-width 2) (+ vertical-speed-readout-height 2)
              "solid" vertical-speed-color-outline)))

;vertical-speed-needle, pointing up before rotation
(define vertical-speed-needle
  (place-images
   (list (triangle 7 "solid" vertical-speed-accent)
         (rectangle 3 20 "solid" vertical-speed-accent))
   (list (make-posn 50 30)
         (make-posn 50 40))
   (rectangle 100 100 "solid" "transparent")))

;positive numbers mean climbing; negative numbers mean descending.
;multiply the dial number by 100: +10 means climbing at 1,000 ft/min.
;zero is on the left of the dial.
;dial with numbers and ticks
(define vertical-speed-base
  (place-images
   (list (text "VERTICAL SPEED" 10 vertical-speed-detail-color)
         (text "×100 FT/MIN" 6 vertical-speed-detail-color)
         (text "-20" 9 vertical-speed-detail-color)
         (text "-15" 9 vertical-speed-detail-color)
         (text "-10" 9 vertical-speed-detail-color)
         (text "-5" 9 vertical-speed-detail-color)
         (text "0" 9 vertical-speed-detail-color)
         (text "+5" 9 vertical-speed-detail-color)
         (text "+10" 9 vertical-speed-detail-color)
         (text "+15" 9 vertical-speed-detail-color)
         (text "+20" 9 vertical-speed-detail-color)
         (rotate -120 vertical-speed-tick)
         (rotate -157.5 vertical-speed-tick)
         (rotate -195 vertical-speed-tick)
         (rotate -232.5 vertical-speed-tick)
         (rotate -270 vertical-speed-tick)
         (rotate -307.5 vertical-speed-tick)
         (rotate -345 vertical-speed-tick)
         (rotate -22.5 vertical-speed-tick)
         (rotate -60 vertical-speed-tick)
         vertical-speed-dial
         vertical-speed-readout)
   (list (make-posn 71 10)    ;title
         (make-posn 71 91)    ;units
         ;numbers
         (make-posn 100 88)    ;-20
         (make-posn 84 101)    ;-15
         (make-posn 62 103)    ;-10
         (make-posn 45 91)    ;-5
         (make-posn 38 71)    ;0
         (make-posn 45 51)    ;+5
         (make-posn 62 39)    ;+10
         (make-posn 84 41)    ;+15
         (make-posn 100 54)    ;+20
         ;ticks
         (make-posn 109 93)    ;-20
         (make-posn 88 112)    ;-15
         (make-posn 60 114)    ;-10
         (make-posn 36 98)    ;-5
         (make-posn 27 71)    ;0
         (make-posn 36 44)    ;+5
         (make-posn 60 28)    ;+10
         (make-posn 88 30)    ;+15
         (make-posn 109 49)    ;+20
         (make-posn 71 71)    ;dial
         (make-posn 71 133))  ;readout
   vertical-speed-canvas))

;; render-vspeed : Number -> Image
(: render-vspeed (Number -> Image))
;; Draws feet/minute, positive for climb; the needle stops at +/-2,000.
(define (render-vspeed feet-per-minute)
  (place-images
   (list vertical-speed-hub
         (rotate (- 90 (* 0.075 (limit-to -2000 2000 feet-per-minute)))
                 vertical-speed-needle)
         (text (string-append (display-number feet-per-minute) " FT/MIN")
               8 vertical-speed-detail-color))
   (list (make-posn 71 71)
         (make-posn 71 71)
         (make-posn 71 133))
   vertical-speed-base))

;example: 0 FT/MIN
(define vertical-speed (render-vspeed 0))



;; @ARTIFICIAL HORIZON

;colors
(define horizon-panel-color "dimgray")

(define horizon-sky-color "steelblue")
(define horizon-ground-color "sienna")

(define horizon-symbol-color "gold")
(define horizon-detail-color "white")

;dimensions
(define horizon-size 170)
(define horizon-window-width 148)
(define horizon-window-height 116)

;detail
;tick(define horizon-pitch-tick
  (rectangle 34 1 "solid" horizon-detail-color))

;parts
;horizon-canvas
(define horizon-canvas
  (overlay
   (rectangle 166 166 "solid" horizon-panel-color)
   (rectangle horizon-size horizon-size "solid" "black")))

;horizon-readout
(define horizon-readout
  (overlay
   (rectangle 128 14 "solid" "black")
   (rectangle 130 16 "solid" "slategray")))

;horizon-base
(define horizon-base
  (place-images
   (list (text "ARTIFICIAL HORIZON" 10 horizon-detail-color)
         horizon-readout)
   (list (make-posn 85 12)
         (make-posn 85 158))
   horizon-canvas))

;horizon-window
(define horizon-window
  (rectangle horizon-window-width horizon-window-height
             "solid" "transparent"))

;horizon-window-border
(define horizon-window-outline
  (rectangle horizon-window-width horizon-window-height
             "outline" "slate gray"))

;airplane symbol
(define horizon-wing
  (rectangle 22 3 "solid" horizon-symbol-color))

(define horizon-wing-tip
  (rectangle 3 8 "solid" horizon-symbol-color))

(define horizon-aircraft
  (place-images
   (list (circle 3 "solid" horizon-symbol-color)
         horizon-wing
         horizon-wing
         horizon-wing-tip
         horizon-wing-tip)
   (list (make-posn 45 10)
         (make-posn 23 10)
         (make-posn 67 10)
         (make-posn 35 13)
         (make-posn 55 13))
   (rectangle 90 20 "solid" "transparent")))

;horizon-landscape
(define horizon-landscape
  (place-images
   (list (rectangle 400 2 "solid" horizon-detail-color)

         horizon-pitch-tick
         (text "30" 9 horizon-detail-color)
         (text "30" 9 horizon-detail-color)
         horizon-pitch-tick
         (text "20" 9 horizon-detail-color)
         (text "20" 9 horizon-detail-color)
         horizon-pitch-tick
         (text "10" 9 horizon-detail-color)
         (text "10" 9 horizon-detail-color)
         horizon-pitch-tick
         (text "-10" 9 horizon-detail-color)
         (text "-10" 9 horizon-detail-color)
         horizon-pitch-tick
         (text "-20" 9 horizon-detail-color)
         (text "-20" 9 horizon-detail-color)
         horizon-pitch-tick
         (text "-30" 9 horizon-detail-color)
         (text "-30" 9 horizon-detail-color))
   (list (make-posn 200 200)  ;level horizon
         (make-posn 200 152)  ;+30 degrees
         (make-posn 170 152)
         (make-posn 230 152)
         (make-posn 200 168)  ;+20 degrees
         (make-posn 170 168)
         (make-posn 230 168)
         (make-posn 200 184)  ;+10 degrees
         (make-posn 170 184)
         (make-posn 230 184)
         (make-posn 200 216)  ;-10 degrees
         (make-posn 170 216)
         (make-posn 230 216)
         (make-posn 200 232)  ;-20 degrees
         (make-posn 170 232)
         (make-posn 230 232)
         (make-posn 200 248)  ;-30 degrees
         (make-posn 170 248)
         (make-posn 230 248))

   (above
    (rectangle 400 200 "solid" horizon-sky-color)
    (rectangle 400 200 "solid" horizon-ground-color))))

;; render-horizon : Number Number -> Image
(: render-horizon (Number Number -> Image))
;; Draws pitch and right bank in degrees around a fixed aircraft symbol.
;; Pitch moves the landscape by 1.6 pixels/degree before bank rotation.
;; The visible pitch movement stops at +/-60; the readout retains the value.
(define (render-horizon pitch roll)
  (place-images
   (list (text (string-append "PITCH " (display-number pitch)
                              "°     ROLL " (display-number roll) "°")
               10 horizon-detail-color)
         horizon-aircraft
         horizon-window-outline
         (place-image
          (rotate roll
                  (place-image horizon-landscape
                               200 (+ 200 (* 1.6 (limit-to -60 60 pitch)))
                               (rectangle 400 400 "solid" "transparent")))
          74 58 horizon-window))
   (list (make-posn 85 158)
         (make-posn 85 85)
         (make-posn 85 85)
         (make-posn 85 85))
   horizon-base))

;example: level flight
(define horizon (render-horizon 0 0))

;; @MAP-AREA
(define map-area (empty-scene 250 250))



;; @SCALE INSTRUMENTS
(define WHEEL (scale 1 wheel))
(define THROTTLE (scale 0.8 throttle))
(define COMPASS (scale 0.7 compass))
(define ALTIMETER (scale 0.7 altimeter))
(define AIRSPEED (scale 0.7 airspeed))
(define VERTICAL-SPEED (scale 0.7 vertical-speed))
(define HORIZON (scale 1 horizon))


;; compose-cockpit : Image Image Image Image Image Image -> Image
(: compose-cockpit (Image Image Image Image Image Image -> Image))
;; Places instrument images in the original layout, applying display scales.
(define (compose-cockpit throttle-image compass-image altimeter-image
                         airspeed-image vspeed-image horizon-image)
  (place-images (list WHEEL
                      (scale 0.8 throttle-image)
                      (scale 0.7 compass-image)
                      (scale 0.7 altimeter-image)
                      (scale 0.7 airspeed-image)
                      (scale 0.7 vspeed-image)
                      horizon-image
                      map-area
                      cockpit)
                (list (make-posn 480 490)    ;wheel
                      (make-posn 290 440)    ;throttle
                      (make-posn 650 450)    ;compass
                      (make-posn 320 290)    ;altimeter
                      (make-posn 650 290)    ;airspeed
                      (make-posn 205 290)    ;vertical-speed
                      (make-posn 480 290)    ;horizon
                      (make-posn 835 415)    ;map-area
                      (make-posn 480 270))   ;cockpit
                canvas))

;; @COCKPIT-PREVIEW
(define COCKPIT-PREVIEW
  (compose-cockpit throttle compass altimeter airspeed vertical-speed horizon))

;; @EXECUTABLE INPUT/OUTPUT EXAMPLES
;; Expected images use concrete positions, angles and text rather than calling
;; the function under test to construct its own expected result.

(check-expect (display-number 12.4) "12")
(check-expect (display-number 12.6) "13")
(check-expect (display-number -12.6) "-13")
(check-expect (limit-to 0 100 -5) 0)
(check-expect (limit-to 0 100 50) 50)
(check-expect (limit-to 0 100 105) 100)
(check-expect (heading-text 0) "000°")
(check-expect (heading-text 45) "045°")
(check-expect (heading-text 270) "270°")
(check-expect (heading-text 359.6) "000°")
(check-expect (heading-text -90) "270°")

(define EXPECTED-IDLE-THROTTLE
  (place-images
   (list throttle-handle (text "0%" 12 throttle-detail-color))
   (list (make-posn 80 185) (make-posn 60 205))
   throttle-base))
(check-expect (render-throttle 0) EXPECTED-IDLE-THROTTLE)

(define EXPECTED-EAST-COMPASS
  (place-images
   (list compass-hub (rotate -90 compass-needle)
         (text "090°" 12 compass-detail-color))
   (list (make-posn 71 71) (make-posn 71 71) (make-posn 71 133))
   compass-base))
(check-expect (render-compass 90) EXPECTED-EAST-COMPASS)

;; At 10,000 feet the needle returns to zero; the readout retains the altitude.
(define EXPECTED-TEN-THOUSAND-FEET
  (place-images
   (list altimeter-hub altimeter-needle
         (text "10000 FT" 10 altimeter-detail-color))
   (list (make-posn 71 71) (make-posn 71 71) (make-posn 71 133))
   altimeter-base))
(check-expect (render-altimeter 10000) EXPECTED-TEN-THOUSAND-FEET)

;; An overspeed needle stops at 400 knots, while its readout shows 500 knots.
(define EXPECTED-OVERSPEED
  (place-images
   (list airspeed-hub (rotate -135 airspeed-needle)
         (text "500 KT" 10 airspeed-detail-color))
   (list (make-posn 71 71) (make-posn 71 71) (make-posn 71 133))
   airspeed-base))
(check-expect (render-airspeed 500) EXPECTED-OVERSPEED)

;; A descent beyond the scale stops the needle at -2,000 feet/minute.
(define EXPECTED-FAST-DESCENT
  (place-images
   (list vertical-speed-hub (rotate 240 vertical-speed-needle)
         (text "-3000 FT/MIN" 8 vertical-speed-detail-color))
   (list (make-posn 71 71) (make-posn 71 71) (make-posn 71 133))
   vertical-speed-base))
(check-expect (render-vspeed -3000) EXPECTED-FAST-DESCENT)

;; Nose-up 10 degrees moves the landscape down 16 pixels in level bank.
(define EXPECTED-NOSE-UP-HORIZON
  (place-images
   (list (text "PITCH 10°     ROLL 0°" 10 horizon-detail-color)
         horizon-aircraft horizon-window-outline
         (place-image horizon-landscape 74 74 horizon-window))
   (list (make-posn 85 158) (make-posn 85 85)
         (make-posn 85 85) (make-posn 85 85))
   horizon-base))
(check-expect (render-horizon 10 0) EXPECTED-NOSE-UP-HORIZON)

;; Full-panel example verifies instrument placement and display scaling.
(define EXPECTED-PREVIEW-LAYOUT
  (place-images
   (list WHEEL THROTTLE COMPASS ALTIMETER AIRSPEED VERTICAL-SPEED HORIZON
         map-area cockpit)
   (list (make-posn 480 490) (make-posn 290 440) (make-posn 650 450)
         (make-posn 320 290) (make-posn 650 290) (make-posn 205 290)
         (make-posn 480 290) (make-posn 835 415) (make-posn 480 270))
   canvas))
(check-expect
 (compose-cockpit throttle compass altimeter airspeed vertical-speed horizon)
 EXPECTED-PREVIEW-LAYOUT)

;; Every function above is non-recursive; no termination arguments are needed.

;; Public drawing interface; individual artwork pieces remain internal.
(provide render-throttle render-compass render-altimeter render-airspeed
         render-vspeed render-horizon compose-cockpit COCKPIT-PREVIEW)
