# MILESTONE

**Instrument-Based Interactive Flight Simulator**

Leonida Ilijoska, Lorenzo Felix, Edoardo Fiorini, as of the 25 November 2026

- Implemented simplified flight physics for thrust, drag, lift, gravity, and stall. Each step updates the aircraft’s position, altitude, airspeed, vertical speed, and heading.
- Connected the physics, keyboard controls, and cockpit in `source/main.rkt`. The simulation starts in flight from an editable initial condition and stops updating at or below zero altitude. Run `source/main.rkt` in DrRacket to start it.
- Added keyboard controls for the first interactive version. Up and Down change pitch, Left and Right change roll, W and S change throttle, and Space levels the aircraft. Banking changes heading through the flight model. Mouse controls and pause and resume are still pending.
- Built the cockpit with an altimeter, airspeed indicator, compass, artificial horizon, vertical speed indicator, and throttle display. The yoke rotates with the aircraft’s roll. The physics uses metric units and the instruments display feet, knots, and feet per minute.
- Revised the data model from the proposal. The local position stores east and north coordinates plus heading so navigation can use the direction of travel. Throttle uses an integer percentage to match the cockpit display and keyboard increments. The `big-bang` loop uses `Aircraft` as its state for this milestone, since the cockpit and physics only need the aircraft’s current values. Destination and flight status are planned for navigation integration.
- Started a separate OpenStreetMap tile prototype that converts geographic coordinates and zoom to tile indices. The moving map, aircraft marker, and destination selection and arrival checks are pending. The tile prototype currently has a position accessor error.
- Added design-recipe examples and tests for flight physics, controls, and cockpit rendering. The flight-physics suite passed all 94 checks. The control-limit test expectations still reflect the earlier pitch and roll limits. Cockpit and keyboard tests could not run in the command-line environment because Racket’s GUI failed to initialize.

