# API Reference

## Core Functions

### HiRoCast_Master.m

**Description**: Main control script that orchestrates the entire optimization pipeline.

**Usage**:
```matlab
HiRoCast_Master
```

**Workflow**:
1. Load simulation parameters
2. Generate stable fluid states (CFD)
3. Generate valid robot poses
4. Run optimal control
5. Validate results
6. Generate KRL code for robot

---

### HiRoCast_OptimalControl.m

**Description**: Implements the trajectory optimization using constrained nonlinear programming.

**Key Functions**:

#### `optimization_task(optimization_values)`
**Purpose**: Objective function for minimization

**Input**:
- `optimization_values`: Matrix of [time_intervals, joint_angles]

**Output**:
- `objective`: Total transfer time

**Algorithm**:
```matlab
objective = sum(time_intervals)
```

---

#### `constraintFcnValidation(optimization_values, input_backup)`
**Purpose**: Constraint function with full CFD validation

**Inputs**:
- `optimization_values`: Current optimization variables
- `input_backup`: Initial trajectory for boundary conditions

**Outputs**:
- `c`: Inequality constraints (must be ≤ 0)
- `ceq`: Equality constraints (must be = 0)

**Constraints Enforced**:
- Time intervals > 0
- Joint angle limits
- Velocity limits: ±400°/s
- Acceleration limits: ±200°/s²
- Jerk limits: ±1000°/s³
- Sloshing constraints from CFD
- Boundary conditions (start/end positions)

---

#### `show_spline(solution, window_title)`
**Purpose**: Visualize optimized trajectory

**Inputs**:
- `solution`: Optimized trajectory data
- `window_title`: Plot window title

**Outputs**:
- Figure with 4 subplots per joint:
  - Position vs. time
  - Velocity vs. time
  - Acceleration vs. time
  - Jerk vs. time

---

### KSetUp.m

**Description**: Initialize robot parameters and workspace configuration

**Key Parameters Set**:
- Robot model: KUKA KR60
- Joint limits
- Velocity/acceleration limits
- Start and end positions
- Ladle geometry

**Usage**:
```matlab
KSetUp;
% Parameters now available in workspace
```

---

### KPfadgenerator.m

**Description**: Generate initial minimum-jerk trajectory

**Input** (from workspace):
- `numSamples`: Number of waypoints

**Output**:
- `minJerkPath`: Initial trajectory matrix

**Algorithm**: Quintic polynomial interpolation for minimum jerk

---

### vorwaertskinematik.m

**Description**: Forward kinematics calculation

**Syntax**:
```matlab
[tcp_position, ladle_orientation] = vorwaertskinematik(joint_angles)
```

**Inputs**:
- `joint_angles`: [θ₁, θ₂, θ₃, θ₄, θ₅, θ₆] (radians)

**Outputs**:
- `tcp_position`: [x, y, z] in meters
- `ladle_orientation`: [Rx, Ry, Rz] orientation angles

**Method**: Denavit-Hartenberg transformation matrices

---

### spline.m

**Description**: Generate cubic spline with derivatives

**Syntax**:
```matlab
[pos, vel, acc, jerk, time, indices] = spline(waypoints, time_intervals, plot_flag)
```

**Inputs**:
- `waypoints`: Array of position waypoints
- `time_intervals`: Time between waypoints
- `plot_flag`: Boolean for visualization

**Outputs**:
- `pos`: Position trajectory (sampled)
- `vel`: Velocity trajectory
- `acc`: Acceleration trajectory
- `jerk`: Jerk trajectory
- `time`: Time vector
- `indices`: Waypoint indices in sampled trajectory

---

### CompleteValidation.m

**Description**: Comprehensive trajectory validation with CFD integration

**Syntax**:
```matlab
[c, ceq] = CompleteValidation(time_intervals, base_points)
```

**Inputs**:
- `time_intervals`: Time between waypoints
- `base_points`: Joint angle waypoints

**Outputs**:
- `c`: Inequality constraint violations
- `ceq`: Equality constraint violations

**Validation Steps**:
1. Generate full trajectory from waypoints
2. Compute TCP accelerations
3. Calculate ladle orientations
4. Query CFD database for sloshing limits
5. Check acceleration against safe corridors
6. Return constraint violations

---

### CalculateAngleInXYPlane.m

**Description**: Calculate angle between two vectors projected onto XY plane

**Syntax**:
```matlab
angle = CalculateAngleInXYPlane(vector1, vector2)
```

**Inputs**:
- `vector1`: First 3D vector [x, y, z]
- `vector2`: Second 3D vector [x, y, z]

**Output**:
- `angle`: Angle in degrees (-180° to +180°)

