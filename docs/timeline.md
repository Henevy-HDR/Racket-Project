# Flight Simulator — Project Decomposition & Development Timeline

**Course:** Programming Fundamentals 1  
**Project:** Instrument-Based Interactive Flight Simulator  
**Language:** Racket (ISL+)  
**Development Period:** November 11 – December 9, 2026

---

## 1. Project Decomposition

The project is divided into six main components, each responsible for a specific aspect of the flight simulator. Every component contains a set of principal functions that will be developed and integrated into the final application.

### 1.1. Data Structures & State Management

**Purpose:** Define and manage the data representing the aircraft, instruments, and simulation state.

**Main data structures:**
- `Aircraft`: Position, altitude, airspeed, heading, pitch, roll, vertical speed, and throttle.
- `WorldState`: Aircraft, destination, and simulation status.
- `Instrument`: Instrument type, position, and size.
- `FlightStatus`: Current simulation condition.

**Main functions:**
- `initial-aircraft`: Creates the initial aircraft state.
- `initial-world`: Creates the initial simulation state.

### 1.2. Flight Physics

**Purpose:** Simulate aircraft movement using a simplified mathematical model of flight dynamics.

**Main functions:**
- `update-airspeed`: Calculates changes in airspeed based on thrust and drag.
- `update-altitude`: Updates altitude according to vertical speed.
- `update-heading`: Calculates heading changes based on aircraft roll.
- `update-position`: Calculates the aircraft's new X/Y coordinates.
- `update-aircraft`: Combines the physical calculations to produce the next aircraft state.

### 1.3. Aircraft Controls

**Purpose:** Allow users to interact with and control the aircraft through keyboard and mouse inputs.

**Main functions:**
- `handle-key`: Processes keyboard inputs.
- `handle-mouse`: Processes mouse interactions with cockpit controls.
- `set-throttle`: Adjusts engine throttle.
- `set-pitch`: Adjusts aircraft pitch.
- `set-roll`: Adjusts aircraft roll.
- `toggle-pause`: Pauses or resumes the simulation.

### 1.4. Cockpit & Instruments

**Purpose:** Display the aircraft's flight conditions through interactive graphical instruments.

**Main functions:**
- `render-cockpit`: Draws the complete instrument panel.
- `render-altimeter`: Displays aircraft altitude.
- `render-airspeed`: Displays current airspeed.
- `render-compass`: Displays aircraft heading.
- `render-horizon`: Displays pitch and roll.
- `render-vspeed`: Displays vertical speed.
- `render-throttle`: Displays engine throttle.

### 1.5. Map & Navigation

**Purpose:** Display a 2D navigation map showing the aircraft's position, orientation, and destination.

**Main functions:**
- `render-map`: Draws the navigation map.
- `render-aircraft-marker`: Displays the aircraft at its current position and heading.
- `render-destination`: Displays the selected destination.
- `select-destination`: Allows the user to choose a destination.
- `distance-to-destination`: Calculates the distance between the aircraft and its destination.
- `destination-reached?`: Determines whether the aircraft has reached its destination.

The initial implementation will use a simulated 2D map. Live OpenStreetMap integration remains an optional extension.

### 1.6. Main Simulation & Integration

**Purpose:** Connect all components and manage the execution of the complete simulator.

**Main functions:**
- `update-world`: Advances the simulation by updating aircraft movement and state.
- `render-world`: Combines cockpit, navigation map, and status information into the displayed interface.
- `update-flight-status`: Checks and updates the current simulation condition.
- `start-simulator`: Initializes and launches the interactive simulation using `big-bang`.

### 1.7 add render cloud.

**purpose:** make cloud render at the cock pit to make it look better
** main function **
- render clouds
- render sky

---

## 2. Development Timeline

The development period is divided into seven phases, progressing from the initial architecture to the final submission.

| Phase | Dates | Main Activities |
|---|---|---|
| **1. Foundation** | Nov 11–13 | Define data structures, initial world state, constants, and basic simulation loop. |
| **2. Flight Physics & Controls** | Nov 14–18 | Implement aircraft movement, airspeed, altitude, heading, and keyboard controls. |
| **3. Cockpit & Navigation** | Nov 19–23 | Implement graphical instruments, cockpit interface, 2D map, aircraft marker, and destination display. |
| **4. Initial Integration** | Nov 24–25 | Connect the main components, verify basic functionality, prepare and submit the milestone. |
| **5. Core Feature Completion** | Nov 26–30 | Complete mouse controls, destination detection, remaining instruments, and integration improvements. |
| **6. Testing & Refinement** | Dec 1–5 | Test the complete simulator, correct defects, improve usability, and prepare documentation. |
| **7. Finalization** | Dec 6–9 | Freeze features, conduct final verification, package the project, and submit the completed application. |

### 2.1. Key Development Milestones

**November 18 — First Functional Flight**

The simulator should support basic aircraft movement. Keyboard controls should modify flight conditions, and the mathematical model should update position, altitude, airspeed, and heading.

**November 25 — Intermediate Milestone**

A runnable prototype should demonstrate the integration of basic flight physics, instruments, and navigation.

Official submission requirements:
- Current Racket source code.
- README documenting implemented features, progress, and changes.

**December 5 — Feature Completion**

All essential simulator functionality should be implemented, including aircraft controls, flight dynamics, cockpit instruments, navigation, and destination detection.

**December 9 — Final Submission**

The complete project must be submitted by **20:30**, including:
- Racket source code and required resources.
- Updated README.
- User guide.
- Developer guide.

**December 10 — Project Discussion**

Demonstration and technical discussion with the teaching assistants. All team members must be familiar with the complete implementation.

---

## 3. Development Principles

**Incremental development:** Each component should be implemented and tested progressively. The simulator should become functional early in development rather than only after all components have been completed.

**Continuous integration:** Components should be connected as they become available, avoiding unnecessary integration difficulties near the deadlines.

**Modular architecture:** Each component should have clearly defined responsibilities and interfaces, allowing separate development without unnecessary dependencies.

**Testing and documentation:** Functions should follow the course's design recipe, including signatures, purpose statements, examples, and appropriate tests. Documentation should be maintained throughout development.

**Scope management:** Optional features, including stalls, terrain collision detection, audio warnings, takeoff and landing, and live OpenStreetMap integration, should only be considered after the essential simulator is complete and tested.

**Final objective:** Deliver a functional, understandable, tested, and documented flight simulator by December 9, 2026.
