# Repository Structure Guide

This document explains the organization of the HiRoCast repository.

## Directory Layout

```
HiRoCast/
│
├── README.md                    # Main project documentation
├── LICENSE                      # MIT License
├── CONTRIBUTING.md              # Contribution guidelines
├── .gitignore                   # Git ignore patterns
│
├── docs/                        # Documentation
│   ├── methodology.md           # Technical methodology and algorithms
│   ├── api-reference.md         # Function documentation
│   ├── results-analysis.md      # Performance analysis and results
│   ├── STRUCTURE.md             # This file
│   └── assets/                  # Images and diagrams for documentation
│       └── (simulation plots, diagrams, etc.)
│
├── src/                         # Source code (organized by function)
│   ├── optimal-control/         # Optimization algorithms
│   │   ├── HiRoCast_Master.m
│   │   ├── HiRoCast_OptimalControl.m
│   │   ├── KSetUp.m
│   │   ├── KPfadgenerator.m
│   │   └── ...
│   │
│   ├── kinematics/              # Robot kinematics
│   │   ├── vorwaertskinematik.m
│   │   ├── RotationUmX.m
│   │   ├── RotationUmY.m
│   │   ├── RotationUmZ.m
│   │   └── ...
│   │
│   ├── validation/              # Constraint validation
│   │   ├── CompleteValidation.m
│   │   ├── constraintFcnValidation.m
│   │   └── ...
│   │
│   ├── visualization/           # Plotting and visualization
│   │   ├── Bahnzeichnung.m
│   │   ├── CFDBeschleunigungen.m
│   │   ├── show_spline.m
│   │   └── ...
│   │
│   ├── utils/                   # Utility functions
│   │   ├── spline.m
│   │   ├── compute_time.m
│   │   ├── CalculateAngleInXYPlane.m
│   │   └── ...
│   │
│   └── code-generation/         # Robot code generation
│       ├── HiRoCast_GenerateKRLCode.m
│       └── ...
│
├── data/                        # Data files
│   ├── fluid-simulations/       # CFD simulation results
│   │   ├── water-glycerin-mixtures/
│   │   │   ├── 100Wasser0Glycerin/
│   │   │   ├── 50Wasser50Glycerin/
│   │   │   └── ...
│   │   └── simulation-database/
│   │       └── simulationData.txt
│   │
│   └── robot-configurations/    # Robot setup files
│       └── ...
│
├── results/                     # Optimization results
│   ├── trajectories/            # Optimized trajectories
│   ├── performance-metrics/     # Performance data
│   └── visualizations/          # Result plots
│
└── legacy/                      # Archive of old code
    ├── Alt/                     # Old implementations
    └── ...
```

## File Organization Principles

### 1. Source Code (`src/`)
- **Modular**: Functions grouped by purpose
- **Documented**: Each function has header comments
- **Tested**: Test files in same directory with `test_` prefix

### 2. Documentation (`docs/`)
- **Comprehensive**: Technical details and methodology
- **Accessible**: Written for both experts and newcomers
- **Visual**: Includes diagrams and plots

### 3. Data (`data/`)
- **Organized**: By experiment type and date
- **Documented**: README in each subdirectory
- **Versioned**: Large files tracked with Git LFS (optional)

### 4. Results (`results/`)
- **Reproducible**: Include parameters used
- **Timestamped**: Date and version information
- **Analyzed**: Summary statistics and plots

### 5. Legacy (`legacy/`)
- **Archived**: Old code kept for reference
- **Not maintained**: May not work with current version
- **Historical**: Shows project evolution

## Naming Conventions

### Files
- MATLAB functions: `functionName.m` or `FunctionName.m`
- Data files: `descriptive-name_YYMMDD.ext`
- Documentation: `lowercase-with-dashes.md`

### Directories
- Lowercase with hyphens: `optimal-control/`
- Descriptive names: `fluid-simulations/`
- No spaces: Use hyphens instead

## Key Files

### Entry Points
- `src/optimal-control/HiRoCast_Master.m` - Main control script
- `src/optimal-control/KSetUp.m` - Configuration and setup

### Core Algorithms
- `src/optimal-control/HiRoCast_OptimalControl.m` - Optimization
- `src/validation/CompleteValidation.m` - CFD validation
- `src/kinematics/vorwaertskinematik.m` - Forward kinematics

### Utilities
- `src/utils/spline.m` - Trajectory interpolation
- `src/utils/CalculateAngleInXYPlane.m` - Angle calculations

## Data Flow

```
Input Parameters (KSetUp.m)
        ↓
Initial Path (KPfadgenerator.m)
        ↓
Optimization (HiRoCast_OptimalControl.m)
        ↓
Validation (CompleteValidation.m) ←→ CFD Data
        ↓
Results & Visualization
        ↓
KRL Code Generation
```