**Use Case**: Determine movement direction relative to preferred sloshing direction

---

## Visualization Functions

### CFDBeschleunigungen.m

**Description**: Visualize CFD acceleration data and sloshing corridors

**Usage**:
```matlab
CFDBeschleunigungen
```

**Outputs**:
- Plots of safe acceleration corridors
- Sloshing angle analysis
- Comparison across fluid mixtures

---

### Bahnzeichnung.m

**Description**: 3D visualization of robot trajectory

**Usage**:
```matlab
Bahnzeichnung
```

**Features**:
- 3D path visualization
- Robot configuration at waypoints
- Ladle orientation indicators
- Workspace boundaries

---

## Utility Functions

### RotationUmX.m, RotationUmY.m, RotationUmZ.m

**Description**: Generate rotation matrices around principal axes

**Syntax**:
```matlab
R = RotationUmX(angle)  % Rotation around X-axis
R = RotationUmY(angle)  % Rotation around Y-axis
R = RotationUmZ(angle)  % Rotation around Z-axis
```

**Input**:
- `angle`: Rotation angle in radians

**Output**:
- `R`: 3×3 rotation matrix

---

### compute_time.m

**Description**: Convert time intervals to cumulative time vector

**Syntax**:
```matlab
time_vector = compute_time(intervals)
```

**Input**:
- `intervals`: Array of time intervals [Δt₁, Δt₂, ...]

**Output**:
- `time_vector`: Cumulative time [0, Δt₁, Δt₁+Δt₂, ...]

---

## Code Generation

### HiRoCast_GenerateKRLCode.m

**Description**: Generate KUKA Robot Language (KRL) code for deployment

**Usage**:
```matlab
HiRoCast_GenerateKRLCode
```

**Output**:
- `.src` file with KRL motion commands
- `.dat` file with position data

**Generated Commands**:
- `PTP`: Point-to-point motion
- `LIN`: Linear motion
- `SPLINE`: Spline motion
- Velocity and acceleration overrides

---

## Data Structures

### Optimization Variables Structure

```matlab
optimization_values = [
    Δt₁, θ₁₁, θ₁₂, θ₁₃, θ₁₄, θ₁₅, θ₁₆;
    Δt₂, θ₂₁, θ₂₂, θ₂₃, θ₂₄, θ₂₅, θ₂₆;
    ...
    Δtₙ₋₁, θₙ₋₁,₁, θₙ₋₁,₂, θₙ₋₁,₃, θₙ₋₁,₄, θₙ₋₁,₅, θₙ₋₁,₆;
    0, θₙ,₁, θₙ,₂, θₙ,₃, θₙ,₄, θₙ,₅, θₙ,₆
]
```

### CFD Simulation Data Structure

```matlab
simu_CFD = [
    Rx, Ry, Rz, nx, ny, nz, phi1, phi2, max_accel;
    ...
]
```

**Columns**:
- `Rx, Ry, Rz`: Ladle orientation (degrees)
- `nx, ny, nz`: Preferred movement direction (unit vector)
- `phi1`: In-plane angle limit (degrees)
- `phi2`: Elevation angle limit (degrees)
- `max_accel`: Maximum safe acceleration (m/s²)

---

## Configuration Files

### Robot Parameters

Defined in `KSetUp.m`:
```matlab
% Joint limits (degrees)
max_jointangle = [185, 14, 144, 350, 120, 350];
min_jointangle = [-185, -130, -100, -350, -120, -350];

% Velocity limits (degrees/second)
max_velocity = [400, 400, 400, 400, 400, 400];

% Acceleration limits (degrees/second²)
max_acceleration = [200, 200, 200, 200, 200, 200];

% Jerk limits (degrees/second³)
max_jerk = [1000, 1000, 1000, 1000, 1000, 1000];
```

---

## Error Handling

### Common Errors

**"ESKALATION/ERROR in place/spline"**
- **Cause**: Spline interpolation failed
- **Solution**: Check time intervals are positive and waypoints are valid

**"Angle not in corridor"**
- **Cause**: Trajectory violates sloshing constraints
- **Solution**: Reduce acceleration or adjust path

**"Optimization terminated: No feasible solution"**
- **Cause**: Constraints too restrictive
- **Solution**: Relax constraints or improve initial guess

---

## Performance Tips

1. **Use warm start**: Run without validation first, then with validation
2. **Adjust waypoint count**: More waypoints = more flexibility but slower
3. **Pre-compute CFD data**: Avoid real-time CFD simulations
4. **Parallel evaluation**: Use parallel toolbox for constraint evaluation
5. **Gradient checking**: Verify constraint gradients for faster convergence

---

*For questions or issues, please open a GitHub issue.*
