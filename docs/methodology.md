# Technical Methodology

## Overview

This document provides a detailed technical explanation of the HiRoCast system's methodology, algorithms, and mathematical formulations.

## Table of Contents

1. [Problem Formulation](#problem-formulation)
2. [Optimization Framework](#optimization-framework)
3. [Fluid Dynamics Integration](#fluid-dynamics-integration)
4. [Robot Kinematics](#robot-kinematics)
5. [Constraint Handling](#constraint-handling)
6. [Validation Strategy](#validation-strategy)

---

## 1. Problem Formulation

### 1.1 Objective

Minimize the transfer time of liquid-filled ladle from start position to end position:

```
minimize: T_total = Σ(Δt_i)
```

where `Δt_i` are time intervals between trajectory waypoints.

### 1.2 Decision Variables

The optimization variables consist of:
- **Time intervals**: `Δt = [Δt₁, Δt₂, ..., Δt_{n-1}]`
- **Joint angles**: `θ = [θ₁, θ₂, ..., θ₆]` for each waypoint

Combined into optimization vector:
```
x = [Δt₁, θ₁₁, θ₁₂, ..., θ₁₆,
     Δt₂, θ₂₁, θ₂₂, ..., θ₂₆,
     ...
     Δt_{n-1}, θ_{n-1,1}, ..., θ_{n-1,6},
     θ_{n,1}, ..., θ_{n,6}]
```

---

## 2. Optimization Framework

### 2.1 Algorithm Selection

**Interior-Point Method** (MATLAB's `fmincon`):
- Handles nonlinear constraints efficiently
- Suitable for large-scale problems
- Provides feasibility mode for difficult constraints

### 2.2 Optimization Settings

```matlab
opts = optimoptions(@fmincon,
    'Algorithm', 'interior-point',
    'MaxFunctionEvaluations', 500000,
    'MaxIterations', 1000,
    'StepTolerance', 1e-10,
    'OptimalityTolerance', 1e-6,
    'SubproblemAlgorithm', 'factorization'
);
```

### 2.3 Multi-Start Strategy

To avoid local minima:
1. Generate initial trajectory using minimum jerk path
2. Run optimization without fluid validation (faster)
3. Use result as warm start for full optimization with CFD validation

---

## 3. Fluid Dynamics Integration

### 3.1 CFD Simulation

**Solver**: OpenFOAM with Volume of Fluid (VOF) method

**Simulation Parameters**:
- Fluid mixtures: Water-Glycerin (0-100% concentrations)
- Mesh resolution: Fine near free surface
- Time step: Adaptive based on Courant number
- Turbulence model: k-ε or LES for accurate sloshing prediction

### 3.2 Sloshing Corridor Concept

Pre-computed "safe corridors" for different ladle orientations:
- **Orientation space**: Discretized rotation angles (Rx, Ry, Rz)
- **Acceleration space**: Maximum allowable acceleration in each direction
- **Angle limits**: φ₁ (in-plane angle), φ₂ (elevation angle)

### 3.3 Real-Time Validation

During optimization, for each candidate trajectory:

1. **Extract ladle orientation**: From forward kinematics
2. **Calculate acceleration vector**: From trajectory derivatives
3. **Find nearest corridor**: Using k-d tree search
4. **Check compliance**: Ensure acceleration within corridor bounds

```matlab
% Angle calculation
phi_1 = CalculateAngleInXYPlane(preferred_direction, actual_direction);
phi_2 = 90 - acos(dot([0 0 1], direction_vector));

% Constraint check
c(end+1) = phi_1 - phi1_max;  % Must be ≤ 0
c(end+1) = phi1_min - phi_1;  % Must be ≤ 0
```

---

## 4. Robot Kinematics

### 4.1 Forward Kinematics

Denavit-Hartenberg (DH) parameters for KUKA KR60:

| Joint | θᵢ | dᵢ | aᵢ | αᵢ |
|-------|----|----|----|----|
| 1 | θ₁ | d₁ | 0 | -90° |
| 2 | θ₂ | 0 | a₂ | 0° |
| 3 | θ₃ | 0 | a₃ | 90° |
| 4 | θ₄ | d₄ | 0 | -90° |
| 5 | θ₅ | 0 | 0 | 90° |
| 6 | θ₆ | d₆ | 0 | 0° |

**Transformation Matrix**:
```
T₀⁶ = T₀¹ · T₁² · T₂³ · T₃⁴ · T₄⁵ · T₅⁶
```

### 4.2 Velocity and Acceleration

Using spline interpolation for smooth trajectories:

**Position**: Cubic spline through waypoints
```
θ(t) = a₀ + a₁t + a₂t² + a₃t³
```

**Velocity**: First derivative
```
θ̇(t) = a₁ + 2a₂t + 3a₃t²
```

**Acceleration**: Second derivative
```
θ̈(t) = 2a₂ + 6a₃t
```

**Jerk**: Third derivative
```
θ⃛(t) = 6a₃
```

---

## 5. Constraint Handling

### 5.1 Equality Constraints

**Boundary Conditions**:
```matlab
% Start and end positions fixed
ceq = [θ_start - θ_0;
       θ_end - θ_final];

% Zero velocity at boundaries
ceq = [θ̇_start - 0;
       θ̇_end - 0];
```

### 5.2 Inequality Constraints

**Joint Limits** (KUKA KR60):
```matlab
θ_min = [-185°, -130°, -100°, -350°, -120°, -350°];
θ_max = [+185°, +14°, +144°, +350°, +120°, +350°];
```

**Velocity Limits**:
```matlab
|θ̇ᵢ| ≤ 400°/s  for all joints
```

**Acceleration Limits**:
```matlab
|θ̈ᵢ| ≤ 200°/s²  for all joints
```

**Jerk Limits**:
```matlab
|θ⃛ᵢ| ≤ 1000°/s³  for all joints
```

**Sloshing Constraints**:
```matlab
% Fluid must stay within safe corridor
c = [phi_1 - phi1_max;
     phi1_min - phi_1;
     phi_2 - phi2_max;
     phi2_min - phi_2];
```

### 5.3 Constraint Violation Handling

- **Soft constraints**: Penalty terms in objective function
- **Hard constraints**: Enforced by optimizer
- **Feasibility mode**: Enabled when initial guess is infeasible

---

## 6. Validation Strategy

### 6.1 Trajectory Validation

**CompleteValidation Function**:
1. Compute trajectory from waypoints and time intervals
2. Calculate TCP (Tool Center Point) positions and orientations
3. Extract acceleration profiles
4. Query CFD database for sloshing limits
5. Return constraint violations

### 6.2 Physical Validation

**Checks performed**:
- ✓ All joint angles within mechanical limits
- ✓ Velocities achievable by motors
- ✓ Accelerations within safe ranges
- ✓ Jerk limits for smooth motion
- ✓ No self-collisions
- ✓ Workspace boundaries respected

### 6.3 Fluid Validation

**Sloshing Analysis**:
- Maximum surface deflection < threshold
- Angular momentum within limits
- No overflow predicted by CFD

### 6.4 Iterative Refinement

```
1. Generate initial trajectory (minimum jerk)
2. Optimize without fluid constraints → Fast solution
3. Validate with CFD → Identify violations
4. Optimize with fluid constraints → Safe solution
5. Fine-tune critical sections → Optimal solution
```

---

## 7. Implementation Details

### 7.1 Spline Generation

Custom spline implementation ensuring:
- C² continuity (continuous acceleration)
- Exact waypoint passage
- Parameterized by time intervals
- Efficient derivative computation

### 7.2 Numerical Stability

**Techniques used**:
- Scaling of optimization variables
- Regularization of ill-conditioned matrices
- Adaptive step sizes
- Gradient checking for constraint functions

### 7.3 Computational Efficiency

**Optimizations**:
- Pre-computed CFD database (offline)
- K-d tree for fast nearest-neighbor search
- Sparse Jacobian matrices
- Parallel evaluation of independent constraints

---

## 8. Results Interpretation

### 8.1 Convergence Criteria

Optimization terminates when:
- First-order optimality < 1e-6
- Step size < 1e-10
- Maximum iterations reached
- Feasible solution found (if in feasibility mode)

### 8.2 Solution Quality Metrics

- **Optimality**: How close to theoretical minimum time
- **Feasibility**: All constraints satisfied
- **Robustness**: Sensitivity to parameter variations
- **Smoothness**: Continuity of derivatives

### 8.3 Performance Comparison

Baseline vs. Optimized:
- Transfer time reduction
- Maximum acceleration comparison
- Sloshing risk assessment
- Energy consumption analysis

---

## References

1. Nocedal, J., & Wright, S. J. (2006). *Numerical Optimization*. Springer.
2. Craig, J. J. (2005). *Introduction to Robotics: Mechanics and Control*. Pearson.
3. Ferziger, J. H., & Perić, M. (2002). *Computational Methods for Fluid Dynamics*. Springer.
4. Betts, J. T. (2010). *Practical Methods for Optimal Control*. SIAM.

---

*Last updated: 2022*
